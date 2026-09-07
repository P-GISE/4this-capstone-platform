<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/layout/head-meta.jsp" %>
    <title>프로젝트 목록</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
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

        
        .page-title {
            font-size: 24px;
            font-weight: 600;
            color: #333;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f1f3f4;
        }
        
        .header-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .create-btn {
            background-color: #4285f4;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
            transition: background-color 0.2s;
        }
        
        .create-btn:hover {
            background-color: #3367d6;
            color: white;
            text-decoration: none;
        }
        
        .project-table {
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            overflow: hidden;
            border: 1px solid #e0e0e0;
        }
        
        .table-header {
            background-color: #f8f9fa;
            border-bottom: 1px solid #e0e0e0;
            padding: 15px 20px;
            display: flex;
            font-weight: 600;
            color: #5f6368;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .table-header .col-name {
            flex: 3;
        }
        
        .table-header .col-description {
            flex: 4;
        }
        
        .table-header .col-role {
            flex: 1;
            text-align: center;
        }
        
        .project-row {
            display: flex;
            align-items: center;
            padding: 20px;
            border-bottom: 1px solid #f1f3f4;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        
        .project-row:hover {
            background-color: #f8f9fa;
        }
        
        .project-row:last-child {
            border-bottom: none;
        }
        
        .project-name {
            flex: 3;
            font-weight: 500;
            color: #333;
            font-size: 16px;
        }
        
        .project-description {
            flex: 4;
            color: #666;
            font-size: 14px;
            line-height: 1.4;
            padding-right: 20px;
        }
        
        .project-role {
            flex: 1;
            text-align: center;
        }
        
        .role-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
        }
        
        .role-leader {
            background-color: #e8f0fe;
            color: #1a73e8;
        }
        
        .role-member {
            background-color: #e6f4ea;
            color: #137333;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #666;
            background: white;
            border-radius: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
        }
        
        .empty-icon {
            font-size: 48px;
            margin-bottom: 20px;
            color: #dadce0;
        }
        
        .empty-title {
            font-size: 18px;
            font-weight: 500;
            color: #333;
            margin-bottom: 10px;
        }
        
        .empty-text {
            font-size: 14px;
            color: #666;
            margin-bottom: 30px;
        }
        
        .empty-btn {
            background-color: #4285f4;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
            transition: background-color 0.2s;
        }
        
        .empty-btn:hover {
            background-color: #3367d6;
            color: white;
            text-decoration: none;
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
            <div class="header-actions">
                <h1 class="page-title">내 프로젝트 목록</h1>
                <a href="${pageContext.request.contextPath}/projects/create" class="create-btn">새 프로젝트 생성</a>
            </div>

            <c:if test="${empty projects}">
                <div class="empty-state">
                    <div class="empty-icon">📋</div>
                    <div class="empty-title">참여중인 프로젝트가 없습니다</div>
                    <div class="empty-text">새로운 프로젝트를 생성해서 시작해보세요.</div>
                    <a href="${pageContext.request.contextPath}/projects/create" class="empty-btn">프로젝트 생성하기</a>
                </div>
            </c:if>

            <c:if test="${not empty projects}">
                <div class="project-table">
                    <div class="table-header">
                        <div class="col-name">프로젝트 이름</div>
                        <div class="col-description">설명</div>
                        <div class="col-role">역할</div>
                    </div>
                    
                    <c:forEach var="project" items="${projects}">
                        <div class="project-row" onclick="location.href='${pageContext.request.contextPath}/projects/${project.id}'">
                            <div class="project-name">${project.title}</div>
                            <div class="project-description">${project.description}</div>
                            <div class="project-role">
                                <c:choose>
                                    <c:when test="${project.role == 'LEADER'}">
                                        <span class="role-badge role-leader">팀장</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="role-badge role-member">팀원</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:if>
        </div>

        <%@ include file="/WEB-INF/views/layout/footer.jsp" %>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.4/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html> 