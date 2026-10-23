#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
root=/opt/fourthis
sha=${1:?reviewed SHA required}
release=${2:?verified release directory required}
[[ $EUID == 0 && $sha =~ ^[0-9a-f]{40}$ ]] || exit 2
[[ -f "$root/.env" && -f "$root/compose.yaml" ]] || exit 2
[[ ! -e "$root/recovery-required" ]] || exit 3
exec 9>"$root/deploy.lock"
flock -n 9 || exit 0
cd "$root"
python3 - "$release" "$sha" <<'PY'
import hashlib, pathlib, re, sys
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
finish() {
  result=$?
  trap - EXIT TERM INT
  if [[ $result != 0 && $switched == 1 ]]; then
    printf '%s\n' "$sha" > failed.sha
    cp -p .env.previous .env
    if ! timeout 120 docker compose up -d --no-deps app >/dev/null 2>&1 || ! healthy; then
      printf '%s\n' 'manual_recovery_required' > recovery-required
    fi
    cp -p deployed.previous deployed.sha || printf '%s\n' 'state_recovery_required' > recovery-required
  fi
  exit "$result"
}
trap finish EXIT
trap 'exit 1' TERM INT
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
healthy
[[ $(timeout 20 docker compose ps -q db) == "$db_before" ]] || exit 5
printf '%s\n' "$sha" > deployed.next
mv deployed.next deployed.sha
switched=0
printf '%s\n' 'deployment_success=true database_container_unchanged=true'
