package com.example.test.chat;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ChatMessageRepository {
    void insert(ChatMessage chatMessage);
    void update(ChatMessage chatMessage);
    void delete(Long id);
    void deleteByRoomId(Long roomId);
    ChatMessage findById(Long id);
    List<ChatMessage> findByRoomId(Long roomId);
    List<ChatMessage> findByUserId(Long userId);
    List<ChatMessage> findByRoomIdOrderByCreatedAtDesc(@Param("roomId") Long roomId);
    List<ChatMessage> findByRoomIdAndContentContaining(@Param("roomId") Long roomId, @Param("content") String content);
    int countByRoomId(Long roomId);
    int countByRoomIdAndCreatedAtAfter(@Param("roomId") Long roomId, @Param("createdAt") java.time.LocalDateTime createdAt);
    java.util.Optional<ChatMessage> findFirstByRoomIdOrderByCreatedAtDesc(@Param("roomId") Long roomId);
    List<ChatMessage> findByName(String name);
    List<ChatMessage> findByIsPrivate(boolean isPrivate);
    List<ChatMessage> findByType(String type);
    List<ChatMessage> findByStatus(String status);
    List<ChatMessage> findByCreatedAtBetween(@Param("start") java.time.LocalDateTime start, @Param("end") java.time.LocalDateTime end);
    List<ChatMessage> findByUpdatedAtBetween(@Param("start") java.time.LocalDateTime start, @Param("end") java.time.LocalDateTime end);
    List<ChatMessage> findAll();
}
