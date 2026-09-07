<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>테스트 페이지</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .debug-info {
            background: #e8f4fd;
            padding: 15px;
            margin: 10px 0;
            border-radius: 6px;
            border: 1px solid #bee5eb;
        }
        .status {
            color: green;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚨 특별 대여 신청 관리 - 테스트 페이지</h1>
        
        <div class="debug-info">
            <h3>🔍 시스템 상태 확인</h3>
            <p class="status">✅ 페이지가 정상적으로 로드되었습니다.</p>
            <p>현재 시간: <%= new java.util.Date() %></p>
            <p>요청 URI: ${pageContext.request.requestURI}</p>
            <p>세션 ID: ${pageContext.session.id}</p>
        </div>
        
        <div class="debug-info">
            <h3>📊 데이터 상태</h3>
            <p>총 신청 수: ${totalCount != null ? totalCount : '0'}</p>
            <p>승인 대기 수: ${pendingCount != null ? pendingCount : '0'}</p>
            <p>긴급 신청 수: ${emergencyCount != null ? emergencyCount : '0'}</p>
            <p>요청 목록 크기: ${requests != null ? requests.size() : 'null'}</p>
        </div>
        
        <div style="margin-top: 20px;">
            <a href="/special-rental/admin/list" style="padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 4px;">
                실제 관리 페이지로 이동
            </a>
        </div>
    </div>
</body>
</html> 