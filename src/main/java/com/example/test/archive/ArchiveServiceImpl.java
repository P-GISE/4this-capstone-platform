package com.example.test.archive;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.example.test.archive.mapper.ArchiveMapper;

@Service
public class ArchiveServiceImpl implements ArchiveService {

    private static final Logger logger = LoggerFactory.getLogger(ArchiveServiceImpl.class);

    @Autowired
    private ArchiveMapper archiveMapper;

    @Override
    public List<ArchiveDto> getArchiveList() {
        return archiveMapper.findVisibleArchives();
    }

    @Override
    public List<ArchiveDto> getArchiveListWithPaging(Map<String, Object> searchParams) {
        return archiveMapper.findVisibleArchivesWithPaging(searchParams);
    }

    @Override
    public int getArchiveCount(Map<String, Object> searchParams) {
        return archiveMapper.countVisibleArchives(searchParams);
    }

    @Override
    public void saveArchive(ArchiveDto archiveDto) {
        archiveMapper.insertArchive(archiveDto);
    }

    @Override
    @Transactional
    public void saveArchiveWithFiles(ArchiveDto archiveDto, List<MultipartFile> files, String uploadDir) {
        try {
            // 1. 아카이브 먼저 저장
            logger.info("아카이브 저장 시작: {}", archiveDto.getTitle());
            archiveMapper.insertArchive(archiveDto);
            
            // 2. 생성된 ID 확인
            Long generatedId = archiveDto.getId();
            logger.info("생성된 아카이브 ID: {}", generatedId);
            
            if (generatedId == null) {
                throw new RuntimeException("아카이브 ID가 생성되지 않았습니다.");
            }

            // 3. 첨부파일이 있는 경우에만 처리
            if (files != null && !files.isEmpty()) {
                logger.info("첨부파일 개수: {}", files.size());
                
                // 업로드 디렉토리 생성
                File uploadDirFile = new File(uploadDir);
                if (!uploadDirFile.exists()) {
                    uploadDirFile.mkdirs();
                    logger.info("업로드 디렉토리 생성: {}", uploadDir);
                }
                
                for (MultipartFile file : files) {
                    if (!file.isEmpty()) {
                        try {
                            String originalName = file.getOriginalFilename();
                            String savedName = UUID.randomUUID().toString() + "_" + originalName;
                            String fullPath = uploadDir + File.separator + savedName;

                            // 파일 저장
                            File targetFile = new File(fullPath);
                            file.transferTo(targetFile);
                            logger.info("파일 저장 완료: {}", fullPath);

                            // DB에 첨부파일 정보 저장
                            ArchiveFileDto fileDto = new ArchiveFileDto();
                            fileDto.setArchiveId(generatedId);
                            fileDto.setFileName(savedName);
                            fileDto.setOriginalFileName(originalName);
                            fileDto.setFilePath(uploadDir);
                            fileDto.setFileType(file.getContentType());
                            fileDto.setFileSize(file.getSize());
                            fileDto.setDownloadCount(0);
                            fileDto.setIsDeleted(false);

                            archiveMapper.insertArchiveFile(fileDto);
                            logger.info("첨부파일 DB 저장 완료: {}", originalName);
                            
                        } catch (IOException e) {
                            logger.error("파일 저장 실패: {}", file.getOriginalFilename(), e);
                            throw new RuntimeException("파일 저장 실패: " + file.getOriginalFilename(), e);
                        }
                    }
                }
            }
            logger.info("아카이브와 첨부파일 저장 완료");
        } catch (RuntimeException e) {
            logger.error("아카이브 저장 중 시스템 오류 발생", e);
            throw e;
        } catch (Exception e) {
            logger.error("아카이브 저장 중 예상치 못한 오류 발생", e);
            throw new RuntimeException("아카이브 저장 실패", e);
        }
    }

    @Override
    public ArchiveDto getArchiveById(Long id) {
        return archiveMapper.findById(id);
    }

    @Override
    public void updateArchive(ArchiveDto archiveDto) {
        archiveMapper.updateArchive(archiveDto);
    }

    @Override
    @Transactional
    public void updateArchiveWithFiles(ArchiveDto archiveDto, List<MultipartFile> files, List<Long> deleteFileIds) {
        try {
            // 1. 아카이브 정보 수정
            logger.info("아카이브 수정 시작: ID={}, 제목={}", archiveDto.getId(), archiveDto.getTitle());
            archiveMapper.updateArchive(archiveDto);
            String uploadDir = com.example.test.config.RuntimePaths.uploads("archives");
        
            // 2. 삭제할 파일들 처리
            if (deleteFileIds != null && !deleteFileIds.isEmpty()) {
                logger.info("삭제할 파일 개수: {}", deleteFileIds.size());
                for (Long fileId : deleteFileIds) {
                    logger.info("파일 삭제 처리 시작: 파일ID={}", fileId);
                    archiveMapper.markFileAsDeleted(fileId);
                    logger.info("파일 삭제 처리 완료: 파일ID={}", fileId);
                }
            } else {
                logger.info("삭제할 파일이 없습니다.");
            }
        
            // 3. 새로운 파일들 추가
            if (files != null && !files.isEmpty()) {
                logger.info("새 파일 추가 개수: {}", files.size());
                // 업로드 디렉토리 생성
                File uploadDirFile = new File(uploadDir);
                if (!uploadDirFile.exists()) {
                    uploadDirFile.mkdirs();
                }
                
                for (MultipartFile file : files) {
                    if (!file.isEmpty()) {
                        try {
                            String originalName = file.getOriginalFilename();
                            String savedName = UUID.randomUUID().toString() + "_" + originalName;
                            String fullPath = uploadDir + File.separator + savedName;
        
                            file.transferTo(new File(fullPath));
        
                            ArchiveFileDto fileDto = new ArchiveFileDto();
                            fileDto.setArchiveId(archiveDto.getId());
                            fileDto.setFileName(savedName);
                            fileDto.setOriginalFileName(originalName);
                            fileDto.setFilePath(uploadDir);
                            fileDto.setFileType(file.getContentType());
                            fileDto.setFileSize(file.getSize());
                            fileDto.setDownloadCount(0);
                            fileDto.setIsDeleted(false);
        
                            archiveMapper.insertArchiveFile(fileDto);
                            logger.info("새 파일 추가 완료: {}", originalName);
                        } catch (IOException e) {
                            logger.error("파일 업데이트 중 오류", e);
                            throw new RuntimeException("파일 업데이트 실패", e);
                        }
                    }
                }
            } else {
                logger.info("새로 추가할 파일이 없습니다.");
            }
            
            logger.info("아카이브 수정 완료: ID={}", archiveDto.getId());
        } catch (RuntimeException e) {
            logger.error("아카이브 업데이트 중 시스템 오류", e);
            throw e;
        } catch (Exception e) {
            logger.error("아카이브 업데이트 중 예상치 못한 오류", e);
            throw new RuntimeException("아카이브 업데이트 실패", e);
        }
    }

    @Override
    public void deleteArchive(Long id) {
        // 1. 아카이브의 모든 파일 삭제 처리
        List<ArchiveFileDto> files = getArchiveFiles(id);
        for (ArchiveFileDto file : files) {
            archiveMapper.markFileAsDeleted(file.getId());
        }
        
        // 2. 아카이브 삭제 표시
        archiveMapper.markAsDeleted(id);
    }

    @Override
    public List<ArchiveFileDto> getArchiveFiles(Long archiveId) {
        return archiveMapper.findFilesByArchiveId(archiveId);
    }

    @Override
    public void approveArchive(Long id, Long adminId) {
        archiveMapper.approveArchive(id, adminId);
    }

    @Override
    public List<ArchiveDto> getPendingArchives() {
        return archiveMapper.findPendingArchives();
    }
    
    @Override
    public List<ArchiveDto> getArchivesByUser(Long userId) {
        logger.info("사용자별 아카이브 조회: userId={}", userId);
        List<ArchiveDto> userArchives = archiveMapper.findArchivesByUser(userId);
        logger.info("사용자 아카이브 개수: {}", userArchives.size());
        return userArchives;
    }

    @Override
    public ArchiveFileDto getFileById(Long fileId) {
        return archiveMapper.findFileById(fileId);
    }
    
    @Override
    public void incrementDownloadCount(Long fileId) {
        archiveMapper.incrementDownloadCount(fileId);
        logger.info("파일 다운로드 카운트 증가: 파일ID={}", fileId);
    }

}