package com.example.test.inquiry;

import lombok.Data;
import java.sql.Timestamp;

@Data
public class InquiryDto {
    private Long id;                  // 문의 고유 ID
    private Long userId;              // 작성자 ID (users 테이블 참조)
    private String title;             // 문의 제목
    private String content;           // 문의 내용
    private String category;          // 문의 유형 (예: 시스템, 대여, 계정 등)
    private String contextType;       // 문의 대상 기능 구분 (ENUM: GENERAL, PROJECT, EQUIPMENT, ACCOUNT)
    private Long targetId;            // 기능 내 대상 ID
    private boolean hasAttachment;    // 첨부파일 존재 여부
    private boolean urgent;       // 우선 처리 요청 여부
    private boolean reviewed;       // 관리자 확인 여부
    private Timestamp answeredAt;     // 답변 완료 시각
    private String status;            // 처리 상태 (ENUM: PENDING, ANSWERED)
    private boolean deleted;         // 삭제 여부
    private Timestamp createdAt;      // 작성 시각
    private Timestamp updatedAt;      // 수정 시각

    // 추가적으로 사용자 이름을 출력에 사용하고 싶다면:
    private String writerName;        // 작성자 이름 (조인된 결과용, 선택적)

    private String username; 
}
