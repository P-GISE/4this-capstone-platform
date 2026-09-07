package com.example.test.archive.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.test.archive.ArchiveDto;
import com.example.test.archive.ArchiveFileDto;

@Mapper
public interface ArchiveMapper {
    List<ArchiveDto> findVisibleArchives();
    
    /**
     * 검색, 필터링, 페이지네이션이 적용된 아카이브 목록 조회
     */
    List<ArchiveDto> findVisibleArchivesWithPaging(Map<String, Object> searchParams);
    
    /**
     * 검색 조건에 따른 전체 아카이브 개수 조회
     */
    int countVisibleArchives(Map<String, Object> searchParams);

    void insertArchive(ArchiveDto archiveDto);
    
    ArchiveDto findById(Long id);

    void updateArchive(ArchiveDto archiveDto);

    void markAsDeleted(Long id);

    // 파일 관련 메서드들
    void insertArchiveFile(ArchiveFileDto fileDto);
    
    List<ArchiveFileDto> findFilesByArchiveId(Long archiveId);
    
    ArchiveFileDto findFileById(Long fileId);
    
    void incrementDownloadCount(Long fileId);
    
    void markFileAsDeleted(@Param("fileId") Long fileId);

    void approveArchive(@Param("id") Long id, @Param("adminId") Long adminId);
    
    // 관리자용 승인 대기 목록 조회
    List<ArchiveDto> findPendingArchives();
    
    // 사용자별 아카이브 목록 조회 (승인 대기중 포함)
    List<ArchiveDto> findArchivesByUser(Long userId);

}