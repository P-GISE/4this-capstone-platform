package com.example.test.equipmentreservation;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface EquipmentReservationDao {

    // 예약 등록
    int insertReservation(EquipmentReservationDto reservation);

    // 특정 기자재의 예약 리스트 (최신순 정렬)
    List<EquipmentReservationDto> selectReservationsByEquipment(@Param("equipmentId") Long equipmentId);

    // 특정 유저의 예약 리스트
    List<EquipmentReservationDto> selectReservationsByUser(@Param("userId") Long userId);

    // 특정 기자재에 대해 사용자의 예약 존재 여부 확인
    boolean existsByUserAndEquipment(@Param("userId") Long userId, @Param("equipmentId") Long equipmentId);

    // 예약 삭제
    int deleteReservationById(@Param("id") Long id);
    
    // 현재 예약중인 기자재 수
    int countActiveReservationsByUser(@Param("userId") Long userId);
}
