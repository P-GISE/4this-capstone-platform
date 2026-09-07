package com.example.test.archive;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import java.util.ArrayList;
import java.util.List;

@Repository
public class ArchiveDao {


    @Autowired
    private SqlSessionTemplate sqlSession;


    public List<ArchiveDto> findAllVisibleArchives() {
        return new ArrayList<>();
    }

    public void insertArchiveFile(ArchiveFileDto fileDto) {
        sqlSession.insert("com.example.test.archive.mapper.ArchiveMapper.insertArchiveFile", fileDto);
    }

    

    
}