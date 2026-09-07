<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<head>
    <style>
        :root {
            --primary-color: #4751c9;
            --secondary-color: #e9eaff;
            --dark-color: #1e1e1e;
            --light-color: #ffffff;
            --accent-color: #ff7043;
            --grey-color: #ffffff;
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
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f8f9fa;
            color: #2d3748;
            line-height: 1.6;
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
        
        .write-card {
            background-color: white;
            border-radius: 8px;
            padding: 40px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            width: 100%;
            border: 1px solid #f0f0f0;
            margin-bottom: 20px;
        }
        
        .form-group {
            margin-bottom: 25px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-size: 1rem;
            font-weight: 500;
            color: var(--text-color);
        }
        
        .required {
            color: #ff4757;
        }
        
        .form-control {
            width: 100%;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 1rem;
            transition: border-color 0.3s, box-shadow 0.3s;
            background-color: white;
        }
        
        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(71, 81, 201, 0.1);
        }
        
        .form-control.textarea {
            resize: vertical;
            min-height: 300px;
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
        
        .form-col-half {
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
        
        .checkbox-input {
            width: 20px;
            height: 20px;
            margin-right: 12px;
            accent-color: var(--primary-color);
        }
        
        .checkbox-label {
            margin: 0;
            font-size: 1rem;
            color: var(--text-color);
            cursor: pointer;
        }
        
        .button-group {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            margin-top: 40px;
            padding-top: 30px;
            border-top: 1px solid var(--border-color);
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
        
        .btn-secondary {
            background-color: white;
            border: 1px solid #ddd;
            color: var(--text-color);
        }
        
        .btn-secondary:hover {
            background-color: #f5f5f5;
        }
        
        .form-help {
            font-size: 0.9rem;
            color: #999;
            margin-top: 8px;
        }
        
        .form-section {
            margin-bottom: 40px;
            padding-bottom: 30px;
            border-bottom: 1px solid #f0f0f0;
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
            border-bottom: 2px solid var(--light-purple);
        }
        
        /* 파일 업로드 스타일 */
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
        
        .file-info {
            display: flex;
            align-items: center;
            flex: 1;
            min-width: 0;
        }
        
        .file-name {
            font-weight: 500;
            margin-right: 10px;
            color: #333;
            word-break: break-word;
            max-width: 300px;
        }
        
        .file-size {
            color: #666;
            font-size: 0.85rem;
            white-space: nowrap;
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
        
        .alert {
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 0.9rem;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .content, .main-body {
            height: auto !important;
            overflow: visible !important;
        }
        
        /* 푸터 스타일 - 상세보기와 동일하게 */
        .footer {
            background-color: #ffffff;
            color: #666;
            text-align: center;
            padding: 20px;
            border-top: 1px solid #ddd;
            font-size: 14px;
        }

        /* 반응형 */
        @media (max-width: 768px) {
            .content {
                margin-left: 0;
                width: 100%;
                padding: 15px;
            }
            
            .sidebar {
                transform: translateX(-100%);
                transition: transform 0.3s ease;
            }
            
            .sidebar.open {
                transform: translateX(0);
            }
            
            .write-card {
                padding: 30px 20px;
            }
            
            .form-row {
                flex-direction: column;
                gap: 0;
            }
            
            .btn {
                padding: 12px 20px;
                min-width: 100px;
            }
            
            .button-group {
                flex-direction: column;
                gap: 10px;
            }
            
            .btn {
                width: 100%;
            }
        }
        
        @media (max-width: 480px) {
            .content {
                padding: 10px;
            }
            
            .write-card {
                padding: 20px 15px;
            }
            
            .section-title {
                font-size: 1.3rem;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../layout/sidebar.jsp" %>

    <div class="content">
        <%@ include file="../layout/header.jsp" %>
        <div class="main-body">
            <div class="page-header">
                <h2 class="section-title">공지사항 작성</h2>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">${errorMessage}</div>
            </c:if>
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">${successMessage}</div>
            </c:if>

            <div class="write-card">
                <form id="noticeForm" action="/notice/write" method="post" enctype="multipart/form-data">
                    
                    <!-- 기본 정보 섹션 -->
                    <div class="form-section">
                        <div class="section-subtitle">기본 정보</div>
                        
                        <!-- 제목 -->
                        <div class="form-group">
                            <label class="form-label">제목 <span class="required">*</span></label>
                            <input type="text" name="title" class="form-control" placeholder="공지사항 제목을 입력해주세요" required />
                        </div>

                        <!-- 카테고리와 공지 대상 -->
                        <div class="form-row">
                            <div class="form-col-half">
                                <div class="form-group">
                                    <label class="form-label">카테고리</label>
                                    <select name="category" class="form-control">
                                        <option value="">카테고리 선택</option>
                                        <option value="일반">일반</option>
                                        <option value="학사">학사</option>
                                        <option value="취업">취업</option>
                                        <option value="행사">행사</option>
                                        <option value="시설">시설</option>
                                        <option value="기타">기타</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-col-half">
                                <div class="form-group">
                                    <label class="form-label">공지 대상 <span class="required">*</span></label>
                                    <select name="targetRole" class="form-control" required>
                                        <option value="ALL">전체</option>
                                        <option value="STUDENT">학생</option>
                                        <option value="ASSISTANT">조교</option>
                                        <option value="PROFESSOR">교수</option>
                                        <option value="STAFF">교직원</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 공지 내용 섹션 -->
                    <div class="form-section">
                        <div class="section-subtitle">공지 내용</div>
                        
                        <!-- 내용 -->
                        <div class="form-group">
                            <label class="form-label">내용 <span class="required">*</span></label>
                            <textarea name="content" class="form-control textarea" placeholder="공지사항 내용을 자세히 입력해주세요" required></textarea>
                            <div class="form-help">최소 10자 이상 입력해주세요.</div>
                        </div>
                    </div>

                    <!-- 파일 첨부 섹션 -->
                    <div class="form-section">
                        <div class="section-subtitle">첨부 파일</div>
                        
                        <!-- 첨부파일 -->
                        <div class="form-group">
                            <div class="file-upload-area" id="fileUploadArea">
                                <div class="file-upload-icon">📎</div>
                                <div class="file-upload-text">파일을 선택하거나 여기로 드래그하세요</div>
                                <div class="upload-hint">
                                    지원 형식: JPG, PNG, PDF, DOC, DOCX, HWP (최대 10MB)<br>
                                    여러 파일을 동시에 선택할 수 있습니다.
                                </div>
                            </div>
                            <input type="file" id="attachFile" name="attachFile" class="form-control" multiple
                                   style="display: none;" accept=".jpg,.jpeg,.png,.pdf,.doc,.docx,.hwp">
                            <div id="fileList" class="file-list"></div>
                        </div>
                    </div>

                    <!-- 공지 옵션 섹션 -->
                    <div class="form-section">
                        <div class="section-subtitle">공지 옵션</div>
                        
                        <!-- 공지 옵션 -->
                        <div class="checkbox-group">
                            <input type="checkbox" id="important" name="important" value="true" class="checkbox-input">
                            <label for="important" class="checkbox-label">중요 공지로 설정</label>
                        </div>
                    </div>

                    <!-- 버튼 -->
                    <div class="button-group">
                        <a href="/notice/list" class="btn btn-secondary">취소</a>
                        <button type="submit" class="btn btn-primary">공지 등록</button>
                    </div>
                </form>
            </div>
        </div>
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <%@ include file="../layout/scripts.jsp" %>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const fileUploadArea = document.getElementById('fileUploadArea');
            const fileInput = document.getElementById('attachFile');
            const fileList = document.getElementById('fileList');
            
            let selectedFiles = [];
            
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
                files.forEach(function(file) {
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
                if (selectedFiles.length === 0) {
                    fileList.innerHTML = '';
                    fileUploadArea.querySelector('.file-upload-text').textContent = 
                        '파일을 선택하거나 여기로 드래그하세요';
                    fileUploadArea.querySelector('.upload-hint').innerHTML = 
                        '지원 형식: JPG, PNG, PDF, DOC, DOCX, HWP (최대 10MB)<br>여러 파일을 동시에 선택할 수 있습니다.';
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

            // 폼 제출 전 유효성 검사
            const form = document.getElementById('noticeForm');
            form.addEventListener('submit', function (e) {
                const title = document.querySelector('input[name="title"]').value.trim();
                const content = document.querySelector('textarea[name="content"]').value.trim();

                if (title.length < 2) {
                    alert('제목은 최소 2자 이상 입력해주세요.');
                    e.preventDefault();
                } else if (content.length < 10) {
                    alert('내용은 최소 10자 이상 입력해주세요.');
                    e.preventDefault();
                }
            });
        });
    </script>
</body>
</html>