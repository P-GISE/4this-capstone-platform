<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<head>
    <title>아카이브 등록</title>
    <style>
        .write-container {
            max-width: 800px;
            margin: 0 auto;
        }
        
        .write-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        
        .write-title {
            font-size: 1.5rem;
            font-weight: bold;
            color: #333;
        }
        
        .back-btn {
            background-color: #6c757d;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            text-decoration: none;
            font-size: 0.9rem;
        }
        
        .back-btn:hover {
            background-color: #5a6268;
        }
        
        .form-card {
            background-color: white;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            margin-bottom: 20px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #333;
        }
        
        .form-label.required::after {
            content: " *";
            color: #e74c3c;
        }
        
        .form-input,
        .form-select,
        .form-textarea {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.9rem;
            box-sizing: border-box;
        }
        
        .form-input:focus,
        .form-select:focus,
        .form-textarea:focus {
            outline: none;
            border-color: #4751c9;
            box-shadow: 0 0 0 3px rgba(71, 81, 201, 0.1);
        }
        
        .form-textarea {
            resize: vertical;
            min-height: 120px;
            line-height: 1.5;
        }
        
        .form-row {
            display: flex;
            gap: 20px;
        }
        
        .form-row .form-group {
            flex: 1;
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        
        .btn {
            padding: 12px 24px;
            border-radius: 6px;
            font-weight: 500;
            border: none;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background-color: #4751c9;
            color: white;
        }
        
        .btn-primary:hover {
            background-color: #3a47b8;
        }
        
        .btn-outline {
            background-color: white;
            border: 1px solid #ddd;
            color: #333;
        }
        
        .btn-outline:hover {
            background-color: #f8f9fa;
        }
        
        .help-text {
            font-size: 0.8rem;
            color: #666;
            margin-top: 5px;
        }
        
        .radio-group {
            display: flex;
            gap: 20px;
            margin-top: 10px;
        }
        
        .radio-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .checkbox-item {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 10px;
        }
        
        .existing-files {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .file-item {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .file-info {
            display: flex;
            flex-direction: column;
        }
        
        .file-name {
            font-size: 0.9rem;
            font-weight: 500;
            color: #333;
        }
        
        .file-size {
            font-size: 0.8rem;
            color: #666;
        }
        
        .file-actions {
            display: flex;
            gap: 10px;
        }
        
        .preview-btn {
            background-color: #4751c9;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .preview-btn:hover {
            background-color: #3a47b8;
        }
        
        .download-btn {
            background-color: white;
            color: #333;
            padding: 8px 16px;
            border: 1px solid #ddd;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .download-btn:hover {
            background-color: #f8f9fa;
        }

        .remove-file {
            background: none;
            border: none;
            color: #ff4444;
            cursor: pointer;
            font-size: 16px;
            padding: 5px 8px;
            border-radius: 3px;
            transition: background-color 0.2s;
            min-width: 30px;
            height: 30px;
        }
        
        .remove-file:hover {
            background-color: rgba(255, 68, 68, 0.1);
        }

        /* 미리보기 모달 스타일 */
        .preview-modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.8);
        }

        .preview-modal-content {
            position: relative;
            margin: 5% auto;
            padding: 0;
            width: 80%;
            max-width: 800px;
            max-height: 80vh;
            background-color: transparent;
        }

        .preview-close {
            position: absolute;
            top: -40px;
            right: 0;
            color: white;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            z-index: 1001;
        }

        .preview-close:hover {
            color: #ccc;
        }

        .preview-media {
            width: 100%;
            height: auto;
            max-height: 80vh;
            object-fit: contain;
            border-radius: 8px;
        }

        .preview-video {
            width: 100%;
            height: auto;
            max-height: 80vh;
            border-radius: 8px;
        }
    </style>
</head>
<body>
    <!-- 사이드바 -->
    <div class="sidebar">
        <%@ include file="../layout/sidebar.jsp" %>
    </div>

    <div class="content">
        <%@ include file="../layout/header.jsp" %>
        <div class="main-body">
            <div class="write-container">
                <div class="write-header">
                    <h2 class="write-title">📁 아카이브 수정</h2>
                    <a href="/archive/list" class="back-btn">← 목록으로</a>
                </div>

                <div class="form-card">
                    <form action="/archive/edit" method="post" id="archiveForm">
                        <!-- 📌 수정용 ID 필드 -->
                        <input type="hidden" name="id" value="${archive.id}" />

                        <div class="form-row">
                            <div class="form-group">
                                <label for="title" class="form-label required">제목</label>
                                <input type="text" id="title" name="title" class="form-input" required
                                    value="${archive.title}" placeholder="아카이브 제목을 입력하세요">
                            </div>
                            <div class="form-group">
                                <label for="version" class="form-label">버전</label>
                                <input type="text" id="version" name="version" class="form-input"
                                    value="${archive.version}" placeholder="v1.0">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="description" class="form-label required">설명</label>
                            <textarea id="description" name="description" class="form-textarea" required
                                    placeholder="프로젝트 설명">${archive.description}</textarea>
                            <div class="help-text">최소 50자 이상 작성해주세요.</div>
                        </div>

                        <div class="form-group">
                            <label for="submittedByName" class="form-label">작성자 이름</label>
                            <input type="text" id="submittedByName" name="submittedByName" class="form-input"
                                value="${archive.submittedByName}" placeholder="입력 안 하면 로그인한 이름이 자동 입력됩니다.">
                        </div>

                        <div class="form-row">
                            <div class="form-group">
                                <label for="category" class="form-label required">카테고리</label>
                                <select id="category" name="category" class="form-select" required>
                                    <option value="">카테고리 선택</option>
                                    <option value="IoT" <c:if test="${archive.category == 'IoT'}">selected</c:if>>IoT</option>
                                    <option value="AI/머신러닝" <c:if test="${archive.category == 'AI/머신러닝'}">selected</c:if>>AI/머신러닝</option>
                                    <option value="웹개발" <c:if test="${archive.category == '웹개발'}">selected</c:if>>웹개발</option>
                                    <option value="모바일" <c:if test="${archive.category == '모바일'}">selected</c:if>>모바일</option>
                                    <option value="로봇" <c:if test="${archive.category == '로봇'}">selected</c:if>>로봇</option>
                                    <option value="기타" <c:if test="${archive.category == '기타'}">selected</c:if>>기타</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label class="form-label">공개 설정</label>
                                <div class="radio-group">
                                    <label class="radio-item">
                                        <input type="radio" name="isPublic" value="true" <c:if test="${archive.isPublic}">checked</c:if>>
                                        <span>전체 공개</span>
                                    </label>
                                    <label class="radio-item">
                                        <input type="radio" name="isPublic" value="false" <c:if test="${!archive.isPublic}">checked</c:if>>
                                        <span>비공개</span>
                                    </label>
                                </div>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="projectId" class="form-label">연결된 프로젝트</label>
                            <select id="projectId" name="projectId" class="form-select">
                                <option value="">선택 안 함</option>
                                <c:forEach var="project" items="${projectList}">
                                    <option value="${project.id}" <c:if test="${archive.projectId == project.id}">selected</c:if>>
                                        ${project.title}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="checkbox-item">
                                <input type="checkbox" name="isSubmitted" value="true"
                                    <c:if test="${archive.isSubmitted}">checked</c:if>>
                                <span>최종 제출 (관리자 승인 요청)</span>
                            </label>
                            <div class="help-text">체크시 관리자의 승인을 받아야 공개됩니다.</div>
                        </div>

                        <!-- 기존 첨부파일 섹션 -->
                        <c:if test="${not empty files}">
                            <div class="form-group">
                                <label class="form-label">기존 첨부파일</label>
                                <div class="existing-files">
                                    <c:forEach var="file" items="${files}">
                                        <div class="file-item" id="file-${file.id}">
                                            <div class="file-info">
                                                <span class="file-name">${file.originalFileName}</span>
                                                <span class="file-size">
                                                    <c:choose>
                                                        <c:when test="${file.fileSize > 1024 * 1024}">
                                                            <fmt:formatNumber value="${file.fileSize / (1024 * 1024)}" maxFractionDigits="1" />MB
                                                        </c:when>
                                                        <c:when test="${file.fileSize > 1024}">
                                                            <fmt:formatNumber value="${file.fileSize / 1024}" maxFractionDigits="1" />KB
                                                        </c:when>
                                                        <c:otherwise>
                                                            ${file.fileSize}B
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            <div class="file-actions">
                                                <c:if test="${fn:contains(file.fileType, 'image') || fn:contains(file.fileType, 'video')}">
                                                    <button type="button" class="preview-btn" onclick="previewFile('${file.fileName}', '${file.originalFileName}', '${file.fileType}')">
                                                        미리보기
                                                    </button>
                                                </c:if>
                                                <button type="button" class="remove-file" data-file-id="${file.id}">×</button>
                                                <input type="hidden" name="deleteFileIds" value="${file.id}" disabled>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>

                        <div class="form-actions">
                            <a href="/archive/detail/${archive.id}" class="btn btn-outline">취소</a>
                            <button type="submit" class="btn btn-primary">수정하기</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 미리보기 모달 -->
    <div id="previewModal" class="preview-modal">
        <div class="preview-modal-content">
            <span class="preview-close" onclick="closePreviewModal()">&times;</span>
            <div id="previewContent"></div>
        </div>
    </div>

    <!-- 공통 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>
    
    <script>
        // 기존 첨부파일 삭제 버튼 처리
        document.addEventListener('DOMContentLoaded', function() {
            console.log('DOM 로드 완료, 삭제 버튼 이벤트 리스너 설정 시작');
            
            const deleteButtons = document.querySelectorAll('.remove-file[data-file-id]');
            console.log('찾은 삭제 버튼 개수:', deleteButtons.length);
            
            deleteButtons.forEach(function(btn, index) {
                const fileId = btn.getAttribute('data-file-id');
                console.log('삭제 버튼 설정:', index, 'fileId:', fileId);
                
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    console.log('삭제 버튼 클릭됨, fileId:', fileId);
                    deleteExistingFile(parseInt(fileId));
                });
            });
        });
        
        // 기존 파일 삭제 함수
        function deleteExistingFile(fileId) {
            console.log('deleteExistingFile 함수 호출됨, fileId:', fileId);
            if (confirm('이 파일을 삭제하시겠습니까?')) {
                const fileElement = document.getElementById('file-' + fileId);
                if (fileElement) {
                    const hiddenInput = fileElement.querySelector('input[type="hidden"]');
                    if (hiddenInput) {
                        hiddenInput.disabled = false; // 삭제 처리용 hidden input 활성화
                        console.log('hidden input 활성화됨, value:', hiddenInput.value);
                    }
                    fileElement.style.display = 'none';
                    console.log('파일 요소 숨김 처리 완료:', fileId);
                } else {
                    console.error('파일 요소를 찾을 수 없음:', 'file-' + fileId);
                }
            }
        }

        // 폼 유효성 검사
        document.getElementById('archiveForm').addEventListener('submit', function(e) {
            const title = document.getElementById('title').value.trim();
            const description = document.getElementById('description').value.trim();
            const category = document.getElementById('category').value;
            
            if (!title) {
                alert('제목을 입력해주세요.');
                e.preventDefault();
                return;
            }
            
            if (!description || description.length < 50) {
                alert('설명을 50자 이상 입력해주세요.');
                e.preventDefault();
                return;
            }
            
            if (!category) {
                alert('카테고리를 선택해주세요.');
                e.preventDefault();
                return;
            }
            
            // 삭제된 파일 ID들 확인
            const deleteFileInputs = document.querySelectorAll('input[name="deleteFileIds"]:not([disabled])');
            console.log('폼 제출 - 삭제할 파일 개수:', deleteFileInputs.length);
            deleteFileInputs.forEach(function(input, index) {
                console.log('삭제할 파일 ID', index + 1, ':', input.value);
            });
            
            // 폼 제출 전 카테고리 값 확인 (디버깅용)
            console.log('선택된 카테고리:', category);
        });
        
        // 설명 글자수 체크
        document.getElementById('description').addEventListener('input', function() {
            const length = this.value.length;
            const helpText = this.nextElementSibling;
            
            if (length < 50) {
                helpText.style.color = '#e74c3c';
                helpText.textContent = `최소 50자 이상 작성해주세요. (현재 ${length}자)`;
            } else {
                helpText.style.color = '#27ae60';
                helpText.textContent = `${length}자 입력됨`;
            }
        });
        
        // 카테고리 선택 이벤트 (디버깅용)
        document.getElementById('category').addEventListener('change', function() {
            console.log('카테고리 변경됨:', this.value);
        });

        // 파일 미리보기 함수
        function previewFile(fileName, originalFileName, fileType) {
            const modal = document.getElementById('previewModal');
            const content = document.getElementById('previewContent');
            const contextPath = '${pageContext.request.contextPath}';
            
            if (fileType.startsWith('image/')) {
                // 이미지 미리보기
                content.innerHTML = '<img src="' + contextPath + '/archive/download?file=' + fileName + '&original=' + originalFileName + '" class="preview-media" alt="' + originalFileName + '">';
                modal.style.display = 'block';
            } else if (fileType.startsWith('video/')) {
                // 비디오 미리보기
                content.innerHTML = '<video controls class="preview-video"><source src="' + contextPath + '/archive/download?file=' + fileName + '&original=' + originalFileName + '" type="' + fileType + '">브라우저가 비디오를 지원하지 않습니다.</video>';
                modal.style.display = 'block';
            }
        }
        
        // 미리보기 모달 닫기
        function closePreviewModal() {
            document.getElementById('previewModal').style.display = 'none';
            document.getElementById('previewContent').innerHTML = '';
        }

        // 모달 외부 클릭시 닫기
        window.onclick = function(event) {
            const previewModal = document.getElementById('previewModal');
            if (event.target == previewModal) {
                closePreviewModal();
            }
        }
    </script>
</body>
</html>