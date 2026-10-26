package com.example.test.deployment;

import com.example.test.auth.*;
import com.example.test.chat.OnlineUserService;
import com.example.test.chat.UserStatusService;
import java.lang.reflect.Field;
import java.lang.reflect.Proxy;
import org.junit.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.ui.ExtendedModelMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import static org.junit.Assert.*;

public class SessionBoundaryTest {
    private void inject(Object target, String name, Object value) throws Exception {
        Field field = target.getClass().getDeclaredField(name);
        field.setAccessible(true); field.set(target, value);
    }

    @Test public void successfulLoginRotatesExistingSessionId() throws Exception {
        AuthDto user = new AuthDto(); user.setId(10L); user.setRole("STUDENT"); user.setName("synthetic");
        AuthController controller = new AuthController();
        inject(controller, "authService", Proxy.newProxyInstance(AuthService.class.getClassLoader(),
                new Class<?>[]{AuthService.class}, (proxy, method, args) -> user));
        inject(controller, "onlineUserService", new OnlineUserService() {
            @Override public void setUserOnline(Long id, String sessionId) { }
        });
        inject(controller, "userStatusService", new UserStatusService() {
            @Override public void setUserOnline(Long id) { }
        });
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/auth/login");
        MockHttpSession session = new MockHttpSession(null, "synthetic-before-login");
        request.setSession(session);
        String before = session.getId();
        assertEquals("redirect:/dashboard", controller.login(new AuthDto(), session, request, new ExtendedModelMap()));
        assertNotEquals(before, session.getId());
        assertSame(user, session.getAttribute("loginUser"));
    }

    @Test public void destructiveAccountActionHasNoGetMapping() throws Exception {
        java.lang.reflect.Method delete = AdminController.class.getMethod("deleteUser", Long.class, jakarta.servlet.http.HttpSession.class);
        assertNull(delete.getAnnotation(GetMapping.class));
        assertNotNull(delete.getAnnotation(PostMapping.class));
    }
}
