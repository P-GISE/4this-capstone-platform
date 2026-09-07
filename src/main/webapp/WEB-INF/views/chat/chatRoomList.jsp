<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<body>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/boxicons@2.0.7/css/boxicons.min.css" rel="stylesheet">
    <!-- FontAwesome CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700&display=swap');

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
        
        .main-content {
            padding: 0;
            flex: 1;
            min-height: 0;
            display: flex;
            flex-direction: column;
            margin-top: 60px;
        }
        
        .chat-page-container {
            flex: 1;
            min-height: 0;
            overflow: hidden;
            margin: 16px;
            border-radius: 20px;
            background: #ffffff;
            box-shadow: 0 32px 64px -12px rgba(0, 0, 0, 0.15);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        
        .chat-container {
            height: 100%;
            display: flex;
        }
        
        
        .search-section {
            padding: 24px 28px;
            border-bottom: 1px solid rgba(226, 232, 240, 0.8);
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
        }
        
        .search-box {
            position: relative;
        }
        
        .search-box input {
            width: 100%;
            padding: 16px 50px 16px 20px;
            border: 2px solid #e2e8f0;
            border-radius: 16px;
            font-size: 15px;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            font-family: 'Pretendard', sans-serif;
        }
        
        .search-box input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.15);
            background: #ffffff;
            outline: none;
        }
        
        .search-box input::placeholder {
            color: #94a3b8;
            font-weight: 500;
        }
        
        .search-icon {
            position: absolute;
            right: 18px;
            top: 50%;
            transform: translateY(-50%);
            color: #64748b;
            font-size: 18px;
            pointer-events: none;
        }
        
        .room-list {
            flex: 1;
            overflow-y: auto;
            padding: 16px;
            min-height: 0;
        }
        
        .room-list h6 {
            color: #1e293b;
            font-weight: 700;
            font-size: 16px;
            margin-bottom: 20px;
            padding: 0 12px;
            display: flex;
            align-items: center;
        }
        
        .room-list h6::before {
            content: '';
            width: 4px;
            height: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 2px;
            margin-right: 12px;
        }
        
        .room-item {
            padding: 20px;
            border-bottom: none;
            cursor: pointer;
            transition: all 0.3s ease;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            display: block;
            text-decoration: none;
            color: inherit;
            margin-bottom: 12px;
            border-radius: 16px;
            border: 1px solid rgba(226, 232, 240, 0.6);
            backdrop-filter: blur(10px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }
        
        .room-item:hover {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            text-decoration: none;
            color: inherit;
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            border-color: #cbd5e1;
        }
        
        .room-item.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-color: transparent;
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
        }
        
        .room-item.active .room-name,
        .room-item.active .room-description,
        .room-item.active .room-info,
        .room-item.active .participant-count {
            color: white !important;
        }
        
        .room-item-content {
            display: flex;
            align-items: start;
        }
        
        .room-avatar {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            margin-right: 16px;
            flex-shrink: 0;
            font-size: 18px;
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.25);
        }
        
        .room-item.active .room-avatar {
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
            border: 2px solid rgba(255, 255, 255, 0.3);
        }
        
        .room-details {
            flex: 1;
            min-width: 0;
        }
        
        .room-name {
            font-weight: 700;
            margin-bottom: 6px;
            font-size: 16px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            color: #1e293b;
        }
        
        .room-description {
            font-size: 14px;
            color: #64748b;
            margin-bottom: 8px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            font-weight: 500;
        }
        
        .room-info {
            font-size: 12px;
            color: #64748b;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-weight: 500;
        }
        
        .room-info i {
            margin-right: 6px;
            color: #667eea;
        }
        
        .room-item.active .room-info i {
            color: rgba(255, 255, 255, 0.8);
        }
        
        .room-meta {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            flex-shrink: 0;
            gap: 8px;
        }
        
        .participant-count {
            font-size: 12px;
            color: #64748b;
            font-weight: 600;
            background: rgba(100, 116, 139, 0.1);
            padding: 4px 10px;
            border-radius: 12px;
            backdrop-filter: blur(5px);
        }
        
        .room-item.active .participant-count {
            background: rgba(255, 255, 255, 0.2);
            color: white;
        }
        
        /* 읽지 않은 메시지 배지 */
        .unread-badge {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            color: white;
            border-radius: 20px;
            padding: 6px 10px;
            font-size: 11px;
            font-weight: 700;
            min-width: 22px;
            height: 22px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }
        
        .room-item.has-unread {
            border-left: 4px solid #ef4444;
            background: linear-gradient(135deg, #fef2f2 0%, #fecaca 100%);
        }
        
        .room-item.has-unread .room-name {
            font-weight: 800;
            color: #1e293b;
        }
        
        /* 오른쪽 채팅방 영역 */
        .chat-main {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            height: 100%;
            min-width: 0;
        }
        
        .chat-welcome {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: #64748b;
            text-align: center;
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        }
        
        .chat-welcome div {
            padding: 60px 40px;
            border-radius: 20px;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.08);
            border: 1px solid rgba(226, 232, 240, 0.6);
            backdrop-filter: blur(10px);
        }
        
        .chat-welcome i {
            font-size: 4rem;
            margin-bottom: 24px;
            color: #667eea;
            opacity: 0.6;
        }
        
        .chat-welcome h5 {
            color: #1e293b;
            font-weight: 700;
            margin-bottom: 12px;
            font-size: 24px;
        }
        
        .chat-welcome p {
            color: #64748b;
            font-size: 16px;
            font-weight: 500;
            margin: 0;
        }
        
        /* 채팅방 iframe 스타일 */
        .chat-frame {
            width: 100%;
            height: 100%;
            border: none;
            border-radius: 0 20px 20px 0;
        }
        
        .chat-message-list {
            flex: 1;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }
        
        .chat-message-list::-webkit-scrollbar {
            width: 8px;
        }
        
        .chat-message-list::-webkit-scrollbar-track {
            background: rgba(241, 245, 249, 0.5);
            border-radius: 4px;
        }
        
        .chat-message-list::-webkit-scrollbar-thumb {
            background: linear-gradient(135deg, #cbd5e1 0%, #94a3b8 100%);
            border-radius: 4px;
        }
        
        .chat-message-list::-webkit-scrollbar-thumb:hover {
            background: linear-gradient(135deg, #94a3b8 0%, #64748b 100%);
        }
        
        /* 페이지 타이틀 */
        .page-title-box {
            padding: 20px 0;
            margin-bottom: 0;
        }
        
        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .chat-sidebar {
                width: 100%;
                min-width: 100%;
            }
            
            .chat-main {
                display: none;
            }
            
            .search-section {
                padding: 16px 20px;
            }
            
            .room-item {
                padding: 16px;
                margin-bottom: 8px;
            }
            
            .room-avatar {
                width: 40px;
                height: 40px;
                font-size: 16px;
            }
        }
    </style>

    <!-- 1) 사이드바 -->
    <div class="sidebar">
        <%@ include file="../layout/sidebar.jsp" %>
    </div>

    <!-- 2) 메인 콘텐츠 -->
    <div class="content">
        <!-- 2-1) 헤더 -->
        <%@ include file="../layout/header.jsp" %>

        <!-- 2-2) 실제 페이지 내용 -->
        <div class="main-content">
            <!-- Page Title -->
            <div class="container-fluid">
                <div class="row">

                </div>
            </div>
            
            <div class="chat-page-container">
                <div class="chat-container">
                    <!-- 왼쪽 채팅방 목록 사이드바 -->
                    <div class="chat-sidebar">
                        <!-- 검색 섹션 -->
                        <div class="search-section">
                            <div class="search-box">
                                <input type="text" class="form-control" placeholder="채팅방 검색...">
                                <i class="bx bx-search search-icon"></i>
                            </div>
                        </div>
                        
                        <!-- 채팅방 목록 -->
                        <div class="chat-message-list">
                            <div class="px-3 py-2">
                                <h6 class="font-size-14 mb-3">내 채팅</h6>
                            </div>
                            <div class="room-list">
                                <!-- 디버깅 정보 추가 -->
                                <c:if test="${empty rooms}">
                                    <div style="padding: 20px; text-align: center; color: #64748b;">
                                        <div style="background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%); 
                                                    padding: 40px 20px; 
                                                    border-radius: 16px; 
                                                    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08); 
                                                    border: 1px solid rgba(226, 232, 240, 0.6); 
                                                    margin: 20px;">
                                            <i class="fas fa-comments" style="font-size: 48px; color: #667eea; opacity: 0.5; margin-bottom: 20px;"></i>
                                            <h5 style="color: #1e293b; font-weight: 700; margin-bottom: 12px;">채팅방이 없습니다</h5>
                                            <p style="color: #64748b; font-size: 14px; margin-bottom: 20px;">
                                                아직 참여할 수 있는 채팅방이 없습니다.<br>
                                                프로젝트에 참여하거나 새로운 채팅방을 생성해보세요.
                                            </p>
                                            <div style="margin-top: 20px;">
                                                <button onclick="createTestChatRoom()" 
                                                        style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                                                               color: white; 
                                                               border: none; 
                                                               padding: 12px 24px; 
                                                               border-radius: 12px; 
                                                               font-weight: 600; 
                                                               cursor: pointer; 
                                                               transition: all 0.3s ease;
                                                               box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);">
                                                    <i class="fas fa-plus"></i> 테스트 채팅방 생성
                                                </button>
                                            </div>
                                            <!-- 디버깅 정보 -->
                                            <div style="margin-top: 20px; padding: 15px; background: #f8f9fa; border-radius: 8px; font-size: 12px; color: #6c757d;">
                                                <strong>디버깅 정보:</strong><br>
                                                현재 사용자: ${user.name} (${user.role})<br>
                                                사용자 ID: ${user.id}<br>
                                                채팅방 개수: ${fn:length(rooms)}
                                            </div>
                                        </div>
                                    </div>
                                </c:if>
                                
                                <c:forEach items="${rooms}" var="room">
                                    <div class="room-item" onclick="selectChatRoom('${room.roomId}', '${room.name}', this)" data-room-id="${room.roomId}">
                                        <div class="room-item-content">
                                            <div class="room-avatar">
                                                ${room.name.substring(0,1)}
                                            </div>
                                            <div class="room-details">
                                                <div class="room-name">
                                                    ${room.name}
                                                </div>
                                                <div class="room-description">${room.description}</div>
                                                <div class="room-info">
                                                    <span>
                                                        <c:if test="${room.isPrivate}">
                                                            <i class="fas fa-lock"></i> 비공개
                                                        </c:if>
                                                        <c:if test="${!room.isPrivate}">
                                                            <i class="fas fa-globe"></i> 공개
                                                        </c:if>
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="room-meta">
                                                <div class="participant-count">${room.participantCount}명</div>
                                                <span class="unread-badge" id="unread-${room.roomId}" style="display: none;">0</span>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>

                    </div>
                    
                    <!-- 오른쪽 채팅방 영역 -->
                    <div class="chat-main">
                        <div class="chat-welcome" id="chatWelcome">
                            <div>
                                <i class="fas fa-comments"></i>
                                <h5>채팅방을 선택해주세요</h5>
                                <p>왼쪽 목록에서 채팅방을 클릭하면 채팅을 시작할 수 있습니다.</p>
                            </div>
                        </div>
                        
                        <iframe id="chatFrame" class="chat-frame" style="display: none;"></iframe>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentRoomId = null;
        
        // 페이지 로드 시 읽지 않은 메시지 개수 로드
        $(document).ready(function() {
            loadUnreadCounts();
            
            // 5초마다 읽지 않은 메시지 개수 업데이트
            setInterval(loadUnreadCounts, 5000);
            
            // URL 파라미터로 특정 채팅방 열기 (예: /chat?openRoom=34)
            const urlParams = new URLSearchParams(window.location.search);
            const openRoom = urlParams.get('openRoom');
            if (openRoom) {
                // URL에서 파라미터 제거
                const newUrl = window.location.pathname;
                window.history.replaceState({}, document.title, newUrl);
                
                // 해당 채팅방 열기
                setTimeout(function() {
                    showChatRoom(openRoom);
                }, 500);
            }
        });
        
        // 읽지 않은 메시지 개수 로드
        function loadUnreadCounts() {
            $('.room-item').each(function() {
                const roomId = $(this).data('room-id');
                if (roomId) {
                    loadUnreadCount(roomId);
                }
            });
        }
        
        // 특정 채팅방의 읽지 않은 메시지 개수 로드
        function loadUnreadCount(roomId) {
            $.get('/chat/room/' + roomId + '/unread-count')
                .done(function(response) {
                    if (response.success) {
                        updateUnreadBadge(roomId, response.unreadCount);
                    }
                })
                .fail(function() {
                    console.error('읽지 않은 메시지 개수 로드 실패:', roomId);
                });
        }
        
        // 읽지 않은 메시지 배지 업데이트
        function updateUnreadBadge(roomId, unreadCount) {
            const badge = $('#unread-' + roomId);
            const roomItem = $('[data-room-id="' + roomId + '"]');
            
            if (unreadCount > 0) {
                badge.text(unreadCount > 99 ? '99+' : unreadCount);
                badge.show();
                roomItem.addClass('has-unread');
            } else {
                badge.hide();
                roomItem.removeClass('has-unread');
            }
        }
        
        function createChatRoom() {
            window.open('/chat/load/chatRoomCreate', '_blank', 'width=600,height=500');
        }
        
        function selectChatRoom(roomId, roomName, element) {
            // 이전 선택 해제
            document.querySelectorAll('.room-item').forEach(item => {
                item.classList.remove('active');
            });
            
            // 현재 선택 활성화
            element.classList.add('active');
            
            // 환영 메시지 숨기기
            document.getElementById('chatWelcome').style.display = 'none';
            
            // 채팅방 iframe 표시 및 로드
            const iframe = document.getElementById('chatFrame');
            iframe.style.display = 'block';
            iframe.src = '/chat/room/' + roomId;
            
            currentRoomId = roomId;
            
            // 채팅방 입장 시 읽지 않은 메시지 개수 초기화
            setTimeout(function() {
                markAllMessagesAsRead(roomId);
            }, 1000);
        }
        
        // 채팅방의 모든 메시지를 읽음으로 표시
        function markAllMessagesAsRead(roomId) {
            $.post('/chat/room/' + roomId + '/mark-all-read')
                .done(function(response) {
                    if (response.success) {
                        updateUnreadBadge(roomId, 0);
                        console.log('모든 메시지를 읽음으로 표시했습니다.');
                    }
                })
                .fail(function() {
                    console.error('읽음 처리 실패:', roomId);
                });
        }
        
        // 새 채팅방이 생성된 후 목록 새로고침
        function refreshRoomList() {
            location.reload();
        }
        
        // 팝업에서 새 채팅방 생성 완료 시 호출될 함수
        window.addEventListener('message', function(event) {
            console.log('메시지 수신:', event.data);
            
            if (event.data === 'chatRoomCreated') {
                refreshRoomList();
            } else if (event.data && event.data.type === 'CHAT_BACK_TO_LIST') {
                // iframe에서 채팅방 목록으로 돌아가기 요청
                console.log('채팅방에서 목록으로 돌아가기 요청 수신');
                
                const chatFrame = document.getElementById('chatFrame');
                const chatWelcome = document.getElementById('chatWelcome');
                
                if (chatFrame && chatWelcome) {
                    // iframe 숨기고 환영 메시지 표시
                    chatFrame.style.display = 'none';
                    chatWelcome.style.display = 'flex';
                    
                    // 활성화된 채팅방 선택 해제
                    document.querySelectorAll('.room-item.active').forEach(item => {
                        item.classList.remove('active');
                    });
                    
                    // 현재 룸 ID 초기화
                    currentRoomId = null;
                    
                    console.log('채팅방 목록으로 돌아가기 완료');
                } else {
                    console.error('chatFrame 또는 chatWelcome 요소를 찾을 수 없음');
                }
            } else if (event.data && event.data.type === 'CHAT_ROOM_DELETED') {
                // iframe에서 채팅방 삭제 완료 알림
                console.log('채팅방 삭제 완료:', event.data.roomId);
                removeChatRoomFromList(event.data.roomId);
            }
        });
        
        // 전역 함수: 특정 채팅방 열기 (헤더에서 호출 가능)
        window.showChatRoom = function(roomId) {
            // 해당 룸 아이템 찾기
            const roomItem = document.querySelector('[data-room-id="' + roomId + '"]');
            if (roomItem) {
                // 채팅방 선택 함수 호출
                roomItem.click();
            } else {
                console.warn('채팅방을 찾을 수 없습니다:', roomId);
                // 채팅방이 목록에 없는 경우 직접 iframe으로 열기
                document.getElementById('chatWelcome').style.display = 'none';
                const iframe = document.getElementById('chatFrame');
                iframe.style.display = 'block';
                iframe.src = '/chat/room/' + roomId;
                currentRoomId = roomId;
            }
        };
        
        // 전역 함수: 채팅방을 목록에서 제거 (삭제 후 호출)
        window.removeChatRoomFromList = function(roomId) {
            const roomItem = document.querySelector('[data-room-id="' + roomId + '"]');
            if (roomItem) {
                // 삭제되는 채팅방이 현재 선택된 방인 경우
                if (currentRoomId == roomId) {
                    // iframe 숨기고 환영 메시지 표시
                    document.getElementById('chatFrame').style.display = 'none';
                    document.getElementById('chatWelcome').style.display = 'flex';
                    currentRoomId = null;
                }
                
                // 채팅방 항목을 목록에서 제거
                roomItem.remove();
                console.log('채팅방이 목록에서 제거되었습니다:', roomId);
            }
        };
        
        // 테스트 채팅방 생성 함수
        function createTestChatRoom() {
            const button = event.target;
            const originalText = button.innerHTML;
            
            // 버튼 비활성화 및 로딩 표시
            button.disabled = true;
            button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 생성 중...';
            
            // 테스트 프로젝트 및 채팅방 자동 생성 요청
            $.post('/chat/auto-create-main-room')
                .done(function(response) {
                    console.log('테스트 채팅방 생성 응답:', response);
                    
                    if (response.success) {
                        alert('테스트 채팅방이 생성되었습니다!');
                        // 페이지 새로고침하여 새로운 채팅방 표시
                        location.reload();
                    } else {
                        alert('채팅방 생성에 실패했습니다: ' + (response.message || '알 수 없는 오류'));
                        button.disabled = false;
                        button.innerHTML = originalText;
                    }
                })
                .fail(function(xhr, status, error) {
                    console.error('테스트 채팅방 생성 실패:', error);
                    alert('채팅방 생성 중 오류가 발생했습니다.');
                    button.disabled = false;
                    button.innerHTML = originalText;
                });
        }
    </script>
</body>
</html> 