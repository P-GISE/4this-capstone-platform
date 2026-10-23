package com.example.test.auth;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import com.example.test.auth.mapper.AuthMapper;
import com.example.test.libs.Email;

@Service
public class AuthServiceImpl implements AuthService {

    private static final Logger logger = LoggerFactory.getLogger(AuthServiceImpl.class);

    @Autowired
    private AuthMapper authMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private Email email;

    @Autowired
    private PlatformTransactionManager transactionManager;

    @Override
    public RegistrationResult register(AuthDto dto) {
        if (dto != null && !"STUDENT".equals(dto.getRole())) {
            return RegistrationResult.FAILURE;
        }
        email.requireConfigured();
        // 입력값 검증
        if (dto == null) {
            return RegistrationResult.FAILURE;
        }
        if (dto.getUsername() == null || dto.getUsername().trim().isEmpty() ||
            dto.getPassword() == null || dto.getPassword().trim().isEmpty() ||
            dto.getName() == null || dto.getName().trim().isEmpty() ||
            dto.getEmail() == null || dto.getEmail().trim().isEmpty() ||
            dto.getRole() == null || dto.getRole().trim().isEmpty()) {
            return RegistrationResult.FAILURE;
        }

        // 비밀번호 암호화
        dto.setPassword(passwordEncoder.encode(dto.getPassword()));

        try {
            // 1) users 테이블에 기본 사용자 정보 저장
            authMapper.insertUser(dto);
            Long userId = dto.getId();
            if (userId == null) {
                throw new RuntimeException("사용자 ID 생성에 실패했습니다.");
            }

            // 2) 역할(role)에 따라 프로필 테이블에 추가 정보 저장
            switch (dto.getRole()) {
                case "STUDENT": {
                    StudentProfileDto studentProfile = new StudentProfileDto();
                    studentProfile.setUserId(userId);
                    studentProfile.setStudentId(dto.getUsername());
                    String deptStu = dto.getDepartment() != null ? dto.getDepartment() : "기타";
                    studentProfile.setDepartment(deptStu);
                    studentProfile.setDepartmentCode(generateDepartmentCode(dto.getDepartment()));
                    studentProfile.setUniversityName("우리대학교");
                    studentProfile.setGrade(1);
                    studentProfile.setAdmissionYear(java.time.Year.now().getValue());
                    studentProfile.setStudentStatus("ACTIVE");
                    authMapper.insertStudentProfile(studentProfile);
                    break;
                }
                case "PROFESSOR": {
                    ProfessorProfileDto professorProfile = new ProfessorProfileDto();
                    professorProfile.setUserId(userId);
                    professorProfile.setProfessorId(dto.getUsername());
                    String deptProf = dto.getDepartment() != null ? dto.getDepartment() : "기타";
                    professorProfile.setDepartment(deptProf);
                    professorProfile.setDepartmentCode(generateDepartmentCode(dto.getDepartment()));
                    professorProfile.setUniversityName("우리대학교");
                    professorProfile.setPosition("교수");
                    authMapper.insertProfessorProfile(professorProfile);
                    break;
                }
                case "STAFF": {
                    StaffProfileDto staffProfile = new StaffProfileDto();
                    staffProfile.setUserId(userId);
                    staffProfile.setStaffId(dto.getUsername());
                    String deptStaff = dto.getDepartment() != null ? dto.getDepartment() : "기타";
                    staffProfile.setDepartment(deptStaff);
                    staffProfile.setDepartmentCode(generateDepartmentCode(dto.getDepartment()));
                    staffProfile.setPosition("직원");
                    authMapper.insertStaffProfile(staffProfile);
                    break;
                }
                case "ASSISTANT": {
                    AssistantProfileDto assistantProfile = new AssistantProfileDto();
                    assistantProfile.setUserId(userId);
                    assistantProfile.setAssistantId(dto.getUsername());
                    String labName = (dto.getDepartment() != null ? dto.getDepartment() : "기타") + " 연구실";
                    assistantProfile.setLabName(labName);
                    assistantProfile.setUniversityName("우리대학교");
                    authMapper.insertAssistantProfile(assistantProfile);
                    break;
                }
                case "ADMIN": {
                    AdminProfileDto adminProfile = new AdminProfileDto();
                    adminProfile.setUserId(userId);
                    adminProfile.setAdminId(dto.getUsername());
                    String deptAdmin = dto.getDepartment() != null ? dto.getDepartment() : "기타";
                    adminProfile.setDepartment(deptAdmin);
                    adminProfile.setDepartmentCode(generateDepartmentCode(dto.getDepartment()));
                    adminProfile.setPosition("관리자");
                    adminProfile.setAccessLevel("NORMAL");
                    adminProfile.setRoleType("SYSTEM");
                    authMapper.insertAdminProfile(adminProfile);
                    break;
                }
            }

            // 회원가입 성공 후 이메일 인증 발송
            if (!sendEmailVerification(dto.getEmail())) return RegistrationResult.EMAIL_DELIVERY_FAILED;
            
            return RegistrationResult.SUCCESS;

        } catch (DuplicateKeyException ex) {
            Throwable rootCause = ex.getRootCause();
            String msg = rootCause != null ? rootCause.getMessage() : ex.getMessage();
            
            if (msg != null) {
                if (msg.contains("username")) return RegistrationResult.DUPLICATE_USERNAME;
                if (msg.contains("email")) return RegistrationResult.DUPLICATE_EMAIL;
                if (msg.contains("phone")) return RegistrationResult.DUPLICATE_PHONE;
            }
            return RegistrationResult.DUPLICATE_USERNAME;
        } catch (RuntimeException ex) {
            logger.error("회원가입 중 런타임 오류 발생", ex);
            return RegistrationResult.FAILURE;
        } catch (Exception ex) {
            logger.error("회원가입 중 예상치 못한 오류 발생", ex);
            return RegistrationResult.FAILURE;
        }
    }

    // 학과명으로 부서코드 생성
    private String generateDepartmentCode(String department) {
        if (department == null || department.trim().isEmpty()) return "ETC";
        String safeDepartment = department;

        switch (safeDepartment) {
            case "컴퓨터공학과": return "CS";
            case "정보통신공학과": return "ICE";
            case "디지털콘텐츠학과": return "DC";
            case "소프트웨어공학과": return "SE";
            case "인공지능학과": return "AI";
            case "AI소프트웨어": return "AIS";
            case "행정부": return "ADM";
            case "교무부": return "ACA";
            case "학생부": return "STU";
            default:
                if (safeDepartment.contains("컴퓨터공학")) return "CS";
                if (safeDepartment.contains("정보통신공학")) return "ICE";
                if (safeDepartment.contains("디지털콘텐츠")) return "DC";
                if (safeDepartment.contains("소프트웨어공학")) return "SE";
                if (safeDepartment.contains("인공지능")) return "AI";
                if (safeDepartment.contains("AI소프트웨어")) return "AIS";
                if (safeDepartment.contains("행정")) return "ADM";
                if (safeDepartment.contains("교무")) return "ACA";
                if (safeDepartment.contains("학생")) return "STU";
                return "ETC";
        }
    }

    @Override
    public AuthDto login(AuthDto authDto) {
        AuthDto user = authMapper.findByUsername(authDto.getUsername());
        if (user != null && passwordEncoder.matches(authDto.getPassword(), user.getPassword())) {
            // 이메일 인증 확인
            if (!user.getIsEmailVerified()) {
                // 이메일 인증이 안 되어 있으면 특별한 상태 표시
                AuthDto unverifiedUser = new AuthDto();
                unverifiedUser.setEmail(user.getEmail());
                unverifiedUser.setUsername(user.getUsername());
                unverifiedUser.setId(-1L); // 특별한 ID로 이메일 미인증 상태 표시
                return unverifiedUser;
            }
            return getUserInfo(user);
        }
        return null;
    }

    @Override
    public AuthDto findByUsername(String username) {
        return authMapper.findByUsername(username);
    }

    @Override
    public boolean isEmailAvailable(String email) {
        return authMapper.findByEmail(email) == null;
    }

    @Override
    public boolean sendTemporaryPassword(String emailAddr) {
        email.requireConfigured();
        return new TransactionTemplate(transactionManager).execute(status -> {
            AuthDto user = authMapper.findByEmail(emailAddr);
            if (user == null) return false;
            String temp = generateTempPassword();
            String encoded = passwordEncoder.encode(temp);
            if (authMapper.updatePasswordByEmail(encoded, emailAddr) != 1) {
                status.setRollbackOnly();
                return false;
            }
            String subject = "[AI캡스톤] 임시 비밀번호 안내";
            String content = String.format(
                    "임시 비밀번호는 <strong>%s</strong> 입니다. 로그인 후 반드시 비밀번호를 변경해주세요.", temp);
            // SMTP failure must escape this transaction so the existing password remains valid.
            email.sendNaverEmail(subject, content, emailAddr);
            return true;
        });
    }

    private String generateTempPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 8; i++) {
            sb.append(chars.charAt((int)(Math.random() * chars.length())));
        }
        return sb.toString();
    }

    @Override
    public boolean verifyEmail(String username) {
        return authMapper.updateEmailVerified(username) > 0;
    }

    @Override
    public boolean resetPassword(String username, String newPassword) {
        String encoded = passwordEncoder.encode(newPassword);
        return authMapper.updatePasswordByUsername(encoded, username) > 0;
    }

    @Override
    public String encodePassword(String password) {
        return passwordEncoder.encode(password);
    }

    @Override
    public boolean matchesPassword(String raw, String encoded) {
        return passwordEncoder.matches(raw, encoded);
    }

    @Override
    public void updateLastLoginAt(Long userId) {
        authMapper.updateLastLoginAt(userId);
    }

    @Override
    public AuthDto getUserInfo(AuthDto authDto) {
        AuthDto user = authMapper.findByUsername(authDto.getUsername());
        if (user == null) return null;

        switch (user.getRole()) {
            case "STUDENT":
                user.setStudentProfile(authMapper.selectStudentProfile(user.getId()));
                break;
            case "PROFESSOR":
                user.setProfessorProfile(authMapper.selectProfessorProfile(user.getId()));
                break;
            case "STAFF":
                user.setStaffProfile(authMapper.selectStaffProfile(user.getId()));
                break;
            case "ASSISTANT":
                user.setAssistantProfile(authMapper.selectAssistantProfile(user.getId()));
                break;
            case "ADMIN":
                user.setAdminProfile(authMapper.selectAdminProfile(user.getId()));
                break;
        }

        if (user.getProfileImageUrl() == null || user.getProfileImageUrl().trim().isEmpty()) {
            String firstLetter = user.getName().substring(0, 1);
            user.setProfileImageUrl("https://via.placeholder.com/150x150/4751c9/ffffff?text=" + firstLetter);
        }

        return user;
    }

    @Override
    public boolean updateUser(AuthDto authDto) {
        try {
            // 입력 데이터 검증
            if (authDto == null) {
                logger.error("updateUser: authDto가 null입니다.");
                return false;
            }
            
            if (authDto.getId() == null) {
                logger.error("updateUser: authDto.getId()가 null입니다. username: {}", authDto.getUsername());
                return false;
            }
            
            logger.info("updateUser 시작: id={}, username={}, name={}, email={}, phone={}", 
                       authDto.getId(), authDto.getUsername(), authDto.getName(), 
                       authDto.getEmail(), authDto.getPhone());
            
            // 1) users 기본 정보 업데이트 (name, email, phone)
            int updateResult = authMapper.updateUser(authDto);
            logger.info("users 테이블 업데이트 결과: {} (영향받은 행 수)", updateResult);

            // 2) 역할별 프로필 테이블 업데이트
            Long userId = authDto.getId();
            String role = authDto.getRole();

            switch (role) {
                case "STUDENT": {
                    StudentProfileDto sp = authDto.getStudentProfile();
                    if (sp != null) {
                        sp.setUserId(userId);
                        authMapper.updateStudentProfile(sp);
                    }
                    break;
                }
                case "PROFESSOR": {
                    ProfessorProfileDto pp = authDto.getProfessorProfile();
                    if (pp != null) {
                        pp.setUserId(userId);
                        authMapper.updateProfessorProfile(pp);
                    }
                    break;
                }
                case "STAFF": {
                    StaffProfileDto sf = authDto.getStaffProfile();
                    if (sf != null) {
                        sf.setUserId(userId);
                        authMapper.updateStaffProfile(sf);
                    }
                    break;
                }
                case "ASSISTANT": {
                    AssistantProfileDto ap = authDto.getAssistantProfile();
                    if (ap != null) {
                        ap.setUserId(userId);
                        authMapper.updateAssistantProfile(ap);
                    }
                    break;
                }
                case "ADMIN": {
                    AdminProfileDto ad = authDto.getAdminProfile();
                    if (ad != null) {
                        ad.setUserId(userId);
                        authMapper.updateAdminProfile(ad);
                    }
                    break;
                }
            }

            logger.info("updateUser 완료: 모든 업데이트 성공");
            return true;
        } catch (Exception e) {
            logger.error("사용자 정보 업데이트 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public boolean updatePassword(String username, String newPassword) {
        try {
            String encodedPassword = passwordEncoder.encode(newPassword);
            return authMapper.updatePassword(username, encodedPassword) > 0;
        } catch (Exception e) {
            logger.error("비밀번호 업데이트 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public boolean deleteUser(Long userId) {
        try {
            return authMapper.deleteUser(userId) > 0;
        } catch (Exception e) {
            logger.error("사용자 삭제 중 오류 발생", e);
            return false;
        }
    }

    @Override
    public List<AuthDto> getAllUsersWithProfiles() {
        List<AuthDto> all = authMapper.selectAllUsersBasic();
        for (AuthDto user : all) {
            Long uid = user.getId();
            switch (user.getRole()) {
                case "STUDENT":
                    user.setStudentProfile(authMapper.selectStudentProfile(uid));
                    break;
                case "PROFESSOR":
                    user.setProfessorProfile(authMapper.selectProfessorProfile(uid));
                    break;
                case "STAFF":
                    user.setStaffProfile(authMapper.selectStaffProfile(uid));
                    break;
                case "ASSISTANT":
                    user.setAssistantProfile(authMapper.selectAssistantProfile(uid));
                    break;
                case "ADMIN":
                    user.setAdminProfile(authMapper.selectAdminProfile(uid));
                    break;
            }
        }
        return all;
    }

    @Override
    public AuthDto findById(Long userId) {
        AuthDto user = authMapper.findById(userId);
        if (user == null) return null;

        switch (user.getRole()) {
            case "STUDENT":
                user.setStudentProfile(authMapper.selectStudentProfile(userId));
                break;
            case "PROFESSOR":
                user.setProfessorProfile(authMapper.selectProfessorProfile(userId));
                break;
            case "STAFF":
                user.setStaffProfile(authMapper.selectStaffProfile(userId));
                break;
            case "ASSISTANT":
                user.setAssistantProfile(authMapper.selectAssistantProfile(userId));
                break;
            case "ADMIN":
                user.setAdminProfile(authMapper.selectAdminProfile(userId));
                break;
        }
        return user;
    }

    @Override
    public void changeAdminAccessLevel(Long userId, String accessLevel) {
        AdminProfileDto admin = new AdminProfileDto();
        admin.setUserId(userId);
        admin.setAccessLevel(accessLevel);
        authMapper.updateAdminAccessLevel(admin);
    }

    @Override
    public AuthDto getUserById(Long userId) {
        return authMapper.selectById(userId);
    }

    // 이메일 인증 토큰을 임시로 메모리에 저장 (실제 환경에서는 DB나 Redis 사용 권장)
    private final Map<String, String> emailVerificationTokens = new HashMap<>();
    private final Map<String, Long> tokenCreationTime = new HashMap<>();

    @Override
    public boolean sendEmailVerification(String emailAddr) {
        email.requireConfigured();
        String token = UUID.randomUUID().toString();
        try {
            // 토큰 생성
            emailVerificationTokens.put(token, emailAddr);
            tokenCreationTime.put(token, System.currentTimeMillis());

            // 이메일 발송
            String subject = "[AI 캡스톤디자인] 이메일 인증";
            String verificationUrl = System.getenv("APP_ORIGIN") + "/auth/verify-email?token=" + token;
            
            String content = String.format(
                "<div style=\"max-width: 600px; margin: 0 auto; padding: 20px; font-family: Arial, sans-serif;\">" +
                "<div style=\"text-align: center; margin-bottom: 30px;\">" +
                "<h1 style=\"color: #4751c9;\">AI 캡스톤디자인 관리시스템</h1>" +
                "<h2>이메일 인증</h2>" +
                "</div>" +
                "<div style=\"background: #f9f9f9; padding: 20px; border-radius: 8px; margin-bottom: 20px;\">" +
                "<p>안녕하세요!</p>" +
                "<p>회원가입을 완료하기 위해 이메일 인증이 필요합니다.</p>" +
                "<p>아래 버튼을 클릭하여 이메일 인증을 완료해주세요.</p>" +
                "</div>" +
                "<div style=\"text-align: center; margin: 30px 0;\">" +
                "<a href=\"%s\" style=\"background: #4751c9; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-size: 16px; font-weight: bold;\">" +
                "이메일 인증하기" +
                "</a>" +
                "</div>" +
                "<div style=\"color: #666; font-size: 14px;\">" +
                "<p>* 이 링크는 24시간 후 만료됩니다.</p>" +
                "<p>* 만약 버튼이 작동하지 않는다면 아래 링크를 복사하여 브라우저에 붙여넣기 해주세요:</p>" +
                "<p style=\"word-break: break-all;\">%s</p>" +
                "</div>" +
                "</div>", verificationUrl, verificationUrl);

            email.sendNaverEmail(subject, content, emailAddr);
            logger.info("verification_email_sent");
            return true;
        } catch (Exception e) {
            emailVerificationTokens.remove(token);
            tokenCreationTime.remove(token);
            logger.warn("verification_email_failed");
            return false;
        }
    }

    @Override
    public boolean verifyEmailToken(String token) {
        try {
            String emailAddr = emailVerificationTokens.get(token);
            if (emailAddr == null) {
                return false; // 토큰이 존재하지 않음
            }

            // 토큰 만료 시간 체크 (24시간)
            Long creationTime = tokenCreationTime.get(token);
            if (creationTime == null || (System.currentTimeMillis() - creationTime) > 24 * 60 * 60 * 1000) {
                // 만료된 토큰 삭제
                emailVerificationTokens.remove(token);
                tokenCreationTime.remove(token);
                return false;
            }

            // 이메일로 사용자 찾고 인증 상태 업데이트
            AuthDto user = authMapper.findByEmail(emailAddr);
            if (user != null) {
                int updated = authMapper.updateEmailVerified(user.getUsername());
                if (updated > 0) {
                    // 사용된 토큰 삭제
                    emailVerificationTokens.remove(token);
                    tokenCreationTime.remove(token);
                    logger.info("email_verified");
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            logger.warn("email_verification_failed");
            return false;
        }
    }

    @Override
    public boolean resendEmailVerification(String emailAddr) {
        // 기존 토큰들 중 해당 이메일과 관련된 것들 삭제
        emailVerificationTokens.entrySet().removeIf(entry -> emailAddr.equals(entry.getValue()));
        tokenCreationTime.entrySet().removeIf(entry -> {
            String token = entry.getKey();
            return emailAddr.equals(emailVerificationTokens.get(token));
        });
        
        // 새로운 인증 이메일 발송
        return sendEmailVerification(emailAddr);
    }

    @Override
    public List<AuthDto> searchUsers(String query) {
        try {
            List<AuthDto> users = authMapper.searchUsers(query);
            // 프로필 정보는 검색에서는 불필요하므로 기본 정보만 반환
            return users;
        } catch (Exception e) {
            logger.error("사용자 검색 중 오류 발생: " + e.getMessage(), e);
            return new ArrayList<>(); // 빈 리스트 반환
        }
    }
}
