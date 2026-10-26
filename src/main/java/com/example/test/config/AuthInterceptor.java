package com.example.test.config;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(@NonNull HttpServletRequest request, 
                             @NonNull HttpServletResponse response, 
                             @NonNull Object handler) throws Exception {
        
        String requestURI = request.getServletPath();
        if (requestURI.isEmpty()) requestURI = request.getRequestURI().substring(request.getContextPath().length());
        requestURI = requestURI.replaceAll(";[^/]*", "");
        if (requestURI.equals("/health") || requestURI.startsWith("/resources/")) {
            return true;
        }
        if (!"GET".equals(request.getMethod()) && requestURI.startsWith("/ai/")
                && !com.example.test.ai.AnthropicApiConfig.isEnabled()) {
            response.setStatus(503);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"AI 기능이 설정되지 않았습니다. 관리자에게 문의하세요.\"}");
            return false;
        }

        
        // 인증 없이 접근 가능한 경로들
        if (requestURI.equals("/auth/login") ||
            requestURI.equals("/auth/register") ||
            requestURI.equals("/auth/find-password") ||
            requestURI.equals("/auth/reset-password") ||
            requestURI.equals("/auth/terms") ||
            requestURI.equals("/auth/privacy") ||
            requestURI.equals("/auth/verify-email") ||
            requestURI.equals("/auth/resend-verification") ||
            requestURI.startsWith("/static/") ||
            requestURI.startsWith("/css/") ||
            requestURI.startsWith("/js/") ||
            requestURI.startsWith("/images/")) {
            return true;
        }
        
        Object user = request.getSession().getAttribute("loginUser");

        if (user == null) {
            response.sendRedirect("/auth/login");
            return false;
        }

        return true;
    }
}
