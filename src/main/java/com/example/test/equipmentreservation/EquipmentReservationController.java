package com.example.test.equipmentreservation;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.test.equipment.EquipmentDto;
import com.example.test.equipment.EquipmentService;
import com.example.test.equipmentrental.EquipmentRentalDto;
import com.example.test.equipmentrental.EquipmentRentalService;
import com.example.test.equipmentrepair.EquipmentRepairDto;
import com.example.test.equipmentrepair.EquipmentRepairService;
import com.example.test.specialrental.SpecialRentalRequestDto;
import com.example.test.specialrental.SpecialRentalService;

@Controller
@RequestMapping("/reservation")
public class EquipmentReservationController {

    @Autowired
    private EquipmentReservationService reservationService;

    @Autowired
    private EquipmentService equipmentService;

    @Autowired
    private EquipmentRentalService equipmentRentalService;

    @Autowired
    private EquipmentReservationService equipmentReservationService;

    @Autowired
    private EquipmentRepairService equipmentRepairService;

    @Autowired
    private SpecialRentalService specialRentalService;


    /** 예약 등록 처리 */
    @PostMapping("/create")
    public String submitReservation(@RequestParam("equipmentId") Long equipmentId,
                                    @RequestParam(value = "note", required = false) String note,
                                    HttpSession session,
                                    RedirectAttributes redirectAttributes) {
        Long userId = (Long) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");

        if (userId == null || !"STUDENT".equals(role)) {
            return "redirect:/auth/login";
        }

        // ✅ 대여 가능한 수량 확인
        EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);
        if (equipment.getAvailableQuantity() > 0) {
            redirectAttributes.addFlashAttribute("errorMessage", "아직 대여 가능한 수량이 있습니다. 예약은 수량이 0일 때만 가능합니다.");
            return "redirect:/equipment/list";
        }

        // ✅ 예약 중복 확인
        boolean already = reservationService.isAlreadyReserved(userId, equipmentId);
        if (already) {
            redirectAttributes.addFlashAttribute("errorMessage", "이미 해당 기자재에 대한 예약이 존재합니다.");
            return "redirect:/equipment/list";
        }

        // ✅ 예약 진행
        reservationService.createReservation(userId, equipmentId, note);
        redirectAttributes.addFlashAttribute("successMessage", "예약이 완료되었습니다.");
        return "redirect:/equipment/list";
    }

    @GetMapping("/my")
    public String viewMyRentalHistory(HttpSession session, Model model) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) {
            return "redirect:/auth/login";
        }

        List<EquipmentRentalDto> allRentals = equipmentRentalService.getRentalsByUser(userId);

        // ① 현재 대여 중
        List<EquipmentRentalDto> currentRentals = allRentals.stream()
            .filter(r -> "APPROVED".equals(r.getStatus()) && r.getReturnDate() == null)
            .collect(Collectors.toList());

        // ② 반납 완료
        List<EquipmentRentalDto> returnedRentals = allRentals.stream()
            .filter(r -> r.getReturnDate() != null)
            .collect(Collectors.toList());

        // ③ 예약중
        List<EquipmentReservationDto> activeReservations = equipmentReservationService.getReservationsByUser(userId);

        // ④ 연체
        int overdueCount = (int) allRentals.stream()
            .filter(r -> "APPROVED".equals(r.getStatus()) && r.getReturnDate() == null &&
                    r.getExpectedReturnDate() != null && 
                    r.getExpectedReturnDate().before(new Date()))
            .count();

        // ⑤ 총 대여 횟수
        int totalCount = allRentals.size();

        // ✅ ⑥ 수리 상태 Map 구성
        List<EquipmentRepairDto> myRepairs = equipmentRepairService.getRepairsByUser(userId);
        Map<Long, Boolean> repairStatusMap = new HashMap<>();
        Map<Long, String> repairRequestDateMap = new HashMap<>();
        Map<Long, String> repairContentMap = new HashMap<>();

        for (EquipmentRepairDto repair : myRepairs) {
            if ("PENDING".equals(repair.getStatus())) {
                EquipmentRentalDto rental = equipmentRentalService.getRentalById(repair.getRentalId());
                if (rental != null) {
                    Long equipmentId = rental.getEquipmentId();
                    repairStatusMap.put(equipmentId, true);
                    repairRequestDateMap.put(equipmentId, repair.getRequestedAt().toLocalDate().toString());
                    repairContentMap.put(equipmentId, repair.getReason());
                }
            }
        }

        // ⑦ 특별 대여 신청 데이터 가져오기
        Map<String, Object> specialParams = new HashMap<>();
        List<SpecialRentalRequestDto> specialRequests = specialRentalService.getSpecialRequestsByUser(userId, specialParams);
        int specialRequestCount = specialRequests.size();

        // 📦 model에 데이터 담기
        model.addAttribute("currentRentals", currentRentals);
        model.addAttribute("returnedRentals", returnedRentals);
        model.addAttribute("reservations", activeReservations);
        model.addAttribute("specialRequests", specialRequests);
        model.addAttribute("overdueCount", overdueCount);
        model.addAttribute("rentalTotalCount", totalCount);
        model.addAttribute("specialRequestCount", specialRequestCount);
        model.addAttribute("repairStatusMap", repairStatusMap);
        model.addAttribute("repairRequestDateMap", repairRequestDateMap);
        model.addAttribute("repairContentMap", repairContentMap);
        model.addAttribute("repairRequestCount", repairStatusMap.size());
        return "reservation/my";
    }



    /** 예약 취소 처리 */
    @PostMapping("/cancel")
    public String cancelReservation(@RequestParam("reservationId") Long reservationId,
                                    HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) {
            return "redirect:/auth/login";
        }

        reservationService.cancelReservation(reservationId);
        return "redirect:/reservation/my";
    }
}
