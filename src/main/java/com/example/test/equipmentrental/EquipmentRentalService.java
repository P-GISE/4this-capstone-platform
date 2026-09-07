package com.example.test.equipmentrental;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.test.auth.AuthDto;
import com.example.test.auth.AuthService;
import com.example.test.equipment.EquipmentDto;
import com.example.test.equipment.EquipmentService;
import com.example.test.notification.NotificationService;

@Service
public class EquipmentRentalService {

    @Autowired
    private EquipmentRentalDao equipmentRentalDao;

    @Autowired
    private EquipmentService equipmentService; // 재고 차감용

    @Autowired
    private AuthService authService; // username으로 userId 조회용

    @Autowired
    private NotificationService notificationService;
    
    // ======================================
    // (A) 학생용 기능: 대여신청 생성
    // ======================================
    public int createRental(EquipmentRentalDto dto) {
        // 장비 정보 조회
        EquipmentDto equipment = equipmentService.getEquipmentById(dto.getEquipmentId());

        // 대여 가능 수량 초과 여부 검사
        if (dto.getRequestedQuantity() > equipment.getAvailableQuantity()) {
            throw new IllegalArgumentException("대여 가능한 수량을 초과했습니다.");
        }

        // 1인당 대여 제한 검사
        validateRentalLimit(dto.getUserId(), dto.getEquipmentId(), dto.getRequestedQuantity());

        // 👉 반드시 상태 설정 필요
        dto.setIsApproved(false);       // 관리자 승인 전 상태
        dto.setStatus("PENDING");       // 관리자 승인 대기 상태

        return equipmentRentalDao.insertRental(dto);
    }


    public void validateRentalLimit(Long userId, Long equipmentId, int requestedQuantity) {
        int currentlyRentedCount = equipmentRentalDao.countActiveRentalsByUserAndEquipment(userId, equipmentId);

        EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);

        if (equipment.getMaxRentalQuantity() != null &&
            (currentlyRentedCount + requestedQuantity) > equipment.getMaxRentalQuantity()) {
            throw new IllegalArgumentException("1인당 대여 제한 수량을 초과할 수 없습니다.");
        }
    }

    public List<EquipmentRentalDto> getRentalsByUser(Long userId) {
        return equipmentRentalDao.selectRentalsByUser(userId);
    }

    public List<EquipmentRentalDto> getPendingRentals() {
        return equipmentRentalDao.selectPendingRentals();
    }

    public int approveRental(Long rentalId, Long adminId) {
        EquipmentRentalDto existing = equipmentRentalDao.selectRentalById(rentalId);
        if (existing == null) {
            return 0;
        }

        EquipmentRentalDto dtoForApprove = new EquipmentRentalDto();
        dtoForApprove.setId(rentalId);
        dtoForApprove.setApprovedBy(adminId);
        dtoForApprove.setStatus("RENTED");
        int rows = equipmentRentalDao.approveRentalById(dtoForApprove);

        if (rows == 1) {
            Long equipmentId = existing.getEquipmentId();
            Integer requestedQty = existing.getRequestedQuantity();
            int qtyToSubtract = (requestedQty != null) ? requestedQty : 0;
            if (qtyToSubtract > 0) {
                equipmentService.decrementAvailableQuantity(equipmentId, qtyToSubtract);
            }
        }
        return rows;
    }

    public int rejectRental(Long rentalId, String rejectionReason, Long adminId) {
        EquipmentRentalDto existing = equipmentRentalDao.selectRentalById(rentalId);
        if (existing == null) {
            return 0;
        }

        EquipmentRentalDto dtoForReject = new EquipmentRentalDto();
        dtoForReject.setId(rentalId);
        dtoForReject.setApprovedBy(adminId);
        dtoForReject.setStatus("REJECTED");
        dtoForReject.setRejectionReason(rejectionReason);

        int rows = equipmentRentalDao.rejectRentalWithReason(dtoForReject);
        
        // 반려 알림 발송
        if (rows > 0) {
            try {
                EquipmentDto equipment = equipmentService.getEquipmentById(existing.getEquipmentId());
                if (existing.getUserId() != null && equipment != null) {
                    String reason = (rejectionReason != null && !rejectionReason.trim().isEmpty()) 
                        ? " (사유: " + rejectionReason + ")" 
                        : "";
                    
                    notificationService.createNotification(
                        existing.getUserId(),
                        "EQUIPMENT_REJECTED",
                        "❌ 기자재 대여신청이 반려되었습니다",
                        equipment.getName() + " " + existing.getRequestedQuantity() + "개 대여가 반려되었습니다" + reason,
                        "/reservation/my"
                    );
                    System.out.println("기자재 반려 알림 발송 완료 - 사용자 ID: " + existing.getUserId());
                }
            } catch (Exception e) {
                System.err.println("기자재 반려 알림 발송 실패: " + e.getMessage());
                // 알림 발송 실패해도 반려 처리는 성공으로 처리
            }
        }

        return rows;
    }


    public int processReturnOrStatusUpdate(EquipmentRentalDto rental) {
        return equipmentRentalDao.updateReturnById(rental);
    }

    public int updateRentalStatus(EquipmentRentalDto rental) {
        return equipmentRentalDao.updateRentalStatus(rental);
    }

    public int deleteRental(Long id) {
        return equipmentRentalDao.deleteRental(id);
    }

    public List<EquipmentRentalDto> getRentalList() {
        return equipmentRentalDao.selectRentalList();
    }

    public EquipmentRentalDto getRentalById(Long id) {
        return equipmentRentalDao.selectRentalById(id);
    }

    public int approveById(Long rentalId, Long adminId) {
        EquipmentRentalDto existing = equipmentRentalDao.selectRentalById(rentalId);
        if (existing == null) {
            return 0;
        }

        // ✅ 대여 가능 수량 초과 방지
        Long equipmentId = existing.getEquipmentId();
        Integer requestedQty = existing.getRequestedQuantity();
        EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);
        if (requestedQty > equipment.getAvailableQuantity()) {
            throw new IllegalArgumentException("대여 가능 수량을 초과하여 승인할 수 없습니다.");
        }

        // ✅ 1인당 대여 제한 수량 검증
        validateRentalLimit(existing.getUserId(), equipmentId, requestedQty);

        // 승인 처리
        EquipmentRentalDto toApprove = new EquipmentRentalDto();
        toApprove.setId(rentalId);
        toApprove.setApprovedBy(adminId);
        toApprove.setStatus("APPROVED");
        int rows = equipmentRentalDao.approveRentalById(toApprove);
        if (rows != 1) {
            return 0;
        }

        // 재고 차감
        int decResult = equipmentService.decrementAvailableQuantity(equipmentId, requestedQty);
        if (decResult != 1) {
            throw new RuntimeException(
                "재고 차감에 실패했습니다. equipmentId=" + equipmentId +
                ", requestedQuantity=" + requestedQty
            );
        }

        // 승인 알림 발송
        try {
            if (existing.getUserId() != null) {
                notificationService.createNotification(
                    existing.getUserId(),
                    "EQUIPMENT_APPROVED",
                    "✅ 기자재 대여신청이 승인되었습니다",
                    equipment.getName() + " " + requestedQty + "개 대여가 승인되었습니다",
                    "/reservation/my"
                );
                System.out.println("기자재 승인 알림 발송 완료 - 사용자 ID: " + existing.getUserId());
            }
        } catch (Exception e) {
            System.err.println("기자재 승인 알림 발송 실패: " + e.getMessage());
            // 알림 발송 실패해도 승인 처리는 성공으로 처리
        }

        return 1;
    }


    public int processReturn(Long rentalId) {
        EquipmentRentalDto rental = equipmentRentalDao.selectRentalById(rentalId);
        if (rental == null || rental.getReturnDate() != null) return 0;

        rental.setReturnDate(new Date());
        rental.setStatus("RETURNED");

        int result = equipmentRentalDao.updateReturnById(rental);

        if (result == 1) {
            equipmentService.incrementAvailableQuantity(
                rental.getEquipmentId(),
                rental.getRequestedQuantity()
            );
        }

        return result;
    }

    public EquipmentRentalDto getRentalByUserAndEquipment(Long userId, Long equipmentId) {
        return equipmentRentalDao.selectRentalByUserAndEquipment(userId, equipmentId);
    }

    public int countCurrentRentalsByUser(Long userId) {
        return equipmentRentalDao.countCurrentRentalsByUser(userId);
    }

    public int countOverdueRentalsByUser(Long userId) {
        return equipmentRentalDao.countOverdueRentalsByUser(userId);
    }

    public int countTotalRentalsByUser(Long userId) {
        return equipmentRentalDao.countTotalRentalsByUser(userId);
    }

    public List<EquipmentRentalDto> getCurrentRentalsByUser(Long userId) {
        List<EquipmentRentalDto> rentals = equipmentRentalDao.selectCurrentRentalsByUser(userId);

        for (EquipmentRentalDto dto : rentals) {
            if (dto.getExpectedReturnDate() != null) {
                LocalDate today = LocalDate.now();
                LocalDate expected = dto.getExpectedReturnDate()
                    .toInstant()
                    .atZone(ZoneId.systemDefault())
                    .toLocalDate();

                long days = ChronoUnit.DAYS.between(today, expected);
                dto.setRemainingDays((int) days);
            } else {
                dto.setRemainingDays(null);
            }
        }

        return rentals;
    }

    // ======================================
    // 프로젝트 기자재 관리용 메서드들 추가
    // ======================================
    
    /**
     * 프로젝트 멤버들의 현재 대여중인 기자재 목록 조회
     */
    public List<EquipmentRentalDto> getCurrentRentalsByProjectMembers(List<Long> memberIds) {
        if (memberIds == null || memberIds.isEmpty()) {
            return new ArrayList<>();
        }
        return equipmentRentalDao.selectCurrentRentalsByUsers(memberIds);
    }

    // ======================================
    // 마이페이지 활동 요약용 메서드들 추가
    // ======================================
    
    /**
     * username으로 현재 대여중인 기자재 수 조회
     */
    public int getCurrentRentalsCountByUsername(String username) {
        try {
            Long userId = getUserIdByUsername(username);
            if (userId == null) {
                return 0;
            }
            return equipmentRentalDao.countCurrentRentalsByUser(userId);
        } catch (Exception e) {
            // 오류 발생 시 0 반환
            return 0;
        }
    }
    
    /**
     * username으로 총 기자재 대여 횟수 조회 (반납완료 + 현재대여중)
     */
    public int getTotalRentalsCountByUsername(String username) {
        try {
            Long userId = getUserIdByUsername(username);
            if (userId == null) {
                return 0;
            }
            return equipmentRentalDao.countTotalRentalsByUser(userId);
        } catch (Exception e) {
            // 오류 발생 시 0 반환
            return 0;
        }
    }
    
    /**
     * username으로 연체중인 기자재 수 조회
     */
    public int getOverdueRentalsCountByUsername(String username) {
        try {
            Long userId = getUserIdByUsername(username);
            if (userId == null) {
                return 0;
            }
            return equipmentRentalDao.countOverdueRentalsByUser(userId);
        } catch (Exception e) {
            // 오류 발생 시 0 반환
            return 0;
        }
    }
    
    /**
     * username으로 userId 조회하는 헬퍼 메서드
     */
    private Long getUserIdByUsername(String username) {
        try {
            AuthDto user = authService.findByUsername(username);
            return user != null ? user.getId() : null;
        } catch (Exception e) {
            return null;
        }
    }
}