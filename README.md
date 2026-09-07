# 4This

대학 캡스톤 프로젝트 수업 운영을 위한 프로젝트, 장비, 자료실, 문의, 채팅 통합 관리 플랫폼입니다.

학생은 팀 프로젝트와 일정, 장비 대여, 자료 공유를 관리하고, 교수/조교/교직원/관리자는 승인과 운영 업무를 처리할 수 있도록 역할 기반으로 구성했습니다.

## 한눈에 보기

| 항목 | 내용 |
| --- | --- |
| 한국어 프로젝트명 | 포디스 캡스톤 플랫폼 |
| 저장소 성격 | 캡스톤 수업 운영용 Spring MVC 웹 애플리케이션 |
| 주요 사용자 | 학생, 교수, 조교, 교직원, 관리자 |
| 실행 형태 | Maven WAR 패키징, Jetty 개발 서버 또는 외부 WAS 배포 |
| 화면 방식 | JSP/JSTL 서버 렌더링 |
| DB 접근 | MyBatis mapper, Spring JDBC, 일부 JPA entity |

## 소스 검토 기준

이 README는 `src/main/java`, `src/main/resources`, `src/main/webapp/WEB-INF/views`, `src/main/resources/mapper`, `pom.xml`을 직접 검토해 다시 작성했습니다. 실제 `.properties`에는 민감값을 넣지 않는 구조로 정리했고, 문서에는 환경변수 이름과 설정 위치만 남겼습니다. 테스트 디렉터리는 현재 저장소에서 확인되지 않아 실행 검증보다는 빌드/구조 검토 중심으로 문서화했습니다.

검토 결과 이 프로젝트는 단일 게시판이 아니라 기자재 대여, 예약, 수리, 공지/문의/자료실, AI 질의, 프로젝트 협업, 실시간 채팅, 관리자 감사 로그를 한 애플리케이션에 묶은 Spring MVC 기반 학과 장비 관리 플랫폼입니다.

## 소스 기준 기능 지도

| 기능 영역 | 확인한 주요 파일 | 실제로 구현된 내용 |
| --- | --- | --- |
| 인증/사용자 | `AuthController.java`, `MypageController.java`, `SecurityConfig.java` | 회원가입, 로그인/로그아웃, 이메일 인증, 비밀번호 찾기, 마이페이지, 권한별 접근 제어 |
| 관리자 | `AdminController.java`, `AdminLogController.java`, `UserLogController.java` | 회원 상태 관리, 권한 부여, 크레딧 지급, 활동/실패 로그, 감사 로그 통계 |
| 기자재 | `EquipmentController.java`, `EquipmentRentalController.java`, `EquipmentReservationController.java`, `EquipmentRepairController.java` | 기자재 등록/수정/삭제, 일반 대여, 특별 대여, 예약, 수리 요청과 승인/반려 |
| 커뮤니티 문서 | `NoticeController.java`, `InquiryController.java`, `ArchiveController.java` | 공지사항, 문의, 자료실 게시글과 파일 업로드/다운로드 |
| AI 기능 | `AiController.java`, `AnthropicService.java`, `AiAnswerService.java` | 챗봇 질의, 기술 답변, 프로젝트 조언, 보고서 생성, AI 사용 크레딧 기록 |
| 프로젝트 협업 | `ProjectController.java`, `ChatController.java`, `ChatWebSocketController.java` | 프로젝트 생성, 태스크/멤버 관리, 초대, 채팅방, 메시지, 파일 공유, 알림 |
| 화면 | `src/main/webapp/WEB-INF/views/**/*.jsp` | `auth`, `equipment`, `project`, `chat`, `ai`, `admin`, `notice`, `inquiry`, `archive` 등 JSP 화면 |
| DB 매퍼 | `src/main/resources/mapper/*.xml` | 사용자, 기자재, 대여, 예약, 문의, 공지, AI, 채팅, 프로젝트, 로그 관련 SQL 매핑 |

## 처음 검토할 때 볼 순서

1. `pom.xml`에서 Java/Spring/MyBatis/JSP 기반의 전통적인 MVC 구성을 확인합니다.
2. `src/main/webapp/WEB-INF/views`를 보면 실제 제공되는 화면 범위가 보입니다.
3. `src/main/java/.../controller`를 보면 사용자가 접근하는 URL과 업무 흐름이 드러납니다.
4. `src/main/resources/mapper`를 보면 DB 테이블 기준으로 어떤 기능이 연결되어 있는지 확인할 수 있습니다.
5. `src/main/resources/config/anthropic.properties`와 `application.properties`는 실제 키가 아니라 환경변수 기반 설정으로 유지해야 합니다.

## 사용 시나리오

1. 학생이 회원가입과 이메일 인증을 진행합니다.
2. 학생은 프로젝트를 생성하고 팀원을 초대하거나 일정/작업/보고서를 관리합니다.
3. 수업 운영자는 공지, 자료실, 문의 답변, 장비 대여/수리 승인 업무를 처리합니다.
4. 프로젝트 참여자는 WebSocket 채팅방에서 대화하고 파일을 공유합니다.
5. 관리자는 사용자 활동 로그, 관리자 감사 로그, 장비/대여/문의 현황을 확인합니다.
6. AI 챗봇은 프로젝트 추천이나 기술 질문에 대한 보조 응답을 제공합니다.

## 주요 기능

- 관리자, 학생, 교수, 조교, 교직원 역할 분리
- 회원가입, 로그인, 이메일 인증, 비밀번호 암호화
- 프로젝트 생성, 팀원 관리, 일정, 작업, 보고서 관리
- WebSocket 기반 채팅과 채팅방 권한 관리
- 장비 등록, 대여 신청, 특별 대여, 수리 요청과 승인 흐름
- 공지사항, 문의사항, 자료실, 사용자 활동 로그
- AI 챗봇과 프로젝트 관련 질의응답 기능
- 관리자 감사 로그와 사용자 관리 화면

## 기술 스택

- Java 8
- Spring Framework 5.3
- Spring Security
- JSP, JSTL, Bootstrap, jQuery
- MyBatis, Spring JDBC
- MariaDB, HikariCP
- Maven, WAR packaging
- WebSocket

## 프로젝트 구조

```text
4this-main/
  src/main/java/com/example/test/
    auth/          인증, 회원, 역할별 프로필
    project/       프로젝트, 일정, 작업, 팀원 관리
    chat/          채팅방, 메시지, WebSocket
    equipment/     장비 관리
    reservation/   장비 대여 예약
    repair/        수리 요청
    notice/        공지사항
    inquiry/       문의사항
    archive/       자료실
    ai/            AI 챗봇
    config/        Spring MVC, 보안, 인터셉터 설정
  src/main/resources/
    mapper/        MyBatis mapper
    config/        외부 설정
  src/main/webapp/WEB-INF/views/
    JSP 화면
  pom.xml
```

## 실행 방법

필수 환경:

- Java 8 이상
- Maven 3.6 이상
- MariaDB
- Servlet 4 호환 WAS 또는 Maven Jetty plugin

데이터베이스를 생성한 뒤 Spring 설정의 DB 접속 정보를 로컬 환경에 맞게 조정합니다. 실제 계정과 비밀번호는 GitHub에 올리지 않고 로컬 설정 파일이나 배포 환경변수로 관리합니다. 이 저장소에는 별도 SQL 초기화 파일이 포함되어 있지 않으므로, MyBatis mapper와 DTO/entity를 기준으로 필요한 테이블을 준비해야 합니다.

```bash
mvn clean package
```

개발 서버 실행:

```bash
mvn jetty:run
```

기본 접속 주소:

```text
http://localhost:8080
```

## 설정 파일

| 파일 | 역할 |
| --- | --- |
| `src/main/resources/application.properties` | Anthropic API 환경변수 참조와 기본 애플리케이션 설정 |
| `src/main/resources/config/anthropic.properties` | AI 기능용 Anthropic 설정 |
| `src/main/resources/mybatis-config.xml` | MyBatis 공통 설정 |
| `src/main/resources/mapper/*.xml` | 도메인별 SQL mapper |
| `src/main/resources/log4j2.xml` | 로깅 설정 |

AI 챗봇을 실제로 사용하려면 운영 환경에서 `ANTHROPIC_API_KEY` 환경변수를 설정합니다. 저장소에는 실제 API 키를 두지 않습니다.

## 주요 화면

- 로그인/회원가입/약관/이메일 인증
- 대시보드
- 프로젝트 목록, 생성, 일정, 작업, 보고서, 팀원 관리
- 채팅방 목록, 생성, 초대, 권한, 메시지 검색, 알림 설정
- 장비 목록, 등록, 상세, 수정
- 일반 대여, 특별 대여, 수리 요청 승인
- 공지사항, 문의사항, 자료실
- 사용자 활동 로그와 관리자 감사 로그
- AI 챗봇과 프로젝트 보조 질의응답

## 구현 포인트

- 역할별 접근 제어를 인터셉터와 서비스 계층에서 분리했습니다.
- 프로젝트, 장비, 자료실, 문의처럼 수업 운영에 필요한 도메인을 기능별 패키지로 나눴습니다.
- JSP 기반 서버 렌더링 구조에서 공통 레이아웃과 화면별 JSP를 분리했습니다.
- 채팅 기능은 WebSocket 설정과 채팅방/참여자/메시지 도메인을 분리해 관리합니다.
- 관리자 감사 로그와 사용자 로그를 별도 도메인으로 두어 운영 이력을 확인할 수 있게 했습니다.

## 검증

```bash
mvn test
mvn clean package
```

WAR 파일은 `target/` 아래에 생성됩니다. 외부 Tomcat 같은 WAS에 배포할 때는 DB 설정, 메일 설정, AI API 키를 운영 환경에 맞게 분리합니다.

## 알려진 준비 사항

- DB DDL/seed 파일이 저장소에 없으므로 최초 실행 전 테이블 생성 작업이 필요합니다.
- `계정정보.md` 같은 로컬 계정 메모는 공개 저장소에 올리지 않습니다.
- 이메일 인증과 AI 챗봇은 외부 서비스 설정이 없으면 전체 흐름 검증이 제한됩니다.

## GitHub 업로드 전 주의

- 실제 로그인 계정, 비밀번호, 운영 서버 주소, DB 접속 정보는 README나 커밋에 포함하지 않습니다.
- 로컬 계정 메모 파일은 `.gitignore`에 포함해 공개 저장소에 올라가지 않도록 관리합니다.
- 충돌 마커가 남아 있던 기존 README는 제거하고 공개 가능한 설명만 남겼습니다.
