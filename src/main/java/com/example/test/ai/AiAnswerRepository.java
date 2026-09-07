package com.example.test.ai;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface AiAnswerRepository {
    // 답변 저장
    Long insertAnswer(AiAnswer answer);
    
    // 답변 조회
    AiAnswer findById(Long id);
    
    // 질문 ID로 답변 조회
    AiAnswer findByQuestionId(Long questionId);
    
    // 여러 질문에 대한 답변 조회
    List<AiAnswer> findByQuestionIds(List<Long> questionIds);
    
    // 성공한 답변만 조회
    List<AiAnswer> findSuccessfulAnswers();
    
    // 답변 수정
    void updateAnswer(AiAnswer answer);
    
    // 답변 삭제
    void deleteById(Long id);
    
    // 질문 ID로 답변 삭제
    void deleteByQuestionId(Long questionId);
    
    // 총 토큰 사용량 조회
    Long getTotalTokenUsage();
    
    // 성공률 통계
    Double getSuccessRate();
} 