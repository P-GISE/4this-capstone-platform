<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/layout/head-meta.jsp" %>
    <title>프로젝트 초대 완료</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background-color: #f8fafc;
            min-height: 100vh;
            padding: 60px 20px 40px;
            color: #1e293b;
        }

        .page-container {
            max-width: 480px;
            margin: 0 auto;
        }

        .completed-container {
            background: white;
            border-radius: 16px;
            padding: 40px 32px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.04);
            border: 1px solid #e2e8f0;
            text-align: center;
        }

        .completed-icon {
            width: 72px;
            height: 72px;
            background: #10b981;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
            font-size: 2rem;
            color: white;
        }

        .project-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: #0f172a;
            margin-bottom: 8px;
            line-height: 1.4;
            word-break: keep-all;
        }

        .completed-message {
            font-size: 1rem;
            color: #64748b;
            margin-bottom: 24px;
            line-height: 1.5;
        }

        .status-badge {
            background: #f0fdf4;
            color: #166534;
            padding: 12px 20px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-weight: 500;
            border: 1px solid #bbf7d0;
            font-size: 0.95rem;
        }

        .project-description {
            background: #f8fafc;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 32px;
            text-align: left;
            border: 1px solid #e2e8f0;
        }

        .project-description .label {
            font-weight: 600;
            color: #374151;
            margin-bottom: 8px;
            font-size: 0.9rem;
        }

        .project-description .content {
            color: #6b7280;
            line-height: 1.6;
            font-size: 0.95rem;
        }

        .action-buttons {
            display: flex;
            gap: 12px;
            justify-content: center;
            margin-bottom: 24px;
            flex-wrap: wrap;
        }

        .btn-custom {
            padding: 12px 24px;
            font-weight: 500;
            border-radius: 8px;
            border: none;
            font-size: 0.9rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
            min-width: 140px;
            justify-content: center;
        }

        .btn-primary {
            background: #3b82f6;
            color: white;
        }

        .btn-primary:hover {
            background: #2563eb;
            color: white;
            text-decoration: none;
            transform: translateY(-1px);
        }

        .btn-secondary {
            background: #10b981;
            color: white;
        }

        .btn-secondary:hover {
            background: #059669;
            color: white;
            text-decoration: none;
            transform: translateY(-1px);
        }

        .footer-note {
            font-size: 0.85rem;
            color: #94a3b8;
            font-weight: 400;
        }

        /* 반응형 디자인 */
        @media (max-width: 576px) {
            body {
                padding: 40px 16px 24px;
            }
            
            .completed-container {
                padding: 32px 24px;
            }
            
            .project-title {
                font-size: 1.3rem;
            }
            
            .action-buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .btn-custom {
                width: 100%;
                max-width: 100px;
            }
        }

        /* 호버 효과 */
        .completed-container:hover {
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
            transition: box-shadow 0.3s ease;
        }

        /* 아이콘 애니메이션 */
        .completed-icon {
            animation: fadeInScale 0.6s ease-out;
        }

        @keyframes fadeInScale {
            0% {
                opacity: 0;
                transform: scale(0.8);
            }
            100% {
                opacity: 1;
                transform: scale(1);
            }
        }
    </style>
</head>
<body>
    <div class="page-container">
        <div class="completed-container">
            <div class="completed-icon">
                ✓
            </div>
            
            <h1 class="project-title">${project.title}</h1>
            
            <p class="completed-message">
                이미 처리 완료된 프로젝트 초대입니다.
            </p>
            
            <div class="status-badge">
                <c:choose>
                    <c:when test="${invitationStatus == 'ACCEPTED'}">
                        🎉 이미 이 프로젝트에 참여하고 있습니다!
                    </c:when>
                    <c:otherwise>
                        📝 이 초대에 대한 응답이 완료되었습니다.
                    </c:otherwise>
                </c:choose>
            </div>
            
            <c:if test="${not empty project.description}">
                <div class="project-description">
                    <div class="label">프로젝트 설명</div>
                    <div class="content">${project.description}</div>
                </div>
            </c:if>
            
            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/dashboard" class="btn-custom btn-primary">
                    🏠 대시보드
                </a>
                <c:if test="${invitationStatus == 'ACCEPTED'}">
                    <a href="${pageContext.request.contextPath}/projects" class="btn-custom btn-secondary">
                        📋 내 프로젝트
                    </a>
                </c:if>
            </div>
            
            <div class="footer-note">
                더 이상 추가 작업이 필요하지 않습니다.
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
</body>
</html>