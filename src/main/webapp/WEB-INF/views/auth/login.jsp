<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Calendar" %>
<%
    Calendar calendar = Calendar.getInstance();
    int year = calendar.get(Calendar.YEAR);
    request.setAttribute("currentYear", year);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI 캡스톤디자인 관리시스템 - 로그인</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Material Design Icons -->
    <link href="https://cdn.jsdelivr.net/npm/@mdi/font@7.2.96/css/materialdesignicons.min.css" rel="stylesheet">
    <!-- Box Icons -->
    <link href="https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css" rel="stylesheet">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary-color: #556ee6;
            --secondary-color: #e9eaff;
            --dark-color: #1e1e1e;
            --light-color: #ffffff;
            --accent-color: #ff7043;
            --grey-color: #f5f5f7;
            --text-color: #495057;
            --light-purple: #e9e6ff;
            --active-purple: #4861d9;
            --border-color: #dee2e6;
            --button-color: #f0f2f5;
            --success-color: #28a745;
            --danger-color: #dc3545;
        }
        
        * { 
            box-sizing: border-box; 
            margin: 0; 
            padding: 0; 
            font-family: 'Noto Sans KR', sans-serif; 
        }
        
        body { 
            margin: 0; 
            padding: 0; 
            min-height: 100vh; 
            width: 100vw; 
        }
        
        .login-page { 
            display: flex; 
            min-height: 100vh; 
            width: 100vw; 
        }
        
        .login-hero {
            flex: 1; 
            background: linear-gradient(45deg, #405de6, #5851db, #833ab4, #c13584, #e1306c, #fd1d1d);
            background-size: 400% 400%;
            animation: gradientBG 15s ease infinite;
            color: white;
            display: flex; 
            flex-direction: column; 
            justify-content: center; 
            align-items: center;
            padding: 40px; 
            position: fixed; 
            left: 0; 
            top: 0; 
            height: 100vh; 
            width: 50%;
            overflow: hidden;
        }
        
        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }
        
        .bg-bubbles {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            overflow: hidden;
            z-index: 1;
            list-style: none;
            margin: 0;
            padding: 0;
        }
        
        .bg-bubbles li {
            position: absolute;
            display: block;
            list-style: none;
            width: 20px;
            height: 20px;
            background: rgba(255, 255, 255, 0.15);
            animation: animate 25s linear infinite;
            bottom: -150px;
            border-radius: 50%;
        }
        
        .bg-bubbles li:nth-child(1) { left: 25%; width: 80px; height: 80px; animation-delay: 0s; }
        .bg-bubbles li:nth-child(2) { left: 10%; width: 20px; height: 20px; animation-delay: 2s; animation-duration: 12s; }
        .bg-bubbles li:nth-child(3) { left: 70%; width: 20px; height: 20px; animation-delay: 4s; }
        .bg-bubbles li:nth-child(4) { left: 40%; width: 60px; height: 60px; animation-delay: 0s; animation-duration: 18s; }
        .bg-bubbles li:nth-child(5) { left: 65%; width: 20px; height: 20px; animation-delay: 0s; }
        .bg-bubbles li:nth-child(6) { left: 75%; width: 110px; height: 110px; animation-delay: 3s; }
        .bg-bubbles li:nth-child(7) { left: 35%; width: 150px; height: 150px; animation-delay: 7s; }
        .bg-bubbles li:nth-child(8) { left: 50%; width: 25px; height: 25px; animation-delay: 15s; animation-duration: 45s; }
        .bg-bubbles li:nth-child(9) { left: 20%; width: 15px; height: 15px; animation-delay: 2s; animation-duration: 35s; }
        .bg-bubbles li:nth-child(10) { left: 85%; width: 150px; height: 150px; animation-delay: 0s; animation-duration: 11s; }
        
        @keyframes animate {
            0% { transform: translateY(0) rotate(0deg); opacity: 1; border-radius: 0; }
            100% { transform: translateY(-1000px) rotate(720deg); opacity: 0; border-radius: 50%; }
        }
        
        .login-hero-content { 
            text-align: center; 
            max-width: 400px; 
            z-index: 2;
            position: relative;
        }
        
        .login-hero-title { 
            font-size: 2.5rem; 
            font-weight: 700; 
            margin-bottom: 20px; 
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }
        
        .login-hero-subtitle { 
            font-size: 1.1rem; 
            margin-bottom: 40px; 
            line-height: 1.6; 
            opacity: 0.9;
        }
        
        .login-form-container {
            flex: 1; 
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            display: flex; 
            justify-content: center; 
            align-items: center;
            padding: 20px 0; 
            margin-left: 50%; 
            min-height: 100vh; 
            overflow-y: auto;
        }
        
        .login-form-wrapper {
            width: 100%; 
            max-width: 450px; 
            background: var(--light-color);
            border-radius: 16px; 
            box-shadow: 0 10px 30px rgba(85, 110, 230, 0.1);
            padding: 20px; 
            margin: 20px;
            border: 1px solid rgba(85, 110, 230, 0.1);
        }
        
        .login-tabs { 
            display: flex; 
            justify-content: center; /* 가로 중앙 정렬 */
            border-bottom: 2px solid #f1f3f4; 
            margin-bottom: 30px; 
        }

        .login-tab {
            flex: 1; /* 동일한 너비 */
            text-align: center;
            padding: 12px 0; /* 좌우 padding 제거 */
            cursor: pointer; 
            color: #6c757d; 
            position: relative; 
            font-size: 0.95rem; 
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            border-radius: 8px 8px 0 0;
        }
        
        .login-tab:hover {
            color: var(--primary-color);
            background: rgba(85, 110, 230, 0.05);
        }
        
        .login-tab.active { 
            color: var(--primary-color); 
            font-weight: 600; 
            background: rgba(85, 110, 230, 0.1);
        }
        
        .login-tab.active::after {
            content: ''; 
            position: absolute; 
            bottom: -2px; 
            left: 0;
            width: 100%; 
            height: 3px; 
            background: linear-gradient(90deg, var(--primary-color), var(--active-purple));
            border-radius: 2px;
        }
        
        .login-title {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 8px;
            text-align: center;
            color: var(--text-color);
        }
        
        .login-description { 
            color: #6c757d; 
            font-size: 1rem; 
            margin-bottom: 30px; 
            text-align: center; 
            line-height: 1.5;
        }
        
        .form-group { 
            margin-bottom: 10px; 
        }
        
        .form-label { 
            display: block; 
            margin-bottom: 8px; 
            font-weight: 600; 
            font-size: 0.95rem; 
            color: var(--text-color); 
        }
        
        .form-input {
            width: 100%; 
            padding: 10px 12px; 
            border: 2px solid #e3e6f0;
            border-radius: 8px; 
            font-size: 0.9rem;
            transition: all 0.3s ease;
            background: #fff;
        }
        
        .form-input:focus { 
            border-color: var(--primary-color); 
            outline: none; 
            box-shadow: 0 0 0 3px rgba(85, 110, 230, 0.1);
            transform: translateY(-1px);
        }
        
        .form-input::placeholder { 
            color: #adb5bd; 
        }
        
        .input-group {
            position: relative;
        }
        
        .password-toggle {
            position: absolute;
            right: 12px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #6c757d;
            cursor: pointer;
            padding: 4px;
            border-radius: 4px;
            transition: all 0.3s ease;
        }
        
        .password-toggle:hover {
            color: var(--primary-color);
            background: rgba(85, 110, 230, 0.1);
        }
        
        .login-btn {
            width: 100%;
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--active-purple) 100%);
            color: white;
            border: none;
            padding: 10px 0;
            border-radius: 6px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            margin-top: 12px;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(85, 110, 230, 0.15);
        }
        
        .login-btn:hover { 
            background: linear-gradient(135deg, var(--active-purple) 0%, var(--primary-color) 100%);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(85, 110, 230, 0.4);
        }
        
        .login-btn:active {
            transform: translateY(0);
        }
        
        .error { 
            color: var(--danger-color); 
            font-size: 0.85rem; 
            margin-top: 6px; 
        }
        
        .error-popup, .alert-danger {
            color: var(--danger-color); 
            font-size: 0.95rem; 
            margin-bottom: 20px; 
            text-align: center;
            padding: 12px 16px; 
            background: #f8d7da; 
            border: 1px solid #f5c6cb; 
            border-radius: 8px;
            border-left: 4px solid var(--danger-color);
        }
        
        .alert-success {
            color: var(--success-color); 
            font-size: 0.95rem; 
            margin-bottom: 20px; 
            text-align: center; 
            padding: 12px 16px; 
            background: #d4edda; 
            border: 1px solid #c3e6cb; 
            border-radius: 8px;
            border-left: 4px solid var(--success-color);
        }
        
        
        
        .signup-link {
            text-align: center;
            margin-top: 25px;
            padding-top: 20px;
            border-top: 1px solid #f1f3f4;
        }
        
        .signup-link a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .signup-link a:hover {
            color: var(--active-purple);
            text-decoration: underline;
        }
        
        .footer-text {
            position: static; /* 기본 흐름으로 */
            margin-top: 30px;
            text-align: center;
            color: rgba(0, 0, 0, 0.6);
            font-size: 0.9rem;
        }
        .footer-text i {
            color: #ff6b6b;
            animation: heartbeat 1.5s ease-in-out infinite;
        } 
        
        @keyframes heartbeat {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }
        
        @media (max-width: 768px) {
            .login-page { 
                flex-direction: column; 
            }
            
            .login-hero {
                position: relative; 
                flex: none; 
                height: 40vh; 
                min-height: 300px; 
                width: 100%;
            }
            
            .login-hero-title {
                font-size: 2rem;
            }
            
            .login-form-container { 
                margin-left: 0; 
                min-height: 60vh; 
                padding: 20px 0; 
            }
            
            .login-form-wrapper { 
                margin: 0 20px; 
                max-width: none; 
                padding: 30px 25px;
            }
            
            .footer-text {
                position: relative;
                bottom: auto;
                left: 50%;                /* ✅ 추가 */
                transform: translateX(-50%); /* ✅ 추가 */
                margin-top: 20px;
                text-align: center;
            }

            
        }
    </style>
</head>
<body>
    <div class="login-page">
        <div class="login-hero">
            <ul class="bg-bubbles">
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
                <li></li>
            </ul>
            <div class="login-hero-content">
                <h1 class="login-hero-title">AI 캡스톤디자인<br>관리시스템</h1>
                <p class="login-hero-subtitle">
                    AI 기술을 활용한 프로젝트 추천 및<br>캡스톤디자인 관리를 위한 통합 플랫폼
                </p>
            </div>
        </div>
        
        <div class="login-form-container">
            <div class="login-form-wrapper">
                <div class="login-tabs">
                    <a href="/auth/login" class="login-tab active">로그인</a>
                    <a href="/auth/register" class="login-tab">회원가입</a>
                    <a href="/auth/find-password" class="login-tab">비밀번호 찾기</a>
                </div>
                
                <h2 class="login-title">환영합니다!</h2>
                <p class="login-description">계정 정보를 입력하여 로그인해주세요.</p>
                
                <c:if test="${not empty loginError}">
                    <div class="alert-danger">
                        ${loginError}
                        <c:if test="${emailVerificationRequired}">
                            <form action="/auth/resend-verification" method="post" style="margin-top: 10px; display: inline;">
                                <input type="hidden" name="email" value="${userEmail}">
                                <button type="submit" style="background: none; border: none; color: var(--primary-color); text-decoration: underline; cursor: pointer; font-size: 0.9rem;">
                                    인증 이메일 재발송
                                </button>
                            </form>
                        </c:if>
                    </div>
                </c:if>
                
                <c:if test="${not empty message}">
                    <div class="alert-success">
                        ${message}
                    </div>
                </c:if>

                <form action="/auth/login" method="post" id="loginForm">
                    <div class="form-group">
                        <label class="form-label">학번/교번</label>
                        <input type="text" class="form-input" name="username" required
                               placeholder="학번 또는 교번을 입력하세요">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">비밀번호</label>
                        <div class="input-group">
                            <input type="password" class="form-input" name="password" id="password" required
                                   placeholder="비밀번호를 입력하세요">
                            <button type="button" class="password-toggle" id="password-toggle">
                                <i class="mdi mdi-eye-off-outline"></i>
                            </button>
                        </div>
                        <div style="text-align: right; margin-top: 8px;">
                            <a href="/auth/find-password" style="color: #6c757d; text-decoration: none; font-size: 0.9rem;">비밀번호를 잊으셨나요?</a>
                        </div>
                    </div>
                    
                    <button type="submit" class="login-btn">로그인</button>
                </form>
                
                
                <div class="signup-link">
                    <p>계정이 없으신가요? <a href="/auth/register">회원가입</a></p>
                </div>
                <div class="footer-text">
                    ⓒ 2025 AI 캡스톤디자인 시스템 | by 4차산업연구회 팀
                </div>
            </div>
        </div>
    </div>

    <script>
        // 비밀번호 표시/숨기기 토글
        document.getElementById('password-toggle').addEventListener('click', function() {
            const passwordField = document.getElementById('password');
            const icon = this.querySelector('i');
            
            if (passwordField.type === 'password') {
                passwordField.type = 'text';
                icon.className = 'mdi mdi-eye-outline';
            } else {
                passwordField.type = 'password';
                icon.className = 'mdi mdi-eye-off-outline';
            }
        });

        // 폼 유효성 검사
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            const username = document.querySelector('input[name="username"]').value.trim();
            const password = document.querySelector('input[name="password"]').value.trim();
            
            if (!username || !password) {
                e.preventDefault();
                alert('학번/교번과 비밀번호를 모두 입력해주세요.');
                return false;
            }
        });
        
        // 소셜 로그인 버튼 호버 효과
        document.querySelectorAll('.social-btn').forEach(btn => {
            btn.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-2px) scale(1.05)';
            });
            
            btn.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(0) scale(1)';
            });
        });
    </script>
</body>
</html>
