<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<head>
    <title>문의사항 수정</title>
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
            --button-color: #f0f2f5;
        }
        
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Noto Sans KR', sans-serif;
        }
        
        body {
            background-color: #f5f5f7;
        }
        
        /* content와 main-body 스타일은 head-meta.jsp에서 관리 */
        
        .page-header {
            margin-bottom: 20px;
        }
        
        .section-title {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 0;
            color: var(--text-color);
        }
        
        .form-card {
            background-color: white;
            border-radius: 8px;
            padding: 40px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            width: 100%;
            max-width: none;
        }
        
        /* 폼 스타일 */
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-size: 1rem;
            color: var(--text-color);
            font-weight: 500;
        }
        
        .required::after {
            content: " *";
            color: #ff4444;
        }
        
        .form-input, .form-select, .form-textarea {
            width: 100%;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 1rem;
            transition: border-color 0.3s, box-shadow 0.3s;
            background-color: white;
        }
        
        .form-input:focus, .form-select:focus, .form-textarea:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(71, 81, 201, 0.1);
        }
        
        .form-textarea {
            resize: vertical;
            min-height: 150px;
            font-family: inherit;
            line-height: 1.6;
        }
        
        .form-row {
            display: flex;
            gap: 20px;
            margin-bottom: 25px;
        }
        
        .form-col {
            flex: 1;
        }
        
        .checkbox-group {
            display: flex;
            align-items: center;
            margin-bottom: 25px;
            padding: 20px;
            background-color: #f8f9ff;
            border-radius: 8px;
            border: 1px solid #e1e5ff;
        }
        
        .form-checkbox {
            margin-right: 12px;
            width: 20px;
            height: 20px;
            accent-color: var(--primary-color);
        }
        
        .checkbox-label {
            font-size: 1rem;
            color: var(--text-color);
            cursor: pointer;
            display: flex;
            align-items: center;
        }
        
        .priority-badge {
            background-color: var(--accent-color);
            color: white;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.85rem;
            margin-left: 10px;
        }
        
        /* 기존 파일과 새 파일 스타일 통합 */
        .existing-files {
            margin-bottom: 15px;
        }
        
        .file-upload-area {
            border: 2px dashed #ddd;
            border-radius: 8px;
            padding: 40px;
            text-align: center;
            background-color: #fafafa;
            transition: border-color 0.3s;
            cursor: pointer;
            margin-bottom: 10px;
        }
        
        .file-upload-area:hover {
            border-color: var(--primary-color);
            background-color: #f8f9ff;
        }
        
        .file-upload-area.drag-over {
            border-color: var(--primary-color);
            background-color: #f8f9ff;
        }
        
        .file-upload-icon {
            font-size: 2.5rem;
            color: #ccc;
            margin-bottom: 15px;
        }
        
        .file-upload-text {
            color: #666;
            font-size: 1rem;
            font-weight: 500;
            margin-bottom: 5px;
        }
        
        .upload-hint {
            font-size: 0.9rem;
            color: #999;
            margin-top: 10px;
            line-height: 1.4;
        }
        
        .file-list {
            margin-top: 15px;
            text-align: left;
        }
        
        .file-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 15px;
            background-color: #f8f9ff;
            border-radius: 6px;
            margin-bottom: 10px;
            font-size: 0.9rem;
            border: 1px solid #e1e5ff;
            min-height: 45px;
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
            margin-left: 10px;
            min-width: 30px;
            height: 30px;
        }
        
        .remove-file:hover {
            background-color: rgba(255, 68, 68, 0.1);
        }
        
        .action-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 40px;
            padding-top: 30px;
        }
        
        .btn {
            padding: 15px 30px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
            border: none;
            font-size: 1rem;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            min-width: 120px;
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
        
        .btn-primary:disabled {
            background-color: #ccc;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }
        
        .btn-secondary {
            background-color: white;
            color: var(--text-color);
        }
        
        .btn-secondary:hover {
            background-color: #f5f5f5;
        }
        
        .form-section {
            margin-bottom: 40px;
            padding-bottom: 30px;
        }
        
        .form-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }
        
        .section-subtitle {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--text-color);
            margin-bottom: 20px;
            padding-bottom: 10px;
        }
        
        .error-message {
            color: #ff4444;
            font-size: 0.9rem;
            margin-top: 5px;
            display: none;
        }
        
        .form-input.error, .form-select.error, .form-textarea.error {
            border-color: #ff4444;
            box-shadow: 0 0 0 3px rgba(255, 68, 68, 0.1);
        }
        .content, .main-body {
        height: auto !important;
        overflow: visible !important;
        }
    </style>
</head>
<body>
    <!-- 사이드바 -->
    <div class="sidebar">
        <%@ include file="../layout/sidebar.jsp" %>
    </div>

    <!-- 메인 콘텐츠 -->
    <div class="content">
        <%@ include file="../layout/header.jsp" %>
        <div class="main-body">
            <div class="page-header">
                <h2 class="section-title">문의사항 수정</h2>
            </div>
        
        <div class="form-card">
            <form action="/inquiry/edit" method="post" enctype="multipart/form-data" id="inquiryForm">
                <input type="hidden" name="id" value="${inquiry.id}" />
                
                <!-- 기본 정보 섹션 -->
                <div class="form-section">
                    <div class="section-subtitle">기본 정보</div>
                    
                    <div class="form-group">
                        <label for="title" class="form-label required">제목</label>
                        <input type="text" name="title" id="title" class="form-input" 
                               value="${inquiry.title}" placeholder="문의 제목을 입력해주세요" required />
                        <div class="error-message" id="titleError">제목을 입력해주세요.</div>
                    </div>

                    <div class="form-row">
                        <div class="form-col">
                            <label for="category" class="form-label required">카테고리</label>
                            <select name="category" id="category" class="form-select" required>
                                <option value="">카테고리 선택</option>
                                <option value="시스템 문의" ${inquiry.category == '시스템 문의' ? 'selected' : ''}>시스템 문의</option>
                                <option value="기자재 관리" ${inquiry.category == '기자재 관리' ? 'selected' : ''}>기자재 관리</option>
                                <option value="계정/권한" ${inquiry.category == '계정/권한' ? 'selected' : ''}>계정/권한</option>
                                <option value="기타 문의" ${inquiry.category == '기타 문의' ? 'selected' : ''}>기타 문의</option>
                            </select>
                            <div class="error-message" id="categoryError">카테고리를 선택해주세요.</div>
                        </div>
                        
                        <div class="form-col">
                            <label for="contextType" class="form-label">문의 유형</label>
                            <select name="contextType" id="contextType" class="form-select">
                                <option value="GENERAL" ${inquiry.contextType == 'GENERAL' ? 'selected' : ''}>전체</option>
                                <option value="PROJECT" ${inquiry.contextType == 'PROJECT' ? 'selected' : ''}>프로젝트 관련</option>
                                <option value="EQUIPMENT" ${inquiry.contextType == 'EQUIPMENT' ? 'selected' : ''}>장비 관련</option>
                                <option value="ACCOUNT" ${inquiry.contextType == 'ACCOUNT' ? 'selected' : ''}>계정 관련</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- 문의 내용 섹션 -->
                <div class="form-section">
                    <div class="section-subtitle">문의 내용</div>
                    
                    <div class="form-group">
                        <label for="content" class="form-label required">문의 내용</label>
                        <textarea name="content" id="content" class="form-textarea" 
                                  placeholder="문의 내용을 자세히 입력해주세요" required>${inquiry.content}</textarea>
                        <div style="font-size: 0.9rem; color: #666; margin-top: 8px;">최소 10자 이상 입력해주세요.</div>
                        <div class="error-message" id="contentError">문의 내용을 10자 이상 입력해주세요.</div>
                    </div>
                </div>

                <!-- 파일 첨부 섹션 -->
                <div class="form-section">
                    <div class="section-subtitle">첨부 파일</div>
                    
                    <!-- 기존 첨부파일 표시 - 새 파일과 동일한 스타일 -->
                    <c:if test="${not empty attachments}">
                        <div class="existing-files">
                            <label class="form-label">기존 첨부파일</label>
                            <div class="file-list">
                                <c:forEach var="file" items="${attachments}">
                                    <div class="file-item" id="file-${file.id}">
                                        <div class="file-info">
                                            <span class="file-name">${file.originalFileName}</span>
                                            <span class="file-size">(<fmt:formatNumber value="${file.fileSize / 1024}" pattern="#,##0.0"/>KB)</span>
                                        </div>
                                        <button type="button" class="remove-file" data-file-id="${file.id}" onclick="deleteExistingFile($file.id)">×</button>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>
                    
                    <!-- 새 파일 추가 -->
                    <div class="form-group">
                        <label class="form-label">새 파일 추가</label>
                        <div class="file-upload-area" id="fileUploadArea">
                            <div class="file-upload-icon">📎</div>
                            <div class="file-upload-text">파일을 선택하거나 여기로 드래그하세요</div>
                            <div class="upload-hint">
                                지원 형식: JPG, PNG, PDF, DOC, DOCX, TXT (최대 10MB)<br>
                                여러 파일을 동시에 선택할 수 있습니다.
                            </div>
                        </div>
                        <input type="file" id="fileInput" name="attachments" multiple 
                               style="display: none;" accept=".jpg,.jpeg,.png,.gif,.pdf,.doc,.docx,.txt,.xlsx,.xls">
                        <div id="fileList" class="file-list"></div>
                    </div>
                </div>

                <!-- 처리 옵션 섹션 -->
                <div class="form-section">
                    <div class="section-subtitle">처리 옵션</div>
                    
                    <div class="checkbox-group">
                        <input class="form-checkbox" type="checkbox" id="isUrgent" name="urgent" value="true" ${inquiry.urgent ? 'checked' : ''}>
                        <label class="checkbox-label" for="isUrgent">
                            우선 처리 요청
                            <span class="priority-badge">우선</span>
                        </label>
                    </div>
                </div>

                <!-- 삭제할 첨부파일 ID 저장용 -->
                <input type="hidden" id="deleteAttachmentIds" name="deleteAttachmentIds" />

                <div class="action-buttons">
                    <a href="/inquiry/view?id=${inquiry.id}" class="btn btn-secondary">취소</a>
                    <button type="submit" class="btn btn-primary" id="submitBtn">수정 완료</button>
                </div>
            </form>
        </div>
        </div>
        <%@ include file="../layout/footer.jsp" %>
    </div>
    
    <!-- 공통 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const fileUploadArea = document.getElementById('fileUploadArea');
            const fileInput = document.getElementById('fileInput');
            const fileList = document.getElementById('fileList');
            const form = document.getElementById('inquiryForm');
            const submitBtn = document.getElementById('submitBtn');
            
            let selectedFiles = []; // 배열로 단순하게 관리
            let deletedFileIds = []; // 삭제할 파일 ID 저장
            
            // 페이지 로드 시 기존 파일 삭제 버튼에 이벤트 리스너 추가
            document.querySelectorAll('.remove-file[data-file-id]').forEach(function(button) {
                button.addEventListener('click', function() {
                    const fileId = this.getAttribute('data-file-id');
                    if (fileId) {
                        deleteExistingFile(parseInt(fileId));
                    }
                });
            });
            
            // 파일 업로드 영역 클릭 시 파일 선택 창 열기
            fileUploadArea.addEventListener('click', function(e) {
                e.preventDefault();
                fileInput.click();
            });
            
            // 드래그 앤 드롭 이벤트
            fileUploadArea.addEventListener('dragover', function(e) {
                e.preventDefault();
                e.stopPropagation();
                this.classList.add('drag-over');
            });
            
            fileUploadArea.addEventListener('dragleave', function(e) {
                e.preventDefault();
                e.stopPropagation();
                this.classList.remove('drag-over');
            });
            
            fileUploadArea.addEventListener('drop', function(e) {
                e.preventDefault();
                e.stopPropagation();
                this.classList.remove('drag-over');
                
                const files = Array.from(e.dataTransfer.files);
                handleFiles(files);
            });
            
            // 파일 입력 변경 시
            fileInput.addEventListener('change', function(e) {
                const files = Array.from(e.target.files);
                handleFiles(files);
            });
            
            // 파일 처리 함수
            function handleFiles(files) {
                console.log('handleFiles 호출됨, 파일 개수:', files.length);
                
                files.forEach(function(file) {
                    console.log('파일 정보:', file.name, file.size, file.type);
                    
                    // 파일 크기 제한 (10MB)
                    if (file.size > 10 * 1024 * 1024) {
                        alert('파일 "' + file.name + '"이 너무 큽니다. (최대 10MB)');
                        return;
                    }
                    
                    // 중복 파일 체크
                    var isDuplicate = selectedFiles.some(function(existingFile) {
                        return existingFile.name === file.name && existingFile.size === file.size;
                    });
                    
                    if (isDuplicate) {
                        alert('파일 "' + file.name + '"이 이미 선택되어 있습니다.');
                        return;
                    }
                    
                    selectedFiles.push(file);
                });
                
                updateDisplay();
                updateFileInput();
            }
            
            // 화면 표시 업데이트
            function updateDisplay() {
                console.log('updateDisplay 호출됨, 파일 개수:', selectedFiles.length);
                
                if (selectedFiles.length === 0) {
                    fileList.innerHTML = '';
                    fileUploadArea.querySelector('.file-upload-text').textContent = 
                        '파일을 선택하거나 여기로 드래그하세요';
                    fileUploadArea.querySelector('.upload-hint').innerHTML = 
                        '지원 형식: JPG, PNG, PDF, DOC, DOCX, TXT (최대 10MB)<br>여러 파일을 동시에 선택할 수 있습니다.';
                    return;
                }
                
                // 파일이 선택된 경우 업로드 영역 텍스트 변경
                fileUploadArea.querySelector('.file-upload-text').textContent = 
                    '새로 선택된 파일 (' + selectedFiles.length + '개)';
                fileUploadArea.querySelector('.upload-hint').textContent = 
                    '파일을 추가하려면 클릭하거나 드래그하세요.';
                
                // 선택된 파일 목록을 표시
                var html = '';
                selectedFiles.forEach(function(file, index) {
                    console.log('파일 처리중:', file.name, file.size);
                    
                    var fileName = file.name || '알 수 없는 파일';
                    var fileSize = '';
                    
                    if (file.size > 1024 * 1024) {
                        fileSize = (file.size / (1024 * 1024)).toFixed(1) + 'MB';
                    } else {
                        fileSize = (file.size / 1024).toFixed(1) + 'KB';
                    }
                    
                    html += '<div class="file-item" data-index="' + index + '">' +
                                '<div class="file-info">' +
                                    '<span class="file-name">' + fileName + '</span>' +
                                    '<span class="file-size">(' + fileSize + ')</span>' +
                                '</div>' +
                                '<button type="button" class="remove-file" onclick="removeFileAt(' + index + ')">×</button>' +
                            '</div>';
                });
                
                fileList.innerHTML = html;
            }
            
            // 파일 제거 함수 (전역으로)
            window.removeFileAt = function(index) {
                selectedFiles.splice(index, 1);
                updateDisplay();
                updateFileInput();
            };
            
            // 기존 파일 삭제 함수
            function deleteExistingFile(fileId) {
                console.log('deleteExistingFile 함수 호출됨, fileId:', fileId);
                if (confirm('이 파일을 삭제하시겠습니까?')) {
                    deletedFileIds.push(fileId);
                    
                    // 화면에서 즉시 제거
                    const fileElement = document.getElementById('file-' + fileId);
                    if (fileElement) {
                        fileElement.style.display = 'none';
                        console.log('파일 요소 숨김 처리 완료:', fileId);
                    } else {
                        console.error('파일 요소를 찾을 수 없음:', 'file-' + fileId);
                    }
                    
                    // hidden input에 삭제할 파일 ID들 설정
                    document.getElementById('deleteAttachmentIds').value = deletedFileIds.join(',');
                    console.log('삭제할 파일 ID 목록:', deletedFileIds);
                }
            }
            
            // 전역 함수로도 등록
            window.deleteExistingFile = deleteExistingFile;
            
            // input 요소의 files 업데이트
            function updateFileInput() {
                const dt = new DataTransfer();
                selectedFiles.forEach(function(file) {
                    dt.items.add(file);
                });
                fileInput.files = dt.files;
            }
            
            // 폼 유효성 검사 함수들
            function validateField(fieldId, errorId, condition, errorMessage) {
                const field = document.getElementById(fieldId);
                const error = document.getElementById(errorId);
                
                if (!condition) {
                    field.classList.add('error');
                    error.style.display = 'block';
                    error.textContent = errorMessage;
                    return false;
                } else {
                    field.classList.remove('error');
                    error.style.display = 'none';
                    return true;
                }
            }
            
            // 실시간 유효성 검사
            document.getElementById('title').addEventListener('blur', function() {
                validateField('title', 'titleError', this.value.trim().length > 0, '제목을 입력해주세요.');
            });
            
            document.getElementById('category').addEventListener('change', function() {
                validateField('category', 'categoryError', this.value !== '', '카테고리를 선택해주세요.');
            });
            
            document.getElementById('content').addEventListener('blur', function() {
                validateField('content', 'contentError', this.value.trim().length >= 10, '문의 내용을 10자 이상 입력해주세요.');
            });
            
            // 폼 제출 시 유효성 검사
            form.addEventListener('submit', function(e) {
                const title = document.getElementById('title').value.trim();
                const content = document.getElementById('content').value.trim();
                const category = document.getElementById('category').value;
                
                let isValid = true;
                
                if (!validateField('title', 'titleError', title.length > 0, '제목을 입력해주세요.')) {
                    isValid = false;
                }
                
                if (!validateField('category', 'categoryError', category !== '', '카테고리를 선택해주세요.')) {
                    isValid = false;
                }
                
                if (!validateField('content', 'contentError', content.length >= 10, '문의 내용을 10자 이상 입력해주세요.')) {
                    isValid = false;
                }
                
                if (!isValid) {
                    e.preventDefault();
                    // 첫 번째 오류 필드로 스크롤
                    const firstError = document.querySelector('.form-input.error, .form-select.error, .form-textarea.error');
                    if (firstError) {
                        firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                        firstError.focus();
                    }
                    return;
                }
                
                // 파일 크기 재검사
                for (var i = 0; i < selectedFiles.length; i++) {
                    var file = selectedFiles[i];
                    if (file.size > 10 * 1024 * 1024) {
                        alert('파일 "' + file.name + '"이 너무 큽니다. (최대 10MB)');
                        e.preventDefault();
                        return;
                    }
                }
                
                // 로딩 상태 표시
                submitBtn.textContent = '수정 중...';
                submitBtn.disabled = true;
            });
        });
    </script>
</body>
</html>