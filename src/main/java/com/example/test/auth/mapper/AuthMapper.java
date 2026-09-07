package com.example.test.auth.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.test.auth.AdminProfileDto;
import com.example.test.auth.AssistantProfileDto;
import com.example.test.auth.AuthDto;
import com.example.test.auth.ProfessorProfileDto;
import com.example.test.auth.StaffProfileDto;
import com.example.test.auth.StudentProfileDto;

@Mapper
public interface AuthMapper {

    int insertUser(AuthDto dto);

    int insertStudentProfile(StudentProfileDto dto);
    int insertProfessorProfile(ProfessorProfileDto dto);
    int insertAdminProfile(AdminProfileDto dto);
    int insertStaffProfile(StaffProfileDto dto);
    int insertAssistantProfile(AssistantProfileDto dto);

    AuthDto findByUsername(String username);
    AuthDto findByEmail(String email);

    /**
     * 이메일 주소(email)에 해당하는 사용자의 비밀번호(password)를 업데이트
     * @param password 새로 설정할 암호화된 비밀번호
     * @param email    대상 사용자의 이메일 주소
     */
    int updatePasswordByEmail(
        @Param("password") String password,
        @Param("email")    String email
    );

    /**
     * 사용자 이름(username)에 해당하는 사용자의 비밀번호(password)를 업데이트
     * @param password 새로 설정할 암호화된 비밀번호
     * @param username 대상 사용자의 로그인 이름
     */
    int updatePasswordByUsername(
        @Param("password") String password,
        @Param("username") String username
    );

    /**
     * 이메일 인증 처리 (username 기준)
     * @param username 대상 사용자의 로그인 이름
     */
    int updateEmailVerified(@Param("username") String username);

    // --- **여기에 아래 조회용 메서드를 추가하세요** ---
    StudentProfileDto    selectStudentProfile   (@Param("userId") Long userId);
    ProfessorProfileDto  selectProfessorProfile (@Param("userId") Long userId);
    StaffProfileDto      selectStaffProfile     (@Param("userId") Long userId);
    AssistantProfileDto  selectAssistantProfile (@Param("userId") Long userId);
    AdminProfileDto      selectAdminProfile     (@Param("userId") Long userId);   
    
    int updateLastLoginAt(@Param("userId") Long userId);

    /**
     * 사용자 정보 업데이트
     */
    int updateUser(AuthDto authDto);

    /**
     * 비밀번호만 업데이트
     */
    int updatePassword(@Param("username") String username, @Param("password") String password);

    /**
     * 사용자 삭제
     */
    int deleteUser(@Param("userId") Long userId);

    
    // 전체 사용자 기본 정보만 가져오는 쿼리 (users 테이블만)
    List<AuthDto> selectAllUsersBasic();

    // ID로 users 기본 정보만 가져오는 쿼리
    AuthDto findById(@Param("userId") Long userId);

    // ADMIN accessLevel 변경 쿼리
    int updateAdminAccessLevel(AdminProfileDto admin);

    // — 아래 5개를 추가 선언 —
    int updateStudentProfile(StudentProfileDto dto);
    int updateProfessorProfile(ProfessorProfileDto dto);
    int updateStaffProfile(StaffProfileDto dto);
    int updateAssistantProfile(AssistantProfileDto dto);
    int updateAdminProfile(AdminProfileDto dto); 
    AuthDto selectById(Long id);

    /**
     * 사용자 검색 (이름 또는 사용자명으로)
     */
    List<AuthDto> searchUsers(@Param("query") String query);
   
}