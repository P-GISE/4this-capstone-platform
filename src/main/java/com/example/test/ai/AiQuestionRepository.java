package com.example.test.ai;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface AiQuestionRepository {
    // 질문 저장
    Long insertQuestion(AiQuestion question);
    
    // 질문 조회
    AiQuestion findById(Long id);
    
    // 사용자별 질문 목록 조회
    List<AiQuestion> findByUserId(Long userId);
    
    // 사용자별 질문 목록 조회 (페이징)
    List<AiQuestion> findByUserIdWithPaging(Long userId, int offset, int limit);
    
    // 컨텍스트 타입별 질문 조회
    List<AiQuestion> findByContextType(String contextType);
    
    // 답변 완료 상태 업데이트
    void updateAnsweredStatus(Long questionId, Boolean isAnswered, Integer answeredInSeconds);
    
    // 질문 수정
    void updateQuestion(AiQuestion question);
    
    // 질문 삭제
    void deleteById(Long id);
    
    // 사용자별 총 질문 개수
    int countByUserId(Long userId);
    
    // 대화방(주제)별 질문 목록 조회
    List<AiQuestion> findByConversationId(Long conversationId);
} 