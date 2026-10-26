package com.example.test.auth;

import com.example.test.auth.mapper.AuthMapper;
import com.example.test.libs.Email;
import com.example.test.mypage.MypageController;
import java.lang.reflect.Field;
import java.util.UUID;
import org.h2.jdbcx.JdbcDataSource;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.AutowiredAnnotationBeanPostProcessor;
import org.springframework.context.support.GenericApplicationContext;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import static org.junit.Assert.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

public class ProfileSecurityTest {
    private JdbcTemplate jdbc;
    private GenericApplicationContext context;
    private MockMvc mvc;

    @Before public void setup() throws Exception {
        JdbcDataSource ds = new JdbcDataSource();
        ds.setURL("jdbc:h2:mem:profile_" + UUID.randomUUID() + ";MODE=MariaDB;DB_CLOSE_DELAY=-1");
        jdbc = new JdbcTemplate(ds);
        jdbc.execute("CREATE TABLE users (id BIGINT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(80), password VARCHAR(100), name VARCHAR(80), email VARCHAR(120), phone VARCHAR(40), role VARCHAR(30), is_email_verified BOOLEAN, status BOOLEAN, last_login_at TIMESTAMP, created_at TIMESTAMP, updated_at TIMESTAMP)");
        jdbc.execute("CREATE TABLE student_profiles (user_id BIGINT, student_id VARCHAR(80), department VARCHAR(100), department_code VARCHAR(30), university_name VARCHAR(100), grade INT, admission_year INT, gender VARCHAR(20), birth_date DATE, student_status VARCHAR(30))");
        jdbc.update("INSERT INTO users(id,username,name,email,phone,role) VALUES(1,'actor','Actor','actor@example.invalid','actor-phone','STUDENT')");
        jdbc.update("INSERT INTO users(id,username,name,email,phone,role) VALUES(2,'victim','Victim','victim@example.invalid','victim-phone','STUDENT')");
        jdbc.update("INSERT INTO student_profiles(user_id,student_id,student_status) VALUES(1,'actor','ACTIVE'),(2,'victim','ACTIVE')");
        SqlSessionFactoryBean factory = new SqlSessionFactoryBean();
        factory.setDataSource(ds);
        factory.setMapperLocations(new ClassPathResource("mapper/AuthMapper.xml"));
        AuthMapper mapper = new SqlSessionTemplate(factory.getObject()).getMapper(AuthMapper.class);
        context = new GenericApplicationContext();
        context.registerBean(AutowiredAnnotationBeanPostProcessor.class);
        context.getBeanFactory().registerSingleton("authMapper", mapper);
        context.getBeanFactory().registerSingleton("email", new Email());
        context.getBeanFactory().registerSingleton("passwordEncoder", new BCryptPasswordEncoder(4));
        context.getBeanFactory().registerSingleton("transactionManager", new DataSourceTransactionManager(ds));
        context.registerBean(AuthServiceImpl.class);
        context.refresh();
        MypageController controller = new MypageController();
        Field field = MypageController.class.getDeclaredField("authService");
        field.setAccessible(true);
        field.set(controller, context.getBean(AuthService.class));
        mvc = MockMvcBuilders.standaloneSetup(controller).build();
    }

    @After public void cleanup() {
        if (context != null) context.close();
        if (jdbc != null) jdbc.execute("SHUTDOWN");
    }

    @Test public void submittedVictimIdAndRoleCannotChangeAnotherAccountOrProfile() throws Exception {
        AuthDto actor = new AuthDto();
        actor.setId(1L); actor.setUsername("actor"); actor.setRole("STUDENT");
        MockHttpSession session = new MockHttpSession();
        session.setAttribute("loginUser", actor);
        mvc.perform(post("/mypage/update-mypage").session(session)
            .param("id", "2").param("username", "victim").param("role", "ADMIN")
            .param("name", "Updated Actor").param("email", "updated@example.invalid")
            .param("phone", "updated-phone")
            .param("studentProfile.userId", "2").param("studentProfile.studentStatus", "DELETED"));
        assertEquals("Victim", jdbc.queryForObject("SELECT name FROM users WHERE id=2", String.class));
        assertEquals("victim@example.invalid", jdbc.queryForObject("SELECT email FROM users WHERE id=2", String.class));
        assertEquals("Updated Actor", jdbc.queryForObject("SELECT name FROM users WHERE id=1", String.class));
        assertEquals("STUDENT", jdbc.queryForObject("SELECT role FROM users WHERE id=1", String.class));
        assertEquals("ACTIVE", jdbc.queryForObject("SELECT student_status FROM student_profiles WHERE user_id=2", String.class));
        assertEquals(Long.valueOf(1), ((AuthDto) session.getAttribute("loginUser")).getId());
    }

    @Test public void anonymousProfileUpdateDoesNotWriteAnyAccount() throws Exception {
        assertEquals("/auth/login", mvc.perform(post("/mypage/update-mypage")
            .param("id", "2").param("name", "Rejected"))
            .andReturn().getResponse().getRedirectedUrl());
        assertEquals("Victim", jdbc.queryForObject("SELECT name FROM users WHERE id=2", String.class));
    }

    @Test public void safeDiagnosticStringExcludesContactAndProfileValues() {
        AuthDto dto = new AuthDto();
        dto.setId(1L); dto.setUsername("synthetic-private-username");
        dto.setName("synthetic-private-name"); dto.setEmail("synthetic-private@example.invalid");
        dto.setPhone("synthetic-private-phone"); dto.setPassword("synthetic-private-password");
        assertFalse(dto.toSafeString().contains("synthetic-private"));
    }
}
