package com.example.test.auth;

import lombok.Data;
import java.sql.Date;

@Data
public class StaffProfileDto {
    private Long userId;                 // staff_profiles.user_id
    private String staffId;              // staff_profiles.staff_id
    private String department;           // staff_profiles.department
    private String departmentCode;       // staff_profiles.department_code
    private String position;             // staff_profiles.position
    private String gender;               // staff_profiles.gender ('M' or 'F')
    private Date birthDate;              // staff_profiles.birth_date
}
