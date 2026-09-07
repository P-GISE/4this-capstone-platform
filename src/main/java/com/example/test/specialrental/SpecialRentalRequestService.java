package com.example.test.specialrental;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.example.test.equipment.EquipmentDto;
import com.example.test.equipment.EquipmentService;
import com.example.test.equipmentrental.EquipmentRentalDto;
import com.example.test.equipmentrental.EquipmentRentalService;
import com.example.test.notification.NotificationService;

@Service
@Transactional
public class SpecialRentalRequestService {

    @Autowired
    private SpecialRentalRequestDao specialRentalRequestDao;
    
    @Autowired
    private EquipmentService equipmentService;
    
    @Autowired
    private EquipmentRentalService equipmentRentalService;
    

    
    @Autowired
    private NotificationService notificationService;
    
    private static final String UPLOAD_DIR = "C:/uploads/special-rentals";
    private static final int MAX_SPECIAL_REQUESTS_PER_USER = 5; // 사용자당 최대 동시 특별 신청 수
    
    // ================================
    // 특별 대여 신청 생성
    // ================================
    
    /**
     * 새로운 특별 대여 신청 생성
     */
    public Long createSpecialRequest(SpecialRentalRequestDto dto, List<MultipartFile> attachments) throws IOException {
        // 1. 기본 검증
        validateSpecialRequest(dto);
        
        // 2. 현재 상황 정보 수집
        collectCurrentSituation(dto);
        
        // 3. 신청 생성
        dto.setStatus("PENDING");
        dto.setCreatedAt(LocalDateTime.now());
        dto.setUpdatedAt(LocalDateTime.now());
        
        // 우선순위 점수 계산
        dto.setPriorityScore(calculatePriorityScore(dto));
        
        int result = specialRentalRequestDao.insertSpecialRequest(dto);
        if (result != 1) {
            throw new RuntimeException("특별 대여 신청 생성에 실패했습니다.");
        }
        
        // 4. 첨부파일 처리
        if (attachments != null && !attachments.isEmpty()) {
            handleAttachments(dto.getId(), attachments);
        }
        
        // 5. 처리 로그 기록
        logAction(dto.getId(), "CREATED", dto.getUserId(), "특별 대여 신청이 생성되었습니다.", null, "PENDING");
        
        // 6. 관리자에게 알림 발송
        sendNotificationToAdmins("새로운 특별 대여 신청이 등록되었습니다.");
        
        return dto.getId();
    }
    
    /**
     * 기본 검증
     */
    private void validateSpecialRequest(SpecialRentalRequestDto dto) {
        // 필수 필드 검증
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
        
        // 기자재 존재 여부 확인
        EquipmentDto equipment = equipmentService.getEquipmentById(dto.getEquipmentId());
        if (equipment == null) {
            throw new IllegalArgumentException("존재하지 않는 기자재입니다.");
        }
        
        // 사용자당 최대 동시 특별 신청 수 제한
        int activeRequestCount = specialRentalRequestDao.countActiveRequestsByUser(dto.getUserId());
        if (activeRequestCount >= MAX_SPECIAL_REQUESTS_PER_USER) {
            throw new IllegalArgumentException("동시에 진행할 수 있는 특별 신청은 최대 " + MAX_SPECIAL_REQUESTS_PER_USER + "개입니다.");
        }
        
        // 동일 기자재에 대한 중복 신청 방지
        int sameEquipmentCount = specialRentalRequestDao.countActiveSameEquipmentRequests(dto.getUserId(), dto.getEquipmentId());
        if (sameEquipmentCount > 0) {
            throw new IllegalArgumentException("이미 동일한 기자재에 대한 특별 신청이 진행중입니다.");
        }
    }
    
    /**
     * 현재 상황 정보 수집
     */
    private void collectCurrentSituation(SpecialRentalRequestDto dto) {
        EquipmentDto equipment = equipmentService.getEquipmentById(dto.getEquipmentId());
        
        dto.setCurrentAvailableQuantity(equipment.getAvailableQuantity());
        dto.setMaxRentalQuantity(equipment.getMaxRentalQuantity());
        
        // 사용자의 현재 대여 수량 조회
        int currentUserRentalCount = equipmentRentalService.countCurrentRentalsByUser(dto.getUserId());
        dto.setCurrentUserRentalCount(currentUserRentalCount);
    }
    
    /**
     * 우선순위 점수 계산
     */
    private int calculatePriorityScore(SpecialRentalRequestDto dto) {
        int score = 0;
        
        // 긴급도에 따른 점수
        switch (dto.getUrgencyLevel()) {
            case "EMERGENCY":
                score += 100;
                break;
            case "HIGH":
                score += 75;
                break;
            case "MEDIUM":
                score += 50;
                break;
            default:
                score += 25;
                break;
        }
        
        // 긴급 신청 여부
        if (Boolean.TRUE.equals(dto.getIsEmergency())) {
            score += 50;
        }
        
        // 사용 기간이 짧을수록 높은 점수
        if (dto.getExpectedUsagePeriod() != null) {
            if (dto.getExpectedUsagePeriod() <= 3) {
                score += 30;
            } else if (dto.getExpectedUsagePeriod() <= 7) {
                score += 20;
            } else if (dto.getExpectedUsagePeriod() <= 14) {
                score += 10;
            }
        }
        
        return score;
    }
    
    // ================================
    // 승인/반려 처리
    // ================================
    
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
        
        // 실제 대여 신청 생성 (특별 승인된 것이므로 수량 제한 무시)
        createActualRental(request);
        
        // 처리 로그 기록
        logAction(requestId, "APPROVED", adminId, approvalReason, "PENDING", "APPROVED");
        
        // 사용자에게 승인 알림 발송
        sendNotificationToUser(request.getUserId(), "특별 대여 신청이 승인되었습니다.", 
            "특별 대여 신청이 승인되어 기자재를 대여할 수 있습니다.");
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
        
        // 처리 로그 기록
        logAction(requestId, "REJECTED", adminId, rejectionReason, "PENDING", "REJECTED");
        
        // 사용자에게 반려 알림 발송
        sendNotificationToUser(request.getUserId(), "특별 대여 신청이 반려되었습니다.", 
            "특별 대여 신청이 반려되었습니다. 사유: " + rejectionReason);
    }
    
    /**
     * 실제 대여 신청 생성 (특별 승인 시)
     */
    private void createActualRental(SpecialRentalRequestDto request) {
        EquipmentRentalDto rental = new EquipmentRentalDto();
        rental.setUserId(request.getUserId());
        rental.setEquipmentId(request.getEquipmentId());
        rental.setRequestedQuantity(request.getRequestedQuantity());
        rental.setPurpose(request.getPurpose() + " (특별 승인)");
        rental.setExpectedReturnDate(java.sql.Date.valueOf(request.getExpectedEndDate()));
        rental.setStatus("SPECIAL_APPROVED");
        rental.setIsApproved(true);
        rental.setApprovedBy(request.getReviewedBy());
        
        // 특별 승인이므로 수량 제한 검증 생략하고 바로 생성
        equipmentRentalService.createRental(rental);
        
        // 재고 차감 (특별 승인이므로 음수가 될 수 있음)
        equipmentService.decrementAvailableQuantity(request.getEquipmentId(), request.getRequestedQuantity());
    }
    
    // ================================
    // 목록 조회
    // ================================
    
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
    
    /**
     * 긴급 신청 목록
     */
    public List<SpecialRentalRequestDto> getEmergencyRequests(Map<String, Object> params) {
        return specialRentalRequestDao.selectEmergencyRequests(params);
    }
    
    // ================================
    // 첨부파일 처리
    // ================================
    
    /**
     * 첨부파일 처리
     */
    private void handleAttachments(Long requestId, List<MultipartFile> attachments) throws IOException {
        // 업로드 디렉토리 생성
        Path uploadDir = Paths.get(UPLOAD_DIR);
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }
        
        for (MultipartFile file : attachments) {
            if (!file.isEmpty()) {
                String originalFilename = file.getOriginalFilename();
                String storedFilename = UUID.randomUUID() + "_" + originalFilename;
                Path filePath = uploadDir.resolve(storedFilename);
                
                file.transferTo(filePath.toFile());
                
                SpecialRentalAttachmentDto attachment = new SpecialRentalAttachmentDto();
                attachment.setSpecialRequestId(requestId);
                attachment.setOriginalFilename(originalFilename);
                attachment.setStoredFilename(storedFilename);
                attachment.setFilePath(filePath.toString());
                attachment.setFileSize(file.getSize());
                attachment.setFileType(file.getContentType());
                attachment.setCreatedAt(LocalDateTime.now());
                
                specialRentalRequestDao.insertAttachment(attachment);
            }
        }
    }
    
    // ================================
    // 알림 발송
    // ================================
    
    /**
     * 관리자들에게 알림 발송
     */
    private void sendNotificationToAdmins(String message) {
        try {
            // 실제 구현에서는 모든 관리자 ID를 조회해서 발송
            // 여기서는 간단하게 구현
            notificationService.createNotification(
                1L, // 관리자 ID (실제로는 모든 관리자에게 발송)
                "SPECIAL_RENTAL_REQUEST",
                "새로운 특별 대여 신청",
                message,
                "/special-rental/admin/list"
            );
        } catch (Exception e) {
            // 알림 발송 실패해도 신청 생성은 성공으로 처리
            System.err.println("관리자 알림 발송 실패: " + e.getMessage());
        }
    }
    
    /**
     * 사용자에게 알림 발송
     */
    private void sendNotificationToUser(Long userId, String title, String message) {
        try {
            notificationService.createNotification(
                userId,
                "SPECIAL_RENTAL_RESPONSE",
                title,
                message,
                "/special-rental/my-requests"
            );
        } catch (Exception e) {
            System.err.println("사용자 알림 발송 실패: " + e.getMessage());
        }
    }
    
    // ================================
    // 로그 관리
    // ================================
    
    /**
     * 처리 로그 기록
     */
    private void logAction(Long requestId, String actionType, Long actionBy, String reason, String previousStatus, String newStatus) {
        try {
            SpecialRentalLogDto log = new SpecialRentalLogDto();
            log.setSpecialRequestId(requestId);
            log.setActionType(actionType);
            log.setActionBy(actionBy);
            log.setActionReason(reason);
            log.setPreviousStatus(previousStatus);
            log.setNewStatus(newStatus);
            log.setCreatedAt(LocalDateTime.now());
            
            specialRentalRequestDao.insertLog(log);
        } catch (Exception e) {
            System.err.println("로그 기록 실패: " + e.getMessage());
        }
    }
    
    // ================================
    // 기타 유틸리티 메서드
    // ================================
    
    /**
     * ID로 특별 신청 조회
     */
    public SpecialRentalRequestDto getSpecialRequestById(Long id) {
        return specialRentalRequestDao.selectSpecialRequestById(id);
    }
    
    /**
     * 특별 신청 취소
     */
    public void cancelSpecialRequest(Long requestId, Long userId) {
        SpecialRentalRequestDto request = specialRentalRequestDao.selectSpecialRequestById(requestId);
        if (request == null) {
            throw new IllegalArgumentException("존재하지 않는 신청입니다.");
        }
        
        if (!request.getUserId().equals(userId)) {
            throw new IllegalArgumentException("본인의 신청만 취소할 수 있습니다.");
        }
        
        if (!"PENDING".equals(request.getStatus())) {
            throw new IllegalArgumentException("승인 대기 상태의 신청만 취소할 수 있습니다.");
        }
        
        specialRentalRequestDao.cancelSpecialRequest(requestId);
        logAction(requestId, "CANCELLED", userId, "사용자가 신청을 취소했습니다.", "PENDING", "CANCELLED");
    }
    
    /**
     * 특별 신청 첨부파일 목록 조회
     */
    public List<SpecialRentalAttachmentDto> getAttachmentsByRequestId(Long requestId) {
        return specialRentalRequestDao.selectAttachmentsByRequestId(requestId);
    }
    
    /**
     * 특별 신청 처리 로그 조회
     */
    public List<SpecialRentalLogDto> getLogsByRequestId(Long requestId) {
        return specialRentalRequestDao.selectLogsByRequestId(requestId);
    }
} 