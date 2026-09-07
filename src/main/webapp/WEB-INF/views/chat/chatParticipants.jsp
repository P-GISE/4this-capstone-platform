<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>참여자 목록 - 채팅방</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/boxicons@2.0.7/css/boxicons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700&display=swap');
        
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            overflow: hidden;
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        
        .participants-container {
            height: 100vh;
            display: flex;
            flex-direction: column;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border-radius: 20px;
            box-shadow: 0 32px 64px -12px rgba(0, 0, 0, 0.15);
            margin: 16px;
            overflow: hidden;
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        
        /* 헤더 영역 - chatRoom.jsp와 동일한 비율 */
        .participants-header {
            padding: 24px 28px;
            border-bottom: 1px solid rgba(226, 232, 240, 0.8);
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            flex-shrink: 0;
            color: white;
            position: relative;
            overflow: hidden;
        }
        
        .participants-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(255,255,255,0.1) 0%, transparent 100%);
            pointer-events: none;
        }
        
        .participants-title {
            margin: 0 0 12px 0;
            font-size: 20px;
            font-weight: 700;
            color: white;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            position: relative;
            z-index: 2;
        }
        
        .participants-title i {
            margin-right: 12px;
            color: white;
            font-size: 20px;
        }
        
        .participants-count {
            display: flex;
            align-items: center;
            color: rgba(255, 255, 255, 0.85);
            font-size: 15px;
            font-weight: 500;
            position: relative;
            z-index: 2;
        }
        
        .participants-count i {
            margin-right: 8px;
            color: rgba(255, 255, 255, 0.9);
        }
        
        /* 상태 필터 영역 - 더 눈에 띄게 */
        .status-filter {
            padding: 20px 28px;
            border-bottom: 1px solid rgba(226, 232, 240, 0.8);
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            flex-shrink: 0;
            backdrop-filter: blur(10px);
        }
        
        .status-filter-label {
            font-size: 16px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 16px;
            text-align: center;
        }
        
        .status-buttons {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
        }
        
        .status-btn {
            padding: 12px 20px;
            border: 2px solid #e2e8f0;
            border-radius: 25px;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            color: #64748b;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            min-width: 90px;
            justify-content: center;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            backdrop-filter: blur(10px);
        }
        
        .status-btn:hover {
            background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
            transform: translateY(-2px);
            border-color: #cbd5e1;
        }
        
        .status-btn.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-color: transparent;
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
            transform: translateY(-3px);
        }
        
        .status-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 4px;
            box-shadow: 0 0 0 2px rgba(255, 255, 255, 0.3);
        }
        
        .status-dot.online {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        }
        
        .status-dot.offline {
            background: linear-gradient(135deg, #94a3b8 0%, #64748b 100%);
        }
        
        .status-dot.away {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        }
        
        /* 참여자 목록 영역 - 깔끔한 스타일 */
        .participants-list {
            flex: 1;
            overflow-y: auto;
            padding: 24px;
            min-height: 0;
            background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
        }
        
        .participant-item {
            padding: 20px;
            border-radius: 16px;
            margin-bottom: 16px;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border: 1px solid rgba(226, 232, 240, 0.6);
            display: flex;
            align-items: center;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            animation: fadeInUp 0.3s ease-out;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .participant-item:hover {
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.12);
            border-color: #cbd5e1;
            transform: translateY(-3px);
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        }
        
        .participant-avatar {
            width: 48px;
            height: 48px;
            border-radius: 16px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 20px;
            margin-right: 18px;
            flex-shrink: 0;
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.25);
            border: 2px solid rgba(255, 255, 255, 0.3);
            position: relative;
        }
        
        .participant-avatar::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(255,255,255,0.2) 0%, transparent 100%);
            border-radius: 14px;
            pointer-events: none;
        }
        
        .participant-info {
            flex: 1;
            min-width: 0;
        }
        
        .participant-name {
            font-size: 16px;
            font-weight: 700;
            color: #1e293b;
            margin: 0 0 4px 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .participant-id {
            font-size: 13px;
            color: #64748b;
            margin: 0;
            font-weight: 500;
            background: rgba(100, 116, 139, 0.1);
            padding: 4px 8px;
            border-radius: 8px;
            display: inline-block;
            backdrop-filter: blur(5px);
        }
        
        .admin-badge {
            flex-shrink: 0;
            margin-left: 12px;
        }
        
        .admin-badge .badge {
            font-size: 12px;
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 600;
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3);
        }
        
        /* 관리자 액션 */
        .participant-actions {
            margin-left: 12px;
        }
        
        .action-btn {
            padding: 8px 16px;
            border: 2px solid #ef4444;
            border-radius: 20px;
            background: linear-gradient(135deg, #ffffff 0%, #fef2f2 100%);
            color: #ef4444;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.15);
        }
        
        .action-btn:hover {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(239, 68, 68, 0.3);
        }
        
        /* 온라인 상태 표시 */
        .participant-item[data-status="online"] .participant-avatar::after {
            content: '';
            position: absolute;
            bottom: -2px;
            right: -2px;
            width: 16px;
            height: 16px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border-radius: 50%;
            border: 3px solid #ffffff;
            box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
        }
        
        .participant-item[data-status="away"] .participant-avatar::after {
            content: '';
            position: absolute;
            bottom: -2px;
            right: -2px;
            width: 16px;
            height: 16px;
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            border-radius: 50%;
            border: 3px solid #ffffff;
            box-shadow: 0 2px 8px rgba(245, 158, 11, 0.3);
        }
        
        .participant-item[data-status="offline"] .participant-avatar::after {
            content: '';
            position: absolute;
            bottom: -2px;
            right: -2px;
            width: 16px;
            height: 16px;
            background: linear-gradient(135deg, #94a3b8 0%, #64748b 100%);
            border-radius: 50%;
            border: 3px solid #ffffff;
            box-shadow: 0 2px 8px rgba(148, 163, 184, 0.3);
        }
        
        /* 빈 상태 */
        .empty-state {
            text-align: center;
            padding: 80px 40px;
            color: #64748b;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border-radius: 20px;
            margin: 40px 20px;
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.08);
            border: 1px solid rgba(226, 232, 240, 0.6);
            backdrop-filter: blur(10px);
        }
        
        .empty-state i {
            font-size: 64px;
            margin-bottom: 24px;
            color: #667eea;
            opacity: 0.4;
        }
        
        .empty-state h5 {
            margin-bottom: 12px;
            color: #1e293b;
            font-size: 20px;
            font-weight: 700;
        }
        
        .empty-state p {
            margin: 0;
            font-size: 15px;
            color: #64748b;
            font-weight: 500;
        }
        
        /* 스크롤바 스타일 */
        .participants-list::-webkit-scrollbar {
            width: 8px;
        }
        
        .participants-list::-webkit-scrollbar-track {
            background: rgba(241, 245, 249, 0.5);
            border-radius: 4px;
        }
        
        .participants-list::-webkit-scrollbar-thumb {
            background: linear-gradient(135deg, #cbd5e1 0%, #94a3b8 100%);
            border-radius: 4px;
        }
        
        .participants-list::-webkit-scrollbar-thumb:hover {
            background: linear-gradient(135deg, #94a3b8 0%, #64748b 100%);
        }
        
        /* 반응형 */
        @media (max-width: 768px) {
            .participants-header {
                padding: 16px 20px;
            }
            
            .participants-list {
                padding: 16px;
            }
            
            .participant-item {
                padding: 16px;
                margin-bottom: 12px;
            }
            
            .participant-avatar {
                width: 40px;
                height: 40px;
                font-size: 16px;
            }
            
            .status-buttons {
                gap: 8px;
            }
            
            .status-btn {
                padding: 8px 14px;
                font-size: 12px;
                min-width: 70px;
            }
            
            .empty-state {
                padding: 60px 20px;
                margin: 20px 10px;
            }
            
            .empty-state i {
                font-size: 48px;
            }
        }
        
        /* 필터 애니메이션 */
        .participant-item.filtered-out {
            opacity: 0;
            transform: translateY(-10px);
            pointer-events: none;
            margin-bottom: 0;
            padding: 0;
            height: 0;
            overflow: hidden;
        }
        
        .participant-item.filtered-in {
            opacity: 1;
            transform: translateY(0);
            pointer-events: auto;
        }
    </style>
</head>
<body>
    <div class="participants-container">
        <!-- 헤더 영역 -->
        <div class="participants-header d-flex justify-content-between align-items-center">
            <div class="participants-title d-flex align-items-center">
                <i class="fas fa-users"></i>
                참여자 목록
            </div>
            <div class="participants-count" id="participantCount">
                <i class="fas fa-user-friends"></i>
                ${participantCount}명
            </div>
        </div>
        
        <!-- 상태 필터 영역 -->
        <div class="status-filter">
            <div class="status-filter-label">상태별 필터</div>
            <div class="status-buttons">
                <button class="status-btn active" data-status="all">
                    <i class="fas fa-users"></i>
                    전체
                </button>
                <button class="status-btn" data-status="online">
                    <span class="status-dot online"></span>
                    온라인
                </button>
                <button class="status-btn" data-status="offline">
                    <span class="status-dot offline"></span>
                    오프라인
                </button>
                <button class="status-btn" data-status="away">
                    <span class="status-dot away"></span>
                    자리비움
                </button>
            </div>
        </div>
        
        <!-- 참여자 목록 영역 -->
        <div class="participants-list" id="participantsList">
            <c:choose>
                <c:when test="${empty participants}">
                    <div class="empty-state">
                        <i class="fas fa-user-friends"></i>
                        <h5>참여자가 없습니다</h5>
                        <p>아직 채팅방에 참여한 사람이 없습니다.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach items="${participants}" var="participant" varStatus="status">
                        <div class="participant-item filtered-in" data-user-id="${participant.userId}" data-status="${participant.isOnline ? 'online' : 'offline'}">
                            <div class="participant-avatar">
                                <c:choose>
                                    <c:when test="${not empty participant.nickname}">
                                        ${participant.nickname.substring(0,1)}
                                    </c:when>
                                    <c:otherwise>
                                        U
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="participant-info">
                                <p class="participant-name">
                                    <c:choose>
                                        <c:when test="${not empty participant.nickname}">
                                            ${participant.nickname}
                                        </c:when>
                                        <c:otherwise>
                                            사용자${participant.userId}
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                                <p class="participant-id">
                                    ID: ${participant.userId}<c:if test="${not empty participant.studentId}"> (${participant.studentId})</c:if>
                                </p>
                            </div>
                            <c:if test="${participant.isAdmin}">
                                <div class="admin-badge">
                                    <span class="badge">관리자</span>
                                </div>
                            </c:if>
                            <c:if test="${isRoomAdmin && participant.userId != currentUserId}">
                                <div class="participant-actions">
                                    <button class="action-btn" onclick="removeParticipant('${participant.userId}')">
                                        강퇴
                                    </button>
                                </div>
                            </c:if>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <script>
        // 상태 필터 기능
        document.querySelectorAll('.status-btn').forEach(button => {
            button.addEventListener('click', function() {
                const status = this.dataset.status;
                
                // 활성 상태 토글
                document.querySelectorAll('.status-btn').forEach(btn => btn.classList.remove('active'));
                this.classList.add('active');
                
                // 참여자 필터링
                filterParticipants(status);
            });
        });
        
        function filterParticipants(status) {
            const participants = document.querySelectorAll('.participant-item');
            let visibleCount = 0;
            
            participants.forEach(participant => {
                const participantStatus = participant.dataset.status;
                
                if (status === 'all' || participantStatus === status) {
                    participant.classList.remove('filtered-out');
                    participant.classList.add('filtered-in');
                    visibleCount++;
                } else {
                    participant.classList.remove('filtered-in');
                    participant.classList.add('filtered-out');
                }
            });
            
            // 참여자 수 업데이트
            updateParticipantCount(visibleCount);
        }
        
        function updateParticipantCount(count) {
            const countElement = document.getElementById('participantCount');
            countElement.innerHTML = '<i class="fas fa-user-friends"></i>' + count + '명';
        }
        
        // 참여자 강퇴 기능
        function removeParticipant(userId) {
            if (confirm('정말로 이 참여자를 강퇴하시겠습니까?')) {
                // 여기에 강퇴 로직 구현
                console.log('참여자 강퇴:', userId);
                // Ajax 요청을 통해 서버에 강퇴 요청
                // 성공 시 해당 참여자 요소 제거
            }
        }
        
        // 페이지 로드 시 애니메이션 적용
        document.addEventListener('DOMContentLoaded', function() {
            const participants = document.querySelectorAll('.participant-item');
            participants.forEach((participant, index) => {
                participant.style.animationDelay = (index * 0.1) + 's';
            });
        });
    </script>
</body>
</html> 