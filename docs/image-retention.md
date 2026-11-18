# 4this 이미지 캐시 정리

운영 서버의 여유 공간 부족 재발을 줄이는 **4this 전용** 정책이다. `docker system/image/builder prune`이나 볼륨 삭제를 사용하지 않는다. DB·업로드·백업 파일 및 다른 프로젝트 이미지를 정리하지 않는다.

## 보존과 정리 조건

`scripts/fourthis_image_retention.py`는 기본적으로 dry-run이다. 실제 삭제는 root가 `--apply`로 실행할 때만 한다.

1. 기존 배포기와 같은 순서로 `/var/lib/fourthis-deploy/install.lock`, `/opt/fourthis/deploy.lock`을 비차단 독점 획득한다. 배포 진행·복구 marker가 있거나 lock을 얻지 못하면 삭제하지 않는다.
2. root 소유 0600 단일 일반 파일만 읽으며 경로의 symlink·쓰기 가능한 상위 디렉터리·열기 전후 inode/내용 크기 변경을 거부한다. 현재/직전 SHA, `.env`/`.env.previous`의 이미지, 실제 앱 컨테이너 및 두 이미지의 OCI revision이 일치해야 한다. rollback 이미지가 없어도 삭제하지 않는다.
3. 현재와 직전 rollback **이미지 ID**, 실행·중지 상태를 포함한 모든 컨테이너 참조 이미지를 보존한다. 다른 태그가 추가된 이미지도 보존한다.
4. 태그가 `fourthis:<40자리 SHA>` 하나뿐이고 OCI revision이 같으며 이미지 생성 시각으로 24시간이 지난 경우만 후보가 된다. 24시간은 마지막 사용 시각이 아니다. 오래된 빌드가 최근 rollback 목록에서 빠졌다면 후보가 될 수 있다.
5. 실행 한 번당 최대 2개, `docker image inspect` Size 합계 최대 3 GiB까지 처리한다. 이 값은 공유 layer 때문에 실제 회수량과 다를 수 있다. 후보별로 상태·태그·모든 컨테이너 참조를 다시 확인한 뒤 **이미지 ID를 지정해 `docker image rm --no-prune`** 한다. `--force`는 사용하지 않는다.

Docker는 로컬 UNIX socket을 명시하며 정제된 환경에서 실행한다. DockerRootDir와 `/opt/fourthis`가 같은 파일시스템인지 확인한 뒤 실제 여유 공간을 측정한다. 명령 오류나 불완전한 metadata에서는 정리를 멈춘다. Docker socket의 권한 자체는 강력하므로 이 스크립트와 unit은 검토한 root 소유 파일로만 설치해야 한다.

여유 공간 목표는 8 GiB, 기존 배포기의 최소 6 GiB 조건은 그대로다. 목표를 채우면 추가 삭제를 멈춘다. 보존 조건이 목표보다 우선이며, 삭제 가능한 후보가 없으면 보존 이미지를 지우지 않고 `headroom_ok=false`, exit 3을 기록한다. 새 이미지의 증가량이나 다른 서비스의 사용량 때문에 용량 부족이 재발할 가능성은 남는다. 그 경우 별도의 용량·보관 정책 검토가 필요하다.

## 설치와 실행

실제 운영 적용 전에 `sudo python3 scripts/test_fourthis_image_retention.py -v`를 격리된 Linux 환경에서 실행하고, 검토한 스크립트의 dry-run 후보·보존 ID를 확인한다. 테스트는 합성 root 소유 파일과 Docker 대역을 사용하며 실제 Docker 이미지를 삭제하지 않는다.

검토한 파일만 root가 설치한다. 앱 GitHub CI가 운영 코드를 자동 설치하지 않는다.

```sh
sudo install -o root -g root -m 0600 scripts/fourthis_image_retention.py /usr/local/libexec/fourthis_image_retention.py
sudo install -o root -g root -m 0644 scripts/deploy/fourthis-image-retention.service /etc/systemd/system/fourthis-image-retention.service
sudo install -o root -g root -m 0644 scripts/deploy/fourthis-image-retention.timer /etc/systemd/system/fourthis-image-retention.timer
sudo systemd-analyze verify /etc/systemd/system/fourthis-image-retention.service /etc/systemd/system/fourthis-image-retention.timer
sudo python3 -I -B /usr/local/libexec/fourthis_image_retention.py
```

후보 승인 후에만 `systemctl daemon-reload`, 서비스 실행, `systemctl enable --now fourthis-image-retention.timer`를 수행한다. timer는 6시간마다 실행하고 5분 이내 지연을 둔다. 서비스 timeout은 5분, `Restart`는 없으므로 여유 공간 경고로 즉시 재시도하지 않는다. unit은 경로 쓰기를 두 기존 lock으로 제한하지만 Docker daemon 권한을 격리하는 보안 경계라고 주장하지 않는다.

`journalctl -u fourthis-image-retention.service`에서 `plan`, 개별 `removed`, `result` JSON을 확인한다. 태그·이미지 ID·삭제 수·전후 실제 여유 공간만 기록하며 환경파일 내용·Docker stderr·비밀번호는 기록하지 않는다. 실패 시 marker나 보존 state를 먼저 지우지 않는다.

## 파일 캐시와 한계

기존 event operator의 artifact ZIP·해제된 이미지 tar는 `TemporaryDirectory` 안에서 생성되어 정상 종료와 예외 처리 때 정리된다. 이번 정책은 수동 배포 이력·백업 디렉터리의 파일을 자동 삭제하지 않는다. 강제 종료 후 남은 임시 디렉터리는 복구 상태를 먼저 검토한다.

첫 검토 dry-run의 보존 대상은 현재 `103193fa...`와 rollback `b31c899...`, 후보는 미참조 `33be679...` 이미지 1개였다. 실제 공유 layer 회수량과 목표 도달 여부는 실행 결과로 확인한다. 강제 재부팅, 운영 DB 변경 및 사용자 데이터 입력은 이 정리 검증에 포함하지 않는다.
