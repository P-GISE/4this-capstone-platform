package com.example.test.dashboard;

import com.example.test.inquiry.InquiryService;
import com.example.test.equipment.EquipmentService;
import com.example.test.equipment.EquipmentDto;
import com.example.test.equipmentrental.EquipmentRentalService;
import com.example.test.auth.AuthDto;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpSession;
import java.util.Collections;
import java.util.List;

@Controller
@RequestMapping("/dashboard")
public class DashboardController {

    private static final Logger logger = LoggerFactory.getLogger(DashboardController.class);

    @Autowired
    private InquiryService inquiryService;
    
    @Autowired
    private EquipmentService equipmentService;
    
    // 기자재 대여 서비스 추가
    @Autowired
    private EquipmentRentalService equipmentRentalService;

    /**
     * /dashboard, /dashboard/, /dashboard/main
     * 세 가지 URL을 모두 이 메서드가 처리합니다.
     */
    @GetMapping({ "", "/", "/main" })
    public String main(Model model, HttpSession session) {
        try {
            // 로그인 사용자 정보 가져오기
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            
            if (loginUser != null) {
                // 관리자 여부 확인
                boolean isAdmin = "관리자".equals(loginUser.getRole()) || "ADMIN".equals(loginUser.getRole());
                
                if (isAdmin) {
                    // 관리자: 답변 대기중인 모든 문의사항 표시
                    List<com.example.test.inquiry.InquiryDto> recentInquiries = 
                        inquiryService.getPagedList(0, 5, null, "PENDING", "latest");
                    
                    model.addAttribute("inquiries", recentInquiries);
                    model.addAttribute("isAdmin", true);
                    model.addAttribute("inquiryTitle", "최근 AI 기술 문의 (답변 대기중)");
                    model.addAttribute("emptyMessage", "답변 대기중인 문의사항이 없습니다.");
                    
                } else {
                    // 일반 사용자: 본인이 작성한 문의사항만 표시 (최근 3개)
                    List<com.example.test.inquiry.InquiryDto> myInquiries = 
                        inquiryService.getMyInquiries(loginUser.getId(), 0, 3, "latest");
                    
                    model.addAttribute("inquiries", myInquiries);
                    model.addAttribute("isAdmin", false);
                    model.addAttribute("inquiryTitle", "나의 문의 내역");
                    model.addAttribute("emptyMessage", "작성한 문의사항이 없습니다.");
                    
                    // === 일반 사용자용 활동 요약 데이터 추가 ===
                    String username = loginUser.getUsername();
                    try {
                        // 1. 현재 대여중인 기자재 수
                        int currentRentalsCount = equipmentRentalService.getCurrentRentalsCountByUsername(username);
                        model.addAttribute("currentRentalsCount", currentRentalsCount);
                        
                        // 2. 총 기자재 대여 횟수 (반납완료 + 현재대여중)
                        int totalRentalsCount = equipmentRentalService.getTotalRentalsCountByUsername(username);
                        model.addAttribute("totalRentalsCount", totalRentalsCount);
                        
                        // 3. 연체중인 기자재 수
                        int overdueRentalsCount = equipmentRentalService.getOverdueRentalsCountByUsername(username);
                        model.addAttribute("overdueRentalsCount", overdueRentalsCount);
                        
                        // 4. 기술 문의 총 횟수
                        int totalInquiriesCount = inquiryService.getTotalInquiriesCountByUsername(username);
                        model.addAttribute("totalInquiriesCount", totalInquiriesCount);
                        
                        logger.info("활동 요약 데이터 로드 완료 - 현재대여: {}, 총대여: {}, 연체: {}, 문의: {}", 
                            currentRentalsCount, totalRentalsCount, overdueRentalsCount, totalInquiriesCount);
                            
                    } catch (Exception e) {
                        logger.warn("활동 요약 데이터 로드 중 오류 발생, 기본값 0으로 설정", e);
                        // 오류 발생 시 기본값 설정
                        model.addAttribute("currentRentalsCount", 0);
                        model.addAttribute("totalRentalsCount", 0);
                        model.addAttribute("overdueRentalsCount", 0);
                        model.addAttribute("totalInquiriesCount", 0);
                    }
                }
            } else {
                // 로그인하지 않은 경우
                model.addAttribute("inquiries", Collections.emptyList());
                model.addAttribute("isAdmin", false);
                model.addAttribute("inquiryTitle", "나의 문의 내역");
                model.addAttribute("emptyMessage", "로그인이 필요합니다.");
                
                // 비로그인 사용자용 기본값 설정
                model.addAttribute("currentRentalsCount", 0);
                model.addAttribute("totalRentalsCount", 0);
                model.addAttribute("overdueRentalsCount", 0);
                model.addAttribute("totalInquiriesCount", 0);
            }

            // 기자재 정보 추가 (최신 등록된 기자재 4개)
            try {
                List<EquipmentDto> recentEquipments = equipmentService.getRecentEquipments(4);
                model.addAttribute("recentEquipments", recentEquipments);
            } catch (Exception e) {
                logger.error("기자재 정보 조회 중 오류: " + e.getMessage(), e);
                model.addAttribute("recentEquipments", Collections.emptyList());
            }
            
            model.addAttribute("notices", Collections.emptyList());
            model.addAttribute("myRentals", Collections.emptyList());
            
        } catch (Exception e) {
            // 에러 발생 시 빈 리스트로 설정
            logger.error("대시보드 데이터 조회 중 오류: " + e.getMessage(), e);
            model.addAttribute("notices", Collections.emptyList());
            model.addAttribute("myRentals", Collections.emptyList());
            model.addAttribute("inquiries", Collections.emptyList());
            model.addAttribute("recentEquipments", Collections.emptyList());
            model.addAttribute("isAdmin", false);
            model.addAttribute("inquiryTitle", "문의 내역");
            model.addAttribute("emptyMessage", "데이터를 불러올 수 없습니다.");
            
            // 에러 시에도 활동 요약 기본값 설정
            model.addAttribute("currentRentalsCount", 0);
            model.addAttribute("totalRentalsCount", 0);
            model.addAttribute("overdueRentalsCount", 0);
            model.addAttribute("totalInquiriesCount", 0);
        }
        
        return "dashboard/main";
    }
}