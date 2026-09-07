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
            <div class="userlog-stats-page">
                <div class="page-header">
                    <h1><i class="fas fa-chart-line" style="margin-right: 8px;"></i>사용자 접속 통계</h1>
                    <a href="${pageContext.request.contextPath}/admin/user-logs/list" class="btn btn-outline">
                        <i class="fas fa-list" style="margin-right: 5px;"></i>로그 목록
                    </a>
                </div>

                <!-- 날짜 필터 카드 -->
                <div class="stats-card">
                    <h3><i class="fas fa-calendar-alt" style="margin-right: 8px;"></i>조회 기간</h3>
                    <form method="get" class="date-filter-form">
                        <input type="date" class="date-input" name="dateFrom" value="${dateFrom}">
                        <input type="date" class="date-input" name="dateTo" value="${dateTo}">
                        <button type="submit" class="btn btn-primary">조회</button>
                    </form>
                </div>

                <!-- 차트 그리드 -->
                <div class="charts-grid">
                    <!-- 로그인 타입별 통계 -->
                    <div class="chart-card">
                        <div class="chart-header">
                            <h3><i class="fas fa-chart-pie" style="margin-right: 8px;"></i>로그인 타입별 통계</h3>
                        </div>
                        <div class="chart-body">
                            <canvas id="loginTypeChart"></canvas>
                        </div>
                    </div>

                    <!-- 사용자 역할별 통계 -->
                    <div class="chart-card">
                        <div class="chart-header">
                            <h3><i class="fas fa-users" style="margin-right: 8px;"></i>사용자 역할별 통계</h3>
                        </div>
                        <div class="chart-body">
                            <canvas id="userRoleChart"></canvas>
                        </div>
                    </div>

                    <!-- 일별 접속 통계 -->
                    <div class="chart-card chart-card-full">
                        <div class="chart-header">
                            <h3><i class="fas fa-chart-line" style="margin-right: 8px;"></i>일별 접속 통계</h3>
                        </div>
                        <div class="chart-body">
                            <canvas id="dailyAccessChart"></canvas>
                        </div>
                    </div>

                    <!-- 브라우저별 통계 -->
                    <div class="chart-card">
                        <div class="chart-header">
                            <h3><i class="fas fa-globe" style="margin-right: 8px;"></i>브라우저별 통계</h3>
                        </div>
                        <div class="chart-body">
                            <table class="stats-table">
                                <thead>
                                    <tr>
                                        <th>브라우저</th>
                                        <th>접속 수</th>
                                        <th>사용자 수</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="stat" items="${statistics.browserStats}">
                                        <tr>
                                            <td>${stat.browser}</td>
                                            <td>${stat.count}</td>
                                            <td>${stat.uniqueUserCount}</td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- IP별 접속 통계 -->
                    <div class="chart-card">
                        <div class="chart-header">
                            <h3><i class="fas fa-network-wired" style="margin-right: 8px;"></i>IP별 접속 통계 (상위 7개)</h3>
                        </div>
                        <div class="chart-body">
                            <table class="stats-table">
                                <thead>
                                    <tr>
                                        <th>IP 주소</th>
                                        <th>접속 수</th>
                                        <th>사용자 수</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="stat" items="${statistics.ipStats}">
                                        <tr>
                                            <td class="ip-address">${stat.ipAddress}</td>
                                            <td>${stat.accessCount}</td>
                                            <td>${stat.uniqueUserCount}</td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2-3) 푸터 -->
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 3) 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <script>
        // 로그인 타입별 차트
        const loginTypeCtx = document.getElementById('loginTypeChart').getContext('2d');
        new Chart(loginTypeCtx, {
            type: 'doughnut',
            data: {
                labels: [
                    <c:forEach var="stat" items="${statistics.loginTypeStats}" varStatus="status">
                        '${stat.loginType == "LOGIN" ? "로그인" : stat.loginType == "LOGOUT" ? "로그아웃" : "실패"}'${!status.last ? ',' : ''}
                    </c:forEach>
                ],
                datasets: [{
                    data: [
                        <c:forEach var="stat" items="${statistics.loginTypeStats}" varStatus="status">
                            ${stat.count}${!status.last ? ',' : ''}
                        </c:forEach>
                    ],
                    backgroundColor: ['#28a745', '#6c757d', '#dc3545']
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });

        // 사용자 역할별 차트
        const userRoleCtx = document.getElementById('userRoleChart').getContext('2d');
        new Chart(userRoleCtx, {
            type: 'bar',
            data: {
                labels: [
                    <c:forEach var="stat" items="${statistics.userRoleStats}" varStatus="status">
                        '${stat.userRole == "ADMIN" ? "관리자" : stat.userRole == "STUDENT" ? "학생" : stat.userRole == "STAFF" ? "교직원" : stat.userRole == "ASSISTANT" ? "조교" : "교수"}'${!status.last ? ',' : ''}
                    </c:forEach>
                ],
                datasets: [{
                    label: '총 접속 수',
                    data: [
                        <c:forEach var="stat" items="${statistics.userRoleStats}" varStatus="status">
                            ${stat.totalCount}${!status.last ? ',' : ''}
                        </c:forEach>
                    ],
                    backgroundColor: '#007bff'
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        display: false
                    }
                }
            }
        });

        // 일별 접속 차트
        const dailyCtx = document.getElementById('dailyAccessChart').getContext('2d');
        new Chart(dailyCtx, {
            type: 'line',
            data: {
                labels: [
                    <c:forEach var="stat" items="${statistics.dailyStats}" varStatus="status">
                        '${stat.date}'${!status.last ? ',' : ''}
                    </c:forEach>
                ],
                datasets: [{
                    label: '일일 접속 수',
                    data: [
                        <c:forEach var="stat" items="${statistics.dailyStats}" varStatus="status">
                            ${stat.count}${!status.last ? ',' : ''}
                        </c:forEach>
                    ],
                    borderColor: '#007bff',
                    backgroundColor: 'rgba(0, 123, 255, 0.1)',
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    </script>

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

        .userlog-stats-page h1 {
            font-size: 24px;
            color: #333;
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

        /* 카드 스타일 */
        .stats-card, .chart-card {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        }

        .stats-card h3, .chart-header h3 {
            font-size: 16px;
            color: #333;
            margin-bottom: 15px;
            font-weight: 600;
        }

        /* 날짜 필터 */
        .date-filter-form {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .date-input {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 0.9rem;
        }

        /* 차트 그리드 */
        .charts-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .chart-card-full {
            grid-column: 1 / -1;
        }

        .chart-body {
            position: relative;
            height: 300px;
        }

        .chart-card-full .chart-body {
            height: 400px;
        }

        /* 통계 테이블 */
        .stats-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .stats-table th,
        .stats-table td {
            padding: 8px 12px;
            text-align: left;
            border-bottom: 1px solid #f0f0f0;
        }

        .stats-table th {
            background: #fafafa;
            font-weight: 600;
            color: #333;
        }

        .stats-table td {
            color: #555;
        }

        .ip-address {
            font-family: 'Courier New', monospace;
            font-size: 13px;
        }

        /* 반응형 */
        @media (max-width: 768px) {
            .charts-grid {
                grid-template-columns: 1fr;
            }
            
            .date-filter-form {
                flex-direction: column;
                align-items: stretch;
            }
            
            .page-header {
                flex-direction: column;
                gap: 10px;
                align-items: stretch;
            }
        }
    </style>
</body>
</html> 