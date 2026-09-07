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
            <h2 class="section-title">프로필 편집</h2>
            
            <!-- 메시지 표시 -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">${errorMessage}</div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">${successMessage}</div>
            </c:if>
            
            <!-- 프로필 편집 폼 -->
            <div class="profile-edit-container">
                <div class="profile-edit-card">
                    <!-- 프로필 이미지 섹션 -->
                    <div class="profile-image-section">
                        <div class="profile-avatar">
                            <c:choose>
                                <c:when test="${not empty profile.profileImageUrl}">
                                    <img src="${profile.profileImageUrl}" class="avatar-circle-img" alt="프로필 이미지" 
                                         onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                    <div class="avatar-circle-fallback" style="display: none;">
                                        <span class="avatar-text">${fn:substring(profile.name, 0, 1)}</span>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <img src="https://via.placeholder.com/120x120/4751c9/ffffff?text=${fn:substring(profile.name, 0, 1)}" 
                                         class="avatar-circle-img" alt="기본 프로필" 
                                         onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                    <div class="avatar-circle-fallback" style="display: none;">
                                        <span class="avatar-text">${fn:substring(profile.name, 0, 1)}</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        
                        <!--
                        <div class="profile-image-info">
                            <h3 class="profile-image-title">프로필 이미지</h3>
                            <p class="profile-image-desc">프로필에 표시될 이미지를 업로드하세요</p>
                            <div class="profile-image-buttons">
                                <button type="button" class="btn-upload">이미지 업로드</button>
                                <button type="button" class="btn-default">기본 이미지 사용</button>
                            </div>
                        </div>
                        --> 
                    </div>
                    
                    <!-- 프로필 정보 폼 -->
                    <form id="updateMypageForm" action="/mypage/update-mypage" method="POST">
                        <!-- 필수 숨겨진 필드: username과 id -->
                        <input type="hidden" name="username" value="${profile.username}">
                        <input type="hidden" name="id" value="${profile.id}">
                        
                        <!-- 두 컬럼 레이아웃 -->
                        <div class="form-row">
                            <div class="form-group half-width">
                                <label for="name">이름</label>
                                <input type="text" id="name" name="name" value="${profile.name}" 
                                       placeholder="이름을 입력하세요" required>
                            </div>
                            <div class="form-group half-width">
                                <label for="studentId">
                                    <c:choose>
                                        <c:when test="${profile.role == 'STUDENT'}">학번</c:when>
                                        <c:when test="${profile.role == 'PROFESSOR'}">교번</c:when>
                                        <c:when test="${profile.role == 'STAFF'}">직번</c:when>
                                        <c:when test="${profile.role == 'ADMIN'}">관리번호</c:when>
                                        <c:when test="${profile.role == 'ASSISTANT'}">조교번호</c:when>
                                        <c:otherwise>사번</c:otherwise>
                                    </c:choose>
                                </label>
                                <input type="text" id="studentId" name="studentId" readonly
                                       value="<c:choose>
                                                <c:when test='${profile.role == "STUDENT"}'>${profile.studentId}</c:when>
                                                <c:when test='${profile.role == "PROFESSOR"}'>${profile.professorId}</c:when>
                                                <c:when test='${profile.role == "STAFF"}'>${profile.staffId}</c:when>
                                                <c:when test='${profile.role == "ADMIN"}'>${profile.adminId}</c:when>
                                                <c:when test='${profile.role == "ASSISTANT"}'>${profile.assistantId}</c:when>
                                                <c:otherwise>-</c:otherwise>
                                              </c:choose>" 
                                       placeholder="자동 입력됩니다">
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group half-width">
                                <label for="email">이메일</label>
                                <input type="email" id="email" name="email" value="${profile.email}" 
                                       placeholder="이메일을 입력하세요" required>
                            </div>
                            <div class="form-group half-width">
                                <label for="phone">연락처</label>
                                <input type="tel" id="phone" name="phone" value="${profile.phone}" 
                                       placeholder="010-0000-0000" required>
                            </div>
                        </div>
                        
                        <div class="form-row">
                            <div class="form-group half-width">
                                <label for="department">학과/부서</label>
                                <input type="text" id="department" name="department" value="${profile.department}" 
                                       placeholder="학과/부서를 입력하세요" readonly>
                            </div>
                            <div class="form-group half-width">
                                <label for="role">사용자 유형</label>
                                <input type="text" id="role" name="role" readonly
                                       value="<c:choose>
                                                <c:when test='${profile.role == "STUDENT"}'>학생</c:when>
                                                <c:when test='${profile.role == "PROFESSOR"}'>교수</c:when>
                                                <c:when test='${profile.role == "STAFF"}'>교직원</c:when>
                                                <c:when test='${profile.role == "ADMIN"}'>관리자</c:when>
                                                <c:when test='${profile.role == "ASSISTANT"}'>조교</c:when>
                                                <c:otherwise>${profile.role}</c:otherwise>
                                              </c:choose>">
                            </div>
                        </div>
                        
                        <!-- 제출 버튼 -->
                        <div class="form-actions">
                            <button type="button" class="btn-cancel" onclick="window.location.href='/mypage'">취소</button>
                            <button type="submit" class="btn-submit">저장</button>
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
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', sans-serif;
        }
        
        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f8f9fa;
            color: #2d3748;
            line-height: 1.6;
        }
        
        /* content와 main-body 스타일은 head-meta.jsp에서 관리 */

        .section-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 20px;
            color: var(--text-color);
        }

        /* 메시지 스타일 */
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
        
        /* 프로필 편집 페이지 스타일 */
        .profile-edit-container {
            width: 100%;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px 0;
        }
        
        .profile-edit-card {
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            padding: 30px;
        }
        
        /* 프로필 이미지 섹션 */
        .profile-image-section {
            display: flex;
            margin-bottom: 30px;
            padding-bottom: 30px;
            border-bottom: 1px solid #eee;
        }
        
        .profile-edit-card .profile-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 30px;
            flex-shrink: 0;
            position: relative;
        }

        .profile-edit-card .avatar-circle-img {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
        }
        
        .profile-edit-card .avatar-circle-fallback {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background-color: var(--primary-color);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .profile-edit-card .avatar-text {
            color: white;
            font-size: 60px;
            font-weight: bold;
        }
        
        .profile-image-info {
            flex: 1;
        }
        
        .profile-image-title {
            font-size: 17px;
            font-weight: 600;
            margin-bottom: 8px;
        }
        
        .profile-image-desc {
            color: #666;
            font-size: 14px;
            margin-bottom: 15px;
        }
        
        .profile-image-buttons {
            display: flex;
            gap: 10px;
        }
        
        .btn-upload {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }
        
        .btn-default {
            background-color: #f0f0f0;
            color: #333;
            border: 1px solid #ddd;
            padding: 8px 15px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }
        
        /* 두 컬럼 레이아웃을 위한 CSS */
        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .form-group.half-width {
            flex: 1;
            margin-bottom: 0;
        }
        
        /* 폼 필드 스타일 */
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            font-size: 14px;
            color: #666;
            margin-bottom: 8px;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            box-sizing: border-box;
        }

        .form-group input[readonly] {
            background-color: #f5f5f5;
            color: #666;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: var(--primary-color);
        }
        
        /* 버튼 스타일 */
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
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        
        .btn-submit {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }

        .btn-submit:hover {
            background-color: var(--active-purple);
        }

        .btn-cancel:hover {
            background-color: #e5e5e5;
        }

        .btn-upload:hover {
            background-color: var(--active-purple);
        }

        .btn-default:hover {
            background-color: #e5e5e5;
        }
        
        /* 반응형 스타일 */
        @media (max-width: 768px) {
            .profile-image-section {
                flex-direction: column;
                align-items: center;
                text-align: center;
            }
            
            .profile-avatar {
                margin-right: 0;
                margin-bottom: 20px;
            }
            
            .profile-image-buttons {
                justify-content: center;
            }
            
            .form-row {
                flex-direction: column;
                gap: 0;
            }
            
            .form-group.half-width {
                margin-bottom: 20px;
            }
        }

        /* 에러 메시지 스타일 */
        .error-message {
            color: #dc3545;
            font-size: 14px;
            margin-top: 5px;
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
            // 중복 제출 방지 변수
            let isSubmitting = false;
            
            console.log('Profile edit form initialized');
            
            // 전화번호 입력 제한 및 형식화
            const phoneInput = document.getElementById('phone');
            if (phoneInput) {
                phoneInput.addEventListener('keypress', function(e) {
                    // 숫자 키(0-9)만 허용
                    if (!/[0-9]/.test(String.fromCharCode(e.which)) && e.which != 8 && e.which != 0) {
                        e.preventDefault();
                    }
                });

                phoneInput.addEventListener('input', function() {
                    // 숫자만 남기기
                    let phone = this.value.replace(/[^0-9]/g, '');

                    // 010으로 시작하게 하기
                    if (phone.length >= 3 && !phone.startsWith('010')) {
                        phone = '010' + phone.substring(Math.min(3, phone.length));
                    }

                    // 형식화
                    if (phone.length <= 3) {
                        this.value = phone;
                    } else if (phone.length <= 7) {
                        this.value = phone.replace(/(\d{3})(\d{1,4})/, '$1-$2');
                    } else {
                        this.value = phone.replace(/(\d{3})(\d{4})(\d{0,4})/, '$1-$2-$3');
                    }

                    // 최대 11자리
                    if (phone.length > 11) {
                        phone = phone.substring(0, 11);
                        this.value = phone.replace(/(\d{3})(\d{4})(\d{4})/, '$1-$2-$3');
                    }
                });
            }
            
            // 폼 제출 이벤트 처리
            const form = document.getElementById('updateMypageForm');
            if (form) {
                form.addEventListener('submit', function(e) {
                    console.log('Form submission attempted');
                    
                    // 중복 제출 방지
                    if (isSubmitting) {
                        console.log('Form already submitting, preventing duplicate submission');
                        e.preventDefault();
                        return false;
                    }
                    
                    isSubmitting = true;
                    const submitBtn = document.querySelector('.btn-submit');
                    submitBtn.disabled = true;
                    submitBtn.textContent = '처리 중...';
                    
                    // 폼 검증
                    if (!validateForm()) {
                        e.preventDefault();
                        isSubmitting = false;
                        submitBtn.disabled = false;
                        submitBtn.textContent = '저장';
                        return false;
                    }
                });
            }
            
            // 폼 검증 함수
            function validateForm() {
                let isValid = true;
                
                // 기존 에러 메시지 제거
                const errorMessages = document.querySelectorAll('.error-message');
                errorMessages.forEach(msg => msg.remove());
                
                // 이름 검증
                const nameInput = document.getElementById('name');
                if (!nameInput.value.trim()) {
                    showError(nameInput, '이름을 입력하세요.');
                    isValid = false;
                }
                
                // 이메일 검증
                const emailInput = document.getElementById('email');
                if (!emailInput.value.trim()) {
                    showError(emailInput, '이메일을 입력하세요.');
                    isValid = false;
                } else if (!isValidEmail(emailInput.value)) {
                    showError(emailInput, '올바른 이메일 형식이 아닙니다.');
                    isValid = false;
                }
                
                // 전화번호 검증
                const phoneInput = document.getElementById('phone');
                if (!phoneInput.value.trim()) {
                    showError(phoneInput, '전화번호를 입력하세요.');
                    isValid = false;
                }
                
                return isValid;
            }
            
            // 에러 메시지 표시 함수
            function showError(element, message) {
                const errorDiv = document.createElement('div');
                errorDiv.className = 'error-message';
                errorDiv.textContent = message;
                element.parentNode.appendChild(errorDiv);
            }
            
            // 이메일 형식 검증 함수
            function isValidEmail(email) {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                return emailRegex.test(email);
            }
            
            // 이미지 업로드 버튼 이벤트
            const uploadBtn = document.querySelector('.btn-upload');
            if (uploadBtn) {
                uploadBtn.addEventListener('click', function() {
                    alert('이미지 업로드 기능은 준비 중입니다.');
                });
            }
            
            // 기본 이미지 버튼 이벤트
            const defaultBtn = document.querySelector('.btn-default');
            if (defaultBtn) {
                defaultBtn.addEventListener('click', function() {
                    alert('기본 이미지로 변경되었습니다.');
                });
            }
        });
    </script>
</body>
</html>