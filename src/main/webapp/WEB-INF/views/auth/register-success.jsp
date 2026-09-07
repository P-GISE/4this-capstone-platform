<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>회원가입 완료 - AI 캡스톤디자인 관리시스템</title>
    <style>
        :root {
            --primary-color: #4751c9;
            --success-color: #28a745;
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
        .success-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            padding: 50px;
            text-align: center;
            max-width: 600px;
            width: 100%;
        }
        .success-icon {
            width: 100px;
            height: 100px;
            background: var(--success-color);
            border-radius: 50%;
            margin: 0 auto 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 50px;
            color: white;
        }
        .success-title {
            font-size: 32px;
            font-weight: bold;
            color: var(--success-color);
            margin-bottom: 20px;
        }
        .success-message {
            font-size: 18px;
            color: #666;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .email-info {
            background: #f8f9ff;
            border: 2px solid #e3e7ff;
            border-radius: 12px;
            padding: 25px;
            margin: 30px 0;
        }
        .email-info-title {
            font-size: 20px;
            font-weight: bold;
            color: var(--primary-color);
            margin-bottom: 15px;
        }
        .email-address {
            font-size: 16px;
            color: #333;
            background: white;
            padding: 10px 15px;
            border-radius: 8px;
            margin: 10px 0;
            word-break: break-all;
        }
        .email-steps {
            text-align: left;
            margin: 20px 0;
        }
        .email-step {
            display: flex;
            align-items: center;
            margin: 10px 0;
            font-size: 14px;
            color: #666;
        }
        .step-number {
            background: var(--primary-color);
            color: white;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: bold;
            margin-right: 10px;
            flex-shrink: 0;
        }
        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            flex-wrap: wrap;
            margin-top: 30px;
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
        .warning-box {
            background: #fff3cd;
            border: 1px solid #fdeaa7;
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
            color: #856404;
            font-size: 14px;
        }
        .resend-form {
            margin-top: 20px;
        }
        .resend-btn {
            background: transparent;
            border: 2px solid var(--primary-color);
            color: var(--primary-color);
            padding: 10px 25px;
            border-radius: 8px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .resend-btn:hover {
            background: var(--primary-color);
            color: white;
        }
        @media (max-width: 768px) {
            .success-container {
                padding: 30px 20px;
            }
            .action-buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="success-container">
        <div class="success-icon">✓</div>
        <h1 class="success-title">회원가입 완료!</h1>
        <p class="success-message">
            AI 캡스톤디자인 관리시스템에 가입해주셔서 감사합니다.<br>
            이메일 인증을 완료하시면 모든 서비스를 이용하실 수 있습니다.
        </p>
        
        <div class="email-info">
            <div class="email-info-title">📧 이메일 인증 안내</div>
            <p>다음 이메일 주소로 인증 링크를 발송했습니다:</p>
            <div class="email-address">${userEmail}</div>
            
            <div class="email-steps">
                <div class="email-step">
                    <span class="step-number">1</span>
                    <span>이메일 수신함을 확인해주세요 (스팸함도 확인)</span>
                </div>
                <div class="email-step">
                    <span class="step-number">2</span>
                    <span>"이메일 인증하기" 버튼을 클릭해주세요</span>
                </div>
                <div class="email-step">
                    <span class="step-number">3</span>
                    <span>인증 완료 후 로그인해주세요</span>
                </div>
            </div>
        </div>
        
        <div class="warning-box">
            ⚠️ <strong>중요:</strong> 이메일 인증을 완료해야 로그인이 가능합니다.<br>
            인증 링크는 24시간 후 만료됩니다.
        </div>
        
        <div class="action-buttons">
            <a href="/auth/login" class="btn btn-primary">로그인 페이지로</a>
            <a href="https://mail.google.com" target="_blank" class="btn btn-secondary">Gmail 열기</a>
        </div>
        
        <div class="resend-form">
            <p style="color: #666; font-size: 14px; margin-bottom: 10px;">이메일을 받지 못하셨나요?</p>
            <form action="/auth/resend-verification" method="post" style="display: inline;">
                <input type="hidden" name="email" value="${userEmail}">
                <button type="submit" class="resend-btn">인증 이메일 재발송</button>
            </form>
        </div>
    </div>
</body>
</html> 