package com.example.test.archive;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

public interface ArchiveService {
    List<ArchiveDto> getArchiveList();
    
    /**
     * 검색, 필터링, 페이지네이션이 적용된 아카이브 목록 조회
     */
    List<ArchiveDto> getArchiveListWithPaging(Map<String, Object> searchParams);
    
    /**
     * 검색 조건에 따른 전체 아카이브 개수 조회
     */
    int getArchiveCount(Map<String, Object> searchParams);
    
    void saveArchive(ArchiveDto archiveDto);
    
    /**
     * 아카이브와 파일을 함께 저장 (공지사항과 동일한 방식)
     */
    void saveArchiveWithFiles(ArchiveDto archiveDto, List<MultipartFile> files, String uploadDir);

    ArchiveDto getArchiveById(Long id);

    void updateArchive(ArchiveDto archiveDto);
    
    /**
     * 아카이브 수정과 파일 처리를 함께 수행 (공지사항과 동일한 방식)
     */
    void updateArchiveWithFiles(ArchiveDto archiveDto, List<MultipartFile> files, List<Long> deleteFileIds);

    void deleteArchive(Long id);

    /**
     * 아카이브의 첨부파일 목록 조회
     */
    List<ArchiveFileDto> getArchiveFiles(Long archiveId);

    void approveArchive(Long id, Long adminId);
    
    /**
     * 관리자용 승인 대기 목록 조회
     */
    List<ArchiveDto> getPendingArchives();
    
    /**
     * 사용자별 아카이브 목록 조회 (승인 대기중 포함)
     */
    List<ArchiveDto> getArchivesByUser(Long userId);

    /**
     * 파일 ID로 파일 정보 조회
     */
    ArchiveFileDto getFileById(Long fileId);
    
    /**
     * 파일 다운로드 카운트 증가
     */
    void incrementDownloadCount(Long fileId);

}