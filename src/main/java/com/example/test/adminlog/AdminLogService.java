package com.example.test.adminlog;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class AdminLogService {
    
    private static final Logger logger = LoggerFactory.getLogger(AdminLogService.class);
    
    @Autowired
    private AdminLogDao adminLogDao;
    
    @Autowired
    private ObjectMapper objectMapper;

    /**
     * 관리자 로그 기록
     */
    public void logAdminAction(Long adminId, String actionType, String targetTable, Long targetId,
                               AdminLogDto.LogLevel logLevel, boolean isSuccessful, 
                               String description, HttpServletRequest request) {
        
        AdminLogDto log = new AdminLogDto();
        log.setAdminId(adminId);
        log.setActionType(actionType);
        log.setTargetTable(targetTable);
        log.setTargetId(targetId);
        log.setLogLevel(logLevel);
        log.setIsSuccessful(isSuccessful);
        log.setDescription(description);
        
        if (request != null) {
            log.setHttpMethod(request.getMethod());
            log.setRequestUri(request.getRequestURI());
            log.setIpAddress(getClientIpAddress(request));
            log.setUserAgent(request.getHeader("User-Agent"));
        }
        
        try {
            adminLogDao.insertLog(log);
        } catch (Exception e) {
            logger.error("관리자 로그 기록 실패: {}", e.getMessage(), e);
        }
    }

    /**
     * 관리자 로그 기록 (간단 버전)
     */
    public void logAdminAction(Long adminId, String actionType, String description) {
        logAdminAction(adminId, actionType, null, null, 
                      AdminLogDto.LogLevel.INFO, true, description, null);
    }

    /**
     * 데이터 변경 로그 기록 (변경 전/후 값 포함)
     */
    public void logDataChange(Long adminId, String actionType, String targetTable, Long targetId,
                              Object beforeValue, Object afterValue, String description, 
                              HttpServletRequest request) {
        
        AdminLogDto log = new AdminLogDto();
        log.setAdminId(adminId);
        log.setActionType(actionType);
        log.setTargetTable(targetTable);
        log.setTargetId(targetId);
        log.setLogLevel(AdminLogDto.LogLevel.INFO);
        log.setIsSuccessful(true);
        log.setDescription(description);
        
        try {
            if (beforeValue != null) {
                log.setBeforeValue(objectMapper.writeValueAsString(beforeValue));
            }
            if (afterValue != null) {
                log.setAfterValue(objectMapper.writeValueAsString(afterValue));
            }
        } catch (JsonProcessingException e) {
            logger.warn("JSON 변환 실패: {}", e.getMessage());
        }
        
        if (request != null) {
            log.setHttpMethod(request.getMethod());
            log.setRequestUri(request.getRequestURI());
            log.setIpAddress(getClientIpAddress(request));
            log.setUserAgent(request.getHeader("User-Agent"));
        }
        
        try {
            adminLogDao.insertLog(log);
        } catch (Exception e) {
            logger.error("관리자 로그 기록 실패: {}", e.getMessage(), e);
        }
    }

    /**
     * 로그인 로그 기록
     */
    public void logLogin(Long adminId, boolean isSuccessful, String description, HttpServletRequest request) {
        logAdminAction(adminId, AdminLogDto.ActionType.LOGIN, null, null,
                      isSuccessful ? AdminLogDto.LogLevel.INFO : AdminLogDto.LogLevel.WARN,
                      isSuccessful, description, request);
    }

    /**
     * 로그아웃 로그 기록
     */
    public void logLogout(Long adminId, HttpServletRequest request) {
        logAdminAction(adminId, AdminLogDto.ActionType.LOGOUT, null, null,
                      AdminLogDto.LogLevel.INFO, true, "관리자 로그아웃", request);
    }

    /**
     * 오류 로그 기록
     */
    public void logError(Long adminId, String actionType, String description, Exception exception, 
                         HttpServletRequest request) {
        String errorDescription = description;
        if (exception != null) {
            errorDescription += " - 오류: " + exception.getMessage();
        }
        
        logAdminAction(adminId, actionType, null, null,
                      AdminLogDto.LogLevel.ERROR, false, errorDescription, request);
    }

    /**
     * 전체 로그 수 조회
     */
    public int getTotalCount(String search, String actionType, String logLevel, String dateFrom, String dateTo) {
        return adminLogDao.getTotalCount(search, actionType, logLevel, dateFrom, dateTo);
    }

    /**
     * 페이징된 로그 목록 조회
     */
    public List<AdminLogDto> getPagedLogs(int offset, int limit, String search, String actionType,
                                          String logLevel, String dateFrom, String dateTo, String sortBy) {
        return adminLogDao.getPagedLogs(offset, limit, search, actionType, logLevel, dateFrom, dateTo, sortBy);
    }

    /**
     * 로그 상세 조회
     */
    public AdminLogDto getLogById(Long id) {
        return adminLogDao.getLogById(id);
    }

    /**
     * 특정 관리자의 최근 로그 조회
     */
    public List<AdminLogDto> getRecentLogsByAdmin(Long adminId, int limit) {
        return adminLogDao.getRecentLogsByAdmin(adminId, limit);
    }

    /**
     * 액션 타입별 통계 조회
     */
    public List<Map<String, Object>> getActionTypeStats(String dateFrom, String dateTo) {
        return adminLogDao.getActionTypeStats(dateFrom, dateTo);
    }

    /**
     * 관리자별 활동 통계 조회
     */
    public List<Map<String, Object>> getAdminActivityStats(String dateFrom, String dateTo) {
        return adminLogDao.getAdminActivityStats(dateFrom, dateTo);
    }

    /**
     * 일별 로그 통계 조회
     */
    public List<Map<String, Object>> getDailyLogStats(String dateFrom, String dateTo) {
        return adminLogDao.getDailyLogStats(dateFrom, dateTo);
    }

    /**
     * 로그 레벨별 통계 조회
     */
    public List<Map<String, Object>> getLogLevelStats(String dateFrom, String dateTo) {
        return adminLogDao.getLogLevelStats(dateFrom, dateTo);
    }

    /**
     * 실패한 작업 로그 조회
     */
    public List<AdminLogDto> getFailedLogs(int offset, int limit, String dateFrom, String dateTo) {
        return adminLogDao.getFailedLogs(offset, limit, dateFrom, dateTo);
    }

    /**
     * 특정 대상에 대한 로그 조회
     */
    public List<AdminLogDto> getLogsByTarget(String targetTable, Long targetId) {
        return adminLogDao.getLogsByTarget(targetTable, targetId);
    }

    /**
     * 오래된 로그 정리
     */
    public int cleanupOldLogs(int retentionDays) {
        try {
            int deletedCount = adminLogDao.deleteOldLogs(retentionDays);
            logger.info("오래된 로그 정리 완료: {} 개 삭제 (보관 기간: {} 일)", deletedCount, retentionDays);
            return deletedCount;
        } catch (Exception e) {
            logger.error("로그 정리 실패: {}", e.getMessage(), e);
            return 0;
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
        
        String xForwardedProto = request.getHeader("X-Forwarded-Proto");
        if (xForwardedProto != null && !xForwardedProto.isEmpty() && !"unknown".equalsIgnoreCase(xForwardedProto)) {
            return xForwardedProto;
        }
        
        return request.getRemoteAddr();
    }
} 