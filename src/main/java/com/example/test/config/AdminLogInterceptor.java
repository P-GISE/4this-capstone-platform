package com.example.test.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.lang.NonNull;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import com.example.test.adminlog.AdminLogDto;
import com.example.test.adminlog.AdminLogService;
import com.example.test.auth.AuthDto;

@Component
public class AdminLogInterceptor implements HandlerInterceptor {

    private static final Logger logger = LoggerFactory.getLogger(AdminLogInterceptor.class);

    @Autowired
    private AdminLogService adminLogService;

    @Override
    public boolean preHandle(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response, @NonNull Object handler) 
            throws Exception {
        
        // 로깅 대상 경로인지 확인
        String uri = request.getRequestURI();
        String method = request.getMethod();
        
        // 관리자만 접근 가능한 경로들 체크
        if (shouldLogRequest(uri, method)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
                
                // 관리자인 경우에만 로깅
                if (loginUser != null && "ADMIN".equals(loginUser.getRole())) {
                    // 요청 시작 시간을 저장 (성공/실패 판정을 위해)
                    request.setAttribute("adminLogStartTime", System.currentTimeMillis());
                    request.setAttribute("adminLogUser", loginUser);
                }
            }
        }
        
        return true;
    }

    @Override
    public void afterCompletion(@NonNull HttpServletRequest request, @NonNull HttpServletResponse response, 
                                @NonNull Object handler, @Nullable Exception ex) throws Exception {
        
        // 요청 시작 시간 체크
        Long startTime = (Long) request.getAttribute("adminLogStartTime");
        AuthDto adminUser = (AuthDto) request.getAttribute("adminLogUser");
        
        if (startTime != null && adminUser != null) {
            String uri = request.getRequestURI();
            
            // 액션 타입과 대상 정보 추출
            AdminActionInfo actionInfo = extractActionInfo(uri, request);
            
            if (actionInfo != null) {
                boolean isSuccessful = (response.getStatus() >= 200 && response.getStatus() < 400) && (ex == null);
                
                try {
                    adminLogService.logAdminAction(
                        adminUser.getId(),
                        actionInfo.actionType,
                        actionInfo.targetTable,
                        actionInfo.targetId,
                        determineLogLevel(actionInfo.actionType, isSuccessful),
                        isSuccessful,
                        actionInfo.description + (ex != null ? " - 오류: " + ex.getMessage() : ""),
                        request
                    );
                } catch (Exception logEx) {
                    logger.error("관리자 로그 기록 실패: " + logEx.getMessage(), logEx);
                }
            }
        }
    }

    /**
     * 로깅 대상 요청인지 판별
     */
    private boolean shouldLogRequest(String uri, String method) {
        // POST, PUT, DELETE 요청만 로깅 (데이터 변경 작업)
        if (!"POST".equals(method) && !"PUT".equals(method) && !"DELETE".equals(method)) {
            return false;
        }
        
        // 로깅 제외 경로들
        if (uri.contains("/api/") || uri.contains("/ajax/") || 
            uri.contains("/heartbeat") || uri.contains("/logs/")) {
            return false;
        }
        
        // 관리자 전용 작업 경로들
        return uri.contains("/admin/") || 
               uri.contains("/equipment/register") || 
               uri.contains("/equipment/edit") || 
               uri.contains("/equipment/delete") || 
               uri.contains("/notice/write") || 
               uri.contains("/notice/update") || 
               uri.contains("/notice/delete") || 
               uri.contains("/inquiry/answer") ||
               uri.contains("/rental/approve") ||
               uri.contains("/rental/reject") ||
               uri.contains("/repair/approve") ||
               uri.contains("/repair/reject");
    }

    /**
     * URI와 파라미터로부터 액션 정보 추출
     */
    private AdminActionInfo extractActionInfo(String uri, HttpServletRequest request) {
        AdminActionInfo info = new AdminActionInfo();
        
        // 기자재 관련
        if (uri.contains("/equipment/")) {
            info.targetTable = AdminLogDto.TargetTable.EQUIPMENTS;
            info.targetId = extractIdFromPath(uri, "/equipment/");
            
            if (uri.contains("/register")) {
                info.actionType = AdminLogDto.ActionType.CREATE_EQUIPMENT;
                info.description = "기자재 등록";
            } else if (uri.contains("/edit") || uri.contains("/update")) {
                info.actionType = AdminLogDto.ActionType.UPDATE_EQUIPMENT;
                info.description = "기자재 정보 수정";
            } else if (uri.contains("/delete")) {
                info.actionType = AdminLogDto.ActionType.DELETE_EQUIPMENT;
                info.description = "기자재 삭제";
            }
        }
        
        // 공지사항 관련
        else if (uri.contains("/notice/")) {
            info.targetTable = AdminLogDto.TargetTable.NOTICES;
            info.targetId = extractIdFromPath(uri, "/notice/");
            
            if (uri.contains("/write")) {
                info.actionType = AdminLogDto.ActionType.CREATE_NOTICE;
                info.description = "공지사항 작성";
            } else if (uri.contains("/update")) {
                info.actionType = AdminLogDto.ActionType.UPDATE_NOTICE;
                info.description = "공지사항 수정";
            } else if (uri.contains("/delete")) {
                info.actionType = AdminLogDto.ActionType.DELETE_NOTICE;
                info.description = "공지사항 삭제";
            }
        }
        
        // 사용자 관리 관련
        else if (uri.contains("/admin/users/")) {
            info.targetTable = AdminLogDto.TargetTable.USERS;
            info.targetId = extractIdFromPath(uri, "/admin/users/");
            
            if (uri.contains("/edit") || uri.contains("/update")) {
                info.actionType = AdminLogDto.ActionType.UPDATE_USER;
                info.description = "사용자 정보 수정";
            } else if (uri.contains("/delete")) {
                info.actionType = AdminLogDto.ActionType.DELETE_USER;
                info.description = "사용자 삭제";
            }
        }
        
        // 대여 승인/거절
        else if (uri.contains("/rental/")) {
            info.targetTable = AdminLogDto.TargetTable.EQUIPMENT_RENTALS;
            info.targetId = extractIdFromRequest(request, "rentalId");
            
            if (uri.contains("/approve")) {
                info.actionType = AdminLogDto.ActionType.APPROVE_RENTAL;
                info.description = "기자재 대여 승인";
            } else if (uri.contains("/reject")) {
                info.actionType = AdminLogDto.ActionType.REJECT_RENTAL;
                info.description = "기자재 대여 거절";
            }
        }
        
        // 수리 승인/거절
        else if (uri.contains("/repair/")) {
            info.targetTable = AdminLogDto.TargetTable.EQUIPMENT_REPAIRS;
            info.targetId = extractIdFromRequest(request, "repairId");
            
            if (uri.contains("/approve")) {
                info.actionType = AdminLogDto.ActionType.APPROVE_REPAIR;
                info.description = "기자재 수리 승인";
            } else if (uri.contains("/reject")) {
                info.actionType = AdminLogDto.ActionType.REJECT_REPAIR;
                info.description = "기자재 수리 거절";
            }
        }
        
        // 문의 답변
        else if (uri.contains("/inquiry/answer")) {
            info.targetTable = AdminLogDto.TargetTable.INQUIRIES;
            info.targetId = extractIdFromRequest(request, "inquiryId");
            info.actionType = AdminLogDto.ActionType.ANSWER_INQUIRY;
            info.description = "문의사항 답변 작성";
        }
        
        return info.actionType != null ? info : null;
    }

    /**
     * URI 경로에서 ID 추출
     */
    private Long extractIdFromPath(String uri, String basePath) {
        try {
            int baseIndex = uri.indexOf(basePath);
            if (baseIndex >= 0) {
                String afterBase = uri.substring(baseIndex + basePath.length());
                String[] parts = afterBase.split("/");
                if (parts.length > 0) {
                    return Long.valueOf(parts[0]);
                }
            }
        } catch (NumberFormatException e) {
            // ID 추출 실패시 null 반환
        }
        return null;
    }

    /**
     * 요청 파라미터에서 ID 추출
     */
    private Long extractIdFromRequest(HttpServletRequest request, String paramName) {
        try {
            String idStr = request.getParameter(paramName);
            if (idStr != null && !idStr.isEmpty()) {
                return Long.valueOf(idStr);
            }
        } catch (NumberFormatException e) {
            // ID 추출 실패시 null 반환
        }
        return null;
    }

    /**
     * 액션 타입에 따른 로그 레벨 결정
     */
    private AdminLogDto.LogLevel determineLogLevel(String actionType, boolean isSuccessful) {
        if (!isSuccessful) {
            return AdminLogDto.LogLevel.ERROR;
        }
        
        // 삭제 작업은 WARNING 레벨
        if (actionType.contains("DELETE")) {
            return AdminLogDto.LogLevel.WARN;
        }
        
        // 거절 작업도 WARNING 레벨
        if (actionType.contains("REJECT")) {
            return AdminLogDto.LogLevel.WARN;
        }
        
        return AdminLogDto.LogLevel.INFO;
    }

    /**
     * 액션 정보를 담는 내부 클래스
     */
    private static class AdminActionInfo {
        public String actionType;
        public String targetTable;
        public Long targetId;
        public String description;
    }
} 