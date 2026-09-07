<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

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
            <h1 class="page-title">관리자 활동 통계</h1>
            
            <div class="modern-card">
                <div class="card-header">
                    <div class="header-actions">
                        <a href="${pageContext.request.contextPath}/admin/logs/list" class="btn btn-primary">활동 로그</a>
                    </div>
                </div>

                <!-- 날짜 필터 영역 -->
                <form method="get" class="search-filter">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label>시작일</label>
                            <input type="date" name="dateFrom" value="${dateFrom}" class="form-control">
                        </div>
                        <div class="filter-group">
                            <label>종료일</label>
                            <input type="date" name="dateTo" value="${dateTo}" class="form-control">
                        </div>
                        <div class="filter-actions">
                            <button type="submit" class="btn btn-primary">조회</button>
                        </div>
                    </div>
                </form>

                <!-- 차트 그리드 -->
                <div class="charts-grid">
                    <!-- 액션 타입별 통계 -->
                    <div class="chart-card">
                        <h3>액션 타입별 통계</h3>
                        <div class="chart-body">
                            <canvas id="actionTypeChart"></canvas>
                        </div>
                    </div>

                    <!-- 로그 레벨별 통계 -->
                    <div class="chart-card">
                        <h3>로그 레벨별 통계</h3>
                        <div class="chart-body">
                            <canvas id="logLevelChart"></canvas>
                        </div>
                    </div>

                    <!-- 일별 활동 통계 -->
                    <div class="chart-card chart-full">
                        <h3>일별 활동 통계</h3>
                        <div class="chart-body">
                            <canvas id="dailyActivityChart"></canvas>
                        </div>
                    </div>

                    <!-- 관리자별 활동 통계 -->
                    <div class="chart-card chart-full">
                        <h3>관리자별 활동 통계</h3>
                        <div class="table-container">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>관리자</th>
                                        <th>전체 활동</th>
                                        <th>성공</th>
                                        <th>실패</th>
                                        <th>최근 활동</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="stat" items="${adminActivityStats}">
                                        <tr>
                                            <td><strong>${stat.adminName}</strong></td>
                                            <td>${stat.totalCount}</td>
                                            <td><span class="badge badge-success">${stat.successCount}</span></td>
                                            <td><span class="badge badge-danger">${stat.failureCount}</span></td>
                                            <td>
                                                <fmt:formatDate value="${stat.lastActivity}" pattern="yyyy-MM-dd HH:mm"/>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 푸터 -->
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

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

        .charts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 24px;
            margin-top: 24px;
        }

        .chart-card {
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .chart-full {
            grid-column: 1 / -1;
        }

        .chart-card h3 {
            margin-bottom: 16px;
            color: #374151;
            font-size: 1.125rem;
            font-weight: 600;
        }

        .chart-body {
            height: 300px;
            position: relative;
        }

        .chart-full .chart-body {
            height: 400px;
        }

        @media (max-width: 768px) {
            .charts-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>

    <script>
        // 액션 타입별 차트
        const actionTypeCtx = document.getElementById('actionTypeChart').getContext('2d');
        new Chart(actionTypeCtx, {
            type: 'doughnut',
            data: {
                labels: [
                    <c:forEach var="stat" items="${actionTypeStats}" varStatus="status">
                        '${stat.actionType}'${!status.last ? ',' : ''}
                    </c:forEach>
                ],
                datasets: [{
                    data: [
                        <c:forEach var="stat" items="${actionTypeStats}" varStatus="status">
                            ${stat.count}${!status.last ? ',' : ''}
                        </c:forEach>
                    ],
                    backgroundColor: ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#6b7280']
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });

        // 로그 레벨별 차트
        const logLevelCtx = document.getElementById('logLevelChart').getContext('2d');
        new Chart(logLevelCtx, {
            type: 'bar',
            data: {
                labels: [
                    <c:forEach var="stat" items="${logLevelStats}" varStatus="status">
                        '${stat.logLevel}'${!status.last ? ',' : ''}
                    </c:forEach>
                ],
                datasets: [{
                    label: '로그 수',
                    data: [
                        <c:forEach var="stat" items="${logLevelStats}" varStatus="status">
                            ${stat.count}${!status.last ? ',' : ''}
                        </c:forEach>
                    ],
                    backgroundColor: '#3b82f6'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });

        // 일별 활동 차트
        const dailyCtx = document.getElementById('dailyActivityChart').getContext('2d');
        new Chart(dailyCtx, {
            type: 'line',
            data: {
                labels: [
                    <c:forEach var="stat" items="${dailyLogStats}" varStatus="status">
                        '${stat.logDate}'${!status.last ? ',' : ''}
                    </c:forEach>
                ],
                datasets: [{
                    label: '성공',
                    data: [
                        <c:forEach var="stat" items="${dailyLogStats}" varStatus="status">
                            ${stat.successCount}${!status.last ? ',' : ''}
                        </c:forEach>
                    ],
                    borderColor: '#10b981',
                    backgroundColor: 'rgba(16, 185, 129, 0.1)',
                    tension: 0.1
                }, {
                    label: '실패',
                    data: [
                        <c:forEach var="stat" items="${dailyLogStats}" varStatus="status">
                            ${stat.failureCount}${!status.last ? ',' : ''}
                        </c:forEach>
                    ],
                    borderColor: '#ef4444',
                    backgroundColor: 'rgba(239, 68, 68, 0.1)',
                    tension: 0.1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'top'
                    }
                }
            }
        });
    </script>
</body>
</html> 
