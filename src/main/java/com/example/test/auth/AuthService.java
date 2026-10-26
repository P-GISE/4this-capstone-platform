package com.example.test.auth;

import java.util.List;

public interface AuthService {

    /**
     * 회원가입 처리 결과 코드
     */
    enum RegistrationResult {
        SUCCESS,               // 정상 등록
        DUPLICATE_USERNAME,    // 아이디 중복
        DUPLICATE_EMAIL,       // 이메일 중복
        DUPLICATE_PHONE,       // 전화번호 중복
        EMAIL_DELIVERY_FAILED, // 등록되었지만 인증 메일 전송 실패
        FAILURE                // 기타 실패
    }

    /**
     * 회원가입 처리
     * @return RegistrationResult 으로 결과를 구분
     */
    RegistrationResult register(AuthDto authDto);

    AuthDto login(AuthDto authDto);

    AuthDto findByUsername(String username);

    boolean isEmailAvailable(String email);

    boolean requestPasswordReset(String email, String clientAddress);

    boolean verifyEmail(String username);

    boolean resetPassword(String token, String newPassword);

    String encodePassword(String password);

    boolean matchesPassword(String rawPassword, String encodedPassword);

    void updateLastLoginAt(Long userId);

    /**
     * 사용자 정보 조회 (프로필 포함)
     */
    AuthDto getUserInfo(AuthDto authDto);

    /**
     * 사용자 정보 업데이트
     */
    boolean updateUser(AuthDto authDto);

    boolean updateOwnProfile(Long actorId, ProfileUpdateDto profile);

    /**
     * 비밀번호 업데이트
     */
    boolean updatePassword(String username, String newPassword);

    /**
     * 사용자 삭제
     */
    boolean deleteUser(Long userId);

    // 1) 전체 사용자+프로필 리스트 조회
    List<AuthDto> getAllUsersWithProfiles();

    // 2) ID로 사용자 정보(기본 users + 프로필) 조회
    AuthDto findById(Long userId);

    // 3) ADMIN accessLevel 변경 (서브 어드민 지정/해제)
    void changeAdminAccessLevel(Long userId, String accessLevel);


    AuthDto getUserById(Long userId); // 선언만!

    /**
     * 이메일 인증 토큰 생성 및 발송
     */
    boolean sendEmailVerification(String email);

    /**
     * 이메일 인증 토큰 검증
     */
    boolean verifyEmailToken(String token);

    /**
     * 이메일 인증 재발송
     */
    boolean resendEmailVerification(String email);

    /**
     * 사용자 검색 (이름 또는 사용자명으로)
     */
    List<AuthDto> searchUsers(String query);

}
