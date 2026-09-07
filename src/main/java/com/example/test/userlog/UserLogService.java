package com.example.test.userlog;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * 사용자 접속 로그 서비스
 */
@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class UserLogService {

    private final UserLogDao userLogDao;

    /**
     * 로그인 성공 로그 기록
     */
    public void logLoginSuccess(Long userId, HttpServletRequest request) {
        try {
            UserLogDto userLog = UserLogDto.builder()
                    .userId(userId)
                    .loginType(UserLogDto.LOGIN)
                    .loginMethod(UserLogDto.WEB)
                    .sessionId(getSessionId(request))
                    .ipAddress(getClientIpAddress(request))
                    .userAgent(request.getHeader("User-Agent"))
                    .success(true)
                    .createdAt(LocalDateTime.now())
                    .build();

            userLogDao.insertLog(userLog);
            log.info("Login success logged for user: {}", userId);
        } catch (Exception e) {
            log.error("Failed to log login success for user: {}", userId, e);
        }
    }

    /**
     * 로그인 실패 로그 기록
     */
    public void logLoginFailure(String loginId, String failureReason, HttpServletRequest request) {
        try {
            UserLogDto userLog = UserLogDto.builder()
                    .userId(null) // 실패한 경우 userId는 null
                    .loginType(UserLogDto.FAILED)
                    .loginMethod(UserLogDto.WEB)
                    .sessionId(getSessionId(request))
                    .ipAddress(getClientIpAddress(request))
                    .userAgent(request.getHeader("User-Agent"))
                    .success(false)
                    .failureReason(failureReason + " (ID: " + loginId + ")")
                    .createdAt(LocalDateTime.now())
                    .build();

            userLogDao.insertLog(userLog);
            log.info("Login failure logged for loginId: {}", loginId);
        } catch (Exception e) {
            log.error("Failed to log login failure for loginId: {}", loginId, e);
        }
    }

    /**
     * 로그아웃 로그 기록
     */
    public void logLogout(Long userId, HttpServletRequest request) {
        try {
            UserLogDto userLog = UserLogDto.builder()
                    .userId(userId)
                    .loginType(UserLogDto.LOGOUT)
                    .loginMethod(UserLogDto.WEB)
                    .sessionId(getSessionId(request))
                    .ipAddress(getClientIpAddress(request))
                    .userAgent(request.getHeader("User-Agent"))
                    .success(true)
                    .createdAt(LocalDateTime.now())
                    .build();

            userLogDao.insertLog(userLog);
            log.info("Logout logged for user: {}", userId);
        } catch (Exception e) {
            log.error("Failed to log logout for user: {}", userId, e);
        }
    }

    /**
     * 페이징된 로그 목록 조회
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getPagedLogs(String search, String loginType, String userRole, 
                                           Boolean success, String dateFrom, String dateTo, 
                                           String sortBy, int page, int size) {
        int offset = (page - 1) * size;
        
        List<UserLogDto> logs = userLogDao.getPagedLogs(
            search, loginType, userRole, success, dateFrom, dateTo, sortBy, offset, size);
        
        int totalCount = userLogDao.getTotalCount(
            search, loginType, userRole, success, dateFrom, dateTo);
        
        int totalPages = (int) Math.ceil((double) totalCount / size);
        
        Map<String, Object> result = new HashMap<>();
        result.put("logs", logs);
        result.put("totalCount", totalCount);
        result.put("totalPages", totalPages);
        result.put("currentPage", page);
        result.put("size", size);
        result.put("hasNext", page < totalPages);
        result.put("hasPrevious", page > 1);
        
        return result;
    }

    /**
     * 로그 상세 조회
     */
    @Transactional(readOnly = true)
    public UserLogDto getLogById(Long id) {
        return userLogDao.getLogById(id);
    }

    /**
     * 특정 사용자의 최근 로그 조회
     */
    @Transactional(readOnly = true)
    public List<UserLogDto> getRecentLogsByUser(Long userId, int limit) {
        return userLogDao.getRecentLogsByUser(userId, limit);
    }

    /**
     * 통계 데이터 조회
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getStatistics(String dateFrom, String dateTo) {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("loginTypeStats", userLogDao.getLoginTypeStats(dateFrom, dateTo));
        stats.put("userRoleStats", userLogDao.getUserRoleStats(dateFrom, dateTo));
        stats.put("dailyAccessStats", userLogDao.getDailyAccessStats(dateFrom, dateTo));
        stats.put("hourlyAccessStats", userLogDao.getHourlyAccessStats(dateFrom, dateTo));
        stats.put("browserStats", userLogDao.getBrowserStats(dateFrom, dateTo));
        stats.put("ipStats", userLogDao.getIpStats(dateFrom, dateTo, 7));
        
        return stats;
    }

    /**
     * 실패한 로그인 시도 조회
     */
    @Transactional(readOnly = true)
    public List<UserLogDto> getFailedLogins(String dateFrom, String dateTo, int page, int size) {
        int offset = (page - 1) * size;
        return userLogDao.getFailedLogins(dateFrom, dateTo, offset, size);
    }

    /**
     * 활성 세션 조회
     */
    @Transactional(readOnly = true)
    public List<UserLogDto> getActiveSessions(int limit) {
        return userLogDao.getActiveSessions(limit);
    }

    /**
     * 보안 분석 데이터 조회
     */
    @Transactional(readOnly = true)
    public Map<String, Object> getSecurityAnalysis(String dateFrom, String dateTo) {
        Map<String, Object> analysis = new HashMap<>();
        
        analysis.put("duplicateIpAccess", userLogDao.getDuplicateIpAccess(dateFrom, dateTo, 5));
        analysis.put("failedLogins", userLogDao.getFailedLogins(dateFrom, dateTo, 0, 20));
        analysis.put("dailyUserAccessCount", userLogDao.getDailyUserAccessCount(dateFrom, dateTo));
        
        return analysis;
    }

    /**
     * 오래된 로그 정리
     */
    public int cleanupOldLogs(int retentionDays) {
        try {
            int deletedCount = userLogDao.deleteOldLogs(retentionDays);
            log.info("Deleted {} old user logs (retention: {} days)", deletedCount, retentionDays);
            return deletedCount;
        } catch (Exception e) {
            log.error("Failed to cleanup old user logs", e);
            throw new RuntimeException("로그 정리 중 오류가 발생했습니다.", e);
        }
    }

    /**
     * 클라이언트 IP 주소 추출
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty() && !"unknown".equalsIgnoreCase(xForwardedFor)) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty() && !"unknown".equalsIgnoreCase(xRealIp)) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }

    /**
     * 세션 ID 추출
     */
    private String getSessionId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session != null ? session.getId() : null;
    }
} 