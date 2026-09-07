package com.example.test.inquiry;

import com.example.test.inquiry.mapper.InquiryMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public class InquiryDao {

    @Autowired
    private InquiryMapper inquiryMapper;

    // 수정된 메서드들 - status와 sort 파라미터 추가
    public void insert(InquiryDto dto) {
        inquiryMapper.insert(dto);
    }

    public List<InquiryDto> getPagedList(int offset, int limit, String search, String status, String sort) {
        return inquiryMapper.getPagedList(offset, limit, search, status, sort);
    }

    public int count(String search, String status) {
        return inquiryMapper.count(search, status);
    }

    public InquiryDto selectById(Long id) {
        return inquiryMapper.selectById(id);
    }

    public void update(InquiryDto dto) {
        inquiryMapper.update(dto);
    }

    public void delete(Long id) {
        inquiryMapper.delete(id);
    }

    // 첨부파일 관련 메서드
    public void insertAttachment(InquiryAttachmentDto attachment) {
        inquiryMapper.insertAttachment(attachment);
    }

    public List<InquiryAttachmentDto> getAttachmentsByInquiryId(Long inquiryId) {
        return inquiryMapper.getAttachmentsByInquiryId(inquiryId);
    }

    public InquiryAttachmentDto getAttachmentById(Long attachmentId) {
        return inquiryMapper.getAttachmentById(attachmentId);
    }

    public void incrementDownloadCount(Long attachmentId) {
        inquiryMapper.incrementDownloadCount(attachmentId);
    }

    public void deleteAttachment(Long attachmentId) {
        inquiryMapper.deleteAttachment(attachmentId);
    }

    // 답변 관련 메서드
    public void insertAnswer(InquiryAnswerDto answer) {
        inquiryMapper.insertAnswer(answer);
    }

    public List<InquiryAnswerDto> getAnswersByInquiryId(Long inquiryId) {
        return inquiryMapper.getAnswersByInquiryId(inquiryId);
    }

    public InquiryAnswerDto getAnswerById(Long answerId) {
        return inquiryMapper.getAnswerById(answerId);
    }

    public void updateAnswer(InquiryAnswerDto answer) {
        inquiryMapper.updateAnswer(answer);
    }

    public void deleteAnswer(Long answerId) {
        inquiryMapper.deleteAnswer(answerId);
    }

    // 답변 읽음 처리 메서드 추가
    public void markAnswerAsRead(Long inquiryId) {
        inquiryMapper.markAnswerAsRead(inquiryId);
    }

    public List<InquiryAttachmentDto> getAttachmentsByAnswerId(Long answerId) {
        return inquiryMapper.getAttachmentsByAnswerId(answerId);
    }

    public void updateInquiryStatus(Long inquiryId, String status) {
        inquiryMapper.updateInquiryStatus(inquiryId, status);
    }
     
    /**
     * 특정 사용자가 작성한 문의사항 조회
     */
    public List<InquiryDto> getMyInquiries(Long userId, int offset, int limit, String sort) {
        return inquiryMapper.getMyInquiries(userId, offset, limit, sort);
    }

    /**
     * 특정 사용자의 문의 총 개수 조회 (마이페이지 활동 요약용)
     */
    public int countTotalInquiriesByUser(Long userId) {
        return inquiryMapper.countTotalInquiriesByUser(userId);
    }
}