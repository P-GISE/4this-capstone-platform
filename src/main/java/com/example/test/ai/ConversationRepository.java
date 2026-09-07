package com.example.test.ai;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface ConversationRepository {
    void insertConversation(Conversation conversation);
    List<Conversation> selectConversationsByUserId(@Param("userId") Long userId);
    Conversation selectConversationById(@Param("id") Long id);
} 