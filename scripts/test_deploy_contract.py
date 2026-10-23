import hashlib
import io
import json
import pathlib
import shutil
import subprocess
import sys
import tarfile
import tempfile
import unittest
import types
from unittest.mock import Mock, patch

SCRIPT = pathlib.Path(__file__).with_name('deploy-app.sh').read_text()
VALIDATOR = SCRIPT.split("<<'PY'\n", 1)[1].split('\nPY\n', 1)[0]
FINISH = 'finish() {' + SCRIPT.split('finish() {', 1)[1].split('\ntrap finish EXIT', 1)[0]
CLEAR_MARKER = SCRIPT.split('clear_marker() {', 1)[1].split("<<'PY'\n", 1)[1].split('\nPY\n', 1)[0]
SHA = 'a' * 40

class DurabilityOrderTest(unittest.TestCase):
    def test_marker_is_removed_only_after_file_and_directory_sync(self):
        events = []
        handle = Mock(); handle.__enter__ = Mock(return_value=handle); handle.__exit__ = Mock(return_value=False)
        handle.fileno.return_value = 11
        fake = types.SimpleNamespace(O_DIRECTORY=0, open=lambda *args: 77,
            fsync=lambda fd: events.append(('sync', fd)),
            unlink=lambda name: events.append(('unlink', name)), close=lambda fd: events.append(('close', fd)))
        with patch.dict(sys.modules, {'os': fake}), patch('builtins.open', return_value=handle):
            exec(CLEAR_MARKER, {})
        self.assertEqual([('sync', 11), ('sync', 11), ('sync', 77),
                          ('unlink', 'deploy-in-progress'), ('sync', 77), ('close', 77)], events)

    def test_failed_sync_does_not_remove_marker(self):
        handle = Mock(); handle.__enter__ = Mock(return_value=handle); handle.__exit__ = Mock(return_value=False)
        fake = types.SimpleNamespace(fsync=Mock(side_effect=OSError('synthetic')), unlink=Mock())
        with patch.dict(sys.modules, {'os': fake}), patch('builtins.open', return_value=handle):
            with self.assertRaises(OSError): exec(CLEAR_MARKER, {})
        fake.unlink.assert_not_called()

class ArchiveContractTest(unittest.TestCase):
    def validate(self, tags, extra=False, user='app'):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            (root / 'database').mkdir()
            (root / 'database/schema.sql').write_text('synthetic')
            (root / 'compose.yaml').write_text('synthetic')
            (root / 'commit.txt').write_text(SHA)
            config = json.dumps({'os': 'linux', 'architecture': 'amd64', 'config': {
                'User': user, 'Cmd': ['catalina.sh', 'run'], 'WorkingDir': '/usr/local/tomcat',
                'Labels': {'org.opencontainers.image.revision': SHA}}}).encode()
            config_name = hashlib.sha256(config).hexdigest() + '.json'
            manifests = [{'Config': config_name, 'RepoTags': tags, 'Layers': []}]
            if extra: manifests.append({'Config': config_name, 'RepoTags': ['other-project:latest'], 'Layers': []})
            with tarfile.open(root / 'image.tar.gz', 'w:gz') as archive:
                for name, data in [('manifest.json', json.dumps(manifests).encode()), (config_name, config)]:
                    item = tarfile.TarInfo(name); item.size = len(data)
                    archive.addfile(item, io.BytesIO(data))
            names = ['image.tar.gz', 'compose.yaml', 'database/schema.sql', 'commit.txt']
            (root / 'SHA256SUMS').write_text('\n'.join(hashlib.sha256((root / name).read_bytes()).hexdigest() + '  ' + name for name in names))
            return subprocess.run([sys.executable, '-c', VALIDATOR, directory, SHA], capture_output=True).returncode

    def test_single_reviewed_image_is_accepted(self):
        self.assertEqual(0, self.validate(['fourthis:' + SHA]))

    def test_other_service_tags_and_multiple_images_are_rejected(self):
        self.assertNotEqual(0, self.validate(['other-project:latest']))
        self.assertNotEqual(0, self.validate(['fourthis:' + SHA, 'other-project:latest']))
        self.assertNotEqual(0, self.validate(['fourthis:' + SHA], extra=True))

    def test_root_image_is_rejected(self):
        self.assertNotEqual(0, self.validate(['fourthis:' + SHA], user='root'))

class RollbackContractTest(unittest.TestCase):
    def probe(self, fail_copy=False, terminate=False):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            for name, content in {'.env': 'new', '.env.previous': 'old', 'deployed.sha': SHA,
                                  'deployed.previous': 'b' * 40, 'deploy-in-progress': 'started'}.items():
                (root / name).write_text(content)
            wrapper = '''set -Eeuo pipefail
sha=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
switched=1
healthy() { return 0; }
clear_marker() { rm -f deploy-in-progress; }
timeout() { shift; "$@"; }
docker() { printf '%s\n' "$*" >> docker-trace; }
cp() {
  printf '%s\n' "$*" >> copy-trace
  if [[ "$2" == .env.previous ]]; then
    REPLACEMENT
  fi
  command cp "$@"
}
''' + FINISH + '\ntrap finish EXIT\nfalse\n'
            action = 'return 42' if fail_copy else ('kill -TERM $$' if terminate else ':')
            script = root / 'probe.sh'; script.write_text(wrapper.replace('REPLACEMENT', action))
            process = subprocess.run([shutil.which('bash') or 'bash', 'probe.sh'], cwd=directory, capture_output=True)
            return {'exit': process.returncode, 'env': (root / '.env').read_text(),
                    'state': (root / 'deployed.sha').read_text(),
                    'marker': (root / 'recovery-required').exists(),
                    'in_progress': (root / 'deploy-in-progress').exists(),
                    'copy': (root / 'copy-trace').read_text(),
                    'docker': (root / 'docker-trace').read_text() if (root / 'docker-trace').exists() else ''}

    def test_env_restore_failure_still_restores_state_and_blocks_future_deploy(self):
        result = self.probe(fail_copy=True)
        self.assertNotEqual(0, result['exit'])
        self.assertEqual('new', result['env'])
        self.assertEqual('b' * 40, result['state'])
        self.assertTrue(result['marker'])
        self.assertTrue(result['in_progress'])

    def test_second_term_does_not_interrupt_verified_rollback(self):
        result = self.probe(terminate=True)
        self.assertNotEqual(0, result['exit'])
        self.assertEqual('old', result['env'])
        self.assertEqual('b' * 40, result['state'])
        self.assertFalse(result['marker'])
        self.assertFalse(result['in_progress'])
        self.assertEqual('compose up -d --no-deps app\n', result['docker'])

if __name__ == '__main__': unittest.main()
