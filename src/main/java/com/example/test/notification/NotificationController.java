package com.example.test.notification;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.example.test.auth.AuthDto;

@Controller
@RequestMapping("/notifications")
public class NotificationController {
    
    @Autowired
    private NotificationService notificationService;
    
    /**
     * 알림 목록 페이지
     */
    @GetMapping("")
    public String notificationPage(Model model, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        try {
            List<Notification> notifications = notificationService.getNotifications(loginUser.getId(), 50);
            int unreadCount = notificationService.getUnreadNotificationCount(loginUser.getId());
            
            model.addAttribute("notifications", notifications);
            model.addAttribute("unreadCount", unreadCount);
        } catch (Exception e) {
            model.addAttribute("error", "알림을 불러오는 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return "notification/list";
    }
    
    /**
     * 알림 목록 조회 API
     */
    @GetMapping("/list")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getNotifications(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.ok(response);
        }
        
        try {
            List<Notification> notifications = notificationService.getNotifications(loginUser.getId(), 20);
            int unreadCount = notificationService.getUnreadNotificationCount(loginUser.getId());
            
            response.put("success", true);
            response.put("notifications", notifications);
            response.put("unreadCount", unreadCount);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "알림 조회 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 알림을 읽음으로 표시
     */
    @PostMapping("/{notificationId}/read")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> markAsRead(@PathVariable Long notificationId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            notificationService.markAsRead(notificationId);
            response.put("success", true);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "알림 읽음 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 모든 알림을 읽음으로 표시
     */
    @PostMapping("/mark-all-read")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> markAllAsRead(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.ok(response);
        }
        
        try {
            notificationService.markAllAsRead(loginUser.getId());
            response.put("success", true);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "알림 읽음 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 읽지 않은 알림 개수 조회
     */
    @GetMapping("/unread-count")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getUnreadCount(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.ok(response);
        }
        
        try {
            int unreadCount = notificationService.getUnreadNotificationCount(loginUser.getId());
            response.put("success", true);
            response.put("unreadCount", unreadCount);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "알림 개수 조회 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
} 