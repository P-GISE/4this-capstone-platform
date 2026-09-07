package com.example.test.chat;

import java.time.LocalDateTime;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessage {
    private Long id;
    private Long roomId;
    private Long userId;
    private String content;
    private MessageType messageType;
    private String filePath;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String senderName; // 보낸 사람 이름 (이름/학번 형태)
    private List<ChatMessageFileDTO> files; // 첨부 파일 목록
} 