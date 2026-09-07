<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>이메일 인증 결과 - AI 캡스톤디자인 관리시스템</title>
    <style>
        :root {
            --primary-color: #4751c9;
            --success-color: #28a745;
            --error-color: #dc3545;
            --light-color: #ffffff;
            --grey-color: #f5f5f7;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Noto Sans KR', sans-serif; }
        body { 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh; 
            display: flex; 
            align-items: center; 
            justify-content: center;
            padding: 20px;
        }
        .verification-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            padding: 50px;
            text-align: center;
            max-width: 500px;
            width: 100%;
        }
        .verification-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            margin: 0 auto 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            color: white;
        }
        .verification-icon.success {
            background: var(--success-color);
        }
        .verification-icon.error {
            background: var(--error-color);
        }
        .verification-title {
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 20px;
        }
        .verification-title.success {
            color: var(--success-color);
        }
        .verification-title.error {
            color: var(--error-color);
        }
        .verification-message {
            font-size: 16px;
            color: #666;
            line-height: 1.6;
            margin-bottom: 40px;
        }
        .verification-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            text-decoration: none;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        .btn-primary {
            background: var(--primary-color);
            color: white;
        }
        .btn-primary:hover {
            background: #3640a8;
            transform: translateY(-2px);
        }
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        .btn-secondary:hover {
            background: #545b62;
            transform: translateY(-2px);
        }
        @media (max-width: 768px) {
            .verification-container {
                padding: 30px 20px;
            }
            .verification-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="verification-container">
        <c:choose>
            <c:when test="${verificationSuccess}">
                <div class="verification-icon success">✓</div>
                <h1 class="verification-title success">인증 성공!</h1>
                <p class="verification-message">
                    이메일 인증이 성공적으로 완료되었습니다.<br>
                    이제 AI 캡스톤디자인 관리시스템에 로그인하실 수 있습니다.
                </p>
                <div class="verification-actions">
                    <a href="/auth/login" class="btn btn-primary">로그인하기</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="verification-icon error">✗</div>
                <h1 class="verification-title error">인증 실패</h1>
                <p class="verification-message">
                    이메일 인증에 실패했습니다.<br>
                    인증 링크가 만료되었거나 유효하지 않을 수 있습니다.<br>
                    다시 시도해보시거나 새로운 인증 이메일을 요청해주세요.
                </p>
                <div class="verification-actions">
                    <a href="/auth/login" class="btn btn-primary">로그인 페이지로</a>
                    <a href="/auth/register" class="btn btn-secondary">회원가입</a>
                </div>
            </c:otherwise>
        </c:choose>
        
        <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
            <p style="color: #999; font-size: 14px;">
                문제가 지속되면 관리자에게 문의하세요.<br>
                <a href="mailto:admin@ibetter.kr" style="color: var(--primary-color);">admin@ibetter.kr</a>
            </p>
        </div>
    </div>
</body>
</html> 