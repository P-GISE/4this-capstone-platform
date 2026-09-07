package com.example.test.userlog;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * 사용자 접속 로그 데이터 접근 객체
 */
@Mapper
public interface UserLogDao {

    /**
     * 로그 삽입
     */
    void insertLog(UserLogDto userLog);

    /**
     * 전체 로그 수 조회 (검색 조건 포함)
     */
    int getTotalCount(@Param("search") String search,
                     @Param("loginType") String loginType,
                     @Param("userRole") String userRole,
                     @Param("success") Boolean success,
                     @Param("dateFrom") String dateFrom,
                     @Param("dateTo") String dateTo);

    /**
     * 페이징된 로그 목록 조회
     */
    List<UserLogDto> getPagedLogs(@Param("search") String search,
                                 @Param("loginType") String loginType,
                                 @Param("userRole") String userRole,
                                 @Param("success") Boolean success,
                                 @Param("dateFrom") String dateFrom,
                                 @Param("dateTo") String dateTo,
                                 @Param("sortBy") String sortBy,
                                 @Param("offset") int offset,
                                 @Param("limit") int limit);

    /**
     * 로그 상세 조회
     */
    UserLogDto getLogById(@Param("id") Long id);

    /**
     * 특정 사용자의 최근 로그 조회
     */
    List<UserLogDto> getRecentLogsByUser(@Param("userId") Long userId,
                                        @Param("limit") int limit);

    /**
     * 로그인 타입별 통계 조회
     */
    List<Map<String, Object>> getLoginTypeStats(@Param("dateFrom") String dateFrom,
                                               @Param("dateTo") String dateTo);

    /**
     * 사용자 역할별 접속 통계 조회
     */
    List<Map<String, Object>> getUserRoleStats(@Param("dateFrom") String dateFrom,
                                               @Param("dateTo") String dateTo);

    /**
     * 일별 접속 통계 조회
     */
    List<Map<String, Object>> getDailyAccessStats(@Param("dateFrom") String dateFrom,
                                                  @Param("dateTo") String dateTo);

    /**
     * 시간대별 접속 통계 조회
     */
    List<Map<String, Object>> getHourlyAccessStats(@Param("dateFrom") String dateFrom,
                                                   @Param("dateTo") String dateTo);

    /**
     * 브라우저별 접속 통계 조회
     */
    List<Map<String, Object>> getBrowserStats(@Param("dateFrom") String dateFrom,
                                             @Param("dateTo") String dateTo);

    /**
     * IP별 접속 통계 조회
     */
    List<Map<String, Object>> getIpStats(@Param("dateFrom") String dateFrom,
                                        @Param("dateTo") String dateTo,
                                        @Param("limit") int limit);

    /**
     * 실패한 로그인 시도 조회
     */
    List<UserLogDto> getFailedLogins(@Param("dateFrom") String dateFrom,
                                    @Param("dateTo") String dateTo,
                                    @Param("offset") int offset,
                                    @Param("limit") int limit);

    /**
     * 활성 세션 조회 (로그인했지만 로그아웃하지 않은 사용자)
     */
    List<UserLogDto> getActiveSessions(@Param("limit") int limit);

    /**
     * 특정 사용자의 세션 히스토리 조회
     */
    List<UserLogDto> getUserSessionHistory(@Param("userId") Long userId,
                                          @Param("offset") int offset,
                                          @Param("limit") int limit);

    /**
     * 오래된 로그 삭제
     */
    int deleteOldLogs(@Param("retentionDays") int retentionDays);

    /**
     * 중복 IP 접속 조회 (보안)
     */
    List<Map<String, Object>> getDuplicateIpAccess(@Param("dateFrom") String dateFrom,
                                                   @Param("dateTo") String dateTo,
                                                   @Param("minCount") int minCount);

    /**
     * 사용자별 일일 접속 횟수 조회
     */
    List<Map<String, Object>> getDailyUserAccessCount(@Param("dateFrom") String dateFrom,
                                                      @Param("dateTo") String dateTo);
} 