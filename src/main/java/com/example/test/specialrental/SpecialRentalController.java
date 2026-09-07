package com.example.test.specialrental;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.test.auth.AuthDto;
import com.example.test.equipment.EquipmentDto;
import com.example.test.equipment.EquipmentService;
import com.example.test.equipmentrental.EquipmentRentalDto;
import com.example.test.equipmentrental.EquipmentRentalService;

@Controller
@RequestMapping("/special-rental")
public class SpecialRentalController {

    @Autowired
    private SpecialRentalService specialRentalService;
    
    @Autowired
    private EquipmentService equipmentService;
    
    @Autowired
    private EquipmentRentalService equipmentRentalService;

    // ================================
    // 학생용 페이지들
    // ================================
    
    /**
     * 특별 대여 신청 페이지
     */
    @GetMapping("/request")
    public String showRequestPage(@RequestParam(required = false) Long equipmentId, 
                                Model model, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        if ("ADMIN".equals(loginUser.getRole())) {
            return "redirect:/access-denied";
        }
        
        // 기자재 정보 조회
        if (equipmentId != null) {
            EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);
            model.addAttribute("equipment", equipment);
        }
        
        model.addAttribute("requestDto", new SpecialRentalRequestDto());
        return "special-rental/request";
    }
    
    /**
     * 특별 대여 신청 처리
     */
    @PostMapping("/request")
    public String submitRequest(@ModelAttribute SpecialRentalRequestDto dto,
                              @RequestParam(value = "attachments", required = false) List<MultipartFile> attachments,
                              HttpSession session,
                              RedirectAttributes redirectAttributes) {
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                return "redirect:/auth/login";
            }
            
            dto.setUserId(loginUser.getId());
            
            // 날짜 검증
            if (dto.getExpectedStartDate() == null || dto.getExpectedEndDate() == null) {
                redirectAttributes.addFlashAttribute("errorMessage", "사용 예정 기간을 입력해주세요.");
                return "redirect:/special-rental/request?equipmentId=" + dto.getEquipmentId();
            }
            
            if (dto.getExpectedStartDate().isAfter(dto.getExpectedEndDate())) {
                redirectAttributes.addFlashAttribute("errorMessage", "시작일이 종료일보다 늦을 수 없습니다.");
                return "redirect:/special-rental/request?equipmentId=" + dto.getEquipmentId();
            }
            
            // 사용 기간 계산
            long period = dto.getExpectedStartDate().until(dto.getExpectedEndDate()).getDays() + 1;
            dto.setExpectedUsagePeriod((int) period);
            
            specialRentalService.createSpecialRequest(dto);
            
            redirectAttributes.addFlashAttribute("successMessage", 
                "특별 대여 신청이 성공적으로 등록되었습니다. 관리자 검토 후 결과를 알려드리겠습니다.");
            
            return "redirect:/reservation/my";
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", "신청 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/special-rental/request?equipmentId=" + dto.getEquipmentId();
        }
    }
    
    /**
     * 내 특별 대여 신청 목록 (리다이렉트 - 이제 /reservation/my에서 통합 관리)
     */
    @GetMapping("/my-requests")
    public String redirectToMyPage() {
        return "redirect:/reservation/my";
    }
    
    /**
     * 특별 대여 신청 상세 보기
     */
    @GetMapping("/view/{id}")
    public String viewRequest(@PathVariable Long id, Model model, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        SpecialRentalRequestDto request = specialRentalService.getSpecialRequestById(id);
        if (request == null) {
            return "redirect:/special-rental/my-requests?error=not_found";
        }
        
        // 권한 체크 (본인 또는 관리자만)
        boolean isAdmin = "ADMIN".equals(loginUser.getRole());
        boolean isOwner = request.getUserId().equals(loginUser.getId());
        
        if (!isAdmin && !isOwner) {
            return "redirect:/access-denied";
        }
        
        model.addAttribute("request", request);
        model.addAttribute("isAdmin", isAdmin);
        model.addAttribute("isOwner", isOwner);
        
        return "special-rental/view";
    }

    // ================================
    // 관리자용 페이지들
    // ================================
    
    /**
     * 관리자 - 특별 대여 신청 관리 페이지 테스트
     */
    @GetMapping("/admin/test-simple")
    public String showTestPage(Model model, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        if (!"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/access-denied";
        }
        
        // 기본 테스트 데이터
        model.addAttribute("totalCount", 0);
        model.addAttribute("pendingCount", 0);
        model.addAttribute("emergencyCount", 0);
        model.addAttribute("requests", new ArrayList<>());
        
        return "special-rental/test-simple";
    }
    
    /**
     * 관리자 - 특별 대여 신청 목록
     */
    @GetMapping("/admin/list")
    public String showAdminList(@RequestParam(defaultValue = "1") int page,
                              @RequestParam(defaultValue = "10") int size,
                              @RequestParam(required = false) String status,
                              @RequestParam(required = false) String urgency,
                              @RequestParam(required = false) String search,
                              Model model, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        if (!"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/access-denied";
        }
        
        Map<String, Object> params = new HashMap<>();
        params.put("offset", (page - 1) * size);
        params.put("size", size);
        params.put("status", status);
        params.put("urgency", urgency);
        params.put("search", search);
        
        try {
            List<SpecialRentalRequestDto> requests = specialRentalService.getSpecialRequestsForAdmin(params);
            
            // 통계 계산
            Map<String, Object> allParams = new HashMap<>();
            List<SpecialRentalRequestDto> allRequests = specialRentalService.getSpecialRequestsForAdmin(allParams);
            
            long totalCount = allRequests.size();
            long pendingCount = allRequests.stream().filter(req -> "PENDING".equals(req.getStatus())).count();
            long emergencyCount = allRequests.stream().filter(req -> "EMERGENCY".equals(req.getUrgencyLevel())).count();
            
            model.addAttribute("requests", requests);
            model.addAttribute("currentPage", page);
            model.addAttribute("status", status);
            model.addAttribute("urgency", urgency);
            model.addAttribute("search", search);
            
            // 통계 정보 추가
            model.addAttribute("totalCount", totalCount);
            model.addAttribute("pendingCount", pendingCount);
            model.addAttribute("emergencyCount", emergencyCount);
            
            return "special-rental/admin-list";
            
        } catch (Exception e) {
            model.addAttribute("errorMessage", "데이터 조회 중 오류가 발생했습니다: " + e.getMessage());
            model.addAttribute("totalCount", 0);
            model.addAttribute("pendingCount", 0);
            model.addAttribute("emergencyCount", 0);
            return "special-rental/admin-list";
        }
    }
    
    /**
     * 관리자 - 승인 대기 목록
     */
    @GetMapping("/admin/pending")
    public String showPendingList(@RequestParam(defaultValue = "1") int page,
                                @RequestParam(defaultValue = "10") int size,
                                Model model, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        if (!"ADMIN".equals(loginUser.getRole())) {
            return "redirect:/access-denied";
        }
        
        Map<String, Object> params = new HashMap<>();
        params.put("offset", (page - 1) * size);
        params.put("size", size);
        
        List<SpecialRentalRequestDto> requests = specialRentalService.getPendingSpecialRequests(params);
        
        model.addAttribute("requests", requests);
        model.addAttribute("currentPage", page);
        
        return "special-rental/admin-pending";
    }

    // ================================
    // AJAX 처리
    // ================================
    
    /**
     * 관리자 - 특별 대여 신청 승인
     */
    @PostMapping("/admin/approve/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> approveRequest(@PathVariable Long id,
                                                            @RequestParam String approvalReason,
                                                            HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return new ResponseEntity<>(response, HttpStatus.UNAUTHORIZED);
            }
            
            if (!"ADMIN".equals(loginUser.getRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return new ResponseEntity<>(response, HttpStatus.FORBIDDEN);
            }
            
            specialRentalService.approveSpecialRequest(id, loginUser.getId(), approvalReason);
            
            response.put("success", true);
            response.put("message", "특별 대여 신청이 승인되었습니다.");
            
            return new ResponseEntity<>(response, HttpStatus.OK);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "승인 처리 중 오류가 발생했습니다: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * 관리자 - 특별 대여 신청 반려
     */
    @PostMapping("/admin/reject/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> rejectRequest(@PathVariable Long id,
                                                           @RequestParam String rejectionReason,
                                                           HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return new ResponseEntity<>(response, HttpStatus.UNAUTHORIZED);
            }
            
            if (!"ADMIN".equals(loginUser.getRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return new ResponseEntity<>(response, HttpStatus.FORBIDDEN);
            }
            
            if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "반려 사유를 입력해주세요.");
                return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
            }
            
            specialRentalService.rejectSpecialRequest(id, loginUser.getId(), rejectionReason);
            
            response.put("success", true);
            response.put("message", "특별 대여 신청이 반려되었습니다.");
            
            return new ResponseEntity<>(response, HttpStatus.OK);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "반려 처리 중 오류가 발생했습니다: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * 기자재 정보 조회 (AJAX)
     */
    @GetMapping("/api/equipment/{id}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getEquipmentInfo(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            EquipmentDto equipment = equipmentService.getEquipmentById(id);
            if (equipment == null) {
                response.put("success", false);
                response.put("message", "기자재를 찾을 수 없습니다.");
                return new ResponseEntity<>(response, HttpStatus.NOT_FOUND);
            }
            
            response.put("success", true);
            response.put("equipment", equipment);
            
            return new ResponseEntity<>(response, HttpStatus.OK);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "기자재 정보 조회 중 오류가 발생했습니다.");
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * 현재 대여중인 기자재 목록 조회 (AJAX) - 특별 대여 신청용
     */
    @GetMapping("/api/equipments")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getEquipmentList(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return new ResponseEntity<>(response, HttpStatus.UNAUTHORIZED);
            }
            
            // 현재 사용자가 대여중인 기자재 목록 조회
            List<EquipmentRentalDto> rentedEquipments = equipmentRentalService.getCurrentRentalsByUser(loginUser.getId());
            
            // null 체크 및 빈 리스트 처리
            if (rentedEquipments == null || rentedEquipments.isEmpty()) {
                response.put("success", true);
                response.put("equipments", new ArrayList<>()); // 빈 리스트 반환
                response.put("message", "현재 대여중인 기자재가 없습니다.");
                return new ResponseEntity<>(response, HttpStatus.OK);
            }
            

            
            // 기자재별 대여 수량 계산
            Map<Long, Integer> equipmentRentalCounts = new HashMap<>();
            for (EquipmentRentalDto rental : rentedEquipments) {
                if (rental != null && rental.getEquipmentId() != null) {
                    Long equipmentId = rental.getEquipmentId();
                    // null 안전하게 처리하여 int 타입으로 변환
                    Integer requestedQty = rental.getRequestedQuantity();
                    int quantity = (requestedQty != null) ? requestedQty : 1;
                    equipmentRentalCounts.merge(equipmentId, quantity, Integer::sum);
                }
            }
            
            // 대여중인 기자재의 상세 정보 조회 (중복 제거) + 대여 수량 정보 추가
            List<Map<String, Object>> equipments = rentedEquipments.stream()
                .map(rental -> rental.getEquipmentId())
                .distinct()  // 같은 기자재를 여러 개 대여한 경우 중복 제거
                .map(equipmentId -> {
                    EquipmentDto equipment = equipmentService.getEquipmentById(equipmentId);
                    
                    if (equipment != null) {
                        Map<String, Object> equipmentWithRentalInfo = new HashMap<>();
                        equipmentWithRentalInfo.put("id", equipment.getId());
                        equipmentWithRentalInfo.put("name", equipment.getName());
                        equipmentWithRentalInfo.put("category", equipment.getCategory() != null ? equipment.getCategory() : "일반");
                        
                        // 대여 수량 안전하게 설정
                        Integer rentalCount = equipmentRentalCounts.get(equipmentId);
                        int finalRentalCount = (rentalCount != null && rentalCount > 0) ? rentalCount : 1;
                        equipmentWithRentalInfo.put("rentedQuantity", finalRentalCount);
                        
                        equipmentWithRentalInfo.put("location", equipment.getLocation());
                        equipmentWithRentalInfo.put("manufacturer", equipment.getManufacturer());
                        
                        return equipmentWithRentalInfo;
                    }
                    return null;
                })
                .filter(equipment -> equipment != null)  // null 체크
                .collect(Collectors.toList());
            
            response.put("success", true);
            response.put("equipments", equipments);
            response.put("message", "현재 대여중인 기자재 " + equipments.size() + "종류를 조회했습니다.");
            
            return new ResponseEntity<>(response, HttpStatus.OK);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "기자재 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
} 