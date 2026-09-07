// src/main/java/com/example/test/auth/StudentProfileDto.java
package com.example.test.auth;

import lombok.Data;
import java.sql.Date;

@Data
public class StudentProfileDto {
    private Long userId;                 // student_profiles.user_id
    private String studentId;            // student_profiles.student_id
    private String department;           // student_profiles.department
    private String departmentCode;       // student_profiles.department_code
    private String universityName;       // student_profiles.university_name
    private Integer grade;               // student_profiles.grade
    private Integer admissionYear;       // student_profiles.admission_year
    private String gender;               // student_profiles.gender ('M' or 'F')
    private Date birthDate;              // student_profiles.birth_date
    private String studentStatus;        // student_profiles.student_status
}
