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
    <title>AI 캡스톤디자인 관리시스템 - 비밀번호 찾기</title>
    
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
        
        .find-password-page { 
            display: flex; 
            min-height: 100vh; 
            width: 100vw; 
        }
        
        .find-password-hero {
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
        
        .find-password-hero-content { 
            text-align: center; 
            max-width: 400px; 
            z-index: 2;
            position: relative;
        }
        
        .find-password-hero-title { 
            font-size: 2.5rem; 
            font-weight: 700; 
            margin-bottom: 20px; 
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }
        
        .find-password-hero-subtitle { 
            font-size: 1.1rem; 
            margin-bottom: 40px; 
            line-height: 1.6; 
            opacity: 0.9;
        }
        
        .password-reset-icon {
            width: 80px;
            height: 80px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 30px;
            font-size: 2.5rem;
            z-index: 2;
            position: relative;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .find-password-form-container {
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
        
        .find-password-form-wrapper {
            width: 100%; 
            max-width: 450px; 
            background: var(--light-color);
            border-radius: 16px; 
            box-shadow: 0 10px 30px rgba(85, 110, 230, 0.1);
            padding: 20px; 
            margin: 20px;
            border: 1px solid rgba(85, 110, 230, 0.1);
        }
        
        .find-password-tabs { 
            display: flex; 
            justify-content: center;
            border-bottom: 2px solid #f1f3f4; 
            margin-bottom: 30px; 
        }

        .find-password-tab {
            flex: 1; /* 동일한 너비 */
            text-align: center;
            padding: 12px 0;
            cursor: pointer; 
            color: #6c757d; 
            position: relative; 
            font-size: 0.95rem; 
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            border-radius: 8px 8px 0 0;
        }
        
        .find-password-tab:hover {
            color: var(--primary-color);
            background: rgba(85, 110, 230, 0.05);
        }
        
        .find-password-tab.active { 
            color: var(--primary-color); 
            font-weight: 600; 
            background: rgba(85, 110, 230, 0.1);
        }
        
        .find-password-tab.active::after {
            content: ''; 
            position: absolute; 
            bottom: -2px; 
            left: 0;
            width: 100%; 
            height: 3px; 
            background: linear-gradient(90deg, var(--primary-color), var(--active-purple));
            border-radius: 2px;
        }
        
        .find-password-title {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 8px;
            text-align: center;
            color: var(--text-color);
        }
        
        .find-password-description {
            color: #6c757d;
            font-size: 0.92rem;
            margin-bottom: 18px;
            text-align: center;
            line-height: 1.4;
        }
        
        .alert-info, .alert-danger, .alert-success {
            font-size: 0.92rem;
            padding: 8px 10px;
            margin-bottom: 12px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            font-size: 0.95rem;
            color: var(--text-color);
        }
        
        .form-input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e3e6f0;
            border-radius: 8px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: #fff;
        }
        
        .form-input:focus {
            border-color: var(--primary-color);
            outline: none;
            box-shadow: 0 0 0 3px rgba(85, 110, 230, 0.08);
            transform: translateY(-1px);
        }
        
        .form-input::placeholder {
            color: #adb5bd;
            font-size: 0.9rem;
        }
        
        .find-password-btn {
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
        
        .find-password-btn:hover {
            background: linear-gradient(135deg, var(--active-purple) 0%, var(--primary-color) 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(85, 110, 230, 0.2);
        }
        
        .find-password-btn:active {
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
        
        .login-link {
            text-align: center;
            margin-top: 16px;
            padding-top: 10px;
            border-top: 1px solid #f1f3f4;
        }
        
        .login-link a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            font-size: 0.95rem;
        }
        
        .login-link a:hover {
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
            .find-password-page { 
                flex-direction: column; 
            }
            
            .find-password-hero {
                position: relative; 
                flex: none; 
                height: 40vh; 
                min-height: 300px; 
                width: 100%;
            }
            
            .find-password-hero-title {
                font-size: 2rem;
            }
            
            .find-password-form-container { 
                margin-left: 0; 
                min-height: 60vh; 
                padding: 20px 0; 
            }
            
            .find-password-form-wrapper { 
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
    <div class="find-password-page">
        <div class="find-password-hero">
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
            <div class="password-reset-icon">
                <i class="mdi mdi-lock-reset"></i>
            </div>
            <div class="find-password-hero-content">
                <h1 class="find-password-hero-title">비밀번호 변경</h1>
                <p class="find-password-hero-subtitle">
                    계정 정보를 확인하여<br>안전하게 비밀번호를 재설정하세요
                </p>
            </div>
        </div>
        
        <div class="find-password-form-container">
            <div class="find-password-form-wrapper">
                <div class="find-password-tabs">
                    <a href="/auth/login" class="find-password-tab">로그인</a>
                    <a href="/auth/register" class="find-password-tab">회원가입</a>
                    <a href="/auth/find-password" class="find-password-tab active">비밀번호 찾기</a>
                </div>
                
                <h2 class="find-password-title">비밀번호 찾기</h2>
                <p class="find-password-description">계정 확인을 위해 등록된 정보를 입력해주세요.</p>
                
                <c:if test="${not empty findPasswordError}">
                    <div class="alert-danger">
                        ${findPasswordError}
                    </div>
                </c:if>
                
                <c:if test="${not empty message}">
                    <div class="alert-success">
                        ${message}
                    </div>
                </c:if>

                <form action="/auth/find-password" method="post" id="findPasswordForm">
                    <div class="form-group">
                        <label class="form-label">이름</label>
                        <input type="text" class="form-input" name="name" required
                               placeholder="이름을 입력하세요">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">학번/교번</label>
                        <input type="text" class="form-input" name="username" required
                               placeholder="학번 또는 교번을 입력하세요">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">이메일</label>
                        <input type="email" class="form-input" name="email" required
                               placeholder="계정에 등록된 이메일을 입력하세요">
                    </div>
                    
                    <button type="submit" class="find-password-btn">
                        <i class="mdi mdi-email-send-outline me-2"></i>
                        인증코드 발송
                    </button>
                </form>
                
                <div class="login-link">
                    <p>비밀번호가 기억나셨나요? <a href="/auth/login">로그인</a></p>
                </div>
                <div class="footer-text">
                    ⓒ 2025 AI 캡스톤디자인 시스템 | by 4차산업연구회 팀
                </div>
            </div>
        </div>
    </div>

    <script>
        // 폼 유효성 검사
        document.getElementById('findPasswordForm').addEventListener('submit', function(e) {
            const name = document.querySelector('input[name="name"]').value.trim();
            const username = document.querySelector('input[name="username"]').value.trim();
            const email = document.querySelector('input[name="email"]').value.trim();
            
            if (!name || !username || !email) {
                e.preventDefault();
                alert('모든 필드를 입력해주세요.');
                return false;
            }
            
            // 이메일 형식 검증
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                e.preventDefault();
                alert('올바른 이메일 주소를 입력해주세요.');
                return false;
            }
        });
        
        
        
        // 버튼 호버 효과
        document.querySelector('.find-password-btn').addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-2px) scale(1.02)';
        });
        
        document.querySelector('.find-password-btn').addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(-2px) scale(1)';
        });
    </script>
</body>
</html>