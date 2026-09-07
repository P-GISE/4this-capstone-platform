<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>채팅방 나가기 - ${chatRoom.name}</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        .warning-icon {
            font-size: 48px;
            color: #dc3545;
        }
    </style>
</head>
<body>
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-body text-center">
                        <div class="warning-icon mb-4">
                            <i class="fas fa-exclamation-triangle"></i>
                        </div>
                        
                        <h4 class="mb-4">채팅방을 나가시겠습니까?</h4>
                        
                        <div class="alert alert-warning">
                            <p class="mb-0">
                                채팅방을 나가면 다시 참여하기 전까지는 메시지를 볼 수 없습니다.
                                <c:if test="${isRoomAdmin}">
                                    <br>
                                    <strong>주의:</strong> 방장이 나가면 채팅방이 삭제됩니다.
                                </c:if>
                            </p>
                        </div>
                        
                        <div class="mt-4">
                            <button class="btn btn-danger mr-2" onclick="leaveRoom()">나가기</button>
                            <a href="/chat/room/${chatRoom.roomId}" class="btn btn-secondary">취소</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://kit.fontawesome.com/your-font-awesome-kit.js"></script>
    <script>
        function leaveRoom() {
            fetch(`/chat/room/${roomId}/leave`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            })
            .then(response => {
                if (response.ok) {
                    window.location.href = '/chat/rooms';
                } else {
                    alert('채팅방을 나가는 중 오류가 발생했습니다.');
                }
            });
        }
    </script>
</body>
</html> 