package com.example.test.ai;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonProperty;

public class AiAnswer {
    private Long id;
    
    @JsonProperty("questionId")
    private Long questionId;
    
    @JsonProperty("answer")
    private String answer;
    
    @JsonProperty("tokenUsage")
    private Integer tokenUsage;
    
    @JsonProperty("isSuccessful")
    private Boolean isSuccessful = true;
    
    @JsonProperty("createdAt")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private java.sql.Timestamp createdAt;

    // 기본 생성자
    public AiAnswer() {}

    // 생성자
    public AiAnswer(Long questionId, String answer) {
        this.questionId = questionId;
        this.answer = answer;
    }

    public AiAnswer(Long questionId, String answer, Integer tokenUsage, Boolean isSuccessful) {
        this.questionId = questionId;
        this.answer = answer;
        this.tokenUsage = tokenUsage;
        this.isSuccessful = isSuccessful;
    }

    // Getter와 Setter 메서드들
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getQuestionId() { return questionId; }
    public void setQuestionId(Long questionId) { this.questionId = questionId; }

    public String getAnswer() { return answer; }
    public void setAnswer(String answer) { this.answer = answer; }

    public Integer getTokenUsage() { return tokenUsage; }
    public void setTokenUsage(Integer tokenUsage) { this.tokenUsage = tokenUsage; }

    public Boolean getIsSuccessful() { return isSuccessful; }
    public void setIsSuccessful(Boolean isSuccessful) { this.isSuccessful = isSuccessful; }

    public java.sql.Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.sql.Timestamp createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "AiAnswer{" +
                "id=" + id +
                ", questionId=" + questionId +
                ", answer='" + answer + '\'' +
                ", tokenUsage=" + tokenUsage +
                ", isSuccessful=" + isSuccessful +
                ", createdAt=" + createdAt +
                '}';
    }
} 