package com.example.test.equipmentrepair;

import java.time.LocalDateTime;
import java.util.Date;

import com.example.test.auth.AuthDto;

import lombok.Data;

@Data
public class EquipmentRepairDto {

    private Long id;
    private Long rentalId;
    private Long requestedBy;
    private String reason;
    private String imagePath;
    private String status; // 예: PENDING, IN_PROGRESS, COMPLETED, REJECTED
    private LocalDateTime requestedAt;
    private Long handledBy;
    private LocalDateTime handledAt;

    private String rejectionReason; // 반려 사유
    
    private AuthDto user;

    private Date requestedAtDate; // JSTL에서 사용 가능한 날짜

} 
