package com.example.test.ai;

import java.time.LocalDateTime;

public class AiHistoryDto {
    private Long questionId;
    private Long userId;
    private String contextType;
    private Long targetId;
    private String question;
    private String category;
    private Boolean isAnswered;
    private Integer answeredInSeconds;
    private LocalDateTime questionCreatedAt;

    private Long answerId;
    private String answer;
    private Integer tokenUsage;
    private Boolean isSuccessful;
    private LocalDateTime answerCreatedAt;

    // Getter/Setter
    public Long getQuestionId() { return questionId; }
    public void setQuestionId(Long questionId) { this.questionId = questionId; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getContextType() { return contextType; }
    public void setContextType(String contextType) { this.contextType = contextType; }
    public Long getTargetId() { return targetId; }
    public void setTargetId(Long targetId) { this.targetId = targetId; }
    public String getQuestion() { return question; }
    public void setQuestion(String question) { this.question = question; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public Boolean getIsAnswered() { return isAnswered; }
    public void setIsAnswered(Boolean isAnswered) { this.isAnswered = isAnswered; }
    public Integer getAnsweredInSeconds() { return answeredInSeconds; }
    public void setAnsweredInSeconds(Integer answeredInSeconds) { this.answeredInSeconds = answeredInSeconds; }
    public LocalDateTime getQuestionCreatedAt() { return questionCreatedAt; }
    public void setQuestionCreatedAt(LocalDateTime questionCreatedAt) { this.questionCreatedAt = questionCreatedAt; }
    public Long getAnswerId() { return answerId; }
    public void setAnswerId(Long answerId) { this.answerId = answerId; }
    public String getAnswer() { return answer; }
    public void setAnswer(String answer) { this.answer = answer; }
    public Integer getTokenUsage() { return tokenUsage; }
    public void setTokenUsage(Integer tokenUsage) { this.tokenUsage = tokenUsage; }
    public Boolean getIsSuccessful() { return isSuccessful; }
    public void setIsSuccessful(Boolean isSuccessful) { this.isSuccessful = isSuccessful; }
    public LocalDateTime getAnswerCreatedAt() { return answerCreatedAt; }
    public void setAnswerCreatedAt(LocalDateTime answerCreatedAt) { this.answerCreatedAt = answerCreatedAt; }
} 