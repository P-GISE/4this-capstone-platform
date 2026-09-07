<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>채팅 알림 설정</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link href="https://cdn.jsdelivr.net/npm/boxicons@2.0.7/css/boxicons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700&display=swap');
        
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            background: #f8fafc;
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        
        .container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .settings-container {
            width: 100%;
            max-width: 600px;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            border: 1px solid #e2e8f0;
            overflow: hidden;
        }
        
        .settings-header {
            padding: 24px;
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            text-align: center;
        }
        
        .settings-header h4 {
            margin: 0;
            font-size: 20px;
            font-weight: 600;
            color: #1e293b;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
        }
        
        .settings-body {
            padding: 24px;
            background: #f8fafc;
        }
        
        .form-section {
            background: #ffffff;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .form-section h5 {
            font-size: 16px;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .custom-control {
            margin-bottom: 16px;
        }
        
        .custom-control-label {
            font-weight: 500;
            color: #374151;
            font-size: 14px;
        }
        
        .custom-control-input:checked ~ .custom-control-label::before {
            background-color: #3b82f6;
            border-color: #3b82f6;
        }
        
        .form-control {
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 12px 16px;
            font-size: 14px;
            transition: all 0.3s ease;
            background: #ffffff;
        }
        
        .form-control:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
            background: #ffffff;
        }
        
        .form-control::placeholder {
            color: #94a3b8;
        }
        
        .time-inputs .col-md-6 {
            margin-bottom: 16px;
        }
        
        .time-inputs label {
            font-weight: 500;
            color: #374151;
            font-size: 14px;
            margin-bottom: 8px;
            display: block;
        }
        
        .room-notification-setting {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 12px;
            transition: all 0.3s ease;
        }
        
        .room-notification-setting:hover {
            background: #f1f5f9;
            border-color: #cbd5e1;
        }
        
        .room-notification-setting h6 {
            font-size: 14px;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 4px;
        }
        
        .room-notification-setting .text-muted {
            font-size: 12px;
            color: #64748b;
        }
        
        .action-buttons {
            text-align: center;
            padding: 24px;
            background: #ffffff;
            border-top: 1px solid #e2e8f0;
        }
        
        .btn {
            border-radius: 8px;
            padding: 12px 24px;
            font-weight: 500;
            font-size: 14px;
            transition: all 0.3s ease;
            border: none;
        }
        
        .btn-primary {
            background: #3b82f6;
            color: white;
        }
        
        .btn-primary:hover {
            background: #2563eb;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
        }
        
        .btn-secondary {
            background: #f8fafc;
            color: #64748b;
            border: 1px solid #e2e8f0;
        }
        
        .btn-secondary:hover {
            background: #f1f5f9;
            color: #475569;
            border-color: #cbd5e1;
        }
        
        .section-icon {
            color: #3b82f6;
            font-size: 16px;
        }
        
        /* 커스텀 스위치 스타일링 */
        .custom-switch .custom-control-input:checked ~ .custom-control-label::before {
            background-color: #3b82f6;
            border-color: #3b82f6;
        }
        
        .custom-switch .custom-control-input:checked ~ .custom-control-label::after {
            background-color: #ffffff;
        }
        
        /* 반응형 */
        @media (max-width: 768px) {
            .container {
                padding: 12px;
            }
            
            .settings-header {
                padding: 20px;
            }
            
            .settings-body {
                padding: 20px;
            }
            
            .form-section {
                padding: 16px;
            }
            
            .action-buttons {
                padding: 20px;
            }
            
            .btn {
                width: 100%;
                margin-bottom: 8px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="settings-container">
            <div class="settings-header">
                <h4>
                    <i class="fas fa-bell section-icon"></i>
                    채팅 알림 설정
                </h4>
            </div>
            <div class="settings-body">
                <form id="notificationSettingsForm">
                    <div class="form-section">
                        <h5>
                            <i class="fas fa-cog section-icon"></i>
                            일반 알림 설정
                        </h5>
                        <div class="custom-control custom-switch">
                            <input type="checkbox" class="custom-control-input" 
                                   id="enableNotifications" name="enableNotifications"
                                   <c:if test="${not empty settings and settings.enableNotifications}">checked</c:if>>
                            <label class="custom-control-label" for="enableNotifications">
                                채팅 알림 활성화
                            </label>
                        </div>
                        
                        <div class="custom-control custom-switch">
                            <input type="checkbox" class="custom-control-input" 
                                   id="soundEnabled" name="soundEnabled"
                                   <c:if test="${not empty settings and settings.soundEnabled}">checked</c:if>>
                            <label class="custom-control-label" for="soundEnabled">
                                알림음 활성화
                            </label>
                        </div>
                        
                        <div class="custom-control custom-switch">
                            <input type="checkbox" class="custom-control-input" 
                                   id="desktopNotifications" name="desktopNotifications"
                                   <c:if test="${not empty settings and settings.desktopNotifications}">checked</c:if>>
                            <label class="custom-control-label" for="desktopNotifications">
                                데스크톱 알림 활성화
                            </label>
                        </div>
                    </div>

                    <div class="form-section">
                        <h5>
                            <i class="fas fa-moon section-icon"></i>
                            방해 금지 시간
                        </h5>
                        <div class="row time-inputs">
                            <div class="col-md-6">
                                <label for="doNotDisturbStart">시작 시간</label>
                                <input type="time" class="form-control" id="doNotDisturbStart" 
                                       name="doNotDisturbStart" value="${not empty settings ? settings.doNotDisturbStart : ''}">
                            </div>
                            <div class="col-md-6">
                                <label for="doNotDisturbEnd">종료 시간</label>
                                <input type="time" class="form-control" id="doNotDisturbEnd" 
                                       name="doNotDisturbEnd" value="${not empty settings ? settings.doNotDisturbEnd : ''}">
                            </div>
                        </div>
                    </div>

                    <div class="form-section">
                        <h5>
                            <i class="fas fa-comments section-icon"></i>
                            채팅방별 알림 설정
                        </h5>
                        <c:if test="${not empty roomSettings}">
                            <c:forEach items="${roomSettings}" var="roomSetting">
                                <div class="room-notification-setting">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h6>${roomSetting.name}</h6>
                                            <small class="text-muted">${roomSetting.participantCount}명 참여 중</small>
                                        </div>
                                        <div class="custom-control custom-switch">
                                            <input type="checkbox" class="custom-control-input" 
                                                   id="roomNotification_${roomSetting.roomId}" 
                                                   name="roomNotifications[${roomSetting.roomId}]"
                                                   <c:if test="${not empty roomNotificationSettings and roomNotificationSettings[roomSetting.roomId]}">checked</c:if>>
                                            <label class="custom-control-label" 
                                                   for="roomNotification_${roomSetting.roomId}">
                                                알림 받기
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:if>
                    </div>

                </form>
            </div>
            <div class="action-buttons">
                <button type="submit" form="notificationSettingsForm" class="btn btn-primary">
                    <i class="fas fa-save"></i> 설정 저장
                </button>
                <button type="button" class="btn btn-secondary ml-2" onclick="goBack()">
                    <i class="fas fa-times"></i> 취소
                </button>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 취소 버튼 클릭 시 이전 페이지로 돌아가기
        function goBack() {
            console.log('취소 버튼 클릭 - 이전 페이지로 돌아가기');
            // 브라우저 히스토리가 있는지 확인
            if (window.history.length > 1) {
                window.history.back();
            } else {
                // 히스토리가 없으면 채팅 메인 페이지로 이동
                window.location.href = '/chat';
            }
        }
        
        // ESC 키 눌렀을 때 취소 기능
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                goBack();
            }
        });
        
        document.getElementById('notificationSettingsForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            const settings = {};
            
            // 일반 알림 설정 - 체크박스 상태 직접 확인
            settings.enableNotifications = document.getElementById('enableNotifications').checked;
            settings.soundEnabled = document.getElementById('soundEnabled').checked;
            settings.desktopNotifications = document.getElementById('desktopNotifications').checked;
            
            // 시간 설정
            settings.doNotDisturbStart = document.getElementById('doNotDisturbStart').value;
            settings.doNotDisturbEnd = document.getElementById('doNotDisturbEnd').value;
            
            // 채팅방별 알림 설정 - 모든 체크박스 상태 확인
            settings.roomNotifications = {};
            const roomCheckboxes = document.querySelectorAll('input[name^="roomNotifications"]');
            roomCheckboxes.forEach(checkbox => {
                const roomId = checkbox.name.match(/\[(.*?)\]/)[1];
                settings.roomNotifications[roomId] = checkbox.checked;
            });
            
            console.log('=== 설정 저장 시작 ===');
            console.log('전송할 설정 데이터:', settings);
            console.log('일반 설정:', {
                enableNotifications: settings.enableNotifications,
                soundEnabled: settings.soundEnabled,
                desktopNotifications: settings.desktopNotifications
            });
            console.log('채팅방별 설정:', settings.roomNotifications);
            
            fetch('/chat/settings/notifications', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(settings)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    alert('알림 설정이 저장되었습니다.');
                    // 이전 페이지(채팅방)로 돌아가기
                    goBack();
                } else {
                    alert('설정 저장 중 오류가 발생했습니다: ' + data.message);
                }
            })
            .catch(error => {
                console.error('알림 설정 저장 오류:', error);
                alert('설정 저장 중 네트워크 오류가 발생했습니다.');
            });
        });
    </script>
</body>
</html> 