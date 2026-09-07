package com.example.test.project;

import com.example.test.project.mapper.ProjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class ProjectDao {

    @Autowired
    private ProjectMapper projectMapper;

    public void createProject(ProjectDto project) {
        projectMapper.createProject(project);
    }

    public ProjectDto findProjectById(Long id) {
        return projectMapper.findProjectById(id);
    }

    public List<ProjectDto> findAllProjects() {
        return projectMapper.findAllProjects();
    }

    public void updateProject(ProjectDto project) {
        projectMapper.updateProject(project);
    }

    public void deleteProject(Long id) {
        projectMapper.deleteProject(id);
    }

    public void addProjectMember(ProjectMemberDto member) {
        projectMapper.addProjectMember(member);
    }

    public List<ProjectMemberDto> findMembersByProjectId(Long projectId) {
        return projectMapper.findMembersByProjectId(projectId);
    }

    public ProjectMemberDto findProjectMemberByUserIdAndProjectId(Long userId, Long projectId) {
        return projectMapper.findProjectMemberByUserIdAndProjectId(userId, projectId);
    }

    public void deleteProjectMember(Long projectId, Long userId) {
        projectMapper.deleteProjectMember(projectId, userId);
    }

    public void approveProjectMember(Long projectId, Long userId) {
        projectMapper.approveProjectMember(projectId, userId);
    }
    
    public void updateMemberRole(Long projectId, Long userId, String newRole) {
        projectMapper.updateMemberRole(projectId, userId, newRole);
    }

    public void createTask(ProjectTaskDto task) {
        projectMapper.createTask(task);
    }

    public List<ProjectTaskDto> findTasksByProjectId(Long projectId) {
        return projectMapper.findTasksByProjectId(projectId);
    }

    public void updateTask(ProjectTaskDto task) {
        projectMapper.updateTask(task);
    }

    public void deleteTask(Long id) {
        projectMapper.deleteTask(id);
    }

    public List<ProjectDto> findProjectsByUserId(Long userId) {
        return projectMapper.findProjectsByUserId(userId);
    }

    public void createReport(ProjectReportDto report) {
        projectMapper.createReport(report);
    }

    public List<ProjectReportDto> findReportsByProjectId(Long projectId) {
        return projectMapper.findReportsByProjectId(projectId);
    }

    public ProjectReportDto findReportById(Long reportId) {
        return projectMapper.findReportById(reportId);
    }
} 