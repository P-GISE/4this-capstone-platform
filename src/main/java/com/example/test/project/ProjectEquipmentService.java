package com.example.test.project;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ProjectEquipmentService {
    
    @Autowired
    private ProjectEquipmentDao projectEquipmentDao;
    
    /**
     * 프로젝트에 기자재 추가
     */
    public int addEquipmentToProject(ProjectEquipmentDto projectEquipment) {
        // 중복 등록 방지
        int existingCount = projectEquipmentDao.countByProjectIdAndRentalId(
            projectEquipment.getProjectId(), 
            projectEquipment.getRentalId()
        );
        
        if (existingCount > 0) {
            throw new IllegalArgumentException("이미 프로젝트에 등록된 기자재입니다.");
        }
        
        return projectEquipmentDao.insertProjectEquipment(projectEquipment);
    }
    
    /**
     * 프로젝트별 등록된 기자재 목록 조회
     */
    public List<ProjectEquipmentDto> getProjectEquipments(Long projectId) {
        return projectEquipmentDao.selectProjectEquipmentsByProjectId(projectId);
    }
    
    /**
     * 프로젝트에서 기자재 제거
     */
    public int removeEquipmentFromProject(Long id) {
        return projectEquipmentDao.deleteProjectEquipment(id);
    }
    
    /**
     * 사용자가 프로젝트에 등록 가능한 대여중인 기자재 목록 조회
     */
    public List<ProjectEquipmentDto> getAvailableEquipmentsForProject(Long projectId, Long userId) {
        return projectEquipmentDao.selectAvailableEquipmentsForProject(projectId, userId);
    }
    
    /**
     * 프로젝트 멤버들이 대여중이면서 프로젝트에 등록 가능한 기자재 목록
     */
    public List<ProjectEquipmentDto> getAvailableEquipmentsForProjectMembers(Long projectId, List<Long> memberIds) {
        if (memberIds == null || memberIds.isEmpty()) {
            return new ArrayList<>();
        }
        return projectEquipmentDao.selectAvailableEquipmentsForProjectMembers(projectId, memberIds);
    }
    
    /**
     * 특정 대여건이 프로젝트에 이미 등록되어 있는지 확인
     */
    public boolean isAlreadyRegistered(Long projectId, Long rentalId) {
        return projectEquipmentDao.countByProjectIdAndRentalId(projectId, rentalId) > 0;
    }
} 