package com.example.test.deployment;

import com.example.test.auth.AuthDto;
import com.example.test.config.DeploymentSecurityFilter;
import com.example.test.config.AuthInterceptor;
import org.junit.Test;
import org.springframework.mock.web.MockFilterChain;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import static org.junit.Assert.*;

public class DeploymentSecurityTest {
    private int run(String method, String path, String origin, String referer, String role) throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest(method, path);
        if (origin != null) request.addHeader("Origin", origin);
        if (referer != null) request.addHeader("Referer", referer);
        if (role != null) {
            AuthDto user = new AuthDto(); user.setId(10L); user.setRole(role);
            request.getSession().setAttribute("loginUser", user);
        }
        MockHttpServletResponse response = new MockHttpServletResponse();
        new DeploymentSecurityFilter("https://4this.example.invalid").doFilter(request, response, new MockFilterChain());
        return response.getStatus();
    }

    @Test public void writesRequireExactOriginIncludingLogin() throws Exception {
        assertEquals(403, run("POST", "/auth/login", "https://evil.example.invalid", null, null));
        assertEquals(403, run("POST", "/projects/create", null, null, "STUDENT"));
        assertEquals(403, run("POST", "/projects/create", "null", "https://4this.example.invalid/projects", "STUDENT"));
        assertEquals(200, run("POST", "/projects/create", "https://4this.example.invalid", null, "STUDENT"));
        assertEquals(200, run("POST", "/projects/create", null, "https://4this.example.invalid/projects", "STUDENT"));
        assertEquals(403, run("POST", "/projects/create", null, "https://4this.example.invalid.evil.invalid/", "STUDENT"));
    }

    @Test public void legacyDebugCannotExposeOrMoveOtherUsersData() throws Exception {
        for (String path : new String[]{"/ai/update-question-user-id", "/ai/test-questions", "/ai/test-db", "/chat/debug/all-projects"}) {
            assertEquals(404, run("GET", path, null, null, "ADMIN"));
        }
    }

    @Test public void administratorBoundaryPreservesArchiveStaffPermission() throws Exception {
        assertEquals(403, run("GET", "/admin/users", null, null, "STUDENT"));
        assertEquals(403, run("GET", "/equipmentrental/admin/pending", null, null, "STUDENT"));
        assertEquals(200, run("GET", "/admin/users", null, null, "ADMIN"));
        assertEquals(200, run("GET", "/archive/admin/pending", null, null, "STAFF"));
        assertEquals(403, run("GET", "/admin/users", null, null, "STAFF"));
    }

    @Test public void normalizedProtectedRouteCannotBorrowLoginPrefix() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/auth/login/../projects/20");
        request.setServletPath("/projects/20");
        assertFalse(new AuthInterceptor().preHandle(request, new MockHttpServletResponse(), new Object()));
    }
}
