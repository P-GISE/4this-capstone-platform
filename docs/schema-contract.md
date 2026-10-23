# 새 DB 스키마 계약

작성 2026-10-24. 기준 Git 4aecf7dcc3c6b74e4680130bf3e9919715872104의 mapper/JDBC와 현재 공동 작업 변경을 읽었다. 학교 DB 접속·덤프·이전 데이터 복사 없이 새 빈 DB를 위한 구조를 작성했다.

- **확인됨:** 26개 mapper XML이 참조하는49개 실제 테이블과 AiService 직접 JDBC의 ai_question_files까지 총50개다. 코드의 SQL·모델에서 필요한 열을 도출했다.
- **제안:** database/schema.sql의 타입 길이·기본값·인덱스·PK/unique는 이 새 배포용 계약이다. 원본 DB의 DDL을 재현했다고 주장하지 않는다. 업무 본문/실계정/기본 관리자 seed는 없다.
- **추정:** 관계열은 사용자·프로젝트·채팅방·장비·게시물 식별자를 참조한다. 기존 삭제 순서에 부모를 먼저 지우는 경로가 있어 FK cascade를 임의로 넣지 않았다. 참조 index로 시작하며 고아 정리·FK 정책은 별도 개선 과제다.
- **미확인:** 학교 DB의 실제 컬럼 길이, 제약, charset, 보존 정책. 실제 MariaDB11.4 전체 mapper 검증은 CI에 연결했으며 로컬 H2 통과와 구분한다.

## 적용 경계

이 SQL은 새 빈 fourthis DB의 Docker 초기화에만 사용한다. CREATE TABLE에 IF NOT EXISTS를 넣지 않아 기존/부분 DB를 조용히 승인하지 않는다. 기존 DB에 재실행하거나 DROP/TRUNCATE하는 절차가 아니다. 관리자 생성은 다른 담당자의 명시 bootstrap CLI를 사용하며 username/password/name/email을 반드시 제공하고 users가 비어 있을 때만 수행한다. 사람의 계정 정보는 이 문서나 테스트에 쓰지 않는다.

users에는 username/email unique를 두며 프로필·AI credit·presence는 user_id를 PK로 쓴다. project_members는(project_id,user_id),chat_reads는(message_id,user_id)를 PK로 써 기존 upsert/회원 관계를 지원한다. 그 외 id는 BIGINT AUTO_INCREMENT다. 자식 참조 열은 FK 강제 대신 index를 둔다. 이름/이메일 길이와 상태 기본값은 기존 소스 사용을 기준으로 선택한 새 계약이다.

## 테이블 근거

| 테이블 | 주키 | 근거 파일 |
|---|---|---|
| admin_logs | id | [AdminLogMapper.xml](../src/main/resources/mapper/AdminLogMapper.xml) |
| admin_profiles | user_id | [AuthMapper.xml](../src/main/resources/mapper/AuthMapper.xml) |
| ai_answers | id | [AiAnswerMapper.xml](../src/main/resources/mapper/AiAnswerMapper.xml), [AiHistoryMapper.xml](../src/main/resources/mapper/AiHistoryMapper.xml) |
| ai_conversations | id | [AiConversationMapper.xml](../src/main/resources/mapper/AiConversationMapper.xml) |
| ai_credit_logs | id | [AiCreditMapper.xml](../src/main/resources/mapper/AiCreditMapper.xml) |
| ai_feedback | id | [AiFeedbackMapper.xml](../src/main/resources/mapper/AiFeedbackMapper.xml) |
| ai_history | id | [AiHistoryMapper.xml](../src/main/resources/mapper/AiHistoryMapper.xml) |
| ai_question_files | id | [AiService.java](../src/main/java/com/example/test/ai/AiService.java) — 첨부파일 조회/저장 JDBC |
| ai_questions | id | [AiHistoryMapper.xml](../src/main/resources/mapper/AiHistoryMapper.xml), [AiQuestionMapper.xml](../src/main/resources/mapper/AiQuestionMapper.xml) |
| archive_files | id | [ArchiveMapper.xml](../src/main/resources/mapper/ArchiveMapper.xml) |
| archives | id | [ArchiveMapper.xml](../src/main/resources/mapper/ArchiveMapper.xml) |
| assistant_profiles | user_id | [AuthMapper.xml](../src/main/resources/mapper/AuthMapper.xml), [ChatMessageMapper.xml](../src/main/resources/mapper/ChatMessageMapper.xml), [ChatParticipantMapper.xml](../src/main/resources/mapper/ChatParticipantMapper.xml) |
| chat_invitations | id | [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml) |
| chat_message_files | id | [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml) |
| chat_messages | id | [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml), [ChatMessageMapper.xml](../src/main/resources/mapper/ChatMessageMapper.xml) |
| chat_participants | id | [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml), [ChatParticipantMapper.xml](../src/main/resources/mapper/ChatParticipantMapper.xml) |
| chat_reads | message_id,user_id | [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml) |
| chat_room_activity_logs | id | [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml) |
| chat_room_permissions | id | [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml) |
| chat_room_settings | id | [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml) |
| chat_room_shares | id | [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml) |
| chat_room_tags | id | [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml) |
| chat_room_templates | id | [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml) |
| chat_rooms | id | [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml), [ChatRoomMapper.xml](../src/main/resources/mapper/ChatRoomMapper.xml) |
| conversations | id | [ConversationMapper.xml](../src/main/resources/mapper/ConversationMapper.xml) |
| equipment | id | [EquipmentMapper.xml](../src/main/resources/mapper/EquipmentMapper.xml), [ProjectEquipmentMapper.xml](../src/main/resources/mapper/ProjectEquipmentMapper.xml), [SpecialRentalRequestMapper.xml](../src/main/resources/mapper/SpecialRentalRequestMapper.xml) |
| equipment_rentals | id | [EquipmentRentalMapper.xml](../src/main/resources/mapper/EquipmentRentalMapper.xml), [ProjectEquipmentMapper.xml](../src/main/resources/mapper/ProjectEquipmentMapper.xml) |
| equipment_repairs | id | [insertRepair.xml](../src/main/resources/mapper/insertRepair.xml) |
| equipment_reservations | id | [EquipmentReservationMapper.xml](../src/main/resources/mapper/EquipmentReservationMapper.xml) |
| inquiries | id | [InquiryMapper.xml](../src/main/resources/mapper/InquiryMapper.xml) |
| inquiry_answers | id | [InquiryMapper.xml](../src/main/resources/mapper/InquiryMapper.xml) |
| inquiry_attachments | id | [InquiryMapper.xml](../src/main/resources/mapper/InquiryMapper.xml) |
| notice_attachments | id | [NoticeMapper.xml](../src/main/resources/mapper/NoticeMapper.xml) |
| notices | id | [NoticeMapper.xml](../src/main/resources/mapper/NoticeMapper.xml) |
| notifications | id | [NotificationMapper.xml](../src/main/resources/mapper/NotificationMapper.xml) |
| professor_profiles | user_id | [AuthMapper.xml](../src/main/resources/mapper/AuthMapper.xml), [ChatMessageMapper.xml](../src/main/resources/mapper/ChatMessageMapper.xml), [ChatParticipantMapper.xml](../src/main/resources/mapper/ChatParticipantMapper.xml) |
| project_equipment | id | [ProjectEquipmentMapper.xml](../src/main/resources/mapper/ProjectEquipmentMapper.xml) |
| project_members | project_id,user_id | [ProjectMapper.xml](../src/main/resources/mapper/ProjectMapper.xml) |
| project_reports | id | [ProjectMapper.xml](../src/main/resources/mapper/ProjectMapper.xml) |
| project_tasks | id | [ProjectMapper.xml](../src/main/resources/mapper/ProjectMapper.xml) |
| projects | id | [ProjectMapper.xml](../src/main/resources/mapper/ProjectMapper.xml) |
| special_rental_attachments | id | [SpecialRentalRequestMapper.xml](../src/main/resources/mapper/SpecialRentalRequestMapper.xml) |
| special_rental_logs | id | [SpecialRentalRequestMapper.xml](../src/main/resources/mapper/SpecialRentalRequestMapper.xml) |
| special_rental_requests | id | [SpecialRentalRequestMapper.xml](../src/main/resources/mapper/SpecialRentalRequestMapper.xml) |
| staff_profiles | user_id | [AuthMapper.xml](../src/main/resources/mapper/AuthMapper.xml), [ChatMessageMapper.xml](../src/main/resources/mapper/ChatMessageMapper.xml), [ChatParticipantMapper.xml](../src/main/resources/mapper/ChatParticipantMapper.xml) |
| student_profiles | user_id | [AuthMapper.xml](../src/main/resources/mapper/AuthMapper.xml), [ChatMessageMapper.xml](../src/main/resources/mapper/ChatMessageMapper.xml), [ChatParticipantMapper.xml](../src/main/resources/mapper/ChatParticipantMapper.xml) |
| user_ai_credits | user_id | [AiCreditMapper.xml](../src/main/resources/mapper/AiCreditMapper.xml) |
| user_logs | id | [UserLogMapper.xml](../src/main/resources/mapper/UserLogMapper.xml) |
| user_status | user_id | [UserStatusMapper.xml](../src/main/resources/mapper/UserStatusMapper.xml) |
| users | id | [AdminLogMapper.xml](../src/main/resources/mapper/AdminLogMapper.xml), [AuthMapper.xml](../src/main/resources/mapper/AuthMapper.xml), [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml), [ChatMessageMapper.xml](../src/main/resources/mapper/ChatMessageMapper.xml), [ChatParticipantMapper.xml](../src/main/resources/mapper/ChatParticipantMapper.xml), [InquiryMapper.xml](../src/main/resources/mapper/InquiryMapper.xml), [NoticeMapper.xml](../src/main/resources/mapper/NoticeMapper.xml), [ProjectEquipmentMapper.xml](../src/main/resources/mapper/ProjectEquipmentMapper.xml), [ProjectMapper.xml](../src/main/resources/mapper/ProjectMapper.xml), [SpecialRentalRequestMapper.xml](../src/main/resources/mapper/SpecialRentalRequestMapper.xml), [UserLogMapper.xml](../src/main/resources/mapper/UserLogMapper.xml) |

## 발견·수정한 기존 쿼리 문제

**확인됨:** ChatMapper의 chat_rooms 수정/소프트삭제는 room_id를 사용하고, 검색 하위 쿼리는 r.room_id를 사용했지만 방 생성·상세조회·타 mapper의 PK는 id다. 이4참조를 id/r.id로 통일했다. schema에 가짜 room_id 열을 추가하지 않았다. 로컬 MyBatis 실제 BoundSql의 update/search/delete PreparedStatement가 새 H2 스키마에서 실행된다. 이 수정은 조회조건만 바꾸며 테이블/기존 데이터를 수정한 작업이 아니다.

## 검증과 한계

- **확인됨:** SchemaDatabaseTest는 H2 MySQL-mode의 새 메모리 DB에50테이블을 만들고 초기 users0, 합성 사용자/프로젝트/멤버/장비/예약/공지 쓰기와 관계 조회·예약 WAITING 기본값을 확인한다.
- **확인됨:** MapperDatabaseTest의 Chat PK 회귀는 실제 XML을 MyBatis로 로드하여 합성 새 DB에서 수정/검색/삭제 SQL을 실행한다.
- **확인됨:** CI run 39996165339의 MariaDB 11.4 새 빈 DB에서 50테이블 초기화와 SELECT 452회(226개 statement × 필터 2형태)가 실행되었다. Maven 전체19개/실패0/오류0/skip0이며 그중 스키마 담당3개도 모두 통과했다. 로컬은 TEST_DB_URL 부재로 MariaDB1개가 skip이고, CI 검증은 운영 DB 적용을 뜻하지 않는다.
- **제안/구현됨:** CI TEST_DB_URL은 jdbc:mariadb://127.0.0.1:<port>/fourthis_schema_test 또는 localhost만 허용하고 query parameter도 받지 않는다. TEST_DB_USERNAME/TEST_DB_PASSWORD는 CI 합성값만 전달한다. 기존 테이블이1개라도 있으면 초기화 전에 실패한다. schema 적용 뒤 모든 mapper SELECT를 빈필터/합성필터 두 형태로 실제 실행한다(200회 초과 필수). 업무 DB·학교 서버 URL은 코드에서 거절된다.
- **미확인:** SELECT 준비/실행은 화면 전체의 업무 정확성, 권한, 모든 동적 sort 조합·쓰기 경로를 증명하지 않는다. Tomcat/JSP/HTTP와 운영 사후 검증은 다른 담당자가 별도로 수행한다.
- **미확인:** Iron Laws는 이 worktree가 허용 폴더 밖이라 schema/test 검사를 거절했다. 도구 검사를 완료했다고 주장하거나 경계를 우회하지 않았다.

로컬 호출: Maven -q -Dtest=SchemaDatabaseTest,MapperDatabaseTest test. 결과3 run/0failure/0error/1skip. 증거 .omo/evidence/schema/mapper-local.txt 및 두 *DatabaseTest.summary.txt. schema 파일 부재 RED는 red.txt, H2 초기 green은 h2.txt다. CI 실제 MariaDB 근거는 .omo/evidence/schema/mariadb-ci.safe.json이다. 이 run의 전체 결론은 이후 이미지 빌드 단계 오류 때문에 failure이며, HTTP·이미지·운영 완료로 확대하지 않는다.
