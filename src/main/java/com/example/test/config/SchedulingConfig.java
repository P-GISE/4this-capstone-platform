package com.example.test.config;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

import com.example.test.equipment.EquipmentDto;
import com.example.test.equipment.EquipmentService;
import com.example.test.equipmentrental.EquipmentRentalDto;
import com.example.test.equipmentrental.EquipmentRentalService;
import com.example.test.notification.NotificationService;

@Configuration
@EnableScheduling
public class SchedulingConfig {
    // 스케줄링 활성화를 위한 설정 클래스
    // UserStatusService의 @Scheduled 메소드가 작동하도록 함

    @Autowired
    private EquipmentRentalService equipmentRentalService;
    
    @Autowired
    private EquipmentService equipmentService;
    
    @Autowired
    private NotificationService notificationService;

    /**
     * 매일 오전 9시에 기자재 반납 기한 알림 발송
     */
    @Scheduled(cron = "0 0 9 * * *")
    public void sendEquipmentReturnReminders() {
        System.out.println("=== 기자재 반납 알림 스케줄러 시작 ===");
        
        try {
            // 현재 대여 중인 모든 기자재 조회
            List<EquipmentRentalDto> currentRentals = equipmentRentalService.getRentalList();
            LocalDate today = LocalDate.now();
            
            for (EquipmentRentalDto rental : currentRentals) {
                // 대여 중인 상태이고 예상 반납일이 있는 경우만 체크
                if ("APPROVED".equals(rental.getStatus()) && rental.getExpectedReturnDate() != null) {
                    LocalDate returnDate = rental.getExpectedReturnDate()
                        .toInstant()
                        .atZone(ZoneId.systemDefault())
                        .toLocalDate();
                    
                    long daysUntilReturn = java.time.temporal.ChronoUnit.DAYS.between(today, returnDate);
                    
                    // 반납 1일 전 알림
                    if (daysUntilReturn == 1) {
                        sendReturnReminder(rental, "내일까지 반납해주세요", "⏰");
                    }
                    // 반납 당일 알림  
                    else if (daysUntilReturn == 0) {
                        sendReturnReminder(rental, "오늘까지 반납해주세요", "🚨");
                    }
                    // 연체 알림
                    else if (daysUntilReturn < 0) {
                        long overdueDays = Math.abs(daysUntilReturn);
                        sendReturnReminder(rental, overdueDays + "일 연체되었습니다", "🔴");
                    }
                }
            }
            
            System.out.println("=== 기자재 반납 알림 스케줄러 완료 ===");
            
        } catch (Exception e) {
            System.err.println("기자재 반납 알림 스케줄러 오류: " + e.getMessage());
        }
    }
    
    private void sendReturnReminder(EquipmentRentalDto rental, String message, String icon) {
        try {
            EquipmentDto equipment = equipmentService.getEquipmentById(rental.getEquipmentId());
            if (equipment != null && rental.getUserId() != null) {
                notificationService.createNotification(
                    rental.getUserId(),
                    "EQUIPMENT_RETURN_REMINDER",
                    icon + " 기자재 반납 알림",
                    equipment.getName() + " " + rental.getRequestedQuantity() + "개 - " + message,
                    "/reservation/my"
                );
                System.out.println("반납 알림 발송: " + equipment.getName() + " -> 사용자 ID: " + rental.getUserId());
            }
        } catch (Exception e) {
            System.err.println("반납 알림 발송 실패: " + e.getMessage());
        }
    }
} 