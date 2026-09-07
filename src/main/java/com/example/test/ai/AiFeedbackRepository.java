package com.example.test.ai;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface AiFeedbackRepository {
    // 피드백 저장
    Long insertFeedback(AiFeedback feedback);
    
    // 피드백 조회
    AiFeedback findById(Long id);
    
    // 답변 ID로 피드백 목록 조회
    List<AiFeedback> findByAnswerId(Long answerId);
    
    // 사용자별 피드백 목록 조회
    List<AiFeedback> findByUserId(Long userId);
    
    // 피드백 타입별 조회
    List<AiFeedback> findByFeedbackType(String feedbackType);
    
    // 점수별 피드백 조회
    List<AiFeedback> findByScore(Integer score);
    
    // 피드백 수정
    void updateFeedback(AiFeedback feedback);
    
    // 피드백 삭제
    void deleteById(Long id);
    
    // 답변 ID로 피드백 삭제
    void deleteByAnswerId(Long answerId);
    
    // 평균 점수 조회
    Double getAverageScore();
    
    // 답변별 평균 점수 조회
    Double getAverageScoreByAnswerId(Long answerId);
    
    // 피드백 통계
    int countByFeedbackType(String feedbackType);
} 