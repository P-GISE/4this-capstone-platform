package com.example.test.auth;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.example.test.libs.Email;

/**
 * 이메일 전송을 처리하는 유틸 클래스
 */
@Component
public class EmailUtil {

    private static final Logger logger = LoggerFactory.getLogger(EmailUtil.class);
    
    private final Email emailClient;

    @Autowired
    public EmailUtil(Email emailClient) {
        this.emailClient = emailClient;
    }

    /**
     * 메일을 보냅니다.
     * @param to 받는 사람 이메일 주소
     * @param subject 이메일 제목
     * @param text 이메일 내용
     * @return 성공 여부 (true: 성공, false: 실패)
     */
    public boolean sendMail(String to, String subject, String text) {
        try {
            // Naver SMTP 로 전송
            emailClient.sendNaverEmail(subject, text, to);
            logger.info("email_sent");
            return true;
        } catch (Exception e) {
            logger.warn("email_failed");
            return false;
        }
    }
}
