package com.example.test.ai;

import java.util.List;

public class QuestionWithAnswerDto {
    private Long id;
    private Long userId;
    private String contextType;
    private String question;
    private String category;
    private java.sql.Timestamp createdAt;
    
    // 답변 정보
    private String answer;
    private Long answerId;
    private Integer tokenUsage;
    private Boolean isSuccessful;
    
    // 첨부파일 정보
    private List<AttachmentFileDto> attachments;
    
    // 기본 생성자
    public QuestionWithAnswerDto() {}
    
    // 생성자
    public QuestionWithAnswerDto(AiQuestion question, AiAnswer answer) {
        this.id = question.getId();
        this.userId = question.getUserId();
        this.contextType = question.getContextType();
        this.question = question.getQuestion();
        this.category = question.getCategory();
        this.createdAt = question.getCreatedAt();
        
        if (answer != null) {
            this.answer = answer.getAnswer();
            this.answerId = answer.getId();
            this.tokenUsage = answer.getTokenUsage();
            this.isSuccessful = answer.getIsSuccessful();
        }
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

    public String getContextType() {
        return contextType;
    }

    public void setContextType(String contextType) {
        this.contextType = contextType;
    }

    public String getQuestion() {
        return question;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public java.sql.Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(java.sql.Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getAnswer() {
        return answer;
    }

    public void setAnswer(String answer) {
        this.answer = answer;
    }

    public Long getAnswerId() {
        return answerId;
    }

    public void setAnswerId(Long answerId) {
        this.answerId = answerId;
    }

    public Integer getTokenUsage() {
        return tokenUsage;
    }

    public void setTokenUsage(Integer tokenUsage) {
        this.tokenUsage = tokenUsage;
    }

    public Boolean getIsSuccessful() {
        return isSuccessful;
    }

    public void setIsSuccessful(Boolean isSuccessful) {
        this.isSuccessful = isSuccessful;
    }
    
    public List<AttachmentFileDto> getAttachments() {
        return attachments;
    }
    
    public void setAttachments(List<AttachmentFileDto> attachments) {
        this.attachments = attachments;
    }
} 