import importlib.util
import pathlib
import tempfile
import unittest
from unittest.mock import Mock, patch

spec = importlib.util.spec_from_file_location("poll", pathlib.Path(__file__).with_name("poll-main.py"))
poll = importlib.util.module_from_spec(spec)
spec.loader.exec_module(poll)
SHA = "a" * 40

class PollTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.directory.name)
        (self.root / "deployed.sha").write_text("b" * 40)
        self.root_patch = patch.object(poll, "ROOT", self.root)
        self.root_patch.start()
        poll.deploy_process = None

    def tearDown(self):
        self.root_patch.stop()
        self.directory.cleanup()

    def test_unverified_main_never_deploys(self):
        with patch.object(poll, "gh", side_effect=[{"sha": SHA}, {"workflow_runs": []}]), patch.object(poll.subprocess, "Popen") as deploy:
            poll.main()
            deploy.assert_not_called()

    def test_wrong_sha_or_pull_request_run_cannot_deploy(self):
        runs = [{"head_sha": "c" * 40, "event": "push", "conclusion": "success", "id": 1},
                {"head_sha": SHA, "event": "pull_request", "conclusion": "success", "id": 2}]
        with patch.object(poll, "gh", side_effect=[{"sha": SHA}, {"workflow_runs": runs}]), patch.object(poll.subprocess, "Popen") as deploy:
            poll.main()
            deploy.assert_not_called()

    def test_failed_sha_requires_review(self):
        (self.root / "failed.sha").write_text(SHA)
        with patch.object(poll, "gh", return_value={"sha": SHA}), patch.object(poll.subprocess, "Popen") as deploy:
            poll.main()
            deploy.assert_not_called()

    def test_main_change_during_download_cannot_deploy(self):
        run = {"head_sha": SHA, "event": "push", "conclusion": "success", "id": 1}
        with patch.object(poll, "gh", side_effect=[{"sha": SHA}, {"workflow_runs": [run]}, {"status": "ahead", "files": []}, {"sha": "c" * 40}]), patch.object(poll.subprocess, "run"), patch.object(poll.subprocess, "Popen") as deploy:
            poll.main()
            deploy.assert_not_called()

    def test_verified_same_main_downloads_named_image_then_deploys(self):
        run = {"head_sha": SHA, "event": "push", "conclusion": "success", "id": 1}
        process = Mock(); process.wait.return_value = 0
        with patch.object(poll, "gh", side_effect=[{"sha": SHA}, {"workflow_runs": [run]}, {"status": "ahead", "files": [{"filename": "src/main/java/Example.java"}]}, {"sha": SHA}]), patch.object(poll.subprocess, "run") as download, patch.object(poll.subprocess, "Popen", return_value=process) as deploy:
            poll.main()
            self.assertIn("fourthis-" + SHA, download.call_args_list[1].args[0])
            self.assertEqual(deploy.call_args.args[0][1], SHA)

    def test_deployment_or_workflow_changes_require_review(self):
        run = {"head_sha": SHA, "event": "push", "conclusion": "success", "id": 1}
        for name in [".github/workflows/ci.yml", "scripts/deploy-app.sh", "database/schema.sql", "Dockerfile"]:
            with self.subTest(name=name), patch.object(poll, "gh", side_effect=[{"sha": SHA}, {"workflow_runs": [run]}, {"status": "ahead", "files": [{"filename": name}]}]), patch.object(poll.subprocess, "Popen") as deploy:
                poll.main()
                deploy.assert_not_called()

    def test_stop_gives_shell_rollback_time(self):
        poll.deploy_process = Mock()
        poll.deploy_process.poll.return_value = None
        with self.assertRaises(SystemExit): poll.stop(15, None)
        poll.deploy_process.terminate.assert_called_once()
        poll.deploy_process.wait.assert_called_once_with(timeout=540)

if __name__ == "__main__":
    unittest.main()
