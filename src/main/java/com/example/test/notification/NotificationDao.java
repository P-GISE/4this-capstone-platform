package com.example.test.notification;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

@Repository
@Mapper
public interface NotificationDao {
    void insertNotification(Notification notification);
    List<Notification> getNotificationsByUserId(Map<String, Object> params);
    int getUnreadNotificationCount(Long userId);
    void markNotificationAsRead(Long notificationId);
    void markAllNotificationsAsRead(Long userId);
    void deleteOldNotifications(int days);
    Notification getNotificationById(Long notificationId);
} 