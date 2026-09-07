package com.example.test.chat;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatParticipantDTO {
    private Long id;
    private Long roomId;
    private Long userId;
    private String nickname;
    private Boolean isAdmin;
    private LocalDateTime joinedAt;
    private LocalDateTime leftAt;
    private LocalDateTime lastReadAt;
    
    // 추가 필드
    private String userName;
    private int unreadCount;
    
    public void setIsAdmin(boolean isAdmin) {
        this.isAdmin = isAdmin;
    }
    
    public boolean getIsAdmin() {
        return isAdmin;
    }
} 