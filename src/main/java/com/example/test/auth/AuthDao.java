package com.example.test.auth;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AuthDao {
    int insertUser(AuthDto user);

    int insertStudentProfile(StudentProfileDto student);
    int insertProfessorProfile(ProfessorProfileDto professor);
    int insertAdminProfile(AdminProfileDto admin);
    int insertStaffProfile(StaffProfileDto staff);
    int insertAssistantProfile(AssistantProfileDto assistant);
}
