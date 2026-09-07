package com.example.test.specialrental;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.test.equipment.EquipmentDto;
import com.example.test.equipment.EquipmentService;
import com.example.test.equipmentrental.EquipmentRentalService;
import com.example.test.notification.NotificationService;

@Service
@Transactional
public class SpecialRentalService {

    private static final Logger logger = LoggerFactory.getLogger(SpecialRentalService.class);

    @Autowired
    private SpecialRentalRequestDao specialRentalRequestDao;
    
    @Autowired
    private EquipmentService equipmentService;
    
    @Autowired
    private EquipmentRentalService equipmentRentalService;
    
    @Autowired
    private NotificationService notificationService;
    
    /**
     * 새로운 특별 대여 신청 생성
     */
    public Long createSpecialRequest(SpecialRentalRequestDto dto) {
        // 1. 기본 검증
        validateSpecialRequest(dto);
        
        // 2. 현재 상황 정보 수집
        collectCurrentSituation(dto);
        
        // 3. 신청 생성
        dto.setStatus("PENDING");
        dto.setCreatedAt(LocalDateTime.now());
        dto.setUpdatedAt(LocalDateTime.now());
        
        int result = specialRentalRequestDao.insertSpecialRequest(dto);
        if (result != 1) {
            throw new RuntimeException("특별 대여 신청 생성에 실패했습니다.");
        }
        
        return dto.getId();
    }
    
    /**
     * 특별 대여 신청 승인
     */
    public void approveSpecialRequest(Long requestId, Long adminId, String approvalReason) {
        SpecialRentalRequestDto request = specialRentalRequestDao.selectSpecialRequestById(requestId);
        if (request == null) {
            throw new IllegalArgumentException("존재하지 않는 신청입니다.");
        }
        
        if (!"PENDING".equals(request.getStatus())) {
            throw new IllegalArgumentException("승인 대기 상태가 아닌 신청은 처리할 수 없습니다.");
        }
        
        // 승인 처리
        int result = specialRentalRequestDao.approveSpecialRequest(requestId, adminId, approvalReason);
        if (result != 1) {
            throw new RuntimeException("승인 처리에 실패했습니다.");
        }
        
        // 기자재 수량 차감 (승인된 수량만큼)
        try {
            equipmentService.decrementAvailableQuantity(request.getEquipmentId(), request.getRequestedQuantity());
            logger.info("기자재 수량 차감 완료: 기자재 ID={}, 차감 수량={}", request.getEquipmentId(), request.getRequestedQuantity());
        } catch (Exception e) {
            logger.warn("기자재 수량 차감 실패: 기자재 ID={}, 오류={}", request.getEquipmentId(), e.getMessage());
            // 수량 차감에 실패해도 승인은 유지 (이미 DB에 저장됨)
        }
        
        // 알림 발송
        sendApprovalNotification(request.getUserId(), request);
    }
    
    /**
     * 특별 대여 신청 반려
     */
    public void rejectSpecialRequest(Long requestId, Long adminId, String rejectionReason) {
        SpecialRentalRequestDto request = specialRentalRequestDao.selectSpecialRequestById(requestId);
        if (request == null) {
            throw new IllegalArgumentException("존재하지 않는 신청입니다.");
        }
        
        if (!"PENDING".equals(request.getStatus())) {
            throw new IllegalArgumentException("승인 대기 상태가 아닌 신청은 처리할 수 없습니다.");
        }
        
        // 반려 처리
        int result = specialRentalRequestDao.rejectSpecialRequest(requestId, adminId, rejectionReason);
        if (result != 1) {
            throw new RuntimeException("반려 처리에 실패했습니다.");
        }
        
        // 알림 발송
        sendRejectionNotification(request.getUserId(), request, rejectionReason);
    }
    
    /**
     * ID로 특별 신청 조회
     */
    public SpecialRentalRequestDto getSpecialRequestById(Long id) {
        return specialRentalRequestDao.selectSpecialRequestById(id);
    }
    
    /**
     * 관리자용 전체 특별 신청 목록 조회
     */
    public List<SpecialRentalRequestDto> getSpecialRequestsForAdmin(Map<String, Object> params) {
        return specialRentalRequestDao.selectAllSpecialRequests(params);
    }
    
    /**
     * 사용자별 특별 신청 목록 조회
     */
    public List<SpecialRentalRequestDto> getSpecialRequestsByUser(Long userId, Map<String, Object> params) {
        return specialRentalRequestDao.selectSpecialRequestsByUser(userId, params);
    }
    
    /**
     * 승인 대기중인 특별 신청 목록
     */
    public List<SpecialRentalRequestDto> getPendingSpecialRequests(Map<String, Object> params) {
        return specialRentalRequestDao.selectPendingSpecialRequests(params);
    }
    
    // 내부 헬퍼 메서드들
    private void validateSpecialRequest(SpecialRentalRequestDto dto) {
        if (dto.getUserId() == null) {
            throw new IllegalArgumentException("사용자 ID가 필요합니다.");
        }
        if (dto.getEquipmentId() == null) {
            throw new IllegalArgumentException("기자재 ID가 필요합니다.");
        }
        if (dto.getRequestedQuantity() == null || dto.getRequestedQuantity() <= 0) {
            throw new IllegalArgumentException("올바른 신청 수량을 입력해주세요.");
        }
        if (dto.getPurpose() == null || dto.getPurpose().trim().isEmpty()) {
            throw new IllegalArgumentException("사용 목적을 입력해주세요.");
        }
        if (dto.getSpecialReason() == null || dto.getSpecialReason().trim().isEmpty()) {
            throw new IllegalArgumentException("특별 신청 사유를 입력해주세요.");
        }
    }
    
    private void collectCurrentSituation(SpecialRentalRequestDto dto) {
        // 현재 상황 정보 수집 및 DTO에 설정
        EquipmentDto equipment = equipmentService.getEquipmentById(dto.getEquipmentId());
        if (equipment != null) {
            dto.setCurrentAvailableQuantity(equipment.getAvailableQuantity());
            logger.debug("기자재 현재 상황 조회: 기자재 ID={}, 사용가능={}, 최대대여={}", 
                        dto.getEquipmentId(), equipment.getAvailableQuantity(), equipment.getMaxRentalQuantity());
        } else {
            dto.setCurrentAvailableQuantity(0); // 기본값 설정
            logger.warn("기자재 정보를 찾을 수 없음: 기자재 ID={}", dto.getEquipmentId());
        }
        
        int currentUserRentalCount = equipmentRentalService.countCurrentRentalsByUser(dto.getUserId());
        dto.setCurrentUserRentalCount(currentUserRentalCount);
        logger.debug("사용자 현재 대여 수 조회: 사용자 ID={}, 대여 수={}", dto.getUserId(), currentUserRentalCount);
    }
    
    private void sendApprovalNotification(Long userId, SpecialRentalRequestDto request) {
        try {
            // 기자재 정보 조회
            EquipmentDto equipment = equipmentService.getEquipmentById(request.getEquipmentId());
            String equipmentName = (equipment != null) ? equipment.getName() : "기자재";
            
            String title = "✅ 특별 대여 신청 승인";
            String message = String.format("'%s' %d개에 대한 특별 대여 신청이 승인되었습니다. 이제 기자재를 대여할 수 있습니다.", 
                                          equipmentName, request.getRequestedQuantity());
            
            notificationService.createNotification(
                userId,
                "RENTAL_APPROVED",  // 타입 길이 단축
                title,
                message,
                "/reservation/my"
            );
            logger.info("승인 알림 발송 완료: 사용자 ID={}, 신청 ID={}", userId, request.getId());
        } catch (Exception e) {
            logger.error("승인 알림 발송 실패: 사용자 ID={}, 신청 ID={}, 오류={}", userId, request.getId(), e.getMessage(), e);
        }
    }
    
    private void sendRejectionNotification(Long userId, SpecialRentalRequestDto request, String reason) {
        try {
            // 기자재 정보 조회
            EquipmentDto equipment = equipmentService.getEquipmentById(request.getEquipmentId());
            String equipmentName = (equipment != null) ? equipment.getName() : "기자재";
            
            String title = "❌ 특별 대여 신청 반려";
            String message = String.format("'%s' %d개에 대한 특별 대여 신청이 반려되었습니다.\n반려 사유: %s", 
                                          equipmentName, request.getRequestedQuantity(), reason);
            
            notificationService.createNotification(
                userId,
                "RENTAL_REJECTED",  // 타입 길이 단축
                title,
                message,
                "/reservation/my"
            );
            logger.info("반려 알림 발송 완료: 사용자 ID={}, 신청 ID={}", userId, request.getId());
        } catch (Exception e) {
            logger.error("반려 알림 발송 실패: 사용자 ID={}, 신청 ID={}, 오류={}", userId, request.getId(), e.getMessage(), e);
        }
    }
} 