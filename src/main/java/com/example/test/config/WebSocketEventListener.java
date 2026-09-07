package com.example.test.config;

import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import com.example.test.chat.OnlineUserService;
import com.example.test.chat.UserStatusService;

@Component
public class WebSocketEventListener {

    @Autowired
    private OnlineUserService onlineUserService;
    
    @Autowired
    private UserStatusService userStatusService;
    
    @Autowired
    private SimpMessageSendingOperations messagingTemplate;
    
    // 세션 ID와 사용자 ID 매핑을 위한 맵
    private final ConcurrentHashMap<String, Long> sessionUserMap = new ConcurrentHashMap<>();

    @EventListener
    public void handleWebSocketConnectListener(SessionConnectedEvent event) {
        System.out.println("=== WebSocket 연결 이벤트 ===");
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();
        System.out.println("새로운 WebSocket 연결: sessionId=" + sessionId);
        
        // WebSocket 연결 시점에서는 사용자 ID를 알 수 없음
        // 실제 온라인 상태는 첫 번째 메시지 전송 시 설정됨
    }

    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        System.out.println("=== WebSocket 연결 해제 이벤트 ===");
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = headerAccessor.getSessionId();
        System.out.println("WebSocket 연결 해제: sessionId=" + sessionId);
        
        // 세션 ID로 사용자를 오프라인 상태로 설정 (메모리 기반)
        onlineUserService.setUserOfflineBySession(sessionId);
        
        // 세션-사용자 매핑에서도 제거
        Long userId = sessionUserMap.remove(sessionId);
        if (userId != null) {
            System.out.println("세션 매핑에서 사용자 제거: userId=" + userId + ", sessionId=" + sessionId);
            
            // 메모리 기반 오프라인 설정
            onlineUserService.setUserOffline(userId);
            
            // 데이터베이스 기반 오프라인 설정
            userStatusService.setUserOffline(userId);
        }
        
        // 모든 채팅방에 사용자 상태 변경 알림
        messagingTemplate.convertAndSend("/topic/user-status", "USER_OFFLINE");
    }
    
    // 세션과 사용자 ID 매핑 추가
    public void addSessionUserMapping(String sessionId, Long userId) {
        sessionUserMap.put(sessionId, userId);
        System.out.println("세션-사용자 매핑 추가: sessionId=" + sessionId + ", userId=" + userId);
    }
    
    // 세션과 사용자 ID 매핑 제거
    public void removeSessionUserMapping(String sessionId) {
        Long userId = sessionUserMap.remove(sessionId);
        if (userId != null) {
            System.out.println("세션-사용자 매핑 제거: sessionId=" + sessionId + ", userId=" + userId);
        }
    }
} 