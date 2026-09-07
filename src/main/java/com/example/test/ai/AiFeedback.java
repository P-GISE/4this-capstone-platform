package com.example.test.ai;

import java.time.LocalDateTime;

public class AiFeedback {
    private Long id;
    private Long answerId;
    private Long userId;
    private Integer score; // 1~5점 척도
    private String comment;
    private String feedbackType; // POSITIVE, NEGATIVE, CONFUSING, OFF_TOPIC
    private Boolean isRelevant;
    private Boolean requestedEdit = false;
    private LocalDateTime createdAt = LocalDateTime.now();

    // 기본 생성자
    public AiFeedback() {}

    // 생성자
    public AiFeedback(Long answerId, Long userId, Integer score) {
        this.answerId = answerId;
        this.userId = userId;
        this.score = score;
    }

    public AiFeedback(Long answerId, Long userId, Integer score, String comment, String feedbackType, Boolean isRelevant, Boolean requestedEdit) {
        this.answerId = answerId;
        this.userId = userId;
        this.score = score;
        this.comment = comment;
        this.feedbackType = feedbackType;
        this.isRelevant = isRelevant;
        this.requestedEdit = requestedEdit;
    }

    // Getter and Setter methods
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getAnswerId() {
        return answerId;
    }

    public void setAnswerId(Long answerId) {
        this.answerId = answerId;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Integer getScore() {
        return score;
    }

    public void setScore(Integer score) {
        this.score = score;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getFeedbackType() {
        return feedbackType;
    }

    public void setFeedbackType(String feedbackType) {
        this.feedbackType = feedbackType;
    }

    public Boolean getIsRelevant() {
        return isRelevant;
    }

    public void setIsRelevant(Boolean isRelevant) {
        this.isRelevant = isRelevant;
    }

    public Boolean getRequestedEdit() {
        return requestedEdit;
    }

    public void setRequestedEdit(Boolean requestedEdit) {
        this.requestedEdit = requestedEdit;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
} 