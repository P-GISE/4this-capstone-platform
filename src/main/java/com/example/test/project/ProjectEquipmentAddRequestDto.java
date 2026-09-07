package com.example.test.project;

import lombok.Data;

@Data
public class ProjectEquipmentAddRequestDto {
    private Long rentalId;
    private Long equipmentId;
    private String purpose;
} 