package com.example.test.inquiry.mapper;

import com.example.test.inquiry.InquiryDto;
import com.example.test.inquiry.InquiryAttachmentDto;
import com.example.test.inquiry.InquiryAnswerDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface InquiryMapper {
    // 수정된 메서드들 - status와 sort 파라미터 추가
    List<InquiryDto> getPagedList(@Param("offset") int offset, 
                                  @Param("limit") int limit, 
                                  @Param("search") String search,
                                  @Param("status") String status,
                                  @Param("sort") String sort);
    
    int count(@Param("search") String search, @Param("status") String status);
    
    InquiryDto selectById(Long id);
    void insert(InquiryDto dto);
    void update(InquiryDto dto);
    void delete(Long id);

    // 첨부파일 관련 메서드
    void insertAttachment(InquiryAttachmentDto attachment);
    List<InquiryAttachmentDto> getAttachmentsByInquiryId(Long inquiryId);
    InquiryAttachmentDto getAttachmentById(Long attachmentId);
    void incrementDownloadCount(Long attachmentId);
    void deleteAttachment(Long attachmentId);

    // 답변 관련 메서드 추가
    void insertAnswer(InquiryAnswerDto answer);
    List<InquiryAnswerDto> getAnswersByInquiryId(Long inquiryId);
    InquiryAnswerDto getAnswerById(Long answerId);
    void updateAnswer(InquiryAnswerDto answer);
    void deleteAnswer(Long answerId);
    void markAnswerAsRead(Long inquiryId);
    
    // 답변 첨부파일 관련
    List<InquiryAttachmentDto> getAttachmentsByAnswerId(Long answerId);
    
    // 문의사항 상태 업데이트
    void updateInquiryStatus(@Param("inquiryId") Long inquiryId, @Param("status") String status);

    /**
     * 특정 사용자가 작성한 문의사항 조회 (대시보드용)
     */
    List<InquiryDto> getMyInquiries(@Param("userId") Long userId, 
                                   @Param("offset") int offset, 
                                   @Param("limit") int limit, 
                                   @Param("sort") String sort);

    /**
     * 특정 사용자의 문의 총 개수 조회 (마이페이지 활동 요약용)
     */
    int countTotalInquiriesByUser(@Param("userId") Long userId);
}