<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
            <h1 class="page-title">관리자 활동 로그</h1>
            
            <div class="modern-card">
                <div class="card-header">
                    <div class="header-actions">
                        <button type="button" class="btn btn-secondary" onclick="showCleanupModal()">
                            로그 정리
                        </button>
                        <a href="${pageContext.request.contextPath}/admin/logs/stats" class="btn btn-primary">
                            통계 보기
                        </a>
                    </div>
                </div>

                <!-- 검색 및 필터 영역 -->
                <form method="get" action="${pageContext.request.contextPath}/admin/logs/list" class="search-filter">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label>검색어</label>
                            <input type="text" name="search" value="${search}" placeholder="관리자명, 액션, 설명, IP..." class="form-control">
                        </div>
                        
                        <div class="filter-group">
                            <label>액션 타입</label>
                            <select name="actionType" class="form-control">
                                <option value="">전체</option>
                                <c:forEach var="entry" items="${actionTypes}">
                                    <option value="${entry.key}" ${actionType == entry.key ? 'selected' : ''}>
                                        ${entry.value}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label>로그 레벨</label>
                            <select name="logLevel" class="form-control">
                                <option value="">전체</option>
                                <c:forEach var="entry" items="${logLevels}">
                                    <option value="${entry.key}" ${logLevel == entry.key ? 'selected' : ''}>
                                        ${entry.value}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label>시작일</label>
                            <input type="date" name="dateFrom" value="${dateFrom}" class="form-control">
                        </div>
                        
                        <div class="filter-group">
                            <label>종료일</label>
                            <input type="date" name="dateTo" value="${dateTo}" class="form-control">
                        </div>
                        
                        <div class="filter-group">
                            <label>정렬</label>
                            <select name="sortBy" class="form-control">
                                <option value="latest" ${sortBy == 'latest' ? 'selected' : ''}>최신순</option>
                                <option value="oldest" ${sortBy == 'oldest' ? 'selected' : ''}>오래된순</option>
                                <option value="action_type" ${sortBy == 'action_type' ? 'selected' : ''}>액션순</option>
                                <option value="admin_name" ${sortBy == 'admin_name' ? 'selected' : ''}>관리자순</option>
                                <option value="log_level" ${sortBy == 'log_level' ? 'selected' : ''}>레벨순</option>
                            </select>
                        </div>
                        
                        <div class="filter-actions">
                            <button type="submit" class="btn btn-primary">검색</button>
                            <a href="${pageContext.request.contextPath}/admin/logs/list" class="btn btn-secondary">초기화</a>
                        </div>
                    </div>
                </form>

                <!-- 결과 정보 -->
                <div class="result-info">
                    <span>총 <strong>${totalCount}</strong>건의 로그 (${currentPage} / ${totalPages} 페이지)</span>
                </div>

                <!-- 로그 목록 테이블 -->
                <div class="table-container">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>관리자</th>
                                <th>액션</th>
                                <th>레벨</th>
                                <th>상태</th>
                                <th>설명</th>
                                <th>IP 주소</th>
                                <th>시간</th>
                                <th>상세</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty logs}">
                                    <tr>
                                        <td colspan="9" class="text-center">검색 조건에 맞는 로그가 없습니다.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="log" items="${logs}">
                                        <tr>
                                            <td>#${log.id}</td>
                                            <td>
                                                <div class="user-info">
                                                    <strong>${log.adminName}</strong>
                                                    <c:if test="${not empty log.adminName}">
                                                        <small>ID: ${log.adminId}</small>
                                                    </c:if>
                                                </div>
                                            </td>
                                            <td>
                                                <span class="badge badge-primary">${log.actionTypeDisplay}</span>
                                                <c:if test="${not empty log.targetTable}">
                                                    <div class="text-muted">${log.targetTable}</div>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${log.logLevel == 'CRITICAL'}">
                                                        <span class="badge badge-danger">CRITICAL</span>
                                                    </c:when>
                                                    <c:when test="${log.logLevel == 'ERROR'}">
                                                        <span class="badge badge-danger">ERROR</span>
                                                    </c:when>
                                                    <c:when test="${log.logLevel == 'WARN'}">
                                                        <span class="badge badge-warning">WARN</span>
                                                    </c:when>
                                                    <c:when test="${log.logLevel == 'INFO'}">
                                                        <span class="badge badge-info">INFO</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-secondary">${log.logLevel}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${log.isSuccessful}">
                                                        <span class="badge badge-success">성공</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-danger">실패</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${fn:length(log.description) > 50}">
                                                        ${fn:substring(log.description, 0, 50)}...
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${log.description}
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${log.ipAddress}</td>
                                            <td>
                                                <div class="datetime-info">
                                                    <div><fmt:formatDate value="${log.createdAt}" pattern="MM-dd"/></div>
                                                    <small><fmt:formatDate value="${log.createdAt}" pattern="HH:mm:ss"/></small>
                                                </div>
                                            </td>
                                            <td>
                                                <button class="btn btn-sm btn-primary" onclick="showLogDetail('${log.id}')">상세</button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

                <!-- 페이지네이션 -->
                <c:if test="${totalPages > 1}">
                    <div class="pagination">
                        <c:if test="${currentPage > 1}">
                            <a href="?page=${currentPage - 1}&search=${search}&actionType=${actionType}&logLevel=${logLevel}&dateFrom=${dateFrom}&dateTo=${dateTo}&sortBy=${sortBy}" class="page-link">이전</a>
                        </c:if>
                        
                        <c:forEach var="i" begin="${startPage}" end="${endPage}">
                            <a href="?page=${i}&search=${search}&actionType=${actionType}&logLevel=${logLevel}&dateFrom=${dateFrom}&dateTo=${dateTo}&sortBy=${sortBy}" 
                               class="page-link ${i == currentPage ? 'active' : ''}">${i}</a>
                        </c:forEach>
                        
                        <c:if test="${currentPage < totalPages}">
                            <a href="?page=${currentPage + 1}&search=${search}&actionType=${actionType}&logLevel=${logLevel}&dateFrom=${dateFrom}&dateTo=${dateTo}&sortBy=${sortBy}" class="page-link">다음</a>
                        </c:if>
                    </div>
                </c:if>
            </div>
        </div>

        <!-- 푸터 -->
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>

    <style>
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
        
    </style>
    <script>

        
        function showCleanupModal() {
            // 로그 정리 모달 표시 로직
            alert('로그 정리 기능을 구현해주세요.');
        }
        
        function showLogDetail(logId) {
            // 로그 상세 정보 표시 로직
            alert('로그 ID: ' + logId + '의 상세 정보를 표시합니다.');
        }
    </script>
</body>
</html> 