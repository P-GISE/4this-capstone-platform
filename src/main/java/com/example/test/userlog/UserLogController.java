package com.example.test.userlog;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * 사용자 접속 로그 컨트롤러
 */
@Controller
@RequestMapping("/admin/user-logs")
@RequiredArgsConstructor
@Slf4j
public class UserLogController {

    private final UserLogService userLogService;

    /**
     * 사용자 접속 로그 목록 페이지
     */
    @GetMapping("/list")
    public String list(@RequestParam(defaultValue = "1") int page,
                      @RequestParam(defaultValue = "20") int size,
                      @RequestParam(required = false) String search,
                      @RequestParam(required = false) String loginType,
                      @RequestParam(required = false) String userRole,
                      @RequestParam(required = false) Boolean success,
                      @RequestParam(required = false) String dateFrom,
                      @RequestParam(required = false) String dateTo,
                      @RequestParam(defaultValue = "newest") String sortBy,
                      Model model) {

        try {
            // 기본 날짜 설정 (최근 30일)
            if (dateFrom == null || dateFrom.isEmpty()) {
                dateFrom = LocalDate.now().minusDays(30).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            }
            if (dateTo == null || dateTo.isEmpty()) {
                dateTo = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            }

            Map<String, Object> result = userLogService.getPagedLogs(
                search, loginType, userRole, success, dateFrom, dateTo, sortBy, page, size);

            model.addAttribute("result", result);
            model.addAttribute("search", search);
            model.addAttribute("loginType", loginType);
            model.addAttribute("userRole", userRole);
            model.addAttribute("success", success);
            model.addAttribute("dateFrom", dateFrom);
            model.addAttribute("dateTo", dateTo);
            model.addAttribute("sortBy", sortBy);

            // 필터 옵션
            model.addAttribute("loginTypes", Arrays.asList(
                new String[]{"LOGIN", "LOGOUT", "FAILED"}
            ));
            model.addAttribute("userRoles", Arrays.asList(
                new String[]{"ADMIN", "STUDENT", "STAFF", "ASSISTANT", "PROFESSOR"}
            ));
            model.addAttribute("sortOptions", Arrays.asList(
                new String[][]{
                    {"newest", "최신순"},
                    {"oldest", "오래된순"},
                    {"login_type", "로그인 타입순"},
                    {"user_name", "사용자명순"},
                    {"ip_address", "IP 주소순"}
                }
            ));

            return "userlog/list";

        } catch (Exception e) {
            log.error("Error loading user logs list", e);
            model.addAttribute("error", "로그 목록을 불러오는 중 오류가 발생했습니다.");
            return "userlog/list";
        }
    }

    /**
     * 사용자 접속 로그 상세 페이지
     */
    @GetMapping("/detail/{id}")
    public String detail(@PathVariable Long id, Model model) {
        try {
            UserLogDto userLog = userLogService.getLogById(id);
            if (userLog == null) {
                model.addAttribute("error", "해당 로그를 찾을 수 없습니다.");
                return "userlog/detail";
            }

            model.addAttribute("log", userLog);

            // 해당 사용자의 최근 로그도 함께 조회
            if (userLog.getUserId() != null) {
                List<UserLogDto> recentLogs = userLogService.getRecentLogsByUser(userLog.getUserId(), 5);
                model.addAttribute("recentLogs", recentLogs);
            }

            return "userlog/detail";

        } catch (Exception e) {
            log.error("Error loading user log detail for id: {}", id, e);
            model.addAttribute("error", "로그 상세 정보를 불러오는 중 오류가 발생했습니다.");
            return "userlog/detail";
        }
    }

    /**
     * 사용자 접속 통계 페이지
     */
    @GetMapping("/stats")
    public String stats(@RequestParam(required = false) String dateFrom,
                       @RequestParam(required = false) String dateTo,
                       Model model) {

        try {
            // 기본 날짜 설정 (최근 30일)
            if (dateFrom == null || dateFrom.isEmpty()) {
                dateFrom = LocalDate.now().minusDays(30).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            }
            if (dateTo == null || dateTo.isEmpty()) {
                dateTo = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            }

            Map<String, Object> statistics = userLogService.getStatistics(dateFrom, dateTo);

            model.addAttribute("statistics", statistics);
            model.addAttribute("dateFrom", dateFrom);
            model.addAttribute("dateTo", dateTo);

            return "userlog/stats";

        } catch (Exception e) {
            log.error("Error loading user access statistics", e);
            model.addAttribute("error", "통계 데이터를 불러오는 중 오류가 발생했습니다.");
            return "userlog/stats";
        }
    }

    /**
     * 보안 분석 페이지
     */
    @GetMapping("/security")
    public String security(@RequestParam(required = false) String dateFrom,
                          @RequestParam(required = false) String dateTo,
                          Model model) {

        try {
            // 기본 날짜 설정 (최근 7일)
            if (dateFrom == null || dateFrom.isEmpty()) {
                dateFrom = LocalDate.now().minusDays(7).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            }
            if (dateTo == null || dateTo.isEmpty()) {
                dateTo = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            }

            Map<String, Object> securityAnalysis = userLogService.getSecurityAnalysis(dateFrom, dateTo);

            model.addAttribute("analysis", securityAnalysis);
            model.addAttribute("dateFrom", dateFrom);
            model.addAttribute("dateTo", dateTo);

            return "userlog/security";

        } catch (Exception e) {
            log.error("Error loading security analysis", e);
            model.addAttribute("error", "보안 분석 데이터를 불러오는 중 오류가 발생했습니다.");
            return "userlog/security";
        }
    }

    /**
     * 활성 세션 페이지
     */
    @GetMapping("/active-sessions")
    public String activeSessions(@RequestParam(defaultValue = "50") int limit, Model model) {
        try {
            List<UserLogDto> activeSessions = userLogService.getActiveSessions(limit);
            model.addAttribute("activeSessions", activeSessions);
            model.addAttribute("limit", limit);

            return "userlog/active-sessions";

        } catch (Exception e) {
            log.error("Error loading active sessions", e);
            model.addAttribute("error", "활성 세션을 불러오는 중 오류가 발생했습니다.");
            return "userlog/active-sessions";
        }
    }

    /**
     * 로그 정리 (AJAX)
     */
    @PostMapping("/cleanup")
    @ResponseBody
    public Map<String, Object> cleanup(@RequestParam int retentionDays) {
        try {
            int deletedCount = userLogService.cleanupOldLogs(retentionDays);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", deletedCount + "개의 오래된 로그가 삭제되었습니다.");
            result.put("deletedCount", deletedCount);
            return result;

        } catch (Exception e) {
            log.error("Error during log cleanup", e);
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "로그 정리 중 오류가 발생했습니다: " + e.getMessage());
            return result;
        }
    }

    /**
     * 통계 데이터 API (AJAX)
     */
    @GetMapping("/api/stats")
    @ResponseBody
    public Map<String, Object> getStatsApi(@RequestParam(required = false) String dateFrom,
                                          @RequestParam(required = false) String dateTo) {
        try {
            if (dateFrom == null || dateFrom.isEmpty()) {
                dateFrom = LocalDate.now().minusDays(30).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            }
            if (dateTo == null || dateTo.isEmpty()) {
                dateTo = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            }

            return userLogService.getStatistics(dateFrom, dateTo);

        } catch (Exception e) {
            log.error("Error loading statistics API", e);
            Map<String, Object> result = new HashMap<>();
            result.put("error", "통계 데이터를 불러오는 중 오류가 발생했습니다.");
            return result;
        }
    }

    /**
     * 실패한 로그인 시도 목록
     */
    @GetMapping("/failed-logins")
    public String failedLogins(@RequestParam(defaultValue = "1") int page,
                              @RequestParam(defaultValue = "20") int size,
                              @RequestParam(required = false) String dateFrom,
                              @RequestParam(required = false) String dateTo,
                              Model model) {

        try {
            // 기본 날짜 설정 (최근 7일)
            if (dateFrom == null || dateFrom.isEmpty()) {
                dateFrom = LocalDate.now().minusDays(7).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            }
            if (dateTo == null || dateTo.isEmpty()) {
                dateTo = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            }

            List<UserLogDto> failedLogins = userLogService.getFailedLogins(dateFrom, dateTo, page, size);

            model.addAttribute("failedLogins", failedLogins);
            model.addAttribute("dateFrom", dateFrom);
            model.addAttribute("dateTo", dateTo);
            model.addAttribute("currentPage", page);

            return "userlog/failed-logins";

        } catch (Exception e) {
            log.error("Error loading failed logins", e);
            model.addAttribute("error", "실패한 로그인 목록을 불러오는 중 오류가 발생했습니다.");
            return "userlog/failed-logins";
        }
    }
} 