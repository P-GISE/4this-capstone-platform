package com.example.test.equipment;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface EquipmentDao {

    /** 전체 기자재 목록 조회 */
    List<EquipmentDto> selectEquipmentList();

    /** 검색 조건과 페이지네이션을 적용한 기자재 목록 조회 */
    List<EquipmentDto> selectEquipmentListWithPaging(Map<String, Object> searchParams);

    /** 검색 조건에 맞는 기자재 총 개수 조회 */
    int selectEquipmentCount(Map<String, Object> searchParams);

    /** 단일 기자재 조회 */
    EquipmentDto selectEquipmentById(@Param("id") Long id);

    /** 기자재 등록 */
    int insertEquipment(EquipmentDto equipment);

    /** 기자재 정보 수정 */
    int updateEquipment(EquipmentDto equipment);

    /** 기자재 삭제 */
    int deleteEquipment(@Param("id") Long id);

    /**
     * available_quantity 칼럼을 amount만큼 차감
     * WHERE 절에 available_quantity >= amount 조건을 걸어 두었으므로
     * 재고가 부족하면 업데이트가 이루어지지 않음.
     */
    int decrementAvailableQuantity(
        @Param("equipmentId") Long equipmentId,
        @Param("amount")      int    amount
    );

    int updateStatus(EquipmentDto dto);

    int incrementAvailableQuantity(EquipmentDto dto);

    void updateStatus(@Param("equipmentId") Long equipmentId, @Param("status") String status);

    List<EquipmentDto> selectAllEquipment();

    /**
     * 최신 등록된 기자재 목록 조회
     * @param limit 조회할 개수
     * @return 최신 등록된 기자재 목록
     */
    List<EquipmentDto> selectRecentEquipments(@Param("limit") int limit);
}