package com.example.test.inquiry;

import lombok.Data;
import java.sql.Timestamp;

@Data
public class InquiryAttachmentDto {
    private Long id;                   // 첨부파일 고유 ID
    private Long inquiryId;           // 문의사항 ID (문의사항 첨부파일인 경우)
    private Long inquiryAnswerId;     // 답변 ID (답변 첨부파일인 경우)
    private String fileName;          // 서버에 저장된 실제 파일명
    private String originalFileName;  // 사용자가 업로드한 원본 파일명
    private String filePath;          // 저장 경로
    private String fileType;          // MIME 타입 (예: image/png 등)
    private Long fileSize;            // 파일 크기 (바이트)
    private String description;       // 첨부파일 설명 또는 용도
    private boolean downloadable;     // 다운로드 가능 여부
    private int downloadCount;        // 다운로드 횟수
    private boolean deleted;          // 삭제 여부
    private Timestamp uploadedAt;     // 업로드 시각

    // 다운로드 링크 생성용 (선택적)
    private String downloadUrl;
    
    // 첨부파일 타입 구분용 메서드
    public boolean isInquiryAttachment() {
        return inquiryId != null && inquiryAnswerId == null;
    }
    
    public boolean isAnswerAttachment() {
        return inquiryAnswerId != null && inquiryId == null;
    }
}