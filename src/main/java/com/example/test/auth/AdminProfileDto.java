// src/main/java/com/example/test/auth/AdminProfileDto.java
package com.example.test.auth;

import lombok.Data;
import java.sql.Date;

@Data
public class AdminProfileDto {
    private Long userId;                 // admin_profiles.user_id
    private String adminId;              // admin_profiles.admin_id
    private String department;           // admin_profiles.department
    private String departmentCode;       // admin_profiles.department_code
    private String position;             // admin_profiles.position
    private String accessLevel;          // admin_profiles.access_level ('NORMAL' or 'SUPER')
    private String roleType;             // admin_profiles.role_type
    private String gender;               // admin_profiles.gender ('M' or 'F')
    private Date birthDate;              // admin_profiles.birth_date
}
