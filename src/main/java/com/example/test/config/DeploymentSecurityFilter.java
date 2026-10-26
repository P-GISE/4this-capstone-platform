package com.example.test.config;
import java.io.IOException;
import java.net.URI;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.example.test.auth.AuthDto;
public class DeploymentSecurityFilter implements Filter {
    private final String origin;
    public DeploymentSecurityFilter() { this(System.getenv("APP_ORIGIN")); }
    public DeploymentSecurityFilter(String origin) {
        if (origin == null || !origin.equals(originOf(origin))) {
            throw new IllegalArgumentException("APP_ORIGIN must be an exact HTTP(S) origin without a path");
        }
        this.origin = origin;
    }

    private static String originOf(String value) {
        try {
            URI uri = URI.create(value);
            if (!("https".equals(uri.getScheme()) || "http".equals(uri.getScheme()))
                    || uri.getHost() == null || uri.getUserInfo() != null) return "";
            return uri.getScheme() + "://" + uri.getHost()
                    + (uri.getPort() == -1 ? "" : ":" + uri.getPort());
        } catch (IllegalArgumentException invalid) { return ""; }
    }

    @Override public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest http = (HttpServletRequest) request;
        HttpServletResponse out = (HttpServletResponse) response;
        String path = http.getServletPath();
        if (path.isEmpty()) path = http.getRequestURI().substring(http.getContextPath().length());
        path = path.replaceAll(";[^/]*", "");
        if (path.startsWith("/ai/test-") || path.equals("/ai/update-question-user-id")
                || path.startsWith("/chat/debug/") || path.startsWith("/chat/test/")
                || path.equals("/chat/admin/debug-online-users")
                || path.equals("/special-rental/admin/test-simple")) {
            out.sendError(404); return;
        }
        String method = http.getMethod();
        if (!("GET".equals(method) || "HEAD".equals(method) || "OPTIONS".equals(method))) {
            String source = http.getHeader("Origin");
            boolean trusted = source != null ? origin.equals(source)
                    : origin.equals(originOf(http.getHeader("Referer") == null ? "" : http.getHeader("Referer")));
            if (!trusted) { out.sendError(403); return; }
        }
        if (path.matches(".*(?:^|/)admin(?:/.*)?")) {
            HttpSession session = http.getSession(false);
            Object principal = session == null ? null : session.getAttribute("loginUser");
            String role = principal instanceof AuthDto ? ((AuthDto) principal).getRole() : "";
            boolean staffArchive = path.startsWith("/archive/admin/")
                    && ("STAFF".equals(role) || "ASSISTANT".equals(role));
            if (!"ADMIN".equals(role) && !staffArchive) { out.sendError(403); return; }
        }
        chain.doFilter(request, response);
    }
}
