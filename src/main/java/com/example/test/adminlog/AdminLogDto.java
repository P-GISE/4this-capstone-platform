package com.example.test.adminlog;

import java.sql.Timestamp;

import lombok.Data;

@Data
public class AdminLogDto {
    private Long id;                    // 로그 고유 ID
    private Long adminId;               // 작업을 수행한 관리자 ID
    private String adminName;           // 관리자 이름 (조인으로 가져올 정보)
    private String actionType;          // 작업 유형
    private String targetTable;         // 작업 대상 테이블명
    private Long targetId;              // 작업 대상 데이터 ID
    private LogLevel logLevel;          // 로그 수준
    private Boolean isSuccessful;       // 작업 성공 여부
    private String httpMethod;          // HTTP 메서드
    private String requestUri;          // API 경로 또는 요청 URL
    private String beforeValue;         // 작업 이전 값
    private String afterValue;          // 작업 이후 값
    private String description;         // 상세 설명 또는 비고
    private String ipAddress;           // 관리자 IP 주소
    private String userAgent;           // 관리자 브라우저/기기 정보
    private Timestamp createdAt;        // 작업 수행 시각

    // 로그 수준 열거형
    public enum LogLevel {
        INFO, WARN, ERROR, CRITICAL
    }

    // 액션 타입 상수들
    public static class ActionType {
        public static final String CREATE_USER = "CREATE_USER";
        public static final String UPDATE_USER = "UPDATE_USER";
        public static final String DELETE_USER = "DELETE_USER";
        public static final String CREATE_EQUIPMENT = "CREATE_EQUIPMENT";
        public static final String UPDATE_EQUIPMENT = "UPDATE_EQUIPMENT";
        public static final String DELETE_EQUIPMENT = "DELETE_EQUIPMENT";
        public static final String CREATE_NOTICE = "CREATE_NOTICE";
        public static final String UPDATE_NOTICE = "UPDATE_NOTICE";
        public static final String DELETE_NOTICE = "DELETE_NOTICE";
        public static final String APPROVE_RENTAL = "APPROVE_RENTAL";
        public static final String REJECT_RENTAL = "REJECT_RENTAL";
        public static final String APPROVE_REPAIR = "APPROVE_REPAIR";
        public static final String REJECT_REPAIR = "REJECT_REPAIR";
        public static final String ANSWER_INQUIRY = "ANSWER_INQUIRY";
        public static final String LOGIN = "LOGIN";
        public static final String LOGOUT = "LOGOUT";
        public static final String SYSTEM_CONFIG = "SYSTEM_CONFIG";
    }

    // 대상 테이블 상수들
    public static class TargetTable {
        public static final String USERS = "users";
        public static final String EQUIPMENTS = "equipments";
        public static final String NOTICES = "notices";
        public static final String EQUIPMENT_RENTALS = "equipment_rentals";
        public static final String EQUIPMENT_REPAIRS = "equipment_repairs";
        public static final String INQUIRIES = "inquiries";
    }

    /**
     * 로그 레벨의 문자열 표현을 반환
     */
    public String getLogLevelDisplay() {
        if (logLevel == null) return "INFO";
        switch (logLevel) {
            case INFO:
                return "정보";
            case WARN:
                return "경고";
            case ERROR:
                return "오류";
            case CRITICAL:
                return "치명적";
            default:
                return "정보";
        }
    }

    /**
     * 액션 타입의 한글 표현을 반환
     */
    public String getActionTypeDisplay() {
        if (actionType == null) return "알 수 없음";
        switch (actionType) {
            case ActionType.CREATE_USER:
                return "사용자 생성";
            case ActionType.UPDATE_USER:
                return "사용자 수정";
            case ActionType.DELETE_USER:
                return "사용자 삭제";
            case ActionType.CREATE_EQUIPMENT:
                return "기자재 등록";
            case ActionType.UPDATE_EQUIPMENT:
                return "기자재 수정";
            case ActionType.DELETE_EQUIPMENT:
                return "기자재 삭제";
            case ActionType.CREATE_NOTICE:
                return "공지사항 작성";
            case ActionType.UPDATE_NOTICE:
                return "공지사항 수정";
            case ActionType.DELETE_NOTICE:
                return "공지사항 삭제";
            case ActionType.APPROVE_RENTAL:
                return "대여 승인";
            case ActionType.REJECT_RENTAL:
                return "대여 거절";
            case ActionType.APPROVE_REPAIR:
                return "수리 승인";
            case ActionType.REJECT_REPAIR:
                return "수리 거절";
            case ActionType.ANSWER_INQUIRY:
                return "문의 답변";
            case ActionType.LOGIN:
                return "로그인";
            case ActionType.LOGOUT:
                return "로그아웃";
            case ActionType.SYSTEM_CONFIG:
                return "시스템 설정";
            default:
                return actionType;
        }
    }

    /**
     * 성공/실패 상태의 문자열 표현
     */
    public String getSuccessStatusDisplay() {
        if (isSuccessful == null) return "알 수 없음";
        return isSuccessful ? "성공" : "실패";
    }

    /**
     * 상태별 CSS 클래스 반환
     */
    public String getStatusCssClass() {
        if (isSuccessful == null) return "text-muted";
        return isSuccessful ? "text-success" : "text-danger";
    }

    /**
     * 로그 레벨별 CSS 클래스 반환
     */
    public String getLogLevelCssClass() {
        if (logLevel == null) return "badge-secondary";
        switch (logLevel) {
            case INFO:
                return "badge-info";
            case WARN:
                return "badge-warning";
            case ERROR:
                return "badge-danger";
            case CRITICAL:
                return "badge-dark";
            default:
                return "badge-secondary";
        }
    }
} 