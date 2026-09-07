package com.example.test.project;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ProjectEquipmentDao {
    
    /**
     * 프로젝트에 기자재 추가
     */
    int insertProjectEquipment(ProjectEquipmentDto projectEquipment);
    
    /**
     * 프로젝트별 등록된 기자재 목록 조회 (상세 정보 포함)
     */
    List<ProjectEquipmentDto> selectProjectEquipmentsByProjectId(@Param("projectId") Long projectId);
    
    /**
     * 프로젝트에서 기자재 제거
     */
    int deleteProjectEquipment(@Param("id") Long id);
    
    /**
     * 특정 프로젝트의 특정 대여건이 이미 등록되어 있는지 확인
     */
    int countByProjectIdAndRentalId(@Param("projectId") Long projectId, @Param("rentalId") Long rentalId);
    
    /**
     * 사용자가 프로젝트에 등록 가능한 대여중인 기자재 목록 조회
     * (현재 대여중이면서 아직 프로젝트에 등록되지 않은 기자재)
     */
    List<ProjectEquipmentDto> selectAvailableEquipmentsForProject(
        @Param("projectId") Long projectId, 
        @Param("userId") Long userId
    );
    
    /**
     * 프로젝트 멤버들이 대여중이면서 프로젝트에 등록 가능한 기자재 목록
     */
    List<ProjectEquipmentDto> selectAvailableEquipmentsForProjectMembers(
        @Param("projectId") Long projectId, 
        @Param("memberIds") List<Long> memberIds
    );
} 