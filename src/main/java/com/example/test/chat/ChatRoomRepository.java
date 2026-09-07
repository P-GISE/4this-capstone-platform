package com.example.test.chat;

import java.time.LocalDateTime;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ChatRoomRepository {
    void insert(ChatRoom chatRoom);
    void update(ChatRoom chatRoom);
    void delete(Long roomId);
    ChatRoom findById(Long roomId);
    List<ChatRoom> findByProjectId(Long projectId);
    List<ChatRoom> findByIsPrivate(@Param("isPrivate") boolean isPrivate);
    List<ChatRoom> findByName(@Param("name") String name);
    List<ChatRoom> findByType(String type);
    List<ChatRoom> findByStatus(String status);
    List<ChatRoom> findByCreatedAtBetween(LocalDateTime startDate, LocalDateTime endDate);
    List<ChatRoom> findByUpdatedAtBetween(LocalDateTime startDate, LocalDateTime endDate);
    boolean existsByProjectIdAndIsMainTrue(Long projectId);
    List<ChatRoom> searchRoomsByName(@Param("keyword") String keyword);
    List<ChatRoom> findAll();
}
