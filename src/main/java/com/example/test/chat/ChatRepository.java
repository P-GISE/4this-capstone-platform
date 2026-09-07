package com.example.test.chat;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

@Mapper
@Repository
public interface ChatRepository {
    void insert(Chat chat);
    void update(Chat chat);
    void delete(Long id);
    Chat findById(Long id);
    List<Chat> findAll();
}
