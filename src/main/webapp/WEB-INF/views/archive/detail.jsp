<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<body>
    <!-- 1) 사이드바 -->
    <div class="sidebar">
        <%@ include file="../layout/sidebar.jsp" %>
    </div>

    <!-- 2) 메인 콘텐츠 -->
    <div class="content">
        <!-- 2-1) 헤더 -->
        <%@ include file="../layout/header.jsp" %>

        <!-- 2-2) 본문 영역 -->
        <div class="main-body archive-detail-page">
            <div class="detail-container">
                <!-- 상단 브레드크럼 -->
                <div class="breadcrumb-section">
                    <div class="breadcrumb">
                        <span class="breadcrumb-item">아카이브</span>
                        <span class="breadcrumb-divider">></span>
                        <span class="breadcrumb-current"><c:out value="${archive.title}" /></span>
                    </div>
                </div>

                <!-- 프로젝트 헤더 -->
                <div class="project-header">
                    <div class="project-title-section">
                        <h1 class="project-title"><c:out value="${archive.title}" /></h1>
                        <div class="project-meta">
                            <span class="meta-item">
                                <span class="meta-icon">📋</span>
                                <strong>프로젝트 ID:</strong> <c:out value="${archive.id}" />
                            </span>
                            <span class="meta-item">
                                <span class="meta-icon">📅</span>
                                <strong>등록일:</strong> <fmt:formatDate value="${archive.submittedAt}" pattern="yyyy.MM.dd" />
                            </span>
                            <span class="meta-item">
                                <span class="meta-icon">🔧</span>
                                <strong>상태:</strong>
                                <span class="status-badge status-complete">
                                    <c:choose>
                                        <c:when test="${archive.isPublic}">공개</c:when>
                                        <c:otherwise>비공개</c:otherwise>
                                    </c:choose>
                                </span>
                            </span>
                        </div>
                    </div>
                    
                    <div class="project-actions">
                        <!-- 권한 체크 - 작성자이거나 관리자인 경우만 표시 -->
                        <c:if test="${sessionScope.userId == archive.submittedBy || sessionScope.userRole == 'ADMIN'}">
                            <a href="${pageContext.request.contextPath}/archive/edit/${archive.id}" class="action-btn edit-btn">
                                <span class="btn-icon">✏️</span>
                                편집하기
                            </a>
                        </c:if>
                    </div>
                </div>

                <!-- 탭 네비게이션 -->
                <div class="tab-navigation">
                    <button class="tab-item active" data-tab="overview">
                        <span class="tab-icon">📖</span>
                        개요
                    </button>
                    <button class="tab-item" data-tab="progress">
                        <span class="tab-icon">📊</span>
                        진행상황
                    </button>
                    <button class="tab-item" data-tab="files">
                        <span class="tab-icon">📎</span>
                        파일자료
                    </button>
                    <button class="tab-item" data-tab="team">
                        <span class="tab-icon">👥</span>
                        팀정보
                    </button>
                    <button class="tab-item" data-tab="equipment">
                        <span class="tab-icon">🛠️</span>
                        기자재
                    </button>
                </div>

                <!-- 콘텐츠 영역 -->
                <div class="content-wrapper">
                    <!-- 개요 탭 -->
                    <div class="tab-content active" id="overview-content">
                        <div class="content-grid">
                            <!-- 프로젝트 설명 -->
                            <div class="description-card">
                                <div class="card-header">
                                    <span class="card-icon">🚀</span>
                                    <h3>프로젝트 설명</h3>
                                </div>
                                <div class="description-content">
                                    <c:out value="${archive.description}" escapeXml="false" />
                                </div>
                            </div>

                            <!-- 프로젝트 정보 -->
                            <div class="info-card">
                                <div class="card-header">
                                    <span class="card-icon">📋</span>
                                    <h3>프로젝트 정보</h3>
                                </div>
                                <div class="info-grid">
                                    <div class="info-item">
                                        <div class="info-label">작성자</div>
                                        <div class="info-value"><c:out value="${archive.submittedByName}" /></div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-label">제출일</div>
                                        <div class="info-value"><fmt:formatDate value="${archive.submittedAt}" pattern="yyyy.MM.dd" /></div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-label">카테고리</div>
                                        <div class="info-value"><c:out value="${archive.category}" /></div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-label">버전</div>
                                        <div class="info-value"><c:out value="${archive.version}" /></div>
                                    </div>
                                    <div class="info-item">
                                        <div class="info-label">상태</div>
                                        <div class="info-value">
                                            <c:choose>
                                                <c:when test="${archive.isSubmitted}">제출됨</c:when>
                                                <c:otherwise>작성중</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                    <c:if test="${not empty archive.projectTitle}">
                                        <div class="info-item">
                                            <div class="info-label">연관 프로젝트</div>
                                            <div class="info-value">
                                                <a href="${pageContext.request.contextPath}/project/detail/${archive.projectId}" class="project-link">
                                                    <c:out value="${archive.projectTitle}" />
                                                </a>
                                            </div>
                                        </div>
                                    </c:if>
                                </div>
                            </div>

                            <!-- 태그 정보 카드 -->
                            <div class="tech-card">
                                <div class="card-header">
                                    <span class="card-icon">🔧</span>
                                    <h3>태그 정보</h3>
                                </div>
                                <div class="tech-grid">
                                    <div class="tag-display">
                                        <span class="tag tag-category">
                                            <c:out value="${archive.category}" />
                                        </span>
                                        <span class="tag tag-version">
                                            <c:out value="${archive.version}" />
                                        </span>
                                        <span class="tag tag-status">
                                            <c:choose>
                                                <c:when test="${archive.isPublic}">공개</c:when>
                                                <c:otherwise>비공개</c:otherwise>
                                            </c:choose>
                                        </span>
                                        <c:if test="${archive.isSubmitted}">
                                            <span class="tag tag-submitted">제출됨</span>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 파일자료 탭 -->
                    <div class="tab-content" id="files-content">
                        <div class="files-section">
                            <!-- 프로젝트 보고서 섹션 -->
                            <c:if test="${not empty projectReports}">
                                <div class="files-category">
                                    <div class="files-header">
                                        <h3>📊 프로젝트 보고서 <span class="file-count">(${fn:length(projectReports)}개)</span></h3>
                                    </div>
                                    <div class="files-grid">
                                        <c:forEach var="report" items="${projectReports}">
                                            <div class="file-item project-report">
                                                <div class="file-icon">
                                                    <c:choose>
                                                        <c:when test="${fn:contains(fn:toLowerCase(report.fileName), '.pdf')}">
                                                            <i class="fas fa-file-pdf" style="color: #e74c3c;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(report.fileName), '.ppt') || fn:contains(fn:toLowerCase(report.fileName), '.pptx')}">
                                                            <i class="fas fa-file-powerpoint" style="color: #d35400;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(report.fileName), '.doc') || fn:contains(fn:toLowerCase(report.fileName), '.docx')}">
                                                            <i class="fas fa-file-word" style="color: #2980b9;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(report.fileName), '.hwp')}">
                                                            <i class="fas fa-file-alt" style="color: #27ae60;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(report.fileName), '.xls') || fn:contains(fn:toLowerCase(report.fileName), '.xlsx')}">
                                                            <i class="fas fa-file-excel" style="color: #16a085;"></i>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="fas fa-file" style="color: #7f8c8d;"></i>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="file-info">
                                                    <div class="file-name">
                                                        <c:out value="${report.fileName}" />
                                                    </div>
                                                    <div class="file-details">
                                                        <span class="file-size">
                                                            <c:choose>
                                                                <c:when test="${report.fileSize > 1024 * 1024}">
                                                                    <fmt:formatNumber value="${report.fileSize / (1024 * 1024)}" maxFractionDigits="1" />MB
                                                                </c:when>
                                                                <c:when test="${report.fileSize > 1024}">
                                                                    <fmt:formatNumber value="${report.fileSize / 1024}" maxFractionDigits="1" />KB
                                                                </c:when>
                                                                <c:otherwise>
                                                                    ${report.fileSize}B
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                        <span class="file-date">업로드: <fmt:formatDate value="${report.uploadedAt}" pattern="MM.dd" /></span>
                                                    </div>
                                                    <c:if test="${not empty report.description}">
                                                        <div class="file-description">
                                                            <c:out value="${report.description}" />
                                                        </div>
                                                    </c:if>
                                                </div>
                                                <div class="file-actions">
                                                    <a href="${pageContext.request.contextPath}/projects/${archive.projectId}/reports/download/${report.id}" 
                                                       class="download-btn" target="_blank">
                                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                                                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3" stroke="currentColor" stroke-width="2"/>
                                                        </svg>
                                                        다운로드
                                                    </a>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>

                            <!-- 아카이브 첨부파일 섹션 -->
                            <c:if test="${not empty files}">
                                <div class="files-category">
                                    <div class="files-header">
                                        <h3>📎 아카이브 첨부파일 <span class="file-count">(${fn:length(files)}개)</span></h3>
                                    </div>
                                    <div class="files-grid">
                                        <c:forEach var="file" items="${files}">
                                            <div class="file-item archive-file">
                                                <div class="file-icon">
                                                    <c:choose>
                                                        <c:when test="${fn:contains(file.fileType, 'pdf') || fn:contains(fn:toLowerCase(file.originalFileName), '.pdf')}">
                                                            <i class="fas fa-file-pdf" style="color: #e74c3c;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(file.originalFileName), '.zip') || fn:contains(fn:toLowerCase(file.originalFileName), '.rar') || fn:contains(fn:toLowerCase(file.originalFileName), '.7z') || fn:contains(fn:toLowerCase(file.originalFileName), '.tar')}">
                                                            <i class="fas fa-file-archive" style="color: #f39c12;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(file.fileType, 'video') || fn:contains(fn:toLowerCase(file.originalFileName), '.mp4') || fn:contains(fn:toLowerCase(file.originalFileName), '.avi') || fn:contains(fn:toLowerCase(file.originalFileName), '.mov')}">
                                                            <i class="fas fa-file-video" style="color: #9b59b6;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(file.fileType, 'image') || fn:contains(fn:toLowerCase(file.originalFileName), '.jpg') || fn:contains(fn:toLowerCase(file.originalFileName), '.jpeg') || fn:contains(fn:toLowerCase(file.originalFileName), '.png') || fn:contains(fn:toLowerCase(file.originalFileName), '.gif')}">
                                                            <i class="fas fa-file-image" style="color: #1abc9c;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(file.originalFileName), '.java') || fn:contains(fn:toLowerCase(file.originalFileName), '.py') || fn:contains(fn:toLowerCase(file.originalFileName), '.js') || fn:contains(fn:toLowerCase(file.originalFileName), '.html') || fn:contains(fn:toLowerCase(file.originalFileName), '.css') || fn:contains(fn:toLowerCase(file.originalFileName), '.cpp') || fn:contains(fn:toLowerCase(file.originalFileName), '.c')}">
                                                            <i class="fas fa-file-code" style="color: #34495e;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(file.originalFileName), '.ppt') || fn:contains(fn:toLowerCase(file.originalFileName), '.pptx')}">
                                                            <i class="fas fa-file-powerpoint" style="color: #d35400;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(file.originalFileName), '.doc') || fn:contains(fn:toLowerCase(file.originalFileName), '.docx')}">
                                                            <i class="fas fa-file-word" style="color: #2980b9;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(file.originalFileName), '.xls') || fn:contains(fn:toLowerCase(file.originalFileName), '.xlsx')}">
                                                            <i class="fas fa-file-excel" style="color: #16a085;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(file.originalFileName), '.hwp')}">
                                                            <i class="fas fa-file-alt" style="color: #27ae60;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(file.fileType, 'text') || fn:contains(fn:toLowerCase(file.originalFileName), '.txt') || fn:contains(fn:toLowerCase(file.originalFileName), '.md')}">
                                                            <i class="fas fa-file-alt" style="color: #95a5a6;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(file.originalFileName), '.csv')}">
                                                            <i class="fas fa-file-csv" style="color: #27ae60;"></i>
                                                        </c:when>
                                                        <c:when test="${fn:contains(fn:toLowerCase(file.originalFileName), '.json') || fn:contains(fn:toLowerCase(file.originalFileName), '.xml')}">
                                                            <i class="fas fa-file-code" style="color: #e67e22;"></i>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="fas fa-file" style="color: #7f8c8d;"></i>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="file-info">
                                                    <div class="file-name">
                                                        <c:out value="${file.originalFileName}" />
                                                    </div>
                                                    <div class="file-details">
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
                                                        <span class="download-count">다운로드: ${file.downloadCount}회</span>
                                                    </div>
                                                </div>
                                                <div class="file-actions">
                                                    <button type="button" class="download-btn" onclick="downloadFile('${file.id}', '${file.fileName}', '${file.originalFileName}')">
                                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                                                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4M7 10l5 5 5-5M12 15V3" stroke="currentColor" stroke-width="2"/>
                                                        </svg>
                                                        다운로드
                                                    </button>
                                                    <c:if test="${fn:contains(file.fileType, 'image') || fn:contains(file.fileType, 'video')}">
                                                        <button type="button" class="preview-btn" onclick="previewFile('${file.fileName}', '${file.originalFileName}', '${file.fileType}')">
                                                            미리보기
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>

                            <!-- 파일이 전혀 없는 경우 -->
                            <c:if test="${empty files && empty projectReports}">
                                <div class="no-files">
                                    <div class="no-files-icon">📎</div>
                                    <p>첨부된 파일이 없습니다.</p>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <!-- 진행상황 탭 -->
                    <div class="tab-content" id="progress-content">
                        <div class="progress-section">
                            <c:if test="${not empty projectDetail}">
                                <!-- 프로젝트 기본 정보 -->
                                <div class="project-info-card">
                                    <div class="card-header">
                                        <span class="card-icon">📊</span>
                                        <h3>프로젝트 진행상황</h3>
                                    </div>
                                    <div class="project-progress-grid">
                                        <div class="progress-item">
                                            <div class="progress-label">프로젝트명</div>
                                            <div class="progress-value"><c:out value="${projectDetail.project.title}" /></div>
                                        </div>
                                        <div class="progress-item">
                                            <div class="progress-label">시작일</div>
                                            <div class="progress-value">
                                                <c:choose>
                                                    <c:when test="${not empty projectDetail.project.createdAt}">
                                                        ${fn:substring(projectDetail.project.createdAt, 0, 10)}
                                                    </c:when>
                                                    <c:otherwise>-</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <div class="progress-item">
                                            <div class="progress-label">팀원 수</div>
                                            <div class="progress-value">${fn:length(projectDetail.members)}명</div>
                                        </div>
                                        <div class="progress-item">
                                            <div class="progress-label">총 작업</div>
                                            <div class="progress-value">${fn:length(projectDetail.tasks)}개</div>
                                        </div>
                                    </div>
                                </div>

                                <!-- 작업 목록 -->
                                <c:if test="${not empty projectDetail.tasks}">
                                    <div class="tasks-card">
                                        <div class="card-header">
                                            <span class="card-icon">✅</span>
                                            <h3>작업 목록</h3>
                                        </div>
                                        <div class="tasks-list">
                                            <c:forEach var="task" items="${projectDetail.tasks}" varStatus="status">
                                                <c:if test="${status.index < 5}"> <!-- 최대 5개만 표시 -->
                                                    <div class="task-item">
                                                        <div class="task-status">
                                                            <span class="status-badge status-${task.status}">
                                                                <c:choose>
                                                                    <c:when test="${task.status == 'TODO'}">대기</c:when>
                                                                    <c:when test="${task.status == 'IN_PROGRESS'}">진행중</c:when>
                                                                    <c:when test="${task.status == 'DONE'}">완료</c:when>
                                                                    <c:otherwise>${task.status}</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </div>
                                                        <div class="task-info">
                                                            <div class="task-title"><c:out value="${task.title}" /></div>
                                                            <div class="task-meta">
                                                                담당자: 
                                                                <c:choose>
                                                                    <c:when test="${not empty task.assignedToUserName}">
                                                                        <c:out value="${task.assignedToUserName}" />
                                                                    </c:when>
                                                                    <c:otherwise>미지정</c:otherwise>
                                                                </c:choose>
                                                                | 마감일: 
                                                                <c:choose>
                                                                    <c:when test="${not empty task.dueDate}">
                                                                        <fmt:formatDate value="${task.dueDate}" pattern="MM.dd" />
                                                                    </c:when>
                                                                    <c:otherwise>-</c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:if>
                                            </c:forEach>
                                            <c:if test="${fn:length(projectDetail.tasks) > 5}">
                                                <div class="more-tasks">
                                                    <a href="${pageContext.request.contextPath}/projects/${projectDetail.project.id}">
                                                        +${fn:length(projectDetail.tasks) - 5}개 더 보기
                                                    </a>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:if>
                            </c:if>
                            
                            <c:if test="${empty projectDetail}">
                                <div class="no-project-info">
                                    <div class="no-info-icon">📊</div>
                                    <p>연결된 프로젝트 정보가 없습니다.</p>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <!-- 팀정보 탭 -->
                    <div class="tab-content" id="team-content">
                        <div class="team-section">
                            <c:if test="${not empty projectDetail}">
                                <div class="team-info-card">
                                    <div class="card-header">
                                        <span class="card-icon">👥</span>
                                        <h3>팀 정보</h3>
                                    </div>
                                    <div class="team-members-grid">
                                        <c:forEach var="member" items="${projectDetail.members}">
                                            <div class="member-item">
                                                <div class="member-avatar ${member.role == 'LEADER' ? 'leader-avatar' : 'member-avatar'}">
                                                    <c:set var="userName" value="${fn:trim(member.userName)}" />
                                                    <c:choose>
                                                        <c:when test="${not empty userName}">
                                                            ${fn:substring(userName, 0, 1)}
                                                        </c:when>
                                                        <c:otherwise>?</c:otherwise>
                                                    </c:choose>
                                                    <c:if test="${member.role == 'LEADER'}">
                                                        <span class="crown-icon">👑</span>
                                                    </c:if>
                                                </div>
                                                <div class="member-info">
                                                    <div class="member-name"><c:out value="${member.userName}" /></div>
                                                    <div class="member-role">
                                                        <c:choose>
                                                            <c:when test="${member.role == 'LEADER'}">팀장</c:when>
                                                            <c:when test="${member.role == 'MEMBER'}">팀원</c:when>
                                                            <c:otherwise>${member.role}</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                                <div class="member-status">
                                                    <c:choose>
                                                        <c:when test="${member.approved}">
                                                            <span class="status-approved">✅ 참여중</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-pending">⏳ 대기중</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                    
                                    <!-- 팀 통계 -->
                                    <div class="team-stats">
                                        <div class="stat-item">
                                            <div class="stat-number">${fn:length(projectDetail.members)}</div>
                                            <div class="stat-label">총 팀원</div>
                                        </div>
                                        <div class="stat-item">
                                            <div class="stat-number">
                                                <c:set var="approvedCount" value="0" />
                                                <c:forEach var="member" items="${projectDetail.members}">
                                                    <c:if test="${member.approved}">
                                                        <c:set var="approvedCount" value="${approvedCount + 1}" />
                                                    </c:if>
                                                </c:forEach>
                                                ${approvedCount}
                                            </div>
                                            <div class="stat-label">참여중</div>
                                        </div>
                                        <div class="stat-item">
                                            <div class="stat-number">${fn:length(projectDetail.tasks)}</div>
                                            <div class="stat-label">총 작업</div>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                            
                            <c:if test="${empty projectDetail}">
                                <div class="no-team-info">
                                    <div class="no-info-icon">👥</div>
                                    <p>연결된 프로젝트의 팀 정보가 없습니다.</p>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <!-- 기자재 탭 -->
                    <div class="tab-content" id="equipment-content">
                        <div class="equipment-section">
                            <c:choose>
                                <c:when test="${not empty equipmentList}">
                                    <div class="equipment-info-card">
                                        <div class="card-header">
                                            <span class="card-icon">🛠️</span>
                                            <h3>프로젝트 사용 기자재</h3>
                                            <span class="equipment-count">총 ${fn:length(equipmentList)}개</span>
                                        </div>
                                        <div class="equipment-grid">
                                            <c:forEach var="equipment" items="${equipmentList}">
                                                <div class="equipment-item">
                                                    <div class="equipment-header">
                                                        <div class="equipment-icon">🔧</div>
                                                        <div class="equipment-name">
                                                            <c:out value="${equipment.equipmentName}" />
                                                        </div>
                                                        <div class="equipment-quantity">
                                                            <span class="quantity-badge">${equipment.quantity}개</span>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="equipment-details">
                                                        <div class="detail-row">
                                                            <span class="detail-label">
                                                                <i class="fas fa-tag"></i> 카테고리
                                                            </span>
                                                            <span class="detail-value">
                                                                <c:out value="${equipment.category}" />
                                                            </span>
                                                        </div>
                                                        
                                                        <c:if test="${not empty equipment.manufacturer}">
                                                            <div class="detail-row">
                                                                <span class="detail-label">
                                                                    <i class="fas fa-industry"></i> 제조사
                                                                </span>
                                                                <span class="detail-value">
                                                                    <c:out value="${equipment.manufacturer}" />
                                                                </span>
                                                            </div>
                                                        </c:if>
                                                        
                                                        <div class="detail-row">
                                                            <span class="detail-label">
                                                                <i class="fas fa-user"></i> 대여자
                                                            </span>
                                                            <span class="detail-value">
                                                                <c:out value="${equipment.renterName}" />
                                                            </span>
                                                        </div>
                                                        
                                                        <div class="detail-row">
                                                            <span class="detail-label">
                                                                <i class="fas fa-calendar"></i> 대여일
                                                            </span>
                                                            <span class="detail-value">
                                                                <c:choose>
                                                                    <c:when test="${not empty equipment.rentDate}">
                                                                        <fmt:formatDate value="${equipment.rentDate}" pattern="yyyy.MM.dd" />
                                                                    </c:when>
                                                                    <c:otherwise>-</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </div>
                                                        
                                                        <div class="detail-row">
                                                            <span class="detail-label">
                                                                <i class="fas fa-calendar-check"></i> 반납예정일
                                                            </span>
                                                            <span class="detail-value">
                                                                <c:choose>
                                                                    <c:when test="${not empty equipment.expectedReturnDate}">
                                                                        <fmt:formatDate value="${equipment.expectedReturnDate}" pattern="yyyy.MM.dd" />
                                                                    </c:when>
                                                                    <c:otherwise>-</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </div>
                                                        
                                                        <c:if test="${not empty equipment.purpose}">
                                                            <div class="detail-row purpose-row">
                                                                <span class="detail-label">
                                                                    <i class="fas fa-clipboard-list"></i> 사용목적
                                                                </span>
                                                                <span class="detail-value purpose-text">
                                                                    <c:out value="${equipment.purpose}" />
                                                                </span>
                                                            </div>
                                                        </c:if>
                                                    </div>
                                                    
                                                    <div class="equipment-status">
                                                        <span class="status-badge status-rented">
                                                            <i class="fas fa-check-circle"></i> 대여중
                                                        </span>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                        
                                        <!-- 기자재 요약 통계 -->
                                        <div class="equipment-summary">
                                            <div class="summary-item">
                                                <div class="summary-number">${fn:length(equipmentList)}</div>
                                                <div class="summary-label">사용 기자재 종류</div>
                                            </div>
                                            <div class="summary-item">
                                                <div class="summary-number">
                                                    <c:set var="totalQuantity" value="0" />
                                                    <c:forEach var="equipment" items="${equipmentList}">
                                                        <c:set var="totalQuantity" value="${totalQuantity + equipment.quantity}" />
                                                    </c:forEach>
                                                    ${totalQuantity}
                                                </div>
                                                <div class="summary-label">총 수량</div>
                                            </div>
                                            <div class="summary-item">
                                                <div class="summary-number">
                                                    <c:set var="renterList" value="" />
                                                    <c:set var="uniqueRenterCount" value="0" />
                                                    <c:forEach var="equipment" items="${equipmentList}">
                                                        <c:if test="${!fn:contains(renterList, equipment.renterName)}">
                                                            <c:set var="renterList" value="${renterList},${equipment.renterName}" />
                                                            <c:set var="uniqueRenterCount" value="${uniqueRenterCount + 1}" />
                                                        </c:if>
                                                    </c:forEach>
                                                    ${uniqueRenterCount}
                                                </div>
                                                <div class="summary-label">대여 팀원</div>
                                            </div>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="no-equipment-info">
                                        <div class="no-info-icon">🛠️</div>
                                        <h3>사용된 기자재가 없습니다</h3>
                                        <p>이 프로젝트에서 대여한 기자재 정보가 없습니다.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- 관리자 승인 섹션 (관리자만 보임) -->
                <c:if test="${sessionScope.userRole == 'ADMIN' && archive.isSubmitted && !archive.approved}">
                    <div class="admin-section">
                        <h3>관리자 승인</h3>
                        <div class="approval-actions">
                            <button type="button" class="btn btn-success" onclick="approveArchive()">승인</button>
                            <button type="button" class="btn btn-warning" onclick="rejectArchive()">반려</button>
                        </div>
                    </div>
                </c:if>

                <!-- 액션 버튼들 (기존 기능 유지) -->
                <div class="bottom-actions">
                    <a href="${pageContext.request.contextPath}/archive/list" class="btn btn-outline">
                        ← 목록으로
                    </a>
                    <c:if test="${sessionScope.userId == archive.submittedBy || sessionScope.userRole == 'ADMIN'}">
                        <button type="button" class="btn btn-danger" onclick="confirmDelete()">
                            삭제
                        </button>
                    </c:if>
                </div>
            </div>
        </div>

        <!-- 2-3) 푸터 -->
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 삭제 확인 모달 -->
    <div id="deleteModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h4>아카이브 삭제</h4>
                <span class="modal-close" onclick="closeDeleteModal()">&times;</span>
            </div>
            <div class="modal-body">
                <p>정말로 이 아카이브를 삭제하시겠습니까?</p>
                <p><strong>삭제된 데이터는 복구할 수 없습니다.</strong></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline" onclick="closeDeleteModal()">취소</button>
                <button type="button" class="btn btn-danger" onclick="deleteArchive()">삭제</button>
            </div>
        </div>
    </div>

    <!-- 미리보기 모달 -->
    <div id="previewModal" class="preview-modal">
        <div class="preview-modal-content">
            <span class="preview-close" onclick="closePreviewModal()">&times;</span>
            <div id="previewContent"></div>
        </div>
    </div>

    <!-- 3) 페이지 전용 CSS -->
    <style>
        :root {
            --primary-color: #6c5ce7;
            --secondary-color: #a29bfe;
            --success-color: #00b894;
            --warning-color: #fdcb6e;
            --danger-color: #e17055;
            --background-color: #f8f9ff;
            --card-bg: #ffffff;
            --text-dark: #2d3436;
            --text-muted: #636e72;
            --border-color: #ddd6fe;
            --border-radius: 16px;
            --box-shadow: 0 4px 20px rgba(108, 92, 231, 0.1);
        }

        /* 스크롤 가능하도록 설정 - 리스트 페이지와 동일하게 */
        .archive-detail-page {
            padding: 20px;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', sans-serif;
        }
        
        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f8f9fa;
            color: #2d3748;
            line-height: 1.6;
        }
        
        /* content와 main-body 스타일은 head-meta.jsp에서 관리 */

        .detail-container {
            max-width: 1200px;
            margin: 0 auto;
        }

        /* 브레드크럼 */
        .breadcrumb-section {
            margin-bottom: 20px;
        }

        .breadcrumb {
            background: rgba(255, 255, 255, 0.9);
            padding: 12px 20px;
            border-radius: var(--border-radius);
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
            backdrop-filter: blur(10px);
        }

        .breadcrumb-item {
            color: var(--text-muted);
        }

        .breadcrumb-current {
            color: var(--primary-color);
            font-weight: 600;
        }

        .breadcrumb-divider {
            color: var(--text-muted);
            margin: 0 4px;
        }

        /* 프로젝트 헤더 */
        .project-header {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            padding: 30px;
            margin-bottom: 20px;
            box-shadow: var(--box-shadow);
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 20px;
        }

        .project-title-section {
            flex: 1;
        }

        .project-title {
            font-size: 2rem;
            font-weight: bold;
            color: var(--text-dark);
            margin-bottom: 15px;
            line-height: 1.2;
        }

        .project-meta {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            color: var(--text-muted);
        }

        .meta-icon {
            font-size: 16px;
        }

        .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .status-complete {
            background-color: #d4edda;
            color: #155724;
        }

        .project-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .action-btn {
            background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 50%, #fecfef 100%);
            border: none;
            color: white;
            padding: 12px 20px;
            border-radius: 25px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            box-shadow: 0 4px 15px rgba(255, 154, 158, 0.3);
        }

        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(255, 154, 158, 0.4);
        }

        .bookmark-btn {
            background: linear-gradient(135deg, #ffeaa7 0%, #fab1a0 100%);
        }

        .download-btn {
            background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
        }

        .share-btn {
            background: linear-gradient(135deg, #fd79a8 0%, #fdcb6e 100%);
        }

        .edit-btn {
            background: linear-gradient(135deg, #a29bfe 0%, #6c5ce7 100%);
        }

        .btn-icon {
            font-size: 16px;
        }

        /* 탭 네비게이션 */
        .tab-navigation {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            padding: 8px;
            margin-bottom: 20px;
            display: flex;
            gap: 4px;
            box-shadow: var(--box-shadow);
        }

        .tab-item {
            flex: 1;
            background: transparent;
            border: none;
            padding: 15px 20px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 500;
            color: var(--text-muted);
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .tab-item.active {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(108, 92, 231, 0.3);
        }

        .tab-item:hover:not(.active) {
            background: var(--background-color);
            color: var(--primary-color);
        }

        .tab-icon {
            font-size: 16px;
        }

        .content-wrapper {
            margin-bottom: 30px;
        }

        .tab-content {
            display: none;
        }

        .tab-content.active {
            display: block;
        }

        .content-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 20px;
        }

        .description-card,
        .info-card,
        .tech-card {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            padding: 25px;
            box-shadow: var(--box-shadow);
            border: 1px solid var(--border-color);
        }

        .description-card {
            grid-row: span 2;
        }

        .card-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--border-color);
        }

        .card-icon {
            font-size: 20px;
        }

        .card-header h3 {
            font-size: 1.2rem;
            font-weight: bold;
            color: var(--text-dark);
            margin: 0;
        }

        .description-content {
            line-height: 1.8;
            color: var(--text-dark);
            white-space: pre-wrap;
            word-break: break-word;
            overflow-wrap: break-word;
        }

        /* 정보 그리드 */
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .info-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .info-label {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .info-value {
            font-size: 14px;
            color: var(--text-dark);
            font-weight: 600;
        }

        .project-link {
            color: var(--primary-color);
            text-decoration: none;
        }

        .project-link:hover {
            text-decoration: underline;
        }

        /* 태그 표시 */
        .tag-display {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .tag {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }

        .tag-category {
            background-color: #e6f3ff;
            color: #0066cc;
        }

        .tag-version {
            background-color: #f0f0f0;
            color: #666;
        }

        .tag-status {
            background-color: #f6ffed;
            color: #389e0d;
        }

        .tag-submitted {
            background-color: #fff2e8;
            color: #fa8c16;
        }

        /* 파일 섹션 */
        .files-section {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            padding: 25px;
            box-shadow: var(--box-shadow);
        }

        .files-header {
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--border-color);
        }

        .files-header h3 {
            font-size: 1.2rem;
            font-weight: bold;
            color: var(--text-dark);
            margin: 0;
        }

        .file-count {
            color: var(--text-muted);
            font-weight: normal;
            font-size: 0.9rem;
        }

        .files-grid {
            display: grid;
            gap: 15px;
        }

        .file-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 20px;
            background: var(--background-color);
            border-radius: 12px;
            transition: all 0.3s ease;
            border: 1px solid transparent;
        }

        .file-item:hover {
            background-color: #f0edff;
            border-color: var(--primary-color);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(108, 92, 231, 0.15);
        }

        .file-icon {
            font-size: 32px;
            width: 60px;
            height: 60px;
            text-align: center;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(255, 255, 255, 0.8);
            border-radius: 12px;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .file-item:hover .file-icon {
            transform: scale(1.05);
            box-shadow: 0 4px 15px rgba(0,0,0,0.15);
        }

        .file-info {
            flex: 1;
        }

        .file-name {
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 6px;
            font-size: 1rem;
        }

        .file-details {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .file-size {
            font-size: 13px;
            color: var(--text-muted);
            background-color: rgba(108, 92, 231, 0.1);
            padding: 2px 8px;
            border-radius: 12px;
        }

        .download-count {
            font-size: 13px;
            color: var(--text-muted);
        }

        .file-actions {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .file-actions .download-btn {
            background-color: var(--primary-color);
            color: white;
            padding: 10px 16px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border: none;
            cursor: pointer;
        }

        .file-actions .download-btn:hover {
            background-color: #5a4fcf;
            transform: translateY(-1px);
        }

        .preview-btn {
            background-color: var(--success-color);
            color: white;
            padding: 10px 16px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border: none;
            cursor: pointer;
        }

        .preview-btn:hover {
            background-color: #00a085;
            transform: translateY(-1px);
        }

        /* 파일이 없는 경우 */
        .no-files {
            text-align: center;
            padding: 60px 20px;
            color: var(--text-muted);
        }

        .no-files-icon {
            font-size: 3rem;
            margin-bottom: 15px;
            opacity: 0.5;
        }

        /* 파일 카테고리 */
        .files-category {
            margin-bottom: 30px;
        }

        .files-category:last-child {
            margin-bottom: 0;
        }

        .files-category .files-header h3 {
            color: var(--text-dark);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* 프로젝트 보고서 특별 스타일 */
        .file-item.project-report {
            border-left: 4px solid var(--primary-color);
            background: linear-gradient(135deg, rgba(108, 92, 231, 0.05), rgba(162, 155, 254, 0.03));
        }

        .file-item.project-report:hover {
            border-left-color: var(--secondary-color);
            background: linear-gradient(135deg, rgba(108, 92, 231, 0.1), rgba(162, 155, 254, 0.05));
        }

        /* 아카이브 파일 특별 스타일 */
        .file-item.archive-file {
            border-left: 4px solid var(--success-color);
            background: linear-gradient(135deg, rgba(0, 184, 148, 0.05), rgba(85, 239, 196, 0.03));
        }

        .file-item.archive-file:hover {
            border-left-color: #00a085;
            background: linear-gradient(135deg, rgba(0, 184, 148, 0.1), rgba(85, 239, 196, 0.05));
        }

        /* 파일 설명 */
        .file-description {
            font-size: 0.85em;
            color: var(--text-muted);
            margin-top: 4px;
            font-style: italic;
        }

        /* 파일 날짜 */
        .file-date {
            color: var(--text-muted);
            font-size: 0.85em;
        }

        /* 기타 탭 콘텐츠 */
        .progress-section,
        .team-section {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            padding: 25px;
            box-shadow: var(--box-shadow);
        }

        .progress-section h3,
        .team-section h3 {
            margin-bottom: 15px;
            color: var(--text-dark);
        }

        /* 프로젝트 정보 카드 */
        .project-info-card,
        .tasks-card,
        .team-info-card {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: var(--box-shadow);
        }

        .project-progress-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }

        .progress-item {
            background: rgba(108, 92, 231, 0.05);
            padding: 15px;
            border-radius: 8px;
            border-left: 4px solid var(--primary-color);
        }

        .progress-label {
            font-size: 0.9em;
            color: var(--text-muted);
            margin-bottom: 5px;
        }

        .progress-value {
            font-weight: 600;
            color: var(--text-dark);
            font-size: 1.1em;
        }

        /* 작업 목록 */
        .tasks-list {
            margin-top: 15px;
        }

        .task-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 12px;
            background: rgba(108, 92, 231, 0.03);
            border-radius: 8px;
            margin-bottom: 10px;
            border: 1px solid var(--border-color);
        }

        .task-status .status-badge {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
        }

        .status-TODO {
            background-color: #f8d7da;
            color: #721c24;
        }

        .status-IN_PROGRESS {
            background-color: #cce5ff;
            color: #004085;
        }

        .status-DONE {
            background-color: #d4edda;
            color: #155724;
        }

        .task-info {
            flex: 1;
        }

        .task-title {
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 4px;
        }

        .task-meta {
            font-size: 0.9em;
            color: var(--text-muted);
        }

        .more-tasks {
            text-align: center;
            padding: 10px;
        }

        .more-tasks a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 500;
        }

        .more-tasks a:hover {
            text-decoration: underline;
        }

        /* 팀 정보 */
        .team-members-grid {
            margin-top: 15px;
            margin-bottom: 25px;
        }

        .member-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px;
            background: rgba(108, 92, 231, 0.03);
            border-radius: 8px;
            margin-bottom: 10px;
            border: 1px solid var(--border-color);
        }

        .member-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1em;
            font-weight: 600;
            color: white;
            position: relative;
            text-transform: uppercase;
            transition: all 0.3s ease;
        }
        
        .member-avatar.leader-avatar {
            background: linear-gradient(135deg, #f39c12, #e67e22);
            border: 2px solid #f1c40f;
            box-shadow: 0 2px 8px rgba(243, 156, 18, 0.3);
        }
        
        .member-avatar.member-avatar {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
        }
        
        .crown-icon {
            position: absolute;
            top: -8px;
            right: -8px;
            font-size: 0.8em;
            background: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
        }
        
        .member-item:hover .member-avatar {
            transform: scale(1.05);
            box-shadow: 0 4px 15px rgba(0,0,0,0.15);
        }
        
        .member-item:hover .member-avatar.leader-avatar {
            box-shadow: 0 4px 15px rgba(243, 156, 18, 0.4);
        }

        .member-info {
            flex: 1;
        }

        .member-name {
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 4px;
        }

        .member-role {
            font-size: 0.9em;
            color: var(--text-muted);
        }

        .member-status {
            font-size: 0.9em;
        }

        .status-approved {
            color: var(--success-color);
            font-weight: 600;
        }

        .status-pending {
            color: var(--warning-color);
            font-weight: 600;
        }

        /* 팀 통계 */
        .team-stats {
            display: flex;
            gap: 20px;
            justify-content: center;
            padding: 20px;
            background: rgba(108, 92, 231, 0.05);
            border-radius: 8px;
        }

        .stat-item {
            text-align: center;
        }

        .stat-number {
            font-size: 2em;
            font-weight: bold;
            color: var(--primary-color);
            margin-bottom: 5px;
        }

        .stat-label {
            font-size: 0.9em;
            color: var(--text-muted);
        }

        /* 기자재 탭 스타일 */
        .equipment-section {
            margin-top: 20px;
        }

        .equipment-info-card {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            padding: 25px;
            box-shadow: var(--box-shadow);
            border: 1px solid var(--border-color);
        }

        .equipment-count {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8em;
            font-weight: 600;
            margin-left: auto;
        }

        .equipment-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .equipment-item {
            background: white;
            border: 2px solid #f1f3f4;
            border-radius: 12px;
            padding: 20px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .equipment-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15);
            border-color: #667eea;
        }

        .equipment-item::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, #667eea, #764ba2);
        }

        .equipment-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 15px;
        }

        .equipment-icon {
            font-size: 1.8em;
            background: linear-gradient(135deg, #667eea, #764ba2);
            background-clip: text;
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .equipment-name {
            font-size: 1.1em;
            font-weight: 700;
            color: var(--text-dark);
            flex: 1;
        }

        .quantity-badge {
            background: #e3f2fd;
            color: #1976d2;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 0.8em;
            font-weight: 600;
        }

        .equipment-details {
            margin: 15px 0;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            padding: 8px 0;
            border-bottom: 1px solid #f8f9fa;
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-label {
            display: flex;
            align-items: center;
            gap: 6px;
            color: var(--text-muted);
            font-size: 0.9em;
            min-width: 100px;
        }

        .detail-label i {
            color: #667eea;
            width: 14px;
        }

        .detail-value {
            color: var(--text-dark);
            font-weight: 500;
            text-align: right;
            flex: 1;
            margin-left: 10px;
        }

        .purpose-row {
            flex-direction: column;
            align-items: flex-start;
        }

        .purpose-text {
            margin-top: 8px;
            padding: 8px 12px;
            background: #f8f9fa;
            border-radius: 6px;
            font-size: 0.9em;
            line-height: 1.4;
            width: 100%;
            text-align: left;
        }

        .equipment-status {
            text-align: center;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #f1f3f4;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
        }

        .status-rented {
            background: #d4edda;
            color: #155724;
        }

        .equipment-summary {
            display: flex;
            gap: 30px;
            justify-content: center;
            margin-top: 30px;
            padding: 25px;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(118, 75, 162, 0.1));
            border-radius: 12px;
            border: 1px solid rgba(102, 126, 234, 0.2);
        }

        .summary-item {
            text-align: center;
        }

        .summary-number {
            font-size: 2.2em;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 8px;
            display: block;
        }

        .summary-label {
            font-size: 0.9em;
            color: var(--text-muted);
            font-weight: 500;
        }

        /* 정보 없음 상태 */
        .no-project-info,
        .no-team-info,
        .no-equipment-info {
            text-align: center;
            padding: 60px 20px;
            color: var(--text-muted);
        }

        .no-info-icon {
            font-size: 3rem;
            margin-bottom: 15px;
            opacity: 0.5;
        }

        /* 관리자 섹션 */
        .admin-section {
            background: var(--card-bg);
            border-radius: var(--border-radius);
            padding: 25px;
            box-shadow: var(--box-shadow);
            border-left: 4px solid var(--warning-color);
            margin-top: 20px;
        }

        .admin-section h3 {
            margin-bottom: 15px;
            color: var(--text-dark);
        }

        .approval-actions {
            display: flex;
            gap: 10px;
        }

        /* 하단 액션 버튼 */
        .bottom-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--card-bg);
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--box-shadow);
            margin-top: 20px;
        }

        /* 버튼 스타일 */
        .btn {
            padding: 10px 16px;
            border-radius: 6px;
            font-weight: 500;
            border: none;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            text-align: center;
            transition: all 0.2s;
            font-size: 14px;
        }

        .btn-outline {
            background-color: white;
            border: 1px solid var(--border-color);
            color: var(--text-dark);
        }

        .btn-outline:hover {
            background-color: var(--background-color);
        }

        .btn-success {
            background-color: var(--success-color);
            color: white;
        }

        .btn-success:hover {
            background-color: #00a085;
        }

        .btn-warning {
            background-color: var(--warning-color);
            color: white;
        }

        .btn-warning:hover {
            background-color: #e6b800;
        }

        .btn-danger {
            background-color: var(--danger-color);
            color: white;
        }

        .btn-danger:hover {
            background-color: #d63031;
        }

        /* 모달 */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
        }

        .modal-content {
            background-color: white;
            margin: 15% auto;
            padding: 0;
            border-radius: var(--border-radius);
            width: 400px;
            max-width: 90%;
            box-shadow: var(--box-shadow);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px;
            border-bottom: 1px solid var(--border-color);
        }

        .modal-header h4 {
            margin: 0;
            color: var(--text-dark);
        }

        .modal-close {
            font-size: 24px;
            cursor: pointer;
            color: var(--text-muted);
        }

        .modal-close:hover {
            color: var(--text-dark);
        }

        .modal-body {
            padding: 20px;
        }

        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            padding: 20px;
            border-top: 1px solid var(--border-color);
        }

        /* 미리보기 모달 */
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

        /* 반응형 */
        @media (max-width: 1024px) {
            .content-grid {
                grid-template-columns: 1fr;
            }

            .project-header {
                flex-direction: column;
                gap: 20px;
            }

            .project-actions {
                width: 100%;
                justify-content: space-between;
            }

            .action-btn {
                flex: 1;
                justify-content: center;
                min-width: 0;
            }
        }

        @media (max-width: 768px) {
            .archive-detail-page {
                padding: 10px;
            }

            .project-header {
                padding: 20px;
            }

            .project-title {
                font-size: 1.5rem;
            }

            .project-meta {
                flex-direction: column;
                gap: 10px;
            }

            .tab-navigation {
                flex-direction: column;
                gap: 4px;
            }

            .tab-item {
                padding: 12px 16px;
            }

            .content-grid {
                gap: 15px;
            }

            .info-grid {
                grid-template-columns: 1fr;
            }

            .file-item {
                flex-direction: column;
                text-align: center;
                gap: 12px;
            }

            .file-details {
                justify-content: center;
            }

            .file-actions {
                flex-direction: column;
                width: 100%;
            }

            .file-actions .download-btn,
            .preview-btn {
                width: 100%;
                justify-content: center;
            }

            .approval-actions {
                flex-direction: column;
            }

            .action-btn {
                padding: 10px 16px;
                font-size: 13px;
            }

            .bottom-actions {
                flex-direction: column;
                gap: 10px;
            }

            .equipment-grid {
                grid-template-columns: 1fr;
            }

            .equipment-summary {
                flex-direction: column;
                gap: 15px;
            }

            .detail-row {
                flex-direction: column;
                align-items: flex-start;
                gap: 4px;
            }

            .detail-value {
                text-align: left;
                margin-left: 0;
            }
        }

        @media (max-width: 480px) {
            .project-actions {
                flex-direction: column;
            }

            .action-btn {
                width: 100%;
            }

            .modal-content {
                width: 95%;
                margin: 10% auto;
            }
        }
    </style>

    <!-- 4) 공통 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>
    
    <script>
        // 탭 전환 기능
        document.addEventListener('DOMContentLoaded', function() {
            const tabItems = document.querySelectorAll('.tab-item');
            const tabContents = document.querySelectorAll('.tab-content');

            tabItems.forEach(item => {
                item.addEventListener('click', function() {
                    const targetTab = this.getAttribute('data-tab');

                    // 모든 탭 비활성화
                    tabItems.forEach(tab => tab.classList.remove('active'));
                    tabContents.forEach(content => content.classList.remove('active'));

                    // 선택된 탭 활성화
                    this.classList.add('active');
                    document.getElementById(targetTab + '-content').classList.add('active');
                });
            });
        });

        // 삭제 확인 모달 열기
        function confirmDelete() {
            document.getElementById('deleteModal').style.display = 'block';
        }

        // 삭제 확인 모달 닫기
        function closeDeleteModal() {
            document.getElementById('deleteModal').style.display = 'none';
        }

        // 실제 삭제 실행
        function deleteArchive() {
            const archiveId = '${archive.id}';
            
            // AJAX로 삭제 요청
            fetch('${pageContext.request.contextPath}/archive/delete/' + archiveId, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                }
            })
            .then(response => {
                if (response.ok) {
                    alert('아카이브가 삭제되었습니다.');
                    location.href = '${pageContext.request.contextPath}/archive/list';
                } else {
                    throw new Error('삭제 실패');
                }
            })
            .catch(error => {
                alert('삭제 중 오류가 발생했습니다.');
                console.error('Error:', error);
            });
        }

        // 관리자 승인 기능
        function approveArchive() {
            if (confirm('이 아카이브를 승인하시겠습니까?')) {
                const archiveId = '${archive.id}';
                
                fetch('${pageContext.request.contextPath}/archive/approve/' + archiveId, {
                    method: 'POST'
                })
                .then(response => {
                    if (response.ok) {
                        alert('승인되었습니다.');
                        location.reload();
                    } else {
                        throw new Error('승인 실패');
                    }
                })
                .catch(error => {
                    alert('승인 중 오류가 발생했습니다.');
                    console.error('Error:', error);
                });
            }
        }

        // 관리자 반려 기능
        function rejectArchive() {
            if (confirm('이 아카이브를 반려하시겠습니까?')) {
                const archiveId = '${archive.id}';
                
                fetch('${pageContext.request.contextPath}/archive/reject/' + archiveId, {
                    method: 'POST'
                })
                .then(response => {
                    if (response.ok) {
                        alert('반려되었습니다.');
                        location.reload();
                    } else {
                        throw new Error('반려 실패');
                    }
                })
                .catch(error => {
                    alert('반려 중 오류가 발생했습니다.');
                    console.error('Error:', error);
                });
            }
        }

        // 모달 외부 클릭시 닫기
        window.onclick = function(event) {
            const modal = document.getElementById('deleteModal');
            if (event.target == modal) {
                modal.style.display = 'none';
            }
            
            const previewModal = document.getElementById('previewModal');
            if (event.target == previewModal) {
                closePreviewModal();
            }
        }

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

        // 파일 다운로드 함수
        function downloadFile(fileId, fileName, originalFileName) {
            const contextPath = '${pageContext.request.contextPath}';
            const encodedFileName = encodeURIComponent(fileName);
            const encodedOriginalFileName = encodeURIComponent(originalFileName);
            
            let downloadUrl = contextPath + '/archive/download?file=' + encodedFileName + '&original=' + encodedOriginalFileName;
            
            // 파일 ID가 있는 경우 추가 (다운로드 카운트 증가용)
            if (fileId) {
                downloadUrl += '&fileId=' + fileId;
            }
            
            // 새 창에서 다운로드 링크 열기
            window.open(downloadUrl, '_blank');
        }
    </script>
</body>
</html>