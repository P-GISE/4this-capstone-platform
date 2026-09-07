package com.example.test.chat;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ChatInvitationRepository {
    ChatInvitation findByRoomIdAndInviteeId(@Param("roomId") Long roomId, @Param("inviteeId") Long inviteeId);
    List<ChatInvitation> findByInviteeIdAndStatus(@Param("inviteeId") Long inviteeId, @Param("status") String status);
    List<ChatInvitation> findByRoomId(Long roomId);
    void deleteByRoomId(Long roomId);
    boolean existsByRoomIdAndInviteeId(@Param("roomId") Long roomId, @Param("inviteeId") Long inviteeId);
    void insert(ChatInvitation invitation);
    void update(ChatInvitation invitation);
    void delete(Long id);
}
