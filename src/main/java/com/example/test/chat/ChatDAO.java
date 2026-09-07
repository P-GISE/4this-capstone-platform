package com.example.test.chat;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

@Repository
@Mapper
public interface ChatDAO {
    boolean existsMainChatRoom(Long projectId);
    void createMainChatRoom(ChatDTO chat);
    
    List<ChatDTO> getChatRooms(Long projectId);
    ChatDTO getChatRoom(Long roomId);
    
    void saveChatMessage(ChatMessageDTO message);
    List<ChatMessageDTO> getChatMessages(Map<String, Object> params);
    List<ChatMessageDTO> getMessageReplies(Long messageId);
    void updateMessage(Map<String, Object> params);
    void deleteMessage(Map<String, Object> params);
    void togglePinMessage(Long messageId);
    
    void saveMessageFile(ChatMessageFileDTO file);
    List<ChatMessageFileDTO> getMessageFiles(Long messageId);
    List<ChatMessageFileDTO> getMessageFilesByMessageIds(List<Long> messageIds);
    ChatMessageFileDTO getMessageFileById(Long fileId);
    
    void markMessageAsRead(Map<String, Object> params);
    void updateLastReadMessage(Map<String, Object> params);
    int getUnreadMessageCount(Map<String, Object> params);
    
    // chat_reads 테이블을 활용한 새로운 읽음 상태 메서드들
    Map<String, Object> getMessageReadStatus(Long messageId);
    void markAllMessagesAsRead(Map<String, Object> params);
    List<Map<String, Object>> getMessageReaders(Long messageId);
    List<Map<String, Object>> getUsersWithUnreadMessages(Long roomId);
    
    void addChatParticipant(ChatParticipantDTO participant);
    List<ChatParticipantDTO> getChatParticipants(Long roomId);
    void updateNotificationSettings(Map<String, Object> params);
    
    // 채팅방 CRUD
    void createChatRoom(ChatDTO chat);
    void updateChatRoom(ChatDTO chat);
    void deleteChatRoom(Long roomId);
    
    // 검색
    List<ChatDTO> searchChatRooms(Map<String, Object> params);
    List<ChatMessageDTO> searchChatMessages(Map<String, Object> params);
    
    // 참여자 관리
    void leaveChatRoom(Map<String, Object> params);
    void rejoinChatRoom(Map<String, Object> params);

    // 채팅방 초대 관련
    void createInvitation(Map<String, Object> params);
    void updateInvitationStatus(Map<String, Object> params);
    List<Map<String, Object>> getPendingInvitations(Long userId);

    // 채팅방 권한 관리
    void setRoomPermission(Map<String, Object> params);
    List<String> getUserPermissions(Map<String, Object> params);

    // 메시지 검색
    List<ChatMessageDTO> searchMessages(Map<String, Object> params);

    // 채팅방 통계
    Map<String, Object> getRoomStatistics(Long roomId);
    List<Map<String, Object>> getUserActivityStats(Map<String, Object> params);
    List<Map<String, Object>> getMessageStats(Map<String, Object> params);

    // 채팅방 검색 및 필터링
    List<ChatDTO> searchRooms(Map<String, Object> params);

    // 채팅방 공유
    void createRoomShare(Map<String, Object> params);
    Map<String, Object> getRoomShare(String shareToken);
    void deleteRoomShare(Map<String, Object> params);

    // 채팅방 내보내기
    Map<String, Object> exportRoomData(Long roomId);
    List<Map<String, Object>> exportRoomMessages(Long roomId);
    List<Map<String, Object>> exportRoomParticipants(Long roomId);

    // 메시지 분석
    List<Map<String, Object>> analyzeMessagePatterns(Map<String, Object> params);
    List<Map<String, Object>> getUserMessageStats(Long roomId);

    // 활동 로그
    void logRoomActivity(Map<String, Object> params);
    List<Map<String, Object>> getRoomActivityLogs(Map<String, Object> params);

    // 채팅방 설정
    void createRoomSettings(Map<String, Object> params);
    void updateRoomSettings(Map<String, Object> params);
    Map<String, String> getRoomSettings(Long roomId);

    // 채팅방 템플릿
    void createRoomTemplate(Map<String, Object> params);
    List<Map<String, Object>> getRoomTemplates(String roomType);
    Map<String, Object> getRoomTemplate(Long templateId);
    void createRoomFromTemplate(Map<String, Object> params);

    // 메시지 필터링
    List<ChatMessageDTO> filterMessages(Map<String, Object> params);

    // 참여자 관리
    void updateParticipantRole(Map<String, Object> params);
    List<Map<String, Object>> getParticipantRoles(Long roomId);
    List<ChatParticipantDTO> getParticipantsByRole(Map<String, Object> params);

    // 알림 설정
    void updateNotificationPreferences(Map<String, Object> params);
    Map<String, Object> getNotificationPreferences(Map<String, Object> params);

    // 메시지 포맷팅
    void updateMessageFormat(Map<String, Object> params);
    List<Map<String, Object>> getMessageFormats(Map<String, Object> params);
    List<Map<String, Object>> getMessageFormatStats(Long roomId);

    // 공개 채팅방 목록 조회
    List<ChatDTO> findByIsPrivateFalse();

    // 알림 설정 조회
    Map<String, Object> getNotificationSettings(Map<String, Object> params);
    
    // 채팅방별 알림 설정 조회 (chat_participants 테이블에서)
    Map<String, Object> getRoomNotificationSettings(Map<String, Object> params);
    
    // 사용자 전체 알림 설정 저장
    void saveUserNotificationSettings(Map<String, Object> params);

    // 검색 메시지 개수 조회
    int getSearchMessageCount(Map<String, Object> params);
} 