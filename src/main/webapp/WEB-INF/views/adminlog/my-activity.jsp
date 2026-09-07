<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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

        <!-- 2-2) 실제 콘텐츠 -->
        <div class="main-body">
            <div class="my-activity-page">
                <div class="page-header">
                    <h1><i class="fas fa-user-cog" style="margin-right: 8px;"></i>내 활동 로그</h1>
                    <div class="header-buttons">
                        <a href="${pageContext.request.contextPath}/admin/logs/list" class="btn btn-outline">
                            <i class="fas fa-list" style="margin-right: 5px;"></i>전체 로그
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/logs/stats" class="btn btn-outline">
                            <i class="fas fa-chart-bar" style="margin-right: 5px;"></i>통계
                        </a>
                    </div>
                </div>

                <!-- 내 활동 카드 -->
                <div class="activity-card">
                    <!-- 결과 요약 -->
                    <div class="result-summary">
                        <span class="text-muted">
                            최근 <strong>${limit}</strong>개의 활동 기록
                        </span>
                    </div>

                    <!-- 활동 로그 테이블 -->
                    <div class="table-responsive">
                        <table class="activity-table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>액션</th>
                                    <th>레벨</th>
                                    <th>상태</th>
                                    <th>설명</th>
                                    <th>시간</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty logs}">
                                        <tr>
                                            <td colspan="6" class="text-center">
                                                활동 기록이 없습니다.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="log" items="${logs}">
                                            <tr>
                                                <td>${log.id}</td>
                                                <td>
                                                    <span class="action-type">
                                                        <c:choose>
                                                            <c:when test="${log.actionType == 'LOGIN'}">
                                                                <i class="fas fa-sign-in-alt" style="color: #28a745;"></i> 로그인
                                                            </c:when>
                                                            <c:when test="${log.actionType == 'LOGOUT'}">
                                                                <i class="fas fa-sign-out-alt" style="color: #6c757d;"></i> 로그아웃
                                                            </c:when>
                                                            <c:when test="${log.actionType == 'CREATE'}">
                                                                <i class="fas fa-plus" style="color: #007bff;"></i> 생성
                                                            </c:when>
                                                            <c:when test="${log.actionType == 'UPDATE'}">
                                                                <i class="fas fa-edit" style="color: #ffc107;"></i> 수정
                                                            </c:when>
                                                            <c:when test="${log.actionType == 'DELETE'}">
                                                                <i class="fas fa-trash" style="color: #dc3545;"></i> 삭제
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="fas fa-cog" style="color: #6c757d;"></i> ${log.actionType}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${log.logLevel == 'CRITICAL'}">
                                                            <span class="badge badge-critical">CRITICAL</span>
                                                        </c:when>
                                                        <c:when test="${log.logLevel == 'ERROR'}">
                                                            <span class="badge badge-error">ERROR</span>
                                                        </c:when>
                                                        <c:when test="${log.logLevel == 'WARN'}">
                                                            <span class="badge badge-warning">WARN</span>
                                                        </c:when>
                                                        <c:when test="${log.logLevel == 'INFO'}">
                                                            <span class="badge badge-info">INFO</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-default">${log.logLevel}</span>
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
                                                <td class="description">
                                                    ${log.description}
                                                    <c:if test="${not empty log.targetTable}">
                                                        <br><small class="text-muted">테이블: ${log.targetTable}</small>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <div class="datetime-main">
                                                        <fmt:formatDate value="${log.createdAt}" pattern="MM-dd"/>
                                                    </div>
                                                    <small class="datetime-sub">
                                                        <fmt:formatDate value="${log.createdAt}" pattern="HH:mm:ss"/>
                                                    </small>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2-3) 푸터 -->
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 3) 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>

    <style>
        /* 기본 스타일 리셋 */
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

        /* 페이지 헤더 */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .my-activity-page h1 {
            font-size: 24px;
            color: #333;
        }

        .header-buttons {
            display: flex;
            gap: 10px;
        }

        /* 버튼 스타일 */
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
            font-size: 0.9rem;
        }

        .btn-outline {
            background-color: white;
            border: 1px solid #ddd;
            color: #333;
        }

        .btn-outline:hover {
            background-color: #f5f5f5;
        }

        /* 카드 스타일 */
        .activity-card {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        }

        /* 결과 요약 */
        .result-summary {
            margin-bottom: 20px;
            font-size: 14px;
        }

        .text-muted {
            color: #6c757d;
        }

        /* 테이블 */
        .activity-table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }

        .activity-table th,
        .activity-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #f0f0f0;
            text-align: left;
            font-size: 14px;
            color: #333;
        }

        .activity-table th {
            background: #fafafa;
            font-weight: 600;
            color: #333;
        }

        .activity-table tbody tr:hover {
            background-color: #f8f9fa;
        }

        /* 액션 타입 */
        .action-type {
            display: flex;
            align-items: center;
            gap: 5px;
            font-weight: 500;
        }

        /* 설명 컬럼 */
        .description {
            max-width: 300px;
            word-wrap: break-word;
        }

        /* 날짜시간 */
        .datetime-main {
            font-weight: 500;
            color: #333;
        }

        .datetime-sub {
            color: #6c757d;
            font-size: 12px;
        }

        /* 배지 스타일 */
        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 500;
            color: #fff;
        }

        .badge-critical { 
            background-color: #8B0000; 
        }

        .badge-error { 
            background-color: #dc3545; 
        }

        .badge-warning { 
            background-color: #ffc107; 
            color: #212529;
        }

        .badge-info { 
            background-color: #17a2b8; 
        }

        .badge-success { 
            background-color: #28a745; 
        }

        .badge-danger { 
            background-color: #dc3545; 
        }

        .badge-default { 
            background-color: #6c757d; 
        }

        /* 테이블 반응형 */
        .table-responsive {
            overflow-x: auto;
        }

        /* 텍스트 센터 */
        .text-center {
            text-align: center;
            padding: 30px 0;
            color: #6c757d;
        }

        /* 반응형 */
        @media (max-width: 768px) {
            .page-header {
                flex-direction: column;
                gap: 10px;
                align-items: stretch;
            }
            
            .header-buttons {
                justify-content: stretch;
            }
            
            .header-buttons .btn {
                flex: 1;
                justify-content: center;
            }
        }
    </style>
</body>
</html>
