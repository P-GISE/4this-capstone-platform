<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<head>
    <title>문의사항 작성</title>
    <style>
        :root {
            --primary-color: #2563eb;
            --primary-dark: #1d4ed8;
            --primary-light: #eff6ff;
            --secondary-color: #f1f5f9;
            --dark-color: #1e293b;
            --light-color: #ffffff;
            --accent-color: #64748b;
            --grey-color: #f8fafc;
            --text-color: #334155;
            --text-light: #64748b;
            --text-muted: #94a3b8;
            --border-color: #e2e8f0;
            --border-light: #f1f5f9;
            --success-color: #059669;
            --warning-color: #d97706;
            --error-color: #dc2626;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            --radius-sm: 4px;
            --radius-md: 6px;
            --radius-lg: 8px;
            --transition: all 0.2s ease-in-out;
        }
        
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans KR', sans-serif;
            background-color: var(--grey-color);
            color: var(--text-color);
            line-height: 1.6;
        }
        
        /* content와 main-body 스타일은 head-meta.jsp에서 관리 */
        
        .page-header {
            margin-bottom: 28px;
        }
        
        .section-title {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 8px;
            color: var(--dark-color);
            letter-spacing: -0.025em;
        }
        
        .form-card {
            background-color: var(--light-color);
            border-radius: var(--radius-lg);
            padding: 32px;
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--border-light);
            width: 100%;
            max-width: none;
        }
        
        /* 폼 스타일 */
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-size: 1rem;
            color: var(--text-color);
            font-weight: 600;
            letter-spacing: 0.025em;
        }
        
        .required::after {
            content: " *";
            color: var(--error-color);
        }
        
        .form-input, .form-select, .form-textarea {
            width: 100%;
            padding: 14px 16px;
            border: 1.5px solid var(--border-color);
            border-radius: var(--radius-md);
            font-size: 1rem;
            transition: var(--transition);
            background-color: var(--light-color);
            font-family: inherit;
            color: var(--text-color);
        }
        
        .form-input:focus, .form-select:focus, .form-textarea:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
            background-color: var(--light-color);
        }
        
        .form-input:hover, .form-select:hover, .form-textarea:hover {
            border-color: var(--text-light);
        }
        
        .form-textarea {
            resize: vertical;
            min-height: 120px;
            line-height: 1.6;
        }
        
        .form-row {
            display: flex;
            gap: 16px;
            margin-bottom: 20px;
        }
        
        .form-col {
            flex: 1;
        }
        
        .checkbox-group {
            display: flex;
            align-items: center;
            margin-bottom: 24px;
            padding: 20px 24px;
            background-color: var(--primary-light);
            border-radius: var(--radius-md);
            border: 1px solid var(--border-color);
            transition: var(--transition);
        }
        
        .checkbox-group:hover {
            border-color: var(--primary-color);
            box-shadow: var(--shadow-sm);
        }
        
        .form-checkbox {
            margin-right: 12px;
            width: 18px;
            height: 18px;
            accent-color: var(--primary-color);
            border-radius: 4px;
        }
        
        .checkbox-label {
            font-size: 1rem;
            color: var(--text-color);
            cursor: pointer;
            display: flex;
            align-items: center;
            font-weight: 500;
        }
        
        .priority-badge {
            background-color: var(--warning-color);
            color: white;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 600;
            margin-left: 12px;
            letter-spacing: 0.025em;
        }
        
        .file-upload-area {
            border: 2px dashed var(--border-color);
            border-radius: var(--radius-md);
            padding: 48px 32px;
            text-align: center;
            background-color: var(--grey-color);
            transition: var(--transition);
            cursor: pointer;
            margin-bottom: 16px;
        }
        
        .file-upload-area:hover {
            border-color: var(--primary-color);
            background-color: var(--primary-light);
            transform: translateY(-1px);
            box-shadow: var(--shadow-sm);
        }
        
        .file-upload-area.drag-over {
            border-color: var(--primary-color);
            background-color: var(--primary-light);
            transform: translateY(-1px);
            box-shadow: var(--shadow-sm);
        }
        
        .file-upload-icon {
            font-size: 2.5rem;
            margin-bottom: 16px;
            opacity: 0.6;
        }
        
        .file-upload-text {
            color: var(--text-color);
            font-size: 1.125rem;
            font-weight: 600;
            margin-bottom: 8px;
        }
        
        .upload-hint {
            font-size: 1rem;
            color: var(--text-muted);
            margin-top: 8px;
            line-height: 1.5;
        }
        
        .file-list {
            margin-top: 16px;
            text-align: left;
        }
        
        .file-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 18px 20px;
            background-color: var(--grey-color);
            border-radius: var(--radius-md);
            margin-bottom: 12px;
            font-size: 1rem;
            border: 1px solid var(--border-light);
            min-height: 54px;
            transition: var(--transition);
        }
        
        .file-item:hover {
            box-shadow: var(--shadow-sm);
            border-color: var(--border-color);
        }
        
        .file-info {
            display: flex;
            align-items: center;
            flex: 1;
            min-width: 0;
        }
        
        .file-name {
            font-weight: 600;
            margin-right: 12px;
            color: var(--text-color);
            word-break: break-word;
            max-width: 300px;
        }
        
        .file-size {
            color: var(--text-muted);
            font-size: 0.875rem;
            white-space: nowrap;
            background-color: var(--border-light);
            padding: 4px 10px;
            border-radius: 12px;
        }
        
        .remove-file {
            background: none;
            border: none;
            color: var(--text-muted);
            cursor: pointer;
            font-size: 18px;
            padding: 8px;
            border-radius: 50%;
            transition: var(--transition);
            margin-left: 12px;
            min-width: 32px;
            height: 32px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .remove-file:hover {
            background-color: var(--error-color);
            color: white;
            transform: scale(1.1);
        }
        
        .action-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 16px;
            margin-top: 48px;
            padding-top: 32px;
            border-top: 1px solid var(--border-light);
        }
        
        .btn {
            padding: 14px 36px;
            border-radius: var(--radius-md);
            cursor: pointer;
            font-weight: 600;
            border: none;
            font-size: 1rem;
            transition: var(--transition);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 130px;
            letter-spacing: 0.025em;
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            color: white;
            box-shadow: var(--shadow-sm);
        }
        
        .btn-primary:hover {
            background-color: var(--primary-dark);
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
        }
        
        .btn-primary:active {
            transform: translateY(0);
        }
        
        .btn-primary:disabled {
            background: var(--text-muted);
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }
        
        .btn-secondary {
            background-color: var(--light-color);
            border: 1.5px solid var(--border-color);
            color: var(--text-color);
        }
        
        .btn-secondary:hover {
            background-color: var(--border-light);
            border-color: var(--text-light);
            transform: translateY(-1px);
            box-shadow: var(--shadow-sm);
        }
        
        .form-section {
            margin-bottom: 40px;
            padding-bottom: 32px;
            border-bottom: 1px solid var(--border-light);
        }
        
        .form-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }
        
        .section-subtitle {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--dark-color);
            margin-bottom: 24px;
            padding-bottom: 8px;
            border-bottom: 2px solid var(--primary-color);
            display: inline-block;
            letter-spacing: -0.025em;
        }
        
        .error-message {
            color: var(--error-color);
            font-size: 1rem;
            margin-top: 8px;
            display: none;
            font-weight: 500;
        }
        
        .form-input.error, .form-select.error, .form-textarea.error {
            border-color: var(--error-color);
            box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.1);
        }
        
        /* 반응형 개선 */
        @media (max-width: 768px) {
            .content {
                padding: 16px;
            }
            
            .form-card {
                padding: 32px 24px;
            }
            
            .form-row {
                flex-direction: column;
                gap: 16px;
            }
            
            .action-buttons {
                flex-direction: column;
                gap: 12px;
            }
            
            .btn {
                width: 100%;
            }
        }
        
        /* 부드러운 스크롤 */
        html {
            scroll-behavior: smooth;
        }
        
        /* 포커스 개선 */
        .form-input:focus, .form-select:focus, .form-textarea:focus {
            outline: 2px solid transparent;
            outline-offset: 2px;
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
                <h2 class="section-title">문의사항 작성</h2>
            </div>
        
            <div class="form-card">
                <form action="/inquiry/write" method="post" enctype="multipart/form-data" id="inquiryForm">
                    
                    <!-- 기본 정보 섹션 -->
                    <div class="form-section">
                        <div class="section-subtitle">기본 정보</div>
                        
                        <div class="form-group">
                            <label for="title" class="form-label required">제목</label>
                            <input type="text" name="title" id="title" class="form-input" 
                                placeholder="문의 제목을 입력해주세요" required />
                            <div class="error-message" id="titleError">제목을 입력해주세요.</div>
                        </div>

                        <div class="form-row">
                            <div class="form-col">
                                <label for="category" class="form-label required">카테고리</label>
                                <select name="category" id="category" class="form-select" required>
                                    <option value="">카테고리 선택</option>
                                    <option value="시스템 문의">시스템 문의</option>
                                    <option value="기자재 관리">기자재 관리</option>
                                    <option value="계정/권한">계정/권한</option>
                                    <option value="기타 문의">기타 문의</option>
                                </select>
                                <div class="error-message" id="categoryError">카테고리를 선택해주세요.</div>
                            </div>
                            
                            <div class="form-col">
                                <label for="contextType" class="form-label">문의 유형</label>
                                <select name="contextType" id="contextType" class="form-select">
                                    <option value="GENERAL">전체</option>
                                    <option value="PROJECT">프로젝트 관련</option>
                                    <option value="EQUIPMENT">장비 관련</option>
                                    <option value="ACCOUNT">계정 관련</option>
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
                                    placeholder="문의 내용을 자세히 입력해주세요" required></textarea>
                            <div style="font-size: 0.9rem; color: #666; margin-top: 8px;">최소 10자 이상 입력해주세요.</div>
                            <div class="error-message" id="contentError">문의 내용을 10자 이상 입력해주세요.</div>
                        </div>
                    </div>

                    <!-- 파일 첨부 섹션 -->
                    <div class="form-section">
                        <div class="section-subtitle">첨부 파일</div>
                        
                        <div class="form-group">
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
                            <input class="form-checkbox" type="checkbox" id="isUrgent" name="urgent" value="true">
                            <label class="checkbox-label" for="isUrgent">
                                우선 처리 요청
                                <span class="priority-badge">우선</span>
                            </label>
                        </div>
                    </div>

                    <div class="action-buttons">
                        <a href="/inquiry/list" class="btn btn-secondary">취소</a>
                        <button type="submit" class="btn btn-primary" id="submitBtn">문의사항 등록</button>
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
                    '선택된 파일 (' + selectedFiles.length + '개)';
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
                submitBtn.textContent = '등록 중...';
                submitBtn.disabled = true;
            });
        });
    </script>
</body>
</html>