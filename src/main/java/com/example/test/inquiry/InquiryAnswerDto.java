package com.example.test.inquiry;

import lombok.Data;
import java.sql.Timestamp;

@Data
public class InquiryAnswerDto {
    private Long id;                    // 답변 고유 ID
    private Long inquiryId;            // 연결된 문의사항 ID
    private Long adminId;              // 최초 답변 작성자 ID
    private Long updatedBy;            // 마지막 수정 관리자 ID
    private String answer;             // 답변 본문 내용
    private boolean hasAttachment;     // 첨부파일 존재 여부
    private boolean edited;            // 답변 수정 여부
    private boolean readByUser;        // 사용자가 답변을 읽었는지 여부
    private Timestamp createdAt;       // 답변 최초 작성 시각
    private Timestamp updatedAt;       // 마지막 수정 시각

    // 조인용 필드
    private String adminName;          // 답변 작성자 이름
    private String adminRole;          // 답변 작성자 역할
    private String updatedByName;      // 수정자 이름
}