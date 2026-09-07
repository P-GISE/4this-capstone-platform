package com.example.test.equipmentreservation;

import java.time.LocalDateTime;

import lombok.Data;

@Data
public class EquipmentReservationDto {
    private Long id;
    private Long userId;
    private Long equipmentId;
    private LocalDateTime reservedAt;
    private String status; // PENDING, COMPLETED, CANCELED
    private String note;
    private LocalDateTime fulfilledAt; // 예약이 실제 대여로 전환된 시간
    private LocalDateTime canceledAt;

    private Integer remainingDays;


    
}
