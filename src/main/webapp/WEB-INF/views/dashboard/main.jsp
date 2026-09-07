<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<body>
    <!-- 1) 사이드바 -->
    <div class="sidebar">
        <%@ include file="../layout/sidebar.jsp" %>
    </div>

    <!-- 2) 메인 콘텐츠 -->
    <div class="content">
        <!-- 2-1) 헤더 -->
        <%@ include file="../layout/header.jsp" %>

        <!-- 2-2) 본문 영역 -->
        <div class="main-body dashboard-page">
            <div class="page-header">
                <h2 class="section-title">대시보드</h2>
            </div>

            <div class="dashboard-grid">
                <!-- 3. 기자재 정보 카드 -->
                <div class="card modern-card">
                    <div class="card-header">
                        <div class="card-icon equipment-icon">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M21 16V8C21 6.9 20.1 6 19 6H16L14 4H10L8 6H5C3.9 6 3 6.9 3 8V16C3 17.1 3.9 18 5 18H19C20.1 18 21 17.1 21 16Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </div>
                        <h3 class="card-title">기자재 정보</h3>
                        <a href="${pageContext.request.contextPath}/equipment/list" class="view-all-btn">
                            전체보기
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M5 12H19M19 12L12 5M19 12L12 19" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </a>
                    </div>

                    <div class="card-content">
                        <c:choose>
                            <c:when test="${not empty recentEquipments}">
                                <div class="equipment-list">
                                    <c:forEach var="equipment" items="${recentEquipments}" varStatus="status">
                                        <c:if test="${status.index < 5}">
                                            <div class="equipment-item" onclick="location.href='${pageContext.request.contextPath}/equipment/detail/${equipment.id}'">
                                                <div class="item-main">
                                                    <div class="item-info">
                                                        <h4 class="item-name"><c:out value="${equipment.name}" /></h4>
                                                        <div class="item-meta">
                                                            <span class="meta-item">
                                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                                    <path d="M20.59 13.41L13.42 20.58C13.05 20.95 12.55 21.16 12.02 21.16C11.49 21.16 10.99 20.95 10.62 20.58L2 12V2H12L20.59 10.59C20.96 10.96 21.17 11.46 21.17 11.99C21.17 12.52 20.96 13.02 20.59 13.39V13.41ZM7 7C6.45 7 6 6.55 6 6C6 5.45 6.45 5 7 5C7.55 5 8 5.45 8 6C8 6.55 7.55 7 7 7Z" fill="currentColor"/>
                                                                </svg>
                                                                <c:out value="${equipment.category}" />
                                                            </span>
                                                            <span class="meta-item">
                                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                                    <path d="M21 16V8C21 6.9 20.1 6 19 6H16L14 4H10L8 6H5C3.9 6 3 6.9 3 8V16C3 17.1 3.9 18 5 18H19C20.1 18 21 17.1 21 16Z" stroke="currentColor" stroke-width="1.5" fill="none"/>
                                                                </svg>
                                                                ${equipment.availableQuantity}/${equipment.quantity}
                                                            </span>
                                                            <c:if test="${not empty equipment.location}">
                                                                <span class="meta-item">
                                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                                        <path d="M21 10C21 17 12 23 12 23S3 17 3 10C3 5 7 1 12 1S21 5 21 10Z" stroke="currentColor" stroke-width="1.5" fill="none"/>
                                                                        <circle cx="12" cy="10" r="3" stroke="currentColor" stroke-width="1.5" fill="none"/>
                                                                    </svg>
                                                                    <c:out value="${equipment.location}" />
                                                                </span>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                    <div class="item-status">
                                                        <c:choose>
                                                            <c:when test="${equipment.isRentable && equipment.availableQuantity > 0}">
                                                                <span class="status-badge available">대여 가능</span>
                                                            </c:when>
                                                            <c:when test="${equipment.availableQuantity == 0}">
                                                                <span class="status-badge unavailable">재고 없음</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="status-badge disabled">대여 불가</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <div class="empty-icon">
                                        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <path d="M21 16V8C21 6.9 20.1 6 19 6H16L14 4H10L8 6H5C3.9 6 3 6.9 3 8V16C3 17.1 3.9 18 5 18H19C20.1 18 21 17.1 21 16Z" stroke="currentColor" stroke-width="1.5" fill="none"/>
                                        </svg>
                                    </div>
                                    <p class="empty-text">등록된 기자재가 없습니다.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- 4. 문의사항 카드 -->
                <div class="card modern-card">
                    <div class="card-header">
                        <div class="card-icon inquiry-icon">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
                                <path d="M9.09 9C9.325 8.685 9.672 8.455 10.072 8.348C10.471 8.241 10.897 8.263 11.284 8.411C11.67 8.559 11.995 8.825 12.209 9.168C12.423 9.511 12.515 9.913 12.471 10.314C12.471 12 11.971 12.75 11.971 12.75" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                <path d="M12 17H12.01" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </div>
                        <h3 class="card-title">${inquiryTitle}</h3>
                        <a href="${pageContext.request.contextPath}/inquiry/list" class="view-all-btn">
                            전체보기
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M5 12H19M19 12L12 5M19 12L12 19" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </a>
                    </div>

                    <div class="card-content">
                        <c:choose>
                            <c:when test="${not empty inquiries}">
                                <div class="inquiry-list">
                                    <c:forEach var="inquiry" items="${inquiries}" varStatus="status">
                                        <c:if test="${status.index < 5}">
                                            <div class="inquiry-item" onclick="location.href='${pageContext.request.contextPath}/inquiry/view?id=${inquiry.id}'">
                                                <div class="item-main">
                                                    <div class="item-info">
                                                        <h4 class="item-name"><c:out value="${inquiry.title}" /></h4>
                                                        <div class="item-meta">
                                                            <c:if test="${isAdmin}">
                                                                <span class="meta-item">
                                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                                        <path d="M20 21V19C20 17.9 19.1 17 18 17H6C4.9 17 4 17.9 4 19V21M16 7C16 9.21 14.21 11 12 11C9.79 11 8 9.21 8 7C8 4.79 9.79 3 12 3C14.21 3 16 4.79 16 7Z" stroke="currentColor" stroke-width="1.5" fill="none"/>
                                                                    </svg>
                                                                    <c:out value="${inquiry.writerName}" />
                                                                </span>
                                                            </c:if>
                                                            <span class="meta-item">
                                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2" stroke="currentColor" stroke-width="1.5" fill="none"/>
                                                                    <line x1="16" y1="2" x2="16" y2="6" stroke="currentColor" stroke-width="1.5"/>
                                                                    <line x1="8" y1="2" x2="8" y2="6" stroke="currentColor" stroke-width="1.5"/>
                                                                    <line x1="3" y1="10" x2="21" y2="10" stroke="currentColor" stroke-width="1.5"/>
                                                                </svg>
                                                                <fmt:formatDate value="${inquiry.createdAt}" pattern="MM.dd" />
                                                            </span>
                                                        </div>
                                                    </div>
                                                    <div class="item-status">
                                                        <c:choose>
                                                            <c:when test="${inquiry.status == 'ANSWERED'}">
                                                                <span class="status-badge answered">답변완료</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="status-badge pending">대기중</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <div class="empty-icon">
                                        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                            <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="1.5"/>
                                            <path d="M9.09 9C9.325 8.685 9.672 8.455 10.072 8.348C10.471 8.241 10.897 8.263 11.284 8.411C11.67 8.559 11.995 8.825 12.209 9.168C12.423 9.511 12.515 9.913 12.471 10.314C12.471 12 11.971 12.75 11.971 12.75" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                            <path d="M12 17H12.01" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
                                        </svg>
                                    </div>
                                    <p class="empty-text">${emptyMessage}</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- 활동 요약 섹션 (관리자가 아닌 경우만 표시) -->
            <c:if test="${not isAdmin}">
                <div class="activity-summary modern-card">
                    <div class="summary-header">
                        <div class="summary-icon">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M3 13L12 4L21 13M5 11V21C5 21.6 5.4 22 6 22H9V16C9 15.4 9.4 15 10 15H14C14.6 15 15 15.4 15 16V22H18C18.6 22 19 21.6 19 21V11" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </div>
                        <h3 class="summary-title">활동 요약</h3>
                    </div>
                    
                    <div class="activity-stats">
                        <div class="stat-card">
                            <div class="stat-icon primary">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <path d="M21 16V8C21 6.9 20.1 6 19 6H16L14 4H10L8 6H5C3.9 6 3 6.9 3 8V16C3 17.1 3.9 18 5 18H19C20.1 18 21 17.1 21 16Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </div>
                            <div class="stat-number">${currentRentalsCount != null ? currentRentalsCount : 0}</div>
                            <div class="stat-label">현재 대여중</div>
                            <div class="stat-detail">현재 대여중인 기자재</div>
                        </div>
                        
                        <div class="stat-card">
                            <div class="stat-icon success">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <path d="M3 3V21L12 16L21 21V3H3Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </div>
                            <div class="stat-number">${totalRentalsCount != null ? totalRentalsCount : 0}</div>
                            <div class="stat-label">총 기자재 사용</div>
                            <div class="stat-detail">누적 대여 횟수</div>
                        </div>
                        
                        <div class="stat-card">
                            <div class="stat-icon warning">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
                                    <path d="M9.09 9C9.325 8.685 9.672 8.455 10.072 8.348C10.471 8.241 10.897 8.263 11.284 8.411C11.67 8.559 11.995 8.825 12.209 9.168C12.423 9.511 12.515 9.913 12.471 10.314C12.471 12 11.971 12.75 11.971 12.75" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                    <path d="M12 17H12.01" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </div>
                            <div class="stat-number">${totalInquiriesCount != null ? totalInquiriesCount : 0}</div>
                            <div class="stat-label">기술 문의</div>
                            <div class="stat-detail">문의 등록 총 횟수</div>
                        </div>
                        
                        <div class="stat-card">
                            <div class="stat-icon danger">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
                                    <line x1="15" y1="9" x2="9" y2="15" stroke="currentColor" stroke-width="2"/>
                                    <line x1="9" y1="9" x2="15" y2="15" stroke="currentColor" stroke-width="2"/>
                                </svg>
                            </div>
                            <div class="stat-number">${overdueRentalsCount != null ? overdueRentalsCount : 0}</div>
                            <div class="stat-label">연체</div>
                            <div class="stat-detail">연체중인 기자재</div>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>

        <!-- 2-3) 푸터 -->
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 3) 페이지 전용 CSS -->
    <style>
        /* Google Fonts Import */
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');

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

        :root {
            --primary-color: #3b82f6;
            --primary-light: #dbeafe;
            --success-color: #10b981;
            --success-light: #d1fae5;
            --warning-color: #f59e0b;
            --warning-light: #fef3c7;
            --danger-color: #ef4444;
            --danger-light: #fee2e2;
            --gray-50: #f9fafb;
            --gray-100: #f3f4f6;
            --gray-200: #e5e7eb;
            --gray-300: #d1d5db;
            --gray-400: #9ca3af;
            --gray-500: #6b7280;
            --gray-600: #4b5563;
            --gray-700: #374151;
            --gray-800: #1f2937;
            --gray-900: #111827;
            --white: #ffffff;
            --border-radius: 12px;
            --border-radius-lg: 16px;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        /* Page Header */
                 .page-header {
             display: flex;
             justify-content: space-between;
             align-items: center;
             margin-bottom: 20px;
             flex-shrink: 0;
         }

        .section-title {
            font-size: 2rem;
            font-weight: 700;
            color: var(--gray-900);
            margin: 0;
            letter-spacing: -0.025em;
        }

        .breadcrumb-wrapper {
            display: flex;
            align-items: center;
        }

        .breadcrumb-nav {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.875rem;
        }

        .breadcrumb-link {
            color: var(--gray-500);
            text-decoration: none;
            transition: color 0.2s ease;
        }

        .breadcrumb-link:hover {
            color: var(--primary-color);
        }

        .breadcrumb-separator {
            color: var(--gray-400);
        }

        .breadcrumb-current {
            color: var(--gray-900);
            font-weight: 500;
        }

        /* Grid Layout */
                 .dashboard-grid {
             display: grid;
             grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
             gap: 20px;
             margin-bottom: 20px;
             flex-shrink: 0;
         }

        /* Modern Card */
        .modern-card {
            background: var(--white);
            border-radius: var(--border-radius-lg);
            border: 1px solid var(--gray-200);
            overflow: hidden;
            transition: all 0.3s ease;
            box-shadow: var(--shadow-sm);
        }

        .modern-card:hover {
            box-shadow: var(--shadow-lg);
            transform: translateY(-2px);
        }

        /* Card Header */
        .card-header {
            display: flex;
            align-items: center;
            padding: 24px 24px 0;
            margin-bottom: 20px;
        }

        .card-icon {
            width: 48px;
            height: 48px;
            border-radius: var(--border-radius);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 16px;
        }

        .equipment-icon {
            background: var(--primary-light);
            color: var(--primary-color);
        }

        .inquiry-icon {
            background: var(--warning-light);
            color: var(--warning-color);
        }

        .card-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--gray-900);
            margin: 0;
            flex: 1;
        }

        .view-all-btn {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--primary-color);
            text-decoration: none;
            font-size: 0.875rem;
            font-weight: 500;
            padding: 8px 12px;
            border-radius: 8px;
            transition: all 0.2s ease;
        }

        .view-all-btn:hover {
            background: var(--primary-light);
            color: var(--primary-color);
        }

        /* Card Content */
        .card-content {
            padding: 0 24px 24px;
        }

        /* List Items */
        .equipment-list,
        .inquiry-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .equipment-item,
        .inquiry-item {
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: var(--border-radius);
            padding: 16px;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .equipment-item:hover,
        .inquiry-item:hover {
            background: var(--white);
            border-color: var(--primary-color);
            box-shadow: var(--shadow);
            transform: translateY(-1px);
        }

        .item-main {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 16px;
        }

        .item-info {
            flex: 1;
            min-width: 0;
        }

        .item-name {
            font-size: 1rem;
            font-weight: 600;
            color: var(--gray-900);
            margin: 0 0 8px 0;
            line-height: 1.4;
        }

        .item-meta {
            display: flex;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 0.875rem;
            color: var(--gray-600);
        }

        .meta-item svg {
            color: var(--gray-400);
            flex-shrink: 0;
        }

        /* Status Badges */
        .item-status {
            flex-shrink: 0;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.025em;
        }

        .status-badge.available {
            background: var(--success-light);
            color: var(--success-color);
        }

        .status-badge.unavailable {
            background: var(--danger-light);
            color: var(--danger-color);
        }

        .status-badge.disabled {
            background: var(--gray-100);
            color: var(--gray-500);
        }

        .status-badge.answered {
            background: var(--success-light);
            color: var(--success-color);
        }

        .status-badge.pending {
            background: var(--warning-light);
            color: var(--warning-color);
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 48px 24px;
        }

        .empty-icon {
            color: var(--gray-300);
            margin-bottom: 16px;
        }

        .empty-text {
            color: var(--gray-500);
            font-size: 0.875rem;
            margin: 0;
        }

                 /* Activity Summary */
         .activity-summary {
             grid-column: 1 / -1;
             flex-shrink: 0;
         }

        .summary-header {
            display: flex;
            align-items: center;
            padding: 24px 24px 0;
            margin-bottom: 24px;
        }

        .summary-icon {
            width: 48px;
            height: 48px;
            border-radius: var(--border-radius);
            background: var(--primary-light);
            color: var(--primary-color);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 16px;
        }

        .summary-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--gray-900);
            margin: 0;
        }

        /* Activity Stats */
        .activity-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 24px;
            padding: 0 24px 24px;
        }

        .stat-card {
            background: var(--gray-50);
            border: 1px solid var(--gray-200);
            border-radius: var(--border-radius);
            padding: 24px;
            text-align: center;
            transition: all 0.2s ease;
        }

        .stat-card:hover {
            background: var(--white);
            box-shadow: var(--shadow);
            transform: translateY(-2px);
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: var(--border-radius);
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
        }

        .stat-icon.primary {
            background: var(--primary-light);
            color: var(--primary-color);
        }

        .stat-icon.success {
            background: var(--success-light);
            color: var(--success-color);
        }

        .stat-icon.warning {
            background: var(--warning-light);
            color: var(--warning-color);
        }

        .stat-icon.danger {
            background: var(--danger-light);
            color: var(--danger-color);
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--gray-900);
            line-height: 1;
            margin-bottom: 8px;
        }

        .stat-label {
            font-size: 1rem;
            font-weight: 600;
            color: var(--gray-700);
            margin-bottom: 4px;
        }

        .stat-detail {
            font-size: 0.875rem;
            color: var(--gray-500);
            line-height: 1.4;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .main-body {
                padding: 120px 20px 20px 20px;
            }

            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 16px;
                margin-bottom: 24px;
            }

            .section-title {
                font-size: 1.75rem;
            }

            .dashboard-grid {
                grid-template-columns: 1fr;
                gap: 16px;
                margin-bottom: 24px;
            }

            .card-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 16px;
            }

            .card-icon {
                margin-right: 0;
            }

            .view-all-btn {
                align-self: flex-end;
            }

            .item-main {
                flex-direction: column;
                gap: 12px;
            }

            .item-meta {
                gap: 12px;
            }

            .activity-stats {
                grid-template-columns: repeat(2, 1fr);
                gap: 16px;
            }

            .stat-number {
                font-size: 2rem;
            }
        }

        @media (max-width: 480px) {
            .main-body {
                padding: 100px 15px 15px 15px;
            }

            .section-title {
                font-size: 1.5rem;
            }

            .card-header,
            .summary-header {
                padding: 20px 20px 0;
            }

            .card-content {
                padding: 0 20px 20px;
            }

            .activity-stats {
                grid-template-columns: 1fr;
                padding: 0 20px 20px;
            }

            .item-meta {
                flex-direction: column;
                align-items: flex-start;
                gap: 8px;
            }
        }

        /* Animation Keyframes */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .modern-card {
            animation: fadeInUp 0.6s ease-out;
        }

        .modern-card:nth-child(1) { animation-delay: 0.1s; }
        .modern-card:nth-child(2) { animation-delay: 0.2s; }
        .activity-summary { animation-delay: 0.3s; }

        /* Focus States for Accessibility */
        .equipment-item:focus,
        .inquiry-item:focus,
        .view-all-btn:focus {
            outline: 2px solid var(--primary-color);
            outline-offset: 2px;
        }

        /* Loading State (for future use) */
        .skeleton {
            background: linear-gradient(90deg, var(--gray-200) 25%, var(--gray-100) 50%, var(--gray-200) 75%);
            background-size: 200% 100%;
            animation: loading 1.5s infinite;
        }

        @keyframes loading {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
        }
    </style>

    <!-- 4) 공통 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>

    <script>
        // 부드러운 클릭 애니메이션
        document.querySelectorAll('.equipment-item, .inquiry-item').forEach(item => {
            item.addEventListener('click', function(e) {
                // 클릭 효과
                this.style.transform = 'scale(0.98)';
                setTimeout(() => {
                    this.style.transform = '';
                }, 150);
            });

            // 키보드 접근성
            item.setAttribute('tabindex', '0');
            item.addEventListener('keypress', function(e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    this.click();
                }
            });
        });

        // 카드 호버 효과 개선
        document.querySelectorAll('.modern-card').forEach(card => {
            card.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-4px)';
            });

            card.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(-2px)';
            });
        });

        // 통계 카드 애니메이션
        function animateNumbers() {
            const statNumbers = document.querySelectorAll('.stat-number');
            
            statNumbers.forEach(stat => {
                const finalNumber = parseInt(stat.textContent);
                const duration = 1000; // 1초
                const steps = 60;
                const increment = finalNumber / steps;
                let current = 0;
                
                const timer = setInterval(() => {
                    current += increment;
                    if (current >= finalNumber) {
                        stat.textContent = finalNumber;
                        clearInterval(timer);
                    } else {
                        stat.textContent = Math.floor(current);
                    }
                }, duration / steps);
            });
        }

        // 페이지 로드 후 숫자 애니메이션 실행
        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(animateNumbers, 500);
        });

        // 성능 최적화: Intersection Observer로 뷰포트에 들어올 때만 애니메이션
        if ('IntersectionObserver' in window) {
            const observerOptions = {
                threshold: 0.1,
                rootMargin: '0px 0px -50px 0px'
            };

            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('animate-in');
                        observer.unobserve(entry.target);
                    }
                });
            }, observerOptions);

            document.querySelectorAll('.modern-card').forEach(card => {
                observer.observe(card);
            });
        }
    </script>
</body>
</html>