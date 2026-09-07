package com.example.test.chat;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoom {
    private Long id;
    private String name;
    private String description;
    private Integer maxParticipants;
    private Boolean isPrivate;
    private Boolean allowInvite;
    private Boolean saveMessageHistory;
    private Boolean isMain;
    private Long projectId;
    private Long createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
} 