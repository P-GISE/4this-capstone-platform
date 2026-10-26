<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<!-- SweetAlert2 CDN 추가 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<body>
    <!-- 사이드바 -->
    <div class="sidebar">
        <%@ include file="../layout/sidebar.jsp" %>
    </div>

    <!-- 메인 콘텐츠 -->
    <div class="content">
        <%@ include file="../layout/header.jsp" %>
        <div class="main-body">
            <!-- 페이지 제목 -->
            <h2 class="section-title">마이페이지</h2>
            
            <!-- 메시지 표시 -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">${errorMessage}</div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">${successMessage}</div>
            </c:if>

            <!-- 마이페이지 본문 시작 -->
            <div class="mypage-profile-card">
                <div class="mypage-profile-header">
                    <div class="mypage-avatar-circle">
                        <span class="mypage-avatar-text">${fn:substring(profile.name, 0, 1)}</span>
                    </div>
                    <div class="mypage-profile-basic-info">
                        <h3 class="mypage-profile-name"><c:out value="${profile.name}" /></h3>
                        <p class="mypage-profile-department">
                            <c:choose>
                                <c:when test="${profile.role == 'STUDENT'}">학과</c:when>
                                <c:when test="${profile.role == 'PROFESSOR'}">학과</c:when>
                                <c:when test="${profile.role == 'STAFF'}">부서</c:when>
                                <c:when test="${profile.role == 'ADMIN'}">부서</c:when>
                                <c:when test="${profile.role == 'ASSISTANT'}">연구실</c:when>
                                <c:otherwise>소속</c:otherwise>
                            </c:choose>
                            / ${profile.department}
                        </p>
                        <p class="mypage-profile-id">
                            <c:choose>
                                <c:when test="${profile.role == 'STUDENT'}">학번: ${profile.studentId}</c:when>
                                <c:when test="${profile.role == 'PROFESSOR'}">교번: ${profile.professorId}</c:when>
                                <c:when test="${profile.role == 'STAFF'}">직번: ${profile.staffId}</c:when>
                                <c:when test="${profile.role == 'ADMIN'}">관리번호: ${profile.adminId}</c:when>
                                <c:when test="${profile.role == 'ASSISTANT'}">조교번호: ${profile.assistantId}</c:when>
                                <c:otherwise>사번: -</c:otherwise>
                            </c:choose>
                        </p>
                        <p class="mypage-profile-email">이메일: <c:out value="${profile.email}" /></p>
                        <p class="mypage-profile-phone">연락처: <c:out value="${profile.phone}" /></p>
                    </div>
                    <div class="mypage-profile-actions">
                        <a href="/mypage/update-mypage" class="mypage-profile-action-btn mypage-primary-btn">프로필 편집</a>
                        <a href="/mypage/update-password" class="mypage-profile-action-btn mypage-secondary-btn">비밀번호 변경</a>
                        <button type="button" class="mypage-profile-action-btn mypage-danger-btn" onclick="showDeleteConfirm()">회원 탈퇴</button>
                    </div>
                </div>
            </div>
        </div>
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
        
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border: 1px solid transparent;
            border-radius: 4px;
        }
        
        .alert-danger {
            color: #a94442;
            background-color: #f2dede;
            border-color: #ebccd1;
        }
        
        .alert-success {
            color: #3c763d;
            background-color: #dff0d8;
            border-color: #d6e9c6;
        }
        
        .mypage-profile-card {
            background-color: #fff;
            border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            padding: 30px;
            margin-bottom: 30px;
        }
        
        .mypage-profile-header {
            display: flex;
            align-items: flex-start;
            gap: 30px;
        }
        
        .mypage-avatar-circle {
            width: 120px;
            height: 120px;
            background-color: var(--primary-color);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .mypage-avatar-text {
            color: white;
            font-size: 3.5rem;
            font-weight: bold;
        }
        
        .mypage-profile-basic-info {
            flex: 1;
        }
        
        .mypage-profile-name {
            font-size: 1.8rem;
            font-weight: bold;
            margin-bottom: 10px;
            color: #333;
        }
        
        .mypage-profile-department {
            font-size: 1.1rem;
            color: #555;
            margin-bottom: 15px;
        }
        
        .mypage-profile-id, .mypage-profile-email, .mypage-profile-phone {
            font-size: 1rem;
            color: #666;
            margin-bottom: 8px;
        }
        
        .mypage-profile-actions {
            display: flex;
            flex-direction: column;
            gap: 10px;
            flex-shrink: 0;
            width: 200px;
        }
        
        .mypage-profile-action-btn {
            padding: 12px 20px;
            border-radius: 8px;
            font-size: 0.95rem;
            font-weight: 500;
            text-align: center;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s ease;
            border: none;
        }
        
        .mypage-primary-btn {
            background-color: var(--primary-color);
            color: white;
        }
        
        .mypage-primary-btn:hover {
            background-color: var(--active-purple);
            color: white;
            text-decoration: none;
        }
        
        .mypage-secondary-btn {
            background-color: #f0f0f0;
            color: #333;
            border: 1px solid #ddd;
        }
        
        .mypage-secondary-btn:hover {
            background-color: #e5e5e5;
            text-decoration: none;
        }
        
        .mypage-danger-btn {
            background-color: #fff0f0;
            color: #dc3545;
            border: 1px solid #dc3545;
        }
        
        .mypage-danger-btn:hover {
            background-color: #dc3545;
            color: #fff;
        }

        @media (max-width: 768px) {
            .mypage-profile-header {
                flex-direction: column;
                text-align: center;
            }
            .mypage-avatar-circle {
                margin-right: 0;
                margin-bottom: 20px;
            }
        }

        /* SweetAlert2 커스터마이징 */
        .swal2-popup {
            border-radius: 16px !important;
            padding: 2rem !important;
        }
        
        .swal2-title {
            font-size: 1.5rem !important;
            color: #dc3545 !important;
            font-weight: bold !important;
        }
        
        .swal2-html-container {
            font-size: 1rem !important;
            color: #666 !important;
            line-height: 1.5 !important;
        }
        
        .swal2-confirm {
            background-color: #dc3545 !important;
            border: none !important;
            border-radius: 8px !important;
            padding: 12px 24px !important;
            font-weight: 500 !important;
        }
        
        .swal2-cancel {
            background-color: #6c757d !important;
            border: none !important;
            border-radius: 8px !important;
            padding: 12px 24px !important;
            font-weight: 500 !important;
        }
        
        .content, .main-body {
            height: auto !important;
            overflow: visible !important;
        }
    </style>

    <!-- 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>
    <script>
        // SweetAlert2를 사용한 회원탈퇴 확인
        function showDeleteConfirm() {
            Swal.fire({
                title: '회원 탈퇴',
                html: `
                    <div style="margin: 20px 0;">
                        <p style="color: #dc3545; font-weight: bold; margin-bottom: 10px;">⚠️ 주의사항</p>
                        <p style="margin-bottom: 10px;">탈퇴한 회원은 <strong>복구할 수 없습니다</strong>.</p>
                        <p style="margin-bottom: 10px;">모든 데이터가 영구적으로 삭제됩니다.</p>
                        <p>정말로 탈퇴를 진행하시겠습니까?</p>
                    </div>
                `,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: '회원 탈퇴',
                cancelButtonText: '취소',
                reverseButtons: true,
                focusCancel: true,
                customClass: {
                    popup: 'custom-swal-popup',
                    title: 'custom-swal-title',
                    htmlContainer: 'custom-swal-content'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    // 탈퇴 확인 시 실제 삭제 진행
                    showFinalConfirm();
                }
            });
        }

        // 최종 확인 단계
        function showFinalConfirm() {
            Swal.fire({
                title: '최종 확인',
                html: `
                    <div style="margin: 20px 0;">
                        <p style="color: #dc3545; font-weight: bold; margin-bottom: 15px;">🚨 마지막 경고</p>
                        <p style="margin-bottom: 10px;">이 작업은 <strong>되돌릴 수 없습니다</strong>.</p>
                        <p>계속 진행하시겠습니까?</p>
                    </div>
                `,
                icon: 'error',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: '최종 탈퇴',
                cancelButtonText: '취소',
                reverseButtons: true,
                focusCancel: true
            }).then((result) => {
                if (result.isConfirmed) {
                    // 실제 탈퇴 처리
                    submitDeleteForm();
                }
            });
        }

        // 탈퇴 폼 제출
        function submitDeleteForm() {
            // 로딩 표시
            Swal.fire({
                title: '처리 중...',
                html: '회원 탈퇴를 처리하고 있습니다.',
                allowOutsideClick: false,
                allowEscapeKey: false,
                showConfirmButton: false,
                didOpen: () => {
                    Swal.showLoading();
                }
            });

            // 성공 메시지를 미리 준비
            setTimeout(() => {
                // 성공 메시지 표시
                Swal.fire({
                    title: '탈퇴 완료',
                    html: `
                        <div style="margin: 20px 0;">
                            <p style="color: #28a745; font-weight: bold; margin-bottom: 15px;">✅ 회원탈퇴가 완료되었습니다</p>
                            <p>그동안 이용해 주셔서 감사합니다.</p>
                            <p style="margin-top: 15px; font-size: 0.9rem; color: #666;">잠시 후 로그인 페이지로 이동합니다.</p>
                        </div>
                    `,
                    icon: 'success',
                    confirmButtonColor: '#28a745',
                    confirmButtonText: '확인',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    timer: 3000,
                    timerProgressBar: true
                }).then(() => {
                    // 실제 폼 제출 (기존 방식)
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = '/mypage/delete';
                    document.body.appendChild(form);
                    form.submit();
                });
            }, 1500); // 1.5초 로딩 후 성공 메시지
        }

        // 다른 SweetAlert 예제들 (필요에 따라 사용)
        function showSuccessAlert(message) {
            Swal.fire({
                title: '성공!',
                text: message || '작업이 성공적으로 완료되었습니다.',
                icon: 'success',
                confirmButtonColor: '#4751c9'
            });
        }

        function showErrorAlert(message) {
            Swal.fire({
                title: '오류!',
                text: message || '작업 중 오류가 발생했습니다.',
                icon: 'error',
                confirmButtonColor: '#dc3545'
            });
        }

        function showInfoAlert(message) {
            Swal.fire({
                title: '알림',
                text: message || '이것은 정보 메시지입니다.',
                icon: 'info',
                confirmButtonColor: '#4751c9'
            });
        }

        // 페이지 로드 시 URL 파라미터에서 메시지 확인
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const message = urlParams.get('message');
            const error = urlParams.get('error');
            
            if (message) {
                showSuccessAlert(decodeURIComponent(message));
                // URL에서 파라미터 제거
                const newUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                window.history.replaceState({}, document.title, newUrl);
            }
            
            if (error) {
                showErrorAlert(decodeURIComponent(error));
                // URL에서 파라미터 제거
                const newUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                window.history.replaceState({}, document.title, newUrl);
            }
        });
    </script>
</body>
</html>
