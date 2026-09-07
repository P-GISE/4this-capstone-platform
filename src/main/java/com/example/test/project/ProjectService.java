package com.example.test.project;

import java.util.List;

import org.springframework.core.io.Resource;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

public interface ProjectService {
    Long createProject(ProjectCreationDto projectCreationDto, Long creatorId);
    List<ProjectDto> getAllProjects();
    ProjectDetailDto getProjectDetail(Long projectId);
    List<ProjectDto> getProjectsForUser(Long userId);
    void updateProject(ProjectDto projectDto);
    void deleteProject(Long projectId);
    void respondToInvitation(Long projectId, Long userId, boolean accept);
    void addProjectMember(ProjectMemberDto projectMemberDto);
    void removeProjectMember(Long projectId, Long userId);
    ProjectTaskDto createTask(ProjectTaskDto projectTaskDto);
    void updateTask(ProjectTaskDto projectTaskDto);
    void deleteTask(Long taskId);
    Long createProjectWithMembers(
        String projectName,
        String projectDescription,
        String teamLeaderId,
        String teamLeaderName,
        List<String> memberIds,
        List<String> memberNames,
        Long creatorId
    );
    
    // ArchiveController에서 사용하는 메소드들 추가
    ProjectDto getProjectById(Long projectId);
    List<ProjectDto> getPublicProjects();
    
    // 보고서 관련 메소드 추가
    String uploadReport(Long projectId, MultipartFile file, Long uploaderId);
    List<ProjectReportDto> getReportsByProjectId(Long projectId);
    ResponseEntity<Resource> downloadReport(Long reportId);
    
    // 팀원 관리 메소드 추가
    void updateMemberRole(Long projectId, Long userId, String newRole);
    void approveMember(Long projectId, Long userId);
    void rejectMember(Long projectId, Long userId);
    boolean isProjectLeader(Long projectId, Long userId);
    
    // 초대 응답 상태 확인 메서드 추가
    String getInvitationStatus(Long projectId, Long userId);
} 