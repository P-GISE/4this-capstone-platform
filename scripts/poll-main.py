import json
import pathlib
import re
import subprocess
import tempfile
import signal

REPO = "P-GISE/4this-capstone-platform"
ROOT = pathlib.Path("/opt/fourthis")
deploy_process = None

def stop(signum, frame):
    if deploy_process is not None and deploy_process.poll() is None:
        deploy_process.terminate()
        deploy_process.wait(timeout=540)
    raise SystemExit(1)

def gh(*arguments):
    return json.loads(subprocess.check_output(
        ["runuser", "-u", "ubuntu", "--", "gh", *arguments], timeout=60))

def main():
    global deploy_process
    sha = gh("api", f"repos/{REPO}/commits/main")["sha"]
    if not re.fullmatch(r"[0-9a-f]{40}", sha):
        raise RuntimeError("Invalid commit identifier")
    if (ROOT / "recovery-required").exists() or (ROOT / "deploy-in-progress").exists():
        raise RuntimeError("Recovery required")
    if (ROOT / "failed.sha").exists() and (ROOT / "failed.sha").read_text().strip() == sha:
        print("failed_commit_requires_review=true")
        return
    deployed = (ROOT / "deployed.sha").read_text().strip()
    if not re.fullmatch(r"[0-9a-f]{40}", deployed):
        raise RuntimeError("Invalid deployed identifier")
    if deployed == sha:
        print("already_deployed=true")
        return
    runs = gh("api", f"repos/{REPO}/actions/workflows/ci.yml/runs?branch=main&status=success&per_page=20")["workflow_runs"]
    run = next((item for item in runs if item["head_sha"] == sha
                and item["event"] == "push" and item["conclusion"] == "success"), None)
    if run is None:
        print("waiting_for_verified_main=true")
        return
    comparison = gh("api", f"repos/{REPO}/compare/{deployed}...{sha}")
    files = comparison.get("files", [])
    protected = (".github/", "scripts/", "docker/", "database/")
    blocked = comparison.get("status") not in ["ahead", "identical"] or len(files) >= 300
    for change in files:
        for name in [change.get("filename", ""), change.get("previous_filename", "")]:
            if name.startswith(protected) or name in ["Dockerfile", "compose.yaml", "pom.xml", ".dockerignore"]:
                blocked = True
    if blocked:
        print("deployment_definition_review_required=true")
        return
    with tempfile.TemporaryDirectory(prefix="fourthis-release-") as directory:
        pathlib.Path(directory).chmod(0o755)
        subprocess.run(["chown", "ubuntu:ubuntu", directory], check=True)
        subprocess.run(["runuser", "-u", "ubuntu", "--", "gh", "run", "download", str(run["id"]),
                        "--repo", REPO, "--name", f"fourthis-{sha}", "--dir", directory], check=True, timeout=240)
        if gh("api", f"repos/{REPO}/commits/main")["sha"] != sha:
            print("main_changed_retry_later=true")
            return
        deploy_process = subprocess.Popen(["/usr/local/libexec/fourthis-deploy-app", sha, directory])
        try:
            result = deploy_process.wait(timeout=720)
        except subprocess.TimeoutExpired:
            stop(signal.SIGTERM, None)
        if result != 0:
            raise RuntimeError("Application deployment failed")

if __name__ == "__main__":
    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    main()
