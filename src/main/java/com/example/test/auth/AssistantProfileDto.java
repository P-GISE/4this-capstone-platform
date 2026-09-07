package com.example.test.auth;

import java.sql.Date;

import lombok.Data;

@Data
public class AssistantProfileDto {
    private Long userId;
    private String assistantId;
    private String labName;
    private String universityName;   
    private String department;    // 실제 테이블에 있는 컬럼
    private String majorField;    // 실제 테이블에 있는 컬럼
    private String gender;
    private Date birthDate;
}

