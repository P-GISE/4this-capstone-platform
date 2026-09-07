<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>참여자 권한 관리 - ${chatRoom.name}</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        .user-item {
            padding: 15px;
            border-bottom: 1px solid #eee;
        }
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
        }
        .permission-badge {
            font-size: 0.8em;
            padding: 3px 8px;
            border-radius: 12px;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4>참여자 권한 관리</h4>
                        <a href="/chat/room/${chatRoom.roomId}" class="btn btn-outline-secondary">돌아가기</a>
                    </div>
                    <div class="card-body">
                        <div class="form-group">
                            <input type="text" class="form-control" id="searchUser" 
                                   placeholder="사용자 검색..." onkeyup="searchUsers()">
                        </div>

                        <div class="user-list">
                            <c:forEach items="${participants}" var="participant">
                                <div class="user-item">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div class="d-flex align-items-center">
                                            <img src="${participant.profileImage}" alt="프로필" 
                                                 class="user-avatar mr-3">
                                            <div>
                                                <h6 class="mb-0">${participant.name}</h6>
                                                <small class="text-muted">${participant.email}</small>
                                            </div>
                                        </div>
                                        <div class="permission-controls">
                                            <c:if test="${isRoomAdmin && participant.userId != currentUserId}">
                                                <select class="form-control form-control-sm" 
                                                        onchange="updatePermission('${participant.userId}', this.value)">
                                                    <option value="MEMBER" 
                                                            ${participant.role == 'MEMBER' ? 'selected' : ''}>
                                                        일반 멤버
                                                    </option>
                                                    <option value="MODERATOR" 
                                                            ${participant.role == 'MODERATOR' ? 'selected' : ''}>
                                                        관리자
                                                    </option>
                                                </select>
                                            </c:if>
                                            <c:if test="${participant.userId == currentUserId}">
                                                <span class="badge badge-primary permission-badge">나</span>
                                            </c:if>
                                        </div>
                                    </div>
                                    <div class="mt-2">
                                        <c:forEach items="${participant.permissions}" var="permission">
                                            <span class="badge badge-info mr-1">${permission}</span>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function searchUsers() {
            const searchText = document.getElementById('searchUser').value.toLowerCase();
            document.querySelectorAll('.user-item').forEach(item => {
                const userName = item.querySelector('h6').textContent.toLowerCase();
                const userEmail = item.querySelector('.text-muted').textContent.toLowerCase();
                if (userName.includes(searchText) || userEmail.includes(searchText)) {
                    item.style.display = '';
                } else {
                    item.style.display = 'none';
                }
            });
        }

        function updatePermission(userId, newRole) {
            if (!confirm('이 사용자의 권한을 변경하시겠습니까?')) {
                return;
            }

            fetch(`/chat/room/${roomId}/permissions/${userId}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    role: newRole
                })
            })
            .then(response => {
                if (response.ok) {
                    alert('권한이 변경되었습니다.');
                    location.reload();
                } else {
                    alert('권한 변경 중 오류가 발생했습니다.');
                }
            });
        }
    </script>
</body>
</html> 