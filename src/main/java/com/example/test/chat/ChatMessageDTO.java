package com.example.test.chat;

import java.time.LocalDateTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDTO {
    private Long id;
    private Long roomId;
    private Long senderId;
    private String senderName;
    private String content;
    private MessageType messageType;
    private String type; // WebSocket에서 사용하는 메시지 타입 (JOIN, CHAT 등)
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime sendTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    
    // 추가 필드
    private String message;
    private boolean edited;
    private boolean isDeleted;
    private boolean isPinned;
    private Long parentMessageId;
    
    private List<ChatMessageFileDTO> files;
    private List<ChatMessageDTO> replies;
    private int replyCount;
    
    // 메시지 타입 상수
    public static final String TYPE_JOIN = "JOIN";
    public static final String TYPE_CHAT = "CHAT";
    public static final String TYPE_LEAVE = "LEAVE";
} 