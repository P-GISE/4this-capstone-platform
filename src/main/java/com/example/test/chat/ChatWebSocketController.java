package com.example.test.chat;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Controller;

import com.example.test.auth.AuthDto;
import com.example.test.auth.AuthService;
import com.example.test.config.WebSocketEventListener;
import com.example.test.notification.NotificationService;

@Controller
public class ChatWebSocketController {

    private final SimpMessagingTemplate messagingTemplate;
    private final ChatService chatService;
    private final WebSocketEventListener webSocketEventListener;
    private final AuthService authService;
    private final NotificationService notificationService;

    @Autowired
    public ChatWebSocketController(
            SimpMessagingTemplate messagingTemplate,
            ChatService chatService,
            WebSocketEventListener webSocketEventListener,
            AuthService authService,
            NotificationService notificationService) {
        this.messagingTemplate = messagingTemplate;
        this.chatService = chatService;
        this.webSocketEventListener = webSocketEventListener;
        this.authService = authService;
        this.notificationService = notificationService;
    }

    @MessageMapping("/chat.join")
    public void handleJoin(@Payload ChatMessageDTO message, StompHeaderAccessor headerAccessor) {
        System.out.println("=== 입장 메시지 처리 시작 ===");
        System.out.println("RoomId: " + message.getRoomId());
        System.out.println("SenderId: " + message.getSenderId());
        
        // 세션 ID 가져오기
        String sessionId = headerAccessor.getSessionId();
        System.out.println("SessionId: " + sessionId);
        
        // 입장 메시지에서는 온라인 상태를 변경하지 않음 (로그인/로그아웃에서만 관리)
        // 세션-사용자 매핑만 추가
        webSocketEventListener.addSessionUserMapping(sessionId, message.getSenderId());
        
        message.setMessageType(MessageType.SYSTEM);
        message.setSendTime(LocalDateTime.now());
        
        // 사용자 정보 가져와서 senderName 설정
        String displayName = "사용자" + message.getSenderId();
        try {
            AuthDto user = authService.getUserById(message.getSenderId());
            if (user != null) {
                displayName = getUserDisplayName(user);
                message.setSenderName(displayName);
                
                // 참여자 목록에 추가 (이미 존재하지 않는 경우에만)
                try {
                    if (!chatService.isParticipantExists(message.getRoomId(), message.getSenderId())) {
                        ChatParticipantDTO participant = new ChatParticipantDTO();
                        participant.setRoomId(message.getRoomId());
                        participant.setUserId(message.getSenderId());
                        participant.setNickname(displayName);
                        participant.setIsAdmin(false);
                        participant.setJoinedAt(LocalDateTime.now());
                        
                        chatService.addParticipant(participant);
                        System.out.println("참여자 추가 완료: " + displayName);
                    } else {
                        System.out.println("이미 참여 중인 사용자: " + displayName);
                    }
                } catch (RuntimeException e) {
                    System.out.println("참여자 추가 실패: " + e.getMessage());
                }
            }
        } catch (RuntimeException e) {
            message.setSenderName(displayName);
            System.out.println("사용자 정보 조회 실패: " + e.getMessage());
        }

        // 메시지 저장
        try {
            chatService.saveMessage(message);
            System.out.println("입장 메시지 저장 완료");
        } catch (RuntimeException e) {
            System.out.println("메시지 저장 실패: " + e.getMessage());
        }
        
        // 채팅방 구독자들에게 메시지 전송
        try {
            messagingTemplate.convertAndSend("/topic/chat/" + message.getRoomId(), message);
            System.out.println("입장 메시지 브로드캐스트 완료");
        } catch (RuntimeException e) {
            System.out.println("메시지 브로드캐스트 실패: " + e.getMessage());
        }
        
        System.out.println("=== 입장 메시지 처리 완료 ===");
    }

    @MessageMapping("/chat.sendMessage")
    public void handleMessage(@Payload ChatMessageDTO message, StompHeaderAccessor headerAccessor) {
        System.out.println("=== WebSocket 메시지 처리 시작 ===");
        System.out.println("받은 메시지: " + message.getContent());
        System.out.println("파일 목록: " + (message.getFiles() != null ? message.getFiles().size() + "개" : "없음"));
        
        // 세션 ID 가져오기
        String sessionId = headerAccessor.getSessionId();
        
        // 메시지 전송에서는 온라인 상태를 변경하지 않음 (로그인/로그아웃에서만 관리)
        // 세션-사용자 매핑만 추가
        webSocketEventListener.addSessionUserMapping(sessionId, message.getSenderId());
        
        message.setMessageType(MessageType.TEXT);
        message.setSendTime(LocalDateTime.now());
        
        // 사용자 정보 가져와서 senderName 설정
        String senderDisplayName = "사용자" + message.getSenderId();
        try {
            AuthDto user = authService.getUserById(message.getSenderId());
            if (user != null) {
                senderDisplayName = getUserDisplayName(user);
                message.setSenderName(senderDisplayName);
            }
        } catch (RuntimeException e) {
            message.setSenderName(senderDisplayName);
        }
        
        // 메시지 저장
        chatService.saveMessage(message);
        
        // 채팅방의 다른 참여자들에게 알림 생성
        try {
            List<ChatParticipantDTO> participants = chatService.getParticipants(message.getRoomId());
            ChatDTO chatRoom = chatService.getChatRoom(message.getRoomId());
            
            for (ChatParticipantDTO participant : participants) {
                // 메시지 발송자는 제외
                if (!participant.getUserId().equals(message.getSenderId())) {
                    try {
                        String title = chatRoom != null ? chatRoom.getName() : "채팅방";
                        String notificationMessage = senderDisplayName + ": " + 
                            (message.getContent().length() > 50 ? 
                                message.getContent().substring(0, 50) + "..." : 
                                message.getContent());
                        String targetUrl = "/chat/room/" + message.getRoomId();
                        
                        notificationService.createNotification(participant.getUserId(), "CHAT", title, notificationMessage, targetUrl);
                        System.out.println("알림 생성 완료: 사용자 " + participant.getUserId());
                    } catch (RuntimeException e) {
                        System.out.println("알림 생성 실패: 사용자 " + participant.getUserId() + ", 오류: " + e.getMessage());
                    }
                }
            }
        } catch (RuntimeException e) {
            System.out.println("채팅 알림 생성 중 오류 발생: " + e.getMessage());
        }
        
        // 파일 정보가 있다면 실시간 메시지에 포함
        if (message.getFiles() != null && !message.getFiles().isEmpty()) {
            System.out.println("파일 정보를 실시간 메시지에 포함합니다.");
            // 이미 업로드된 파일 정보는 그대로 유지
        }
        
        System.out.println("실시간 브로드캐스트할 메시지: " + message);
        System.out.println("브로드캐스트할 파일 수: " + (message.getFiles() != null ? message.getFiles().size() : 0));
        
        // 채팅방 구독자들에게 메시지 전송
        messagingTemplate.convertAndSend("/topic/chat/" + message.getRoomId(), message);
        
        System.out.println("=== WebSocket 메시지 처리 완료 ===");
    }

    @MessageMapping("/chat.leave")
    public void handleLeave(@Payload ChatMessageDTO message, StompHeaderAccessor headerAccessor) {
        System.out.println("=== 퇴장 메시지 처리 시작 ===");
        System.out.println("받은 메시지: " + message);
        System.out.println("RoomId: " + message.getRoomId());
        System.out.println("SenderId: " + message.getSenderId());
        System.out.println("Content: " + message.getContent());
        
        // 세션 ID 가져오기
        String sessionId = headerAccessor.getSessionId();
        
        // 퇴장 메시지에서는 온라인 상태를 변경하지 않음 (WebSocket 연결 해제 이벤트에서만 관리)
        // 하지만 세션 매핑은 제거
        webSocketEventListener.removeSessionUserMapping(sessionId);
        
        message.setMessageType(MessageType.SYSTEM);
        message.setSendTime(LocalDateTime.now());
        
        // 사용자 정보 가져와서 senderName 설정
        try {
            AuthDto user = authService.getUserById(message.getSenderId());
            if (user != null) {
                String displayName = getUserDisplayName(user);
                message.setSenderName(displayName);
                System.out.println("사용자명 설정: " + displayName);
            }
        } catch (RuntimeException e) {
            message.setSenderName("사용자" + message.getSenderId());
            System.out.println("사용자 정보 조회 실패: " + e.getMessage());
        }
        
        // 메시지 저장
        try {
            chatService.saveMessage(message);
            System.out.println("퇴장 메시지 저장 완료");
        } catch (RuntimeException e) {
            System.out.println("메시지 저장 실패: " + e.getMessage());
        }
        
        // 채팅방 구독자들에게 메시지 전송
        try {
            messagingTemplate.convertAndSend("/topic/chat/" + message.getRoomId(), message);
            System.out.println("퇴장 메시지 브로드캐스트 완료");
        } catch (RuntimeException e) {
            System.out.println("메시지 브로드캐스트 실패: " + e.getMessage());
        }
        
        System.out.println("=== 퇴장 메시지 처리 완료 ===");
    }
    
    private String getUserDisplayName(AuthDto user) {
        if (user.getStudentProfile() != null && user.getStudentProfile().getStudentId() != null) {
            return user.getName() + "/" + user.getStudentProfile().getStudentId();
        }
        return user.getName();
    }
}
