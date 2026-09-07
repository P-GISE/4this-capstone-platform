package com.example.test.specialrental;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class SpecialRentalLogDto {
    private Long id;
    private Long specialRequestId;
    private String actionType; // CREATED, REVIEWED, APPROVED, REJECTED, CANCELLED, MODIFIED
    private Long actionBy;
    private String actionReason;
    private String previousStatus;
    private String newStatus;
    private LocalDateTime createdAt;
    
    // 조인용 필드
    private String actionByName;     // 처리자 이름
    private String actionByUsername; // 처리자 학번/교번
    
    // 헬퍼 메서드들
    public String getActionTypeDisplayName() {
        if (actionType == null) return "";
        switch (actionType) {
            case "CREATED": return "신청 생성";
            case "REVIEWED": return "검토 완료";
            case "APPROVED": return "승인 처리";
            case "REJECTED": return "반려 처리";
            case "CANCELLED": return "취소 처리";
            case "MODIFIED": return "수정";
            default: return actionType;
        }
    }
    
    public String getActionIcon() {
        if (actionType == null) return "fas fa-circle";
        switch (actionType) {
            case "CREATED": return "fas fa-plus-circle text-primary";
            case "REVIEWED": return "fas fa-eye text-info";
            case "APPROVED": return "fas fa-check-circle text-success";
            case "REJECTED": return "fas fa-times-circle text-danger";
            case "CANCELLED": return "fas fa-ban text-secondary";
            case "MODIFIED": return "fas fa-edit text-warning";
            default: return "fas fa-circle";
        }
    }
    
    public String getActionColorClass() {
        if (actionType == null) return "text-secondary";
        switch (actionType) {
            case "CREATED": return "text-primary";
            case "REVIEWED": return "text-info";
            case "APPROVED": return "text-success";
            case "REJECTED": return "text-danger";
            case "CANCELLED": return "text-secondary";
            case "MODIFIED": return "text-warning";
            default: return "text-secondary";
        }
    }
} 