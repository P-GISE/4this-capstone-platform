package com.example.test.libs;

import com.example.test.config.ExternalServiceUnavailableException;
import java.util.Properties;
import java.util.Map;
import java.util.HashMap;
import java.util.Collections;
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
    private final Map<String, String> environment;

    public Email() { this(System.getenv()); }

    Email(Map<String, String> environment) {
        this.environment = Collections.unmodifiableMap(new HashMap<>(environment));
    }

    public void requireConfigured() { smtpProperties(); }

    Properties smtpProperties() {
        if (!"true".equalsIgnoreCase(environment.get("EMAIL_ENABLED"))) throw unavailable();
        for (String key : new String[]{"SMTP_HOST", "SMTP_USERNAME", "SMTP_PASSWORD", "SMTP_FROM", "SMTP_SECURITY", "SMTP_PORT"}) {
            String value = environment.get(key);
            if (value == null || value.trim().isEmpty() || value.contains("\r") || value.contains("\n")) throw unavailable();
        }
        String mode = environment.get("SMTP_SECURITY");
        if (!"ssl".equals(mode) && !"starttls".equals(mode)) throw unavailable();
        String port = environment.get("SMTP_PORT");
        if (!port.matches("[0-9]{1,5}") || Integer.parseInt(port) < 1 || Integer.parseInt(port) > 65535) throw unavailable();
        if (!environment.get("SMTP_HOST").matches("[A-Za-z0-9](?:[A-Za-z0-9.-]*[A-Za-z0-9])?")) throw unavailable();
        try { new InternetAddress(environment.get("SMTP_FROM"), true).validate(); }
        catch (javax.mail.internet.AddressException invalid) { throw unavailable(); }
        boolean ssl = "ssl".equals(mode);
        Properties properties = new Properties();
        properties.setProperty("mail.smtp.host", environment.get("SMTP_HOST"));
        properties.setProperty("mail.smtp.port", port);
        properties.setProperty("mail.smtp.auth", "true");
        properties.setProperty("mail.smtp.ssl.enable", Boolean.toString(ssl));
        properties.setProperty("mail.smtp.starttls.enable", Boolean.toString(!ssl));
        properties.setProperty("mail.smtp.starttls.required", Boolean.toString(!ssl));
        properties.setProperty("mail.smtp.ssl.checkserveridentity", "true");
        properties.setProperty("mail.smtp.connectiontimeout", "10000");
        properties.setProperty("mail.smtp.timeout", "10000");
        properties.setProperty("mail.smtp.writetimeout", "10000");
        return properties;
    }

    private ExternalServiceUnavailableException unavailable() {
        return new ExternalServiceUnavailableException("메일 기능이 설정되지 않았습니다. 관리자에게 문의하세요.");
    }

    public void sendNaverEmail(String subject, String content, String to) {
        Properties properties = smtpProperties();
        Session session = Session.getInstance(properties, new Authenticator() {
            @Override protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(environment.get("SMTP_USERNAME"), environment.get("SMTP_PASSWORD"));
            }
        });
        try {
            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(environment.get("SMTP_FROM")));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
            message.setSubject(subject, "UTF-8");
            message.setContent(content, "text/html; charset=UTF-8");
            Transport.send(message);
        } catch (MessagingException failure) {
            throw new ExternalServiceUnavailableException("메일을 보내지 못했습니다. 잠시 후 다시 시도하세요.");
        }
    }
}
