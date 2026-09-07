package com.example.test.notice;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.apache.ibatis.session.SqlSession;

import com.example.test.notice.mapper.NoticeMapper;

@Component
public class NoticeDao {

    private static final Logger logger = LoggerFactory.getLogger(NoticeDao.class);

    @Autowired
    private SqlSession sqlSession;

    @Autowired
    JdbcTemplate jdbcTemplate;

    @Autowired
    NoticeMapper noticeMapper;

    public void insert(NoticeDto dto) {
        noticeMapper.insert(dto);
    }

    /**
     * 전체 공지사항 목록을 데이터베이스에서 조회하는 메서드 (기존)
     * @return 공지사항 리스트
     */
    public List<NoticeDto> list() {
        String sql = "SELECT " +
                     "id, title, content, category, writer_id AS writerId, updated_by AS updatedBy, " +
                     "view_count AS viewCount, is_important AS important, " +
                     "visible_from AS visibleFrom, visible_until AS visibleUntil, " +
                     "target_role AS targetRole, created_at AS createdAt, updated_at AS updatedAt " +
                     "FROM notices ORDER BY is_important DESC, created_at DESC";

        try {
            return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(NoticeDto.class));
        } catch (DataAccessException e) {
            logger.error("공지사항 목록 조회 오류: {}", e.getMessage(), e);
            return null;
        }
    }

    /**
     * 사용자 역할에 따른 공지사항 목록을 조회하는 메서드 (새로 추가)
     * @param userRole 사용자 역할
     * @return 해당 역할이 볼 수 있는 공지사항 리스트
     */
    public List<NoticeDto> getNoticesByRole(String userRole) {
        String sql = "SELECT " +
                     "id, title, content, category, writer_id AS writerId, updated_by AS updatedBy, " +
                     "view_count AS viewCount, is_important AS important, " +
                     "visible_from AS visibleFrom, visible_until AS visibleUntil, " +
                     "target_role AS targetRole, created_at AS createdAt, updated_at AS updatedAt " +
                     "FROM notices " +
                     "WHERE target_role = 'ALL' OR target_role = ? OR target_role IS NULL " +
                     "ORDER BY is_important DESC, created_at DESC";

        try {
            return jdbcTemplate.query(sql, new BeanPropertyRowMapper<>(NoticeDto.class), userRole);
        } catch (DataAccessException e) {
            logger.error("역할별 공지사항 목록 조회 오류 (userRole: {}): {}", userRole, e.getMessage(), e);
            return null;
        }
    }

    public NoticeDto selectById(Long id) {
        return noticeMapper.selectById(id);
    }

    public void increaseViewCount(Long id) {
        noticeMapper.increaseViewCount(id);
    }

    public void update(NoticeDto dto) {
        noticeMapper.updateNotice(dto);
    }
    public void insertAttachment(NoticeAttachmentDto attach) {
        noticeMapper.insertAttachment(attach);
    }

    
    public int countNotices() {
        return noticeMapper.countNotices();
    }
    public List<NoticeDto> listPaged(int offset, int limit) {
        Map<String, Object> params = new HashMap<>();
        params.put("offset", offset);
        params.put("limit", limit);
        return sqlSession.selectList("com.example.test.notice.mapper.NoticeMapper.listPaged", params);
    }
    
}