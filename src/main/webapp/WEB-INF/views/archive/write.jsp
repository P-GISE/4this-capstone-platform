<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<head>
    <title>아카이브 등록</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f8f9fa;
            color: #2d3748;
            line-height: 1.6;
        }

        /* 아카이브 페이지 스타일 - 기자재 페이지와 동일 */
        .archive-page h1 {
            font-size: 24px;
            color: #333;
            margin-bottom: 20px;
        }
        
        /* 카드 컨테이너 - 기자재와 동일한 스타일 */
        .equipment-card {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        }
        
        .write-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        
        .back-btn {
            background-color: #8595a3;
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
        
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 5px;
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
            border: 2px solid #e1e5e9;
            border-radius: 8px;
            font-size: 14px;
            background: #f8f9fa;
            box-sizing: border-box;
            transition: all 0.3s ease;
        }
        
        .form-input:focus,
        .form-select:focus,
        .form-textarea:focus {
            outline: none;
            border-color: #3366ff;
            background: #fff;
            box-shadow: 0 0 0 3px rgba(51, 102, 255, 0.1);
        }
        
        .form-textarea {
            resize: vertical;
            min-height: 120px;
            line-height: 1.5;
        }
        
        .form-row {
            display: flex;
            gap: 10px;
        }
        
        .form-row .form-group {
            flex: 1;
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
            padding-top: 15px;
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
            font-size: 0.9rem;
        }
        
        .btn-primary {
            background-color: #4751c9;
            color: white;
            border: 1px solid #eaeaf1;
        }
        
        .btn-primary:hover {
            background-color: #acb1dd;
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

        /* 섹션 구분 스타일 */
        .form-section {
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .form-section:last-child {
            border-bottom: none;
            margin-bottom: 0;
        }
        
        .section-subtitle {
            font-size: 1.1rem;
            font-weight: 600;
            color: #333;
            margin-bottom: 15px;
            padding-bottom: 8px;
            border-bottom: 2px solid #e9eaff;
        }

        /* 파일 업로드 스타일 - 공지사항과 동일 */
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
            border-color: #4751c9;
            background-color: #f8f9ff;
        }
        
        .file-upload-area.drag-over {
            border-color: #4751c9;
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
        
        .file-actions {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        
        .preview-btn {
            background: none;
            border: none;
            color: #4751c9;
            cursor: pointer;
            font-size: 14px;
            padding: 5px 8px;
            border-radius: 3px;
            transition: background-color 0.2s;
            text-decoration: none;
        }
        
        .preview-btn:hover {
            background-color: rgba(71, 81, 201, 0.1);
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
        <div class="main-body archive-page">
            <div class="write-container">
                <!-- 페이지 헤더 -->
                <h1>📁 아카이브 등록</h1>
                <div class="write-header">
                    <a href="/archive/list" class="back-btn">← 목록으로</a>
                </div>

                <!-- 성공/에러 메시지 -->
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger">${errorMessage}</div>
                </c:if>
                <c:if test="${not empty successMessage}">
                    <div class="alert alert-success">${successMessage}</div>
                </c:if>

                <!-- 등록 폼 -->
                <div class="equipment-card">
                    <form action="/archive/write" method="post" id="archiveForm" enctype="multipart/form-data">
                        
                        <!-- 기본 정보 섹션 -->
                        <div class="form-section">
                            <div class="section-subtitle">기본 정보</div>
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="title" class="form-label required">제목</label>
                                    <input type="text" id="title" name="title" class="form-input" required 
                                           placeholder="아카이브 제목을 입력하세요" value="${archive.title}">
                                </div>
                                <div class="form-group">
                                    <label for="version" class="form-label">버전</label>
                                    <input type="text" id="version" name="version" class="form-input" 
                                           placeholder="v1.0" value="v1.0">
                                </div>
                            </div>

                            <div class="form-group">
                                <label for="submittedByName" class="form-label">작성자 이름</label>
                                <input type="text" name="submittedByName" value="${loginUser.name}" class="form-input" placeholder="작성자 이름 (미입력 시 자동)" />
                            </div>
                        </div>
                        
                        <!-- 프로젝트 정보 섹션 -->
                        <div class="form-section">
                            <div class="section-subtitle">프로젝트 정보</div>
                            
                            <div class="form-group">
                                <label for="description" class="form-label required">설명</label>
                                <textarea id="description" name="description" class="form-textarea" required
                                          placeholder="프로젝트의 목적, 주요 기능, 사용 기술 등을 상세히 설명해주세요.">${archive.description}</textarea>
                                <div class="help-text">최소 50자 이상 작성해주세요.</div>
                            </div>
                            
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="category" class="form-label required">카테고리</label>
                                    <select id="category" name="category" class="form-select" required>
                                        <option value="">카테고리 선택</option>
                                        <option value="IoT">IoT</option>
                                        <option value="AI/머신러닝">AI/머신러닝</option>
                                        <option value="웹개발">웹개발</option>
                                        <option value="모바일">모바일</option>
                                        <option value="로봇">로봇</option>
                                        <option value="기타">기타</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">공개 설정</label>
                                    <div class="radio-group">
                                        <label class="radio-item">
                                            <input type="radio" name="isPublic" value="true" checked>
                                            <span>전체 공개</span>
                                        </label>
                                        <label class="radio-item">
                                            <input type="radio" name="isPublic" value="false">
                                            <span>비공개</span>
                                        </label>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <label for="projectId" class="form-label">연결된 프로젝트</label>
                                <select id="projectId" name="projectId" class="form-select">
                                    <c:forEach var="project" items="${projectList}">
                                        <option value="${project.id}" <c:if test="${archive.projectId == project.id}">selected</c:if>>
                                            ${project.title}
                                        </option>
                                    </c:forEach>
                                </select>
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
                                        지원 형식: JPG, PNG, PDF, DOC, DOCX, HWP, ZIP, RAR (최대 50MB)<br>
                                        프로젝트 결과물, 소스코드, 문서 등을 업로드할 수 있습니다.
                                    </div>
                                </div>
                                <input type="file" id="attachFile" name="attachFile" class="form-input" multiple
                                       style="display: none;" accept=".jpg,.jpeg,.png,.pdf,.doc,.docx,.hwp,.zip,.rar,.txt,.py,.java,.js,.html,.css">
                                <div id="fileList" class="file-list"></div>
                            </div>
                        </div>

                        <!-- 제출 옵션 섹션 -->
                        <div class="form-section">
                            <div class="section-subtitle">제출 옵션</div>
                            <div class="help-text">이 아카이브는 등록 시 자동으로 관리자 승인 요청이 됩니다.<br>승인 전까지는 목록에 표시되지 않습니다.</div>
                            <input type="hidden" name="isSubmitted" value="true">
                        </div>

                        <!-- 버튼 영역 -->
                        <div class="form-actions">
                            <a href="/archive/list" class="btn btn-outline">취소</a>
                            <button type="submit" class="btn btn-primary">등록하기</button>
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
                console.log('handleFiles 호출됨, 파일 개수:', files.length);
                
                files.forEach(function(file) {
                    console.log('파일 정보:', file.name, file.size, file.type);
                    
                    // 파일 크기 제한 (50MB)
                    if (file.size > 50 * 1024 * 1024) {
                        alert('파일 "' + file.name + '"이 너무 큽니다. (최대 50MB)');
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
                        '지원 형식: JPG, PNG, PDF, DOC, DOCX, HWP, ZIP, RAR (최대 50MB)<br>프로젝트 결과물, 소스코드, 문서 등을 업로드할 수 있습니다.';
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
                    
                    // 미리보기 가능한 파일인지 확인
                    const isPreviewable = isImageFile(file) || isVideoFile(file);
                    
                    html += '<div class="file-item" data-index="' + index + '">' +
                                '<div class="file-info">' +
                                    '<span class="file-name">' + fileName + '</span>' +
                                    '<span class="file-size">(' + fileSize + ')</span>' +
                                '</div>' +
                                '<div class="file-actions">';
                    
                    if (isPreviewable) {
                        html += '<button type="button" class="preview-btn" onclick="previewFile(' + index + ')">미리보기</button>';
                    }
                    
                    html += '<button type="button" class="remove-file" onclick="removeFileAt(' + index + ')">×</button>' +
                                '</div>' +
                            '</div>';
                });
                
                fileList.innerHTML = html;
            }
            
            // 이미지 파일인지 확인
            function isImageFile(file) {
                return file.type.startsWith('image/');
            }
            
            // 비디오 파일인지 확인
            function isVideoFile(file) {
                return file.type.startsWith('video/');
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
            const form = document.getElementById('archiveForm');
            form.addEventListener('submit', function (e) {
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
        });
        
        // 미리보기 함수 (전역)
        function previewFile(index) {
            const file = selectedFiles[index];
            const modal = document.getElementById('previewModal');
            const content = document.getElementById('previewContent');
            
            if (file.type.startsWith('image/')) {
                // 이미지 미리보기
                const reader = new FileReader();
                reader.onload = function(e) {
                    content.innerHTML = '<img src="' + e.target.result + '" class="preview-media" alt="미리보기">';
                    modal.style.display = 'block';
                };
                reader.readAsDataURL(file);
            } else if (file.type.startsWith('video/')) {
                // 비디오 미리보기
                const reader = new FileReader();
                reader.onload = function(e) {
                    content.innerHTML = '<video controls class="preview-video"><source src="' + e.target.result + '" type="' + file.type + '">브라우저가 비디오를 지원하지 않습니다.</video>';
                    modal.style.display = 'block';
                };
                reader.readAsDataURL(file);
            }
        }
        
        // 미리보기 모달 닫기
        function closePreviewModal() {
            document.getElementById('previewModal').style.display = 'none';
            document.getElementById('previewContent').innerHTML = '';
        }
        
        // 모달 외부 클릭시 닫기
        window.onclick = function(event) {
            const modal = document.getElementById('previewModal');
            if (event.target == modal) {
                closePreviewModal();
            }
        }
    </script>
</body>
</html>