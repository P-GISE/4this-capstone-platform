<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/layout/head-meta.jsp" %>
    <title>새 프로젝트 생성</title>
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Feather Icons -->
    <link href="https://cdn.jsdelivr.net/npm/feather-icons@4.29.0/dist/feather.css" rel="stylesheet">
    
    <style>
        :root {
            --primary-color: #556ee6;
            --primary-light: #eff2ff;
            --success-color: #34c38f;
            --success-light: #d4edda;
            --warning-color: #f1b44c;
            --danger-color: #f46a6a;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-300: #cbd5e1;
            --gray-400: #94a3b8;
            --gray-500: #64748b;
            --gray-600: #475569;
            --gray-700: #334155;
            --gray-800: #1e293b;
            --gray-900: #0f172a;
            --white: #ffffff;
            --border-radius: 8px;
            --border-radius-lg: 12px;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f8f9fa;
            color: #2d3748;
            line-height: 1.6;
        }
        
        /* main-body 스타일은 head-meta.jsp에서 관리 */

        /* Page Header */
        .page-header {
            margin-bottom: 32px;
        }
        
        .page-title {
            font-size: 1.875rem;
            font-weight: 700;
            color: var(--gray-900);
            margin: 0 0 8px 0;
            letter-spacing: -0.025em;
        }

        .page-description {
            color: var(--gray-600);
            font-size: 1rem;
            margin: 0;
        }

        /* Success Alert */
        .alert {
            background: var(--success-light);
            border: 1px solid var(--success-color);
            border-radius: var(--border-radius-lg);
            padding: 20px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .alert-success {
            color: #155724;
        }

        .alert-icon {
            width: 24px;
            height: 24px;
            color: var(--success-color);
        }

        /* Form Container */
        .form-container { 
            background: var(--white);
            border-radius: var(--border-radius-lg);
            box-shadow: var(--shadow);
            border: 1px solid var(--gray-200);
            overflow: hidden;
            max-width: 800px;
            margin: 0 auto 0 50px; /* top · right · bottom · left */
        }

        .form-header {
            background: linear-gradient(135deg, var(--primary-color), #4c63d2);
            color: white;
            padding: 24px 32px;
            border-bottom: none;
        }

        .form-header h3 {
            margin: 0;
            font-size: 1.25rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .form-header-icon {
            width: 24px;
            height: 24px;
        }

        .form-body {
            padding: 32px;
        }
        
        /* Section Styles */
        .form-section {
            margin-bottom: 32px;
        }

        .form-section:last-child {
            margin-bottom: 0;
        }
        
        .section-title {
            font-size: 1.125rem;
            font-weight: 600;
            margin-bottom: 20px;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .section-icon {
            width: 20px;
            height: 20px;
            color: var(--primary-color);
        }
        
        .section-divider {
            border: none;
            height: 1px;
            background: var(--gray-200);
            margin: 24px 0;
        }

        /* Form Elements */
        .form-group { 
            margin-bottom: 20px; 
        }
        
        .form-label {
            font-weight: 500;
            color: var(--gray-700);
            margin-bottom: 8px;
            display: block;
            font-size: 0.875rem;
        }

        .form-label.required::after {
            content: '*';
            color: var(--danger-color);
            margin-left: 4px;
        }
        
        .form-control {
            width: 100%;
            border: 1px solid var(--gray-300);
            border-radius: var(--border-radius);
            padding: 12px 16px;
            font-size: 0.875rem;
            transition: all 0.2s ease;
            background: var(--white);
            box-sizing: border-box;
        }
        
        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(85, 110, 230, 0.1);
            outline: none;
        }
        
        .form-control::placeholder {
            color: var(--gray-400);
            font-size: 0.875rem;
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 100px;
            line-height: 1.5;
        }

        /* Grid System */
        .row {
            display: flex;
            flex-wrap: wrap;
            margin: 0 -12px;
        }

        .col, .col-md-6, .col-md-12 {
            padding: 0 12px;
            box-sizing: border-box;
        }

        .col-md-6 {
            flex: 0 0 50%;
            max-width: 50%;
        }

        .col-md-12 {
            flex: 0 0 100%;
            max-width: 100%;
        }

        /* Member Management */
        .members-container {
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: var(--border-radius);
            padding: 20px;
        }

        .member-row {
            background: var(--white);
            border: 1px solid var(--gray-200);
            border-radius: var(--border-radius);
            padding: 16px;
            margin-bottom: 12px;
            transition: all 0.3s ease;
            position: relative;
        }
        
        .member-row:hover {
            border-color: var(--primary-color);
            box-shadow: var(--shadow-sm);
        }

        .member-row:last-child {
            margin-bottom: 0;
        }

        .member-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
        }

        .member-number {
            background: var(--primary-light);
            color: var(--primary-color);
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 8px;
            border-radius: 4px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .member-inputs {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        /* Button Styles */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 12px 20px;
            border-radius: var(--border-radius);
            font-weight: 500;
            font-size: 0.875rem;
            text-decoration: none;
            border: 1px solid transparent;
            cursor: pointer;
            transition: all 0.2s ease;
            min-height: 44px;
            box-sizing: border-box;
        }

        .btn-icon {
            width: 16px;
            height: 16px;
        }
        
        .btn-primary {
            background: var(--primary-color);
            color: white;
            border-color: var(--primary-color);
        }
        
        .btn-primary:hover {
            background: #4c63d2;
            border-color: #4c63d2;
            color: white;
            transform: translateY(-1px);
            box-shadow: var(--shadow);
        }
        
        .btn-secondary {
            background: var(--white);
            color: var(--gray-700);
            border-color: var(--gray-300);
        }

        .btn-secondary:hover {
            background: var(--gray-50);
            border-color: var(--gray-400);
            color: var(--gray-800);
        }

        .btn-success {
            background: var(--success-color);
            color: white;
            border-color: var(--success-color);
        }

        .btn-success:hover {
            background: #2ab475;
            border-color: #2ab475;
            color: white;
            transform: translateY(-1px);
            box-shadow: var(--shadow);
        }
        
        .btn-outline-danger {
            color: var(--danger-color);
            border-color: var(--danger-color);
            background: transparent;
        }
        
        .btn-outline-danger:hover {
            color: white;
            background: var(--danger-color);
            border-color: var(--danger-color);
            transform: translateY(-1px);
        }

        .btn-lg {
            padding: 16px 32px;
            font-size: 1rem;
            border-radius: 10px;
        }
        
        /* Button Groups */
        .btn-group {
            display: flex;
            gap: 12px;
            margin-top: 24px;
        }

        .member-actions {
            display: flex;
            gap: 8px;
            margin-top: 16px;
        }

        .btn-group-end {
            justify-content: flex-end;
        }

        .btn-group-center {
            justify-content: center;
        }

        /* Utility Classes */
        .d-flex {
            display: flex !important;
        }

        .justify-content-center {
            justify-content: center !important;
        }

        .align-items-center {
            align-items: center !important;
        }

        .gap-2 {
            gap: 8px !important;
        }

        .mt-4 {
            margin-top: 24px !important;
        }

        .mb-2 {
            margin-bottom: 8px !important;
        }

        .text-center {
            text-align: center !important;
        }

        /* Animations */
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .form-container {
            animation: slideIn 0.5s ease-out;
        }

        .member-row {
            animation: slideIn 0.3s ease-out;
        }

        /* Mobile Responsive */
        @media (max-width: 768px) {
            .main-body {
                margin-left: 0;
                padding: 16px;
            }

            .form-body {
                padding: 20px;
            }

            .form-header {
                padding: 20px;
            }

            .col-md-6 {
                flex: 0 0 100%;
                max-width: 100%;
            }

            .member-inputs {
                grid-template-columns: 1fr;
            }

            .btn-group {
                flex-direction: column;
            }

            .page-title {
                font-size: 1.5rem;
            }
        }

        @media (max-width: 480px) {
            .main-body {
                padding: 12px;
            }

            .form-body {
                padding: 16px;
            }

            .form-header {
                padding: 16px;
            }
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <%@ include file="/WEB-INF/views/layout/sidebar.jsp" %>
    </div>
    <div class="content">
        <%@ include file="/WEB-INF/views/layout/header.jsp" %>

        <div class="main-body">
            <div class="page-header">
                <h1 class="page-title">새 프로젝트 생성</h1>
                <p class="page-description">새로운 프로젝트를 생성하고 팀원들을 추가해보세요.</p>
            </div>
            
            <%-- 프로젝트 생성 성공 메시지 --%>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">
                    <svg class="alert-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    <div>
                        <strong>프로젝트가 성공적으로 생성되었습니다!</strong>
                        <div style="margin-top: 4px; font-size: 0.875rem;">${successMessage}</div>
                    </div>
                </div>
                <div class="d-flex justify-content-center mt-4">
                    <a href="${pageContext.request.contextPath}/projects" class="btn btn-lg btn-success">
                        <svg class="btn-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                        </svg>
                        프로젝트 목록으로 가기
                    </a>
                </div>
                <script>
                    document.querySelector('.form-container').style.display = 'none';
                </script>
            </c:if>
            
            <div class="form-container">
                <div class="form-header">
                    <h3>
                        <svg class="form-header-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                        </svg>
                        프로젝트 정보 입력
                    </h3>
                </div>

                <div class="form-body">
                    <form action="/projects/create" method="post">
                        
                        <!-- 프로젝트 정보 섹션 -->
                        <div class="form-section">
                            <div class="section-title">
                                <svg class="section-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
                                </svg>
                                프로젝트 정보
                            </div>
                            
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="projectName" class="form-label required">프로젝트 이름</label>
                                        <input type="text" class="form-control" id="projectName" name="projectName" placeholder="예: 캡스톤디자인 프로젝트" required>
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="projectDescription" class="form-label">프로젝트 설명</label>
                                        <textarea class="form-control" id="projectDescription" name="projectDescription" rows="4" placeholder="프로젝트에 대한 간단한 설명을 입력하세요."></textarea>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <hr class="section-divider">

                        <!-- 팀장 정보 섹션 -->
                        <div class="form-section">
                            <div class="section-title">
                                <svg class="section-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5.121 17.804A13.937 13.937 0 0112 16c2.5 0 4.847.655 6.879 1.804M15 10a3 3 0 11-6 0 3 3 0 016 0zm6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                </svg>
                                팀장 정보
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="teamLeaderId" class="form-label required">팀장 학번</label>
                                        <input type="text" class="form-control" id="teamLeaderId" name="teamLeaderId" placeholder="팀장 학번을 입력하세요" required>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="teamLeaderName" class="form-label required">팀장 이름</label>
                                        <input type="text" class="form-control" id="teamLeaderName" name="teamLeaderName" placeholder="팀장 이름을 입력하세요" required>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <hr class="section-divider">

                        <!-- 팀원 정보 섹션 -->
                        <div class="form-section">
                            <div class="section-title">
                                <svg class="section-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                                </svg>
                                팀원 정보
                            </div>
                            
                            <div class="members-container">
                                <div id="members">
                                    <div class="member-row">
                                        <div class="member-header">
                                            <span class="member-number">팀원 1</span>
                                        </div>
                                        <div class="member-inputs">
                                            <input type="text" class="form-control" name="memberIds" placeholder="팀원 학번" required>
                                            <input type="text" class="form-control" name="memberNames" placeholder="팀원 이름" required>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="member-actions">
                                    <button type="button" class="btn btn-secondary" onclick="addMember()">
                                        <svg class="btn-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                                        </svg>
                                        팀원 추가
                                    </button>
                                    <button type="button" class="btn btn-outline-danger" onclick="removeLastMember()">
                                        <svg class="btn-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                                        </svg>
                                        마지막 팀원 제거
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <!-- 버튼 그룹 -->
                        <div class="btn-group btn-group-end">
                            <a href="/projects" class="btn btn-secondary">
                                <svg class="btn-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                                </svg>
                                취소
                            </a>
                            <button type="submit" class="btn btn-primary">
                                <svg class="btn-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                                </svg>
                                프로젝트 생성
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <%@ include file="/WEB-INF/views/layout/footer.jsp" %>
    </div>

    <%@ include file="/WEB-INF/views/layout/scripts.jsp" %>

    <script>
        let memberCount = 1;

        function addMember() {
            memberCount++;
            const memberRow = document.createElement('div');
            memberRow.className = 'member-row';
            memberRow.innerHTML = `
                <div class="member-header">
                    <span class="member-number">팀원 ${memberCount}</span>
                </div>
                <div class="member-inputs">
                    <input type="text" class="form-control" name="memberIds" placeholder="팀원 학번" required>
                    <input type="text" class="form-control" name="memberNames" placeholder="팀원 이름" required>
                </div>
            `;
            
            document.getElementById('members').appendChild(memberRow);
            
            // 부드러운 애니메이션 효과
            setTimeout(() => {
                memberRow.style.opacity = '1';
                memberRow.style.transform = 'translateY(0)';
            }, 10);
        }
        
        function removeLastMember() {
            const memberRows = document.querySelectorAll('.member-row');
            
            if (memberRows.length <= 1) {
                alert('최소 1명의 팀원은 있어야 합니다.');
                return;
            }
            
            if (confirm('마지막에 추가된 팀원을 제거하시겠습니까?')) {
                const lastRow = memberRows[memberRows.length - 1];
                lastRow.style.transition = 'all 0.3s ease';
                lastRow.style.opacity = '0';
                lastRow.style.transform = 'translateY(-10px)';
                
                setTimeout(() => {
                    lastRow.remove();
                    memberCount--;
                }, 300);
            }
        }

        // 폼 제출 전 유효성 검사
        document.querySelector('form').addEventListener('submit', function(e) {
            const projectName = document.getElementById('projectName').value.trim();
            const teamLeaderId = document.getElementById('teamLeaderId').value.trim();
            const teamLeaderName = document.getElementById('teamLeaderName').value.trim();
            
            if (!projectName || !teamLeaderId || !teamLeaderName) {
                e.preventDefault();
                alert('필수 항목을 모두 입력해주세요.');
                return;
            }
            
            const memberIds = document.querySelectorAll('input[name="memberIds"]');
            const memberNames = document.querySelectorAll('input[name="memberNames"]');
            
            for (let i = 0; i < memberIds.length; i++) {
                if (!memberIds[i].value.trim() || !memberNames[i].value.trim()) {
                    e.preventDefault();
                    alert('모든 팀원의 학번과 이름을 입력해주세요.');
                    return;
                }
            }
        });

        // 페이지 로드 시 애니메이션
        document.addEventListener('DOMContentLoaded', function() {
            const formContainer = document.querySelector('.form-container');
            formContainer.style.opacity = '0';
            formContainer.style.transform = 'translateY(20px)';
            
            setTimeout(() => {
                formContainer.style.transition = 'all 0.5s ease';
                formContainer.style.opacity = '1';
                formContainer.style.transform = 'translateY(0)';
            }, 100);
        });
    </script>
</body>
</html>