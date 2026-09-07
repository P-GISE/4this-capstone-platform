<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<head>
    <title>문의사항</title>
    <style>

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
        
        .section-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 20px;
            color: #333;
        }
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .inquiry-card {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        }
        
        .search-section {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .search-form {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .search-input {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 0.9rem;
            width: 200px;
        }
        
        .filter-selects {
            display: flex;
            gap: 10px;
        }
        
        .filter-select {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: white;
            cursor: pointer;
            font-size: 0.9rem;
        }
        
        .btn {
            padding: 8px 15px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 500;
            border: none;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            font-size: 0.9rem;
        }
        
        .btn-primary {
            background-color: #4751c9;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #6c63ff;
        }
        
        .btn-outline {
            background-color: white;
            border: 1px solid #ddd;
            color: #333;
        }
        
        .btn-outline:hover {
            background-color: #f5f5f5;
        }
        
        .inquiry-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        
        .inquiry-table th,
        .inquiry-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        
        .inquiry-table th {
            background-color: #f8f9fa;
            font-weight: 600;
            color: #333;
            font-size: 0.9rem;
        }
        
        .inquiry-table td {
            font-size: 0.9rem;
            color: #555;
        }
        
        .inquiry-table tbody tr {
            cursor: pointer;
            transition: background-color 0.2s;
        }
        
        .inquiry-table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        .inquiry-title {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .inquiry-title-link {
            color: #333;
            text-decoration: none;
            font-weight: 500;
        }
        
        .inquiry-title-link:hover {
            color: #6c63ff;
            text-decoration: underline;
        }
        
        .badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 500;
        }
        
        .badge-answered {
            background-color: #52c41a;
            color: white;
        }
        
        .badge-pending {
            background-color: #8c8c8c;
            color: white;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 5px;
            margin-top: 20px;
        }
        
        .page-btn {
            background-color: white;
            border: 1px solid #ddd;
            padding: 8px 12px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 0.9rem;
            transition: all 0.3s;
            min-width: 35px;
            text-align: center;
            text-decoration: none;
            color: #333;
        }
        
        .page-btn:hover:not(.active) {
            background-color: #f5f5f5;
            color: #6c63ff;
        }
        
        .page-btn.active {
            background-color: #6c63ff;
            color: white;
            border-color: #6c63ff;
        }
        
        .empty-message {
            text-align: center;
            padding: 40px;
            color: #666;
            font-size: 0.9rem;
        }
        
        .alert {
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 0.9rem;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
    </style>
</head>
<body>
    <!-- 사이드바 -->
    <div class="sidebar">
        <%@ include file="../layout/sidebar.jsp" %>
    </div>

    <!-- 메인 콘텐츠 -->
    <div class="content">
        <%@ include file="../layout/header.jsp" %>
        <div class="main-body">
            <div class="page-header">
                <h2 class="section-title">문의사항</h2>
                <a href="/inquiry/write" class="btn btn-primary">+ 문의하기</a>
            </div>

            <c:if test="${param.error == 'access_denied'}">
                <div class="alert alert-warning" style="margin-bottom: 20px; padding: 15px; background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 5px; color: #856404;">
                    <strong>⚠️ 접근 권한이 없습니다.</strong> 본인이 작성한 문의사항만 조회할 수 있습니다.
                </div>
            </c:if>

            <c:if test="${param.error == 'not_found'}">
                <div class="alert alert-danger" style="margin-bottom: 20px; padding: 15px; background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 5px; color: #721c24;">
                    <strong>❌ 문의사항을 찾을 수 없습니다.</strong> 삭제되었거나 존재하지 않는 문의사항입니다.
                </div>
            </c:if>

            <c:if test="${param.deleted == 'true'}">
                <div class="alert alert-success" style="margin-bottom: 20px; padding: 15px; background-color: #d4edda; border: 1px solid #c3e6cb; border-radius: 5px; color: #155724;">
                    <strong>✅ 문의사항이 삭제되었습니다.</strong>
                </div>
            </c:if>

            <!-- 메시지 -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">${errorMessage}</div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">${successMessage}</div>
            </c:if>

            <div class="inquiry-card">
                <!-- 검색 및 필터 영역 -->
                <div class="search-section">
                    <form method="get" action="/inquiry/list" class="search-form">
                        <input type="text" name="search" class="search-input" placeholder="문의사항 검색..." value="${param.search}">
                        <button class="btn btn-outline" type="submit">검색</button>
                        
                        <div class="filter-selects">
                            <select class="filter-select" name="status" onchange="this.form.submit()">
                                <option value="">전체 문의</option>
                                <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>대기중</option>
                                <option value="ANSWERED" ${param.status == 'ANSWERED' ? 'selected' : ''}>답변완료</option>
                            </select>
                            <select class="filter-select" name="sort" onchange="this.form.submit()">
                                <option value="latest" ${param.sort == 'latest' ? 'selected' : ''}>최신순</option>
                                <option value="oldest" ${param.sort == 'oldest' ? 'selected' : ''}>등록순</option>
                            </select>
                        </div>
                    </form>
                </div>

                <!-- 문의사항 테이블 -->
                <table class="inquiry-table">
                    <thead>
                        <tr>
                            <th style="width: 80px;">번호</th>
                            <th>제목</th>
                            <th style="width: 120px;">작성자</th>
                            <th style="width: 120px;">작성일</th>
                            <th style="width: 100px;">상태</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="inq" items="${inquiryList}" varStatus="status">
                            <tr onclick="location.href='/inquiry/view?id=${inq.id}'">
                                <td>${totalCount - (currentPage - 1) * pageSize - status.index}</td>
                                <td>
                                    <div class="inquiry-title">
                                        <a href="/inquiry/view?id=${inq.id}" class="inquiry-title-link">
                                            <c:out value="${inq.title}" />
                                        </a>
                                    </div>
                                </td>
                                <td>${inq.writerName}</td>
                                <td><fmt:formatDate value="${inq.createdAt}" pattern="yyyy.MM.dd" /></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${inq.status == 'ANSWERED'}">
                                            <span class="badge badge-answered">답변완료</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-pending">대기중</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <!-- 데이터가 없을 때 -->
                        <c:if test="${empty inquiryList}">
                            <tr>
                                <td colspan="5" class="empty-message">
                                    등록된 문의사항이 없습니다.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>

                <!-- 페이지네이션 -->
                <div class="pagination">
                    <c:if test="${currentPage > 1}">
                        <a href="?page=1&search=${param.search}&status=${param.status}&sort=${param.sort}" class="page-btn">«</a>
                        <a href="?page=${currentPage - 1}&search=${param.search}&status=${param.status}&sort=${param.sort}" class="page-btn">‹</a>
                    </c:if>
                    
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span class="page-btn active">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="?page=${i}&search=${param.search}&status=${param.status}&sort=${param.sort}" class="page-btn">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    
                    <c:if test="${currentPage < totalPages}">
                        <a href="?page=${currentPage + 1}&search=${param.search}&status=${param.status}&sort=${param.sort}" class="page-btn">›</a>
                        <a href="?page=${totalPages}&search=${param.search}&status=${param.status}&sort=${param.sort}" class="page-btn">»</a>
                    </c:if>
                </div>
            </div>
        </div>
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 공통 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // 검색 폼 엔터키 처리
            const searchInput = document.querySelector('.search-input');
            if (searchInput) {
                searchInput.addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') {
                        this.form.submit();
                    }
                });
            }
        });
    </script>
</body>
</html>