package com.example.test.ai;

import java.sql.Timestamp;

public class AttachmentFileDto {
    private Long id;
    private Long questionId;
    private String filePath;
    private String originalFileName;
    private String fileType;
    private Long fileSize;
    private Timestamp uploadedAt;
    
    // 기본 생성자
    public AttachmentFileDto() {}
    
    // 전체 생성자
    public AttachmentFileDto(Long id, Long questionId, String filePath, String originalFileName, 
                           String fileType, Long fileSize, Timestamp uploadedAt) {
        this.id = id;
        this.questionId = questionId;
        this.filePath = filePath;
        this.originalFileName = originalFileName;
        this.fileType = fileType;
        this.fileSize = fileSize;
        this.uploadedAt = uploadedAt;
    }
    
    // Getter and Setter methods
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public Long getQuestionId() {
        return questionId;
    }
    
    public void setQuestionId(Long questionId) {
        this.questionId = questionId;
    }
    
    public String getFilePath() {
        return filePath;
    }
    
    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }
    
    public String getOriginalFileName() {
        return originalFileName;
    }
    
    public void setOriginalFileName(String originalFileName) {
        this.originalFileName = originalFileName;
    }
    
    public String getFileType() {
        return fileType;
    }
    
    public void setFileType(String fileType) {
        this.fileType = fileType;
    }
    
    public Long getFileSize() {
        return fileSize;
    }
    
    public void setFileSize(Long fileSize) {
        this.fileSize = fileSize;
    }
    
    public Timestamp getUploadedAt() {
        return uploadedAt;
    }
    
    public void setUploadedAt(Timestamp uploadedAt) {
        this.uploadedAt = uploadedAt;
    }
    
    // 파일 크기를 읽기 쉬운 형태로 변환
    public String getFormattedFileSize() {
        if (fileSize == null) return "0 B";
        
        long bytes = fileSize;
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024 * 1024) return String.format("%.1f KB", bytes / 1024.0);
        if (bytes < 1024 * 1024 * 1024) return String.format("%.1f MB", bytes / (1024.0 * 1024));
        return String.format("%.1f GB", bytes / (1024.0 * 1024 * 1024));
    }
    
    // 파일 확장자 추출
    public String getFileExtension() {
        if (originalFileName == null || !originalFileName.contains(".")) {
            return "";
        }
        return originalFileName.substring(originalFileName.lastIndexOf(".") + 1).toLowerCase();
    }
    
    // 이미지 파일 여부 확인
    public boolean isImageFile() {
        String ext = getFileExtension();
        return ext.equals("jpg") || ext.equals("jpeg") || ext.equals("png") || 
               ext.equals("gif") || ext.equals("bmp") || ext.equals("webp");
    }
} 