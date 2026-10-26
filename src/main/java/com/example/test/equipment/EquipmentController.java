package com.example.test.equipment;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.example.test.equipmentrental.EquipmentRentalDto;
import com.example.test.equipmentrental.EquipmentRentalService;
import com.example.test.equipmentrepair.EquipmentRepairDto;
import com.example.test.equipmentrepair.EquipmentRepairService;
import com.example.test.equipmentreservation.EquipmentReservationService;

@Controller
@RequestMapping("/equipment")
public class EquipmentController {

    @Autowired private EquipmentRentalService equipmentRentalService;
    @Autowired private EquipmentService equipmentService;
    @Autowired private EquipmentRepairService equipmentRepairService;
    @Autowired private EquipmentReservationService equipmentReservationService;

    // 1. 루트 → 리스트 리다이렉트
    @GetMapping({ "", "/" })
    public String equipmentRoot() {
        return "redirect:/equipment/list";
    }

    // 2. 기자재 리스트 페이지 (검색, 필터링, 페이지네이션 지원)
    @GetMapping("/list")
    public String listEquipment(
            HttpSession session, 
            Model model,
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "10") int size,
            @RequestParam(value = "keyword", required = false) String keyword,
            @RequestParam(value = "category", required = false) String category,
            @RequestParam(value = "status", required = false) String status,
            @RequestParam(value = "location", required = false) String location,
            @RequestParam(value = "sortBy", defaultValue = "created_at_desc") String sortBy) {
        
        String role = (String) session.getAttribute("role");
        Long userId = (Long) session.getAttribute("userId");

        // 검색 조건 Map 생성
        Map<String, Object> searchParams = new HashMap<>();
        searchParams.put("keyword", keyword);
        searchParams.put("category", category);
        searchParams.put("status", status);
        searchParams.put("location", location);
        searchParams.put("sortBy", sortBy);
        searchParams.put("offset", (page - 1) * size);
        searchParams.put("size", size);

        // 전체 개수 조회
        int totalCount = equipmentService.getEquipmentCount(searchParams);
        int totalPages = (int) Math.ceil((double) totalCount / size);

        // 기자재 목록 조회
        List<EquipmentDto> equipmentList = equipmentService.getEquipmentListWithPaging(searchParams);

        // 페이지네이션 정보 계산
        int startPage = Math.max(1, page - 2);
        int endPage = Math.min(totalPages, page + 2);

        // 모델에 데이터 추가
        model.addAttribute("equipmentList", equipmentList);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("startPage", startPage);
        model.addAttribute("endPage", endPage);

        // 학생인 경우 대여/수리/예약 정보 추가
        if ("STUDENT".equals(role) && userId != null) {
            Map<Long, EquipmentRentalDto> rentalMap = new HashMap<>();
            Map<Long, String> repairStatusMap = new HashMap<>();
            Map<Long, Boolean> reservationStatusMap = new HashMap<>();

            for (EquipmentDto eq : equipmentList) {
                Long eqId = eq.getId();

                // 대여정보
                EquipmentRentalDto rental = equipmentRentalService.getRentalByUserAndEquipment(userId, eqId);
                if (rental != null) {
                    rentalMap.put(eqId, rental);

                    // 최근 수리 상태 가져오기
                    EquipmentRepairDto latestRepair = equipmentRepairService.getLatestRepairByRentalId(rental.getId());
                    if (latestRepair != null) {
                        repairStatusMap.put(eqId, latestRepair.getStatus());
                    } else {
                        repairStatusMap.put(eqId, null);
                    }
                } else {
                    repairStatusMap.put(eqId, null);
                }

                // 예약여부
                boolean reserved = equipmentReservationService.isAlreadyReserved(userId, eqId);
                reservationStatusMap.put(eqId, reserved);
            }

            model.addAttribute("rentalMap", rentalMap);
            model.addAttribute("repairStatusMap", repairStatusMap);
            model.addAttribute("reservationStatusMap", reservationStatusMap);
        }

        return "equipment/list";
    }

    // 3. 기자재 등록 폼 (ADMIN 전용)
    @GetMapping("/register")
    public String showRegisterForm(HttpSession session, Model model) {
        if (!"ADMIN".equals(session.getAttribute("role"))) {
            return "redirect:/access-denied";
        }
        model.addAttribute("equipment", new EquipmentDto());
        return "equipment/register";
    }

    // 4. 기자재 등록 처리
    @PostMapping("/register")
    public String registerEquipment(HttpSession session, @ModelAttribute EquipmentDto equipment) {
        if (!"ADMIN".equals(session.getAttribute("role"))) {
            return "redirect:/access-denied";
        }
        equipment.setManagedBy((Long) session.getAttribute("userId"));
        equipmentService.createEquipment(equipment);
        return "redirect:/equipment/list";
    }

    // 5. 기자재 상세 페이지
    @GetMapping("/detail/{id}")
    public String detailEquipment(@PathVariable Long id, HttpSession session, Model model) {
        EquipmentDto equipment = equipmentService.getEquipmentById(id);
        if (equipment == null) {
            return "redirect:/equipment/list";
        }

        model.addAttribute("equipment", equipment);

        String role = (String) session.getAttribute("role");
        Long userId = (Long) session.getAttribute("userId");

        if ("STUDENT".equals(role) && userId != null) {
            EquipmentRentalDto rentalInfo = equipmentRentalService.getRentalByUserAndEquipment(userId, id);
            model.addAttribute("rentalInfo", rentalInfo);
        }

        return "equipment/detail";
    }

    // 6. 기자재 수정 폼
    @GetMapping("/edit/{id}")
    public String showEditForm(HttpSession session, @PathVariable Long id, Model model) {
        if (!"ADMIN".equals(session.getAttribute("role"))) {
            return "redirect:/access-denied";
        }

        EquipmentDto equipment = equipmentService.getEquipmentById(id);
        model.addAttribute("equipment", equipment);
        return "equipment/edit";
    }

    // 7. 기자재 수정 처리
    @PostMapping("/edit/{id}")
    public String updateEquipment(HttpSession session, @PathVariable Long id, @ModelAttribute EquipmentDto equipment) {
        if (!"ADMIN".equals(session.getAttribute("role"))) {
            return "redirect:/access-denied";
        }

        equipment.setId(id);
        equipment.setManagedBy((Long) session.getAttribute("userId"));
        equipmentService.updateEquipment(equipment);
        return "redirect:/equipment/list";
    }

    // 8. 기자재 삭제
    @PostMapping("/delete/{id}")
    public String deleteEquipment(HttpSession session, @PathVariable Long id) {
        if (!"ADMIN".equals(session.getAttribute("role"))) {
            return "redirect:/access-denied";
        }

        equipmentService.deleteEquipment(id);
        return "redirect:/equipment/list";
    }
}