package com.example.test.project;

import java.util.List;

public class ProjectDetailDto {
    private ProjectDto project;
    private List<ProjectMemberDto> members;
    private List<ProjectTaskDto> tasks;
    // 사용자 정보를 포함한 멤버 목록을 위한 새로운 DTO를 만들 수 있습니다.
    // 예: private List<ProjectMemberInfoDto> memberInfos;

    // Getters and Setters
    public ProjectDto getProject() {
        return project;
    }

    public void setProject(ProjectDto project) {
        this.project = project;
    }

    public List<ProjectMemberDto> getMembers() {
        return members;
    }

    public void setMembers(List<ProjectMemberDto> members) {
        this.members = members;
    }

    public List<ProjectTaskDto> getTasks() {
        return tasks;
    }

    public void setTasks(List<ProjectTaskDto> tasks) {
        this.tasks = tasks;
    }
} 