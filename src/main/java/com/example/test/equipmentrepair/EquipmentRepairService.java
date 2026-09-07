package com.example.test.equipmentrepair;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.example.test.equipment.EquipmentService;
import com.example.test.equipmentrental.EquipmentRentalDto;
import com.example.test.equipmentrental.EquipmentRentalService;
import com.example.test.notification.Notification;
import com.example.test.notification.NotificationService;

@Service
public class EquipmentRepairService {

    

    private static final String UPLOAD_DIR = "C:/uploads/repair";

    @Autowired
    private EquipmentRepairDao equipmentRepairDao;

    @Autowired
    private EquipmentRentalService equipmentRentalService;

    @Autowired
    private EquipmentService equipmentService;

    @Autowired
    private NotificationService notificationService;


    public int submitRepairRequest(Long rentalId, Long userId, String reason, MultipartFile image) {
        EquipmentRentalDto rental = equipmentRentalService.getRentalById(rentalId);
        if (rental == null || !rental.getUserId().equals(userId)) {
            return 0;
        }

        EquipmentRepairDto repair = new EquipmentRepairDto();
        repair.setRentalId(rentalId);
        repair.setRequestedBy(userId);
        repair.setReason(reason);
        repair.setStatus("PENDING");
        repair.setRequestedAt(LocalDateTime.now());

        if (image != null && !image.isEmpty()) {
            String filename = saveFile(image);
            repair.setImagePath(filename);
        }

        equipmentService.markAsDamaged(rental.getEquipmentId());

        return equipmentRepairDao.insertRepair(repair);
    }

    public List<EquipmentRepairDto> getRepairsByUser(Long userId) {
        return equipmentRepairDao.selectRepairsByUser(userId);
    }

    private String saveFile(MultipartFile file) {
        try {
            Files.createDirectories(Paths.get(UPLOAD_DIR));
            String filename = UUID.randomUUID() + "_" + file.getOriginalFilename();
            Path filepath = Paths.get(UPLOAD_DIR, filename);
            Files.copy(file.getInputStream(), filepath);
            return filename;
        } catch (IOException e) {
            throw new RuntimeException("파일 저장 실패: " + e.getMessage(), e);
        }
    }

    public boolean isRepairRequested(Long rentalId) {
        return equipmentRepairDao.existsByRentalId(rentalId);  // Mapper에 쿼리 필요
    }


    public void rejectRepair(Long repairId, Long adminId, String rejectionReason) {
        // 수리 요청 정보 조회 (알림을 위해 먼저 조회)
        EquipmentRepairDto repair = equipmentRepairDao.selectRepairById(repairId);
        if (repair == null) {
            throw new RuntimeException("수리 요청을 찾을 수 없습니다.");
        }

        EquipmentRepairDto dto = new EquipmentRepairDto();
        dto.setId(repairId);
        dto.setHandledBy(adminId);
        dto.setStatus("REJECTED");
        dto.setRejectionReason(rejectionReason);
        dto.setHandledAt(LocalDateTime.now());

        int result = equipmentRepairDao.updateRepairStatus(dto);
        if (result != 1) {
            throw new RuntimeException("반려 처리에 실패했습니다.");
        }

        // 기자재 상태 AVAILABLE 복원
        EquipmentRentalDto rental = equipmentRentalService.getRentalById(repair.getRentalId());
        if (rental != null) {
            equipmentService.updateEquipmentStatus(rental.getEquipmentId(), "AVAILABLE");

            // 사용자에게 알림 전송
            try {
                String title = "수리 요청 반려";
                String message = String.format("수리 요청이 반려되었습니다.\n사유: %s", rejectionReason);
                String targetUrl = "/reservation/my";
                notificationService.createNotification(repair.getRequestedBy(), Notification.TYPE_EQUIPMENT, title, message, targetUrl);
            } catch (Exception e) {
                // 알림 전송 실패 시 로그만 출력하고 계속 진행
                System.err.println("수리 요청 반려 알림 전송 실패: " + e.getMessage());
            }
        }
    }


    public List<EquipmentRepairDto> getPendingRepairs() {
        return equipmentRepairDao.selectPendingRepairs();
    }

    public List<EquipmentRepairDto> getAllRepairs() {
        return equipmentRepairDao.selectAllRepairs();
    }

    public EquipmentRepairDto getRepairById(Long id) {
        return equipmentRepairDao.selectRepairById(id);
    }


    public void approveRepair(Long id, Long adminId) {
        equipmentRepairDao.updateStatus(id, "COMPLETED", adminId, null);
    }

    public EquipmentRepairDto getLatestRepairByRentalId(Long rentalId) {
        return equipmentRepairDao.selectLatestByRentalId(rentalId);
    }

    
} 
