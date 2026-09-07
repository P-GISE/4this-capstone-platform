<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>채팅방 초대 - ${chatRoom.name}</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        .user-item {
            padding: 10px;
            border-bottom: 1px solid #eee;
            cursor: pointer;
        }
        .user-item:hover {
            background-color: #f8f9fa;
        }
        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
        }
        .selected-user {
            background-color: #e3f2fd;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4>채팅방 초대</h4>
                        <a href="/chat/room/${chatRoom.roomId}" class="btn btn-outline-secondary">돌아가기</a>
                    </div>
                    <div class="card-body">
                        <div class="form-group">
                            <input type="text" class="form-control" id="searchUser" 
                                   placeholder="사용자 검색..." onkeyup="searchUsers()">
                        </div>

                        <div class="selected-users mb-3">
                            <h6>선택된 사용자</h6>
                            <div id="selectedUsersList" class="d-flex flex-wrap">
                                <!-- 선택된 사용자들이 여기에 표시됩니다 -->
                            </div>
                        </div>

                        <div class="user-list">
                            <c:forEach items="${users}" var="user">
                                <div class="user-item d-flex align-items-center" 
                                     onclick="toggleUserSelection('${user.userId}', '${user.name}', '${user.profileImage}')">
                                    <img src="${user.profileImage}" alt="프로필" class="user-avatar mr-3">
                                    <div class="user-info">
                                        <div class="user-name">${user.name}</div>
                                        <small class="text-muted">${user.email}</small>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="text-center mt-4">
                            <button class="btn btn-primary" onclick="inviteUsers()">초대하기</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const selectedUsers = new Set();
        const roomId = '${chatRoom.roomId}';
        
        function toggleUserSelection(userId, userName, userImage) {
            const userItem = event.currentTarget;
            if (selectedUsers.has(userId)) {
                selectedUsers.delete(userId);
                userItem.classList.remove('selected-user');
                removeSelectedUser(userId);
            } else {
                selectedUsers.add(userId);
                userItem.classList.add('selected-user');
                addSelectedUser(userId, userName, userImage);
            }
        }
        
        function addSelectedUser(userId, userName, userImage) {
            const selectedUsersList = document.getElementById('selectedUsersList');
            const userTag = document.createElement('div');
            userTag.className = 'selected-user-tag m-1 p-2 bg-light rounded';
            userTag.innerHTML = 
                '<img src="' + userImage + '" alt="' + userName + '" class="user-avatar-sm mr-2" style="width: 20px; height: 20px;">' +
                userName +
                '<button type="button" class="close ml-2" onclick="removeUser(\'' + userId + '\')">&times;</button>';
            userTag.id = 'selected-user-' + userId;
            selectedUsersList.appendChild(userTag);
        }
        
        function removeSelectedUser(userId) {
            const userTag = document.getElementById('selected-user-' + userId);
            if (userTag) {
                userTag.remove();
            }
        }
        
        function removeUser(userId) {
            selectedUsers.delete(userId);
            const userItem = document.querySelector('[onclick*="' + userId + '"]');
            if (userItem) {
                userItem.classList.remove('selected-user');
            }
            removeSelectedUser(userId);
        }
        
        function searchUsers() {
            const searchText = document.getElementById('searchUser').value.toLowerCase();
            document.querySelectorAll('.user-item').forEach(item => {
                const userName = item.querySelector('.user-name').textContent.toLowerCase();
                const userEmail = item.querySelector('.text-muted').textContent.toLowerCase();
                if (userName.includes(searchText) || userEmail.includes(searchText)) {
                    item.style.display = '';
                } else {
                    item.style.display = 'none';
                }
            });
        }
        
        function inviteUsers() {
            if (selectedUsers.size === 0) {
                alert('초대할 사용자를 선택해주세요.');
                return;
            }
            
            fetch('/chat/room/' + roomId + '/invite', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    userIds: Array.from(selectedUsers)
                })
            })
            .then(response => {
                if (response.ok) {
                    alert('초대가 완료되었습니다.');
                    window.location.href = '/chat/room/' + roomId;
                } else {
                    alert('초대 중 오류가 발생했습니다.');
                }
            });
        }
    </script>
</body>
</html> 