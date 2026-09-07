package com.example.test.ai;

import java.sql.Timestamp;

import lombok.Data;

@Data
public class UserAiCreditDto {
    private Long userId;
    private Integer totalCredits;      // 총 할당 크레딧
    private Integer usedCredits;       // 사용한 크레딧
    private Integer remainingCredits;  // 남은 크레딧
    private Timestamp lastRechargedAt; // 마지막 충전 시각
    private Timestamp createdAt;
    private Timestamp updatedAt;
}

