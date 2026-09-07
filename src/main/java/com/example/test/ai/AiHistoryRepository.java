package com.example.test.ai;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface AiHistoryRepository {
    void insertHistory(AiHistory history);
    List<AiHistory> findByUserId(@Param("userId") String userId);
    List<AiHistory> findRecentByUserId(@Param("userId") String userId, @Param("limit") int limit);
    int countByUserId(@Param("userId") String userId);
    int countByUserIdThisMonth(@Param("userId") String userId);
    List<AiHistoryDto> findHistoryByUserId(@Param("userId") Long userId, @Param("limit") int limit);
    AiHistoryDto findHistoryByQuestionId(@Param("questionId") Long questionId);
    void deleteHistoryByQuestionId(@Param("questionId") Long questionId);
} 