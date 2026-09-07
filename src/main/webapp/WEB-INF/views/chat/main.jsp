<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>팀 커뮤니케이션</title>
    <style>
        .chat-container {
            display: flex;
            min-height: 600px;
            margin: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
            overflow: hidden;
        }

        .chat-rooms {
            width: 300px;
            border-right: 1px solid #ddd;
            background-color: #f5f5f5;
        }

        .rooms-header {
            padding: 15px;
            border-bottom: 1px solid #ddd;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .create-room-btn {
            padding: 8px 15px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        .create-room-btn:hover {
            background-color: #0056b3;
        }

        .rooms-list {
            height: calc(100% - 60px);
            overflow-y: auto;
        }

        .chat-messages {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .messages-header {
            padding: 15px;
            border-bottom: 1px solid #ddd;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .room-actions button {
            padding: 5px 10px;
            background-color: #f8f9fa;
            border: 1px solid #ddd;
            border-radius: 4px;
            cursor: pointer;
        }

        .messages-content {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background-color: white;
        }

        .message-input {
            padding: 15px;
            border-top: 1px solid #ddd;
            display: flex;
            gap: 10px;
        }

        .message-input textarea {
            flex: 1;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            resize: none;
            height: 40px;
        }

        .send-btn {
            padding: 0 20px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        .send-btn:hover {
            background-color: #0056b3;
        }

        /* 채팅방 스타일 */
        .room-item {
            padding: 15px;
            border-bottom: 1px solid #eee;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .room-item:hover {
            background-color: #f8f9fa;
        }

        .room-name {
            font-weight: 500;
            margin-bottom: 5px;
        }

        .room-info {
            font-size: 0.9em;
            color: #666;
        }

        .room-item.active {
            background-color: #e3f2fd;
        }

        /* 메시지 스타일 */
        .message {
            margin-bottom: 15px;
            display: flex;
            flex-direction: column;
        }

        .message-header {
            display: flex;
            align-items: center;
            margin-bottom: 5px;
        }

        .message-sender {
            font-weight: bold;
            margin-right: 10px;
        }

        .message-time {
            color: #6c757d;
            font-size: 0.8em;
        }

        .message-content {
            padding: 10px;
            background-color: #f8f9fa;
            border-radius: 8px;
            max-width: 70%;
        }

        .message.own {
            align-items: flex-end;
        }

        .message.own .message-content {
            background-color: #007bff;
            color: white;
        }
    </style>
</head>
<body>
    <div class="chat-container">
        <div class="chat-rooms">
            <div class="rooms-header">
                <span>채팅방 목록</span>
                <button class="create-room-btn">새 채팅방 만들기</button>
            </div>
            <div id="chatRoomList" class="rooms-list">
                <!-- 채팅방 목록이 JavaScript로 동적으로 로드됩니다 -->
                <div style="padding: 20px; color: #666;">채팅방을 불러오는 중...</div>
            </div>

        </div>
        <div class="chat-messages">
            <div id="chatContent">
                <!-- 선택된 채팅방의 내용이 여기에 로드됩니다 -->
            </div>
        </div>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.0/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const createRoomBtn = document.querySelector('.create-room-btn');
            const chatContent = document.getElementById('chatContent');
            let stompClient = null;
            let currentRoomId = null;
            const currentUser = {
                id: "${user.id != null ? user.id : ''}",
                name: "${user.name != null ? user.name : ''}"
            };

            if (createRoomBtn) {
                createRoomBtn.addEventListener('click', function() {
                    chatContent.innerHTML = '';
                    loadJSP('chatRoomCreate', chatContent);
                });
            }

            // JSP 로드 함수
            function loadJSP(jspName, targetElement, params = {}) {
                if (!jspName) {
                    console.error('jspName이 비어 있습니다!');
                    return;
                }
                const queryString = new URLSearchParams(params).toString();
                const url = '/chat/load/' + jspName + (queryString ? '?' + queryString : '');
                fetch(url)
                    .then(response => response.text())
                    .then(html => {
                        targetElement.innerHTML = html;

                        // 동적으로 삽입된 <script> 실행
                        const scripts = targetElement.querySelectorAll('script');
                        scripts.forEach(oldScript => {
                            const newScript = document.createElement('script');
                            if (oldScript.src) {
                                newScript.src = oldScript.src;
                            } else {
                                newScript.textContent = oldScript.textContent;
                            }
                            document.body.appendChild(newScript);
                            document.body.removeChild(newScript);
                        });
                    });
            }

            // 채팅방 목록 불러오기 함수
            function loadChatRooms() {
                fetch('/chat/rooms')
                    .then(response => {
                        console.log('Response status:', response.status);
                        return response.json();
                    })
                    .then(rooms => {
                        console.log('받은 채팅방 데이터:', rooms);
                        console.log('첫 번째 채팅방:', rooms[0]);
                        const roomList = document.getElementById('chatRoomList');
                        roomList.innerHTML = '';
                        
                        if (!rooms || rooms.length === 0) {
                            roomList.innerHTML = '<div style="padding: 20px;">채팅방이 없습니다.</div>';
                            return;
                        }
                        
                        rooms.forEach((room, index) => {
                            console.log('채팅방 ' + index + ':', room);
                            console.log('- name: "' + room.name + '" (타입: ' + typeof room.name + ')');
                            console.log('- description: "' + room.description + '" (타입: ' + typeof room.description + ')');
                            console.log('- roomId: ' + room.roomId + ', id: ' + room.id);
                            
                            const roomDiv = document.createElement('div');
                            roomDiv.className = 'room-item';
                            roomDiv.style.cssText = 'padding: 15px; border-bottom: 1px solid #eee; cursor: pointer; background: white; margin-bottom: 5px;';
                            
                            // 더 강력한 값 처리
                            let roomName = '이름 없음';
                            let roomDescription = '';
                            let roomId = null;
                            
                            // name 필드 처리
                            if (room.name !== null && room.name !== undefined && room.name !== 'false') {
                                roomName = String(room.name);
                            }
                            
                            // description 필드 처리  
                            if (room.description !== null && room.description !== undefined && room.description !== 'false') {
                                roomDescription = String(room.description);
                            }
                            
                            // roomId 처리
                            roomId = room.roomId || room.id;
                            
                            console.log('최종 처리된 값들 - name: "' + roomName + '", description: "' + roomDescription + '", roomId: ' + roomId);
                            
                            // 강력한 안전 처리
                            const displayName = (room.name && String(room.name).trim() !== '' && String(room.name) !== 'null' && String(room.name) !== 'undefined') 
                                ? String(room.name) : '채팅방 ' + roomId;
                            const displayDescription = (room.description && String(room.description).trim() !== '' && String(room.description) !== 'null' && String(room.description) !== 'undefined') 
                                ? String(room.description) : '';
                            
                            roomDiv.innerHTML = 
                                '<div style="font-weight: bold; font-size: 16px; margin-bottom: 5px;">' + displayName + '</div>' +
                                '<div style="color: #666; font-size: 14px; margin-bottom: 5px;">' + displayDescription + '</div>' +
                                '<div style="font-size: 12px; color: #888;">ID: ' + roomId + ' | 참가자: ' + (room.participantCount || 0) + '명</div>';
                            
                            // 클릭 이벤트 직접 처리
                            roomDiv.onclick = function(e) {
                                e.preventDefault();
                                console.log('클릭된 채팅방:', room);
                                console.log('채팅방 ID:', roomId);
                                if (roomId) {
                                    const url = '/chat/room/' + roomId;
                                    console.log('이동할 URL:', url);
                                    window.location.href = url;
                                } else {
                                    alert('채팅방 ID가 없습니다');
                                }
                            };
                            
                            roomList.appendChild(roomDiv);
                        });
                    })
                    .catch(error => {
                        console.error('채팅방 목록을 불러오는데 실패했습니다:', error);
                        alert('채팅방 목록을 불러오는데 실패했습니다: ' + error.message);
                    });
            }

            // WebSocket 연결
            function connect() {
                const socket = new SockJS('/ws');
                stompClient = Stomp.over(socket);
                stompClient.debug = null;
                const headers = {
                    'user-id': currentUser.id,
                    'user-name': currentUser.name
                };
                stompClient.connect(headers, onConnected, onError);
            }
            function onConnected() { console.log('WebSocket 연결됨'); }
            function onError(error) {
                console.error('WebSocket 연결 실패:', error);
                setTimeout(connect, 3000);
            }
            connect();

            // 채팅방 목록 최초 로드
            loadChatRooms();
        });
    </script>
    <span id="currentTime"><%= new SimpleDateFormat("HH:mm:ss").format(new Date()) %></span>
    <script>
        function updateTime() {
            const now = new Date();
            const timeString = now.getHours().toString().padStart(2, '0') + ':' +
                             now.getMinutes().toString().padStart(2, '0') + ':' +
                             now.getSeconds().toString().padStart(2, '0');
            document.getElementById('currentTime').innerText = timeString;
        }
        updateTime();
        setInterval(updateTime, 1000);
    </script>
</body>
</html> 