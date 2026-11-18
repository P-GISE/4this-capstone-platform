# 2026-11-18 배포 잠금 복구

PR #14의 CI는 통과했지만 이벤트 배포가 `/var/lock/fourthis-install.lock` 누락으로 실패했다. `/var/lock`은 휘발성 `/run/lock`을 가리키는데, 설치된 root entry가 해당 파일의 device/inode까지 고정하고 있었다. 부팅 후 파일을 다시 만들어도 기존 pin과 일치하지 않는다.

서버 전용 배포기의 아래 세 파일에서 설치 잠금을 `/var/lib/fourthis-deploy/install.lock`으로 옮겼다. 앱의 `/opt/fourthis/deploy.lock`은 유지했다.

- `/usr/local/libexec/fourthis-root-entry`
- `/usr/local/libexec/fourthis-event/trusted_files.py`
- `/usr/local/libexec/fourthis-event/event_operator.py`

새 잠금은 root 소유 일반 파일, 0600, 단일 link로 생성했고 entry의 lock identity 및 변경 모듈의 SHA-256 pin을 함께 갱신했다. 원본은 `/var/lib/fourthis-deploy/security-lock-repair-20261118`에 보존했다. 실제 중복 lock 획득이 거부되고 baseline·canonical metadata 검증이 통과하는 것을 확인했다. 서버 재설치 시 이 영구 경로를 사용하고 새 파일의 identity와 검토한 소스 hash를 등록해야 한다. 오래된 설치본을 그대로 덮어쓰면 문제가 재발한다.

추가로 여유 공간이 배포기 기준인 6 GiB 미만이었다. 실행 중 이미지와 직전 rollback 이미지를 유지한 채, 컨테이너에서 참조하지 않는 이 앱의 오래된 이미지 6개와 이미 해제된 오래된 중복 artifact ZIP만 정리했다. DB 볼륨·백업과 다른 앱 이미지는 변경하지 않았고 공간 기준도 낮추지 않았다.

검증한 앱 commit은 `b31c899305c0cbd186048517120a05b8e5de8990`, CI는 [44180804180](https://github.com/P-GISE/4this-capstone-platform/actions/runs/44180804180)이다. 배포 결과는 [44181375262](https://github.com/P-GISE/4this-capstone-platform/actions/runs/44181375262)의 최신 attempt와 서버 영수증을 함께 확인한다. 과거 실패 attempt는 복구 이력으로 유지한다.

복구 후 위 이벤트 배포가 성공했다. 실행 SHA·배포 state는 목표 commit과 같고 image는 `sha256:3b0f6e1d1fb3e91da14ea4a35a212032dda7065bd70a5f29afa721d50305fac9`다. 원본 `/health`가 `ok`를 반환했다. DB 컨테이너는 재시작하지 않았으며 기존 image와 시작 시각을 유지했다. 강제 서버 재부팅과 실제 사용자 문의·채팅 데이터 입력은 검증에 포함하지 않았다.
