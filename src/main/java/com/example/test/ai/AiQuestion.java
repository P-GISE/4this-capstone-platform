package com.example.test.ai;

public class AiQuestion {
    private Long id;
    private Long userId;
    private String contextType; // PROJECT, EQUIPMENT, PROFILE
    private Long targetId;
    private String question;
    private String category;
    private Boolean isAnswered = false;
    private Integer answeredInSeconds;
    private Long attachmentId;
    private java.sql.Timestamp createdAt;

    public AiQuestion() {}
    public AiQuestion(Long userId, String contextType, String question) {
        this.userId = userId;
        this.contextType = contextType;
        this.question = question;
    }
    public AiQuestion(Long userId, String contextType, Long targetId, String question, String category) {
        this.userId = userId;
        this.contextType = contextType;
        this.targetId = targetId;
        this.question = question;
        this.category = category;
    }
    // Getter/Setter
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
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
    public Long getAttachmentId() { return attachmentId; }
    public void setAttachmentId(Long attachmentId) { this.attachmentId = attachmentId; }
    public java.sql.Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(java.sql.Timestamp createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "AiQuestion{" +
                "id=" + id +
                ", userId=" + userId +
                ", contextType='" + contextType + '\'' +
                ", question='" + question + '\'' +
                ", category='" + category + '\'' +
                ", isAnswered=" + isAnswered +
                ", createdAt=" + createdAt +
                '}';
    }
} 