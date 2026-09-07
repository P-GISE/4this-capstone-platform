package com.example.test.chat;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChatDTO {
    private Long roomId;
    private String name;
    private String description;
    private Integer maxParticipants;
    private Boolean isPrivate;
    private Boolean allowInvite;
    private Boolean saveMessageHistory;
    private Boolean isMain;
    private Long projectId;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
    
    // 추가 필드
    private int messageCount;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lastMessageTime;
    
    private Long createdBy;
    private Integer participantCount;
    
    // 추가 메서드
    public void setProjectId(Long projectId) {
        this.projectId = projectId;
    }
    
    public void setCreatedBy(Long createdBy) {
        this.createdBy = createdBy;
    }
    
    public void setMain(boolean isMain) {
        this.isMain = isMain;
    }
    
    public Boolean getIsPrivate() {
        return isPrivate;
    }
    
    public void setIsPrivate(Boolean isPrivate) {
        this.isPrivate = isPrivate;
    }
    
    public Boolean getAllowInvite() {
        return allowInvite;
    }
    
    public Boolean getSaveMessageHistory() {
        return saveMessageHistory;
    }
} 