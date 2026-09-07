package com.example.test.ai;

import java.time.LocalDateTime;

public class TechnicalQuestionDto {
    private Long id;
    private String userId;
    private String question;
    private String answer;
    private LocalDateTime createdAt;

    // 기본 생성자
    public TechnicalQuestionDto() {}

    // 생성자
    public TechnicalQuestionDto(String userId, String question, String answer) {
        this.userId = userId;
        this.question = question;
        this.answer = answer;
        this.createdAt = LocalDateTime.now();
    }

    // Getter and Setter methods
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getQuestion() {
        return question;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public String getAnswer() {
        return answer;
    }

    public void setAnswer(String answer) {
        this.answer = answer;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
} 