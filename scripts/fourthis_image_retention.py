#!/usr/bin/env python3
"""Root-only, bounded Fourthis image-cache retention; dry-run unless --apply."""
from contextlib import ExitStack, contextmanager
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import subprocess
import sys
from typing import Final

APP_ROOT: Final = Path('/opt/fourthis')
LOCKS: Final = (Path('/var/lib/fourthis-deploy/install.lock'), APP_ROOT / 'deploy.lock')
MIN_AGE: Final = timedelta(hours=24)
MAX_IMAGES: Final = 2
MAX_BYTES: Final = 3 * 1024**3
TARGET_FREE: Final = 8 * 1024**3
SHA: Final = re.compile(r'[0-9a-f]{40}')
IMAGE_ID: Final = re.compile(r'sha256:[0-9a-f]{64}')
TAG: Final = re.compile(r'fourthis:([0-9a-f]{40})')
SAFE_ENV: Final = {'PATH': '/usr/sbin:/usr/bin:/sbin:/bin', 'LANG': 'C.UTF-8'}


class RetentionBlocked(RuntimeError):
    """No further cleanup is allowed when a preservation check fails."""


def require(condition: bool, reason: str) -> None:
    if not condition:
        raise RetentionBlocked(reason)


def identity(info: os.stat_result) -> tuple[int, ...]:
    return (info.st_dev, info.st_ino, info.st_uid, info.st_gid,
            info.st_mode, info.st_nlink, info.st_size, info.st_mtime_ns)


@contextmanager
def trusted_file(path: Path, writable: bool = False):
    for parent in path.parents:
        info = parent.lstat()
        require(stat.S_ISDIR(info.st_mode) and info.st_uid == 0 and info.st_gid == 0
                and not info.st_mode & 0o022, 'unsafe_parent')
    before = path.lstat()
    require(stat.S_ISREG(before.st_mode) and before.st_uid == 0 and before.st_gid == 0
            and stat.S_IMODE(before.st_mode) == 0o600 and before.st_nlink == 1
            and before.st_size <= 65536, 'unsafe_file')
    flags = (os.O_RDWR if writable else os.O_RDONLY) | os.O_NOFOLLOW | os.O_NONBLOCK
    with os.fdopen(os.open(path, flags), 'rb') as stream:
        require(identity(os.fstat(stream.fileno())) == identity(before), 'file_changed')
        yield stream
        require(identity(os.fstat(stream.fileno())) == identity(before)
                and identity(path.lstat()) == identity(before), 'file_changed')


def read_state(path: Path) -> bytes:
    with trusted_file(path) as stream:
        data = stream.read(65537)
        require(len(data) <= 65536, 'oversized_state')
        return data


@contextmanager
def deployment_locks():
    with ExitStack() as stack:
        for path in LOCKS:
            stream = stack.enter_context(trusted_file(path, writable=True))
            require(os.fstat(stream.fileno()).st_size == 0, 'invalid_lock')
            try:
                fcntl.flock(stream.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError as error:
                raise RetentionBlocked('deployment_lock_busy') from error
        yield


def docker(*arguments: str) -> str:
    result = subprocess.run(['/usr/bin/docker', '--host=unix:///var/run/docker.sock', *arguments], env=SAFE_ENV,
                            capture_output=True, text=True, timeout=45, check=False)
    require(result.returncode == 0, 'docker_command_failed')
    require(len(result.stdout) <= 2 * 1024**2, 'oversized_docker_response')
    return result.stdout


@dataclass(frozen=True, slots=True)
class Image:
    image_id: str
    tags: tuple[str, ...]
    size: int
    created: datetime
    revision: str


def images(references: list[str]) -> list[Image]:
    require(0 < len(references) <= 200, 'invalid_image_count')
    output = docker('image', 'inspect', '--format',
                    '{"id":{{json .Id}},"tags":{{json .RepoTags}},"size":{{json .Size}},'
                    '"created":{{json .Created}},"revision":'
                    '{{json (index .Config.Labels "org.opencontainers.image.revision")}}}',
                    *references)
    result = []
    for line in output.splitlines():
        value = json.loads(line)
        require(bool(IMAGE_ID.fullmatch(value['id'])) and type(value['size']) is int
                and value['size'] >= 0 and isinstance(value['tags'], list)
                and all(isinstance(tag, str) for tag in value['tags']), 'invalid_image_metadata')
        created = datetime.fromisoformat(value['created'].replace('Z', '+00:00'))
        require(created.tzinfo is not None, 'invalid_image_time')
        result.append(Image(value['id'], tuple(value['tags']), value['size'], created,
                            value['revision'] or ''))
    require(len(result) == len(references), 'incomplete_image_metadata')
    return result


@dataclass(frozen=True, slots=True)
class Snapshot:
    current: str
    rollback: str
    protected_ids: frozenset[str]
    used_ids: frozenset[str]
    state_digest: str


def snapshot() -> Snapshot:
    require(not any(os.path.lexists(APP_ROOT / marker)
                    for marker in ('deploy-in-progress', 'recovery-required')), 'recovery_marker')
    state = [read_state(APP_ROOT / name) for name in
             ('deployed.sha', 'deployed.previous', '.env', '.env.previous')]
    current, rollback = (value.decode().strip() for value in state[:2])
    require(bool(SHA.fullmatch(current)) and bool(SHA.fullmatch(rollback)), 'invalid_release_sha')
    for value, sha in zip(state[2:], (current, rollback)):
        settings = [line for line in value.decode().splitlines() if line.startswith('APP_IMAGE=')]
        require(settings == ['APP_IMAGE=fourthis:' + sha], 'environment_state_mismatch')
    protected = images(['fourthis:' + current, 'fourthis:' + rollback])
    for image, sha in zip(protected, (current, rollback)):
        require('fourthis:' + sha in image.tags and image.revision == sha, 'release_image_mismatch')
    app = json.loads(docker('inspect', '--format',
        '{"image":{{json .Image}},"tag":{{json .Config.Image}},"running":{{json .State.Running}}}',
        'fourthis-app-1'))
    require(app['running'] is True and app['image'] == protected[0].image_id
            and app['tag'] == 'fourthis:' + current, 'running_release_mismatch')
    containers = docker('container', 'ls', '--all', '--quiet', '--no-trunc').splitlines()
    require(0 < len(containers) <= 500
            and all(re.fullmatch(r'[0-9a-f]{64}', value) for value in containers), 'invalid_container_list')
    used = docker('container', 'inspect', '--format', '{{.Image}}', *containers).splitlines()
    require(len(used) == len(containers) and all(IMAGE_ID.fullmatch(value) for value in used),
            'incomplete_container_images')
    return Snapshot(current, rollback, frozenset(image.image_id for image in protected),
                    frozenset(used), hashlib.sha256(b'\0'.join(state)).hexdigest())


def candidates(found: list[Image], protected: Snapshot, now: datetime) -> list[Image]:
    result = []
    total = 0
    for image in sorted(found, key=lambda item: (item.created, item.image_id)):
        tag = TAG.fullmatch(image.tags[0]) if len(image.tags) == 1 else None
        if (not tag or image.revision != tag.group(1) or image.image_id in protected.protected_ids
                or image.image_id in protected.used_ids or now - image.created < MIN_AGE):
            continue
        if len(result) == MAX_IMAGES:
            break
        if total + image.size > MAX_BYTES:
            continue
        result.append(image)
        total += image.size
    return result


def free_bytes() -> int:
    usage = os.statvfs(APP_ROOT)
    return usage.f_bavail * usage.f_frsize


def log(event: str, **values) -> None:
    print(json.dumps({'event': event, **values}, sort_keys=True), flush=True)


def run(apply: bool) -> int:
    require(os.geteuid() == 0, 'root_required')
    with deployment_locks():
        storage = Path(docker('info', '--format', '{{.DockerRootDir}}').strip())
        require(storage.is_absolute() and storage.is_dir()
                and storage.stat().st_dev == APP_ROOT.stat().st_dev, 'different_storage_filesystem')
        before = snapshot()
        available = free_bytes()
        refs = sorted(set(docker('image', 'ls', '--filter', 'reference=fourthis:*',
                                 '--quiet', '--no-trunc').splitlines()))
        require(bool(refs) and all(IMAGE_ID.fullmatch(ref) for ref in refs), 'invalid_image_list')
        planned = candidates(images(refs), before, datetime.now(timezone.utc)) if available < TARGET_FREE else []
        log('plan', apply=apply, current=before.current, rollback=before.rollback,
            protected_ids=sorted(before.protected_ids), free_bytes=available, target_bytes=TARGET_FREE,
            candidates=[{'id': item.image_id, 'tag': item.tags[0], 'size_upper_bound': item.size}
                        for item in planned], max_images=MAX_IMAGES, max_bytes=MAX_BYTES, min_age_hours=24)
        removed = 0
        if apply:
            for item in planned:
                if free_bytes() >= TARGET_FREE:
                    break
                fresh = snapshot()
                require((fresh.current, fresh.rollback, fresh.protected_ids, fresh.state_digest) ==
                        (before.current, before.rollback, before.protected_ids, before.state_digest),
                        'release_changed')
                current = images([item.image_id])
                require(current == [item] and candidates(current, fresh, datetime.now(timezone.utc)) == [item],
                        'candidate_changed')
                docker('image', 'rm', '--no-prune', item.image_id)
                removed += 1
                log('removed', id=item.image_id, tag=item.tags[0])
            after = snapshot()
            require((after.current, after.rollback, after.protected_ids, after.state_digest) ==
                    (before.current, before.rollback, before.protected_ids, before.state_digest), 'release_changed')
        remaining = free_bytes()
        log('result', removed=removed, free_bytes=remaining, measured_free_delta=remaining-available,
            headroom_ok=remaining >= TARGET_FREE, apply=apply)
        return 0 if not apply or remaining >= TARGET_FREE else 3


if __name__ == '__main__':
    try:
        require(sys.argv[1:] in ([], ['--apply']), 'invalid_arguments')
        raise SystemExit(run(sys.argv[1:] == ['--apply']))
    except (RetentionBlocked, OSError, ValueError, KeyError, TypeError, subprocess.TimeoutExpired) as error:
        # Do not print Docker stderr, state contents, or exception details containing data.
        log('blocked', reason=str(error) if isinstance(error, RetentionBlocked) else type(error).__name__)
        raise SystemExit(1) from None
