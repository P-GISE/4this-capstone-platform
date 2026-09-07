package com.example.test.chat;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UserStatus {
    private Long userId;
    private String status; // ONLINE, AWAY, BUSY, OFFLINE
    private String statusMessage; // 사용자 정의 상태 메시지
    private LocalDateTime lastSeen; // 마지막 접속 시간
    private LocalDateTime lastHeartbeat; // 마지막 하트비트 시간
    private LocalDateTime statusUpdatedAt; // 상태 변경 시간
    
    // 상태 상수
    public static final String STATUS_ONLINE = "ONLINE";
    public static final String STATUS_AWAY = "AWAY";
    public static final String STATUS_BUSY = "BUSY";
    public static final String STATUS_OFFLINE = "OFFLINE";
} 