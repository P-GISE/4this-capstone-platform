# 4this 새 환경 배포

2026-10-24. 기존 학교/GitLab DB와 SMTP·AI 키를 사용하지 않는 신규 데이터 환경이다. 실제 서버 설치와 공개 DNS는 아직 수행하지 않았다.

## 경계

- 앱: Tomcat 9, Java 21, Java 17 API 기준 WAR. `127.0.0.1:3401`만 노출한다.
- 전용 Compose 프로젝트 `fourthis`, DB 내부 네트워크 `private`, 앱 전용 bridge `web`, MariaDB 11.4, `database`·`uploads` 볼륨을 사용한다. DB 포트는 게시하지 않는다.
- 앱 메모리 상한 768MiB, DB 384MiB. 실제 사용량은 초기 기동 후 확인해야 한다.
- 새 스키마는 소스 쿼리 계약을 복원한 것이다. 기존 운영 스키마와 동일하다고 주장하지 않는다. [스키마 근거](schema-contract.md)를 함께 검토한다.
- 메일·AI는 기본 비활성이다. 비활성 메일 요청은 계정·비밀번호 변경 전에 503, AI 변경 요청은 컨트롤러 진입 전에 503으로 거절한다. 앱의 bridge는 외부 통신도 가능하므로 비활성화는 앱 설정 경계이며, 외부 키를 활성화하려면 새 키와 별도 운영 검토가 필요하다.
- 일반 회원가입은 학생 역할만 허용한다. 교수·직원·조교·관리자 역할은 기존 관리 경로에서 부여한다. 이메일 인증 요구는 유지한다.
- 세션 쿠키는 HttpOnly·Secure·SameSite=Lax, URL 세션 전달은 사용하지 않는다. 앱은 HTTPS 공개 경로에서 사용해야 한다.
- 쓰기 요청의 Origin 또는 Origin이 없는 경우 Referer가 `APP_ORIGIN`과 정확히 일치해야 한다. 둘 다 없는 요청은 403이다. 프록시가 사용자 Origin을 덮어쓰면 안 된다.

## 최초 설치 계획 — 실행 전 검토 필요

1. S2의 기존 컨테이너 ID·이미지·시작 시각, 3401 미사용, 여유 메모리·디스크를 다시 기록한다. 기존 FactLens·FocusAI·공유 터널은 변경하지 않는다.
2. `/opt/fourthis`를 root 전용으로 만들고 검토된 `compose.yaml`, `database/schema.sql`, 성공 CI의 image artifact를 배치한다. 새 DB 암호 두 개는 서버에서 생성해 root 0600 `.env`에 저장한다. 명령 출력·문서·Git에 암호를 남기지 않는다.
3. artifact의 `SHA256SUMS`, commit, 이미지 OCI revision을 모두 검증한다. `.env`에는 실제 승인된 `APP_ORIGIN`과 `APP_IMAGE=fourthis:<40자리 commit>`을 넣는다.
4. `docker compose up -d db`로 새 전용 볼륨만 초기화한다. 기존 이름의 볼륨이 있으면 중단하고 소유권을 확인한다. 기존 DB 접속·복사·이전은 하지 않는다.
5. `docker compose up -d app` 후 `/health` 200·로그인 JSP·권한 경계·새 볼륨/업로드 영속성을 확인한다. health 200은 전체 기능 검증이 아니다.
6. 기존 서비스의 컨테이너 ID·시작 시각을 대조한다. 공개 DNS는 별도 승인 후 연결한다. 새 주소를 연결하기 전 아래의 미확인 보안 경계를 해결한다.

## 최초 관리자

`AdminBootstrap`은 HTTP 엔드포인트가 없는 서버 내부 CLI다. `users`가 비어 있고 DB host가 Compose의 `db`, DB명이 `fourthis`일 때만 동작한다. 일반 회원 이메일 인증의 우회 경로로 노출하지 않는다.

서버에서 새 관리자 이름·새 20자 이상 난수 암호·운영자가 지정한 이메일을 root 0600 JSON 파일에 저장한다. JSON 키는 `confirmation`(`fresh-fourthis`), `username`, `password`, `email`이다. 파일 내용과 암호를 셸 인자·로그에 표시하지 않는다. 다음 명령은 파일을 표준입력으로 읽는다.

```sh
docker compose exec -T app java -cp '/usr/local/tomcat/webapps/ROOT/WEB-INF/classes:/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*' com.example.test.config.AdminBootstrap < /root/fourthis-bootstrap.json
```

성공 출력은 `administrator_created=true`뿐이다. 첫 사용자 존재 시 재실행을 거절하고 트랜잭션 실패 시 롤백한다. 로그인 정보 전달 방법을 운영자와 정하고 JSON 임시 파일은 전달 완료 후 제거한다. 이 절차는 아직 서버에서 실행하지 않았다.

## CI와 자동 배포

CI는 새 `fourthis_schema_test` MariaDB에서 합성 데이터로 검증하고, Docker 이미지를 빌드한 후 별도 Compose DB를 띄워 HTTP 경계를 확인한다. 업무 본문·쿠키를 아티팩트에 저장하지 않는다. 합성 자격증명은 CI에만 사용하며 서버에 재사용하지 않는다.

`poll-main.py`는 기존 서버 ubuntu GitHub 인증으로 main의 동일 SHA, push 이벤트, 성공 CI를 확인하고 해당 이름의 이미지 artifact를 받는다. 다운로드 뒤 main이 바뀌면 중단한다. `deploy-app.sh`는 hash·OCI revision·현재 이미지/state 일치와 compose/schema 동일성을 확인하고 앱만 `--no-deps`로 교체한다. DB·네트워크·터널은 갱신하지 않는다.

서버의 root 소유 trusted copy로 poller·app deploy 스크립트를 설치해야 한다. artifact에 담긴 배포 코드를 실행하지 않는다. `.env`·state는 root 0600, 배포기 디렉터리는 root 0750, systemd unit/timer는 root 0644다. 최초 `deployed.sha`는 실제 실행 이미지 commit과 일치시킨다. timer 설치·활성화 및 통합 경로 검증은 아직 수행하지 않았다.

일반 앱 소스 변경은 자동 배포 대상이다. `.github/`, `scripts/`, `docker/`, `database/`, Dockerfile, Compose, pom.xml, Docker ignore 변경과 비교 범위가 300파일 이상인 경우는 `deployment_definition_review_required`로 멈춘다. 검토 후 새 trusted 배포 정의 및 실제 이미지·state를 함께 갱신하는 수동 배포가 필요하다. 이 경계를 자동 우회하는 승인 파일은 제공하지 않는다.

## 롤백

앱 교체 실패 시 `.env.previous`와 이전 이미지로 앱만 재기동한다. 성공 건강 상태를 확인하고 이전 `deployed.sha`를 복원한다. 실패 commit은 `failed.sha`로 자동 재시도를 차단한다. 롤백 실패는 `recovery-required`를 남겨 이후 자동 배포를 거절한다. 수동 복구 시 실제 image/env/state를 확인하기 전 차단 파일을 지우지 않는다.

최초 변경 전에 `deploy-in-progress`를 fsync해 남기고 정상 배포 또는 검증된 롤백에서만 제거한다. 복구 중 TERM/INT는 무시하며 env·state 복원은 독립적으로 시도한다. 이미지 load 전에 단일 `fourthis:<sha>` 태그·config digest·OCI revision·비root 실행·고정 명령·압축 및 해제 크기를 검사한다.

최초 설치 실패 시 새 앱·새 DB 컨테이너를 중지할 수 있지만 새 볼륨도 자동 삭제하지 않는다. 삭제는 데이터가 필요 없는 새 합성 환경인지 별도 확인해야 한다. 기존 다른 서비스는 롤백 대상이 아니다.

## 검증 한계

초기 CI에서 앱·DB 내부 health는 정상이었지만 `internal` 네트워크만 연결한 앱의 호스트 포트가 게시되지 않아 호스트 GET 연결이 거절됐다. 앱에만 전용 bridge를 추가하고 DB는 내부망에 유지했다. [Docker 네트워킹 문서](https://docs.docker.com/engine/network/)의 frontend bridge/backend internal 구성에 따른다.

- 확인됨: 로컬 설정·외부 연동 차단·Origin/관리자·세션 교체·프로젝트 task/아카이브 수정 소유권 회귀. 스키마 회귀는 별도 근거를 따른다.
- 미확인: 실제 S2 기동, 전체 사용자 흐름, 실제 iPhone, 메일·AI 새 키 연동, 자동 배포의 전체 설치·롤백 경로.
- 미확인/공개 전 필수 검토: 기존 채팅방·메시지·다운로드 파일별 소유권 전체, 다른 도메인에서의 WebSocket 접속과 구독 권한, 전체 업로드 파일명 처리. 핵심 경계 패치와 정적 검사 통과가 이 범위의 안전을 보장하지 않는다.
- 확인됨: 이전 소스의 SMTP 비밀 상수와 API key 번들 fallback은 현재 소스에서 제거했다. Git 과거 이력은 수정하지 않았으므로 기존 키 교체는 별도 운영 작업이다.
