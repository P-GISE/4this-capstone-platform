<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<body>
    <!-- 사이드바 -->
    <div class="sidebar">
        <%@ include file="../layout/sidebar.jsp" %>
    </div>

    <!-- 메인 콘텐츠 -->
    <div class="content">
        <!-- 헤더 -->
        <%@ include file="../layout/header.jsp" %>

        <!-- 본문 영역 -->
        <div class="main-body">
            <!-- 페이지 제목 -->
            <h2 class="section-title">비밀번호 변경</h2>
            
            <!-- 메시지 표시 -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">${errorMessage}</div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">${successMessage}</div>
            </c:if>
            
            <!-- 비밀번호 변경 폼 -->
            <div class="pwd-change-container">
                <div class="pwd-change-card">
                    <!-- 현재 비밀번호 입력 안내 -->
                    <div class="password-info">
                        <h3>보안을 위해 현재 비밀번호를 확인합니다</h3>
                        <p>새로운 비밀번호로 변경하기 위해 현재 비밀번호를 입력해주세요.</p>
                    </div>

                    <!-- 비밀번호 변경 폼 -->
                    <form action="/mypage/update-password" method="POST">
                        <!-- 현재 비밀번호 -->
                        <div class="form-group">
                            <label for="currentPassword">현재 비밀번호</label>
                            <input type="password" id="currentPassword" name="currentPassword" 
                                   placeholder="현재 비밀번호를 입력하세요" required>
                        </div>
                        
                        <!-- 새 비밀번호 -->
                        <div class="form-group">
                            <label for="password">새 비밀번호</label>
                            <input type="password" id="password" name="password" 
                                   placeholder="새 비밀번호를 입력하세요" required>
                            <div class="password-strength">
                                <div class="strength-bar">
                                    <div class="strength-fill"></div>
                                </div>
                                <div class="strength-text">비밀번호 강도: 매우 약함</div>
                            </div>
                        </div>
                        
                        <!-- 새 비밀번호 확인 -->
                        <div class="form-group">
                            <label for="password2">새 비밀번호 확인</label>
                            <input type="password" id="password2" name="password2" 
                                   placeholder="새 비밀번호를 다시 입력하세요" required>
                        </div>
                        
                        <!-- 제출 버튼 -->
                        <div class="form-actions">
                            <button type="button" class="btn-cancel" onclick="window.location.href='/mypage'">취소</button>
                            <button type="submit" class="btn-save">비밀번호 변경</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- 푸터 -->
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 스타일 -->
    <style>
        :root {
            --primary-color: #4751c9;
            --secondary-color: #e9eaff;
            --dark-color: #1e1e1e;
            --light-color: #ffffff;
            --accent-color: #ff7043;
            --grey-color: #f5f5f7;
            --text-color: #333333;
            --light-purple: #e9e6ff;
            --active-purple: #6c63ff;
            --border-color: #eaeaea;
            --button-color: #f0f2f5;
            --success-color: #28a745;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
        }

        * {
            box-sizing: border-box;
            font-family: 'Segoe UI', sans-serif;
        }
        
        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f8f9fa;
            color: #2d3748;
            line-height: 1.6;
        }
        
        /* content 스타일은 head-meta.jsp에서 관리 */
        

        .section-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 20px;
            color: var(--text-color);
        }

        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 4px;
        }
        
        .alert-success {
            color: #3c763d;
            background-color: #dff0d8;
            border-color: #d6e9c6;
        }
        
        .alert-danger {
            color: #a94442;
            background-color: #f2dede;
            border-color: #ebccd1;
        }
        
        .pwd-change-container {
            width: 100%;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px 0;
        }
        
        .pwd-change-card {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            padding: 30px;
        }

        .password-info {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }

        .password-info h3 {
            color: var(--text-color);
            margin-bottom: 10px;
            font-size: 1.2rem;
        }

        .password-info p {
            color: #666;
            font-size: 0.9rem;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-group label {
            display: block;
            font-size: 14px;
            color: #666;
            margin-bottom: 8px;
            font-weight: 600;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            box-sizing: border-box;
            transition: border-color 0.3s, box-shadow 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 2px rgba(71, 81, 201, 0.1);
        }
        .form-group input.valid {
            border-color: var(--success-color);
        }

        .form-group input.invalid {
            border-color: var(--danger-color);
        }

        /* 비밀번호 강도 표시 */
        .password-strength {
            margin-top: 10px;
        }

        .strength-bar {
            width: 100%;
            height: 6px;
            background-color: #e0e0e0;
            border-radius: 3px;
            overflow: hidden;
            margin-bottom: 5px;
        }

        .strength-fill {
            height: 100%;
            width: 0%;
            transition: width 0.3s, background-color 0.3s;
            border-radius: 3px;
        }

        .strength-fill.weak { background-color: var(--danger-color); }
        .strength-fill.medium { background-color: var(--warning-color); }
        .strength-fill.strong { background-color: var(--success-color); }

        .strength-text {
            font-size: 12px;
            color: #666;
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 30px;
        }
        
        .btn-cancel {
            background-color: #f0f0f0;
            color: #333;
            border: 1px solid #ddd;
            padding: 12px 24px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s;
        }

        .btn-cancel:hover {
            background-color: #e5e5e5;
        }
        
        .btn-save {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s;
        }

        .btn-save:hover {
            background-color: var(--active-purple);
        }

        .btn-save:disabled {
            background-color: #ccc;
            cursor: not-allowed;
        }
        .content, .main-body {
        height: auto !important;
        overflow: visible !important;
        }
    </style>

    <!-- 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>
    <script>
        document.addEventListener('DOMContentLoaded', function() {

            function evaluatePasswordStrength(password) {
                let score = 0;

                if (!password) return score;

                // 조건별 점수 증가
                if (password.length >= 8) score++;
                if (/[A-Z]/.test(password)) score++;
                if (/[a-z]/.test(password)) score++;
                if (/[0-9]/.test(password)) score++;
                if (/[^A-Za-z0-9]/.test(password)) score++;

                return score;
            }

            function updateStrengthMeter(password) {
                const fill = document.querySelector('.strength-fill');
                const text = document.querySelector('.strength-text');

                const strength = evaluatePasswordStrength(password);

                // 기본 값 초기화
                fill.className = 'strength-fill';

                if (strength <= 1) {
                    fill.style.width = '20%';
                    fill.classList.add('weak');
                    text.textContent = '비밀번호 강도: 매우 약함';
                } else if (strength === 2 || strength === 3) {
                    fill.style.width = '60%';
                    fill.classList.add('medium');
                    text.textContent = '비밀번호 강도: 보통';
                } else {
                    fill.style.width = '100%';
                    fill.classList.add('strong');
                    text.textContent = '비밀번호 강도: 강함';
                }
            }

            
            console.log('비밀번호 변경 페이지 로드 완료');
            
            // 간단한 비밀번호 일치 검증만
            const passwordInput = document.getElementById('password');
            const confirmInput = document.getElementById('password2');

            

            function validatePasswords() {
                if (passwordInput && confirmInput) {
                    const password = passwordInput.value;
                    const confirm = confirmInput.value;

                    if (confirm.length > 0) {
                        if (password === confirm) {
                            confirmInput.style.borderColor = '#28a745';
                        } else {
                            confirmInput.style.borderColor = '#dc3545';
                        }
                    }
                }
            }

            if (passwordInput) {
                passwordInput.addEventListener('input', function () {
                    updateStrengthMeter(passwordInput.value);
                    validatePasswords();
                });
            }
            
            if (confirmInput) {
                confirmInput.addEventListener('input', validatePasswords);
            }
        });
    </script>
</body>
</html>