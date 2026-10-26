package com.example.test.mypage;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.test.auth.AuthDto;
import com.example.test.auth.AuthService;
import com.example.test.auth.ProfileUpdateDto;

/**
 * 사용자 프로필 관련 요청을 처리하는 컨트롤러
 */
@Controller
@RequestMapping("/mypage")
public class MypageController {

    private static final Logger logger = LoggerFactory.getLogger(MypageController.class);

    @Autowired
    private AuthService authService;

    /**
     * 세션에서 로그인된 사용자 정보를 가져오는 헬퍼 메서드
     */
    private String getLoggedInUsername(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        
        // 세션에서 loginUser 객체 가져오기
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        return loginUser != null ? loginUser.getUsername() : null;
    }

    /**
     * 로그인 체크 및 리다이렉트 처리
     */
    private boolean checkLogin(String username, RedirectAttributes redirectAttributes) {
        if (username == null || username.trim().isEmpty()) {
            logger.warn("세션에 username이 없습니다. 로그인 페이지로 리다이렉트");
            redirectAttributes.addFlashAttribute("errorMessage", "로그인이 필요합니다.");
            return false;
        }
        return true;
    }

    /**
     * 프로필 화면 요청 처리 (GET 방식)
     */
    @GetMapping("")
    public String profile(Model model, HttpServletRequest request, RedirectAttributes redirectAttributes) {
        logger.info("프로필 화면 요청");
        
        // 세션에서 로그인된 사용자 ID 가져오기
        String username = getLoggedInUsername(request);
        
        if (!checkLogin(username, redirectAttributes)) {
            return "redirect:/auth/login";
        }

        try {
            // 사용자 정보 조회
            AuthDto user = new AuthDto();
            user.setUsername(username);
            user = authService.getUserInfo(user);

            if (user == null) {
                logger.error("사용자 정보를 찾을 수 없습니다. username: {}", username);
                redirectAttributes.addFlashAttribute("errorMessage", "사용자 정보를 찾을 수 없습니다.");
                return "redirect:/auth/login";
            }

            // 모델에 사용자 정보 담기
            model.addAttribute("profile", user);

            logger.info("프로필 화면 렌더링 완료. username: {}", username);
            return "mypage/mypage";
            
        } catch (Exception e) {
            logger.error("프로필 조회 중 오류 발생", e);
            redirectAttributes.addFlashAttribute("errorMessage", "프로필 정보를 불러오는 중 오류가 발생했습니다.");
            return "redirect:/";
        }
    }

    /**
     * 프로필 수정 화면 요청 처리 (GET 방식)
     * URL 경로를 /update-mypage로 수정
     */
    @GetMapping("/update-mypage")
    public String updateProfileGet(Model model, HttpServletRequest request, RedirectAttributes redirectAttributes) {
        logger.info("프로필 수정 화면 요청");
        
        // 세션에서 로그인된 사용자 아이디 가져오기
        String username = getLoggedInUsername(request);
        
        if (!checkLogin(username, redirectAttributes)) {
            return "redirect:/auth/login";
        }

        try {
            // 사용자 정보 조회
            AuthDto user = new AuthDto();
            user.setUsername(username);
            user = authService.getUserInfo(user);

            if (user == null) {
                logger.error("사용자 정보를 찾을 수 없습니다. username: {}", username);
                redirectAttributes.addFlashAttribute("errorMessage", "사용자 정보를 찾을 수 없습니다.");
                return "redirect:/mypage";
            }

            // 모델에 사용자 정보 담기
            model.addAttribute("profile", user);
            logger.info("프로필 수정 화면 렌더링 완료. username: {}", username);

            return "mypage/updateMypage";
            
        } catch (Exception e) {
            logger.error("프로필 수정 화면 로드 중 오류 발생", e);
            redirectAttributes.addFlashAttribute("errorMessage", "프로필 수정 화면을 불러오는 중 오류가 발생했습니다.");
            return "redirect:/mypage";
        }
    }

    /**
     * 프로필 수정 요청 처리 (POST 방식)
     * URL 경로를 /update-mypage로 수정
     */
    @PostMapping("/update-mypage")
    public String updateProfilePost(@ModelAttribute("profile") ProfileUpdateDto profile,
                                  BindingResult bindingResult,
                                  HttpServletRequest request, 
                                  RedirectAttributes redirectAttributes) {
        
        HttpSession session = request.getSession(false);
        Object principal = session == null ? null : session.getAttribute("loginUser");
        AuthDto actor = principal instanceof AuthDto ? (AuthDto) principal : null;
        if (actor == null || actor.getId() == null) {
            return "redirect:/auth/login";
        }
        if (bindingResult.hasErrors()) {
            redirectAttributes.addFlashAttribute("errorMessage", "입력 데이터가 올바르지 않습니다.");
            return "redirect:/mypage/update-mypage";
        }
        try {
            if (authService.updateOwnProfile(actor.getId(), profile)) {
                AuthDto updatedUser = authService.findById(actor.getId());
                if (updatedUser != null) session.setAttribute("loginUser", updatedUser);
                logger.info("profile_update_completed actor_id={}", actor.getId());
                redirectAttributes.addFlashAttribute("successMessage", "프로필이 성공적으로 수정되었습니다.");
                return "redirect:/mypage";
            }
        } catch (Exception e) {
            logger.error("profile_update_failed");
        }
        redirectAttributes.addFlashAttribute("errorMessage", "프로필 수정에 실패했습니다. 다시 시도해주세요.");
        return "redirect:/mypage/update-mypage";
    }

    /**
     * 비밀번호 수정 화면 요청 처리 (GET 방식)
     */
    @GetMapping("/update-password")
    public String updatePasswordGet(HttpServletRequest request, RedirectAttributes redirectAttributes) {
        logger.info("비밀번호 수정 화면 요청");
        
        String username = getLoggedInUsername(request);
        if (!checkLogin(username, redirectAttributes)) {
            return "redirect:/auth/login";
        }
        
        return "mypage/updatePassword";
    }

    /**
     * 비밀번호 수정 요청 처리 (POST 방식) - 수정된 버전
     */
    @PostMapping("/update-password")
    public String updatePasswordPost(@ModelAttribute AuthDto user, 
                                HttpServletRequest request, 
                                RedirectAttributes redirectAttributes) {
        
        logger.info("=== 비밀번호 수정 요청 시작 ===");
        
        String username = getLoggedInUsername(request);
        logger.info("세션 username: {}", username);
        
        if (!checkLogin(username, redirectAttributes)) {
            return "redirect:/auth/login";
        }

        String currentPassword = request.getParameter("currentPassword");
        String newPassword = user.getPassword();
        
        logger.info("현재 비밀번호 입력됨: {}", currentPassword != null && !currentPassword.isEmpty());
        logger.info("새 비밀번호 입력됨: {}", newPassword != null && !newPassword.isEmpty());

        if (currentPassword == null || currentPassword.trim().isEmpty()) {
            logger.warn("현재 비밀번호가 입력되지 않았습니다.");
            redirectAttributes.addFlashAttribute("errorMessage", "현재 비밀번호를 입력해주세요.");
            return "redirect:/mypage/update-password";
        }

        if (newPassword == null || newPassword.trim().isEmpty()) {
            logger.warn("새 비밀번호가 입력되지 않았습니다.");
            redirectAttributes.addFlashAttribute("errorMessage", "새 비밀번호를 입력해주세요.");
            return "redirect:/mypage/update-password";
        }

        if (newPassword.length() < 8) {
            logger.warn("새 비밀번호가 8자 미만입니다.");
            redirectAttributes.addFlashAttribute("errorMessage", "비밀번호는 8자 이상이어야 합니다.");
            return "redirect:/mypage/update-password";
        }

        try {
            AuthDto currentUser = authService.findByUsername(username);
            if (currentUser == null) {
                logger.error("사용자 정보를 찾을 수 없습니다. username: {}", username);
                redirectAttributes.addFlashAttribute("errorMessage", "사용자 정보를 찾을 수 없습니다.");
                return "redirect:/mypage/update-password";
            }

            boolean passwordMatches = authService.matchesPassword(currentPassword, currentUser.getPassword());
            logger.info("현재 비밀번호 검증 결과: {}", passwordMatches);
            
            if (!passwordMatches) {
                logger.warn("현재 비밀번호가 일치하지 않습니다.");
                redirectAttributes.addFlashAttribute("errorMessage", "현재 비밀번호가 올바르지 않습니다.");
                return "redirect:/mypage/update-password";
            }

            boolean result = authService.updatePassword(username, newPassword);
            logger.info("비밀번호 업데이트 결과: {}", result);

            if (result) {
                logger.info("비밀번호 수정 성공!");
                redirectAttributes.addFlashAttribute("successMessage", "비밀번호가 성공적으로 변경되었습니다.");
                return "redirect:/mypage";
            } else {
                logger.warn("비밀번호 수정 실패 - updatePassword가 false 반환");
                redirectAttributes.addFlashAttribute("errorMessage", "비밀번호 변경에 실패했습니다.");
                return "redirect:/mypage/update-password";
            }
            
        } catch (Exception e) {
            logger.error("비밀번호 수정 중 예외 발생", e);
            redirectAttributes.addFlashAttribute("errorMessage", "비밀번호 변경 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/mypage/update-password";
        } finally {
            logger.info("=== 비밀번호 수정 요청 종료 ===");
        }
    }

    /**
     * 회원 탈퇴 처리
     */
    @PostMapping("/delete")
    public String delete(HttpServletRequest request, RedirectAttributes redirectAttributes) {
        logger.info("회원 탈퇴 요청");
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            logger.warn("세션이 없습니다. 로그인 페이지로 리다이렉트");
            redirectAttributes.addFlashAttribute("errorMessage", "로그인이 필요합니다.");
            return "redirect:/auth/login";
        }
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            logger.warn("세션에 사용자 정보가 없습니다.");
            redirectAttributes.addFlashAttribute("errorMessage", "로그인이 필요합니다.");
            return "redirect:/auth/login";
        }

        try {
            boolean deleted = authService.deleteUser(loginUser.getId());

            if (deleted) {
                logger.info("회원 탈퇴 성공. username: {}, userId: {}", loginUser.getUsername(), loginUser.getId());
                session.invalidate();
                redirectAttributes.addFlashAttribute("successMessage", "회원 탈퇴가 완료되었습니다.");
                return "redirect:/auth/logout";
            } else {
                logger.warn("회원 탈퇴 실패. username: {}, userId: {}", loginUser.getUsername(), loginUser.getId());
                redirectAttributes.addFlashAttribute("errorMessage", "회원 탈퇴에 실패했습니다. 다시 시도해주세요.");
                return "redirect:/mypage";
            }
            
        } catch (Exception e) {
            logger.error("회원 탈퇴 중 예외 발생. username: {}, userId: {}", loginUser.getUsername(), loginUser.getId(), e);
            redirectAttributes.addFlashAttribute("errorMessage", 
                "회원 탈퇴 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/mypage";
        }
    }
}
