#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
root=/opt/fourthis
sha=${1:?reviewed SHA required}
release=${2:?verified release directory required}
[[ $EUID == 0 && $sha =~ ^[0-9a-f]{40}$ ]] || exit 2
[[ -f "$root/.env" && -f "$root/compose.yaml" ]] || exit 2
[[ ! -e "$root/recovery-required" && ! -e "$root/deploy-in-progress" ]] || exit 3
exec 9>"$root/deploy.lock"
flock -n 9 || exit 0
cd "$root"
python3 - "$release" "$sha" <<'PY'
import hashlib, pathlib, re, sys, json, tarfile
root = pathlib.Path(sys.argv[1]).resolve()
expected = {'image.tar.gz', 'compose.yaml', 'database/schema.sql', 'commit.txt'}
seen = set()
for line in (root / 'SHA256SUMS').read_text().splitlines():
    match = re.fullmatch(r'([0-9a-f]{64})  ([A-Za-z0-9_./-]+)', line)
    if not match or match[2] not in expected or match[2] in seen: raise SystemExit(2)
    seen.add(match[2])
    with (root / match[2]).open('rb') as stream:
        digest = hashlib.file_digest(stream, 'sha256').hexdigest()
    if digest != match[1]: raise SystemExit(2)
if seen != expected or (root/'commit.txt').read_text().strip() != sys.argv[2]: raise SystemExit(2)
image = root / 'image.tar.gz'
if image.stat().st_size > 1024 * 1024 * 1024: raise SystemExit(2)
with tarfile.open(image, 'r:gz') as archive:
    members = []
    total = 0
    for item in archive:
        members.append(item)
        total += item.size
        if total > 3 * 1024 * 1024 * 1024 or len(members) > 10000: raise SystemExit(2)
        if item.issym() or item.islnk() or item.name.startswith('/') or '..' in pathlib.PurePosixPath(item.name).parts: raise SystemExit(2)
    manifest_member = archive.getmember('manifest.json')
    if manifest_member.size > 1024 * 1024: raise SystemExit(2)
    manifests = json.load(archive.extractfile(manifest_member))
    if len(manifests) != 1 or manifests[0].get('RepoTags') != ['fourthis:' + sys.argv[2]]: raise SystemExit(2)
    config_name = manifests[0]['Config']
    config_member = archive.getmember(config_name)
    if config_member.size > 4 * 1024 * 1024: raise SystemExit(2)
    raw = archive.extractfile(config_member).read()
    digest = hashlib.sha256(raw).hexdigest()
    if config_name not in [digest + '.json', 'blobs/sha256/' + digest]: raise SystemExit(2)
    config = json.loads(raw)
    runtime = config.get('config', {})
    if config.get('os') != 'linux' or config.get('architecture') != 'amd64': raise SystemExit(2)
    if runtime.get('Labels', {}).get('org.opencontainers.image.revision') != sys.argv[2]: raise SystemExit(2)
    if runtime.get('User') != 'app' or runtime.get('Cmd') != ['catalina.sh', 'run']: raise SystemExit(2)
    if runtime.get('Entrypoint') not in [None, []] or runtime.get('WorkingDir') != '/usr/local/tomcat': raise SystemExit(2)
PY
cmp -s "$release/compose.yaml" compose.yaml || { echo 'compose_review_required'; exit 4; }
cmp -s "$release/database/schema.sql" database/schema.sql || { echo 'schema_review_required'; exit 4; }
old_image=$(sed -n 's/^APP_IMAGE=//p' .env)
[[ $old_image =~ ^fourthis:[0-9a-f]{40}$ ]] || exit 2
db_before=$(timeout 20 docker compose ps -q db)
[[ -n "$db_before" ]] || exit 2
old_app=$(timeout 20 docker compose ps -q app)
[[ -n "$old_app" ]] || exit 2
[[ $(timeout 20 docker inspect --format '{{.Config.Image}}' "$old_app") == "$old_image" ]] || exit 3
[[ $(cat deployed.sha) == "${old_image#fourthis:}" ]] || exit 3
timeout 180 docker load --input "$release/image.tar.gz" >/dev/null
[[ $(timeout 20 docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' "fourthis:$sha") == "$sha" ]] || exit 2
cp -p .env .env.previous
cp -p deployed.sha deployed.previous
switched=0
healthy() {
  for attempt in {1..12}; do
    if curl --fail --silent --max-time 12 http://127.0.0.1:3401/health >/dev/null; then return 0; fi
    sleep 5
  done
  return 1
}
clear_marker() {
  python3 - <<'PY'
import os
for name in ['.env', 'deployed.sha']:
    with open(name, 'rb') as state:
        os.fsync(state.fileno())
directory = os.open('.', os.O_DIRECTORY)
try:
    os.fsync(directory)
    os.unlink('deploy-in-progress')
    os.fsync(directory)
finally:
    os.close(directory)
PY
}
finish() {
  result=$?
  trap - EXIT
  trap '' TERM INT
  if [[ $result != 0 && $switched == 1 ]]; then
    recovery_failed=0
    printf '%s\n' "$sha" > failed.sha || recovery_failed=1
    if cp -p .env.previous .env; then
      if ! timeout 120 docker compose up -d --no-deps app >/dev/null 2>&1 || ! healthy; then
        recovery_failed=1
      fi
    else
      recovery_failed=1
    fi
    cp -p deployed.previous deployed.sha || recovery_failed=1
    if [[ $recovery_failed == 1 ]]; then
      printf '%s\n' 'manual_recovery_required' > recovery-required || true
    else
      clear_marker || printf '%s\n' 'durability_recovery_required' > recovery-required
    fi
  fi
  exit "$result"
}
trap finish EXIT
trap 'exit 1' TERM INT
python3 - <<'PY'
import os
with open('deploy-in-progress', 'x') as marker:
    marker.write('application_switch_started\n')
    marker.flush()
    os.fsync(marker.fileno())
directory = os.open('.', os.O_DIRECTORY)
os.fsync(directory)
os.close(directory)
PY
switched=1
python3 - "$sha" <<'PY'
import os, pathlib, re, sys
path = pathlib.Path('.env')
text, count = re.subn(r'^APP_IMAGE=.*$', 'APP_IMAGE=fourthis:' + sys.argv[1], path.read_text(), flags=re.M)
if count != 1: raise SystemExit(2)
temporary = path.with_suffix('.env.next')
temporary.write_text(text)
temporary.chmod(0o600)
os.replace(temporary, path)
PY
timeout 120 docker compose up -d --no-deps app >/dev/null
[[ $(timeout 20 docker inspect --format '{{.Config.Image}}' "$(timeout 20 docker compose ps -q app)") == "fourthis:$sha" ]] || exit 5
[[ $(timeout 20 docker inspect --format '{{.Image}}' "$(timeout 20 docker compose ps -q app)") == "$(timeout 20 docker image inspect --format '{{.Id}}' "fourthis:$sha")" ]] || exit 5
healthy
[[ $(timeout 20 docker compose ps -q db) == "$db_before" ]] || exit 5
printf '%s\n' "$sha" > deployed.next
mv deployed.next deployed.sha
switched=0
clear_marker
printf '%s\n' 'deployment_success=true database_container_unchanged=true'
