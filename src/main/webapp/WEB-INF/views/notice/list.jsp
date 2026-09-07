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
            justify-content: space-between;
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
            margin-left: auto;
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
            transition: background-color 0.2s;
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
        
        /* 🔵 중요 아이콘 스타일 */
        .important-icon {
            display: inline-block;
            font-size: 1rem;
            margin-left: 5px;
            vertical-align: middle;
            color: #ff6b6b;
        }
        
        /* 🔵 공지사항 제목 링크 스타일 수정 */
        .notice-title-link {
            color: #333 !important;
            text-decoration: none !important;
            font-weight: 500;
        }

        .notice-title-link:hover {
            color: #333 !important;
            text-decoration: none !important;
        }

        .notice-title-link:visited {
            color: #333 !important;
        }

        .notice-title-link:active {
            color: #333 !important;
        }

        /* 🔵 자료정보 파일명 스타일 수정 (호버 효과 제거) */
        .file-name-text {
            color: #333;
            font-weight: 500;
            cursor: default;
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
        
        /* 탭 버튼 스타일 */
        .tab-buttons {
            display: flex;
            gap: 5px;
        }
        
        .tab-btn {
            background-color: #f0f2f5;
            border: none;
            padding: 8px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 500;
            color: #333;
            transition: all 0.3s;
            text-decoration: none;
        }
        
        .tab-btn.active {
            background-color: #6c63ff;
            color: white;
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
                <h2 class="section-title">공지사항</h2>
                <c:if test="${userRole != 'STUDENT'}">
                    <a href="/notice/write" class="btn btn-primary">+ 공지</a>
                </c:if>
            </div>

            <!-- 메시지 -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">${errorMessage}</div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">${successMessage}</div>
            </c:if>

            <div class="inquiry-card">
                <!-- 탭 버튼과 검색 영역 -->
                <div class="search-section">
                    <div class="tab-buttons">
                        <a href="/notice/list?tab=notice" class="tab-btn ${tab == 'notice' ? 'active' : ''}">공지</a>
                        <a href="/notice/list?tab=files" class="tab-btn ${tab == 'files' ? 'active' : ''}">자료정보</a>
                    </div>
                    
                    <form method="get" action="/notice/list" class="search-form">
                        <input type="hidden" name="tab" value="${tab}" />
                        <input type="text" name="search" class="search-input" placeholder="공지사항 검색..." value="${param.search}">
                        <button class="btn btn-outline" type="submit">검색</button>
                        
                        <div class="filter-selects">
                            <select name="category" class="filter-select" onchange="this.form.submit()">
                                <option value="">전체 카테고리</option>
                                <option value="일반" ${param.category == '일반' ? 'selected' : ''}>일반</option>
                                <option value="학사" ${param.category == '학사' ? 'selected' : ''}>학사</option>
                                <option value="취업" ${param.category == '취업' ? 'selected' : ''}>취업</option>
                                <option value="행사" ${param.category == '행사' ? 'selected' : ''}>행사</option>
                                <option value="시설" ${param.category == '시설' ? 'selected' : ''}>시설</option>
                                <option value="기타" ${param.category == '기타' ? 'selected' : ''}>기타</option>
                            </select>
                        </div>
                    </form>
                </div>

                <!-- 공지사항 목록 -->
                <c:if test="${tab == 'notice'}">
                    <table class="inquiry-table">
                        <thead>
                            <tr>
                                <th style="width: 80px;">번호</th>
                                <th style="width: 100px;">카테고리</th>
                                <th>제목</th>
                                <th style="width: 120px;">작성자</th>
                                <th style="width: 120px;">작성일</th>
                                <th style="width: 80px;">조회수</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="notice" items="${notices}" varStatus="status">
                                <tr>
                                    <!-- 🔵 번호 옆에 중요 아이콘 표시 -->
                                    <td>
                                        ${totalCount - (currentPage - 1) * pageSize - status.index}
                                        <c:if test="${notice.important}">
                                            <span class="important-icon" title="중요 공지">📌</span>
                                        </c:if>
                                    </td>
                                    <td>${notice.category}</td>
                                    <td>
                                        <!-- 🔵 수정: 공지사항 제목 링크 (검은색 유지) -->
                                        <a href="/notice/view?id=${notice.id}" class="notice-title-link">${notice.title}</a>
                                    </td>
                                    <td>${notice.writerName}</td>
                                    <td>
                                        <fmt:formatDate value="${notice.createdAt}" pattern="yyyy.MM.dd" />
                                    </td>
                                    <td>${notice.viewCount}</td>
                                </tr>
                            </c:forEach>
                            
                            <!-- 데이터가 없을 때 -->
                            <c:if test="${empty notices}">
                                <tr>
                                    <td colspan="6" class="empty-message">
                                        등록된 공지사항이 없습니다.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </c:if>

                <!-- 자료정보 목록 -->
                <c:if test="${tab == 'files'}">
                    <table class="inquiry-table">
                        <thead>
                            <tr>
                                <th style="width: 80px;">번호</th>
                                <th style="width: 100px;">카테고리</th>
                                <th>파일명</th>
                                <th style="width: 120px;">작성자</th>
                                <th style="width: 120px;">업로드일</th>
                                <th style="width: 100px;">다운로드</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="file" items="${files}" varStatus="status">
                                <tr>
                                    <!-- 🔵 수정: 공지 탭과 동일한 번호 계산 방식 적용 -->
                                    <td>
                                        ${totalCount - (currentPage - 1) * pageSize - status.index}
                                    </td>
                                    <td>${file.category}</td>
                                    <td>
                                        <!-- 🔵 수정: 파일명은 클릭할 수 없는 텍스트 (호버 효과 없음) -->
                                        <div class="inquiry-title">
                                            <span class="file-name-text">${file.originalFileName}</span>
                                        </div>
                                    </td>
                                    <td>${file.writerName}</td>
                                    <td><fmt:formatDate value="${file.uploadedAt}" pattern="yyyy.MM.dd" /></td>
                                    <td>
                                        <c:url var="downloadUrl" value="/notice/download">
                                            <c:param name="file" value="${file.fileName}" />
                                            <c:param name="original" value="${file.originalFileName}" />
                                        </c:url>
                                        <a href="${downloadUrl}" class="btn btn-outline" style="padding: 4px 8px; font-size: 0.8rem;">다운로드</a>
                                    </td>
                                </tr>
                            </c:forEach>
                            
                            <!-- 데이터가 없을 때 -->
                            <c:if test="${empty files}">
                                <tr>
                                    <td colspan="6" class="empty-message">
                                        등록된 파일이 없습니다.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </c:if>

                <!-- 페이지네이션 -->
                <div class="pagination">
                    <c:if test="${currentPage > 1}">
                        <a href="?page=1&tab=${tab}&category=${param.category}&search=${param.search}" class="page-btn">«</a>
                        <a href="?page=${currentPage - 1}&tab=${tab}&category=${param.category}&search=${param.search}" class="page-btn">‹</a>
                    </c:if>
                    
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <c:choose>
                            <c:when test="${i == currentPage}">
                                <span class="page-btn active">${i}</span>
                            </c:when>
                            <c:otherwise>
                                <a href="?page=${i}&tab=${tab}&category=${param.category}&search=${param.search}" class="page-btn">${i}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    
                    <c:if test="${currentPage < totalPages}">
                        <a href="?page=${currentPage + 1}&tab=${tab}&category=${param.category}&search=${param.search}" class="page-btn">›</a>
                        <a href="?page=${totalPages}&tab=${tab}&category=${param.category}&search=${param.search}" class="page-btn">»</a>
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