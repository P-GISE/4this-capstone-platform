<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>채팅방 설정 - ${chatRoom.name}</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="card-title mb-0">채팅방 설정</h5>
                        <a href="/chat/room/${chatRoom.roomId}" class="btn btn-sm btn-outline-secondary">
                            <i class="fas fa-arrow-left"></i> 돌아가기
                        </a>
                    </div>
                    <div class="card-body">
                        <form id="chatRoomSettingsForm" onsubmit="updateChatRoom(event)">
                            <input type="hidden" name="roomId" value="${chatRoom.roomId}">
                            
                            <div class="form-group">
                                <label for="name">채팅방 이름</label>
                                <input type="text" class="form-control" id="name" name="name" 
                                       value="${chatRoom.name}" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="description">설명</label>
                                <textarea class="form-control" id="description" name="description" 
                                          rows="3">${chatRoom.description}</textarea>
                            </div>
                            
                            <div class="form-group">
                                <label for="maxParticipants">최대 참여자 수</label>
                                <input type="number" class="form-control" id="maxParticipants" name="maxParticipants" 
                                       value="${chatRoom.maxParticipants}" min="2" max="100">
                            </div>
                            
                            <div class="form-group">
                                <div class="custom-control custom-switch">
                                    <input type="checkbox" class="custom-control-input" id="isPrivate" name="isPrivate"
                                           ${chatRoom.isPrivate ? 'checked' : ''}>
                                    <label class="custom-control-label" for="isPrivate">비공개 채팅방</label>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <div class="custom-control custom-switch">
                                    <input type="checkbox" class="custom-control-input" id="allowInvite" name="allowInvite"
                                           ${chatRoom.allowInvite ? 'checked' : ''}>
                                    <label class="custom-control-label" for="allowInvite">초대 허용</label>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <div class="custom-control custom-switch">
                                    <input type="checkbox" class="custom-control-input" id="saveMessageHistory" name="saveMessageHistory"
                                           ${chatRoom.saveMessageHistory ? 'checked' : ''}>
                                    <label class="custom-control-label" for="saveMessageHistory">메시지 기록 저장</label>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <button type="submit" class="btn btn-primary">설정 저장</button>
                                <button type="button" class="btn btn-danger" onclick="deleteChatRoom('${chatRoom.roomId}')">채팅방 삭제</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function updateChatRoom(event) {
            event.preventDefault();
            const formData = new FormData(event.target);
            const data = {};
            formData.forEach((value, key) => {
                if (key === 'isPrivate' || key === 'allowInvite' || key === 'saveMessageHistory') {
                    data[key] = value === 'on';
                } else {
                    data[key] = value;
                }
            });
            
            fetch('/chat/room', {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('설정이 저장되었습니다.');
                    window.location.href = '/chat/room/' + data.roomId;
                } else {
                    alert('설정 저장 실패: ' + data.message);
                }
            })
            .catch(error => console.error('설정 저장 실패:', error));
        }

        function deleteChatRoom(roomId) {
            if (confirm('정말로 이 채팅방을 삭제하시겠습니까?')) {
                fetch('/chat/room/' + roomId, {
                    method: 'DELETE'
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert('채팅방이 삭제되었습니다.');
                        
                        // iframe에서 열린 경우 (부모 창이 존재하는 경우)
                        if (window.parent && window.parent !== window) {
                            // 부모 창에 삭제 이벤트 전달
                            if (window.parent.removeChatRoomFromList) {
                                window.parent.removeChatRoomFromList(roomId);
                            }
                            // 부모 창에 메시지 전송
                            window.parent.postMessage({
                                type: 'CHAT_ROOM_DELETED',
                                roomId: roomId
                            }, '*');
                            
                            // iframe을 채팅방 목록으로 리다이렉트
                            window.location.href = '/chat';
                            return;
                        }
                        
                        // 새 창에서 열린 경우
                        if (window.opener) {
                            window.opener.removeChatRoomFromList(roomId);
                            window.close();
                            return;
                        }
                        
                        // 일반적인 경우
                        window.location.href = '/chat';
                    } else {
                        alert('채팅방 삭제 실패: ' + data.message);
                    }
                })
                .catch(error => console.error('채팅방 삭제 실패:', error));
            }
        }
    </script>

    <style>
        .form-group {
            margin-bottom: 1rem;
        }

        .custom-control {
            margin-bottom: 0.5rem;
        }

        .btn {
            margin-right: 0.5rem;
        }
    </style>
</body>
</html> 