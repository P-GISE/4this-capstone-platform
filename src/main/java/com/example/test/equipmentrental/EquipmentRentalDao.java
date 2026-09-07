package com.example.test.equipmentrental;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.test.equipmentrepair.EquipmentRepairDto;

@Mapper
public interface EquipmentRentalDao {

    // 1) 전체 대여 내역 조회
    List<EquipmentRentalDto> selectRentalList();

    // 2) ID로 단건 조회 (승인 전에 request 정보 확인용)
    EquipmentRentalDto selectRentalById(Long id);

    // 3) 특정 기자재의 대여 내역 조회
    List<EquipmentRentalDto> selectRentalsByEquipment(Long equipmentId);

    // 4) 대여 정보 INSERT (학생 대여 신청)
    int insertRental(EquipmentRentalDto rental);

    // 5) 반납 처리 (return_date, status 업데이트)
    int updateReturnById(EquipmentRentalDto rental);

    // 6) 대여 상태만 업데이트 (연장, 취소 등)
    int updateRentalStatus(EquipmentRentalDto rental);

    // 7) 대여 내역 DELETE
    int deleteRental(Long id);

    // 8) 아직 승인되지 않은(=isApproved=false) 목록 조회
    List<EquipmentRentalDto> selectPendingRentals();

    // 9) 승인 처리 (DTO에 id, approvedBy, status 전달)
    int approveRentalById(EquipmentRentalDto rental);

    // (추가) “나의 대여 내역” 조회 (userId 기준)
    List<EquipmentRentalDto> selectRentalsByUser(@Param("userId") Long userId);

    EquipmentRentalDto selectRentalByUserAndEquipment(
        @Param("userId") Long userId,
        @Param("equipmentId") Long equipmentId
    );

    // 현재 대여 중인 기자재 수 (반납일 NULL)
    int countCurrentRentalsByUser(@Param("userId") Long userId);

    // 연체 중인 기자재 수 (반납일 NULL && 반납예정일 < NOW)
    int countOverdueRentalsByUser(@Param("userId") Long userId);

    // 전체 대여 횟수
    int countTotalRentalsByUser(@Param("userId") Long userId);

    // 특정 유저가 특정 기자재를 대여 중인 건수 (반납 안 된 상태만)
    int countActiveRentalsByUserAndEquipment(@Param("userId") Long userId,
                                            @Param("equipmentId") Long equipmentId);

    List<EquipmentRentalDto> selectCurrentRentalsByUser(Long userId);

    int rejectRentalWithReason(EquipmentRentalDto dto);
    // EquipmentRepairDao.java
    List<EquipmentRepairDto> selectAllRepairs();
    
    // 프로젝트 멤버들의 현재 대여중인 기자재 목록 조회
    List<EquipmentRentalDto> selectCurrentRentalsByUsers(@Param("userIds") List<Long> userIds);

}
