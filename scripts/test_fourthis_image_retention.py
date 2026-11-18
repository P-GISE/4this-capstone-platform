import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from datetime import datetime, timedelta, timezone

if os.name == 'posix':
    import fourthis_image_retention as retention


@unittest.skipUnless(os.name == 'posix', 'Linux production policy')
class SelectionTests(unittest.TestCase):
    def setUp(self):
        self.now = datetime(2026, 11, 18, tzinfo=timezone.utc)
        self.old = retention.Image('sha256:' + 'c'*64, ('fourthis:' + 'c'*40,),
                                   1024**3, self.now-timedelta(days=2), 'c'*40)
        self.protected = retention.Snapshot('a'*40, 'b'*40,
            frozenset({'sha256:'+'a'*64, 'sha256:'+'b'*64}), frozenset(), 'state')

    def test_old_unreferenced_owned_image_is_selected(self):
        self.assertEqual(retention.candidates([self.old], self.protected, self.now), [self.old])

    def test_current_and_rollback_image_ids_are_preserved(self):
        for value in ('a', 'b'):
            image = retention.Image('sha256:'+value*64, ('fourthis:'+value*40,),
                                    1, self.old.created, value*40)
            self.assertEqual(retention.candidates([image], self.protected, self.now), [])

    def test_stopped_container_reference_is_preserved(self):
        protected = retention.Snapshot('a'*40, 'b'*40, self.protected.protected_ids,
                                       frozenset({self.old.image_id}), 'state')
        self.assertEqual(retention.candidates([self.old], protected, self.now), [])

    def test_multitag_unknown_tag_and_wrong_revision_are_preserved(self):
        for tags, revision in ((self.old.tags+('other:tag',), self.old.revision),
                               (('fourthis:latest',), self.old.revision),
                               (self.old.tags, 'd'*40)):
            image = retention.Image(self.old.image_id, tags, self.old.size, self.old.created, revision)
            self.assertEqual(retention.candidates([image], self.protected, self.now), [])

    def test_younger_than_24_hours_and_future_images_are_preserved(self):
        for created in (self.now-timedelta(hours=23), self.now+timedelta(hours=1)):
            image = retention.Image(self.old.image_id, self.old.tags, 1, created, self.old.revision)
            self.assertEqual(retention.candidates([image], self.protected, self.now), [])

    def test_count_limit_is_two(self):
        found = [retention.Image('sha256:'+value*64, ('fourthis:'+value*40,),
                 1, self.old.created, value*40) for value in ('c', 'd', 'e')]
        self.assertEqual(len(retention.candidates(found, self.protected, self.now)), 2)

    def test_total_size_limit_is_three_gib(self):
        found = [retention.Image('sha256:'+value*64, ('fourthis:'+value*40,),
                 2*1024**3, self.old.created, value*40) for value in ('c', 'd')]
        self.assertEqual(len(retention.candidates(found, self.protected, self.now)), 1)

    def test_oversized_old_image_does_not_block_smaller_candidates(self):
        huge = retention.Image('sha256:'+'d'*64, ('fourthis:'+'d'*40,),
                                retention.MAX_BYTES+1, self.old.created-timedelta(days=1), 'd'*40)
        self.assertEqual(retention.candidates([huge,self.old], self.protected, self.now), [self.old])


@unittest.skipUnless(os.name == 'posix' and hasattr(os, 'geteuid') and os.geteuid() == 0,
                     'real root-owned files and flock require isolated Linux root')
class GuardTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix='fourthis-retention-test-', dir='/root')
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        for name, value in {'deployed.sha':'a'*40, 'deployed.previous':'b'*40,
                            '.env':'APP_IMAGE=fourthis:'+'a'*40,
                            '.env.previous':'APP_IMAGE=fourthis:'+'b'*40,
                            'install.lock':'', 'deploy.lock':''}.items():
            path = self.root/name
            path.write_text(value)
            path.chmod(0o600)
        self.addCleanup(patch.stopall)
        patch.object(retention, 'APP_ROOT', self.root).start()
        patch.object(retention, 'LOCKS', (self.root/'install.lock',self.root/'deploy.lock')).start()
        patch.object(retention, 'free_bytes', return_value=6*1024**3).start()
        patch.object(retention, 'log').start()
        self.removed = []
        self.used = ['sha256:'+'a'*64, 'sha256:'+'f'*64]
        self.image_data = {value:{'id':'sha256:'+value*64, 'tags':['fourthis:'+value*40],
            'size':1024**3,'created':'2026-01-01T00:00:00Z','revision':value*40}
            for value in ('a','b','c','d')}
        patch.object(retention, 'docker', side_effect=self.docker).start()

    def docker(self, *args):
        if args[0] == 'info':
            return str(self.root)
        if args[:2] == ('image','inspect'):
            refs = args[4:]
            return '\n'.join(json.dumps(self.image_data[ref.split(':')[1][0]]) for ref in refs)
        if args[0] == 'inspect':
            return json.dumps({'image':'sha256:'+'a'*64,'tag':'fourthis:'+'a'*40,'running':True})
        if args[:2] == ('container','ls'):
            return '\n'.join(value*64 for value in ('1','2'))
        if args[:2] == ('container','inspect'):
            return '\n'.join(self.used)
        if args[:2] == ('image','ls'):
            return '\n'.join(item['id'] for item in self.image_data.values())
        if args[:3] == ('image','rm','--no-prune'):
            self.removed.append(args[3])
            del self.image_data[args[3].split(':')[1][0]]
            return ''
        raise AssertionError('unexpected Docker call')

    def test_dry_run_never_removes_images(self):
        self.assertEqual(retention.run(False), 0)
        self.assertEqual(self.removed, [])

    def test_apply_is_bounded_and_second_run_removes_nothing(self):
        self.assertEqual(retention.run(True), 3)
        self.assertEqual(set(self.removed), {'sha256:'+'c'*64,'sha256:'+'d'*64})
        self.removed.clear()
        self.assertEqual(retention.run(True), 3)
        self.assertEqual(self.removed, [])
        self.assertEqual(set(self.image_data), {'a','b'})

    def test_low_headroom_without_candidates_reports_unmet_target(self):
        self.image_data = {key:value for key,value in self.image_data.items() if key in ('a','b')}
        self.assertEqual(retention.run(True), 3)
        self.assertEqual(self.removed, [])

    def test_sufficient_headroom_removes_nothing(self):
        with patch.object(retention, 'free_bytes', return_value=retention.TARGET_FREE):
            self.assertEqual(retention.run(True), 0)
        self.assertEqual(self.removed, [])

    def test_recovery_marker_blocks_before_removal(self):
        for marker in ('deploy-in-progress','recovery-required'):
            with self.subTest(marker=marker):
                (self.root/marker).touch()
                with self.assertRaisesRegex(retention.RetentionBlocked, 'recovery_marker'):
                    retention.run(True)
                (self.root/marker).unlink()
        self.assertEqual(self.removed, [])

    def test_malformed_state_and_environment_mismatch_block(self):
        for name, value in (('deployed.sha','bad'),('.env.previous','APP_IMAGE=fourthis:'+'a'*40)):
            with self.subTest(name=name):
                original=(self.root/name).read_text()
                (self.root/name).write_text(value)
                with self.assertRaises(retention.RetentionBlocked):
                    retention.run(True)
                (self.root/name).write_text(original)
        self.assertEqual(self.removed, [])

    def test_missing_rollback_image_blocks(self):
        del self.image_data['b']
        with self.assertRaises(KeyError):
            retention.run(True)
        self.assertEqual(self.removed, [])

    def test_symlink_state_is_rejected(self):
        (self.root/'deployed.sha').unlink()
        (self.root/'deployed.sha').symlink_to(self.root/'deployed.previous')
        with self.assertRaisesRegex(retention.RetentionBlocked, 'unsafe_file'):
            retention.run(True)
        self.assertEqual(self.removed, [])

    def test_same_deployment_lock_blocks_cleanup(self):
        with retention.deployment_locks():
            with self.assertRaisesRegex(retention.RetentionBlocked, 'deployment_lock_busy'):
                retention.run(True)
        self.assertEqual(self.removed, [])

    def test_new_container_reference_before_delete_blocks(self):
        real_snapshot = retention.snapshot
        calls = 0
        def changing_snapshot():
            nonlocal calls
            calls += 1
            if calls > 1:
                self.used[1] = 'sha256:'+'c'*64
            return real_snapshot()
        with patch.object(retention,'snapshot',side_effect=changing_snapshot):
            with self.assertRaisesRegex(retention.RetentionBlocked, 'candidate_changed'):
                retention.run(True)
        self.assertEqual(self.removed, [])

    def test_docker_failure_blocks_without_removal(self):
        with patch.object(retention,'docker',side_effect=retention.RetentionBlocked('docker_command_failed')):
            with self.assertRaisesRegex(retention.RetentionBlocked, 'docker_command_failed'):
                retention.run(True)
        self.assertEqual(self.removed, [])

    def test_multitag_added_after_plan_blocks_removal(self):
        real_snapshot = retention.snapshot
        calls = 0
        def changing_snapshot():
            nonlocal calls
            calls += 1
            if calls > 1:
                self.image_data['c']['tags'].append('another-project:stable')
            return real_snapshot()
        with patch.object(retention,'snapshot',side_effect=changing_snapshot):
            with self.assertRaisesRegex(retention.RetentionBlocked, 'candidate_changed'):
                retention.run(True)
        self.assertEqual(self.removed, [])

    def test_environment_changed_after_plan_blocks_removal(self):
        real_snapshot = retention.snapshot
        calls = 0
        def changing_snapshot():
            nonlocal calls
            calls += 1
            if calls > 1:
                (self.root/'.env').write_text('APP_IMAGE=fourthis:'+'a'*40+'\nNEW_SETTING=changed')
            return real_snapshot()
        with patch.object(retention,'snapshot',side_effect=changing_snapshot):
            with self.assertRaisesRegex(retention.RetentionBlocked, 'release_changed'):
                retention.run(True)
        self.assertEqual(self.removed, [])

    def test_different_docker_storage_filesystem_blocks_removal(self):
        def other_storage(*args):
            return '/proc' if args[0] == 'info' else self.docker(*args)
        with patch.object(retention,'docker',side_effect=other_storage):
            with self.assertRaisesRegex(retention.RetentionBlocked, 'different_storage_filesystem'):
                retention.run(True)
        self.assertEqual(self.removed, [])


if __name__ == '__main__':
    unittest.main()
