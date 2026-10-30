# 4this CI 이벤트 배포 연결

이 변경은 기존 `CI` (`.github/workflows/ci.yml`)가 main push를 성공적으로 검증한 뒤, 별도 `Fourthis verified event deploy`가 전용 SSH 명령을 호출하도록 준비합니다. 서버 설치·키 등록·GitHub secret 설정·타이머 전환은 이 커밋으로 수행되지 않습니다.

## 요청과 응답 계약

배포 workflow는 저장소를 checkout하지 않습니다. webhook의 run ID/SHA만 입력으로 받고 GitHub canonical run API에서 같은 저장소, main, push, CI 경로, completed/success, 첫 번째 run attempt를 다시 검증합니다. PR·fork·다른 workflow·다른 SHA·진행 중/실패 run은 SSH 호출 전에 거부합니다.

호출 명령은 `event-deploy-fourthis <40자리 소문자 SHA> <run ID>`입니다. 프로젝트명·경로·이미지·셸 명령은 입력할 수 없습니다. SSH는 전용 키와 고정 known_hosts를 사용하며 임시 키 파일은 0600 권한으로 생성하고 종료 시 제거합니다.

필요한 repository secrets:

- `FOURTHIS_DEPLOY_TARGET`: 승인된 전용 SSH 대상
- `FOURTHIS_DEPLOY_SSH_KEY`: 4this forced-command에만 등록한 전용 키
- `FOURTHIS_DEPLOY_KNOWN_HOSTS`: 검증된 서버 host-key pin

서버 v2는 `status` (`verified` 또는 `already_deployed`), `sha`, `requested_run_id`, `deployed_run_id`, `artifact_run_id`, `artifact_id`, `artifact_digest`, `image`를 반환합니다. workflow는 SHA와 모든 run ID가 요청과 일치하고, artifact ID가 양의 정수이며 artifact digest와 실제 image ID가 SHA256 형식인지 확인해야 성공합니다. 4this는 같은 SHA라도 다른 run의 기존 receipt로 성공 처리하지 않습니다.

서버는 canonical main/run/artifact API를 별도로 확인하고 artifact ID·digest·중복 여부, 릴리스 및 image revision을 검증합니다. 기존 manager→deploy 잠금을 사용하고, 실제 상태·건강·DB 및 다른 컨테이너의 보존 검사를 거친 뒤 receipt를 롤백 범위 안에서 기록합니다. 예전 배포에 receipt가 없으면 `unverified_legacy`이며 run/image 출처를 추정해서 채우지 않습니다.

## 충돌과 복구

배포는 `cancel-in-progress: false` 및 `queue: max`로 직렬화합니다. 서버의 exit 75 + 정확한 `event_deploy_failed:lock_timeout`만 최대 20분 동안 재시도합니다. 네트워크 실패, 다른 exit 75, 검증 실패는 자동 재시도하지 않고 workflow를 실패 처리합니다.

`workflow_dispatch`는 main에서만 사용할 수 있습니다. 원래 성공한 첫 attempt의 정확한 run ID와 40자리 SHA를 입력해 같은 검증 경로를 다시 실행합니다. canonical CI run의 재실행으로 `run_attempt`가 2 이상이 된 경우는 서버 정책상 거부되며 별도 검토가 필요합니다. 만료된 artifact나 이미 이동한 main은 성공으로 처리하지 않습니다.

## 최초 활성화 순서

1. 서버 v2의 실제 보존 가드/receipt 훅·설치 트랜잭션 synthetic 검증과 독립 검토를 완료합니다. 현재 서버의 다른 관리 키와 connector를 포함한 최신 inventory를 다시 확인해야 하며 이전 snapshot으로 설치를 승인하지 않습니다.
2. 별도 승인된 서버 설치 절차로 4this forced-command 키/진입점만 추가합니다. DB·SMTP·기존 접근 권한은 변경하지 않습니다.
3. 승인된 전용 값을 위 세 secrets에 등록합니다. 값 자체를 로그나 문서에 남기지 않습니다.
4. 이 첫 변경은 `.github/`와 `scripts/`를 수정하므로 일반 배포의 보호 소스 변경 검사에 걸립니다. 정확한 첫 main SHA/run/artifact와 보호 소스 차이를 별도 검토한 baseline 승격이 필요합니다. 이를 통과시키려고 일반 guard를 완화하거나 자동으로 baseline을 덮어쓰지 않습니다.
5. baseline 승격·receipt·실제 상태를 확인한 뒤 별도 승인된 타이머 전환을 수행합니다. 이 커밋은 타이머나 서비스를 조작하지 않습니다.
6. 이후 일반 애플리케이션 변경은 main push CI 성공 이벤트로 배포하고 receipt와 실제 상태를 확인합니다.

## 검증

`python3 -m unittest discover -s scripts/deploy -p 'test_event_workflow.py' -v`

12개 테스트는 실제 YAML 안의 inline Python과 job 조건식을 실행합니다. canonical API·SSH는 synthetic 응답으로 고정하므로 실제 GitHub 요청이나 서버 연결이 발생하지 않습니다. 정상 호출, PR/fork/다른 workflow 거부, 수동 복구, 잘못된 receipt, 잠금 재시도·예산 소진, 비잠금 오류를 검증합니다. 기존 CI에 위 명령 하나를 추가했으며 애플리케이션·DB·메일 로직은 변경하지 않았습니다.

## 2026-10-30 활성화 검증

최초 보호 소스 승격과 같은 SHA/run의 수동 이벤트 복구를 검증했다. 이 문서 갱신의 main CI가 성공하면 새 SHA의 이벤트 배포와 서버 영수증·이미지·DB 및 다른 서비스 보존을 대조한다. 신규 이벤트 검증 후 기존 타이머 전환을 마친다.
