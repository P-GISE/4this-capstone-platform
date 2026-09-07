package com.example.test.auth;

import java.sql.Timestamp;

import lombok.Data;

@Data
public class AuthDto {
    // users 테이블 기본 컬럼
    private Long    id;
    private String  username;
    private String  password;
    private String  name;
    private String  email;
    private String  phone;
    private String  role;            // "STUDENT","PROFESSOR","STAFF","ASSISTANT","ADMIN"
    private Boolean isEmailVerified;
    private Boolean status;
    private Timestamp lastLoginAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // 회원가입 시 추가 정보
    private String department;       // 학과/부서 정보

    // 각 역할별 프로필 DTO
    private StudentProfileDto    studentProfile;
    private ProfessorProfileDto  professorProfile;
    private StaffProfileDto      staffProfile;
    private AssistantProfileDto  assistantProfile;
    private AdminProfileDto      adminProfile;

    // UI용 프로필 이미지 URL
    private String profileImageUrl;

    /**
     * 민감한 정보를 제외한 안전한 문자열 표현
     */
    public String toSafeString() {
        return "AuthDto{" +
                "id=" + id +
                ", username='" + (username != null ? username : "") + '\'' +
                ", name='" + (name != null ? name : "") + '\'' +
                ", email='" + (email != null ? email : "") + '\'' +
                ", phone='" + (phone != null ? phone : "") + '\'' +
                ", role='" + (role != null ? role : "") + '\'' +
                ", department='" + (department != null ? department : "") + '\'' +
                ", isEmailVerified=" + isEmailVerified +
                ", status=" + status +
                '}';
    }

    // 역할별 프로필에서 부서 정보 가져오기
    public String getDepartment() {
        if (department != null) return department; // 회원가입 시 입력된 정보
        
        if (role == null) return null; // role이 null인 경우 안전하게 처리
        
        switch (role) {
            case "STUDENT":
                return studentProfile != null ? studentProfile.getDepartment() : null;
            case "PROFESSOR":
                return professorProfile != null ? professorProfile.getDepartment() : null;
            case "STAFF":
                return staffProfile != null ? staffProfile.getDepartment() : null;
            case "ADMIN":
                return adminProfile != null ? adminProfile.getDepartment() : null;
            default:
                return null;
        }
    }

    // 역할별 프로필에서 ID 가져오기
    public String getStudentId() {
        return studentProfile != null ? studentProfile.getStudentId() : null;
    }

    public String getProfessorId() {
        return professorProfile != null ? professorProfile.getProfessorId() : null;
    }

    public String getStaffId() {
        return staffProfile != null ? staffProfile.getStaffId() : null;
    }

    public String getAdminId() {
        return adminProfile != null ? adminProfile.getAdminId() : null;
    }

    public String getAssistantId() {
        return assistantProfile != null ? assistantProfile.getAssistantId() : null;
    }
    
    /**
     * 현재 사용자 역할에 맞는 ID 반환
     */
    public String getCurrentRoleId() {
        if (role == null) return null;
        
        switch (role) {
            case "STUDENT":
                return getStudentId();
            case "PROFESSOR":
                return getProfessorId();
            case "STAFF":
                return getStaffId();
            case "ADMIN":
                return getAdminId();
            case "ASSISTANT":
                return getAssistantId();
            default:
                return null;
        }
    }
}