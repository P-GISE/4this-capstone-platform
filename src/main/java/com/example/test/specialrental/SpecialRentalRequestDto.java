package com.example.test.specialrental;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;

import lombok.Data;

@Data
public class SpecialRentalRequestDto {
    private Long id;
    private Long userId;
    private Long equipmentId;
    private String requestType; // QUANTITY_EXCEED, ADDITIONAL_RENTAL, LIMIT_EXCEED
    private Long existingRentalId; // 추가 대여의 경우 기존 대여 ID
    private Integer requestedQuantity;
    private Integer currentAvailableQuantity;
    private Integer maxRentalQuantity;
    private Integer currentUserRentalCount;
    
    private String purpose;
    private String specialReason;
    private String urgencyLevel; // LOW, MEDIUM, HIGH, EMERGENCY
    private Integer expectedUsagePeriod;
    
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate expectedStartDate;
    
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate expectedEndDate;
    
    private String status; // PENDING, APPROVED, REJECTED, CANCELLED
    private Long reviewedBy;
    private LocalDateTime reviewedAt;
    private String approvalReason;
    private String rejectionReason;
    
    private String adminNotes;
    private Boolean isEmergency;
    private Integer priorityScore;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // 조인용 필드들
    private String userName;           // 신청자 이름
    private String userUsername;       // 신청자 학번/교번
    private String equipmentName;      // 기자재 이름
    private String equipmentCategory;  // 기자재 분류
    private String reviewerName;       // 검토자 이름
    
    // 계산용 필드들 (메서드로 대체되어 필드는 제거)
    private Integer daysFromRequest;       // 신청일로부터 경과일
    private Boolean isOverdue;             // 처리 지연 여부
    
    // JSP에서 사용할 Date 타입 변환 메서드들
    public Date getCreatedAtAsDate() {
        if (createdAt == null) return null;
        return Date.from(createdAt.atZone(ZoneId.systemDefault()).toInstant());
    }
    
    public Date getUpdatedAtAsDate() {
        if (updatedAt == null) return null;
        return Date.from(updatedAt.atZone(ZoneId.systemDefault()).toInstant());
    }
    
    public Date getReviewedAtAsDate() {
        if (reviewedAt == null) return null;
        return Date.from(reviewedAt.atZone(ZoneId.systemDefault()).toInstant());
    }
    
    // 헬퍼 메서드들
    public String getRequestTypeDisplayName() {
        if (requestType == null) return "";
        switch (requestType) {
            case "QUANTITY_EXCEED":
                return "수량 초과 신청";
            case "ADDITIONAL_RENTAL":
                return "추가 대여 신청";
            case "LIMIT_EXCEED":
                return "제한 초과 신청";
            default:
                return requestType;
        }
    }
    
    public String getUrgencyDisplayName() {
        if (urgencyLevel == null) return "";
        switch (urgencyLevel) {
            case "LOW":
                return "낮음";
            case "MEDIUM":
                return "보통";
            case "HIGH":
                return "높음";
            case "EMERGENCY":
                return "긴급";
            default:
                return urgencyLevel;
        }
    }
    
    public String getStatusDisplayName() {
        if (status == null) return "";
        switch (status) {
            case "PENDING":
                return "승인 대기";
            case "APPROVED":
                return "승인됨";
            case "REJECTED":
                return "반려됨";
            case "CANCELLED":
                return "취소됨";
            default:
                return status;
        }
    }
    
    public String getUrgencyBadgeClass() {
        if (urgencyLevel == null) return "badge-secondary";
        switch (urgencyLevel) {
            case "LOW":
                return "badge-info";
            case "MEDIUM":
                return "badge-warning";
            case "HIGH":
                return "badge-orange";
            case "EMERGENCY":
                return "badge-danger";
            default:
                return "badge-secondary";
        }
    }
    
    public String getStatusBadgeClass() {
        if (status == null) return "badge-secondary";
        switch (status) {
            case "PENDING":
                return "badge-warning";
            case "APPROVED":
                return "badge-success";
            case "REJECTED":
                return "badge-danger";
            case "CANCELLED":
                return "badge-secondary";
            default:
                return "badge-secondary";
        }
    }
    
    public Boolean getIsHighPriority() {
        return Boolean.TRUE.equals(isEmergency) || "HIGH".equals(urgencyLevel) || "EMERGENCY".equals(urgencyLevel);
    }
    
    public Boolean getCanCancel() {
        return "PENDING".equals(status);
    }
    
    public Boolean getCanEdit() {
        return "PENDING".equals(status);
    }
} 