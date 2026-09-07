<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/layout/head-meta.jsp" %>
    <title>프로젝트 AI 상담</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
        }

        .container {
            display: flex;
            width: 100%;
            min-height: 600px;
            background: white;
            margin: 20px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
            overflow: hidden;
        }

        /* 왼쪽 프로젝트 선택 영역 */
        .project-selection {
            width: 400px;
            background: #f8f9fa;
            border-right: 1px solid #e9ecef;
            display: flex;
            flex-direction: column;
        }

        .project-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            text-align: center;
        }

        .project-header h2 {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
        }

        .project-list {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
        }

        .project-item {
            background: white;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 15px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .project-item:hover {
            border-color: #667eea;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.2);
        }

        .project-item.selected {
            border-color: #667eea;
            background: #f0f4ff;
        }

        .project-title {
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
        }

        .project-description {
            font-size: 12px;
            color: #666;
            margin-bottom: 8px;
        }

        .project-meta {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            color: #999;
        }

        .selected-project-info {
            background: white;
            border-top: 1px solid #e9ecef;
            padding: 20px;
        }

        .selected-project-info h4 {
            margin: 0 0 10px 0;
            color: #333;
        }

        /* 오른쪽 AI 상담 영역 */
        .ai-assistant {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .ai-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .ai-header h2 {
            margin: 0;
            font-size: 18px;
        }

        .report-buttons {
            display: flex;
            gap: 10px;
        }

        .report-btn {
            padding: 8px 15px;
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 12px;
            transition: all 0.3s;
        }

        .report-btn:hover {
            background: rgba(255, 255, 255, 0.3);
        }

        .chat-area {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background: #fafbfc;
        }

        .welcome-message {
            text-align: center;
            color: #666;
            padding: 40px 20px;
        }

        .welcome-message i {
            font-size: 48px;
            color: #667eea;
            margin-bottom: 20px;
        }

        .message {
            display: flex;
            margin-bottom: 20px;
            max-width: 80%;
        }

        .message.user {
            margin-left: auto;
            flex-direction: row-reverse;
        }

        .message-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 10px;
            flex-shrink: 0;
        }

        .message.user .message-avatar {
            background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
            color: #333;
        }

        .message.ai .message-avatar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .message-content {
            background: white;
            padding: 15px;
            border-radius: 15px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            word-wrap: break-word;
        }

        .message.user .message-content {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .chat-input-area {
            padding: 20px;
            background: white;
            border-top: 1px solid #e9ecef;
        }

        .chat-input-container {
            display: flex;
            gap: 10px;
            align-items: flex-end;
        }

        .chat-input {
            flex: 1;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 20px;
            font-size: 14px;
            outline: none;
            background: #f8f9fa;
            resize: none;
            min-height: 40px;
            max-height: 100px;
        }

        .chat-input:focus {
            border-color: #667eea;
            background: white;
        }

        .chat-send-btn {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 50%;
            cursor: pointer;
            font-size: 18px;
            transition: all 0.3s;
        }

        .chat-send-btn:hover {
            transform: scale(1.1);
        }

        .typing-indicator {
            display: none;
            padding: 15px;
            background: white;
            border-radius: 15px;
            margin: 0 50px 15px 0;
            align-items: center;
            gap: 10px;
        }

        .typing-indicator.show {
            display: flex;
        }

        .typing-animation {
            display: flex;
            gap: 4px;
        }

        .typing-dot {
            width: 8px;
            height: 8px;
            background: #667eea;
            border-radius: 50%;
            animation: typing 1.4s infinite;
        }

        .typing-dot:nth-child(2) { animation-delay: 0.2s; }
        .typing-dot:nth-child(3) { animation-delay: 0.4s; }

        @keyframes typing {
            0%, 60%, 100% { transform: translateY(0); }
            30% { transform: translateY(-15px); }
        }

        .no-projects {
            text-align: center;
            padding: 40px 20px;
            color: #999;
        }

        .no-projects i {
            font-size: 48px;
            margin-bottom: 20px;
            color: #ddd;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- 왼쪽 프로젝트 선택 영역 -->
        <div class="project-selection">
            <div class="project-header">
                <h2><i class="fas fa-project-diagram"></i> 내 프로젝트</h2>
            </div>
            
            <div class="project-list" id="projectList">
                <c:choose>
                    <c:when test="${empty projects}">
                        <div class="no-projects">
                            <i class="fas fa-folder-open"></i>
                            <p>참여중인 프로젝트가 없습니다.</p>
                            <a href="/projects/create" style="color: #667eea; text-decoration: none;">새 프로젝트 만들기</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="project" items="${projects}">
                            <div class="project-item" data-project-id="${project.id}">
                                <div class="project-title">${project.title}</div>
                                <div class="project-description">
                                    <c:choose>
                                        <c:when test="${fn:length(project.description) > 80}">
                                            ${fn:substring(project.description, 0, 80)}...
                                        </c:when>
                                        <c:otherwise>
                                            ${project.description}
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="project-meta">
                                    <span>상태: ${project.status}</span>
                                    <span>${project.createdAt}</span>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
            
            <!-- 선택된 프로젝트 정보 -->
            <div class="selected-project-info" id="selectedProjectInfo" style="display: none;">
                <h4 id="selectedProjectTitle">프로젝트를 선택해주세요</h4>
                <div id="selectedProjectDetails"></div>
            </div>
        </div>

        <!-- 오른쪽 AI 상담 영역 -->
        <div class="ai-assistant">
            <div class="ai-header">
                <h2><i class="fas fa-robot"></i> AI 프로젝트 상담</h2>
                <div class="report-buttons">
                    <button class="report-btn" data-report-type="중간보고서" id="midReportBtn" disabled>
                        <i class="fas fa-file-alt"></i> 중간보고서
                    </button>
                    <button class="report-btn" data-report-type="최종보고서" id="finalReportBtn" disabled>
                        <i class="fas fa-file-pdf"></i> 최종보고서
                    </button>
                </div>
            </div>
            
            <div class="chat-area" id="chatArea">
                <div class="welcome-message" id="welcomeMessage">
                    <i class="fas fa-comments"></i>
                    <h3>프로젝트 AI 상담에 오신 것을 환영합니다!</h3>
                    <p>왼쪽에서 프로젝트를 선택하고, AI와 프로젝트에 대해 상담해보세요.</p>
                    <p><strong>가능한 질문 예시:</strong></p>
                    <ul style="text-align: left; display: inline-block; margin-top: 15px;">
                        <li>프로젝트 진행 상황을 분석해주세요</li>
                        <li>팀원들의 역할 분담을 개선하는 방법은?</li>
                        <li>프로젝트에서 발생할 수 있는 위험요소는?</li>
                        <li>다음 단계로 무엇을 해야 할까요?</li>
                    </ul>
                </div>
                
                <!-- 타이핑 인디케이터 -->
                <div class="typing-indicator" id="typingIndicator">
                    <div class="typing-animation">
                        <div class="typing-dot"></div>
                        <div class="typing-dot"></div>
                        <div class="typing-dot"></div>
                    </div>
                    <span>AI가 답변을 생성하고 있습니다...</span>
                </div>
            </div>
            
            <div class="chat-input-area">
                <div class="chat-input-container">
                    <textarea id="chatInput" class="chat-input" 
                              placeholder="프로젝트에 대해 궁금한 것을 질문해보세요..." 
                              rows="1" disabled></textarea>
                    <button id="sendBtn" class="chat-send-btn" onclick="sendMessage()" disabled>
                        <i class="fas fa-paper-plane"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let selectedProjectId = null;
        let selectedProjectData = null;

        // 프로젝트 선택
        function selectProject(projectId) {
            console.log('프로젝트 선택:', projectId);
            selectedProjectId = projectId;
            
            // 모든 프로젝트 아이템에서 selected 클래스 제거
            document.querySelectorAll('.project-item').forEach(item => {
                item.classList.remove('selected');
            });
            
            // 선택된 프로젝트에 selected 클래스 추가
            event.target.closest('.project-item').classList.add('selected');
            
            // 프로젝트 상세 정보 로드
            loadProjectDetail(projectId);
            
            // 채팅 입력 활성화
            document.getElementById('chatInput').disabled = false;
            document.getElementById('sendBtn').disabled = false;
            document.getElementById('midReportBtn').disabled = false;
            document.getElementById('finalReportBtn').disabled = false;
            
            // 웰컴 메시지 숨기기
            document.getElementById('welcomeMessage').style.display = 'none';
        }

        // 프로젝트 선택 (element 직접 전달)
        function selectProjectWithElement(projectId, element) {
            console.log('프로젝트 선택:', projectId);
            selectedProjectId = projectId;
            
            // 모든 프로젝트 아이템에서 selected 클래스 제거
            document.querySelectorAll('.project-item').forEach(item => {
                item.classList.remove('selected');
            });
            
            // 선택된 프로젝트에 selected 클래스 추가
            element.classList.add('selected');
            
            // 프로젝트 상세 정보 로드
            loadProjectDetail(projectId);
            
            // 채팅 입력 활성화
            document.getElementById('chatInput').disabled = false;
            document.getElementById('sendBtn').disabled = false;
            document.getElementById('midReportBtn').disabled = false;
            document.getElementById('finalReportBtn').disabled = false;
            
            // 웰컴 메시지 숨기기
            document.getElementById('welcomeMessage').style.display = 'none';
        }

        // 프로젝트 상세 정보 로드
        function loadProjectDetail(projectId) {
            fetch('/ai/project/' + projectId)
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    selectedProjectData = data;
                    updateSelectedProjectInfo(data);
                } else {
                    console.error('프로젝트 정보 로드 실패:', data.message);
                }
            })
            .catch(error => {
                console.error('프로젝트 정보 로드 오류:', error);
            });
        }

        // 선택된 프로젝트 정보 업데이트
        function updateSelectedProjectInfo(data) {
            const infoDiv = document.getElementById('selectedProjectInfo');
            const titleDiv = document.getElementById('selectedProjectTitle');
            const detailsDiv = document.getElementById('selectedProjectDetails');
            
            titleDiv.textContent = data.project.title;
            detailsDiv.innerHTML = 
                '<p><strong>설명:</strong> ' + (data.project.description || "설명 없음") + '</p>' +
                '<p><strong>팀원 수:</strong> ' + data.members.length + '명</p>' +
                '<p><strong>진행 작업:</strong> ' + data.tasks.length + '개</p>' +
                '<p><strong>상태:</strong> ' + (data.project.status || "진행중") + '</p>';
            
            infoDiv.style.display = 'block';
        }

        // 메시지 전송
        function sendMessage() {
            const input = document.getElementById('chatInput');
            const message = input.value.trim();
            
            if (!message || !selectedProjectId) {
                alert('프로젝트를 선택하고 메시지를 입력해주세요.');
                return;
            }
            
            // 사용자 메시지 표시
            displayMessage('user', message);
            
            // 입력창 초기화
            input.value = '';
            input.style.height = 'auto';
            
            // 타이핑 인디케이터 표시
            showTypingIndicator();
            
            // AI 응답 요청
            const formData = new FormData();
            formData.append('projectId', selectedProjectId);
            formData.append('question', message);
            
            fetch('/ai/project-chat', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                hideTypingIndicator();
                if (data.success) {
                    displayMessage('ai', data.answer);
                } else {
                    displayMessage('ai', '죄송합니다. 응답 생성 중 오류가 발생했습니다: ' + data.message);
                }
            })
            .catch(error => {
                hideTypingIndicator();
                displayMessage('ai', '죄송합니다. 요청 처리 중 오류가 발생했습니다.');
                console.error('AI 응답 오류:', error);
            });
        }

        // 메시지 표시
        function displayMessage(type, content) {
            const chatArea = document.getElementById('chatArea');
            const messageDiv = document.createElement('div');
            messageDiv.className = 'message ' + type;
            
            const avatarIcon = type === 'user' ? 'fas fa-user' : 'fas fa-robot';
            
            messageDiv.innerHTML = 
                '<div class="message-avatar">' +
                    '<i class="' + avatarIcon + '"></i>' +
                '</div>' +
                '<div class="message-content">' + 
                    formatMessage(content) + 
                '</div>';
            
            chatArea.appendChild(messageDiv);
            chatArea.scrollTop = chatArea.scrollHeight;
        }

        // 메시지 포맷팅
        function formatMessage(message) {
            return message
                .replace(/\n/g, '<br>')
                .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
                .replace(/\*(.*?)\*/g, '<em>$1</em>');
        }

        // 타이핑 인디케이터 표시/숨김
        function showTypingIndicator() {
            document.getElementById('typingIndicator').classList.add('show');
            document.getElementById('chatArea').scrollTop = document.getElementById('chatArea').scrollHeight;
        }

        function hideTypingIndicator() {
            document.getElementById('typingIndicator').classList.remove('show');
        }

        // 보고서 생성
        function generateReport(reportType) {
            if (!selectedProjectId) {
                alert('프로젝트를 선택해주세요.');
                return;
            }
            
            showTypingIndicator();
            
            const formData = new FormData();
            formData.append('projectId', selectedProjectId);
            formData.append('reportType', reportType);
            
            fetch('/ai/generate-project-report', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                hideTypingIndicator();
                if (data.success) {
                    displayMessage('ai', '<strong>' + reportType + ' 생성 완료</strong><br><br>' + data.report);
                } else {
                    displayMessage('ai', '보고서 생성 중 오류가 발생했습니다: ' + data.message);
                }
            })
            .catch(error => {
                hideTypingIndicator();
                displayMessage('ai', '보고서 생성 중 오류가 발생했습니다.');
                console.error('보고서 생성 오류:', error);
            });
        }

        // 엔터키 이벤트
        document.getElementById('chatInput').addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });

        // 자동 높이 조절
        document.getElementById('chatInput').addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = this.scrollHeight + 'px';
        });

        // 보고서 버튼 이벤트 리스너 추가
        document.getElementById('midReportBtn').addEventListener('click', function() {
            const reportType = this.getAttribute('data-report-type');
            generateReport(reportType);
        });

        document.getElementById('finalReportBtn').addEventListener('click', function() {
            const reportType = this.getAttribute('data-report-type');
            generateReport(reportType);
        });

        // 프로젝트 아이템 클릭 이벤트 리스너 추가
        document.addEventListener('DOMContentLoaded', function() {
            document.querySelectorAll('.project-item').forEach(function(item) {
                item.addEventListener('click', function(event) {
                    const projectId = this.getAttribute('data-project-id');
                    selectProjectWithElement(projectId, this);
                });
            });
        });
    </script>
</body>
</html> 