package com.example.test.equipmentrental;

import java.util.List;

import jakarta.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.test.auth.AuthDto;
import com.example.test.auth.AuthService;
import com.example.test.equipment.EquipmentDto;
import com.example.test.equipment.EquipmentService;
import com.example.test.notification.NotificationService;

@Controller
@RequestMapping("/equipmentrental")
public class EquipmentRentalController {

    private static final Logger logger = LoggerFactory.getLogger(EquipmentRentalController.class);

    @Autowired
    private EquipmentRentalService equipmentRentalService;

    @Autowired
    private EquipmentService equipmentService;

    @Autowired
    private AuthService authService;
    
    @Autowired
    private NotificationService notificationService;

    /**
     * 1) 대여신청 폼 보기 (GET)
     *    URL: /equipmentrental/request/{equipmentId}
     */
    @GetMapping("/request/{equipmentId}")
    public String showRequestForm(
            @PathVariable("equipmentId") Long equipmentId,
            HttpSession session,
            Model model) {

        String role = (String) session.getAttribute("role");
        Long userId = (Long) session.getAttribute("userId");
        if (role == null || !"STUDENT".equals(role) || userId == null) {
            return "redirect:/auth/login";
        }

        EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);
        if (equipment == null) {
            return "redirect:/equipment/list";
        }
        model.addAttribute("equipment", equipment);

        java.util.Date now = new java.util.Date();
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
        String defaultStart = sdf.format(now);
        String defaultEnd = sdf.format(new java.util.Date(now.getTime() + 1000L * 60 * 60 * 24));
        model.addAttribute("defaultStart", defaultStart);
        model.addAttribute("defaultEnd", defaultEnd);

        // realContent 경로에서 앞의 /를 모두 제거했습니다.
        model.addAttribute("realContent", "equipmentrental/request.jsp");
        return "equipmentrental/request";
    }

    /**
     * 2) 대여신청 폼 제출 처리 (POST)
     *    URL: /equipmentrental/request
     */
    @PostMapping("/request")
    public String processRequest(
            @RequestParam("equipmentId") Long equipmentId,
            @RequestParam("rentDate") String rentDateStr,
            @RequestParam("expectedReturnDate") String expectedReturnDateStr,
            @RequestParam("requestedQuantity") Integer requestedQuantity,
            @RequestParam("purpose") String purpose,
            HttpSession session,
            Model model) {

        String role = (String) session.getAttribute("role");
        Long userId = (Long) session.getAttribute("userId");
        if (role == null || !"STUDENT".equals(role) || userId == null) {
            return "redirect:/auth/login";
        }

        java.util.Date rentDate;
        java.util.Date expectedReturnDate;
        try {
            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            rentDate = sdf.parse(rentDateStr);
            expectedReturnDate = sdf.parse(expectedReturnDateStr);
        } catch (java.text.ParseException e) {
            EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);
            model.addAttribute("equipment", equipment);
            model.addAttribute("defaultStart", rentDateStr);
            model.addAttribute("defaultEnd", expectedReturnDateStr);
            model.addAttribute("errorMessage", "날짜 형식이 올바르지 않습니다. 다시 확인해주세요.");
            model.addAttribute("realContent", "equipmentrental/request.jsp");
            return "equipmentrental/request";
        }
        
        // ✅ 날짜 유효성 검증 추가
        java.util.Date now = new java.util.Date();
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(now);
        cal.add(java.util.Calendar.MONTH, 1);
        java.util.Date oneMonthFromNow = cal.getTime();
        
        // 대여일시 검증
        if (rentDate.before(now)) {
            EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);
            model.addAttribute("equipment", equipment);
            model.addAttribute("defaultStart", rentDateStr);
            model.addAttribute("defaultEnd", expectedReturnDateStr);
            model.addAttribute("errorMessage", "대여일시는 현재 시간 이후로 선택해주세요.");
            model.addAttribute("realContent", "equipmentrental/request.jsp");
            return "equipmentrental/request";
        }
        
        if (rentDate.after(oneMonthFromNow)) {
            EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);
            model.addAttribute("equipment", equipment);
            model.addAttribute("defaultStart", rentDateStr);
            model.addAttribute("defaultEnd", expectedReturnDateStr);
            model.addAttribute("errorMessage", "대여일시는 1개월 이내로 선택해주세요.");
            model.addAttribute("realContent", "equipmentrental/request.jsp");
            return "equipmentrental/request";
        }
        
        // 반납예정일시 검증
        if (expectedReturnDate.before(rentDate) || expectedReturnDate.equals(rentDate)) {
            EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);
            model.addAttribute("equipment", equipment);
            model.addAttribute("defaultStart", rentDateStr);
            model.addAttribute("defaultEnd", expectedReturnDateStr);
            model.addAttribute("errorMessage", "반납예정일시는 대여일시보다 이후로 선택해주세요.");
            model.addAttribute("realContent", "equipmentrental/request.jsp");
            return "equipmentrental/request";
        }
        
        cal.setTime(rentDate);
        cal.add(java.util.Calendar.MONTH, 1);
        java.util.Date oneMonthFromRent = cal.getTime();
        
        if (expectedReturnDate.after(oneMonthFromRent)) {
            EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);
            model.addAttribute("equipment", equipment);
            model.addAttribute("defaultStart", rentDateStr);
            model.addAttribute("defaultEnd", expectedReturnDateStr);
            model.addAttribute("errorMessage", "반납예정일시는 대여일로부터 1개월 이내로 선택해주세요.");
            model.addAttribute("realContent", "equipmentrental/request.jsp");
            return "equipmentrental/request";
        }

        // ✅ 대여 수량 제한 검증 추가
        try {
            equipmentRentalService.validateRentalLimit(userId, equipmentId, requestedQuantity);
        } catch (IllegalArgumentException e) {
            EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);
            model.addAttribute("equipment", equipment);
            model.addAttribute("defaultStart", rentDateStr);
            model.addAttribute("defaultEnd", expectedReturnDateStr);
            model.addAttribute("errorMessage", e.getMessage());
            model.addAttribute("realContent", "equipmentrental/request.jsp");
            return "equipmentrental/request";
        }

        EquipmentRentalDto dto = new EquipmentRentalDto();
        dto.setEquipmentId(equipmentId);
        dto.setUserId(userId);
        dto.setRentDate(rentDate);
        dto.setExpectedReturnDate(expectedReturnDate);
        dto.setRequestedQuantity(requestedQuantity);
        dto.setPurpose(purpose);
        dto.setStatus("RENTED");
        dto.setIsApproved(false);

        int result = equipmentRentalService.createRental(dto);
        if (result != 1) {
            EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);
            model.addAttribute("equipment", equipment);
            model.addAttribute("defaultStart", rentDateStr);
            model.addAttribute("defaultEnd", expectedReturnDateStr);
            model.addAttribute("errorMessage", "대여 신청 중 오류가 발생했습니다. 다시 시도해주세요.");
            model.addAttribute("realContent", "equipmentrental/request.jsp");
            return "equipmentrental/request";
        }

        model.addAttribute("message", "대여 신청이 정상적으로 접수되었습니다. 관리자의 승인을 기다려주세요.");
        model.addAttribute("realContent", "equipmentrental/confirm.jsp");
        return "equipmentrental/confirm";
    }


    // ====================================================
    // (B) 관리자용 "신청 현황 관리" 화면(GET)
    //     URL: /equipmentrental/admin/pending
    // ====================================================
    @GetMapping("/admin/pending")
    public String showPendingList(HttpSession session, Model model) {
        String role = (String) session.getAttribute("role");
        if (role == null || !"ADMIN".equals(role)) {
            return "redirect:/auth/login";
        }

        List<EquipmentRentalDto> pendingList = equipmentRentalService.getPendingRentals();

        // 🔧 각 대여 요청에 사용자 정보 주입
        for (EquipmentRentalDto rental : pendingList) {
            AuthDto user = authService.getUserById(rental.getUserId());
            rental.setUser(user);  // 반드시 DTO에 setUser()가 있어야 함
        }

        model.addAttribute("pendingList", pendingList);
        return "equipmentrental/admin-pending-list";
    }


    /**
     * 관리자용: 대여 승인 처리 (POST)
     * URL: /equipmentrental/admin/approve/{rentalId}
     */
    @PostMapping("/admin/approve/{rentalId}")
    public String approveRental(
            @PathVariable("rentalId") Long rentalId,
            @RequestParam(value = "approvalReason", defaultValue = "관리자 승인") String approvalReason,
            HttpSession session,
            Model model) {

        String role = (String) session.getAttribute("role");
        Long adminId = (Long) session.getAttribute("userId");
        if (role == null || !"ADMIN".equals(role) || adminId == null) {
            return "redirect:/auth/login";
        }

        try {
            logger.info("=== 기자재 대여 승인 처리 시작 ===");
            logger.info("대여 ID: {}", rentalId);
            logger.info("관리자 ID: {}", adminId);
            logger.info("승인 사유: {}", approvalReason);

            // 대여 정보 조회
            EquipmentRentalDto rental = equipmentRentalService.getRentalById(rentalId);
            if (rental == null) {
                logger.error("대여 정보를 찾을 수 없음: {}", rentalId);
                model.addAttribute("errorMessage", "대여 정보를 찾을 수 없습니다.");
                return "equipmentrental/admin-pending-list";
            }

            // 승인 처리
            int result = equipmentRentalService.approveById(rentalId, adminId);
            if (result != 1) {
                logger.error("승인 처리 실패: {}", rentalId);
                model.addAttribute("errorMessage", "승인 처리 중 오류가 발생했습니다.");
                return "equipmentrental/admin-pending-list";
            }

            // 기자재 수량 차감
            try {
                equipmentService.decrementAvailableQuantity(rental.getEquipmentId(), rental.getRequestedQuantity());
                logger.info("기자재 수량 차감 완료: 기자재 ID {}, 차감 수량 {}", rental.getEquipmentId(), rental.getRequestedQuantity());
            } catch (Exception e) {
                logger.error("기자재 수량 차감 실패: {}", e.getMessage());
                // 수량 차감 실패해도 승인은 유지
            }

            // 사용자에게 승인 알림 발송
            try {
                String title = "기자재 대여 승인 알림";
                String message = "✅ 기자재 대여 신청이 승인되었습니다";
                String url = "/reservation/my";
                
                notificationService.createNotification(
                    rental.getUserId(),
                    "RENTAL_APPROVED",
                    title,
                    message,
                    url
                );
                logger.info("승인 알림 발송 완료: 사용자 ID {}", rental.getUserId());
            } catch (Exception e) {
                logger.error("승인 알림 발송 실패: {}", e.getMessage());
            }

            logger.info("=== 기자재 대여 승인 처리 완료 ===");
            
        } catch (Exception e) {
            logger.error("승인 처리 중 예외 발생: {}", e.getMessage(), e);
            model.addAttribute("errorMessage", "승인 처리 중 오류가 발생했습니다.");
            return "equipmentrental/admin-pending-list";
        }

        return "redirect:/equipmentrental/admin/pending";
    }

    @PostMapping("/return")
    public String returnEquipment(@RequestParam("rentalId") Long rentalId, RedirectAttributes redirectAttributes) {
        int result = equipmentRentalService.processReturn(rentalId);

        if (result == 1) {
            redirectAttributes.addFlashAttribute("message", "반납 완료되었습니다.");
        } else {
            redirectAttributes.addFlashAttribute("message", "반납 처리에 실패했습니다.");
        }

        return "redirect:/equipment/list";
    }






    /**
     * 관리자용: 대여 반려 처리 (POST)
     * URL: /equipmentrental/admin/reject/{rentalId}
     */
    @PostMapping("/admin/reject/{rentalId}")
    public String rejectRental(
            @PathVariable("rentalId") Long rentalId,
            @RequestParam("rejectionReason") String rejectionReason,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        String role = (String) session.getAttribute("role");
        Long adminId = (Long) session.getAttribute("userId");
        if (role == null || !"ADMIN".equals(role) || adminId == null) {
            return "redirect:/auth/login";
        }

        try {
            logger.info("=== 기자재 대여 반려 처리 시작 ===");
            logger.info("대여 ID: {}", rentalId);
            logger.info("관리자 ID: {}", adminId);
            logger.info("반려 사유: {}", rejectionReason);

            // 대여 정보 조회
            EquipmentRentalDto rental = equipmentRentalService.getRentalById(rentalId);
            if (rental == null) {
                logger.error("대여 정보를 찾을 수 없음: {}", rentalId);
                redirectAttributes.addFlashAttribute("errorMessage", "대여 정보를 찾을 수 없습니다.");
                return "redirect:/equipmentrental/admin/pending";
            }

            // 반려 처리
            EquipmentRentalDto dto = new EquipmentRentalDto();
            dto.setId(rentalId);
            dto.setApprovedBy(adminId);
            dto.setStatus("REJECTED");
            dto.setRejectionReason(rejectionReason);

            equipmentRentalService.updateRentalStatus(dto);

            // 사용자에게 반려 알림 발송
            try {
                String title = "기자재 대여 반려 알림";
                String message = "❌ 기자재 대여 신청이 반려되었습니다: " + rejectionReason;
                String url = "/reservation/my";
                
                notificationService.createNotification(
                    rental.getUserId(),
                    "RENTAL_REJECTED",
                    title,
                    message,
                    url
                );
                logger.info("반려 알림 발송 완료: 사용자 ID {}", rental.getUserId());
            } catch (Exception e) {
                logger.error("반려 알림 발송 실패: {}", e.getMessage());
            }

            logger.info("=== 기자재 대여 반려 처리 완료 ===");
            redirectAttributes.addFlashAttribute("successMessage", "반려 처리가 완료되었습니다.");
            
        } catch (IllegalArgumentException | IllegalStateException e) {
            logger.error("반려 처리 실패: {}", e.getMessage());
            redirectAttributes.addFlashAttribute("errorMessage", "반려 실패: " + e.getMessage());
        } catch (RuntimeException e) {
            logger.error("반려 처리 중 시스템 오류: {}", e.getMessage(), e);
            redirectAttributes.addFlashAttribute("errorMessage", "시스템 오류가 발생했습니다. 관리자에게 문의하세요.");
        }

        return "redirect:/equipmentrental/admin/pending";
    }
    



    @GetMapping("/admin/reject-form")
    public String showRejectionForm(@RequestParam("rentalId") Long rentalId, Model model) {
        model.addAttribute("rentalId", rentalId);
        return "admin/reject-form";  // JSP 파일 이름
    }

    @PostMapping("/admin/reject")
    public String rejectRental(@RequestParam("rentalId") Long rentalId,
                               @RequestParam("rejectionReason") String reason,
                               HttpSession session) {
        Long adminId = (Long) session.getAttribute("userId");
        equipmentRentalService.rejectRental(rentalId, reason, adminId);
        return "redirect:/equipmentrental/admin/pending";
    }
    
}
