<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<head>
    <title>내 아카이브</title>
    <style>
        /* 글로벌 스타일 */
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
        
        /* content와 main-body 스타일은 head-meta.jsp에서 관리 */
        
        /* 헤더 */
        .page-header {
            background: white;
            border-radius: 16px;
            padding: 35px 40px;
            margin-bottom: 25px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
        }
        
        .page-title {
            font-size: 2.4em;
            font-weight: 700;
            color: #2d3748;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 14px;
        }
        
        .page-title i {
            color: #4299e1;
        }
        
        .page-subtitle {
            font-size: 1.1em;
            color: #718096;
            font-weight: 400;
        }
        
        /* 통계 섹션 */
        .stats-section {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 30px;
            margin-bottom: 30px;
            max-width: 1000px;
            margin-left: auto;
            margin-right: auto;
        }
        
        .stats-card {
            background: white;
            border-radius: 16px;
            padding: 35px 25px;
            text-align: center;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            transition: all 0.3s ease;
        }
        
        .stats-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }
        
        .stats-number {
            font-size: 3.2em;
            font-weight: 800;
            line-height: 1;
            margin-bottom: 8px;
        }
        
        .stats-total { color: #4299e1; }
        .stats-approved { color: #48bb78; }
        .stats-pending { color: #ed8936; }
        
        .stats-label {
            font-size: 0.95em;
            color: #718096;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        /* 탭 메뉴만 있는 액션 바 */
        .tabs-container {
            display: flex;
            justify-content: center;
            margin-bottom: 30px;
        }
        
        /* 탭 메뉴 */
        .tabs {
            background: white;
            border-radius: 50px;
            padding: 8px;
            display: flex;
            gap: 6px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }
        
        .tab-btn {
            background: none;
            border: none;
            padding: 14px 32px;
            font-size: 1em;
            font-weight: 600;
            color: #718096;
            cursor: pointer;
            border-radius: 40px;
            transition: all 0.3s ease;
            min-width: 120px;
            position: relative;
        }
        
        .tab-btn.active {
            background: linear-gradient(135deg, #4299e1, #3182ce);
            color: white;
            box-shadow: 0 4px 15px rgba(66, 153, 225, 0.4);
            transform: translateY(-1px);
        }
        
        .tab-btn:hover:not(.active) {
            background: #f7fafc;
            color: #4299e1;
            transform: translateY(-1px);
        }
        
        /* 아카이브 그리드 - 카드 크기 통일 */
        .archive-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
            align-items: stretch;
        }
        
        /* 큰 화면에서 더 많은 컬럼 */
        @media (min-width: 2200px) {
            .archive-grid {
                grid-template-columns: repeat(5, 1fr);
            }
        }
        
        @media (min-width: 1800px) and (max-width: 2199px) {
            .archive-grid {
                grid-template-columns: repeat(4, 1fr);
            }
        }
        
        @media (min-width: 1400px) and (max-width: 1799px) {
            .archive-grid {
                grid-template-columns: repeat(3, 1fr);
            }
        }
        
        @media (min-width: 1000px) and (max-width: 1399px) {
            .archive-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        
        .archive-card {
            background: white;
            border-radius: 16px;
            padding: 24px;
            border: 1px solid #e2e8f0;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            position: relative;
            height: 400px; /* 고정 높이로 통일 */
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        
        .archive-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.12);
            border-color: #4299e1;
        }
        
        .card-approved {
            border-left: 5px solid #48bb78;
        }
        
        .card-pending {
            border-left: 5px solid #ed8936;
        }
        
        .archive-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 18px;
            min-height: 60px; /* 헤더 높이 고정 */
        }
        
        .archive-title {
            font-size: 1.25em;
            font-weight: 700;
            color: #2d3748;
            margin: 0;
            line-height: 1.4;
            flex: 1;
            margin-right: 16px;
            /* 텍스트 줄바꿈 및 말줄임표 설정 */
            word-wrap: break-word;
            word-break: break-all;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            max-height: 2.8em; /* 2줄 높이 제한 */
        }
        
        .status-badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.8em;
            font-weight: 600;
            white-space: nowrap;
            flex-shrink: 0;
        }
        
        .status-approved {
            background: #c6f6d5;
            color: #2f855a;
        }
        
        .status-pending {
            background: #feebc8;
            color: #c05621;
        }
        
        .archive-meta {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-bottom: 18px;
            min-height: 80px; /* 메타 정보 높이 고정 */
        }
        
        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.85em;
            color: #718096;
            min-height: 24px;
        }
        
        .meta-item i {
            color: #4299e1;
            width: 16px;
            font-size: 1em;
            flex-shrink: 0;
        }
        
        .meta-value {
            color: #2d3748;
            font-weight: 600;
            word-wrap: break-word;
            word-break: break-all;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        
        .archive-description {
            color: #4a5568;
            line-height: 1.6;
            margin-bottom: 20px;
            font-size: 0.9em;
            flex-grow: 1;
            /* 텍스트 줄바꿈 및 말줄임표 설정 */
            word-wrap: break-word;
            word-break: break-all;
            overflow: hidden;
            display: -webkit-box;
            -webkit-line-clamp: 4;
            -webkit-box-orient: vertical;
            max-height: 6.4em; /* 4줄 높이 제한 */
        }
        
        .archive-actions {
            display: flex;
            gap: 8px;
            justify-content: flex-end;
            padding-top: 18px;
            border-top: 1px solid #e2e8f0;
            margin-top: auto;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 8px;
            font-size: 0.8em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            white-space: nowrap;
            flex: 1;
            justify-content: center;
            min-width: 80px;
        }
        
        .btn-primary {
            background: #4299e1;
            color: white;
        }
        
        .btn-primary:hover {
            background: #3182ce;
            transform: translateY(-1px);
        }
        
        .btn-warning {
            background: #ed8936;
            color: white;
        }
        
        .btn-warning:hover {
            background: #dd6b20;
            transform: translateY(-1px);
        }
        
        .btn-success {
            background: #48bb78;
            color: white;
            cursor: default;
        }
        
        /* 빈 상태 */
        .empty-state {
            text-align: center;
            padding: 80px 40px;
            color: #718096;
            grid-column: 1 / -1;
            background: white;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
        }
        
        .empty-state i {
            font-size: 4.5em;
            margin-bottom: 24px;
            color: #cbd5e0;
        }
        
        .empty-state h3 {
            font-size: 1.8em;
            font-weight: 700;
            color: #2d3748;
            margin-bottom: 12px;
        }
        
        .empty-state p {
            font-size: 1.1em;
            margin-bottom: 32px;
        }
        
        /* 특별한 아카이브 등록하기 버튼 */
        .action-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white !important;
            border: none;
            padding: 16px 32px;
            border-radius: 25px;
            font-size: 1.1em;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 12px;
            transition: all 0.3s ease;
            cursor: pointer;
            box-shadow: 0 8px 32px rgba(102, 126, 234, 0.4);
            animation: gentle-glow 3s ease-in-out infinite;
            position: relative;
            overflow: hidden;
        }
        
        .action-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 40px rgba(102, 126, 234, 0.6);
            background: linear-gradient(135deg, #5a67d8 0%, #667eea 100%);
            color: white !important;
        }
        
        .action-btn:active {
            transform: translateY(-1px);
        }
        
        .action-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s;
        }
        
        .action-btn:hover::before {
            left: 100%;
        }
        
        .action-btn i {
            color: white !important;
        }
        
        @keyframes gentle-glow {
            0%, 100% {
                box-shadow: 0 8px 32px rgba(102, 126, 234, 0.4);
            }
            50% {
                box-shadow: 0 8px 32px rgba(102, 126, 234, 0.6);
            }
        }
        
        /* 반응형 디자인 */
        @media (max-width: 1024px) {
            .main-body {
                padding: 100px 25px 25px 25px;
            }
            
            .stats-section {
                max-width: 100%;
                gap: 25px;
            }
            
            .page-title {
                font-size: 2.2em;
            }
            
            .stats-number {
                font-size: 3em;
            }
            
            .stats-card {
                padding: 30px 20px;
            }
            
            .archive-grid {
                grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            }
        }
        
        @media (max-width: 768px) {
            .main-body {
                padding: 120px 20px 20px 20px;
            }
            
            .page-header {
                padding: 35px 25px;
            }
            
            .page-title {
                font-size: 1.8em;
                flex-direction: column;
                gap: 12px;
                text-align: center;
            }
            
            .page-subtitle {
                text-align: center;
            }
            
            .stats-section {
                grid-template-columns: 1fr;
                gap: 20px;
            }
            
            .stats-card {
                padding: 30px 20px;
            }
            
            .tabs {
                border-radius: 16px;
                flex-direction: column;
                gap: 4px;
                width: 100%;
                max-width: 300px;
            }
            
            .tab-btn {
                border-radius: 12px;
                padding: 12px 20px;
                font-size: 0.95em;
                min-width: auto;
            }
            
            .archive-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }
            
            .archive-card {
                padding: 25px;
                height: auto;
                min-height: 350px;
            }
            
            .archive-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 12px;
                min-height: auto;
            }
            
            .archive-title {
                margin-right: 0;
                font-size: 1.2em;
                -webkit-line-clamp: 3;
                max-height: 4.2em;
            }
            
            .archive-meta {
                grid-template-columns: 1fr;
                gap: 12px;
                min-height: auto;
            }
            
            .archive-actions {
                flex-direction: column;
                gap: 8px;
            }
            
            .btn {
                justify-content: center;
                padding: 12px 16px;
                flex: none;
                min-width: auto;
            }
        }
        
        @media (max-width: 480px) {
            .main-body {
                padding: 110px 15px 15px 15px;
            }
            
            .page-header {
                padding: 30px 20px;
            }
            
            .page-title {
                font-size: 1.6em;
            }
            
            .stats-card {
                padding: 25px 15px;
            }
            
            .archive-card {
                padding: 20px;
            }
            
            .archive-grid {
                grid-template-columns: 1fr;
                gap: 15px;
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
        <!-- 헤더 -->
        <div class="page-header">
            <h1 class="page-title">
                <i class="fas fa-archive"></i>
                내 아카이브
            </h1>
            <p class="page-subtitle">${userName}님이 등록한 아카이브 목록</p>
        </div>
        
        <!-- 통계 -->
        <div class="stats-section">
            <div class="stats-card">
                <div class="stats-number stats-total" id="totalCount">0</div>
                <div class="stats-label">전체 아카이브</div>
            </div>
            <div class="stats-card">
                <div class="stats-number stats-approved" id="approvedCount">0</div>
                <div class="stats-label">승인 완료</div>
            </div>
            <div class="stats-card">
                <div class="stats-number stats-pending" id="pendingCount">0</div>
                <div class="stats-label">승인 대기중</div>
            </div>
        </div>
        
        <!-- 탭 메뉴 -->
        <div class="tabs-container">
            <div class="tabs">
                <button class="tab-btn active" data-tab="all">전체 보기</button>
                <button class="tab-btn" data-tab="approved">승인 완료</button>
                <button class="tab-btn" data-tab="pending">대기 중</button>
            </div>
        </div>
        
        <!-- 아카이브 목록 -->
        <c:choose>
            <c:when test="${not empty myArchives}">
                <div class="archive-grid" id="archiveGrid">
                    <c:forEach items="${myArchives}" var="archive">
                        <div class="archive-card ${archive.approved ? 'card-approved' : 'card-pending'}" 
                             data-status="${archive.approved ? 'approved' : 'pending'}">
                            <div class="archive-header">
                                <h3 class="archive-title">
                                    <c:out value="${archive.title}" />
                                </h3>
                                <span class="status-badge ${archive.approved ? 'status-approved' : 'status-pending'}">
                                    ${archive.approved ? '승인완료' : '대기중'}
                                </span>
                            </div>
                            
                            <div class="archive-meta">
                                <div class="meta-item">
                                    <i class="fas fa-calendar-alt"></i>
                                    <span>등록일</span>
                                    <span class="meta-value">
                                        <fmt:formatDate value="${archive.submittedAt}" pattern="yyyy-MM-dd" />
                                    </span>
                                </div>
                                <div class="meta-item">
                                    <i class="fas fa-folder"></i>
                                    <span>카테고리</span>
                                    <span class="meta-value"><c:out value="${archive.category}" /></span>
                                </div>
                                <div class="meta-item">
                                    <i class="fas fa-code-branch"></i>
                                    <span>버전</span>
                                    <span class="meta-value"><c:out value="${archive.version}" /></span>
                                </div>
                                <c:if test="${archive.approved}">
                                    <div class="meta-item">
                                        <i class="fas fa-check-circle"></i>
                                        <span>승인일</span>
                                        <span class="meta-value">
                                            <fmt:formatDate value="${archive.approvedAt}" pattern="yyyy-MM-dd" />
                                        </span>
                                    </div>
                                </c:if>
                            </div>
                            
                            <c:if test="${not empty archive.description}">
                                <div class="archive-description">
                                    <c:out value="${archive.description}" />
                                </div>
                            </c:if>
                            
                            <div class="archive-actions">
                                <a href="${pageContext.request.contextPath}/archive/detail/${archive.id}" 
                                   class="btn btn-primary">
                                    <i class="fas fa-eye"></i> 상세보기
                                </a>
                                
                                <c:if test="${not archive.approved}">
                                    <a href="${pageContext.request.contextPath}/archive/edit/${archive.id}" 
                                       class="btn btn-warning">
                                        <i class="fas fa-edit"></i> 편집
                                    </a>
                                </c:if>
                                
                                <c:if test="${archive.approved}">
                                    <span class="btn btn-success">
                                        <i class="fas fa-check"></i> 승인됨
                                    </span>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="fas fa-archive"></i>
                    <h3>아카이브가 없습니다</h3>
                    <p>새로운 아카이브를 등록해보세요</p>
                    <a href="${pageContext.request.contextPath}/archive/write" class="action-btn">
                        <i class="fas fa-plus"></i>
                        아카이브 등록하기
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <%@ include file="/WEB-INF/views/layout/footer.jsp" %>
</div>

<%@ include file="/WEB-INF/views/layout/scripts.jsp" %>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const tabButtons = document.querySelectorAll('.tab-btn');
    const archiveCards = document.querySelectorAll('.archive-card');
    
    // 통계 업데이트
    updateStats();
    
    // 탭 이벤트
    tabButtons.forEach(button => {
        button.addEventListener('click', function() {
            const targetTab = this.getAttribute('data-tab');
            
            // 탭 활성화
            tabButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
            
            // 카드 필터링
            filterCards(targetTab);
        });
    });
    
    function filterCards(filter) {
        archiveCards.forEach(card => {
            const status = card.getAttribute('data-status');
            
            if (filter === 'all' || 
                (filter === 'approved' && status === 'approved') ||
                (filter === 'pending' && status === 'pending')) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }
    
    function updateStats() {
        const totalCount = archiveCards.length;
        const approvedCount = document.querySelectorAll('.archive-card[data-status="approved"]').length;
        const pendingCount = document.querySelectorAll('.archive-card[data-status="pending"]').length;
        
        document.getElementById('totalCount').textContent = totalCount;
        document.getElementById('approvedCount').textContent = approvedCount;
        document.getElementById('pendingCount').textContent = pendingCount;
    }
});
</script>

</body>
</html>