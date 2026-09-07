package com.example.test.equipmentrepair;

import java.time.ZoneId;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.test.auth.AuthDto;
import com.example.test.auth.AuthService;

@Controller
@RequestMapping("/repair")
public class EquipmentRepairController {

    @Autowired
    private EquipmentRepairService equipmentRepairService;

    @Autowired
    private AuthService authService;

    // ① 수리 요청 작성 폼 (학생용)
    @GetMapping("/form")
    public String showRepairForm(@RequestParam(value = "rentalId", required = false) Long rentalId,
                                @RequestParam(value = "equipmentId", required = false) Long equipmentId,
                                HttpSession session,
                                Model model) {
        String role = (String) session.getAttribute("role");
        if (role == null || !"STUDENT".equals(role)) {
            return "redirect:/auth/login";
        }

        // rentalId와 equipmentId 중 최소 하나는 있어야 함
        if (rentalId == null && equipmentId == null) {
            model.addAttribute("errorMessage", "수리 요청을 위해 rentalId 또는 equipmentId가 필요합니다.");
            return "error/400"; // error/400.jsp 존재해야 함
        }

        model.addAttribute("rentalId", rentalId);
        model.addAttribute("equipmentId", equipmentId);
        return "repair/form";
    }



    // ② 수리 요청 제출 처리 (학생용)
    @PostMapping("/submit")
    public String submitRepair(@RequestParam(value = "rentalId", required = false) Long rentalId,
                                @RequestParam("reason") String reason,
                                @RequestParam(value = "image", required = false) MultipartFile image,
                                HttpSession session,
                                RedirectAttributes redirectAttributes,
                                Model model) {

        String role = (String) session.getAttribute("role");
        Long userId = (Long) session.getAttribute("userId");

        if (role == null || !"STUDENT".equals(role) || userId == null) {
            return "redirect:/auth/login";
        }

        // rentalId 필수 검증
        if (rentalId == null) {
            redirectAttributes.addFlashAttribute("errorMessage", "수리 요청을 위해서는 대여 중인 기자재가 필요합니다. 대여 목록에서 다시 시도해주세요.");
            return "redirect:/reservation/my";
        }

        // 사유 검증
        if (reason == null || reason.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("errorMessage", "고장 사유를 입력해주세요.");
            return "redirect:/repair/form?rentalId=" + rentalId;
        }

        try {
            int result = equipmentRepairService.submitRepairRequest(rentalId, userId, reason, image);
            if (result == 1) {
                redirectAttributes.addFlashAttribute("successMessage", "수리 요청이 성공적으로 제출되었습니다.");
                return "redirect:/repair/complete";
            } else {
                redirectAttributes.addFlashAttribute("errorMessage", "수리 요청 처리 중 오류가 발생했습니다.");
                return "redirect:/reservation/my";
            }
        } catch (Exception e) {
            System.err.println("수리 요청 제출 오류: " + e.getMessage());
            redirectAttributes.addFlashAttribute("errorMessage", "수리 요청 처리 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/repair/form?rentalId=" + rentalId;
        }
    }
    // ③ 수리 완료 안내 페이지
    @RequestMapping("/complete")
    public String showCompletePage() {
        return "repair/complete";
    }


    // ✅ ④ [관리자용] 수리 요청 반려 처리
    @PostMapping("/admin/reject")
    public String rejectRepair(@RequestParam("repairId") Long repairId,
                               @RequestParam("rejectionReason") String rejectionReason,
                               HttpSession session,
                               RedirectAttributes redirectAttributes) {

        Long adminId = (Long) session.getAttribute("userId");
        if (adminId == null) {
            return "redirect:/auth/login";
        }

        try {
            equipmentRepairService.rejectRepair(repairId, adminId, rejectionReason);
            redirectAttributes.addFlashAttribute("successMessage", "수리 요청을 반려했습니다.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "반려 처리 중 오류 발생: " + e.getMessage());
        }

        return "redirect:/repair/admin/list";
    }

    @GetMapping("/admin/list")
    public String showPendingRepairs(HttpSession session, Model model) {
        String role = (String) session.getAttribute("role");
        if (role == null || !"ADMIN".equals(role)) {
            return "redirect:/auth/login";
        }

        List<EquipmentRepairDto> pendingList = equipmentRepairService.getPendingRepairs();

        // 👉 각 항목에 user, requestedAtDate 주입
        for (EquipmentRepairDto dto : pendingList) {
            // ① 사용자 정보 주입
            AuthDto user = authService.getUserById(dto.getRequestedBy());
            dto.setUser(user);

            // ② LocalDateTime → java.util.Date 변환 (JSP <fmt:formatDate>용)
            if (dto.getRequestedAt() != null) {
                dto.setRequestedAtDate(Date.from(
                    dto.getRequestedAt().atZone(ZoneId.systemDefault()).toInstant()
                ));
            }
        }

        model.addAttribute("pendingList", pendingList);
        return "repair/admin-list";
    }


    // 승인/반려 폼 보여주기
    @GetMapping("/admin/approve-form")
    public String showRepairApprovalForm(@RequestParam("rId") Long repairId,
                                        Model model,
                                        HttpSession session) {

        if (repairId == null) {
            return "redirect:/repair/admin/list";
        }

        String role = (String) session.getAttribute("role");
        if (!"ADMIN".equals(role)) {
            return "redirect:/auth/login";
        }

        // 수리 요청 정보 조회
        EquipmentRepairDto repair = equipmentRepairService.getRepairById(repairId);
        if (repair == null) {
            return "redirect:/repair/admin/list";
        }

        // ✅ 요청자 정보 주입 (AuthDto)
        AuthDto user = authService.getUserById(repair.getRequestedBy());
        repair.setUser(user); // EquipmentRepairDto에 setUser(AuthDto) 필요

        // ✅ LocalDateTime → Date로 변환
        Date repairRequestedAtDate = null;
        if (repair.getRequestedAt() != null) {
            repairRequestedAtDate = Date.from(
                repair.getRequestedAt().atZone(ZoneId.systemDefault()).toInstant()
            );
        }

        // 모델에 데이터 전달
        model.addAttribute("repair", repair);
        model.addAttribute("repairRequestedAtDate", repairRequestedAtDate);

        return "repair/admin-approve-form";
    }



    
    @PostMapping("/admin/handle")
    public String handleRepairRequest(@RequestParam Long repairId,
                                    @RequestParam String action,
                                    @RequestParam(required = false) String rejectionReason,
                                    HttpSession session) {
        String role = (String) session.getAttribute("role");
        if (role == null || !"ADMIN".equals(role)) {
            return "redirect:/auth/login";
        }

        Long adminId = ((AuthDto) session.getAttribute("loginUser")).getId();

        if ("approve".equals(action)) {
            equipmentRepairService.approveRepair(repairId, adminId);
        } else {
            equipmentRepairService.rejectRepair(repairId, adminId, rejectionReason);
        }

        return "redirect:/repair/admin/list";
    }

}
