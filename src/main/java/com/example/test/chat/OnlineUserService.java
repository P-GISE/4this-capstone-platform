package com.example.test.chat;

import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Service;

@Service
public class OnlineUserService {
    
    // 온라인 사용자 ID 저장 (Thread-safe)
    private final ConcurrentHashMap<Long, String> onlineUsers = new ConcurrentHashMap<>();
    
    // 사용자를 온라인 상태로 설정
    public void setUserOnline(Long userId, String sessionId) {
        onlineUsers.put(userId, sessionId);
        System.out.println("사용자 온라인 상태 설정: userId=" + userId + ", sessionId=" + sessionId);
    }
    
    // 사용자를 오프라인 상태로 설정
    public void setUserOffline(Long userId) {
        onlineUsers.remove(userId);
        System.out.println("사용자 오프라인 상태 설정: userId=" + userId);
    }
    
    // 세션 ID로 사용자를 오프라인 상태로 설정
    public void setUserOfflineBySession(String sessionId) {
        Long userIdToRemove = null;
        for (ConcurrentHashMap.Entry<Long, String> entry : onlineUsers.entrySet()) {
            if (sessionId.equals(entry.getValue())) {
                userIdToRemove = entry.getKey();
                break;
            }
        }
        if (userIdToRemove != null) {
            onlineUsers.remove(userIdToRemove);
            System.out.println("세션으로 사용자 오프라인 상태 설정: userId=" + userIdToRemove + ", sessionId=" + sessionId);
        }
    }
    
    // 사용자가 온라인인지 확인
    public boolean isUserOnline(Long userId) {
        return onlineUsers.containsKey(userId);
    }
    
    // 모든 온라인 사용자 ID 반환
    public Set<Long> getOnlineUserIds() {
        return new HashSet<>(onlineUsers.keySet());
    }
    
    // 온라인 사용자 수 반환
    public int getOnlineUserCount() {
        return onlineUsers.size();
    }
    
    // 모든 사용자를 오프라인 상태로 초기화 (서버 재시작 시 사용)
    public void clearAllOnlineUsers() {
        onlineUsers.clear();
        System.out.println("모든 온라인 사용자 상태 초기화 완료");
    }
    
    // 강제 초기화 및 특정 사용자만 온라인으로 설정
    public void forceResetWithUser(Long userId, String sessionId) {
        onlineUsers.clear();
        onlineUsers.put(userId, sessionId);
        System.out.println("강제 초기화 후 사용자 " + userId + "만 온라인으로 설정");
    }
} 