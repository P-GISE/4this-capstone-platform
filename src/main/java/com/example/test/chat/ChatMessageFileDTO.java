package com.example.test.chat;

import java.util.Date;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageFileDTO {
    private Long id;
    private Long messageId;
    private String fileName;
    private String filePath;
    private String fileType;
    private Long fileSize;
    private String uploadedAt;
    
    // 추가 필드
    private String originalFileName;
    private String fileUrl;
    private boolean isDeleted;
    private Date deletedAt;
} 