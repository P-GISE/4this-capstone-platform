package com.example.test.notification;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class NotificationService {
    
    @Autowired
    private NotificationDao notificationDao;
    
    /**
     * 알림 생성
     */
    @Transactional
    public void createNotification(Long userId, String type, String title, String message, String targetUrl) {
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setType(type);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setTargetUrl(targetUrl);
        notification.setIsRead(false);
        notification.setCreatedAt(LocalDateTime.now());
        
        notificationDao.insertNotification(notification);
    }
    
    /**
     * 사용자의 알림 목록 조회
     */
    public List<Notification> getNotifications(Long userId, int limit) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("limit", limit);
        return notificationDao.getNotificationsByUserId(params);
    }
    
    /**
     * 읽지 않은 알림 개수 조회
     */
    public int getUnreadNotificationCount(Long userId) {
        return notificationDao.getUnreadNotificationCount(userId);
    }
    
    /**
     * 알림을 읽음으로 표시
     */
    @Transactional
    public void markAsRead(Long notificationId) {
        notificationDao.markNotificationAsRead(notificationId);
    }
    
    /**
     * 모든 알림을 읽음으로 표시
     */
    @Transactional
    public void markAllAsRead(Long userId) {
        notificationDao.markAllNotificationsAsRead(userId);
    }
    
    /**
     * 채팅 알림 생성
     */
    @Transactional
    public void createChatNotification(Long userId, String senderName, String message, Long roomId) {
        String title = senderName + "님이 메시지를 보냈습니다";
        String targetUrl = "/chat/room/" + roomId;
        createNotification(userId, Notification.TYPE_CHAT, title, message, targetUrl);
    }
    
    /**
     * 공지사항 알림 생성
     */
    @Transactional
    public void createNoticeNotification(Long userId, String noticeTitle, Long noticeId) {
        String title = "새로운 공지사항이 등록되었습니다";
        String message = noticeTitle;
        String targetUrl = "/notice/view/" + noticeId;
        createNotification(userId, Notification.TYPE_NOTICE, title, message, targetUrl);
    }
    
    /**
     * 문의사항 알림 생성
     */
    @Transactional
    public void createInquiryNotification(Long userId, String inquiryTitle, Long inquiryId) {
        String title = "문의사항에 답변이 등록되었습니다";
        String message = inquiryTitle;
        String targetUrl = "/inquiry/view/" + inquiryId;
        createNotification(userId, Notification.TYPE_INQUIRY, title, message, targetUrl);
    }
    
    /**
     * 기자재 알림 생성
     */
    @Transactional
    public void createEquipmentNotification(Long userId, String equipmentName, String action, Long equipmentId) {
        String title = "기자재 " + action + " 알림";
        String message = equipmentName + " " + action + " 처리되었습니다";
        String targetUrl = "/equipment/detail/" + equipmentId;
        createNotification(userId, Notification.TYPE_EQUIPMENT, title, message, targetUrl);
    }
    
    /**
     * 프로젝트 초대 알림 생성
     */
    @Transactional
    public void createProjectInvitationNotification(Long inviterId, Long inviteeId, Long projectId, String projectTitle) {
        String title = "프로젝트 팀원 초대";
        String message = "'" + projectTitle + "' 프로젝트에 팀원으로 초대되었습니다.";
        String targetUrl = "/projects/invitation/" + projectId;
        createNotification(inviteeId, Notification.TYPE_PROJECT, title, message, targetUrl);
    }
    
    /**
     * 오래된 알림 삭제 (30일 이상)
     */
    @Transactional
    public void deleteOldNotifications() {
        notificationDao.deleteOldNotifications(30);
    }
} 