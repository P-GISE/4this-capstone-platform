<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/layout/head-meta.jsp" %>
    <title>보고서 관리 - ${projectDetail.project.title}</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* 글로벌 폰트 설정 */
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
        
        /* content와 main-body 스타일은 head-meta.jsp에서 관리 */
        
        .report-header {
            background: white;
            color: #2d3748;
            padding: 30px;
            border-radius: 12px;
            margin-bottom: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
        }
        
        .report-header h2 {
            color: #2d3748;
            font-weight: 500;
            font-size: 24px;
            margin-bottom: 8px;
        }
        
        .btn-back {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            color: #495057;
            padding: 12px 20px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        
        .btn-back:hover {
            background: #e9ecef;
            color: #495057;
            text-decoration: none;
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .upload-area {
            border: 2px dashed #dee2e6;
            border-radius: 12px;
            padding: 50px 30px;
            text-align: center;
            margin-bottom: 30px;
            background: white;
            transition: all 0.3s ease;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .upload-area:hover {
            border-color: #60a5fa;
            background: #f8faff;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(96, 165, 250, 0.15);
        }
        
        .upload-area.dragover {
            border-color: #60a5fa;
            background: #f0f9ff;
            border-style: solid;
        }
        
        .file-icon {
            font-size: 48px;
            color: #60a5fa;
            margin-bottom: 20px;
        }
        
        .upload-area h4 {
            color: #2d3748;
            font-weight: 500;
            font-size: 18px;
            margin-bottom: 12px;
        }
        
        .upload-area p {
            color: #6c757d;
            font-size: 14px;
        }
        .report-card {
            border: 1px solid #e0e0e0;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 16px;
            background: white;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .report-card:hover {
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);
            transform: translateY(-2px);
        }
        
        .file-info {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .file-details {
            display: flex;
            align-items: center;
        }
        
        .file-icon-small {
            font-size: 24px;
            margin-right: 16px;
            color: #60a5fa;
        }
        
        .file-details h6 {
            color: #2d3748;
            font-weight: 500;
            margin-bottom: 4px;
        }
        
        .file-details small {
            color: #6c757d;
            font-size: 13px;
        }
        
        .reports-section h4 {
            color: #2d3748;
            font-weight: 500;
            font-size: 20px;
            margin-bottom: 20px;
        }
        
        .no-reports {
            text-align: center;
            padding: 80px 20px;
            color: #6c757d;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
        }
        
        .no-reports i {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.3;
            color: #60a5fa;
        }
        
        .no-reports h5 {
            color: #2d3748;
            font-weight: 500;
            margin-bottom: 12px;
        }
        
        .btn-primary {
            background: #60a5fa;
            border: none;
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        
        .btn-primary:hover {
            background: #3b82f6;
            transform: translateY(-1px);
            box-shadow: 0 3px 8px rgba(96, 165, 250, 0.3);
        }
        
        .btn-outline-primary {
            background: transparent;
            border: 1px solid #60a5fa;
            color: #60a5fa;
            padding: 8px 16px;
            border-radius: 6px;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        
        .btn-outline-primary:hover {
            background: #60a5fa;
            color: white;
            transform: translateY(-1px);
            box-shadow: 0 2px 6px rgba(96, 165, 250, 0.25);
        }
        
        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .main-body {
                padding: 15px;
                margin-top: 70px;
            }
            
            .report-header {
                padding: 20px;
                margin-bottom: 20px;
            }
            
            .report-header .d-flex {
                flex-direction: column;
                gap: 15px;
                align-items: flex-start !important;
            }
            
            .upload-area {
                padding: 40px 20px;
                margin-bottom: 20px;
            }
            
            .report-card {
                padding: 20px;
            }
            
            .file-info {
                flex-direction: column;
                gap: 15px;
                align-items: flex-start;
            }
            
            .no-reports {
                padding: 60px 20px;
            }
        }
        
        @media (max-width: 480px) {
            .main-body {
                padding: 12px;
            }
            
            .report-header h2 {
                font-size: 20px;
            }
            
            .upload-area {
                padding: 30px 15px;
            }
            
            .upload-area h4 {
                font-size: 16px;
            }
            
            .report-card {
                padding: 16px;
            }
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <%@ include file="/WEB-INF/views/layout/sidebar.jsp" %>
    </div>
    <div class="content">
        <%@ include file="/WEB-INF/views/layout/header.jsp" %>

        <div class="main-body">
            <!-- 프로젝트 정보 헤더 -->
            <div class="report-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2">
                            <i class="fas fa-file-alt" style="color: #60a5fa; margin-right: 12px;"></i>
                            보고서 관리
                        </h2>
                        <p class="mb-0" style="color: #6c757d; font-size: 15px;">${projectDetail.project.title}</p>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/projects/${projectDetail.project.id}" class="btn btn-back">
                            <i class="fas fa-arrow-left" style="margin-right: 8px;"></i>프로젝트로 돌아가기
                        </a>
                    </div>
                </div>
            </div>
            
            <!-- 파일 업로드 영역 -->
            <div class="upload-area" id="uploadArea">
                <div class="file-icon">
                    <i class="fas fa-cloud-upload-alt"></i>
                </div>
                <h4>보고서 파일을 업로드하세요</h4>
                <p class="mb-3">파일을 드래그하여 놓거나 클릭하여 선택하세요</p>
                <input type="file" id="fileInput" class="d-none" accept=".pdf,.doc,.docx,.hwp,.ppt,.pptx">
                <button type="button" class="btn btn-primary" onclick="document.getElementById('fileInput').click()">
                    <i class="fas fa-file-plus" style="margin-right: 8px;"></i>파일 선택
                </button>
                <p class="mt-3 mb-0" style="color: #9ca3af; font-size: 13px;">
                    지원 형식: PDF, DOC, DOCX, HWP, PPT, PPTX (최대 50MB)
                </p>
            </div>
            
            <!-- 진행률 표시 -->
            <div id="uploadProgress" class="progress mb-3" style="display: none; height: 6px; border-radius: 3px; background: #f1f3f4;">
                <div class="progress-bar" role="progressbar" style="width: 0%; background: #60a5fa; border-radius: 3px; transition: width 0.3s ease;"></div>
            </div>
            
            <!-- 보고서 목록 -->
            <div class="reports-section">
                <h4 class="mb-3">
                    <i class="fas fa-list-alt" style="color: #60a5fa; margin-right: 12px;"></i>
                    업로드된 보고서
                </h4>
                
                <c:choose>
                    <c:when test="${not empty reports}">
                        <c:forEach var="report" items="${reports}">
                            <div class="report-card">
                                <div class="file-info">
                                    <div class="file-details">
                                        <div class="file-icon-small">
                                    <i class="fas fa-file-alt"></i>
                                </div>
                                        <div>
                                            <h6 class="mb-1">${report.fileName}</h6>
                                            <small class="text-muted">
                                                업로드: <fmt:formatDate value="${report.uploadedAt}" pattern="yyyy-MM-dd HH:mm" />
                                            </small>
                                        </div>
                                    </div>
                                    <div>
                                        <button class="btn btn-outline-primary btn-sm" onclick="downloadReport('${report.id}')">
                                            <i class="fas fa-download" style="margin-right: 6px;"></i>다운로드
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="no-reports">
                            <i class="fas fa-file-upload"></i>
                            <h5>업로드된 보고서가 없습니다</h5>
                            <p>위의 업로드 영역을 사용하여 첫 번째 보고서를 업로드해보세요.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <%@ include file="/WEB-INF/views/layout/footer.jsp" %>
    </div>
    
    <%@ include file="/WEB-INF/views/layout/scripts.jsp" %>
    
    <script>
        // 파일 업로드 처리
        const uploadArea = document.getElementById('uploadArea');
        const fileInput = document.getElementById('fileInput');
        const uploadProgress = document.getElementById('uploadProgress');
        
        // 드래그 앤 드롭 이벤트
        uploadArea.addEventListener('dragover', (e) => {
            e.preventDefault();
            uploadArea.classList.add('dragover');
        });
        
        uploadArea.addEventListener('dragleave', (e) => {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
        });
        
        uploadArea.addEventListener('drop', (e) => {
            e.preventDefault();
            uploadArea.classList.remove('dragover');
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                handleFileUpload(files[0]);
            }
        });
        
        // 파일 선택 이벤트
        fileInput.addEventListener('change', (e) => {
            if (e.target.files.length > 0) {
                handleFileUpload(e.target.files[0]);
            }
        });
        
        // 파일 업로드 처리 함수
        function handleFileUpload(file) {
            // 파일 크기 검증 (50MB)
            if (file.size > 50 * 1024 * 1024) {
                alert('파일 크기가 50MB를 초과합니다.');
                return;
            }
            
            // 파일 형식 검증
            const allowedTypes = ['.pdf', '.doc', '.docx', '.hwp', '.ppt', '.pptx'];
            const fileExtension = '.' + file.name.split('.').pop().toLowerCase();
            if (!allowedTypes.includes(fileExtension)) {
                alert('지원하지 않는 파일 형식입니다.');
                return;
            }
            
            const formData = new FormData();
            formData.append('file', file);
            
            uploadProgress.style.display = 'block';
            const progressBar = uploadProgress.querySelector('.progress-bar');
            
            fetch('${pageContext.request.contextPath}/projects/${projectDetail.project.id}/reports/upload', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                uploadProgress.style.display = 'none';
                
                if (data.success) {
                    alert(data.message);
                    location.reload(); // 페이지 새로고침
                } else {
                    alert('업로드 실패: ' + data.message);
                }
            })
            .catch(error => {
                uploadProgress.style.display = 'none';
                alert('업로드 중 오류가 발생했습니다.');
                console.error('Error:', error);
            });
        }
        
        // 보고서 다운로드
        function downloadReport(reportId) {
            // 다운로드 URL로 이동
            window.location.href = '${pageContext.request.contextPath}/projects/${projectDetail.project.id}/reports/download/' + reportId;
        }
    </script>
</body>
</html> 
 