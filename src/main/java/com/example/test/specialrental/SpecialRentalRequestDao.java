package com.example.test.specialrental;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface SpecialRentalRequestDao {
    
    // ================================
    // 기본 CRUD 작업
    // ================================
    
    /**
     * 특별 대여 신청 등록
     */
    int insertSpecialRequest(SpecialRentalRequestDto dto);
    
    /**
     * 특별 대여 신청 수정
     */
    int updateSpecialRequest(SpecialRentalRequestDto dto);
    
    /**
     * 특별 대여 신청 삭제
     */
    int deleteSpecialRequest(Long id);
    
    /**
     * ID로 특별 대여 신청 조회
     */
    SpecialRentalRequestDto selectSpecialRequestById(Long id);
    
    // ================================
    // 목록 조회
    // ================================
    
    /**
     * 모든 특별 대여 신청 목록 조회 (관리자용)
     */
    List<SpecialRentalRequestDto> selectAllSpecialRequests(@Param("params") Map<String, Object> params);
    
    /**
     * 사용자별 특별 대여 신청 목록 조회
     */
    List<SpecialRentalRequestDto> selectSpecialRequestsByUser(@Param("userId") Long userId, @Param("params") Map<String, Object> params);
    
    /**
     * 승인 대기중인 특별 대여 신청 목록 조회
     */
    List<SpecialRentalRequestDto> selectPendingSpecialRequests(@Param("params") Map<String, Object> params);
    
    /**
     * 긴급 신청 목록 조회
     */
    List<SpecialRentalRequestDto> selectEmergencyRequests(@Param("params") Map<String, Object> params);
    
    // ================================
    // 개수 조회
    // ================================
    
    /**
     * 전체 특별 대여 신청 개수
     */
    int countAllSpecialRequests(@Param("params") Map<String, Object> params);
    
    /**
     * 사용자별 특별 대여 신청 개수
     */
    int countSpecialRequestsByUser(@Param("userId") Long userId, @Param("params") Map<String, Object> params);
    
    /**
     * 승인 대기중인 특별 대여 신청 개수
     */
    int countPendingSpecialRequests(@Param("params") Map<String, Object> params);
    
    /**
     * 긴급 신청 개수
     */
    int countEmergencyRequests(@Param("params") Map<String, Object> params);
    
    // ================================
    // 상태 변경
    // ================================
    
    /**
     * 특별 대여 신청 승인
     */
    int approveSpecialRequest(@Param("id") Long id, @Param("reviewedBy") Long reviewedBy, @Param("approvalReason") String approvalReason);
    
    /**
     * 특별 대여 신청 반려
     */
    int rejectSpecialRequest(@Param("id") Long id, @Param("reviewedBy") Long reviewedBy, @Param("rejectionReason") String rejectionReason);
    
    /**
     * 특별 대여 신청 취소
     */
    int cancelSpecialRequest(@Param("id") Long id);
    
    /**
     * 상태 변경
     */
    int updateSpecialRequestStatus(@Param("id") Long id, @Param("status") String status, @Param("reviewedBy") Long reviewedBy);
    
    // ================================
    // 검증 및 제한 확인
    // ================================
    
    /**
     * 사용자의 동일 기자재에 대한 진행중인 특별 신청 개수
     */
    int countActiveSameEquipmentRequests(@Param("userId") Long userId, @Param("equipmentId") Long equipmentId);
    
    /**
     * 사용자의 진행중인 특별 신청 총 개수
     */
    int countActiveRequestsByUser(@Param("userId") Long userId);
    
    /**
     * 기자재별 승인 대기중인 특별 신청 개수
     */
    int countPendingRequestsByEquipment(@Param("equipmentId") Long equipmentId);
    
    // ================================
    // 통계 및 분석
    // ================================
    
    /**
     * 월별 특별 신청 통계
     */
    List<Map<String, Object>> getMonthlyRequestStats(@Param("year") Integer year);
    
    /**
     * 기자재별 특별 신청 통계
     */
    List<Map<String, Object>> getEquipmentRequestStats(@Param("params") Map<String, Object> params);
    
    /**
     * 승인율 통계
     */
    Map<String, Object> getApprovalRateStats(@Param("params") Map<String, Object> params);
    
    // ================================
    // 첨부파일 관리
    // ================================
    
    /**
     * 첨부파일 등록
     */
    int insertAttachment(SpecialRentalAttachmentDto attachment);
    
    /**
     * 첨부파일 삭제
     */
    int deleteAttachment(Long attachmentId);
    
    /**
     * 특별 신청의 첨부파일 목록 조회
     */
    List<SpecialRentalAttachmentDto> selectAttachmentsByRequestId(Long requestId);
    
    /**
     * 첨부파일 조회
     */
    SpecialRentalAttachmentDto selectAttachmentById(Long attachmentId);
    
    // ================================
    // 로그 관리
    // ================================
    
    /**
     * 처리 로그 등록
     */
    int insertLog(SpecialRentalLogDto log);
    
    /**
     * 특별 신청의 처리 로그 조회
     */
    List<SpecialRentalLogDto> selectLogsByRequestId(Long requestId);
} 