package com.example.test.equipment;

import java.sql.Timestamp;
import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;

import lombok.Data;

@Data
public class EquipmentDto {
    private Long id;                  // 기자재 ID
    private String name;              // 기자재 이름
    private String assetCode;         // 자산 식별 코드
    private String category;          // 기자재 분류
    private String manufacturer;      // 제조사

    // 구입일: yyyy-MM-dd 형식의 입력을 Date 객체로 변환
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date purchaseDate;

    // 보증 만료일: yyyy-MM-dd 형식의 입력을 Date 객체로 변환
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date warrantyExpiration;

    private String location;            // 보관 위치
    private Integer quantity;           // 전체 수량
    private Integer availableQuantity;  // 대여 가능 수량
    private Boolean isRentable;         // 대여 가능 여부
    private Boolean isRetired;          // 폐기 여부
    private Long managedBy;             // 관리자 ID
    private String status;              // 상태 (AVAILABLE, IN_USE, DAMAGED, LOST)
    private String description;         // 설명
    private String imagePath;           // 이미지 경로
    private Timestamp createdAt;         // 등록일 (DB에서 자동 채워짐)
    private Timestamp updatedAt;         // 수정일 (DB에서 자동 채워짐)
    private Integer maxRentalQuantity;

}
