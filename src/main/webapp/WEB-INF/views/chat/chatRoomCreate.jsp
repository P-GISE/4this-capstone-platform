<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.text.SimpleDateFormat, java.util.Date" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>새 채팅방 만들기</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <style>
        body {
            padding: 20px;
            background-color: #f8f9fa;
        }
        
        .card {
            border: none;
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        }
        
        .card-header {
            background-color: #007bff;
            color: white;
            border-bottom: none;
        }
        
        .form-group {
            margin-bottom: 1rem;
        }

        .custom-control {
            margin-bottom: 0.5rem;
        }

        .btn {
            margin-right: 0.5rem;
        }
        
        .btn-group {
            display: flex;
            gap: 0.5rem;
            margin-top: 1rem;
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="card-header">
            <h5 class="card-title mb-0">
                <i class="fas fa-plus-circle"></i> 새 채팅방 만들기
            </h5>
        </div>
        <div class="card-body">
            <form id="createChatRoomForm" onsubmit="handleCreateChatRoom(event)">
                <div class="form-group">
                    <label for="roomName">채팅방 이름 <span class="text-danger">*</span></label>
                    <input type="text" class="form-control" id="roomName" name="roomName" required
                           placeholder="채팅방 이름을 입력해주세요">
                </div>
                
                <div class="form-group">
                    <label for="description">설명</label>
                    <textarea class="form-control" id="description" name="description" rows="3"
                              placeholder="채팅방에 대한 간단한 설명을 입력해주세요"></textarea>
                </div>
                
                <div class="form-group">
                    <label for="maxParticipants">최대 참여자 수</label>
                    <input type="number" class="form-control" id="maxParticipants" name="maxParticipants" 
                           min="2" max="100" value="50">
                    <small class="form-text text-muted">2명 이상 100명 이하로 설정해주세요</small>
                </div>
                
                <div class="form-group">
                    <div class="custom-control custom-switch">
                        <input type="checkbox" class="custom-control-input" id="isPrivate" name="isPrivate">
                        <label class="custom-control-label" for="isPrivate">
                            <i class="fas fa-lock"></i> 비공개 채팅방
                        </label>
                    </div>
                    <small class="form-text text-muted">비공개 채팅방은 초대를 통해서만 참여할 수 있습니다</small>
                </div>
                
                <div class="form-group">
                    <div class="custom-control custom-switch">
                        <input type="checkbox" class="custom-control-input" id="allowInvite" name="allowInvite" checked>
                        <label class="custom-control-label" for="allowInvite">
                            <i class="fas fa-user-plus"></i> 초대 허용
                        </label>
                    </div>
                </div>
                
                <div class="form-group">
                    <div class="custom-control custom-switch">
                        <input type="checkbox" class="custom-control-input" id="saveMessageHistory" name="saveMessageHistory" checked>
                        <label class="custom-control-label" for="saveMessageHistory">
                            <i class="fas fa-history"></i> 메시지 기록 저장
                        </label>
                    </div>
                </div>
                
                <div class="btn-group">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-plus"></i> 채팅방 만들기
                    </button>
                    <button type="button" class="btn btn-secondary" onclick="closeWindow()">
                        <i class="fas fa-times"></i> 취소
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function handleCreateChatRoom(event) {
            event.preventDefault();
            const form = event.target;
            
            // 버튼 비활성화
            const submitBtn = form.querySelector('button[type="submit"]');
            const originalText = submitBtn.innerHTML;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 생성 중...';
            submitBtn.disabled = true;
            
            const formData = {
                name: form.roomName.value,
                description: form.description.value,
                maxParticipants: parseInt(form.maxParticipants.value),
                isPrivate: form.isPrivate.checked,
                allowInvite: form.allowInvite.checked,
                saveMessageHistory: form.saveMessageHistory.checked,
                projectId: 1  // 기본값 설정
            };
            
            fetch('/chat/room', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(formData)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('채팅방이 생성되었습니다.');
                    
                    // 부모 창에 메시지 전송
                    if (window.opener) {
                        window.opener.postMessage('chatRoomCreated', '*');
                    }
                    
                    // 창 닫기
                    window.close();
                } else {
                    alert('채팅방 생성에 실패했습니다.');
                    // 버튼 복원
                    submitBtn.innerHTML = originalText;
                    submitBtn.disabled = false;
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('채팅방 생성 중 오류가 발생했습니다.');
                // 버튼 복원
                submitBtn.innerHTML = originalText;
                submitBtn.disabled = false;
            });
        }
        
        function closeWindow() {
            window.close();
        }
        
        // 엔터키로 폼 제출
        document.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                const activeElement = document.activeElement;
                if (activeElement.tagName !== 'TEXTAREA') {
                    e.preventDefault();
                    document.getElementById('createChatRoomForm').dispatchEvent(new Event('submit'));
                }
            }
        });
    </script>
</body>
</html> 