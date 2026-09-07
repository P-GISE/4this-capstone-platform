package com.example.test.equipmentrepair;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface EquipmentRepairDao {

    /**
     * 수리 요청 등록
     */
    int insertRepair(EquipmentRepairDto repair);
    
    List<EquipmentRepairDto> selectRepairsByUser(Long userId);

    Boolean existsByRentalId(@Param("rentalId") Long rentalId);

    int updateRepairStatus(EquipmentRepairDto dto);
    
    EquipmentRepairDto selectRepairById(Long id);
    
    List<EquipmentRepairDto> selectPendingRepairs();
    List<EquipmentRepairDto> selectAllRepairs();

    // DAO
    void updateStatus(@Param("id") Long id,
                    @Param("status") String status,
                    @Param("handledBy") Long handledBy,
                    @Param("rejectionReason") String rejectionReason);
    EquipmentRepairDto selectLatestByRentalId(Long rentalId); // <-- 추가    
    /**
     * 향후 구현: 수리 요청 상태 변경, 목록 조회 등
     */
    // int updateRepairStatus(@Param("id") Long id, @Param("status") String status);
    // List<EquipmentRepairDto> selectRepairsByUser(Long userId);
    // List<EquipmentRepairDto> selectAllRepairs();
} 
