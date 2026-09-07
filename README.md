# 4This

대학 캡스톤 프로젝트 수업 운영을 위한 프로젝트, 장비, 자료실, 문의, 채팅 통합 관리 플랫폼입니다.

학생은 팀 프로젝트와 일정, 장비 대여, 자료 공유를 관리하고, 교수/조교/교직원/관리자는 승인과 운영 업무를 처리할 수 있도록 역할 기반으로 구성했습니다.

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

데이터베이스를 생성한 뒤 Spring 설정의 DB 접속 정보를 로컬 환경에 맞게 조정합니다. 실제 계정과 비밀번호는 GitHub에 올리지 않고 로컬 설정 파일이나 배포 환경변수로 관리합니다.

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

## 구현 포인트

- 역할별 접근 제어를 인터셉터와 서비스 계층에서 분리했습니다.
- 프로젝트, 장비, 자료실, 문의처럼 수업 운영에 필요한 도메인을 기능별 패키지로 나눴습니다.
- JSP 기반 서버 렌더링 구조에서 공통 레이아웃과 화면별 JSP를 분리했습니다.
- 채팅 기능은 WebSocket 설정과 채팅방/참여자/메시지 도메인을 분리해 관리합니다.
- 관리자 감사 로그와 사용자 로그를 별도 도메인으로 두어 운영 이력을 확인할 수 있게 했습니다.

## GitHub 업로드 전 주의

- 실제 로그인 계정, 비밀번호, 운영 서버 주소, DB 접속 정보는 README나 커밋에 포함하지 않습니다.
- 로컬 계정 메모 파일은 `.gitignore`에 포함해 공개 저장소에 올라가지 않도록 관리합니다.
- 충돌 마커가 남아 있던 기존 README는 제거하고 공개 가능한 설명만 남겼습니다.
