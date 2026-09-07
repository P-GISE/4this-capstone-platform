package com.example.test.chat;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatParticipant {
    private Long roomId;
    private Long userId;
    private String nickname;
    private Boolean isAdmin;
    private LocalDateTime joinedAt;
    private LocalDateTime lastReadAt;
    private Boolean notificationsEnabled;
} 