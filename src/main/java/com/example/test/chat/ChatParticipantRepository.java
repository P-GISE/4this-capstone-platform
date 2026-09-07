package com.example.test.chat;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ChatParticipantRepository {
    List<ChatParticipant> findByRoomId(Long roomId);
    List<ChatParticipant> findByUserId(Long userId);
    ChatParticipant findByRoomIdAndUserId(@Param("roomId") Long roomId, @Param("userId") Long userId);
    int countByRoomId(Long roomId);
    boolean existsByRoomIdAndUserId(@Param("roomId") Long roomId, @Param("userId") Long userId);
    void insert(ChatParticipant participant);
    void update(ChatParticipant participant);
    void deleteByRoomIdAndUserId(@Param("roomId") Long roomId, @Param("userId") Long userId);
    void deleteByRoomId(Long roomId);
}
