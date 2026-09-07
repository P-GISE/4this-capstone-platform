<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>접근 권한 없음</title>
    <style>
        body {
            font-family: sans-serif;
            text-align: center;
            margin-top: 100px;
        }
        .message {
            color: #c00;
            font-size: 1.2em;
            margin-bottom: 20px;
        }
        a {
            text-decoration: none;
            color: #06c;
        }
    </style>
</head>
<body>
    <div class="message">
        <strong>접근 권한이 없습니다</strong><br/>
        이 기능은 관리자만 이용할 수 있습니다.
    </div>
    <a href="${pageContext.request.contextPath}/equipment/list">목록으로 돌아가기</a>
</body>
</html>
