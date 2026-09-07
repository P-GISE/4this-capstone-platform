<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<%@ include file="../layout/head-meta.jsp" %>
<link rel="stylesheet" href="/css/notice-detail.css">
<style>

    
    .detail-card { background: white; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
    .detail-header { padding: 20px; border-bottom: 1px solid #eaeaea; }
    .notice-title { font-size: 1.3rem; font-weight: bold; margin-bottom: 15px; }
    .notice-meta { display: flex; flex-wrap: wrap; gap: 20px; font-size: 0.9rem; color: #666; }
    .meta-label { font-weight: 500; color: #444; }
    .category-badge { background: #4751c9; color: white; padding: 3px 8px; border-radius: 12px; font-size: 0.8rem; }
    .detail-content { padding: 30px; }
    .content-text { 
        line-height: 1.8; 
        white-space: pre-line; 
        word-wrap: break-word;
        word-break: break-word;
        overflow-wrap: break-word;
    }
    .action-buttons { display: flex; justify-content: space-between; padding: 20px; background: #f8f9fa; }
    .btn { padding: 10px 15px; border-radius: 5px; font-weight: 500; border: none; text-decoration: none; }
    .btn-outline { background: white; border: 1px solid #ddd; color: #333; }
    .btn-primary { background: #4751c9; color: white; }
    .btn-danger { background: #dc3545; color: white; }
    .file-section { padding: 0 30px 20px; }
    .file-section ul { list-style: none; padding-left: 0; }
    .file-section li { margin: 5px 0; }

    * {
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


    .image-section {
        padding: 20px 30px;
        border-bottom: 1px solid #f0f0f0;
        margin-bottom: 20px;
    }

    .image-preview {
        max-width: 100%;
        height: auto;
        border: 1px solid #ddd;
        border-radius: 8px;
        margin: 10px 0;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    
    .image-container {
        text-align: center;
        margin: 15px 0;
        padding: 10px;
        background-color: #ffffff;
        border-radius: 8px;
    }
    
    .image-filename {
        font-size: 0.9rem;
        color: #666;
        margin-top: 8px;
        font-style: italic;
    }
    
    .download-link {
        display: inline-flex;
        align-items: center;
        padding: 8px 12px;
        background-color: #f0f2f5;
        border-radius: 5px;
        text-decoration: none;
        color: #333;
        transition: background-color 0.2s;
        margin: 5px 0;
    }
    
    .download-link:hover {
        background-color: #e9ecef;
        text-decoration: none;
        color: #333;
    }
</style>
<body>
<%@ include file="../layout/sidebar.jsp" %>
<div class="content">
    <%@ include file="../layout/header.jsp" %>
    <div class="main-body">
        <h2 class="section-title">공지사항 상세보기</h2>

        <div class="detail-card">
            <div class="detail-header">
                <h3 class="notice-title">${notice.title}</h3>
                <div class="notice-meta">
                    <span><strong class="meta-label">카테고리:</strong> <span class="category-badge">${notice.category}</span></span>
                    <span><strong class="meta-label">작성자:</strong> ${notice.writerName}</span>
                    <span><strong class="meta-label">작성일:</strong> <fmt:formatDate value="${notice.createdAt}" pattern="yyyy-MM-dd HH:mm"/></span>
                    <span><strong class="meta-label">조회수:</strong> ${notice.viewCount}</span>
                    <span><strong class="meta-label">공개대상:</strong> 
                        <c:choose>
                            <c:when test="${notice.targetRole == 'STUDENT'}">학생</c:when>
                            <c:when test="${notice.targetRole == 'PROFESSOR'}">교수</c:when>
                            <c:when test="${notice.targetRole == 'ASSISTANT'}">조교</c:when>
                            <c:when test="${notice.targetRole == 'ADMIN'}">관리자</c:when>
                            <c:when test="${notice.targetRole == 'ALL'}">전체</c:when>
                            <c:otherwise>${notice.targetRole}</c:otherwise>
                        </c:choose>
                    </span>
                    <c:if test="${notice.visibleFrom != null && notice.visibleUntil != null}">
                        <span><strong class="meta-label">공개기간:</strong>
                            <fmt:formatDate value="${notice.visibleFrom}" pattern="yyyy-MM-dd" /> ~ 
                            <fmt:formatDate value="${notice.visibleUntil}" pattern="yyyy-MM-dd" />
                        </span>
                    </c:if>
                </div>
            </div>

            <div class="detail-content">
                <div class="content-text">${notice.content}</div>
            </div>

            <c:if test="${not empty attachments}">
                <c:set var="hasImages" value="false" />
                <c:set var="hasFiles" value="false" />

                <c:forEach var="file" items="${attachments}">
                    <c:set var="fileExtension" value="${fn:toLowerCase(fn:substringAfter(file.originalFileName, '.'))}" />
                    <c:if test="${fileExtension == 'jpg' || fileExtension == 'jpeg' || fileExtension == 'png' || fileExtension == 'gif' || fileExtension == 'bmp' || fileExtension == 'webp'}">
                        <c:set var="hasImages" value="true" />
                    </c:if>
                    <c:if test="${!(fileExtension == 'jpg' || fileExtension == 'jpeg' || fileExtension == 'png' || fileExtension == 'gif' || fileExtension == 'bmp' || fileExtension == 'webp')}">
                        <c:set var="hasFiles" value="true" />
                    </c:if>
                </c:forEach>

                <c:if test="${hasImages}">
                    <div class="image-section">
                        <c:forEach var="file" items="${attachments}">
                            <c:set var="fileExtension" value="${fn:toLowerCase(fn:substringAfter(file.originalFileName, '.'))}" />
                            <c:if test="${fileExtension == 'jpg' || fileExtension == 'jpeg' || fileExtension == 'png' || fileExtension == 'gif' || fileExtension == 'bmp' || fileExtension == 'webp'}">
                                <c:url var="downloadUrl" value="/notice/download">
                                    <c:param name="file" value="${file.fileName}" />
                                    <c:param name="original" value="${file.originalFileName}" />
                                </c:url>
                                <div class="image-container">
                                    <img src="${downloadUrl}" alt="${file.originalFileName}" class="image-preview"
                                         onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                                    <div style="display:none;">
                                        <a href="${downloadUrl}" class="download-link">📎 ${file.originalFileName} (이미지 로드 실패 - 다운로드)</a>
                                    </div>
                                    <div style="margin-top: 10px;">
                                        <a href="${downloadUrl}" class="download-link">💾 다운로드</a>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </c:if>

                <c:if test="${hasFiles}">
                    <div class="file-section">
                        <strong>첨부파일:</strong>
                        <ul>
                            <c:forEach var="file" items="${attachments}">
                                <c:set var="fileExtension" value="${fn:toLowerCase(fn:substringAfter(file.originalFileName, '.'))}" />
                                <c:if test="${!(fileExtension == 'jpg' || fileExtension == 'jpeg' || fileExtension == 'png' || fileExtension == 'gif' || fileExtension == 'bmp' || fileExtension == 'webp')}">
                                    <c:url var="downloadUrl" value="/notice/download">
                                        <c:param name="file" value="${file.fileName}" />
                                        <c:param name="original" value="${file.originalFileName}" />
                                    </c:url>
                                    <li>
                                        <a href="${downloadUrl}" class="download-link">📎 ${file.originalFileName}</a>
                                    </li>
                                </c:if>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>
            </c:if>

            <div class="action-buttons">
                <div>
                    <a href="/notice/list" class="btn btn-outline">목록으로</a>
                </div>
                <div>
                    <c:if test="${userRole != 'STUDENT' && loginUser.id == notice.writerId}">
                        <a href="/notice/edit?id=${notice.id}" class="btn btn-primary">수정</a>
                        <form action="/notice/delete" method="post" style="display:inline;" onsubmit="return confirm('정말로 삭제하시겠습니까?');">
                            <input type="hidden" name="id" value="${notice.id}" />
                            <button type="submit" class="btn btn-danger">삭제</button>
                        </form>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
    <%@ include file="../layout/footer.jsp" %>
</div>
</body>
</html>
