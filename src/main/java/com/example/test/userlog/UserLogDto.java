package com.example.test.userlog;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 사용자 접속 로그 DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserLogDto {
    
    // 로그인 타입 상수
    public static final String LOGIN = "LOGIN";
    public static final String LOGOUT = "LOGOUT"; 
    public static final String FAILED = "FAILED";
    
    // 로그인 방법 상수
    public static final String WEB = "WEB";
    public static final String MOBILE = "MOBILE";
    public static final String API = "API";
    
    private Long id;
    private Long userId;
    private String userName;        // JOIN으로 가져올 사용자명
    private String userRole;        // JOIN으로 가져올 사용자 역할
    private String loginType;       // LOGIN, LOGOUT, FAILED
    private String loginMethod;     // WEB, MOBILE, API
    private String sessionId;
    private String ipAddress;
    private String location;
    private String userAgent;
    private Boolean success;
    private String failureReason;
    private LocalDateTime createdAt;
    
    /**
     * 로그인 타입을 한글로 표시
     */
    public String getLoginTypeDisplay() {
        if (loginType == null) return "";
        switch (loginType) {
            case LOGIN:
                return "로그인";
            case LOGOUT:
                return "로그아웃";
            case FAILED:
                return "로그인 실패";
            default:
                return loginType;
        }
    }
    
    /**
     * 로그인 방법을 한글로 표시
     */
    public String getLoginMethodDisplay() {
        if (loginMethod == null) return "";
        switch (loginMethod) {
            case WEB:
                return "웹";
            case MOBILE:
                return "모바일";
            case API:
                return "API";
            default:
                return loginMethod;
        }
    }
    
    /**
     * 성공 여부를 한글로 표시
     */
    public String getSuccessDisplay() {
        if (success == null) return "";
        return success ? "성공" : "실패";
    }
    
    /**
     * 생성일시를 포맷된 문자열로 반환
     */
    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        return createdAt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }
    
    /**
     * 생성일자를 포맷된 문자열로 반환
     */
    public String getFormattedCreatedDate() {
        if (createdAt == null) return "";
        return createdAt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }
    
    /**
     * 생성시간을 포맷된 문자열로 반환
     */
    public String getFormattedCreatedTime() {
        if (createdAt == null) return "";
        return createdAt.format(DateTimeFormatter.ofPattern("HH:mm:ss"));
    }
    
    /**
     * 사용자 정보 표시 (이름 + 역할)
     */
    public String getUserDisplay() {
        if (userName == null && userRole == null) {
            return userId != null ? "사용자 #" + userId : "미상";
        }
        StringBuilder sb = new StringBuilder();
        if (userName != null) {
            sb.append(userName);
        }
        if (userRole != null) {
            sb.append(" (").append(getRoleDisplay()).append(")");
        }
        return sb.toString();
    }
    
    /**
     * 역할을 한글로 표시
     */
    public String getRoleDisplay() {
        if (userRole == null) return "";
        switch (userRole) {
            case "ADMIN":
                return "관리자";
            case "STUDENT":
                return "학생";
            case "STAFF":
                return "교직원";
            case "ASSISTANT":
                return "조교";
            case "PROFESSOR":
                return "교수";
            default:
                return userRole;
        }
    }
    
    /**
     * IP 주소 마스킹 (개인정보 보호)
     */
    public String getMaskedIpAddress() {
        if (ipAddress == null || ipAddress.isEmpty()) return "";
        String[] parts = ipAddress.split("\\.");
        if (parts.length == 4) {
            return parts[0] + "." + parts[1] + "." + parts[2] + ".***";
        }
        return ipAddress;
    }
    
    /**
     * User Agent 요약 (브라우저 정보만 추출)
     */
    public String getUserAgentSummary() {
        if (userAgent == null || userAgent.isEmpty()) return "";
        
        // 간단한 브라우저 감지
        if (userAgent.contains("Chrome")) return "Chrome";
        if (userAgent.contains("Firefox")) return "Firefox";
        if (userAgent.contains("Safari")) return "Safari";
        if (userAgent.contains("Edge")) return "Edge";
        if (userAgent.contains("Opera")) return "Opera";
        
        return "기타";
    }
} 