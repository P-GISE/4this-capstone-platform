package com.example.test.notification;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Notification {
    private Long id;
    private Long userId;
    private String type; // CHAT, NOTICE, INQUIRY, EQUIPMENT
    private String title;
    private String message;
    private String targetUrl;
    private Boolean isRead;
    private LocalDateTime createdAt;
    private LocalDateTime readAt;
    
    // 알림 타입 상수
    public static final String TYPE_CHAT = "CHAT";
    public static final String TYPE_NOTICE = "NOTICE";
    public static final String TYPE_INQUIRY = "INQUIRY";
    public static final String TYPE_EQUIPMENT = "EQUIPMENT";
    public static final String TYPE_PROJECT = "PROJECT";
    
    // 새로운 세부 알림 타입 상수들
    public static final String TYPE_IMPORTANT_NOTICE = "IMPORTANT_NOTICE";
    public static final String TYPE_INQUIRY_ANSWER = "INQUIRY_ANSWER";
    public static final String TYPE_EQUIPMENT_APPROVED = "EQUIPMENT_APPROVED";
    public static final String TYPE_EQUIPMENT_REJECTED = "EQUIPMENT_REJECTED";
    public static final String TYPE_EQUIPMENT_RETURN_REMINDER = "EQUIPMENT_RETURN_REMINDER";
} 