package com.example.test.auth;

import com.example.test.auth.mapper.AuthMapper;
import com.example.test.config.ExternalServiceUnavailableException;
import com.example.test.libs.Email;
import org.h2.jdbcx.JdbcDataSource;
import org.junit.Before;
import org.junit.After;
import org.junit.Test;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.AutowiredAnnotationBeanPostProcessor;
import org.springframework.context.support.GenericApplicationContext;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.ui.ExtendedModelMap;
import java.lang.reflect.Field;
import java.util.UUID;
import static org.junit.Assert.*;

public class MailFailureTest {
    private JdbcTemplate jdbc;
    private AuthService service;
    private FakeEmail mail;
    private GenericApplicationContext context;
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(4);

    static class FakeEmail extends Email {
        boolean fail = true;
        String body;
        @Override public void requireConfigured() { }
        @Override public void sendNaverEmail(String subject, String content, String to) {
            body = content;
            if (fail) throw new ExternalServiceUnavailableException("synthetic SMTP failure");
        }
    }

    @Before public void setup() throws Exception {
        JdbcDataSource ds = new JdbcDataSource();
        ds.setURL("jdbc:h2:mem:mail_" + UUID.randomUUID() + ";MODE=MariaDB;DB_CLOSE_DELAY=-1");
        jdbc = new JdbcTemplate(ds);
        jdbc.execute("CREATE TABLE users (id BIGINT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(80), password VARCHAR(100), name VARCHAR(80), email VARCHAR(120), phone VARCHAR(40), role VARCHAR(30), is_email_verified BOOLEAN, status BOOLEAN, last_login_at TIMESTAMP, created_at TIMESTAMP, updated_at TIMESTAMP)");
        jdbc.execute("CREATE TABLE student_profiles (user_id BIGINT, student_id VARCHAR(80), department VARCHAR(100), department_code VARCHAR(30), university_name VARCHAR(100), grade INT, admission_year INT, gender VARCHAR(20), birth_date DATE, student_status VARCHAR(30))");
        SqlSessionFactoryBean factory = new SqlSessionFactoryBean();
        factory.setDataSource(ds);
        factory.setMapperLocations(new ClassPathResource("mapper/AuthMapper.xml"));
        AuthMapper mapper = new SqlSessionTemplate(factory.getObject()).getMapper(AuthMapper.class);
        mail = new FakeEmail();
        context = new GenericApplicationContext();
        context.registerBean(AutowiredAnnotationBeanPostProcessor.class);
        context.getBeanFactory().registerSingleton("authMapper", mapper);
        context.getBeanFactory().registerSingleton("email", mail);
        context.getBeanFactory().registerSingleton("passwordEncoder", encoder);
        context.getBeanFactory().registerSingleton("transactionManager", new DataSourceTransactionManager(ds));
        context.registerBean(AuthServiceImpl.class);
        context.refresh();
        service = context.getBean(AuthService.class);
    }

    @After public void cleanup() {
        if (context != null) context.close();
        if (jdbc != null) jdbc.execute("SHUTDOWN");
    }

    private AuthDto applicant() {
        AuthDto dto = new AuthDto(); dto.setUsername("synthetic-student");
        dto.setPassword("synthetic-password"); dto.setName("Synthetic");
        dto.setEmail("synthetic@example.invalid"); dto.setPhone("synthetic-phone");
        dto.setRole("STUDENT"); dto.setDepartment("Test"); return dto;
    }

    @Test public void failedRegistrationMailDoesNotClaimSentAndOffersRetry() throws Exception {
        AuthController controller = new AuthController();
        Field field = AuthController.class.getDeclaredField("authService"); field.setAccessible(true); field.set(controller, service);
        ExtendedModelMap model = new ExtendedModelMap();
        assertEquals("auth/login", controller.register(applicant(), model));
        assertEquals(Boolean.TRUE, model.get("emailVerificationRequired"));
        assertNotNull(model.get("loginError"));
        assertNotEquals(Boolean.TRUE, model.get("emailSent"));
        assertNull(model.get("successMessage"));
        assertEquals(1, jdbc.queryForObject("SELECT COUNT(*) FROM users WHERE is_email_verified=false", Integer.class).intValue());
    }

    @Test public void acceptedRegistrationMailRetainsSuccessFlow() throws Exception {
        mail.fail = false;
        AuthController controller = new AuthController();
        Field field = AuthController.class.getDeclaredField("authService"); field.setAccessible(true); field.set(controller, service);
        ExtendedModelMap model = new ExtendedModelMap();
        assertEquals("auth/register-success", controller.register(applicant(), model));
        assertEquals(Boolean.TRUE, model.get("emailSent"));
        assertNotNull(model.get("successMessage"));
        assertNull(model.get("loginError"));
    }

    @Test public void failedResendKeepsVisibleErrorAndRetryForm() throws Exception {
        AuthController controller = new AuthController();
        Field field = AuthController.class.getDeclaredField("authService"); field.setAccessible(true); field.set(controller, service);
        ExtendedModelMap model = new ExtendedModelMap();
        assertEquals("auth/login", controller.resendVerification("synthetic@example.invalid", model));
        assertNotNull(model.get("loginError"));
        assertEquals(Boolean.TRUE, model.get("emailVerificationRequired"));
        assertEquals("synthetic@example.invalid", model.get("userEmail"));
        assertNull(model.get("message"));
    }

    @Test public void failedVerificationMailCannotLeaveAnUsableToken() {
        jdbc.update("INSERT INTO users(username,email,is_email_verified) VALUES(?,?,false)", "synthetic", "synthetic@example.invalid");
        assertFalse(service.sendEmailVerification("synthetic@example.invalid"));
        java.util.regex.Matcher matcher = java.util.regex.Pattern.compile("token=([0-9a-f-]{36})").matcher(mail.body);
        assertTrue(matcher.find());
        assertFalse(service.verifyEmailToken(matcher.group(1)));
        assertFalse(jdbc.queryForObject("SELECT is_email_verified FROM users", Boolean.class));
    }

    @Test public void smtpFailureRollsBackExistingPassword() {
        String before = encoder.encode("existing-synthetic-password");
        jdbc.update("INSERT INTO users(username,password,email) VALUES(?,?,?)", "synthetic", before, "synthetic@example.invalid");
        try { service.sendTemporaryPassword("synthetic@example.invalid"); fail("SMTP failure must escape transaction"); }
        catch (ExternalServiceUnavailableException expected) { }
        assertEquals(before, jdbc.queryForObject("SELECT password FROM users", String.class));
    }

    @Test public void acceptedMailCommitsOnlyPasswordMatchingSyntheticMessage() {
        jdbc.update("INSERT INTO users(username,password,email) VALUES(?,?,?)", "synthetic", encoder.encode("before"), "synthetic@example.invalid");
        mail.fail = false;
        assertTrue(service.sendTemporaryPassword("synthetic@example.invalid"));
        String sent = mail.body.substring(mail.body.indexOf("<strong>") + 8, mail.body.indexOf("</strong>"));
        assertTrue(encoder.matches(sent, jdbc.queryForObject("SELECT password FROM users", String.class)));
    }

    @Test public void unknownAddressDoesNotGenerateMailOrChangePassword() {
        assertFalse(service.sendTemporaryPassword("missing@example.invalid"));
        assertNull(mail.body);
        assertEquals(0, jdbc.queryForObject("SELECT COUNT(*) FROM users", Integer.class).intValue());
    }
}
