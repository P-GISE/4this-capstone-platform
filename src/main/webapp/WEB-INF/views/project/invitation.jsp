<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/layout/head-meta.jsp" %>
    <title>프로젝트 초대</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        .invitation-container {
            max-width: 600px;
            margin: 100px auto;
            padding: 40px;
            background: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            text-align: center;
        }
        .invitation-icon {
            font-size: 4rem;
            color: #007bff;
            margin-bottom: 20px;
        }
        .project-title {
            font-size: 1.8rem;
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
        }
        .invitation-message {
            font-size: 1.1rem;
            color: #666;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        .project-description {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            color: #555;
        }
        .btn-group-custom {
            display: flex;
            gap: 15px;
            justify-content: center;
        }
        .btn-accept {
            background: linear-gradient(135deg, #28a745, #20c997);
            border: none;
            color: white;
            padding: 12px 30px;
            font-weight: 500;
            border-radius: 6px;
            transition: all 0.3s ease;
        }
        .btn-accept:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(40, 167, 69, 0.3);
            color: white;
        }
        .btn-decline {
            background: linear-gradient(135deg, #dc3545, #c82333);
            border: none;
            color: white;
            padding: 12px 30px;
            font-weight: 500;
            border-radius: 6px;
            transition: all 0.3s ease;
        }
        .btn-decline:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(220, 53, 69, 0.3);
            color: white;
        }
    </style>
</head>
<body style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
    <div class="invitation-container">
        <div class="invitation-icon">
            🎯
        </div>
        
        <h1 class="project-title">${project.title}</h1>
        
        <p class="invitation-message">
            프로젝트 팀원으로 초대되었습니다!<br>
            함께 프로젝트를 진행하시겠습니까?
        </p>
        
        <c:if test="${not empty project.description}">
        <div class="project-description">
            <strong>프로젝트 설명:</strong><br>
            ${project.description}
        </div>
        </c:if>
        
        <div class="btn-group-custom">
            <form action="${pageContext.request.contextPath}/projects/invitation/${project.id}/respond" method="post" style="display: inline;">
                <input type="hidden" name="accept" value="true">
                <button type="submit" class="btn btn-accept">
                    ✅ 참여하기
                </button>
            </form>
            
            <form action="${pageContext.request.contextPath}/projects/invitation/${project.id}/respond" method="post" style="display: inline;">
                <input type="hidden" name="accept" value="false">
                <button type="submit" class="btn btn-decline">
                    ❌ 거절하기
                </button>
            </form>
        </div>
        
        <div class="mt-4">
            <small class="text-muted">
                신중하게 결정해주세요. 이 결정은 되돌릴 수 없습니다.
            </small>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html> 