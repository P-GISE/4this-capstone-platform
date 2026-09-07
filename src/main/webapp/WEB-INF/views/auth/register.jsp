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
    <title>AI 캡스톤디자인 관리시스템 - 회원가입</title>
    
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
        
        .register-page { 
            display: flex; 
            min-height: 100vh; 
            width: 100vw; 
        }
        
        .register-hero {
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
        
        .register-hero-content { 
            text-align: center; 
            max-width: 400px; 
            z-index: 2;
            position: relative;
        }
        
        .register-hero-title { 
            font-size: 2.5rem; 
            font-weight: 700; 
            margin-bottom: 20px; 
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }
        
        .register-hero-subtitle { 
            font-size: 1.1rem; 
            margin-bottom: 40px; 
            line-height: 1.6; 
            opacity: 0.9;
        }
        
        .register-form-container {
            flex: 1; 
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            display: flex; 
            justify-content: center; 
            align-items: flex-start;
            padding: 20px 0; 
            margin-left: 50%; 
            min-height: 100vh; 
            overflow-y: auto;
        }
        
        .register-form-wrapper {
            width: 100%; 
            max-width: 450px; 
            background: var(--light-color);
            border-radius: 16px; 
            box-shadow: 0 10px 30px rgba(85, 110, 230, 0.1);
            padding: 20px; 
            margin: 20px;
            border: 1px solid rgba(85, 110, 230, 0.1);
        }
        
        .register-tabs { 
            display: flex; 
            justify-content: center; /* 가로 중앙 정렬 */
            border-bottom: 2px solid #f1f3f4; 
            margin-bottom: 30px; 
        }

        .register-tab {
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
        
        .register-tab:hover {
            color: var(--primary-color);
            background: rgba(85, 110, 230, 0.05);
        }
        
        .register-tab.active { 
            color: var(--primary-color); 
            font-weight: 600; 
            background: rgba(85, 110, 230, 0.1);
        }
        
        .register-tab.active::after {
            content: ''; 
            position: absolute; 
            bottom: -2px; 
            left: 0;
            width: 100%; 
            height: 3px; 
            background: linear-gradient(90deg, var(--primary-color), var(--active-purple));
            border-radius: 2px;
        }
        
        .register-title {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 8px;
            text-align: center;
            color: var(--text-color);
        }
        
        .register-description { 
            color: #6c757d; 
            font-size: 1rem; 
            margin-bottom: 30px; 
            text-align: center; 
            line-height: 1.5;
        }
        
        .form-group { 
            margin-bottom: 10px; 
        }

        .form-row {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .form-row .form-group {
            flex: 1;
        }
        
        .form-label { 
            display: block; 
            margin-bottom: 4px; 
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
        
        .radio-group { 
            display: flex; 
            gap: 15px; 
            margin-top: 8px; 
            flex-wrap: wrap; 
        }
        
        .radio-group label { 
            font-weight: 500; 
            display: flex; 
            align-items: center; 
            font-size: 0.95rem; 
            color: var(--text-color);
            cursor: pointer;
            border: none;
            padding: 0;
            background: none;
        }

        .radio-group label:hover {
            color: var(--primary-color);
        }

        .radio-group input[type="radio"] {
            margin-right: 6px;
            accent-color: var(--primary-color);
        }
        
        .checkbox-label {
            display: flex; 
            align-items: flex-start; 
            margin-top: 15px; 
            font-size: 0.95rem; 
            line-height: 1.5;
            color: var(--text-color);
        }
        
        .checkbox-label input[type="checkbox"] { 
            margin-right: 10px; 
            margin-top: 3px; 
            width: auto; 
            accent-color: var(--primary-color);
        }
        
        .checkbox-label a { 
            color: var(--primary-color); 
            text-decoration: none; 
            font-weight: 600;
        }
        
        .checkbox-label a:hover { 
            text-decoration: underline; 
        }
        
        .register-btn {
            width: 100%; 
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--active-purple) 100%);
            color: white;
            border: none; 
            padding: 16px; 
            border-radius: 8px; 
            font-size: 1.1rem; 
            font-weight: 600; 
            cursor: pointer;
            margin-top: 20px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(85, 110, 230, 0.3);
        }
        
        .register-btn:hover { 
            background: linear-gradient(135deg, var(--active-purple) 0%, var(--primary-color) 100%);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(85, 110, 230, 0.4);
        }
        
        .register-btn:active {
            transform: translateY(0);
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
        
        .error { 
            color: var(--danger-color); 
            font-size: 0.55rem; 
            margin-top: 4px; 
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
        
        
        .login-link {
            text-align: center;
            margin-top: 25px;
            padding-top: 20px;
            border-top: 1px solid #f1f3f4;
        }
        
        .login-link a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
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
            .register-page { 
                flex-direction: column; 
            }
            
            .register-hero {
                position: relative; 
                flex: none; 
                height: 40vh; 
                min-height: 300px; 
                width: 100%;
            }
            
            .register-hero-title {
                font-size: 2rem;
            }
            
            .register-form-container { 
                margin-left: 0; 
                min-height: 60vh; 
                padding: 20px 0; 
            }
            
            .register-form-wrapper { 
                margin: 0 20px; 
                max-width: none; 
                padding: 30px 25px;
            }
            
            .radio-group { 
                flex-direction: column; 
                gap: 10px; 
            }
            
            .footer-text {
                position: relative;
                bottom: auto;
                transform: none;
                margin-top: 20px;
                text-align: center;
            }
        }

        .register-form-fields {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px 24px;
        }
        .register-form-fields .form-group {
            margin-bottom: 0;
        }
        /* 마지막 줄은 1칸만 차지하도록 */
        .register-form-fields .form-group.full-width {
            grid-column: 1 / 3;
        }
        @media (max-width: 900px) {
            .register-form-fields {
                grid-template-columns: 1fr;
                gap: 14px 0;
            }
            .register-form-fields .form-group.full-width {
                grid-column: 1 / 2;
            }
        }

        .department-row {
            display: flex;
            gap: 10px;
        }
        .department-row input,
        .department-row select {
            height: 48px;
            padding: 0 16px;
            font-size: 1rem;
            box-sizing: border-box;
        }
        @media (max-width: 700px) {
            .department-row {
                flex-direction: column;
                gap: 8px;
            }
        }
    </style>
    
    <c:if test="${not empty errorCode}">
        <script>
            let errorMessage = '';
            switch('${errorCode}') {
                case 'DUPLICATE_USERNAME': errorMessage = '이미 사용 중인 학번/교번입니다.'; break;
                case 'DUPLICATE_EMAIL':    errorMessage = '이미 사용 중인 이메일입니다.'; break;
                case 'DUPLICATE_PHONE':    errorMessage = '이미 사용 중인 전화번호입니다.'; break;
                case 'FAILURE':            errorMessage = '회원가입 중 오류가 발생했습니다.'; break;
                default:                   errorMessage = '회원가입에 실패했습니다.';
            }
            alert(errorMessage);
        </script>
    </c:if>
</head>
<body>
    <div class="register-page">
        <div class="register-hero">
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
            <div class="register-hero-content">
                <h1 class="register-hero-title">AI 캡스톤디자인<br>관리시스템</h1>
                <p class="register-hero-subtitle">
                    AI 기술을 활용한 프로젝트 추천 및<br>캡스톤디자인 관리를 위한 통합 플랫폼
                </p>
            </div>
        </div>
        
        <div class="register-form-container">
            <div class="register-form-wrapper">
                <div class="register-tabs">
                    <a href="/auth/login" class="register-tab">로그인</a>
                    <a href="/auth/register" class="register-tab active">회원가입</a>
                    <a href="/auth/find-password" class="register-tab">비밀번호 찾기</a>
                </div>
                
                <h2 class="register-title">계정 생성</h2>
                <p class="register-description">AI 캡스톤디자인 관리시스템에 가입하세요.</p>
                
                <form action="/auth/register" method="post" id="registerForm">
                    <c:if test="${not empty errorCode}">
                        <div class="alert-danger">
                            <c:choose>
                                <c:when test="${errorCode == 'DUPLICATE_USERNAME'}">이미 사용 중인 학번/교번입니다.</c:when>
                                <c:when test="${errorCode == 'DUPLICATE_EMAIL'}">이미 사용 중인 이메일입니다.</c:when>
                                <c:when test="${errorCode == 'DUPLICATE_PHONE'}">이미 사용 중인 전화번호입니다.</c:when>
                                <c:when test="${errorCode == 'FAILURE'}">회원가입 중 오류가 발생했습니다.</c:when>
                                <c:otherwise>회원가입에 실패했습니다.</c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>

                    <!-- 사용자 유형: 한 줄 전체 -->
                    <div class="form-group full-width">
                        <label class="form-label">사용자 유형</label>
                        <div class="radio-group">
                            <label><input type="radio" name="role" value="STUDENT" checked> 학생</label>
                            <label><input type="radio" name="role" value="PROFESSOR"> 교수</label>
                            <label><input type="radio" name="role" value="ASSISTANT"> 조교</label>
                            <label><input type="radio" name="role" value="STAFF"> 교직원</label>
                        </div>
                    </div>

                    <!-- 2단 그리드 입력폼 -->
                    <div class="register-form-fields">
                        <div class="form-group">
                            <label class="form-label">이름</label>
                            <input type="text" class="form-input" name="name" required value="${param.name}" placeholder="이름을 입력하세요">
                        </div>
                        <div class="form-group">
                            <label class="form-label">학번/교번</label>
                            <input type="text" class="form-input" name="username" required value="${param.username}" placeholder="학번 또는 교번을 입력하세요">
                        </div>
                        <div class="form-group">
                            <label class="form-label">이메일</label>
                            <input type="email" class="form-input" name="email" required value="${param.email}" placeholder="이메일을 입력하세요">
                        </div>
                        <div class="form-group">
                            <label class="form-label">휴대폰</label>
                            <input type="text" class="form-input" name="phone" required value="${param.phone}" placeholder="010-0000-0000">
                        </div>
                        <div class="form-group">
                            <label class="form-label">비밀번호</label>
                            <input type="password" class="form-input" name="password" required placeholder="비밀번호를 입력하세요">
                            <div class="error">
                                비밀번호는 대소문자, 숫자, 특수문자를 포함한 8자 이상이어야 합니다.
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="form-label">비밀번호 확인</label>
                            <input type="password" class="form-input" name="confirmPassword" required placeholder="비밀번호를 다시 입력하세요">
                        </div>
                        <!-- 소속 학과/부서: 2단 그리드 한 줄로 분리 -->
                        <div class="form-group">
                            <label class="form-label">소속 학과/부서 검색</label>
                            <input type="text" id="departmentSearch" class="form-input" placeholder="학과/부서 검색">
                        </div>
                        <div class="form-group">
                            <label class="form-label">소속 학과/부서 선택</label>
                            <select id="departmentSelect" class="form-input" name="department" required>
                                <option value="">선택하세요</option>
                            </select>
                        </div>
                        <div class="form-group full-width">
                            <label class="checkbox-label">
                                <input type="checkbox" name="agree" required>
                                회원가입 시 <a href="/auth/terms" target="_blank">이용약관</a>과 <a href="/auth/privacy" target="_blank">개인정보 처리방침</a>에 동의합니다.
                            </label>
                        </div>
                        <div class="form-group full-width">
                            <button type="submit" class="register-btn">회원가입</button>
                        </div>
                    </div>
                </form>
                
                <div class="login-link">
                    <p>이미 계정이 있으신가요? <a href="/auth/login">로그인</a></p>
                </div>
                <div class="footer-text">
                    ⓒ 2025 AI 캡스톤디자인 시스템 | by 4차산업연구회 팀
                </div>
            </div>
        </div>
    </div>

    <script>
    document.addEventListener('DOMContentLoaded', function() {
        // 1) 비밀번호 일치 및 강도 검사
        document.getElementById('registerForm').addEventListener('submit', function(e) {
            const pw = document.querySelector('input[name="password"]').value;
            const cpw = document.querySelector('input[name="confirmPassword"]').value;
            if (pw !== cpw) {
                e.preventDefault();
                alert('비밀번호가 일치하지 않습니다.');
                return false;
            }
            const pwRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
            if (!pwRegex.test(pw)) {
                e.preventDefault();
                alert('비밀번호는 대소문자, 숫자, 특수문자를 포함한 8자 이상이어야 합니다.');
                return false;
            }
        });

        // 2) 전화번호 자동 포맷팅
        const phoneInput = document.querySelector('input[name="phone"]');
        if (phoneInput) {
            phoneInput.addEventListener('input', function(e) {
                let v = e.target.value.replace(/[^0-9]/g, '');
                if (v.length >= 4 && v.length <= 7) {
                    v = v.replace(/(\d{3})(\d+)/, '$1-$2');
                } else if (v.length >= 8) {
                    v = v.replace(/(\d{3})(\d{4})(\d+)/, '$1-$2-$3');
                }
                e.target.value = v;
            });
        }

        // 3) 역할별 학과/부서 데이터
        const departmentsMap = {
            STUDENT: [
                '컴퓨터공학과','정보통신공학과','디지털콘텐츠학과',
                '소프트웨어공학과','인공지능학과','AI소프트웨어'
            ],
            PROFESSOR: [
                '컴퓨터공학과','정보통신공학과','디지털콘텐츠학과',
                '소프트웨어공학과','인공지능학과','AI소프트웨어'
            ],
            ASSISTANT: [
                '컴퓨터공학과','정보통신공학과','디지털콘텐츠학과',
                '소프트웨어공학과','인공지능학과','AI소프트웨어'
            ],
            STAFF: [
                '행정부','교무부','학생부','기타'
            ]
        };

        const roleRadios = document.querySelectorAll('input[name="role"]');
        const deptSelect = document.getElementById('departmentSelect');
        const deptSearch = document.getElementById('departmentSearch');

        function populateOptions(role) {
            // 초기화
            deptSelect.innerHTML = '<option value="">선택하세요</option>';
            departmentsMap[role].forEach(dep => {
                const opt = document.createElement('option');
                opt.value = dep; opt.text = dep;
                deptSelect.appendChild(opt);
            });
            // 이전 선택값 복원
            const prev = '${param.department}';
            if (prev) deptSelect.value = prev;
        }

        // 역할 변경 시 옵션 재설정
        roleRadios.forEach(r => {
            r.addEventListener('change', () => {
                populateOptions(r.value);
                deptSearch.value = '';
            });
        });

        // 검색어 입력 시 옵션 필터링
        deptSearch.addEventListener('input', function() {
            const kw = this.value.trim().toLowerCase();
            Array.from(deptSelect.options).forEach(opt => {
                if (opt.value === '') return;
                opt.hidden = kw && !opt.text.toLowerCase().includes(kw);
            });
        });

        // 초기 로드 때 기본 역할의 옵션 채우기
        const initialRole = document.querySelector('input[name="role"]:checked').value;
        populateOptions(initialRole);
        
        // 소셜 회원가입 버튼 호버 효과
        document.querySelectorAll('.social-btn').forEach(btn => {
            btn.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-2px) scale(1.05)';
            });
            
            btn.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(0) scale(1)';
            });
        });

        // 비밀번호 토글
        const pwToggle = document.getElementById('password-toggle');
        const pwField = document.getElementById('password');
        pwToggle.addEventListener('click', function() {
            const icon = this.querySelector('i');
            if (pwField.type === 'password') {
                pwField.type = 'text';
                icon.className = 'mdi mdi-eye-outline';
            } else {
                pwField.type = 'password';
                icon.className = 'mdi mdi-eye-off-outline';
            }
        });

        // 비밀번호 확인 토글
        const cpwToggle = document.getElementById('confirm-password-toggle');
        const cpwField = document.getElementById('confirmPassword');
        cpwToggle.addEventListener('click', function() {
            const icon = this.querySelector('i');
            if (cpwField.type === 'password') {
                cpwField.type = 'text';
                icon.className = 'mdi mdi-eye-outline';
            } else {
                cpwField.type = 'password';
                icon.className = 'mdi mdi-eye-off-outline';
            }
        });
    });
    </script>
</body>
</html>