package com.example.test.equipment;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class EquipmentService {
    
    @Autowired
    private EquipmentDao equipmentDao;
    
    public List<EquipmentDto> getEquipmentList() {
        return equipmentDao.selectEquipmentList();
    }
    
    /**
     * 검색 조건과 페이지네이션을 적용한 기자재 목록 조회
     */
    public List<EquipmentDto> getEquipmentListWithPaging(Map<String, Object> searchParams) {
        return equipmentDao.selectEquipmentListWithPaging(searchParams);
    }
    
    /**
     * 검색 조건에 맞는 기자재 총 개수 조회
     */
    public int getEquipmentCount(Map<String, Object> searchParams) {
        return equipmentDao.selectEquipmentCount(searchParams);
    }
    
    public EquipmentDto getEquipmentById(Long id) {
        return equipmentDao.selectEquipmentById(id);
    }
    
    public int createEquipment(EquipmentDto equipment) {
        return equipmentDao.insertEquipment(equipment);
    }
    
    public int updateEquipment(EquipmentDto equipment) {
        return equipmentDao.updateEquipment(equipment);
    }
    
    public int deleteEquipment(Long id) {
        return equipmentDao.deleteEquipment(id);
    }

    /**
     * 승인 시 재고를 차감하려고 호출하는 메서드
     * @return 1이면 정상 차감, 0이면 실패 (재고 부족 등)
     */
    public int decrementAvailableQuantity(Long equipmentId, int amount) {
        return equipmentDao.decrementAvailableQuantity(equipmentId, amount);
    }    

    public int markAsDamaged(Long equipmentId) {
        EquipmentDto dto = new EquipmentDto();
        dto.setId(equipmentId);
        dto.setStatus("DAMAGED");  // 상태 ENUM 또는 문자열

        return equipmentDao.updateStatus(dto);  // updateStatus는 DAO에 구현 필요
    }
    
    public int incrementAvailableQuantity(Long equipmentId, int quantity) {
        EquipmentDto dto = new EquipmentDto();
        dto.setId(equipmentId);
        dto.setAvailableQuantity(quantity); // 증가 수량

        return equipmentDao.incrementAvailableQuantity(dto); // 반드시 DAO에 존재해야 함
    }
    
    public List<EquipmentDto> getAllEquipment() {
        return equipmentDao.selectAllEquipment(); // DAO에서 전체 기자재 조회하는 메서드 호출
    }
    
    public int updateEquipmentStatus(Long equipmentId, String status) {
        EquipmentDto dto = new EquipmentDto();
        dto.setId(equipmentId);
        dto.setStatus(status);
        return equipmentDao.updateStatus(dto);
    }

    /**
     * 최신 등록된 기자재 목록 조회
     * @param limit 조회할 개수
     * @return 최신 등록된 기자재 목록
     */
    public List<EquipmentDto> getRecentEquipments(int limit) {
        return equipmentDao.selectRecentEquipments(limit);
    }
}