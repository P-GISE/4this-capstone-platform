<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>채팅방 통계 - ${chatRoom.name}</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .stat-card {
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .stat-value {
            font-size: 24px;
            font-weight: bold;
        }
        .stat-label {
            color: #6c757d;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4>채팅방 통계</h4>
                        <a href="/chat/room/${chatRoom.roomId}" class="btn btn-outline-secondary">돌아가기</a>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-3">
                                <div class="stat-card bg-light">
                                    <div class="stat-value">${stats.totalMessages}</div>
                                    <div class="stat-label">총 메시지 수</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card bg-light">
                                    <div class="stat-value">${stats.activeParticipants}</div>
                                    <div class="stat-label">현재 참여자 수</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card bg-light">
                                    <div class="stat-value">
                                        <fmt:formatDate value="${stats.roomCreatedAt}" pattern="yyyy-MM-dd"/>
                                    </div>
                                    <div class="stat-label">생성일</div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="stat-card bg-light">
                                    <div class="stat-value">${stats.averageMessagesPerDay}</div>
                                    <div class="stat-label">일평균 메시지</div>
                                </div>
                            </div>
                        </div>

                        <div class="row mt-4">
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h5>시간대별 메시지 수</h5>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="messagesByHourChart"></canvas>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h5>사용자별 메시지 수</h5>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="messagesByUserChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row mt-4">
                            <div class="col-md-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h5>최근 활동</h5>
                                    </div>
                                    <div class="card-body">
                                        <div class="table-responsive">
                                            <table class="table">
                                                <thead>
                                                    <tr>
                                                        <th>사용자</th>
                                                        <th>마지막 메시지</th>
                                                        <th>시간</th>
                                                        <th>메시지 수</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach items="${stats.recentActivities}" var="activity">
                                                        <tr>
                                                            <td>
                                                                <div class="d-flex align-items-center">
                                                                    <img src="${activity.userProfileImage}" 
                                                                         alt="프로필" class="rounded-circle mr-2" 
                                                                         width="30" height="30">
                                                                    ${activity.userName}
                                                                </div>
                                                            </td>
                                                            <td>${activity.lastMessage}</td>
                                                            <td>
                                                                <fmt:formatDate value="${activity.lastMessageTime}" 
                                                                              pattern="yyyy-MM-dd HH:mm"/>
                                                            </td>
                                                            <td>${activity.messageCount}</td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 시간대별 메시지 수 차트
        const messagesByHourCtx = document.getElementById('messagesByHourChart').getContext('2d');
        new Chart(messagesByHourCtx, {
            type: 'line',
            data: {
                labels: JSON.parse('${stats.hourlyMessageCounts.labels}'),
                datasets: [{
                    label: '메시지 수',
                    data: JSON.parse('${stats.hourlyMessageCounts.data}'),
                    borderColor: 'rgb(75, 192, 192)',
                    tension: 0.1
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

        // 사용자별 메시지 수 차트
        const messagesByUserCtx = document.getElementById('messagesByUserChart').getContext('2d');
        new Chart(messagesByUserCtx, {
            type: 'pie',
            data: {
                labels: JSON.parse('${stats.userMessageCounts.labels}'),
                datasets: [{
                    data: JSON.parse('${stats.userMessageCounts.data}'),
                    backgroundColor: [
                        'rgb(255, 99, 132)',
                        'rgb(54, 162, 235)',
                        'rgb(255, 205, 86)',
                        'rgb(75, 192, 192)',
                        'rgb(153, 102, 255)'
                    ]
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'right'
                    }
                }
            }
        });
    </script>
</body>
</html> 