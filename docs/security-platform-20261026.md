# 지원 플랫폼으로 전환

현재 변경은 Spring7.0.10·Security crypto7.0.8·MyBatis-Spring4·Tomcat11.0.27(Servlet6.1/JSP4)로 WAR 실행 경계를 바꾼다. Java17 컴파일/컨테이너JDK21·기존URL/JSP·MariaDB schema/mapper·DB/업로드볼륨·세션이름/쿠키/Origin 정책은 유지한다. Spring6.2는2026년6월 OSS지원 종료이고 현재 보안 수정 일부가 유료 지원만 제공되므로 무료 지원7계열을 선택했다. [공식 지원표](https://github.com/spring-projects/spring-framework/wiki/Spring-Framework-Versions).

사용되지 않는 Spring Data JPA/ORM/Hibernate와 CommonsFileUpload를 제거했다. 실제 root-context는 JDBC/MyBatis만 구성한다. 기존 CommonsMultipartResolver는 Spring6부터 제거돼 Servlet 표준 resolver로 변경하고 web.xml의 전체/파일10MiB·메모리threshold1MiB를 명시한다. servlet namespace25파일을 Jakarta로 변경했으며 독립 JavaMail의 javax.mail은 유지했다. JDBC/메일/암호화의 javax를 일괄 변경하지 않았다.

Jackson 모듈은 안전2.18.11로 정렬했다. Spring7.0의 Jackson2 fallback을 사용하므로 향후7.1 이상 전환 전에 Jackson3 작업을 별도 검토한다. H2는 안전2.3.232/test scope이고 실제 MariaDB schema는 바꾸지 않았다. Jakarta JSTL3.0.1 artifact의 legacy core/fmt/functions URI alias를 직접 확인해83개 JSP URI를 그대로 유지했다. Jetty9는 javax 기반이라 제거했고 개발/검증도 Tomcat11을 기준으로 한다.

## 발견한 실제 호환 경계

새 플랫폼에서 이름 없는 @RequestParam 바인딩·없어진 정적파일·초과 업로드의3회귀를 먼저 실행하여 모두 실패했다. 최신compiler3.14.1과 parameters=true로 실제 MethodParameters를 생성하고, Spring7 NoResourceFound/MaxUploadSize 예외를404/413으로 명시해 기존 generic500 처리로 흘러가지 않도록 했다. 비공개 report static 경로는 계속 차단한다. 기존 SpringSecurity5.8.11로 만든 공개 합성 BCrypt$2a fixture도 새 encoder가 검증하는 회귀를 추가했다. 기존 저장 비밀번호를 재해시/변경하지 않는다.

## 실제 multipart 호출 목록

모두 동일 DispatcherServlet의 StandardServletMultipartResolver를 사용한다. 아래는 소스에서 읽은 실제 요청·필드 목록이며 모든 업무 저장 흐름을 실제 브라우저로 실행했다고 주장하지 않는다.

| Controller/경로 | 파일 필드 |
|---|---|
| Archive /archive/write, /archive/edit | attachFile(List) |
| Chat /chat/upload | files(array), roomId |
| Inquiry /inquiry/write, /inquiry/edit, /inquiry/answer | attachments, answerAttachments |
| Notice /notice/write, /notice/update | attachFile, attachFile[] |
| Project /projects/{projectId}/reports/upload | file |
| EquipmentRepair /repair/submit | image(optional) |
| SpecialRental /special-rental/request | attachments(optional) |
| AI /ai/recommend-project, /ai/ask, /ai/project-chat | files(optional array) |

AI·메일은 CI에서 OFF, 실제 제공자 호출0이다. Project 경로는 실제 Tomcat의 정상PDF upload/DB저장·UTF8 JSP목록·권한 download/attachment/nosniff·정적404·11MiB Content-Length/Expect 요청413·실패DB불변을 합성 CI에 추가했다. 초과 body를 응답 확인 없이 계속 보내는 raw client는 Tomcat의 기본 유한 maxSwallow 제한으로 연결이 닫힐 수 있다. 이를 숨기기 위해 무제한 swallow나 허용 크기 상향을 적용하지 않았다. 나머지 업무별 저장·권한·파일형식은 기존 서비스 로직을 보존하며 이 플랫폼 변경으로 전체 보안 통과를 의미하지 않는다.

## 검증·배포·롤백 경계

첫 실제 Tomcat11 CI에서 health는200이지만 로그인 JSP가500이었다. Jakarta JSTL 구현이 API를provided로만 선언해WAR에서 누락된 원인을 ClassNotFound 회귀로 재현하고 Jakarta JSTL API3.0.2를 명시해 수정했다. 로컬 최종 clean verify56개 중55통과/기존MariaDB환경1skip, WAR 생성. 실제 Linux MariaDB·Docker/Tomcat11/UTF8JSP/multipart/쿠키 검증은 PR CI의 최신 결과를 따른다. POM include-dev High/Critical21→0, Maven resolved57component CycloneDX SBOM Trivy도0을 확인했다. 단순 loose-JAR scan은 대상0으로 인식되지 않아 통과 근거로 사용하지 않았다. SBOM의 third-party/hash warning은 남으며 전체 OS 이미지 취약점 부재나 운영 완료를 주장하지 않는다.

기존 schema.sql/Compose/context cookie 설정은 byte 기준 변경하지 않았다. 새 유료 자원/DB migration/계정 변경·운영 반영 없음. 보호 POM/Docker 변경이므로 부모의 exact SHA 검토와 기존 배포 guard를 거친다. 승인 후 앱만 교체하고 이전 검토 이미지/env/Compose를 보존해 실패시 앱 이미지만 되돌린다. DB 복원은 필요 없으며 앱 세션·미사용 재설정 링크는 재시작으로 다시 시작해야 할 수 있다. 롤백은 기존 라이브러리 취약점도 복원하므로 임시 복구로만 취급한다.
