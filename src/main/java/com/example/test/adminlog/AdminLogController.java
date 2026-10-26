package com.example.test.adminlog;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.test.auth.AuthDto;

@Controller
@RequestMapping("/admin/logs")
public class AdminLogController {

    private static final Logger logger = LoggerFactory.getLogger(AdminLogController.class);

    @Autowired
    private AdminLogService adminLogService;

    /**
     * 관리자 로그 목록 페이지
     */
    @GetMapping("/list")
    public String listLogs(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "20") int size,
            @RequestParam(value = "search", required = false) String search,
            @RequestParam(value = "actionType", required = false) String actionType,
            @RequestParam(value = "logLevel", required = false) String logLevel,
            @RequestParam(value = "dateFrom", required = false) String dateFrom,
            @RequestParam(value = "dateTo", required = false) String dateTo,
            @RequestParam(value = "sortBy", defaultValue = "latest") String sortBy,
            HttpSession session,
            Model model) {

        // 관리자 권한 체크
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null || !"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/access-denied";
        }

        // 기본 날짜 설정 (최근 30일)
        if (dateFrom == null || dateFrom.isEmpty()) {
            dateFrom = LocalDate.now().minusDays(30).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        }
        if (dateTo == null || dateTo.isEmpty()) {
            dateTo = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        }

        // 페이징 계산
        int offset = (page - 1) * size;
        if (offset < 0) offset = 0;

        // 데이터 조회
        int totalCount = adminLogService.getTotalCount(search, actionType, logLevel, dateFrom, dateTo);
        int totalPages = (int) Math.ceil((double) totalCount / size);
        List<AdminLogDto> logs = adminLogService.getPagedLogs(offset, size, search, actionType, logLevel, dateFrom, dateTo, sortBy);

        // 페이지네이션 정보
        int startPage = Math.max(1, page - 2);
        int endPage = Math.min(totalPages, page + 2);

        // 모델에 데이터 추가
        model.addAttribute("logs", logs);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("pageSize", size);
        model.addAttribute("startPage", startPage);
        model.addAttribute("endPage", endPage);

        // 검색 조건 유지
        model.addAttribute("search", search);
        model.addAttribute("actionType", actionType);
        model.addAttribute("logLevel", logLevel);
        model.addAttribute("dateFrom", dateFrom);
        model.addAttribute("dateTo", dateTo);
        model.addAttribute("sortBy", sortBy);

        // 액션 타입 옵션
        model.addAttribute("actionTypes", getActionTypeOptions());
        model.addAttribute("logLevels", getLogLevelOptions());

        return "adminlog/list";
    }

    /**
     * 로그 상세 보기
     */
    @GetMapping("/detail/{id}")
    public String detailLog(@PathVariable Long id, HttpSession session, Model model) {
        // 관리자 권한 체크
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null || !"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/access-denied";
        }

        AdminLogDto log = adminLogService.getLogById(id);
        if (log == null) {
            return "redirect:/admin/logs/list?error=not_found";
        }

        model.addAttribute("log", log);
        return "adminlog/detail";
    }

    /**
     * 통계 대시보드
     */
    @GetMapping("/stats")
    public String statsPage(
            @RequestParam(value = "dateFrom", required = false) String dateFrom,
            @RequestParam(value = "dateTo", required = false) String dateTo,
            HttpSession session,
            Model model) {

        // 관리자 권한 체크
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null || !"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/access-denied";
        }

        // 기본 날짜 설정 (최근 30일)
        if (dateFrom == null || dateFrom.isEmpty()) {
            dateFrom = LocalDate.now().minusDays(30).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        }
        if (dateTo == null || dateTo.isEmpty()) {
            dateTo = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        }

        // 통계 데이터 조회
        List<Map<String, Object>> actionTypeStats = adminLogService.getActionTypeStats(dateFrom, dateTo);
        List<Map<String, Object>> adminActivityStats = adminLogService.getAdminActivityStats(dateFrom, dateTo);
        List<Map<String, Object>> dailyLogStats = adminLogService.getDailyLogStats(dateFrom, dateTo);
        List<Map<String, Object>> logLevelStats = adminLogService.getLogLevelStats(dateFrom, dateTo);

        model.addAttribute("actionTypeStats", actionTypeStats);
        model.addAttribute("adminActivityStats", adminActivityStats);
        model.addAttribute("dailyLogStats", dailyLogStats);
        model.addAttribute("logLevelStats", logLevelStats);
        model.addAttribute("dateFrom", dateFrom);
        model.addAttribute("dateTo", dateTo);

        return "adminlog/stats";
    }

    /**
     * 실패한 작업 로그 조회
     */
    @GetMapping("/failures")
    public String failureLogs(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "20") int size,
            @RequestParam(value = "dateFrom", required = false) String dateFrom,
            @RequestParam(value = "dateTo", required = false) String dateTo,
            HttpSession session,
            Model model) {

        // 관리자 권한 체크
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null || !"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/access-denied";
        }

        // 기본 날짜 설정 (최근 7일)
        if (dateFrom == null || dateFrom.isEmpty()) {
            dateFrom = LocalDate.now().minusDays(7).format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        }
        if (dateTo == null || dateTo.isEmpty()) {
            dateTo = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        }

        int offset = (page - 1) * size;
        if (offset < 0) offset = 0;

        List<AdminLogDto> failedLogs = adminLogService.getFailedLogs(offset, size, dateFrom, dateTo);

        model.addAttribute("logs", failedLogs);
        model.addAttribute("dateFrom", dateFrom);
        model.addAttribute("dateTo", dateTo);

        return "adminlog/failures";
    }

    /**
     * 내 활동 로그 조회 (현재 로그인한 관리자)
     */
    @GetMapping("/my-activity")
    public String myActivity(
            @RequestParam(value = "limit", defaultValue = "50") int limit,
            HttpSession session,
            Model model) {

        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null || !"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/access-denied";
        }

        List<AdminLogDto> myLogs = adminLogService.getRecentLogsByAdmin(loginUser.getId(), limit);
        model.addAttribute("logs", myLogs);
        model.addAttribute("limit", limit);

        return "adminlog/my-activity";
    }

    /**
     * 특정 대상에 대한 로그 조회 (AJAX)
     */
    @GetMapping("/api/target-logs")
    @ResponseBody
    public ResponseEntity<List<AdminLogDto>> getTargetLogs(
            @RequestParam String targetTable,
            @RequestParam Long targetId,
            HttpSession session) {

        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null || !"ADMIN".equals(loginUser.getRole())) {
            return ResponseEntity.status(403).build();
        }

        List<AdminLogDto> logs = adminLogService.getLogsByTarget(targetTable, targetId);
        return ResponseEntity.ok(logs);
    }

    /**
     * 로그 정리 실행 (AJAX)
     */
    @PostMapping("/api/cleanup")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> cleanupLogs(
            @RequestParam(value = "retentionDays", defaultValue = "90") int retentionDays,
            HttpSession session,
            HttpServletRequest request) {

        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null || !"ADMIN".equals(loginUser.getRole())) {
            return ResponseEntity.status(403).build();
        }

        Map<String, Object> result = new HashMap<>();
        try {
            int deletedCount = adminLogService.cleanupOldLogs(retentionDays);
            
            // 로그 정리 활동을 기록
            adminLogService.logAdminAction(
                loginUser.getId(),
                AdminLogDto.ActionType.SYSTEM_CONFIG,
                AdminLogDto.TargetTable.USERS, // 시스템 관리 테이블
                null,
                AdminLogDto.LogLevel.INFO,
                true,
                "로그 정리 실행 - " + deletedCount + "개 삭제 (보관기간: " + retentionDays + "일)",
                request
            );

            result.put("success", true);
            result.put("deletedCount", deletedCount);
            result.put("message", deletedCount + "개의 오래된 로그가 삭제되었습니다.");
        } catch (Exception e) {
            logger.error("로그 정리 실패", e);
            
            // 실패 로그 기록
            adminLogService.logError(
                loginUser.getId(),
                AdminLogDto.ActionType.SYSTEM_CONFIG,
                "로그 정리 실패",
                e,
                request
            );

            result.put("success", false);
            result.put("message", "로그 정리 중 오류가 발생했습니다: " + e.getMessage());
        }

        return ResponseEntity.ok(result);
    }

    /**
     * 액션 타입 옵션 반환
     */
    private Map<String, String> getActionTypeOptions() {
        Map<String, String> options = new HashMap<>();
        options.put(AdminLogDto.ActionType.CREATE_USER, "사용자 생성");
        options.put(AdminLogDto.ActionType.UPDATE_USER, "사용자 수정");
        options.put(AdminLogDto.ActionType.DELETE_USER, "사용자 삭제");
        options.put(AdminLogDto.ActionType.CREATE_EQUIPMENT, "기자재 등록");
        options.put(AdminLogDto.ActionType.UPDATE_EQUIPMENT, "기자재 수정");
        options.put(AdminLogDto.ActionType.DELETE_EQUIPMENT, "기자재 삭제");
        options.put(AdminLogDto.ActionType.CREATE_NOTICE, "공지사항 작성");
        options.put(AdminLogDto.ActionType.UPDATE_NOTICE, "공지사항 수정");
        options.put(AdminLogDto.ActionType.DELETE_NOTICE, "공지사항 삭제");
        options.put(AdminLogDto.ActionType.APPROVE_RENTAL, "대여 승인");
        options.put(AdminLogDto.ActionType.REJECT_RENTAL, "대여 거절");
        options.put(AdminLogDto.ActionType.APPROVE_REPAIR, "수리 승인");
        options.put(AdminLogDto.ActionType.REJECT_REPAIR, "수리 거절");
        options.put(AdminLogDto.ActionType.ANSWER_INQUIRY, "문의 답변");
        options.put(AdminLogDto.ActionType.LOGIN, "로그인");
        options.put(AdminLogDto.ActionType.LOGOUT, "로그아웃");
        options.put(AdminLogDto.ActionType.SYSTEM_CONFIG, "시스템 설정");
        return options;
    }

    /**
     * 로그 레벨 옵션 반환
     */
    private Map<String, String> getLogLevelOptions() {
        Map<String, String> options = new HashMap<>();
        options.put("INFO", "정보");
        options.put("WARN", "경고");
        options.put("ERROR", "오류");
        options.put("CRITICAL", "치명적");
        return options;
    }
} 