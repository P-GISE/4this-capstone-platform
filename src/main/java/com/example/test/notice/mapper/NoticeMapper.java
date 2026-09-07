package com.example.test.notice.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.example.test.notice.NoticeAttachmentDto;
import com.example.test.notice.NoticeDto;

@Mapper
public interface NoticeMapper {

    int insert(NoticeDto dto);

    int insertNotice(NoticeDto dto);
    
    /**
     * 전체 공지사항 목록 조회
     */
    List<NoticeDto> list();
    
    /**
     * 사용자 역할에 따른 공지사항 목록 조회
     */
    List<NoticeDto> getNoticesByRole(@Param("userRole") String userRole);

    NoticeDto selectById(Long id);

    void increaseViewCount(Long id);
    
    int updateNotice(NoticeDto dto);

    int deleteNotice(Long id);

    int insertAttachment(NoticeAttachmentDto dto);
    List<NoticeAttachmentDto> getAttachmentsByNoticeId(Long noticeId);

    List<NoticeDto> listPaged(@Param("offset") int offset, @Param("limit") int limit); 
    int countNotices(); 

    List<NoticeDto> searchPaged(@Param("offset") int offset,
                                @Param("limit") int limit,
                                @Param("category") String category,
                                @Param("keyword") String keyword);

    int searchCount(@Param("category") String category,
                    @Param("keyword") String keyword);

    List<NoticeAttachmentDto> selectAllAttachments();

    
    int deleteAttachmentById(Long id);  // 메소드 이름과 일치시켜야 함

    int countAttachments(@Param("category") String category, @Param("keyword") String keyword);

    List<NoticeAttachmentDto> getPagedAttachments(@Param("offset") int offset,
        @Param("limit") int limit,
        @Param("category") String category,
        @Param("keyword") String keyword);
    

    
    /**
     * 역할별 공지사항 페이징 조회
     */
    List<NoticeDto> listPagedByRole(@Param("offset") int offset, 
    @Param("limit") int limit, 
    @Param("userRole") String userRole);

    /**
    * 역할별 공지사항 총 개수
    */
    int countNoticesByRole(@Param("userRole") String userRole);

    /**
    * 역할별 + 검색 조건 페이징 조회
    */
    List<NoticeDto> searchPagedByRole(@Param("offset") int offset,
    @Param("limit") int limit,
    @Param("category") String category,
    @Param("keyword") String keyword,
    @Param("userRole") String userRole);

    /**
    * 역할별 + 검색 조건 총 개수
    */
    int searchCountByRole(@Param("category") String category,
    @Param("keyword") String keyword,
    @Param("userRole") String userRole);
                

}