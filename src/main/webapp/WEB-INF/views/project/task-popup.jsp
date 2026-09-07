<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>작업 추가</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .popup-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
            width: 100%;
            max-width: 450px;
            overflow: hidden;
        }
        .popup-header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 20px 25px;
            text-align: center;
            position: relative;
        }
        .popup-title {
            font-size: 1.3em;
            font-weight: 600;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        .close-btn {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: white;
            font-size: 1.5em;
            cursor: pointer;
            padding: 5px;
            border-radius: 50%;
            transition: all 0.3s ease;
        }
        .close-btn:hover { background: rgba(255, 255, 255, 0.2); }
        .popup-body { padding: 25px; }
        .form-group { margin-bottom: 18px; }
        .form-label {
            font-size: 0.9em;
            font-weight: 600;
            color: #495057;
            margin-bottom: 6px;
            display: block;
        }
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 0.9em;
            transition: all 0.3s ease;
            font-family: inherit;
        }
        .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        .popup-footer {
            background: #f8f9fa;
            padding: 20px 25px;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        .btn {
            padding: 12px 25px;
            border-radius: 25px;
            font-size: 0.9em;
            font-weight: 600;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .btn-cancel {
            background: #6c757d;
            color: white;
        }
        .btn-cancel:hover {
            background: #545b62;
            transform: translateY(-1px);
        }
        .btn-save {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        .btn-save:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }
        .btn-save:disabled {
            opacity: 0.7;
            cursor: not-allowed;
        }
        .alert {
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 15px;
            font-size: 0.9em;
            display: none;
        }
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        /* 색상 선택기 스타일 */
        .color-picker {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        
        .color-input {
            height: 40px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
        }
        
        .color-presets {
            display: grid;
            grid-template-columns: repeat(8, 1fr);
            gap: 8px;
        }
        
        .color-preset {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            cursor: pointer;
            border: 2px solid transparent;
            transition: all 0.3s ease;
        }
        
        .color-preset:hover {
            transform: scale(1.1);
            border: 2px solid #fff;
            box-shadow: 0 0 0 2px #667eea;
        }
        
        .color-preset.selected {
            border: 2px solid #fff;
            box-shadow: 0 0 0 3px #667eea;
            transform: scale(1.1);
        }
        
        .popup-container {
            animation: popupSlideIn 0.4s ease-out;
        }
        @keyframes popupSlideIn {
            from {
                opacity: 0;
                transform: translateY(-30px) scale(0.9);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }
    </style>
</head>
<body>
    <div class="popup-container">
        <div class="popup-header">
            <h5 class="popup-title">
                <i class="fas fa-plus"></i>
                작업 추가
            </h5>
            <button type="button" class="close-btn" onclick="window.close()">
                <i class="fas fa-times"></i>
            </button>
        </div>
        
        <div class="popup-body">
            <div id="taskFormAlert" class="alert"></div>
            
            <div class="form-group">
                <label class="form-label">제목</label>
                <input type="text" class="form-control" id="taskTitle" placeholder="작업 제목을 입력하세요">
            </div>
            
            <div class="form-group">
                <label class="form-label">설명</label>
                <textarea class="form-control" id="taskDescription" rows="3" placeholder="작업 설명을 입력하세요"></textarea>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">시작월</label>
                    <select class="form-control" id="taskStartMonth">
                        <option value="1">1월</option>
                        <option value="2">2월</option>
                        <option value="3">3월</option>
                        <option value="4">4월</option>
                        <option value="5">5월</option>
                        <option value="6">6월</option>
                        <option value="7">7월</option>
                        <option value="8">8월</option>
                        <option value="9">9월</option>
                        <option value="10">10월</option>
                        <option value="11">11월</option>
                        <option value="12">12월</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">종료월</label>
                    <select class="form-control" id="taskEndMonth">
                        <option value="1">1월</option>
                        <option value="2">2월</option>
                        <option value="3">3월</option>
                        <option value="4">4월</option>
                        <option value="5">5월</option>
                        <option value="6">6월</option>
                        <option value="7">7월</option>
                        <option value="8">8월</option>
                        <option value="9">9월</option>
                        <option value="10">10월</option>
                        <option value="11">11월</option>
                        <option value="12">12월</option>
                    </select>
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label">상태</label>
                <select class="form-control" id="taskStatus">
                    <option value="TODO" selected>예정</option>
                    <option value="IN_PROGRESS">진행중</option>
                    <option value="DONE">완료</option>
                </select>
            </div>
            
            <div class="form-group">
                <label class="form-label">색상</label>
                <div class="color-picker">
                    <input type="color" class="form-control color-input" id="taskColor" value="#667eea">
                    <div class="color-presets">
                        <div class="color-preset" data-color="#667eea" style="background-color: #667eea;"></div>
                        <div class="color-preset" data-color="#f093fb" style="background-color: #f093fb;"></div>
                        <div class="color-preset" data-color="#4facfe" style="background-color: #4facfe;"></div>
                        <div class="color-preset" data-color="#43e97b" style="background-color: #43e97b;"></div>
                        <div class="color-preset" data-color="#fa709a" style="background-color: #fa709a;"></div>
                        <div class="color-preset" data-color="#ffecd2" style="background-color: #ffecd2;"></div>
                        <div class="color-preset" data-color="#a8edea" style="background-color: #a8edea;"></div>
                        <div class="color-preset" data-color="#d299c2" style="background-color: #d299c2;"></div>
                    </div>
                </div>
            </div>
            
            <div class="form-group">
                <label class="form-label">담당자</label>
                <select class="form-control" id="taskAssignedTo">
                    <option value="">-- 담당자를 선택해주세요 --</option>
                    <c:forEach items="${projectDetail.members}" var="member">
                        <option value="${member.userId}">${member.userName}</option>
                    </c:forEach>
                </select>
            </div>
            
            <input type="hidden" id="projectId" value="${projectDetail.project.id}">
        </div>
        
        <div class="popup-footer">
            <button type="button" class="btn btn-cancel" onclick="window.close()">
                <i class="fas fa-times"></i>
                취소
            </button>
            <button type="button" class="btn btn-save" id="saveTaskBtn">
                <i class="fas fa-check"></i>
                저장
            </button>
        </div>
    </div>

    <script>
        // 페이지 로드 후 실행
        document.addEventListener('DOMContentLoaded', function() {
            console.log('===== 작업 추가 페이지 로드됨 =====');
            
            // 현재 월로 기본값 설정
            const currentMonth = new Date().getMonth() + 1;
            document.getElementById('taskStartMonth').value = currentMonth;
            document.getElementById('taskEndMonth').value = currentMonth;
            
            console.log('기본 월 설정:', currentMonth);
            
            // 색상 선택기 이벤트
            document.querySelectorAll('.color-preset').forEach(preset => {
                preset.addEventListener('click', function() {
                    document.querySelectorAll('.color-preset').forEach(p => p.classList.remove('selected'));
                    this.classList.add('selected');
                    document.getElementById('taskColor').value = this.dataset.color;
                });
            });
            
            // 첫 번째 색상을 기본 선택
            document.querySelector('.color-preset').classList.add('selected');
            
            // 저장 버튼 이벤트
            document.getElementById('saveTaskBtn').addEventListener('click', function() {
                console.log('===== 저장 버튼 클릭됨 =====');
                
                const alertDiv = document.getElementById('taskFormAlert');
                const projectId = document.getElementById('projectId').value;
                
                // 입력값 수집
                const title = document.getElementById('taskTitle').value.trim();
                const description = document.getElementById('taskDescription').value.trim();
                const startMonth = document.getElementById('taskStartMonth').value;
                const endMonth = document.getElementById('taskEndMonth').value;
                const status = document.getElementById('taskStatus').value;
                const assignedTo = document.getElementById('taskAssignedTo').value;
                const color = document.getElementById('taskColor').value;
                
                console.log('입력값:', { title: title, description: description, startMonth: startMonth, endMonth: endMonth, status: status, assignedTo: assignedTo, color: color });
                
                // 유효성 검사
                if (!title) {
                    alertDiv.className = 'alert alert-danger';
                    alertDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> 제목을 입력해주세요.';
                    alertDiv.style.display = 'block';
                    return;
                }
                
                // 날짜 생성 (2025년 고정)
                const projectYear = 2025;
                const startDate = projectYear + '-' + String(startMonth).padStart(2, '0') + '-01';
                const endDate = projectYear + '-' + String(endMonth).padStart(2, '0') + '-28';
                
                console.log('생성된 날짜:', { startDate: startDate, endDate: endDate });
                
                // 요청 데이터 (JSON 형태)
                const requestData = {
                    title: title,
                    description: description,
                    startDate: startDate,
                    dueDate: endDate,
                    status: status,
                    assignedTo: assignedTo || null,
                    priority: 'MEDIUM',
                    color: color
                };
                
                console.log('전송할 데이터:', requestData);
                
                // 버튼 비활성화
                const saveBtn = this;
                saveBtn.disabled = true;
                saveBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 저장 중...';
                
                // 알림 숨기기
                alertDiv.style.display = 'none';
                
                // AJAX 요청 (JSON으로 전송)
                fetch('/projects/' + projectId + '/tasks', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(requestData)
                })
                .then(response => {
                    console.log('응답 상태:', response.status);
                    return response.json();
                })
                .then(data => {
                    console.log('응답 데이터:', data);
                    
                    if (data.success) {
                        alertDiv.className = 'alert alert-success';
                        alertDiv.innerHTML = '<i class="fas fa-check-circle"></i> ' + data.message;
                        alertDiv.style.display = 'block';
                        
                        // 부모 창 새로고침
                        if (window.opener && !window.opener.closed) {
                            window.opener.location.reload();
                        }
                        
                        setTimeout(function() { window.close(); }, 1500);
                    } else {
                        alertDiv.className = 'alert alert-danger';
                        alertDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + data.message;
                        alertDiv.style.display = 'block';
                    }
                })
                .catch(error => {
                    console.error('요청 오류:', error);
                    alertDiv.className = 'alert alert-danger';
                    alertDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> 작업 추가 중 오류가 발생했습니다.';
                    alertDiv.style.display = 'block';
                })
                .finally(() => {
                    // 버튼 다시 활성화
                    saveBtn.disabled = false;
                    saveBtn.innerHTML = '<i class="fas fa-check"></i> 저장';
                });
            });
        });
    </script>
</body>
</html> 