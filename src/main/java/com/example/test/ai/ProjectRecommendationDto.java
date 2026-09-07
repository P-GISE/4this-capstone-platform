package com.example.test.ai;

import java.time.LocalDateTime;
import java.util.List;

public class ProjectRecommendationDto {
    private Long id;
    private Long userId;
    private List<String> equipments;
    private Integer teamSize;
    private String question;
    private String recommendation;
    private String projectType;
    private String difficulty;
    private Integer estimatedDuration; // 예상 소요 기간 (주)
    private LocalDateTime createdAt = LocalDateTime.now();

    // 기본 생성자
    public ProjectRecommendationDto() {}

    // 생성자
    public ProjectRecommendationDto(Long userId, List<String> equipments, Integer teamSize, String question) {
        this.userId = userId;
        this.equipments = equipments;
        this.teamSize = teamSize;
        this.question = question;
        this.createdAt = LocalDateTime.now();
    }

    public ProjectRecommendationDto(Long userId, List<String> equipments, Integer teamSize, 
                                  String question, String recommendation, String projectType) {
        this.userId = userId;
        this.equipments = equipments;
        this.teamSize = teamSize;
        this.question = question;
        this.recommendation = recommendation;
        this.projectType = projectType;
        this.createdAt = LocalDateTime.now();
    }

    // Getter and Setter methods
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public List<String> getEquipments() {
        return equipments;
    }

    public void setEquipments(List<String> equipments) {
        this.equipments = equipments;
    }

    public Integer getTeamSize() {
        return teamSize;
    }

    public void setTeamSize(Integer teamSize) {
        this.teamSize = teamSize;
    }

    public String getQuestion() {
        return question;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public String getRecommendation() {
        return recommendation;
    }

    public void setRecommendation(String recommendation) {
        this.recommendation = recommendation;
    }

    public String getProjectType() {
        return projectType;
    }

    public void setProjectType(String projectType) {
        this.projectType = projectType;
    }

    public String getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }

    public Integer getEstimatedDuration() {
        return estimatedDuration;
    }

    public void setEstimatedDuration(Integer estimatedDuration) {
        this.estimatedDuration = estimatedDuration;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}