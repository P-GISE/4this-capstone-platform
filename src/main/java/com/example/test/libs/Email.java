package com.example.test.libs;

import java.util.Properties;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component  // ← 이 어노테이션을 추가해서 스캔 대상에 포함
public class Email {

    private static final Logger logger = LoggerFactory.getLogger(Email.class);
    
    private final String mailFrom    = "paki516@naver.com";
    private final String appPassword = "NCBUEXVLY7CC";

    public void sendNaverEmail(String mailSubject, String mailContent, String mailTo) {
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.naver.com");
        props.put("mail.smtp.port", "587");  // 네이버 권장 포트
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");  // TLS 사용
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.ssl.trust", "smtp.naver.com");
        
        // 연결 타임아웃 설정
        props.put("mail.smtp.connectiontimeout", "10000");
        props.put("mail.smtp.timeout", "10000");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(mailFrom, appPassword);
            }
        });

        try {
            MimeMessage msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(mailFrom));
            msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(mailTo));
            msg.setSubject(mailSubject, "UTF-8");
            msg.setContent(mailContent, "text/html; charset=utf-8");

            Transport.send(msg);
            logger.info("✅ 네이버 메일 전송 완료: to={}, subject={}", mailTo, mailSubject);
        } catch (MessagingException e) {
            logger.error("❌ 네이버 메일 전송 실패: to={}, subject={}, error={}", mailTo, mailSubject, e.getMessage(), e);
        }
    }
}
