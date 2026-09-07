package com.example.test.chat;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserStatusService {
    
    @Autowired
    private UserStatusRepository userStatusRepository;
    
    /**
     * 하트비트 업데이트 (사용자가 활성 상태임을 알림)
     */
    @Transactional
    public void updateHeartbeat(Long userId) {
        userStatusRepository.updateHeartbeat(userId, LocalDateTime.now());
    }
    
    /**
     * 사용자 상태 변경
     */
    @Transactional
    public void updateUserStatus(Long userId, String status, String statusMessage) {
        userStatusRepository.updateStatus(userId, status, statusMessage);
    }
    
    /**
     * 사용자 온라인 상태 설정
     */
    @Transactional
    public void setUserOnline(Long userId) {
        UserStatus userStatus = new UserStatus();
        userStatus.setUserId(userId);
        userStatus.setStatus(UserStatus.STATUS_ONLINE);
        userStatus.setLastSeen(LocalDateTime.now());
        userStatus.setLastHeartbeat(LocalDateTime.now());
        userStatus.setStatusUpdatedAt(LocalDateTime.now());
        userStatusRepository.upsert(userStatus);
    }
    
    /**
     * 사용자 오프라인 상태 설정
     */
    @Transactional
    public void setUserOffline(Long userId) {
        UserStatus userStatus = userStatusRepository.findByUserId(userId);
        if (userStatus == null) {
            userStatus = new UserStatus();
            userStatus.setUserId(userId);
        }
        userStatus.setStatus(UserStatus.STATUS_OFFLINE);
        userStatus.setLastSeen(LocalDateTime.now());
        userStatus.setStatusUpdatedAt(LocalDateTime.now());
        userStatusRepository.upsert(userStatus);
    }
    
    /**
     * 사용자 상태 조회
     */
    public UserStatus getUserStatus(Long userId) {
        UserStatus status = userStatusRepository.findByUserId(userId);
        if (status == null) {
            // 기본 상태 생성
            status = new UserStatus();
            status.setUserId(userId);
            status.setStatus(UserStatus.STATUS_OFFLINE);
            status.setLastSeen(LocalDateTime.now());
            status.setStatusUpdatedAt(LocalDateTime.now());
        }
        return status;
    }
    
    /**
     * 여러 사용자의 상태 조회
     */
    public Map<Long, UserStatus> getUserStatuses(List<Long> userIds) {
        List<UserStatus> statuses = userStatusRepository.findByUserIds(userIds);
        return statuses.stream()
                .collect(Collectors.toMap(UserStatus::getUserId, status -> status));
    }
    
    /**
     * 사용자가 온라인인지 확인
     */
    public boolean isUserOnline(Long userId) {
        UserStatus status = getUserStatus(userId);
        
        // OFFLINE 상태이거나 하트비트가 없으면 오프라인
        if (UserStatus.STATUS_OFFLINE.equals(status.getStatus()) || status.getLastHeartbeat() == null) {
            return false;
        }
        
        // 5분 이내에 하트비트가 있으면 온라인으로 간주
        LocalDateTime fiveMinutesAgo = LocalDateTime.now().minusMinutes(5);
        return status.getLastHeartbeat().isAfter(fiveMinutesAgo);
    }
    
    /**
     * 마지막 접속 시간을 사용자 친화적 문자열로 변환
     */
    public String getLastSeenText(UserStatus userStatus) {
        if (userStatus == null || userStatus.getLastSeen() == null) {
            return "접속 기록 없음";
        }
        
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime lastSeen = userStatus.getLastSeen();
        
        long minutes = ChronoUnit.MINUTES.between(lastSeen, now);
        long hours = ChronoUnit.HOURS.between(lastSeen, now);
        long days = ChronoUnit.DAYS.between(lastSeen, now);
        
        if (minutes < 1) {
            return "방금 전";
        } else if (minutes < 60) {
            return minutes + "분 전";
        } else if (hours < 24) {
            return hours + "시간 전";
        } else if (days < 7) {
            return days + "일 전";
        } else {
            return "오래 전";
        }
    }
    
    /**
     * 온라인 사용자 목록 조회
     */
    public List<UserStatus> getOnlineUsers() {
        return userStatusRepository.findOnlineUsers();
    }
    
    /**
     * 정기적으로 비활성 사용자를 오프라인으로 변경 (5분마다 실행)
     */
    @Scheduled(fixedRate = 300000) // 5분 = 300,000ms
    @Transactional
    public void markInactiveUsersOffline() {
        // 5분 이상 하트비트가 없는 사용자를 오프라인으로 변경
        userStatusRepository.markOfflineByHeartbeat(5);
    }
    
    /**
     * 상태 메시지 업데이트
     */
    @Transactional
    public void updateStatusMessage(Long userId, String statusMessage) {
        UserStatus currentStatus = getUserStatus(userId);
        userStatusRepository.updateStatus(userId, currentStatus.getStatus(), statusMessage);
    }
    
    /**
     * 모든 사용자 상태 초기화 (관리자용)
     */
    @Transactional
    public void resetAllUserStatus() {
        userStatusRepository.resetAllStatus();
    }
} 