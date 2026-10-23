package com.example.test.libs;

import com.example.test.config.ExternalServiceUnavailableException;
import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import org.springframework.stereotype.Component;

@Component
public class Email {
    public void requireConfigured() {
        if (!"true".equalsIgnoreCase(System.getenv("EMAIL_ENABLED"))
                || missing("SMTP_HOST") || missing("SMTP_USERNAME")
                || missing("SMTP_PASSWORD") || missing("SMTP_FROM")) {
            throw new ExternalServiceUnavailableException("메일 기능이 설정되지 않았습니다. 관리자에게 문의하세요.");
        }
    }

    private boolean missing(String name) {
        String value = System.getenv(name);
        return value == null || value.trim().isEmpty();
    }

    public void sendNaverEmail(String subject, String content, String to) {
        requireConfigured();
        Properties properties = new Properties();
        properties.setProperty("mail.smtp.host", System.getenv("SMTP_HOST"));
        properties.setProperty("mail.smtp.port", System.getenv().getOrDefault("SMTP_PORT", "587"));
        properties.setProperty("mail.smtp.auth", "true");
        properties.setProperty("mail.smtp.starttls.enable", "true");
        properties.setProperty("mail.smtp.starttls.required", "true");
        properties.setProperty("mail.smtp.ssl.checkserveridentity", "true");
        properties.setProperty("mail.smtp.connectiontimeout", "10000");
        properties.setProperty("mail.smtp.timeout", "10000");
        properties.setProperty("mail.smtp.writetimeout", "10000");
        Session session = Session.getInstance(properties, new Authenticator() {
            @Override protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(System.getenv("SMTP_USERNAME"), System.getenv("SMTP_PASSWORD"));
            }
        });
        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(System.getenv("SMTP_FROM")));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject, "UTF-8");
            message.setContent(content, "text/html; charset=UTF-8");
            Transport.send(message);
        } catch (MessagingException failure) {
            throw new ExternalServiceUnavailableException("메일을 보내지 못했습니다. 잠시 후 다시 시도하세요.");
        }
    }
}
