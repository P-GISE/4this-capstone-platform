<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

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
        <div class="main-body notification-page">
            <h2 class="section-title">알림 목록</h2>
            
            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>
            
            <div class="notification-container">
                <div class="notification-header">
                    <c:if test="${unreadCount > 0}">
                        <div class="unread-info">
                            <span class="unread-count">${unreadCount}개의 새 알림</span>
                            <button class="btn-mark-all" onclick="markAllAsRead()">모두 읽음</button>
                        </div>
                    </c:if>
                </div>
                
                <c:choose>
                    <c:when test="${empty notifications}">
                        <div class="empty-state">
                            <span class="empty-icon"></span>
                            <h3>알림이 없습니다</h3>
                            <p>새로운 알림이 도착하면 여기에 표시됩니다.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="notification-list">
                            <c:forEach items="${notifications}" var="notification">
                                <div class="notification-item ${notification.isRead ? '' : 'unread'}" 
                                     data-notification-id="${notification.id}" 
                                     data-notification-type="${notification.type}" 
                                     data-target-url="${notification.targetUrl}">
                                    <div class="notification-icon ${fn:toLowerCase(notification.type)}" data-type="${notification.type}">
                                        <span class="notification-emoji"></span>
                                    </div>
                                    <div class="notification-content">
                                        <div class="notification-title">${notification.title}</div>
                                        <div class="notification-message">${notification.message}</div>
                                        <div class="notification-time">
                                            ${notification.createdAt}
                                        </div>
                                    </div>
                                    <c:if test="${!notification.isRead}">
                                        <div class="notification-unread-dot"></div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- 2-3) 푸터 -->
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 3) 페이지 전용 CSS -->
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
        
        .notification-page .section-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 24px;
            color: #333;
        }
        
        .notification-page .notification-container {
            background: #ffffff;
            border-radius: 8px;
            padding: 24px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
        }
        
        .notification-page .notification-header {
            margin-bottom: 20px;
        }
        
        .notification-page .unread-info {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 16px;
            background-color: #e3f2fd;
            border-radius: 6px;
            border-left: 4px solid #2196f3;
        }
        
        .notification-page .unread-count {
            color: #1976d2;
            font-weight: 600;
        }
        
        .notification-page .btn-mark-all {
            background-color: #2196f3;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        
        .notification-page .btn-mark-all:hover {
            background-color: #1976d2;
        }
        
        .notification-page .notification-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        
        .notification-page .notification-item {
            display: flex;
            align-items: flex-start;
            padding: 16px;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            background-color: #fff;
            cursor: pointer;
            transition: all 0.2s ease;
            position: relative;
        }
        
        .notification-page .notification-item:hover {
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            transform: translateY(-1px);
        }
        
        .notification-page .notification-item.unread {
            background-color: #f8f9ff;
            border-left: 4px solid #2196f3;
        }
        
        .notification-page .notification-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 16px;
            flex-shrink: 0;
        }

        .notification-page .notification-emoji {
            font-size: 20px;
        }
        
        .notification-page .notification-icon.chat {
            background-color: #e3f2fd;
            color: #1976d2;
        }
        
        .notification-page .notification-icon.notice {
            background-color: #fff3e0;
            color: #f57c00;
        }
        
        .notification-page .notification-icon.inquiry {
            background-color: #e8f5e8;
            color: #388e3c;
        }
        
        .notification-page .notification-icon.equipment {
            background-color: #fce4ec;
            color: #c2185b;
        }


        
        .notification-page .notification-content {
            flex: 1;
        }
        
        .notification-page .notification-title {
            font-size: 16px;
            font-weight: 600;
            color: #333;
            margin-bottom: 4px;
        }
        
        .notification-page .notification-message {
            font-size: 14px;
            color: #666;
            margin-bottom: 8px;
            line-height: 1.4;
        }
        
        .notification-page .notification-time {
            font-size: 12px;
            color: #999;
        }
        
        .notification-page .notification-unread-dot {
            position: absolute;
            top: 16px;
            right: 16px;
            width: 8px;
            height: 8px;
            background-color: #2196f3;
            border-radius: 50%;
        }
        
        .notification-page .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #666;
        }
        
        .notification-page .empty-icon {
            font-size: 48px;
            margin-bottom: 16px;
            opacity: 0.5;
        }
        
        .notification-page .empty-state h3 {
            margin-bottom: 8px;
            color: #333;
        }
        
        .notification-page .alert {
            padding: 12px 16px;
            border-radius: 6px;
            margin-bottom: 20px;
        }
        
        .notification-page .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>

    <script>
        // 기존 JS 그대로 유지
        const NotificationListPage = {
            // 알림 타입별 이모티콘 반환 (헤더와 동일)
            getNotificationIcon: function(type) {
                switch(type) {
                    case 'CHAT': return '💬'; // 채팅 이모티콘
                    case 'NOTICE': return '📢'; // 공지사항 이모티콘
                    case 'INQUIRY': return '❓'; // 문의 이모티콘
                    case 'EQUIPMENT': return '🔧'; // 장비 이모티콘
                    default: return '🔔'; // 기본 알림 이모티콘
                }
            },
            // 아이콘 초기화
            initIcons: function() {
                // 알림 아이콘 설정
                document.querySelectorAll('.notification-icon[data-type]').forEach(function(iconEl) {
                    const type = iconEl.getAttribute('data-type');
                    const emojiEl = iconEl.querySelector('.notification-emoji');
                    if (emojiEl) {
                        emojiEl.textContent = NotificationListPage.getNotificationIcon(type);
                    }
                });
                
                // 빈 상태 아이콘 설정
                const emptyIcon = document.querySelector('.empty-icon');
                if (emptyIcon) {
                    emptyIcon.textContent = '🔕';
                }
            },
            getTimeAgo: function(dateString) {
                if (!dateString) return '알 수 없음';
                const now = new Date();
                let date;
                if (Array.isArray(dateString)) {
                    const [y, m, d, h, mi, s] = dateString;
                    date = new Date(y, m - 1, d, h || 0, mi || 0, s || 0);
                } else if (typeof dateString === 'string' && dateString.includes('T')) {
                    const clean = dateString.replace('T', ' ');
                    date = new Date(clean);
                } else {
                    date = new Date(dateString);
                }
                if (isNaN(date.getTime())) return '알 수 없음';
                const diff = Math.floor((now - date) / 1000);
                if (diff < 0) return '방금 전';
                if (diff < 60) return '방금 전';
                if (diff < 3600) return Math.floor(diff / 60) + '분 전';
                if (diff < 86400) return Math.floor(diff / 3600) + '시간 전';
                if (diff < 2592000) return Math.floor(diff / 86400) + '일 전';
                const months = Math.floor(diff / 2592000);
                if (months > 12) return Math.floor(months / 12) + '년 전';
                return months + '개월 전';
            },
            handleNotificationClick: function(id, type, url) {
                fetch('/notifications/' + id + '/read', { method: 'POST' }).then(function() {
                    // 채팅 알림의 경우 헤더와 동일한 처리
                    if (type === 'CHAT' && url) {
                        // url에서 roomId 추출 (예: /chat/room/34 -> 34)
                        const roomIdMatch = url.match(/\/chat\/room\/(\d+)/);
                        if (roomIdMatch) {
                            const roomId = roomIdMatch[1];
                            // 채팅 메인 페이지로 이동 후 특정 방 열기
                            window.location.href = '/chat?openRoom=' + roomId;
                            return;
                        }
                    }
                    
                    // 다른 타입의 알림 처리
                    if (url && url.trim() !== '') {
                        window.location.href = url;
                    } else {
                        switch(type) {
                            case 'CHAT': window.location.href = '/chat'; break;
                            case 'NOTICE': window.location.href = '/notice'; break;
                            case 'INQUIRY': window.location.href = '/inquiry'; break;
                            case 'EQUIPMENT': window.location.href = '/equipment'; break;
                            default: window.location.href = '/dashboard';
                        }
                    }
                });
            },
            markAllAsRead: function() {
                fetch('/notifications/mark-all-read', { method: 'POST' }).then(function() {
                    window.location.reload();
                });
            }
        };
        document.addEventListener('DOMContentLoaded', function() {
            // 아이콘 초기화
            NotificationListPage.initIcons();
            
            document.querySelectorAll('.notification-time').forEach(function(el) {
                const txt = el.textContent.trim();
                if (txt && txt !== '알 수 없음') {
                    el.textContent = NotificationListPage.getTimeAgo(txt);
                }
            });
            document.querySelectorAll('.notification-item[data-notification-id]').forEach(function(item) {
                item.addEventListener('click', function() {
                    var id = this.getAttribute('data-notification-id');
                    var type = this.getAttribute('data-notification-type');
                    var url = this.getAttribute('data-target-url');
                    NotificationListPage.handleNotificationClick(id, type, url);
                });
            });
        });
        function markAllAsRead() {
            NotificationListPage.markAllAsRead();
        }
    </script>
</body>
</html>
