package com.example.test.ai;

import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface AiConversationRepository {
    Long insertConversation(AiConversation conversation);
    AiConversation selectConversationById(Long id);
    List<AiConversation> selectConversationsByUserId(Long userId);
    void deleteConversationById(Long id);
    void updateConversationTitle(Long id, String title);
} 