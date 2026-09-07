package com.example.test.notice;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.sql.Timestamp;

/**
 * 공지사항 첨부파일 정보를 담는 DTO
 */
@Data
public class NoticeAttachmentDto {
    // DB 저장용 필드
    private Long id;                  // 첨부파일 고유 ID
    private Long noticeId;            // 연결된 공지사항 ID
    private String fileName;          // 서버에 저장된 파일명
    private String originalFileName;  // 사용자가 업로드한 원래 파일명
    private String filePath;          // 저장 경로
    private String fileType;          // MIME 타입
    private Long fileSize;            // 파일 크기 (byte)
    private int downloadCount;        // 다운로드 횟수
    private boolean deleted;          // 삭제 여부
    private Timestamp uploadedAt;     // 업로드 시각

    // 업로드 처리용 필드
    private MultipartFile uploadFile; // 업로드된 MultipartFile 객체 (form에서 수신)
    private boolean deleteFile;       // 삭제 요청 여부 (true 시 기존 파일 삭제 처리)

    private String writerName;

    private String category;
}
