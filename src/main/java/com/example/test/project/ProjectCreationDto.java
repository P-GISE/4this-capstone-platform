package com.example.test.project;

public class ProjectCreationDto {

    // Project info
    private String projectName;
    private String projectDescription;

    // Team info
    private String teamName;
    private String teamLeaderUsername;
    private String meetingType; // "ON" or "OFF"

    // Team members info
    private String teamMemberUsernames;

    // Getters and Setters
    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public String getProjectDescription() {
        return projectDescription;
    }

    public void setProjectDescription(String projectDescription) {
        this.projectDescription = projectDescription;
    }

    public String getTeamName() {
        return teamName;
    }

    public void setTeamName(String teamName) {
        this.teamName = teamName;
    }

    public String getTeamLeaderUsername() {
        return teamLeaderUsername;
    }

    public void setTeamLeaderUsername(String teamLeaderUsername) {
        this.teamLeaderUsername = teamLeaderUsername;
    }

    public String getMeetingType() {
        return meetingType;
    }

    public void setMeetingType(String meetingType) {
        this.meetingType = meetingType;
    }

    public String getTeamMemberUsernames() {
        return teamMemberUsernames;
    }

    public void setTeamMemberUsernames(String teamMemberUsernames) {
        this.teamMemberUsernames = teamMemberUsernames;
    }
} 