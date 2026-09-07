package com.example.test.chat;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatInvitation {
    private Long id;
    private Long roomId;
    private Long inviterId;
    private Long inviteeId;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
} 