package com.example.test.notice;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.example.test.auth.AuthDto;
import com.example.test.auth.AuthService;
import com.example.test.notice.mapper.NoticeMapper;
import com.example.test.notification.Notification;
import com.example.test.notification.NotificationService;

/**
 * 공지사항 관련 비즈니스 로직을 처리하는 서비스 클래스
 * 컨트롤러와 DAO 사이에서 중간 역할을 수행
 */
@Service
public class NoticeService {

    private static final Logger logger = LoggerFactory.getLogger(NoticeService.class);

    @Autowired
    NoticeDao noticeDao;

    @Autowired
    NoticeMapper noticeMapper;
    
    @Autowired
    NotificationService notificationService;
    
    @Autowired
    AuthService authService;

    public void insert(NoticeDto dto) {
        noticeDao.insert(dto);
    }
    
    /**
     * 전체 공지사항 목록을 조회하는 메서드 (기존)
     * @return 공지사항 리스트 (List<NoticeDto>)
     */
    public List<NoticeDto> list() {
        return noticeDao.list();
    }

    /**
     * 사용자 역할에 따른 공지사항 목록을 조회하는 메서드 (새로 추가)
     * @param userRole 사용자 역할 (STUDENT, PROFESSOR, ADMIN 등)
     * @return 해당 역할이 볼 수 있는 공지사항 리스트
     */
    public List<NoticeDto> getNoticesByRole(String userRole) {
        return noticeDao.getNoticesByRole(userRole);
    }
    
    public NoticeDto selectById(Long id) {
        return noticeDao.selectById(id);
    }

    public void increaseViewCount(Long id) {
        noticeDao.increaseViewCount(id);
    }

    public boolean updateNotice(NoticeDto dto) {
        return noticeMapper.updateNotice(dto) > 0;
    }

    public boolean deleteNotice(Long id) {
        return noticeMapper.deleteNotice(id) > 0;
    }

    public List<NoticeAttachmentDto> getAttachmentsByNoticeId(Long noticeId) {
        return noticeMapper.getAttachmentsByNoticeId(noticeId);
    }

    /**
     * 공지사항과 첨부파일을 함께 저장하는 메서드 (수정됨)
     * @param noticeDto 공지사항 정보
     * @param files 첨부파일 목록
     * @param uploadDir 업로드 디렉토리
     */
    @Transactional // 트랜잭션 추가
    public void insertWithFiles(NoticeDto noticeDto, List<MultipartFile> files, String uploadDir) {
        try {
            // 1. 공지사항 먼저 저장
            logger.info("공지사항 저장 시작: {}", noticeDto.getTitle());
            noticeDao.insert(noticeDto);
            
            // 2. 생성된 ID 확인
            Long generatedId = noticeDto.getId();
            logger.info("생성된 공지사항 ID: {}", generatedId);
            
            if (generatedId == null) {
                throw new RuntimeException("공지사항 ID가 생성되지 않았습니다.");
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
                            NoticeAttachmentDto attach = new NoticeAttachmentDto();
                            attach.setNoticeId(generatedId); // 생성된 ID 사용
                            attach.setFileName(savedName);
                            attach.setOriginalFileName(originalName);
                            attach.setFilePath(uploadDir);
                            attach.setFileType(file.getContentType());
                            attach.setFileSize(file.getSize());

                            int result = noticeMapper.insertAttachment(attach);
                            logger.info("첨부파일 DB 저장 결과: {}, 파일명: {}", result, originalName);
                            
                            if (result <= 0) {
                                throw new RuntimeException("첨부파일 DB 저장 실패: " + originalName);
                            }
                        } catch (IOException e) {
                            logger.error("파일 저장 실패: {}", file.getOriginalFilename(), e);
                            throw new RuntimeException("파일 저장 실패: " + file.getOriginalFilename(), e);
                        }
                    }
                }
            }
            logger.info("공지사항과 첨부파일 저장 완료");
            
            // 중요공지인 경우 모든 사용자에게 알림 발송
            if (noticeDto.isImportant()) {
                logger.info("중요공지 알림 발송 시작: {}", noticeDto.getTitle());
                try {
                    // 모든 사용자 목록 조회
                    List<AuthDto> allUsers = authService.getAllUsersWithProfiles();
                    for (AuthDto user : allUsers) {
                        // 공지사항 작성자는 제외
                        if (!user.getId().equals(noticeDto.getWriterId())) {
                            notificationService.createNotification(
                                user.getId(),
                                Notification.TYPE_IMPORTANT_NOTICE,
                                "🚨 중요 공지사항이 등록되었습니다",
                                noticeDto.getTitle(),
                                "/notice/view?id=" + generatedId
                            );
                        }
                    }
                    logger.info("중요공지 알림 발송 완료. 대상: {}명", allUsers.size() - 1);
                } catch (Exception notifyError) {
                    logger.error("중요공지 알림 발송 실패: {}", notifyError.getMessage(), notifyError);
                    // 알림 발송 실패해도 공지사항 등록은 성공으로 처리
                }
            }
            
        } catch (RuntimeException e) {
            logger.error("공지사항 저장 중 오류 발생", e);
            throw new RuntimeException("공지사항 저장 실패", e);
        }
    }

    public int countAttachments(String category, String keyword) {
        return noticeMapper.countAttachments(category, keyword);
    }
    
    public List<NoticeAttachmentDto> getPagedFiles(int offset, int limit, String category, String keyword) {
        return noticeMapper.getPagedAttachments(offset, limit, category, keyword);
    }

    public int countNotices() {
        return noticeDao.countNotices();
    }

    public List<NoticeDto> searchPaged(int offset, int limit, String category, String keyword) {
        return noticeMapper.searchPaged(offset, limit, category, keyword);
    }
    
    public int searchCount(String category, String keyword) {
        return noticeMapper.searchCount(category, keyword);
    }

    public List<NoticeAttachmentDto> getAllFiles() {
        return noticeMapper.selectAllAttachments();
    }

    public List<NoticeDto> listPaged(int offset, int limit) {
        return noticeDao.listPaged(offset, limit);
    }
    
    @Transactional // 트랜잭션 추가
    public boolean updateNoticeWithFiles(NoticeDto dto, List<MultipartFile> files, List<Long> deleteFileIds) {
        try {
            boolean updated = updateNotice(dto);
            String uploadDir = "/your/upload/folder/path";
        
            // 삭제할 파일들 처리
            if (deleteFileIds != null && !deleteFileIds.isEmpty()) {
                for (Long fileId : deleteFileIds) {
                    int result = noticeMapper.deleteAttachmentById(fileId);
                    logger.info("첨부파일 삭제 결과: {}, ID: {}", result, fileId);
                }
            }
        
            // 새로운 파일들 추가
            if (files != null && !files.isEmpty()) {
                for (MultipartFile file : files) {
                    if (!file.isEmpty()) {
                        try {
                            String originalName = file.getOriginalFilename();
                            String savedName = UUID.randomUUID().toString() + "_" + originalName;
                            String fullPath = uploadDir + File.separator + savedName;
        
                            file.transferTo(new File(fullPath));
        
                            NoticeAttachmentDto attach = new NoticeAttachmentDto();
                            attach.setNoticeId(dto.getId());
                            attach.setFileName(savedName);
                            attach.setOriginalFileName(originalName);
                            attach.setFilePath(uploadDir);
                            attach.setFileType(file.getContentType());
                            attach.setFileSize(file.getSize());
        
                            noticeMapper.insertAttachment(attach);
                        } catch (IOException e) {
                            logger.error("파일 업데이트 중 오류", e);
                            throw new RuntimeException("파일 업데이트 실패", e);
                        }
                    }
                }
            }
        
            return updated;
        } catch (RuntimeException e) {
            logger.error("공지사항 업데이트 중 오류", e);
            throw new RuntimeException("공지사항 업데이트 실패", e);
        }
    }

    /**
     * 역할별 공지사항 페이징 조회
     */
    public List<NoticeDto> listPagedByRole(int offset, int limit, String userRole) {
        return noticeMapper.listPagedByRole(offset, limit, userRole);
    }

    /**
     * 역할별 공지사항 총 개수
     */
    public int countNoticesByRole(String userRole) {
        return noticeMapper.countNoticesByRole(userRole);
    }

    /**
     * 역할별 + 검색 조건 페이징 조회
     */
    public List<NoticeDto> searchPagedByRole(int offset, int limit, String category, String keyword, String userRole) {
        return noticeMapper.searchPagedByRole(offset, limit, category, keyword, userRole);
    }

    /**
     * 역할별 + 검색 조건 총 개수
     */
    public int searchCountByRole(String category, String keyword, String userRole) {
        return noticeMapper.searchCountByRole(category, keyword, userRole);
    }
}