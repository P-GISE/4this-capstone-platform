package com.example.test.auth;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;


@Controller
@RequestMapping("/admin")  // 모든 메서드는 /admin/** 경로를 처리
public class AdminController {

    @Autowired
    private AuthService authService;
    
    @Autowired
    private com.example.test.ai.AiService aiService;

    /**
     * 1) 전체 사용자 관리 페이지 (/admin/users)
     */
    @GetMapping("/users")
    public String showAllUsers(Model model, HttpSession session) {
        // 1-1) 세션에서 로그인한 사용자의 정보 꺼내기
        AuthDto currentUser = (AuthDto) session.getAttribute("loginUser");
        if (currentUser == null || !Objects.equals("ADMIN", currentUser.getRole())) {
            // ADMIN이 아니면 접근 금지 또는 로그인 페이지로 리다이렉트
            return "redirect:/auth/login";
        }

        // 1-2) 전체 사용자+프로필 정보 가져오기
        List<AuthDto> userList = authService.getAllUsersWithProfiles();
        System.out.println("=== 관리자 사용자 관리 디버깅 ===");
        System.out.println("조회된 사용자 수: " + (userList != null ? userList.size() : "null"));
        if (userList != null && !userList.isEmpty()) {
            System.out.println("첫 번째 사용자: " + userList.get(0).getName() + " (" + userList.get(0).getRole() + ")");
        }
        model.addAttribute("userList", userList);

        // 1-3) 사용자 통계 계산
        if (userList != null) {
            int totalUsers = userList.size();
            long activeUsers = userList.stream().filter(u -> {
                Object status = u.getStatus();
                if (status == null) return true;
                if (status instanceof Boolean) return (Boolean) status;
                return "ACTIVE".equals(String.valueOf(status));
            }).count();
            long studentCount = userList.stream().filter(u -> "STUDENT".equals(u.getRole())).count();
            long professorCount = userList.stream().filter(u -> "PROFESSOR".equals(u.getRole())).count();
            long staffCount = userList.stream().filter(u -> "STAFF".equals(u.getRole())).count();
            long assistantCount = userList.stream().filter(u -> "ASSISTANT".equals(u.getRole())).count();
            long adminCount = userList.stream().filter(u -> "ADMIN".equals(u.getRole())).count();

            // 통계 정보를 모델에 추가
            model.addAttribute("totalUsers", totalUsers);
            model.addAttribute("activeUsers", activeUsers);
            model.addAttribute("studentCount", studentCount);
            model.addAttribute("professorCount", professorCount);
            model.addAttribute("staffCount", staffCount);
            model.addAttribute("assistantCount", assistantCount);
            model.addAttribute("adminCount", adminCount);

            System.out.println("=== 사용자 통계 ===");
            System.out.println("전체: " + totalUsers + ", 활성: " + activeUsers + ", 학생: " + studentCount + ", 교수: " + professorCount);
        } else {
            // userList가 null인 경우 기본값 설정
            model.addAttribute("totalUsers", 0);
            model.addAttribute("activeUsers", 0);
            model.addAttribute("studentCount", 0);
            model.addAttribute("professorCount", 0);
            model.addAttribute("staffCount", 0);
            model.addAttribute("assistantCount", 0);
            model.addAttribute("adminCount", 0);
        }

        // 1-3) 현재 로그인한 관리자 정보도 뷰에 전달 (슈퍼어드민 여부 확인용)
        model.addAttribute("currentUser", currentUser);

        return "admin/users";
    }

    /**
     * 2) 사용자 정보 수정 페이지로 이동 (/admin/user/edit/{userId})
     */
    @GetMapping("/user/edit/{userId}")
    public String showEditPage(@PathVariable("userId") Long userId,
                               Model model,
                               HttpSession session) {
        System.out.println("=== 사용자 수정 페이지 접근 ===");
        System.out.println("요청된 userId: " + userId);
        
        AuthDto currentUser = (AuthDto) session.getAttribute("loginUser");
        System.out.println("현재 사용자: " + (currentUser != null ? currentUser.getName() + " (" + currentUser.getRole() + ")" : "null"));
        
        if (currentUser == null || !Objects.equals("ADMIN", currentUser.getRole())) {
            System.out.println("권한 없음 - 로그인 페이지로 리다이렉트");
            return "redirect:/auth/login";
        }

        // 2-1) userId로 AuthDto(기본 정보+프로필) 가져오기
        AuthDto user = authService.findById(userId); 
        System.out.println("조회된 사용자: " + (user != null ? user.getName() + " (ID: " + user.getId() + ")" : "null"));
        
        if (user == null) {
            System.out.println("사용자를 찾을 수 없음 - 사용자 목록으로 리다이렉트");
            return "redirect:/admin/users";
        }

        model.addAttribute("user", user);
        System.out.println("모델에 사용자 정보 추가 완료 - admin/user_edit 뷰로 이동");
        return "admin/user_edit"; // 수정 페이지 뷰 이름
    }

    /**
     * 3) 사용자 정보 수정 처리 (/admin/user/edit/{userId}, POST)
     */
    @PostMapping("/user/edit/{userId}")
    public String updateUser(@PathVariable("userId") Long userId,
                             AuthDto authDto,
                             HttpSession session) {
        AuthDto currentUser = (AuthDto) session.getAttribute("loginUser");
        if (currentUser == null || !Objects.equals("ADMIN", currentUser.getRole())) {
            return "redirect:/auth/login";
        }

        // 3-1) PathVariable로 받은 userId를 authDto에 설정
        authDto.setId(userId);
        
        // 3-2) 기본 users 테이블 업데이트 & 프로필 테이블 업데이트
        authService.updateUser(authDto);

        return "redirect:/admin/users";
    }

    /**
     * 4) 사용자 삭제 처리 (/admin/user/delete/{userId})
     */
    @GetMapping("/user/delete/{userId}")
    public String deleteUser(@PathVariable("userId") Long userId,
                             HttpSession session) {
        AuthDto currentUser = (AuthDto) session.getAttribute("loginUser");
        if (currentUser == null || !Objects.equals("ADMIN", currentUser.getRole())) {
            return "redirect:/auth/login";
        }

        authService.deleteUser(userId);
        return "redirect:/admin/users";
    }
    
    /**
     * 5) 사용자 상태 변경 처리 (AJAX)
     */
    @PostMapping("/user/status")
    @ResponseBody
    public Map<String, Object> changeUserStatus(@RequestBody Map<String, Object> request,
                                               HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto currentUser = (AuthDto) session.getAttribute("loginUser");
            if (currentUser == null || !Objects.equals("ADMIN", currentUser.getRole())) {
                response.put("success", false);
                response.put("message", "권한이 없습니다.");
                return response;
            }
            
            Long userId = Long.valueOf(request.get("userId").toString());
            String status = request.get("status").toString();
            
            // 사용자 상태 변경 로직 (AuthService에 메서드가 있다면 사용)
            // 현재는 간단히 성공 응답만 반환
            response.put("success", true);
            response.put("message", "상태가 변경되었습니다.");
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "상태 변경 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * 5) 서브 어드민 지정/해제 (/admin/users/subadmin, POST)
     */
    @PostMapping("/users/subadmin")
    public String changeSubAdmin(@RequestParam("userId") Long userId,
                                 @RequestParam("accessLevel") String accessLevel,
                                 HttpSession session) {
        AuthDto currentUser = (AuthDto) session.getAttribute("loginUser");
        if (currentUser == null || !Objects.equals("ADMIN", currentUser.getRole())) {
            return "redirect:/auth/login";
        }

        // // 5-1) 슈퍼어드민 여부 확인
        // AdminProfileDto myAdminProfile = currentUser.getAdminProfile();
        // if (myAdminProfile == null || !"SUPER".equals(myAdminProfile.getAccessLevel())) {
        //     // SUPER 어드민이 아니면 권한 없음
        //     throw new AccessDeniedException("슈퍼 어드민만 접근 가능합니다.");
        // }

        // 5-2) 지정/해제 로직
        authService.changeAdminAccessLevel(userId, accessLevel);

        return "redirect:/admin/users";
    }

    /**
     * 6) 사용자 정보 조회 (AJAX용 JSON 응답)
     */
    @GetMapping("/user/{userId}/json")
    @ResponseBody
    public ResponseEntity<AuthDto> getUserJson(@PathVariable("userId") Long userId,
                                              HttpSession session) {
        AuthDto currentUser = (AuthDto) session.getAttribute("loginUser");
        if (currentUser == null || !Objects.equals("ADMIN", currentUser.getRole())) {
            return ResponseEntity.status(401).build();
        }

        AuthDto user = authService.findById(userId);
        if (user == null) {
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(user);
    }

    /**
     * 7) 사용자 정보 수정 (AJAX용 JSON 응답)
     */
    @PostMapping("/user/{userId}/json")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateUserJson(@PathVariable("userId") Long userId,
                                                             @RequestBody AuthDto authDto,
                                                             HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto currentUser = (AuthDto) session.getAttribute("loginUser");
            if (currentUser == null || !Objects.equals("ADMIN", currentUser.getRole())) {
                response.put("success", false);
                response.put("message", "권한이 없습니다.");
                return ResponseEntity.status(401).body(response);
            }

            // PathVariable로 받은 userId를 authDto에 설정
            authDto.setId(userId);
            
            // 사용자 정보 업데이트
            boolean result = authService.updateUser(authDto);
            
            if (result) {
                response.put("success", true);
                response.put("message", "사용자 정보가 성공적으로 수정되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "사용자 정보 수정에 실패했습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
    
    /**
     * 관리자 - 사용자에게 크레딧 부여
     */
    @PostMapping("/grant-credits")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> grantCredits(
            @RequestParam Long userId,
            @RequestParam int credits,
            @RequestParam(required = false, defaultValue = "") String reason,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto admin = (AuthDto) session.getAttribute("loginUser");
            if (admin == null || !"ADMIN".equals(admin.getRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }
            
            // 크레딧 부여
            aiService.adminGrantCredits(userId, credits, reason.isEmpty() ? "관리자 부여" : reason);
            
            // 업데이트된 크레딧 정보 조회
            com.example.test.ai.UserAiCreditDto credit = aiService.getUserCredit(userId);
            
            response.put("success", true);
            response.put("message", credits + " 크레딧이 성공적으로 부여되었습니다.");
            response.put("remainingCredits", credit.getRemainingCredits());
            response.put("totalCredits", credit.getTotalCredits());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "크레딧 부여 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
    
    /**
     * 관리자 - 모든 사용자 크레딧 현황 조회
     */
    @GetMapping("/credits-overview")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getCreditsOverview(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto admin = (AuthDto) session.getAttribute("loginUser");
            if (admin == null || !"ADMIN".equals(admin.getRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }
            
            // 모든 사용자의 크레딧 정보 조회
            List<AuthDto> allUsers = authService.getAllUsersWithProfiles();
            List<Map<String, Object>> userCredits = new java.util.ArrayList<>();
            
            for (AuthDto user : allUsers) {
                try {
                    com.example.test.ai.UserAiCreditDto credit = aiService.getUserCredit(user.getId());
                    Map<String, Object> userCreditInfo = new HashMap<>();
                    userCreditInfo.put("userId", user.getId());
                    userCreditInfo.put("userName", user.getName());
                    userCreditInfo.put("username", user.getUsername());
                    userCreditInfo.put("role", user.getRole());
                    userCreditInfo.put("totalCredits", credit.getTotalCredits());
                    userCreditInfo.put("usedCredits", credit.getUsedCredits());
                    userCreditInfo.put("remainingCredits", credit.getRemainingCredits());
                    userCredits.add(userCreditInfo);
                } catch (Exception e) {
                    // 크레딧 정보가 없는 사용자는 스킵
                }
            }
            
            response.put("success", true);
            response.put("users", userCredits);
            response.put("totalUsers", userCredits.size());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "크레딧 현황 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }
}