package com.example.test.specialrental;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class SpecialRentalAttachmentDto {
    private Long id;
    private Long specialRequestId;
    private String originalFilename;
    private String storedFilename;
    private String filePath;
    private Long fileSize;
    private String fileType;
    private String description;
    private LocalDateTime createdAt;
    
    // 헬퍼 메서드들
    public String getFileSizeFormatted() {
        if (fileSize == null) return "0 B";
        
        if (fileSize < 1024) {
            return fileSize + " B";
        } else if (fileSize < 1024 * 1024) {
            return String.format("%.1f KB", fileSize / 1024.0);
        } else if (fileSize < 1024 * 1024 * 1024) {
            return String.format("%.1f MB", fileSize / (1024.0 * 1024.0));
        } else {
            return String.format("%.1f GB", fileSize / (1024.0 * 1024.0 * 1024.0));
        }
    }
    
    public String getFileExtension() {
        if (originalFilename == null) return "";
        int lastDotIndex = originalFilename.lastIndexOf('.');
        if (lastDotIndex > 0 && lastDotIndex < originalFilename.length() - 1) {
            return originalFilename.substring(lastDotIndex + 1).toLowerCase();
        }
        return "";
    }
    
    public boolean isImageFile() {
        String extension = getFileExtension();
        return extension.matches("jpg|jpeg|png|gif|bmp|webp");
    }
    
    public boolean isPdfFile() {
        return "pdf".equals(getFileExtension());
    }
    
    public boolean isDocumentFile() {
        String extension = getFileExtension();
        return extension.matches("doc|docx|xls|xlsx|ppt|pptx|txt|hwp");
    }
} 