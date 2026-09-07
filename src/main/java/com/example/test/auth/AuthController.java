package com.example.test.auth;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.http.ResponseEntity;

import com.example.test.adminlog.AdminLogService;
import com.example.test.auth.AuthService.RegistrationResult;
import com.example.test.chat.OnlineUserService;
import com.example.test.chat.UserStatusService;
import com.example.test.userlog.UserLogService;

@Controller
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthService authService;
    
    @Autowired
    private OnlineUserService onlineUserService;
    
    @Autowired
    private UserStatusService userStatusService;
    
    @Autowired
    private AdminLogService adminLogService;
    
    @Autowired
    private UserLogService userLogService;

    @GetMapping("/login")
    public String showLoginPage() {
        return "auth/login";
    }

    @PostMapping("/login")
    public String login(@ModelAttribute AuthDto authDto,
                        HttpSession session,
                        HttpServletRequest request,
                        Model model) {
        AuthDto loginUser = authService.login(authDto);
        if (loginUser != null) {
            // 이메일 미인증 사용자 체크
            if (loginUser.getId() == -1L) {
                model.addAttribute("emailVerificationRequired", true);
                model.addAttribute("userEmail", loginUser.getEmail());
                model.addAttribute("username", loginUser.getUsername());
                model.addAttribute("loginError", "이메일 인증을 완료해주세요. 인증 이메일을 재발송하시겠습니까?");
                return "auth/login";
            }
            
            // 로그인 성공 → 세션에 로그인 사용자 정보와 userId, role을 모두 저장해야 함
            session.setAttribute("loginUser", loginUser);
            session.setAttribute("userId", loginUser.getId());   // ★ 반드시 추가
            session.setAttribute("role", loginUser.getRole());
            
            // 로그인 시 온라인 상태로 설정 (메모리 기반)
            onlineUserService.setUserOnline(loginUser.getId(), session.getId());
            
            // 로그인 시 온라인 상태로 설정 (데이터베이스 기반)
            userStatusService.setUserOnline(loginUser.getId());
            
            System.out.println("로그인 성공 - 사용자 온라인 상태 설정: " + loginUser.getName() + " (ID: " + loginUser.getId() + ")");
            
            // 관리자 로그인 로깅
            if ("ADMIN".equals(loginUser.getRole())) {
                try {
                    adminLogService.logLogin(
                        loginUser.getId(), 
                        true, 
                        "관리자 로그인 성공 - " + loginUser.getName(), 
                        request
                    );
                } catch (Exception e) {
                    System.err.println("관리자 로그인 로깅 실패: " + e.getMessage());
                }
            }
            
            // 모든 사용자 로그인 로깅
            try {
                userLogService.logLoginSuccess(loginUser.getId(), request);
            } catch (Exception e) {
                System.err.println("사용자 로그인 로깅 실패: " + e.getMessage());
            }
            
            return "redirect:/dashboard";
        } else {
            // 로그인 실패 로깅
            try {
                userLogService.logLoginFailure(authDto.getUsername(), "잘못된 아이디 또는 비밀번호", request);
                
                // 관리자 계정인지 확인 후 관리자 로그에도 기록
                AuthDto tempUser = authService.findByUsername(authDto.getUsername());
                if (tempUser != null && "ADMIN".equals(tempUser.getRole())) {
                    adminLogService.logLogin(
                        tempUser.getId(),
                        false,
                        "관리자 로그인 실패 - 잘못된 비밀번호",
                        request
                    );
                }
            } catch (Exception e) {
                System.err.println("로그인 실패 로깅 중 오류: " + e.getMessage());
            }
            
            model.addAttribute("loginError", "아이디 또는 비밀번호가 틀렸습니다.");
            return "auth/login";
        }
    }
    
    @GetMapping("/logout")
    public String logout(HttpSession session, HttpServletRequest request) {
        AuthDto u = (AuthDto) session.getAttribute("loginUser");
        if (u != null) {
            authService.updateLastLoginAt(u.getId());
            
            // 로그아웃 시 오프라인 상태로 설정 (메모리 기반)
            onlineUserService.setUserOffline(u.getId());
            
            // 로그아웃 시 오프라인 상태로 설정 (데이터베이스 기반)
            userStatusService.setUserOffline(u.getId());
            
            System.out.println("로그아웃 - 사용자 오프라인 상태 설정: " + u.getName() + " (ID: " + u.getId() + ")");
            
            // 관리자 로그아웃 로깅
            if ("ADMIN".equals(u.getRole())) {
                try {
                    adminLogService.logLogout(u.getId(), request);
                } catch (Exception e) {
                    System.err.println("관리자 로그아웃 로깅 실패: " + e.getMessage());
                }
            }
            
            // 모든 사용자 로그아웃 로깅
            try {
                userLogService.logLogout(u.getId(), request);
            } catch (Exception e) {
                System.err.println("사용자 로그아웃 로깅 실패: " + e.getMessage());
            }
        }
        session.invalidate();
        return "redirect:/auth/login";
    }

    @GetMapping("/register")
    public String showRegisterPage() {
        return "auth/register";
    }

    @PostMapping("/register")
    public String register(@ModelAttribute AuthDto authDto, Model model) {
        RegistrationResult result = authService.register(authDto);
        if (result == RegistrationResult.SUCCESS) {
            model.addAttribute("successMessage", "회원가입이 완료되었습니다! 이메일 인증 후 로그인해주세요.");
            model.addAttribute("emailSent", true);
            model.addAttribute("userEmail", authDto.getEmail());
            return "auth/register-success";
        }
        model.addAttribute("errorCode", result.name());
        return "auth/register";
    }

    @GetMapping("/find-password")
    public String showFindPasswordPage() {
        return "auth/find-password";
    }

    @PostMapping("/find-password")
    public String findPassword(@RequestParam String email, Model model) {
        boolean sent = authService.sendTemporaryPassword(email);
        if (sent) {
            model.addAttribute("message", "임시 비밀번호를 이메일로 보냈습니다.");
        } else {
            model.addAttribute("error", "등록된 이메일이 아닙니다.");
        }
        return "auth/find-password";
    }

    @GetMapping("/terms")
    public String showTermsPage() {
        return "auth/terms";
    }

    @GetMapping("/privacy")
    public String showPrivacyPage() {
        return "auth/privacy";
    }

    @GetMapping("/verify-email")
    public String verifyEmail(@RequestParam String token, Model model) {
        boolean verified = authService.verifyEmailToken(token);
        if (verified) {
            model.addAttribute("verificationSuccess", true);
            model.addAttribute("message", "이메일 인증이 성공적으로 완료되었습니다. 이제 로그인하실 수 있습니다.");
        } else {
            model.addAttribute("verificationSuccess", false);
            model.addAttribute("message", "이메일 인증에 실패했습니다. 토큰이 만료되었거나 유효하지 않습니다.");
        }
        return "auth/email-verification-result";
    }

    @PostMapping("/resend-verification")
    public String resendVerification(@RequestParam String email, Model model) {
        boolean sent = authService.resendEmailVerification(email);
        if (sent) {
            model.addAttribute("message", "인증 이메일을 재발송했습니다. 이메일을 확인해주세요.");
        } else {
            model.addAttribute("error", "이메일 재발송에 실패했습니다.");
        }
        return "auth/login";
    }

    /**
     * 사용자 검색 API
     */
    @GetMapping("/search")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> searchUsers(@RequestParam String query, HttpSession session) {
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                return ResponseEntity.status(401).build();
            }

            List<AuthDto> users = authService.searchUsers(query);
            List<Map<String, Object>> result = users.stream()
                    .map(user -> {
                        // 프로필 정보 조회하여 학번/교번 정보 가져오기
                        AuthDto userWithProfile = authService.findById(user.getId());
                        
                        Map<String, Object> userMap = new HashMap<>();
                        userMap.put("id", user.getId());
                        userMap.put("name", user.getName());
                        userMap.put("username", user.getUsername());
                        userMap.put("position", user.getRole());
                        userMap.put("role", user.getRole());
                        
                        // 학번/교번 정보 추가
                        if (userWithProfile != null) {
                            String roleId = userWithProfile.getCurrentRoleId();
                            userMap.put("roleId", roleId != null ? roleId : user.getUsername());
                        } else {
                            userMap.put("roleId", user.getUsername());
                        }
                        
                        return userMap;
                    })
                    .collect(Collectors.toList());

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }
}
