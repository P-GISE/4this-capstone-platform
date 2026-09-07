package com.example.test.notice;

import lombok.Data;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * 공지사항 정보를 담는 DTO 클래스
 */
@Data
public class NoticeDto {
    private Long id;                // 공지사항 고유 ID
    private String title;           // 공지 제목
    private String content;         // 공지 내용 본문
    private String category;        // 공지 분류 (예: 시스템, 일정, 대회 등)
    private Long writerId;          // 작성자 ID (users 테이블 참조)
    private Long updatedBy;         // 마지막 수정자 ID (users 테이블 참조)
    private int viewCount;          // 조회수
    private boolean important;      // 중요 공지 여부 (isImportant)
    private Timestamp visibleFrom;  // 공지 게시 시작 시각
    private Timestamp visibleUntil; // 공지 게시 종료 시각
    private String targetRole;      // 공지 대상 사용자 유형
    private Timestamp createdAt;    // 작성 시각
    private Timestamp updatedAt;    // 마지막 수정 시각

    // JSP에서 사용하는 추가 필드 - boolean은 변수명을 isXxx로 하지 말고 xxx로 해야 함
    private boolean newFlag;      // NEW 배지 표시용 (isNew 대신 newFlag 사용)
    
    
    // 편의를 위한 추가 메서드
    public boolean getIsNew() {
        return newFlag;
    }
    
    public void setIsNew(boolean isNew) {
        this.newFlag = isNew;
    }

    private String writerName;


    public String getTargetRoleKorean() {
        switch (targetRole.toUpperCase()) {
            case "STUDENT": return "학생";
            case "PROFESSOR": return "교수";
            case "ASSISTANT": return "조교";
            case "ADMIN": return "관리자";
            case "ALL": return "전체";
            default: return targetRole;
        }
    }

    private List<NoticeAttachmentDto> attachments = new ArrayList<>();
}
