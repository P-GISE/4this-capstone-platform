package com.example.test.project.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.test.project.ProjectDto;
import com.example.test.project.ProjectMemberDto;
import com.example.test.project.ProjectReportDto;
import com.example.test.project.ProjectTaskDto;

@Mapper
public interface ProjectMapper {
    // Project
    void createProject(ProjectDto project);
    ProjectDto findProjectById(@Param("id") Long id);
    List<ProjectDto> findAllProjects();
    void updateProject(ProjectDto project);
    void deleteProject(@Param("id") Long id);

    // Project Members
    void addProjectMember(ProjectMemberDto member);
    List<ProjectMemberDto> findMembersByProjectId(@Param("projectId") Long projectId);
    ProjectMemberDto findProjectMemberByUserIdAndProjectId(@Param("userId") Long userId, @Param("projectId") Long projectId);
    void deleteProjectMember(@Param("projectId") Long projectId, @Param("userId") Long userId);
    void approveProjectMember(@Param("projectId") Long projectId, @Param("userId") Long userId);
    void updateMemberRole(@Param("projectId") Long projectId, @Param("userId") Long userId, @Param("newRole") String newRole);

    // Project Tasks
    void createTask(ProjectTaskDto task);
    List<ProjectTaskDto> findTasksByProjectId(@Param("projectId") Long projectId);
    void updateTask(ProjectTaskDto task);
    void deleteTask(@Param("id") Long id);

    // User's Projects
    List<ProjectDto> findProjectsByUserId(@Param("userId") Long userId);

    // Project Reports
    void createReport(ProjectReportDto report);
    List<ProjectReportDto> findReportsByProjectId(@Param("projectId") Long projectId);
    ProjectReportDto findReportById(@Param("reportId") Long reportId);
} 