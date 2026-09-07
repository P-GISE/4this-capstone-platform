package com.example.test.chat;

import lombok.Data;

@Data
public class ChatRoomDto {
    private Long id;
    private String Name;
    private boolean isMain; 
    private String description;
    private Integer maxParticipants;
    private boolean isPrivate;
    private boolean allowInvite;
    private boolean saveMessageHistory;
    private String createdAt;  // LocalDateTime도 가능
    private String updatedAt;  // LocalDateTime도 가능
}
