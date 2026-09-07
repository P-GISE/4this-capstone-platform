package com.example.test.adminlog;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class AdminLogDao {

    @Autowired
    private SqlSessionTemplate sqlSession;

    private static final String NAMESPACE = "com.example.test.adminlog.mapper.AdminLogMapper";

    /**
     * 관리자 로그 삽입
     */
    public void insertLog(AdminLogDto log) {
        sqlSession.insert(NAMESPACE + ".insertLog", log);
    }

    /**
     * 전체 로그 수 조회
     */
    public int getTotalCount(String search, String actionType, String logLevel, String dateFrom, String dateTo) {
        Map<String, Object> params = new HashMap<>();
        params.put("search", search);
        params.put("actionType", actionType);
        params.put("logLevel", logLevel);
        params.put("dateFrom", dateFrom);
        params.put("dateTo", dateTo);
        return sqlSession.selectOne(NAMESPACE + ".getTotalCount", params);
    }

    /**
     * 페이징된 로그 목록 조회
     */
    public List<AdminLogDto> getPagedLogs(int offset, int limit, String search, String actionType, 
                                          String logLevel, String dateFrom, String dateTo, String sortBy) {
        Map<String, Object> params = new HashMap<>();
        params.put("offset", offset);
        params.put("limit", limit);
        params.put("search", search);
        params.put("actionType", actionType);
        params.put("logLevel", logLevel);
        params.put("dateFrom", dateFrom);
        params.put("dateTo", dateTo);
        params.put("sortBy", sortBy);
        return sqlSession.selectList(NAMESPACE + ".getPagedLogs", params);
    }

    /**
     * 로그 상세 조회
     */
    public AdminLogDto getLogById(Long id) {
        return sqlSession.selectOne(NAMESPACE + ".getLogById", id);
    }

    /**
     * 특정 관리자의 최근 로그 조회
     */
    public List<AdminLogDto> getRecentLogsByAdmin(Long adminId, int limit) {
        Map<String, Object> params = new HashMap<>();
        params.put("adminId", adminId);
        params.put("limit", limit);
        return sqlSession.selectList(NAMESPACE + ".getRecentLogsByAdmin", params);
    }

    /**
     * 액션 타입별 통계 조회
     */
    public List<Map<String, Object>> getActionTypeStats(String dateFrom, String dateTo) {
        Map<String, Object> params = new HashMap<>();
        params.put("dateFrom", dateFrom);
        params.put("dateTo", dateTo);
        return sqlSession.selectList(NAMESPACE + ".getActionTypeStats", params);
    }

    /**
     * 관리자별 활동 통계 조회
     */
    public List<Map<String, Object>> getAdminActivityStats(String dateFrom, String dateTo) {
        Map<String, Object> params = new HashMap<>();
        params.put("dateFrom", dateFrom);
        params.put("dateTo", dateTo);
        return sqlSession.selectList(NAMESPACE + ".getAdminActivityStats", params);
    }

    /**
     * 일별 로그 통계 조회
     */
    public List<Map<String, Object>> getDailyLogStats(String dateFrom, String dateTo) {
        Map<String, Object> params = new HashMap<>();
        params.put("dateFrom", dateFrom);
        params.put("dateTo", dateTo);
        return sqlSession.selectList(NAMESPACE + ".getDailyLogStats", params);
    }

    /**
     * 로그 레벨별 통계 조회
     */
    public List<Map<String, Object>> getLogLevelStats(String dateFrom, String dateTo) {
        Map<String, Object> params = new HashMap<>();
        params.put("dateFrom", dateFrom);
        params.put("dateTo", dateTo);
        return sqlSession.selectList(NAMESPACE + ".getLogLevelStats", params);
    }

    /**
     * 오래된 로그 삭제 (데이터 정리용)
     */
    public int deleteOldLogs(int retentionDays) {
        return sqlSession.delete(NAMESPACE + ".deleteOldLogs", retentionDays);
    }

    /**
     * 실패한 작업 로그 조회
     */
    public List<AdminLogDto> getFailedLogs(int offset, int limit, String dateFrom, String dateTo) {
        Map<String, Object> params = new HashMap<>();
        params.put("offset", offset);
        params.put("limit", limit);
        params.put("dateFrom", dateFrom);
        params.put("dateTo", dateTo);
        return sqlSession.selectList(NAMESPACE + ".getFailedLogs", params);
    }

    /**
     * 특정 대상에 대한 로그 조회
     */
    public List<AdminLogDto> getLogsByTarget(String targetTable, Long targetId) {
        Map<String, Object> params = new HashMap<>();
        params.put("targetTable", targetTable);
        params.put("targetId", targetId);
        return sqlSession.selectList(NAMESPACE + ".getLogsByTarget", params);
    }
} 