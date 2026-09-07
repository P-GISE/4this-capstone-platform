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
        
        String requestURI = request.getRequestURI();
        
        // 인증 없이 접근 가능한 경로들
        if (requestURI.startsWith("/auth/login") || 
            requestURI.startsWith("/auth/register") || 
            requestURI.startsWith("/auth/find-password") ||
            requestURI.startsWith("/auth/terms") ||           // 이용약관
            requestURI.startsWith("/auth/privacy") ||         // 개인정보 처리방침
            requestURI.startsWith("/auth/verify-email") ||    // 이메일 인증
            requestURI.startsWith("/auth/resend-verification") || // 이메일 재발송
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
