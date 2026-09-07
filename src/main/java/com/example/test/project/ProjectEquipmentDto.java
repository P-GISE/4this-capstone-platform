package com.example.test.project;

import java.sql.Timestamp;

import com.example.test.auth.AuthDto;
import com.example.test.equipment.EquipmentDto;
import com.example.test.equipmentrental.EquipmentRentalDto;

import lombok.Data;

@Data
public class ProjectEquipmentDto {
    private Long id;
    private Long projectId;
    private Long equipmentId;
    private Long rentalId;
    private Long addedBy;
    private String purpose;
    private Timestamp addedAt;
    
    // 조인된 정보들
    private EquipmentDto equipment;           // 기자재 상세 정보
    private EquipmentRentalDto rental;        // 대여 정보
    private AuthDto addedByUser;              // 추가한 사용자 정보
    private String equipmentName;             // 기자재명 (간단 조회용)
    private String renterName;                // 대여자명 (간단 조회용)
} 