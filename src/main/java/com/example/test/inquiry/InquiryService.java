package com.example.test.inquiry;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.test.auth.AuthDto;
import com.example.test.auth.AuthService;
import com.example.test.notification.NotificationService;

@Service
public class InquiryService {

    @Autowired
    private InquiryDao inquiryDao;
    
    @Autowired
    private AuthService authService; // username으로 userId 조회용
    
    @Autowired
    private NotificationService notificationService;

    // 수정된 메서드들 - status와 sort 파라미터 추가
    public List<InquiryDto> getPagedList(int offset, int limit, String search, String status, String sort) {
        return inquiryDao.getPagedList(offset, limit, search, status, sort);
    }

    public int count(String search, String status) {
        return inquiryDao.count(search, status);
    }

    public InquiryDto selectById(Long id) {
        return inquiryDao.selectById(id);
    }

    public void insert(InquiryDto dto) {
        inquiryDao.insert(dto);
    }

    public void update(InquiryDto dto) {
        inquiryDao.update(dto);
    }

    public void delete(Long id) {
        inquiryDao.delete(id);
    }

    // 첨부파일 관련 메서드
    public void insertAttachment(InquiryAttachmentDto attachment) {
        inquiryDao.insertAttachment(attachment);
    }

    public List<InquiryAttachmentDto> getAttachmentsByInquiryId(Long inquiryId) {
        return inquiryDao.getAttachmentsByInquiryId(inquiryId);
    }

    public InquiryAttachmentDto getAttachmentById(Long attachmentId) {
        return inquiryDao.getAttachmentById(attachmentId);
    }

    public void incrementDownloadCount(Long attachmentId) {
        inquiryDao.incrementDownloadCount(attachmentId);
    }

    public void deleteAttachment(Long attachmentId) {
        inquiryDao.deleteAttachment(attachmentId);
    }

    // 답변 관련 메서드 추가
    public void insertAnswer(InquiryAnswerDto answer) {
        inquiryDao.insertAnswer(answer);
        
        // 답변 등록 후 문의 작성자에게 알림 발송
        try {
            InquiryDto inquiry = selectById(answer.getInquiryId());
            if (inquiry != null && inquiry.getUserId() != null) {
                notificationService.createNotification(
                    inquiry.getUserId(),
                    "INQUIRY_ANSWER",
                    "💬 문의사항에 답변이 등록되었습니다",
                    inquiry.getTitle(),
                    "/inquiry/view?id=" + inquiry.getId()
                );
                System.out.println("문의답변 알림 발송 완료 - 사용자 ID: " + inquiry.getUserId());
            }
        } catch (Exception e) {
            System.err.println("문의답변 알림 발송 실패: " + e.getMessage());
            // 알림 발송 실패해도 답변 등록은 성공으로 처리
        }
    }

    public List<InquiryAnswerDto> getAnswersByInquiryId(Long inquiryId) {
        return inquiryDao.getAnswersByInquiryId(inquiryId);
    }

    public InquiryAnswerDto getAnswerById(Long answerId) {
        return inquiryDao.getAnswerById(answerId);
    }

    public void updateAnswer(InquiryAnswerDto answer) {
        inquiryDao.updateAnswer(answer);
    }

    public void deleteAnswer(Long answerId) {
        inquiryDao.deleteAnswer(answerId);
    }

    public void markAnswerAsRead(Long inquiryId) {
        inquiryDao.markAnswerAsRead(inquiryId);
    }

    public List<InquiryAttachmentDto> getAttachmentsByAnswerId(Long answerId) {
        return inquiryDao.getAttachmentsByAnswerId(answerId);
    }

    public void updateInquiryStatus(Long inquiryId, String status) {
        inquiryDao.updateInquiryStatus(inquiryId, status);
    }

    /**
     * 특정 사용자가 작성한 문의사항 조회 (대시보드용)
     */
    public List<InquiryDto> getMyInquiries(Long userId, int offset, int limit, String sort) {
        return inquiryDao.getMyInquiries(userId, offset, limit, sort);
    }
    
    // ======================================
    // 마이페이지 활동 요약용 메서드 추가
    // ======================================
    
    /**
     * username으로 기술 문의 총 횟수 조회
     */
    public int getTotalInquiriesCountByUsername(String username) {
        try {
            Long userId = getUserIdByUsername(username);
            if (userId == null) {
                return 0;
            }
            return inquiryDao.countTotalInquiriesByUser(userId);
        } catch (Exception e) {
            // 오류 발생 시 0 반환
            return 0;
        }
    }
    
    /**
     * username으로 userId 조회하는 헬퍼 메서드
     */
    private Long getUserIdByUsername(String username) {
        try {
            AuthDto user = authService.findByUsername(username);
            return user != null ? user.getId() : null;
        } catch (Exception e) {
            return null;
        }
    }
}