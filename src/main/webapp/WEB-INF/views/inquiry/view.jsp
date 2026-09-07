<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<head>
    <title>문의 상세보기</title>
    <style>
        :root {
            --primary-color: #4751c9;
            --secondary-color: #e9eaff;
            --dark-color: #1e1e1e;
            --light-color: #ffffff;
            --accent-color: #ff7043;
            --grey-color: #f5f5f7;
            --text-color: #333333;
            --light-purple: #e9e6ff;
            --active-purple: #6c63ff;
            --border-color: #eaeaea;
            --success-color: #52c41a;
            --warning-color: #faad14;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', sans-serif;
        }
        
        /* content와 main-body 스타일은 head-meta.jsp에서 관리 */

        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f8f9fa;
            color: #2d3748;
            line-height: 1.6;
        }
        
        .view-container {
            background-color: white;
            border-radius: 8px;
            padding: 40px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }
        
        .view-title {
            font-size: 1.8rem;
            font-weight: bold;
            margin-bottom: 20px;
            color: #333;
            line-height: 1.4;
        }
        
        .view-meta {
            font-size: 0.9rem;
            color: #888;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .view-content {
            font-size: 1rem;
            color: #444;
            line-height: 1.8;
            white-space: pre-line;
            margin-bottom: 30px;
        }
        
        .badge {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.8rem;
            color: white;
            font-weight: 500;
            margin-left: 8px;
        }
        
        .badge-urgent {
            background-color: var(--accent-color);
        }
        
        .badge-pending {
            background-color: #999;
        }
        
        .badge-answered {
            background-color: var(--success-color);
        }
        
        .badge-edited {
            background-color: var(--warning-color);
        }
        
        /* 첨부파일 스타일 */
        .attachment-section {
            margin-top: 40px;
            padding-top: 30px;
            border-top: 1px solid #eee;
        }
        
        .attachment-title {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 15px;
            color: #333;
        }
        
        .attachment-list {
            list-style: none;
            padding: 0;
        }
        
        .attachment-item {
            display: flex;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .attachment-item:last-child {
            border-bottom: none;
        }
        
        .attachment-icon {
            font-size: 1.2rem;
            margin-right: 10px;
            color: #666;
        }
        
        .attachment-info {
            flex: 1;
        }
        
        .attachment-name {
            font-weight: 500;
            color: #333;
            text-decoration: none;
            margin-bottom: 4px;
            display: block;
        }
        
        .attachment-name:hover {
            color: var(--primary-color);
            text-decoration: underline;
        }
        
        .attachment-meta {
            font-size: 0.85rem;
            color: #999;
        }
        
        /* 답변 섹션 스타일 */
        .section-title {
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 20px;
            color: var(--text-color);
            padding-bottom: 10px;
            border-bottom: 2px solid var(--light-purple);
        }
        
        .answer-item {
            background-color: #f8f9ff;
            border-left: 4px solid var(--primary-color);
            border-radius: 0 8px 8px 0;
            padding: 20px;
            margin-bottom: 20px;
        }
        
        .answer-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #e1e5ff;
        }
        
        .answer-author {
            display: flex;
            align-items: center;
        }
        
        .author-avatar {
            width: 32px;
            height: 32px;
            background-color: var(--primary-color);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            margin-right: 10px;
        }
        
        .author-info {
            display: flex;
            flex-direction: column;
        }
        
        .author-name {
            font-weight: 600;
            color: var(--text-color);
        }
        
        .author-role {
            font-size: 0.8rem;
            color: #666;
        }
        
        .answer-meta {
            font-size: 0.85rem;
            color: #888;
        }
        
        .answer-content {
            font-size: 0.95rem;
            line-height: 1.6;
            color: #444;
            white-space: pre-line;
        }
        
        /* 답변 첨부파일 스타일 */
        .answer-attachment-section {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #e1e5ff;
        }
        
        .answer-attachment-title {
            font-size: 0.9rem;
            font-weight: 600;
            margin-bottom: 10px;
            color: #666;
        }
        
        .answer-attachment-list {
            list-style: none;
            padding: 0;
        }
        
        .answer-attachment-item {
            display: flex;
            align-items: center;
            padding: 8px 12px;
            background-color: rgba(255, 255, 255, 0.7);
            border-radius: 4px;
            margin-bottom: 5px;
            border: 1px solid #e1e5ff;
        }
        
        .answer-attachment-item:last-child {
            margin-bottom: 0;
        }
        
        .answer-attachment-icon {
            font-size: 1rem;
            margin-right: 8px;
            color: #888;
        }
        
        .answer-attachment-info {
            flex: 1;
        }
        
        .answer-attachment-name {
            font-weight: 500;
            color: #444;
            text-decoration: none;
            font-size: 0.9rem;
        }
        
        .answer-attachment-name:hover {
            color: var(--primary-color);
            text-decoration: underline;
        }
        
        .answer-attachment-meta {
            font-size: 0.8rem;
            color: #999;
            margin-top: 2px;
        }
        
        /* 답변 작성 폼 스타일 */
        .answer-form-section {
            background-color: white;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-size: 1rem;
            color: var(--text-color);
            font-weight: 500;
        }
        
        .form-textarea {
            width: 100%;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 1rem;
            resize: vertical;
            min-height: 120px;
            font-family: inherit;
            line-height: 1.6;
        }
        
        .form-textarea:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(71, 81, 201, 0.1);
        }
        
        /* 버튼 스타일 */
        .btn {
            padding: 12px 24px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            border: none;
            font-size: 1rem;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            color: white;
        }
        
        .btn-primary:hover {
            background-color: var(--active-purple);
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(71, 81, 201, 0.3);
        }
        
        .btn-secondary {
            background-color: white;
            border: 1px solid #ddd;
            color: var(--text-color);
        }
        
        .btn-secondary:hover {
            background-color: #f5f5f5;
        }
        
        .btn-danger {
            background-color: #dc3545;
            color: white;
        }
        
        .btn-danger:hover {
            background-color: #c82333;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
        }
        
        .action-buttons {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 30px;
        }
        
        .answer-buttons {
            display: flex;
            gap: 10px;
        }
        
        .no-answers {
            text-align: center;
            padding: 40px;
            color: #999;
            font-style: italic;
        }
        
        .read-indicator {
            font-size: 0.8rem;
            color: var(--success-color);
            font-weight: 500;
        }
        
        .unread-indicator {
            font-size: 0.8rem;
            color: var(--accent-color);
            font-weight: 500;
        }
        .content, .main-body {
        height: auto !important;
        overflow: visible !important;
        }   
    </style>
</head>
<body>
    <div class="sidebar">
        <%@ include file="../layout/sidebar.jsp" %>
    </div>

    <div class="content">
        <%@ include file="../layout/header.jsp" %>

        <div class="main-body">
            <!-- 문의사항 내용 -->
            <div class="view-container">
                <div class="view-title">${inquiry.title}</div>
                <div class="view-meta">
                    <strong>작성자:</strong> ${inquiry.writerName} |
                    <strong>작성일:</strong> <fmt:formatDate value="${inquiry.createdAt}" pattern="yyyy-MM-dd HH:mm" /> |
                    <strong>카테고리:</strong> ${inquiry.category} |
                    <strong>상태:</strong>
                    <c:choose>
                        <c:when test="${inquiry.status == 'ANSWERED'}">
                            <span class="badge badge-answered">답변완료</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge badge-pending">대기중</span>
                        </c:otherwise>
                    </c:choose>
                    <c:if test="${inquiry.urgent}">
                        <span class="badge badge-urgent">우선</span>
                    </c:if>
                </div>

                <div class="view-content">
                    ${inquiry.content}
                </div>

                <!-- 문의사항 첨부파일 -->
                <c:if test="${not empty attachments}">
                    <div class="attachment-section">
                        <div class="attachment-title">📎 첨부파일 (${attachments.size()}개)</div>
                        <ul class="attachment-list">
                            <c:forEach var="file" items="${attachments}">
                                <li class="attachment-item">
                                    <span class="attachment-icon">📄</span>
                                    <div class="attachment-info">
                                        <a href="/inquiry/download?attachmentId=${file.id}" 
                                           class="attachment-name"
                                           title="${file.originalFileName}">
                                            ${file.originalFileName}
                                        </a>
                                        <div class="attachment-meta">
                                            크기: <fmt:formatNumber value="${file.fileSize / 1024}" pattern="#,##0.0"/>KB | 
                                            다운로드: ${file.downloadCount}회 |
                                            업로드: <fmt:formatDate value="${file.uploadedAt}" pattern="yyyy-MM-dd HH:mm"/>
                                        </div>
                                    </div>
                                </li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>
            </div>

            <!-- 답변 섹션 -->
            <div class="view-container">
                <div class="section-title">관리자 답변</div>
                
                <c:choose>
                    <c:when test="${not empty answers}">
                        <c:forEach var="answer" items="${answers}" varStatus="status">
                            <div class="answer-item">
                                <div class="answer-header">
                                    <div class="answer-author">
                                        <div class="author-avatar">
                                            ${answer.adminName.substring(0,1)}
                                        </div>
                                        <div class="author-info">
                                            <div class="author-name">${answer.adminName}</div>
                                            <div class="author-role">${answer.adminRole}</div>
                                        </div>
                                    </div>
                                    <div class="answer-meta">
                                        <fmt:formatDate value="${answer.createdAt}" pattern="yyyy-MM-dd HH:mm" />
                                        <c:if test="${answer.edited}">
                                            <span class="badge badge-edited">수정됨</span>
                                            <br><small>수정자: ${answer.updatedByName}</small>
                                        </c:if>
                                        <c:if test="${isAdmin}">
                                            <br>
                                            <c:choose>
                                                <c:when test="${not empty answer.readByUser and (answer.readByUser == true || answer.readByUser == 1)}">
                                                    <span class="read-indicator">✓ 읽음</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="unread-indicator">● 읽지않음</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>
                                    </div>
                                </div>
                                
                                <div class="answer-content">
                                    ${answer.answer}
                                </div>
                                
                                <!-- 답변 첨부파일 표시 -->
                                <c:if test="${not empty answerAttachments 
                                    and fn:length(answerAttachments) > status.index 
                                    and not empty answerAttachments[status.index]}">
                                    <div class="answer-attachment-section">
                                        <div class="answer-attachment-title">📎 첨부파일 (${answerAttachments[status.index].size()}개)</div>
                                        <ul class="answer-attachment-list">
                                            <c:forEach var="file" items="${answerAttachments[status.index]}">
                                                <li class="answer-attachment-item">
                                                    <span class="answer-attachment-icon">📄</span>
                                                    <div class="answer-attachment-info">
                                                        <a href="/inquiry/answer/download?attachmentId=${file.id}" 
                                                           class="answer-attachment-name"
                                                           title="${file.originalFileName}">
                                                            ${file.originalFileName}
                                                        </a>
                                                        <div class="answer-attachment-meta">
                                                            <fmt:formatNumber value="${file.fileSize / 1024}" pattern="#,##0.0"/>KB | 
                                                            <fmt:formatDate value="${file.uploadedAt}" pattern="yyyy-MM-dd HH:mm"/>
                                                        </div>
                                                    </div>
                                                </li>
                                            </c:forEach>
                                        </ul>
                                    </div>
                                </c:if>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="no-answers">
                            아직 답변이 없습니다.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- 관리자/조교 답변 작성 폼 - 답변이 없을 때만 노출 -->
            <c:if test="${(isAdmin or isAllowedAssistant) and empty answers}">
                <div class="answer-form-section">
                    <div class="section-title">답변 작성</div>
                    
                    <form action="/inquiry/answer" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="inquiryId" value="${inquiry.id}" />
                        
                        <div class="form-group">
                            <label for="answer" class="form-label">답변 내용</label>
                            <textarea name="answer" id="answer" class="form-textarea" 
                                      placeholder="답변 내용을 입력해주세요" required></textarea>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">첨부파일</label>
                            <input type="file" name="answerAttachments" multiple 
                                   accept=".jpg,.jpeg,.png,.pdf,.doc,.docx,.txt"
                                   style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px;">
                        </div>
                        <div class="action-buttons">
                            <a href="/inquiry/list" class="btn btn-secondary">목록으로</a>
                            <button type="submit" class="btn btn-primary">답변 등록</button>
                        </div>
                    </form>
                </div>
            </c:if>
            
            <!-- 답변 섹션 아래에 항상 목록으로 버튼 노출 -->
            <div class="action-buttons">
                <a href="/inquiry/list" class="btn btn-secondary">목록으로</a>
                <c:if test="${!isAdmin}">
                    <c:if test="${canEdit}">
                        <div class="answer-buttons">
                            <a href="/inquiry/edit?id=${inquiry.id}" class="btn btn-primary">수정</a>
                            <button type="button" class="btn btn-danger" onclick="deleteInquiry()">삭제</button>
                        </div>
                    </c:if>
                    <c:if test="${!canEdit && isOwner}">
                        <small style="color: #999; margin-left: 15px;">답변 완료된 문의사항은 수정/삭제할 수 없습니다.</small>
                    </c:if>
                </c:if>
            </div>
        </div>
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <%@ include file="../layout/scripts.jsp" %>
    
    <script>
        // 최소한의 JavaScript만 유지
        function deleteInquiry() {
            if (confirm('정말로 이 문의사항을 삭제하시겠습니까?')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '/inquiry/delete';
                
                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'id';
                idInput.value = '${inquiry.id}';
                
                form.appendChild(idInput);
                document.body.appendChild(form);
                form.submit();
            }
        }
        
        // 답변 폼 간단한 검증 - 폼이 존재할 때만 실행
        document.addEventListener('DOMContentLoaded', function() {
            const answerForm = document.querySelector('form[action="/inquiry/answer"]');
            if (answerForm) {
                answerForm.addEventListener('submit', function(e) {
                    const answer = document.getElementById('answer');
                    if (answer && !answer.value.trim()) {
                        alert('답변을 입력해주세요.');
                        e.preventDefault();
                    }
                });
            }
        });
    </script>
</body>
</html>