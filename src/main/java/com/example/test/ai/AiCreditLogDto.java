package com.example.test.ai;

import java.sql.Timestamp;

import lombok.Data;

@Data
public class AiCreditLogDto {
    private Long id;
    private Long userId;
    private Long questionId;
    private Integer creditsUsed;       // 사용한 크레딧
    private String actionType;         // 'QUESTION', 'RECHARGE', 'ADMIN_GRANT'
    private String description;
    private Timestamp createdAt;
}

