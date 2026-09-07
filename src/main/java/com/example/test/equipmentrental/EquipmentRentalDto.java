package com.example.test.equipmentrental;

import java.util.Date;

import com.example.test.auth.AuthDto;

import lombok.Data;

@Data
public class EquipmentRentalDto {
    private Long id;
    private Long userId;                   // DB의 user_id
    private Long equipmentId;              // DB의 equipment_id
    private Date rentDate;                 // DB의 rent_date
    private Date expectedReturnDate;       // DB의 expected_return_date
    private Date returnDate;               // DB의 return_date
    private Integer extensionCount;        // DB의 extension_count
    private Integer requestedQuantity;     // DB의 requested_quantity
    private String purpose;                // DB의 purpose
    private Boolean isApproved;            // DB의 is_approved
    private Long approvedBy;               // DB의 approved_by
    private String status;                 // DB의 status
    private Date createdAt;                // DB의 created_at
    private Date updatedAt;                // DB의 updated_at
    private String rejectionReason;
    private Integer remainingDays;
    private AuthDto user;
    
}
