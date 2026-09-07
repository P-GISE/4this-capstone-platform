// src/main/java/com/example/test/auth/ProfessorProfileDto.java
package com.example.test.auth;

import lombok.Data;
import java.sql.Date;

@Data
public class ProfessorProfileDto {
    private Long userId;                 // professor_profiles.user_id
    private String professorId;          // professor_profiles.professor_id
    private String department;           // professor_profiles.department
    private String departmentCode;       // professor_profiles.department_code
    private String universityName;       // professor_profiles.university_name
    private String position;             // professor_profiles.position
    private String gender;               // professor_profiles.gender ('M' or 'F')
    private Date birthDate;              // professor_profiles.birth_date
}
