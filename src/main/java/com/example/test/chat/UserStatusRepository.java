package com.example.test.chat;

import java.time.LocalDateTime;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserStatusRepository {
    
    // 사용자 상태 조회
    UserStatus findByUserId(Long userId);
    
    // 사용자 상태 저장/업데이트
    void upsert(UserStatus userStatus);
    
    // 하트비트 업데이트
    void updateHeartbeat(@Param("userId") Long userId, @Param("heartbeatTime") LocalDateTime heartbeatTime);
    
    // 상태 업데이트
    void updateStatus(@Param("userId") Long userId, @Param("status") String status, @Param("statusMessage") String statusMessage);
    
    // 마지막 접속 시간 업데이트
    void updateLastSeen(@Param("userId") Long userId, @Param("lastSeen") LocalDateTime lastSeen);
    
    // 오프라인 상태로 변경 (하트비트가 오래된 사용자들)
    void markOfflineByHeartbeat(@Param("timeoutMinutes") int timeoutMinutes);
    
    // 채팅방 참여자들의 상태 조회
    List<UserStatus> findByUserIds(@Param("userIds") List<Long> userIds);
    
    // 온라인 사용자 목록 조회
    List<UserStatus> findOnlineUsers();
    
    // 모든 사용자 상태 초기화 (관리자용)
    void resetAllStatus();
} 