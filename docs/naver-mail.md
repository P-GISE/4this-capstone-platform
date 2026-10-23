# 네이버 메일 연결 준비

이 변경은 메일 기본값을 비활성으로 유지한다. 네이버 계정의 SMTP 사용 설정, 애플리케이션 비밀번호 발급, 실제 발송은 별도 승인 후 수행한다. 이번 로컬 검증은 합성 H2 DB와 모의 전송만 사용했다.

## 배포 환경키

| 키 | 설정 |
|---|---|
| EMAIL_ENABLED | 기본 `false`. 승인 후에만 `true` |
| SMTP_HOST | 네이버는 `smtp.naver.com` |
| SMTP_PORT | 네이버 SSL은 `465`. 기존 STARTTLS 환경은 `587`을 명시 |
| SMTP_SECURITY | `ssl` 또는 `starttls`만 허용. 생략·평문 모드는 거부 |
| SMTP_USERNAME | 승인된 발송 계정의 인증 식별자. 값은 문서·Git·로그에 저장하지 않음 |
| SMTP_PASSWORD | 승인 후 준비한 애플리케이션 비밀번호. 기존 일반 로그인 비밀번호를 추측하거나 재사용하지 않음 |
| SMTP_FROM | 승인된 단일 발신 주소. 계정의 발신 권한과 일치해야 함 |
| APP_ORIGIN | 현재 공개 정본의 HTTPS origin. path나 끝의 `/` 없이 유지 |

`ssl`은 연결 시작부터 TLS를 사용하고 STARTTLS를 끈다. `starttls`는 SMTP의 TLS 전환을 필수로 한다. 두 모드 모두 서버 인증서·호스트 검증과 10초 연결/읽기/쓰기 timeout을 유지한다. trust-all이나 평문 fallback은 추가하지 않는다. 비활성·누락 값·잘못된 모드/포트/발신 주소는 네트워크 접속 전에 거부한다.

네이버의 현재 공식 안내는 SMTP465 SSL, SMTP 사용 설정, 2단계 인증 및 애플리케이션 비밀번호를 요구한다. [네이버 도움말](https://help.naver.com/service/30029/contents/21341?lang=ko&osType=PC), [JavaMail 속성 문서](https://javaee.github.io/javamail/docs/api/com/sun/mail/smtp/package-summary.html)

## 실패 시 동작

- 가입 후 메일이 실패하면 계정은 미인증 상태로 남는다. 성공/발송 완료 화면 대신 로그인 화면의 인증 메일 재전송 안내를 보여 준다. 같은 계정을 다시 생성하지 않는다.
- 전송에 실패한 인증 토큰은 제거한다. 인증 토큰은 기존 메모리 저장 방식을 유지하므로 앱 재시작 후 이전 링크는 무효화된다. 재전송이 필요하며 DB 스키마는 바꾸지 않는다.
- 비밀번호 찾기는 기존 `PlatformTransactionManager`의 `TransactionTemplate`으로 DB 변경과 SMTP 호출을 묶는다. SMTP 예외가 발생하면 DB 변경을 롤백하여 기존 비밀번호를 유지한다. HTTP 호출자는 기존 외부 서비스 오류 응답을 받는다.
- 메일 수락과 DB commit은 서로 다른 시스템이다. 서버가 수락한 뒤 응답이 유실되거나 DB commit이 실패하면 수신된 임시 비밀번호가 유효하지 않을 수 있다. 메일 도착·DB commit의 완전한 원자성을 보장하지 않는다. 기존 비밀번호로 다시 로그인하거나 복구를 재시도해야 한다.
- SMTP를 기다리는 동안 해당 비밀번호 변경의 DB 트랜잭션이 열린다. 단일 연결 timeout을 전체 요청의 총 시간 제한으로 해석하지 않는다.
- 메일 관련 로그는 주소·제목·토큰·예외 본문 대신 상태 코드만 남긴다. 다른 기능 전체의 로깅을 수정한 것은 아니다.

## 승인 후 적용·검증·롤백

1. 로컬 diff와 테스트를 검토한 후 GitHub 반영·배포를 별도로 진행한다. Compose가 변경됐으므로 기존 배포기의 `compose_review_required` 보호를 정상적으로 통과할 수 있도록 설치본 변경을 명시적으로 검토해야 한다. 보호 검사를 우회하지 않는다.
2. 서버 제한 권한의 환경파일에 승인된 값만 주입한다. 환경값을 명령 인자, CI 로그, Compose 전체 출력에 노출하지 않는다. 기본 비활성 상태로 먼저 앱 빌드·설정·health를 검증한다.
3. SMTP 설정 및 발송 승인을 받은 뒤 앱만 재생성한다. DB/스키마/볼륨/다른 서비스는 변경하지 않는다. 별도의 네이버 계정 설정이나 비밀번호 발급을 자동 수행하지 않는다.
4. 승인된 수신자에게 합성 메일 1회로 SMTP 수락, 실제 수신, 인증 링크, DB 인증 상태의 성공을 구분해 확인한다. 운영 실데이터를 시험에 사용하지 않는다.
5. 문제가 있으면 EMAIL_ENABLED=false로 앱만 재생성한다. 코드 롤백이 필요하면 저장한 이전 Compose·앱 이미지·환경파일의 일치 상태로 복원한다. 이미 발송한 메일, 완료된 사용자 인증·비밀번호 변경은 앱 이미지 롤백으로 되돌아가지 않는다.

## 로컬 검증

- `mvn -q test`: 32개 중 31개 통과, 외부 TEST_DB_*가 없는 MariaDB 통합 시나리오 1개 skip. 신규 H2 실제 mapper·트랜잭션·재전송 화면 테스트 7개와 SMTP 설정 테스트 3개 통과.
- `mvn -q -DskipTests package`: WAR 패키징 통과. 운영 이미지·실제 Tomcat·네이버 SMTP 연결은 이번에 실행하지 않았다.
- 합성 환경만 사용한 `docker compose --env-file NUL config --format json`: 기본 비활성 및 명시 SSL 환경키 전달 확인. 컨테이너 생성 없음.
- 상세 로컬 근거: `.omo/evidence/naver-mail/RESULT.md`.
