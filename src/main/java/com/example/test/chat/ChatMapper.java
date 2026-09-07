package com.example.test.chat;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ChatMapper {
    List<ChatRoom> selectAllPublicRooms();
    List<ChatRoom> searchRoomsByName(String keyword);
}
