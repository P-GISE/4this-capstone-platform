<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page session="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setCharacterEncoding("UTF-8"); %>
<% request.setAttribute("title", "AI 기술지원 - 프로젝트 추천"); %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<body>
    <!-- 사이드바 -->
    <%@ include file="../layout/sidebar.jsp" %>

    <!-- 메인 콘텐츠 -->
    <div class="content">
        <!-- 헤더 -->
        <%@ include file="../layout/header.jsp" %>

        <!-- 본문 영역 -->
        <div class="main-body">
            <style>
                /* 폰트 설정 */
                @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;800&display=swap');
                
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
                
                /* main-body 패딩 조정 (AI 페이지는 자체 레이아웃 사용) */
                .main-body {
                    padding: 20px !important;
                }
                
                /* 푸터 여백 제거 (AI 페이지용) */
                footer.footer {
                    width: calc(100% + 40px) !important;
                    margin-left: -20px !important;
                    margin-right: -20px !important;
                }
                
                /* AI 페이지 전용 스타일 */
                :root {
                    --primary-color: #2563eb;
                    --primary-dark: #1d4ed8;
                    --primary-light: #eff6ff;
                    --secondary-color: #64748b;
                    --secondary-light: #f1f5f9;
                    --dark-color: #5372a4;
                    --light-color: #ffffff;
                    --grey-color: #f8fafc;
                    --text-color: #334155;
                    --text-light: #64748b;
                    --text-muted: #94a3b8;
                    --border-color: #e2e8f0;
                    --border-light: #f1f5f9;
                    --success-color: #059669;
                    --warning-color: #d97706;
                    --error-color: #dc2626;
                    --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
                    --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
                    --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
                    --transition: all 0.2s ease-in-out;
                }

        /* 메인 컨테이너 */
        .ai-container {
            display: flex !important;
            gap: 24px;
            background: var(--light-color);
            border-radius: 12px;
            overflow: visible !important;
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--border-light);
            margin-bottom: 40px;
            height: 850px;
        }

        /* 왼쪽 영역 - 프로젝트 추천 폼 */
        .project-request-section {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: var(--light-color);
            border-right: 1px solid var(--border-color);
        }

        .project-header {
            background: #3e516b;
            color: var(--light-color);
            padding: 24px 32px;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .project-header h1 {
            font-size: 1.5rem;
            font-weight: 700;
            margin: 0;
            letter-spacing: -0.025em;
        }

        .project-header .header-icon {
            font-size: 1.5rem;
        }

        .project-form {
            padding: 20px;
            flex: 1;
            overflow-y: auto;
            max-height: calc(100% - 80px);
        }

        .form-section {
            margin-bottom: 20px;
        }

        .form-section h3 {
            color: var(--dark-color);
            font-size: 1rem;
            margin-bottom: 10px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 8px;
            letter-spacing: -0.025em;
        }

        /* 기자재 선택 */
        .equipment-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-bottom: 16px;
            max-height: 250px;
            overflow-y: auto;
            padding: 8px;
            background: #f9fafb;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
        }
        
        /* 기자재 그리드 스크롤바 */
        .equipment-grid::-webkit-scrollbar {
            width: 6px;
        }
        
        .equipment-grid::-webkit-scrollbar-track {
            background: #f1f1f1;
        }
        
        .equipment-grid::-webkit-scrollbar-thumb {
            background: #d1d5db;
            border-radius: 3px;
        }

        .equipment-item {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 8px 10px;
            background: var(--grey-color);
            border: 1.5px solid var(--border-color);
            border-radius: 6px;
            cursor: pointer;
            transition: var(--transition);
            font-size: 0.8rem;
            font-weight: 500;
        }

        .equipment-item:hover {
            background: #f3f4f6;
            border-color: #6366f1;
        }

        .equipment-item.selected {
            background: #6366f1;
            color: var(--light-color);
            border-color: #6366f1;
        }

        .equipment-checkbox {
            margin: 0;
            cursor: pointer;
            accent-color: var(--primary-color);
        }

        .equipment-label {
            flex: 1;
            font-weight: 500;
            cursor: pointer;
        }

        /* 팀원 구성 */
        .team-select {
            width: 200px;
            padding: 12px 16px;
            border: 1.5px solid var(--border-color);
            border-radius: 8px;
            font-size: 1rem;
            background: var(--light-color);
            cursor: pointer;
            transition: var(--transition);
            color: var(--text-color);
        }

        .team-select:focus {
            outline: none;
            border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
        }

        /* 질문 추가 */
        .question-textarea {
            width: 100%;
            min-height: 80px;
            padding: 12px 16px;
            border: 1.5px solid var(--border-color);
            border-radius: 8px;
            font-size: 1rem;
            font-family: inherit;
            resize: vertical;
            background: var(--grey-color);
            transition: var(--transition);
            color: var(--text-color);
        }

        .question-textarea:focus {
            outline: none;
            border-color: #6366f1;
            background: var(--light-color);
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
        }

        /* 요청 버튼 */
        .request-btn {
            width: 100%;
            padding: 12px 20px;
            background: var(--primary-color);
            color: var(--light-color);
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            margin-bottom: 16px;
            box-shadow: var(--shadow-sm);
        }

        .request-btn:hover {
            background: var(--primary-dark);
            transform: translateY(-1px);
            box-shadow: var(--shadow-md);
        }

        .request-btn:disabled {
            background: var(--text-muted);
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        /* 채팅 영역 */
        .chat-section {
            flex: 1;
            display: flex !important;
            flex-direction: column !important;
            background: #ffffff;
            border-radius: 12px;
            margin-top: 16px;
            overflow: visible !important;
            border: 2px solid #6366f1;
            box-shadow: 0 10px 25px -5px rgba(99, 102, 241, 0.25), 0 10px 10px -5px rgba(99, 102, 241, 0.15);
            position: relative;
        }
        
        /* 채팅 영역 호버 효과 */
        .chat-section:hover {
            box-shadow: 0 20px 25px -5px rgba(99, 102, 241, 0.35), 0 10px 10px -5px rgba(99, 102, 241, 0.2);
            transform: translateY(-2px);
            transition: all 0.3s ease;
        }

        .chat-header {
            background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
            color: #ffffff;
            padding: 20px 24px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 12px;
            border-bottom: none;
            border-radius: 12px 12px 0 0;
            box-shadow: 0 2px 4px rgba(99, 102, 241, 0.1);
        }

        .chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            min-height: 450px !important;
            max-height: 600px !important;
            background: #ffffff;
        }
        
        /* 채팅 메시지 스크롤바 스타일 */
        .chat-messages::-webkit-scrollbar {
            width: 6px;
        }
        
        .chat-messages::-webkit-scrollbar-track {
            background: #f9fafb;
        }
        
        .chat-messages::-webkit-scrollbar-thumb {
            background: #d1d5db;
            border-radius: 3px;
        }
        
        .chat-messages::-webkit-scrollbar-thumb:hover {
            background: #9ca3af;
        }

        /* 채팅 입력창 */
        .chat-input-area {
            padding: 20px 24px;
            background: linear-gradient(to bottom, #f9fafb, #ffffff);
            border-top: 2px solid #e0e7ff;
            display: flex;
            flex-direction: column;
            gap: 16px;
            border-radius: 0 0 12px 12px;
        }

        .chat-input-container {
            display: flex;
            gap: 12px;
            align-items: flex-end;
        }

        .chat-attachment-buttons {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        /* 첨부 드롭다운 */
        .attachment-dropdown {
            position: relative;
            display: inline-block;
        }

        .attachment-btn.main-btn {
            width: 40px;
            height: 40px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            background: #ffffff;
            color: #6b7280;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }

        .attachment-btn.main-btn:hover {
            background: #f9fafb;
            border-color: #6366f1;
            color: #6366f1;
        }

        .attachment-btn.main-btn.active {
            background: #6366f1;
            color: #ffffff;
            border-color: #6366f1;
        }

        .attachment-menu {
            position: absolute;
            bottom: 50px;
            left: 0;
            background: var(--light-color);
            border-radius: 8px;
            box-shadow: var(--shadow-lg);
            padding: 8px 0;
            min-width: 150px;
            opacity: 0;
            visibility: hidden;
            transform: translateY(10px) scale(0.95);
            transition: var(--transition);
            z-index: 1000;
            border: 1px solid var(--border-color);
        }

        .attachment-menu.show {
            opacity: 1;
            visibility: visible;
            transform: translateY(0) scale(1);
        }

        .attachment-option {
            padding: 12px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            transition: var(--transition);
            font-size: 0.875rem;
            color: var(--text-color);
        }

        .attachment-option:hover {
            background: #f3f4f6;
            color: #6366f1;
        }

        .attachment-option i {
            width: 20px;
            font-size: 16px;
            color: var(--text-light);
        }

        .attachment-option:hover i {
            color: #6366f1;
        }

        .attachment-btn input[type="file"] {
            display: none;
        }

        .chat-input {
            flex: 1;
            padding: 12px 20px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 1rem;
            outline: none;
            background: #ffffff;
            resize: none;
            min-height: 44px;
            max-height: 100px;
            transition: var(--transition);
            color: var(--text-color);
        }

        .chat-input:focus {
            border-color: #6366f1;
            background: #ffffff;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
        }

        .chat-send-btn {
            width: 44px;
            height: 44px;
            background: #6366f1;
            color: #ffffff;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 18px;
            font-weight: 700;
            transition: var(--transition);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
        }

        .chat-send-btn:hover {
            background: #4f46e5;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }

        .chat-send-btn:disabled {
            background: var(--text-muted);
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        /* 첨부파일 미리보기 */
        .attachment-preview {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            max-height: 150px;
            overflow-y: auto;
        }

        .attachment-item {
            position: relative;
            padding: 8px 12px;
            background: var(--secondary-light);
            border-radius: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.75rem;
            color: var(--text-color);
            max-width: 200px;
            border: 1px solid var(--border-color);
        }

        .attachment-item.image {
            flex-direction: column;
            align-items: flex-start;
        }

        .attachment-item img {
            max-width: 100px;
            max-height: 80px;
            border-radius: 5px;
            object-fit: cover;
        }

        .attachment-remove {
            position: absolute;
            top: -5px;
            right: -5px;
            width: 20px;
            height: 20px;
            background: var(--error-color);
            color: var(--light-color);
            border: none;
            border-radius: 50%;
            font-size: 12px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .file-icon {
            font-size: 16px;
            color: #6366f1;
        }

        .message {
            display: flex;
            gap: 16px;
            margin-bottom: 20px;
            max-width: 85%;
            animation: fadeInUp 0.4s ease;
        }

        .message.user {
            align-self: flex-end;
            flex-direction: row-reverse;
            margin-left: auto;
        }

        .message.ai {
            align-self: flex-start;
        }

        .message-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            flex-shrink: 0;
            border: 1px solid var(--border-color);
        }

        .message.ai .message-avatar {
            background: #6366f1;
            color: var(--light-color);
        }
        
        /* 웰컴 메시지 특별 스타일 */
        #welcomeMessage .message-content {
            background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
            border: 2px solid #3b82f6;
            padding: 24px;
        }
        
        #welcomeMessage h4 {
            color: #1e40af;
            margin-bottom: 12px;
            font-size: 1.1rem;
        }
        
        #welcomeMessage p {
            color: #3730a3;
            margin-bottom: 8px;
        }
        
        #welcomeMessage ul {
            color: #4338ca;
        }
        
        /* 새 대화 버튼 호버 효과 */
        #newChatBtn:hover {
            background: #6366f1 !important;
            color: #ffffff !important;
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.4) !important;
        }

        .message.user .message-avatar {
            background: var(--secondary-color);
            color: var(--light-color);
        }

        .message-content {
            background: var(--light-color);
            padding: 16px 20px;
            border-radius: 16px;
            box-shadow: var(--shadow-sm);
            line-height: 1.6;
            word-wrap: break-word;
            color: var(--text-color);
            border: 1px solid var(--border-light);
        }

        .message.user .message-content {
            background: #6366f1;
            color: var(--light-color);
            border-color: #6366f1;
        }

        /* 오른쪽 영역 - AI 지원 정보 */
        .ai-info-sidebar {
            width: 350px;
            background: #fafafa;
            display: flex;
            flex-direction: column;
            height: 100%;
            border-left: 1px solid #e5e7eb;
        }

        .sidebar-header {
            background: #ffffff;
            color: #111827;
            padding: 24px 32px;
            text-align: center;
            border-bottom: 1px solid #e5e7eb;
        }

        .sidebar-header h2 {
            font-size: 1.25rem;
            font-weight: 700;
            margin: 0;
            letter-spacing: -0.025em;
            color: #1f2937;
        }

        .ai-stats {
            padding: 14px 16px;
            background: #ffffff;
            border-bottom: 1px solid #e5e7eb;
        }

        .ai-stats h3 {
            color: #111827;
            font-size: 1rem;
            margin-bottom: 12px;
            font-weight: 700;
            letter-spacing: -0.025em;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        .stat-item {
            text-align: center;
            padding: 16px 12px;
            background: #f9fafb;
            border-radius: 8px;
            box-shadow: none;
            border: 1px solid #e5e7eb;
            transition: var(--transition);
        }

        .stat-item:hover {
            background: #f3f4f6;
            border-color: #d1d5db;
        }

        .stat-number {
            display: block;
            font-size: 1.5rem;
            font-weight: 800;
            color: #6366f1;
            margin-bottom: 4px;
        }

        .stat-label {
            font-size: 0.7rem;
            color: #6b7280;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .question-history {
            padding: 20px 24px;
            background: #ffffff;
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 0;
        }

        .question-history h3 {
            color: #111827;
            font-size: 1rem;
            margin-bottom: 14px;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: space-between;
            letter-spacing: -0.025em;
        }

        .refresh-btn {
            background: none;
            border: none;
            color: #6366f1;
            cursor: pointer;
            font-size: 16px;
            transition: var(--transition);
            padding: 8px;
            border-radius: 8px;
        }

        .refresh-btn:hover {
            transform: rotate(180deg);
            background: #f3f4f6;
        }

        .question-list {
            display: flex;
            flex-direction: column;
            gap: 10px;
            max-height: 400px;
            overflow-y: auto;
            padding-right: 8px;
        }
        
        /* 질문 목록 스크롤바 스타일 */
        .question-list::-webkit-scrollbar {
            width: 6px;
        }
        
        .question-list::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 3px;
        }
        
        .question-list::-webkit-scrollbar-thumb {
            background: #6366f1;
            border-radius: 3px;
        }
        
        .question-list::-webkit-scrollbar-thumb:hover {
            background: #4f46e5;
        }

        .question-item {
            background: #f9fafb;
            padding: 14px;
            border-radius: 8px;
            cursor: pointer;
            transition: var(--transition);
            border-left: 4px solid #6366f1;
            border: 1px solid #e5e7eb;
        }

        .question-item:hover {
            background: #f3f4f6;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            border-color: #d1d5db;
        }

        .question-text {
            font-weight: 600;
            color: #1f2937;
            margin-bottom: 6px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            line-height: 1.4;
            font-size: 0.9rem;
        }

        .question-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.7rem;
            color: #6b7280;
        }

        .question-category {
            background: #e0e7ff;
            color: #6366f1;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.6875rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        /* 로딩 인디케이터 */
        .typing-indicator {
            display: none;
            padding: 16px 20px;
            background: var(--light-color);
            border-radius: 16px;
            margin: 0 20px 16px 20px;
            align-items: center;
            gap: 16px;
            max-width: 200px;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--border-light);
        }

        .typing-indicator.show {
            display: flex;
        }

        .typing-animation {
            display: flex;
            gap: 4px;
        }

        .typing-dot {
            width: 8px;
            height: 8px;
            background: #6366f1;
            border-radius: 50%;
            animation: typing 1.4s infinite;
        }

        .typing-dot:nth-child(2) { animation-delay: 0.2s; }
        .typing-dot:nth-child(3) { animation-delay: 0.4s; }

        @keyframes typing {
            0%, 60%, 100% { transform: translateY(0); }
            30% { transform: translateY(-15px); }
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* 피드백 버튼 */
        .feedback-buttons {
            margin-top: 16px;
            display: flex;
            gap: 12px;
        }

        .feedback-btn {
            padding: 8px 12px;
            border: 1px solid var(--border-color);
            border-radius: 16px;
            background: var(--light-color);
            cursor: pointer;
            font-size: 0.75rem;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 6px;
            color: var(--text-light);
        }

        .feedback-btn:hover {
            background: var(--grey-color);
            border-color: var(--primary-color);
            color: var(--primary-color);
        }

        .feedback-btn.helpful:hover {
            background: rgba(5, 150, 105, 0.1);
            border-color: var(--success-color);
            color: var(--success-color);
        }

        .feedback-btn.needs-improvement:hover {
            background: rgba(220, 38, 38, 0.1);
            border-color: var(--error-color);
            color: var(--error-color);
        }

        /* 반응형 */
        @media (max-width: 1024px) {
            .ai-container {
                flex-direction: column;
                gap: 16px;
                height: auto;
            }
            
            .ai-info-sidebar {
                width: 100%;
            }
            
            .equipment-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 768px) {
            .ai-container {
                gap: 12px;
            }
            
            .project-form {
                padding: 16px;
            }
            
            .equipment-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .equipment-grid {
                grid-template-columns: 1fr;
            }
        }
            </style>

            <div class="ai-container">
            <!-- 왼쪽 영역 - 프로젝트 추천 폼 -->
            <div class="project-request-section">
                <div class="project-header">
                    <i class="fas fa-lightbulb header-icon"></i>
                    <h1>프로젝트 추천 요청</h1>
                </div>
                
                <div class="project-form">
                    <!-- 기자재 선택 -->
                    <div class="form-section">
                        <h3>
                            <i class="fas fa-tools"></i>
                            사용 가능한 기자재 선택
                        </h3>
                        <div class="equipment-grid" id="equipmentGrid">
                            <!-- 관리자가 등록한 기자재가 동적으로 로드됩니다 -->
                            <div style="text-align: center; color: #999; padding: 20px;">
                                <i class="fas fa-spinner fa-spin"></i> 기자재 목록을 불러오는 중...
                            </div>
                        </div>
                    </div>

                    <!-- 팀원 구성 -->
                    <div class="form-section">
                        <h3>
                            <i class="fas fa-users"></i>
                            팀원 구성
                        </h3>
                        <select id="teamSize" class="team-select">
                            <option value="1">1명 (개인 프로젝트)</option>
                            <option value="2">2명</option>
                            <option value="3">3명</option>
                            <option value="4">4명</option>
                            <option value="5">5명</option>
                            <option value="6">6명 이상</option>
                        </select>
                    </div>





                    <!-- 기자재/팀원 선택 영역 제거, 아래로 대체 -->
                    <div class="ai-custom-controls" style="display:none; align-items:center; gap:16px; margin-bottom:16px;">
                        <!--<button id="openEquipmentModalBtn" style="display:none;">기자재 선택하기</button>-->
                        <div style="display:flex; align-items:center; gap:6px;">
                            <span style="font-size:15px;">팀원 수</span>
                            <button type="button" id="teamMinusBtn" style="width:28px; height:28px; border-radius:50%; border:none; background:#eee; font-size:18px; font-weight:700; cursor:pointer;">-</button>
                            <span id="teamSizeDisplay" style="min-width:28px; text-align:center; font-size:16px; font-weight:600;">1</span>
                            <button type="button" id="teamPlusBtn" style="width:28px; height:28px; border-radius:50%; border:none; background:#eee; font-size:18px; font-weight:700; cursor:pointer;">+</button>
                        </div>
                    </div>

                    <!-- 기자재 선택 모달 완전 숨김 -->
                    <div id="equipmentModal" style="display:none;"></div>

                    <!-- 채팅 영역 -->
                    <div class="chat-section">
                        <div class="chat-header">
                            <i class="fas fa-comments"></i>
                            AI 대화
                            <button id="newChatBtn" style="margin-left:auto; padding:8px 20px; border-radius:20px; border:none; background:#ffffff; color:#6366f1; font-weight:600; cursor:pointer; font-size:14px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); transition: all 0.3s ease;">
                                <i class="fas fa-plus-circle" style="margin-right:6px;"></i>새 대화
                            </button>
                        </div>
                        <div class="chat-messages" id="chatContainer">
                            <!-- 웰컴 메시지 -->
                            <div id="welcomeMessage" class="message ai">
                                <div class="message-avatar">
                                    <i class="fas fa-robot"></i>
                                </div>
                                <div class="message-content">
                                    <h4>안녕하세요! 프로젝트 추천 AI입니다 🤖</h4>
                                    <p>원하는 기자재를 선택하고 팀원 수를 설정한 후, 만들고 싶은 프로젝트에 대해 질문해보세요!</p>
                                    <p><strong>예시:</strong></p>
                                    <ul style="margin-left: 20px; margin-top: 10px;">
                                        <li>스마트 홈 시스템 만들기</li>
                                        <li>자동 급수 시스템 제작</li>
                                        <li>IoT 환경 모니터링 장치</li>
                                        <li>음성 인식 로봇 만들기</li>
                                    </ul>
                                </div>
                            </div>
                            
                            <!-- 타이핑 인디케이터 -->
                            <div class="typing-indicator" id="typingIndicator" style="display:none;">
                                <div class="typing-animation">
                                    <div class="typing-dot"></div>
                                    <div class="typing-dot"></div>
                                    <div class="typing-dot"></div>
                                </div>
                                <span>AI가 답변을 생성하고 있습니다...</span>
                            </div>
                        </div>
                        
                        <!-- 채팅 입력창 -->
                        <div class="chat-input-area">
                            <!-- 첨부파일 미리보기 -->
                            <div class="attachment-preview" id="attachmentPreview" style="display: none;"></div>
                            
                            <!-- 입력창과 버튼 -->
                            <div class="chat-input-container">
                                <!-- 첨부 버튼 -->
                                <div class="chat-attachment-buttons">
                                    <div class="attachment-dropdown">
                                        <button type="button" class="attachment-btn main-btn" onclick="toggleAttachmentMenu()" title="첨부하기">
                                            ➕
                                        </button>
                                        <div class="attachment-menu" id="attachmentMenu">
                                            <div class="attachment-option" onclick="selectFileType('file')">
                                                <i class="fas fa-file-plus"></i>
                                                <span>파일 첨부</span>
                                            </div>
                                            <div class="attachment-option" onclick="selectFileType('image')">
                                                <i class="fas fa-camera"></i>
                                                <span>이미지 첨부</span>
                                            </div>
                                            <div class="attachment-option" onclick="selectFileType('audio')">
                                                <i class="fas fa-microphone"></i>
                                                <span>음성 메모</span>
                                            </div>
                                        </div>
                                        <!-- 숨겨진 파일 입력들 -->
                                        <input type="file" id="fileInput" multiple accept="*/*" onchange="handleFileSelect(event)" style="display: none;">
                                        <input type="file" id="imageInput" multiple accept="image/*" onchange="handleImageSelect(event)" style="display: none;">
                                        <input type="file" id="audioInput" accept="audio/*" onchange="handleAudioSelect(event)" style="display: none;">
                                    </div>
                                </div>
                                
                                <!-- 텍스트 입력창 -->
                                <textarea id="projectQuestion" class="chat-input" 
                                          placeholder="어떤 프로젝트를 만들고 싶은지 구체적으로 설명해주세요..."
                                          rows="1"></textarea>
                                
                                <!-- 전송 버튼 -->
                                <button id="requestBtn" class="chat-send-btn" onclick="requestProject()">
                                    ⬆
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 오른쪽 영역 - AI 지원 정보 -->
            <div class="ai-info-sidebar">
                <div class="sidebar-header">
                    <h2>AI 지원 정보</h2>
                </div>
                
                <!-- AI 통계 -->
                <div class="ai-stats">
                    <h3>AI 지원 통계</h3>
                    <div class="stats-grid">
                        <div class="stat-item">
                            <span class="stat-number" id="totalQuestions">0</span>
                            <span class="stat-label">총 질문</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-number" id="monthlyQuestions">0</span>
                            <span class="stat-label">이번 달 질문</span>
                        </div>
                    </div>
                    
                    <!-- 크레딧 정보 -->
                    <div style="margin-top: 16px; padding: 16px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 12px; color: white;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <span style="font-size: 0.875rem; font-weight: 600;">💳 AI 크레딧</span>
                            <button onclick="loadCreditInfo()" style="background: rgba(255,255,255,0.2); border: none; color: white; padding: 4px 8px; border-radius: 4px; cursor: pointer; font-size: 0.75rem;">
                                <i class="fas fa-sync-alt"></i>
                            </button>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: baseline;">
                            <span style="font-size: 2rem; font-weight: 800;" id="remainingCredits">-</span>
                            <span style="font-size: 0.875rem; opacity: 0.9;">/ <span id="totalCredits">-</span> 크레딧</span>
                        </div>
                        <div style="margin-top: 8px; height: 6px; background: rgba(255,255,255,0.3); border-radius: 3px; overflow: hidden;">
                            <div id="creditProgress" style="height: 100%; background: white; border-radius: 3px; transition: width 0.3s ease; width: 0%;"></div>
                        </div>
                        <div style="margin-top: 8px; font-size: 0.75rem; opacity: 0.9; text-align: center;">
                            <span id="usedCredits">-</span> 크레딧 사용됨 · 질문당 5 크레딧
                        </div>
                    </div>
                </div>

                <!-- 질문 기록 -->
                <div class="question-history">
                    <h3>
                        최근 질문 기록
                        <button class="refresh-btn" onclick="loadQuestionHistory()" title="새로고침">
                            <i class="fas fa-sync-alt"></i>
                        </button>
                    </h3>
                    <div class="question-list" id="questionList"></div>
                </div>
            </div>
        </div>

        <!-- 푸터 -->
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 스크립트 포함 -->
    <%@ include file="../layout/scripts.jsp" %>

<script>
// 전역 변수
let selectedEquipments = [];
let questionHistory = [];
let currentChatMessages = [];
let attachedFiles = [];
let teamSize = 1;
let currentConversationId = null; // 현재 대화 세션 ID
let availableEquipments = []; // 실제 DB에서 가져온 기자재 목록





// 메인 프로젝트 요청 함수
function requestMainProject() {
    console.log('=== 메인 프로젝트 추천 요청 시작 ===');
    
    // 기자재 선택 체크
    updateEquipmentSelection();
    if (selectedEquipments.length === 0) {
        alert('최소 1개 이상의 기자재를 선택해주세요!');
        return;
    }
    
    // 팀 사이즈 가져오기
    const teamSizeSelect = document.getElementById('teamSize');
    teamSize = parseInt(teamSizeSelect.value);
    
    // 질문 생성
    const equipmentNames = selectedEquipments.map(function(eq) { return eq.name; }).join(', ');
    let question = '선택한 기자재: ' + equipmentNames + '\n';
    question += '팀원 수: ' + teamSize + '명\n';
    question += '이 기자재들로 만들 수 있는 프로젝트를 추천해주세요.';
    
    const requestBtn = document.getElementById('mainRequestBtn');
    requestBtn.disabled = true;
    requestBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 요청 중...';
    
    displayUserMessage(question);
    showTypingIndicator();
    
    const formData = new FormData();
    formData.append('question', question);
    formData.append('teamSize', teamSize);
    formData.append('selectedEquipments', JSON.stringify(selectedEquipments));
    
    fetch('/ai/recommend-project', {
        method: 'POST',
        body: formData
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('서버 오류: ' + response.status);
        }
        return response.text();
    })
    .then(data => {
        hideTypingIndicator();
        try {
            const result = JSON.parse(data);
            if (result.success) {
                // 새로운 대화 세션 시작
                currentConversationId = result.questionId || Date.now();
                displayAiMessage(result.recommendation, result.questionId);
                loadQuestionHistory();
                updateStatistics();
                
                // 폼 초기화
                selectedEquipments = [];
                const checkboxes = document.querySelectorAll('.equipment-checkbox');
                checkboxes.forEach(checkbox => {
                    checkbox.checked = false;
                    checkbox.parentElement.classList.remove('selected');
                });
                teamSizeSelect.value = '1';
                teamSize = 1;
            } else {
                const errorMsg = result.error || result.message || '알 수 없는 오류가 발생했습니다.';
                displayAiMessage('죄송합니다. ' + errorMsg, null);
            }
        } catch (error) {
            displayAiMessage('죄송합니다. 응답을 처리하는 중 오류가 발생했습니다.', null);
        }
    })
    .catch(error => {
        hideTypingIndicator();
        displayAiMessage('죄송합니다. 요청 처리 중 오류가 발생했습니다: ' + error.message, null);
    })
    .finally(() => {
        requestBtn.disabled = false;
        requestBtn.innerHTML = '<i class="fas fa-paper-plane"></i> 프로젝트 추천 요청';
    });
}
function requestProject() {
  console.log('=== AI 채팅 요청 시작 ===');
  const question = document.getElementById('projectQuestion').value.trim();
  if (!question) {
    alert('질문을 입력해주세요!');
    return;
  }
  
  // 기자재 선택 정보 업데이트
  updateEquipmentSelection();
  
  // 팀 사이즈 가져오기
  const teamSizeSelect = document.getElementById('teamSize');
  teamSize = parseInt(teamSizeSelect.value);
  
  const requestBtn = document.getElementById('requestBtn');
  requestBtn.disabled = true;
  requestBtn.innerHTML = '⏳';
  
  // 프롬프트에 기자재와 팀원 정보 포함
  let enhancedQuestion = question;
  
  // 기자재가 선택되었으면 프롬프트에 추가
  if (selectedEquipments.length > 0) {
    const equipmentNames = selectedEquipments.map(eq => eq.name).join(', ');
    enhancedQuestion = '=== 프로젝트 정보 ===\n';
    enhancedQuestion += '선택한 기자재: ' + equipmentNames + '\n';
    enhancedQuestion += '팀원 수: ' + teamSize + '명\n\n';
    enhancedQuestion += '=== 질문 ===\n';
    enhancedQuestion += question + '\n\n';
    enhancedQuestion += '위 기자재들과 팀원 구성을 고려하여 구체적으로 답변해주세요.';
  }
  
  console.log('전송할 프롬프트:', enhancedQuestion);
  
  if (attachedFiles.length > 0) {
    displayUserMessageWithAttachments(question, [...attachedFiles]);
  } else {
    displayUserMessage(question);
  }
  showTypingIndicator();
  
  // AI 채팅용 요청 데이터 (향상된 프롬프트 사용)
  const requestData = {
    question: enhancedQuestion,
    category: 'GENERAL',
    conversationId: currentConversationId,
    chatHistory: currentChatMessages
  };
  
  fetch('/ai/ask-json', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(requestData)
  })
  .then(response => {
    if (!response.ok) {
      throw new Error('서버 오류: ' + response.status);
    }
    return response.text();
  })
  .then(data => {
    hideTypingIndicator();
    try {
      const result = JSON.parse(data);
      if (result.success) {
        displayAiMessage(result.answer, result.questionId);
        loadQuestionHistory();
        updateStatistics();
        
        // 크레딧 사용 정보 표시
        if (result.creditsUsed && result.remainingCredits !== undefined) {
          console.log('크레딧 사용:', result.creditsUsed, '/ 남은 크레딧:', result.remainingCredits);
          
          // 크레딧이 부족하면 경고
          if (result.remainingCredits < 10) {
            setTimeout(() => {
              alert('⚠️ AI 크레딧이 ' + result.remainingCredits + '개 남았습니다!\n관리자에게 크레딧 충전을 요청하세요.');
            }, 500);
          }
        }
        
        document.getElementById('projectQuestion').value = '';
        document.getElementById('projectQuestion').style.height = 'auto';
        attachedFiles = [];
        updateAttachmentPreview();
      } else {
        const errorMsg = result.error || result.message || '알 수 없는 오류가 발생했습니다.';
        
        // 크레딧 부족 에러 처리
        if (result.errorCode === 'INSUFFICIENT_CREDITS') {
          displayAiMessage('❌ AI 크레딧이 부족합니다!\n\n현재 남은 크레딧: ' + (result.remainingCredits || 0) + '개\n필요 크레딧: 5개\n\n관리자에게 크레딧 충전을 요청하세요.', null);
        } else {
          displayAiMessage('죄송합니다. ' + errorMsg, null);
        }
      }
    } catch (error) {
      displayAiMessage('죄송합니다. 응답을 처리하는 중 오류가 발생했습니다.', null);
    }
  })
  .catch(error => {
    hideTypingIndicator();
    displayAiMessage('죄송합니다. 요청 처리 중 오류가 발생했습니다: ' + error.message, null);
  })
  .finally(() => {
    requestBtn.disabled = false;
    requestBtn.innerHTML = '↑';
  });
}

// 사용자 메시지 표시
function displayUserMessage(msg, saveToSession = true) {
    console.log('사용자 메시지 표시:', msg);
    
    const chatContainer = document.getElementById('chatContainer');
    
    // 웰컴 메시지 제거
    const welcomeMessage = document.getElementById('welcomeMessage');
    if (welcomeMessage) {
        welcomeMessage.remove();
    }
    
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message user';
    messageDiv.innerHTML = 
        '<div class="message-content">' + msg + '</div>' +
        '<div class="message-avatar">' +
            '<i class="fas fa-user"></i>' +
        '</div>';
    
    chatContainer.appendChild(messageDiv);
    
    // 세션에 저장
    if (saveToSession) {
        currentChatMessages.push({ type: 'user', content: msg });
        saveChatToSession();
    }
    
    // 스크롤을 맨 아래로
    setTimeout(() => {
        chatContainer.scrollTop = chatContainer.scrollHeight;
    }, 100);
}

// AI 메시지 표시
function displayAiMessage(msg, questionId) {
    console.log('AI 메시지 표시:', msg);
    
    const chatContainer = document.getElementById('chatContainer');
    
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message ai';
    
    let feedbackHtml = '';
    if (questionId) {
        feedbackHtml = 
            '<div class="feedback-buttons">' +
                '<button class="feedback-btn helpful" onclick="submitFeedback(' + questionId + ', 1, \'helpful\')">' +
                    '<i class="fas fa-thumbs-up"></i> 도움됨' +
                '</button>' +
                '<button class="feedback-btn needs-improvement" onclick="submitFeedback(' + questionId + ', 0, \'needs_improvement\')">' +
                    '<i class="fas fa-thumbs-down"></i> 개선 필요' +
                '</button>' +
            '</div>';
    }
    
    messageDiv.innerHTML = 
        '<div class="message-avatar">' +
            '<i class="fas fa-robot"></i>' +
        '</div>' +
        '<div class="message-content">' + 
            formatAiMessage(msg) + 
            feedbackHtml +
        '</div>';
    
    chatContainer.appendChild(messageDiv);
    
    // 세션에 저장
    currentChatMessages.push({ type: 'ai', content: msg, questionId: questionId });
    saveChatToSession();
    
    // 스크롤을 맨 아래로
    setTimeout(() => {
        chatContainer.scrollTop = chatContainer.scrollHeight;
    }, 100);
}

// 타이핑 인디케이터 표시/숨김
function showTypingIndicator() {
    const indicator = document.getElementById('typingIndicator');
    if (indicator) {
        indicator.classList.add('show');
        const chatContainer = document.getElementById('chatContainer');
        setTimeout(() => {
            chatContainer.scrollTop = chatContainer.scrollHeight;
        }, 100);
    } else {
        console.warn('typingIndicator 요소를 찾을 수 없습니다.');
    }
}

function hideTypingIndicator() {
    const indicator = document.getElementById('typingIndicator');
    if (indicator) {
        indicator.classList.remove('show');
    }
}

// 질문 기록 로드
function loadQuestionHistory() {
    console.log('질문 기록 로드 중...');
    
    // 캐시된 데이터 강제 초기화
    questionHistory = [];
    updateQuestionLogList();
    updateStatistics();
    
    fetch('/ai/my-questions')
    .then(response => {
        console.log('서버 응답 상태:', response.status);
        console.log('응답 타입:', response.headers.get('content-type'));
        if (!response.ok) {
            throw new Error('HTTP ' + response.status + ': ' + response.statusText);
        }
        return response.json();
    })
    .then(data => {
        console.log('질문 기록 로드됨:', data);
        console.log('데이터 타입:', typeof data);
        console.log('데이터 길이:', Array.isArray(data) ? data.length : '배열이 아님');
        
        // 이전 사용자 데이터 완전 초기화 후 새 데이터 설정
        questionHistory = [];
        if (Array.isArray(data) && data.length > 0) {
            questionHistory = data;
            console.log('새로운 질문 기록 설정됨:', questionHistory.length + '개');
        } else {
            console.log('현재 사용자는 질문 기록이 없습니다.');
        }
        
        updateQuestionLogList();
        updateStatistics();
    })
    .catch(error => {
        console.error('질문 기록 로드 오류:', error);
        console.error('오류 타입:', error.name);
        console.error('오류 메시지:', error.message);
        // 오류 시 빈 배열로 초기화
        questionHistory = [];
        updateQuestionLogList();
        updateStatistics();
    });
}

// 질문 기록 목록 업데이트
function updateQuestionLogList() {
    const questionList = document.getElementById('questionList');
    if (!questionList) {
        console.error('questionList 요소를 찾을 수 없습니다.');
        return;
    }
    
    console.log('질문 목록 업데이트:', questionHistory.length + '개');
    
    if (questionHistory.length === 0) {
        questionList.innerHTML = '<div style="text-align: center; color: #999; padding: 20px;">아직 질문 기록이 없습니다.</div>';
        return;
    }
    questionList.innerHTML = questionHistory.slice(0, 20).map((question, idx) => {
        const date = new Date(question.createdAt);
        const formattedDate = date.toLocaleDateString('ko-KR', { month: 'short', day: 'numeric' });
        const formattedTime = date.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' });
        return '<div class="question-item" onclick="previewQuestionDetail(' + idx + ')">' +
                   '<div class="question-text">' + escapeHtml(question.question) + '</div>' +
                   '<div class="question-meta">' +
                       '<span class="question-category">' + (question.category || '일반') + '</span>' +
                       '<span>' + formattedDate + ' ' + formattedTime + '</span>' +
                   '</div>' +
               '</div>';
    }).join('');
}

// 미리보기 함수 추가
function previewQuestionDetail(idx) {
    const q = questionHistory[idx];
    const chatContainer = document.getElementById('chatContainer');
    
    // 기존 대화창 비우고, 해당 질문/답변만 표시
    chatContainer.innerHTML = '';
    currentChatMessages = []; // 세션도 초기화
    sessionStorage.removeItem('currentChat');
    
    // 질문(사용자)
    const userDiv = document.createElement('div');
    userDiv.className = 'message user';
    userDiv.innerHTML =
        '<div class="message-content">' + escapeHtml(q.question) + '</div>' +
        '<div class="message-avatar"><i class="fas fa-user"></i></div>';
    chatContainer.appendChild(userDiv);
    
    // 답변(AI)
    const aiDiv = document.createElement('div');
    aiDiv.className = 'message ai';
    aiDiv.innerHTML =
        '<div class="message-avatar"><i class="fas fa-robot"></i></div>' +
        '<div class="message-content">' + formatAiMessage(q.answer || '답변이 없습니다.') + '</div>';
    chatContainer.appendChild(aiDiv);
    
    // 스크롤 맨 아래로
    setTimeout(() => { chatContainer.scrollTop = chatContainer.scrollHeight; }, 100);
}

// 통계 업데이트
function updateStatistics() {
    console.log('통계 업데이트 중...');
    
    // 총 질문 수
    const totalQuestionsElem = document.getElementById('totalQuestions');
    if (totalQuestionsElem) {
        totalQuestionsElem.textContent = questionHistory.length;
    }
    
    // 이번 달 질문 수
    const thisMonth = new Date().getMonth();
    const thisYear = new Date().getFullYear();
    const monthlyCount = questionHistory.filter(q => {
        const qDate = new Date(q.createdAt);
        return qDate.getMonth() === thisMonth && qDate.getFullYear() === thisYear;
    }).length;
    const monthlyQuestionsElem = document.getElementById('monthlyQuestions');
    if (monthlyQuestionsElem) {
        monthlyQuestionsElem.textContent = monthlyCount;
    }
    
    // 크레딧 정보 로드
    loadCreditInfo();
    
    console.log('통계 업데이트 완료:', questionHistory.length, '개 질문');
}

// 크레딧 정보 로드
function loadCreditInfo() {
    fetch('/ai/credits')
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            const remainingElem = document.getElementById('remainingCredits');
            const totalElem = document.getElementById('totalCredits');
            const usedElem = document.getElementById('usedCredits');
            const progressElem = document.getElementById('creditProgress');
            
            if (remainingElem) remainingElem.textContent = data.remainingCredits;
            if (totalElem) totalElem.textContent = data.totalCredits;
            if (usedElem) usedElem.textContent = data.usedCredits;
            
            // 프로그레스 바 업데이트
            if (progressElem && data.totalCredits > 0) {
                const percentage = (data.remainingCredits / data.totalCredits) * 100;
                progressElem.style.width = percentage + '%';
                
                // 크레딧이 20% 이하면 빨간색으로 표시
                if (percentage <= 20) {
                    progressElem.style.background = '#ef4444';
                } else if (percentage <= 50) {
                    progressElem.style.background = '#f59e0b';
                } else {
                    progressElem.style.background = 'white';
                }
            }
            
            console.log('크레딧 정보 로드 완료:', data.remainingCredits, '/', data.totalCredits);
        }
    })
    .catch(error => {
        console.error('크레딧 정보 로드 오류:', error);
    });
}

// 피드백 제출
function submitFeedback(questionId, isHelpful, feedbackType) {
    console.log('피드백 제출:', questionId, isHelpful, feedbackType);
    
    const requestData = {
        questionId: questionId,
        isHelpful: isHelpful,
        feedbackType: feedbackType
    };
    
    fetch('/ai/feedback', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(requestData)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // 피드백 버튼 비활성화
            const feedbackButtons = document.querySelectorAll('[onclick*="' + questionId + '"]');
            feedbackButtons.forEach(btn => {
                btn.disabled = true;
                btn.style.opacity = '0.5';
            });
            
            console.log('피드백 제출 완료');
        }
    })
    .catch(error => {
        console.error('피드백 제출 오류:', error);
    });
}

// 유틸리티 함수들
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}

function formatAiMessage(message) {
    return message
        .replace(/\n/g, '<br>')
        .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
        .replace(/\*(.*?)\*/g, '<em>$1</em>');
}

// 세션 관리
function saveChatToSession() {
    try {
        sessionStorage.setItem('currentChat', JSON.stringify(currentChatMessages));
    } catch (error) {
        console.warn('세션 저장 실패:', error);
    }
}

function restoreChatFromSession() {
    try {
        const savedChat = sessionStorage.getItem('currentChat');
        if (savedChat) {
            currentChatMessages = JSON.parse(savedChat);
            
            if (currentChatMessages.length > 0) {
                // 웰컴 메시지 제거
                const welcomeMessage = document.getElementById('welcomeMessage');
                if (welcomeMessage) {
                    welcomeMessage.remove();
                }
                
                // 메시지 복원
                const chatContainer = document.getElementById('chatContainer');
                chatContainer.innerHTML = '';
                
                currentChatMessages.forEach(msg => {
                    if (msg.type === 'user') {
                        displayUserMessage(msg.content, false);
                    } else if (msg.type === 'ai') {
                        displayAiMessage(msg.content, msg.questionId);
                    }
                });
            }
        }
    } catch (error) {
        console.warn('세션 복원 실패:', error);
    }
}

// 첨부 메뉴 토글
function toggleAttachmentMenu() {
    const menu = document.getElementById('attachmentMenu');
    const btn = document.querySelector('.attachment-btn.main-btn');
    
    if (menu.classList.contains('show')) {
        menu.classList.remove('show');
        btn.classList.remove('active');
    } else {
        menu.classList.add('show');
        btn.classList.add('active');
    }
}

// 파일 타입 선택
function selectFileType(type) {
    const menu = document.getElementById('attachmentMenu');
    const btn = document.querySelector('.attachment-btn.main-btn');
    
    // 메뉴 닫기
    menu.classList.remove('show');
    btn.classList.remove('active');
    
    // 해당 파일 입력 트리거
    if (type === 'file') {
        document.getElementById('fileInput').click();
    } else if (type === 'image') {
        document.getElementById('imageInput').click();
    } else if (type === 'audio') {
        document.getElementById('audioInput').click();
    }
}

// 파일 선택 처리
function handleFileSelect(event) {
    const files = Array.from(event.target.files);
    files.forEach(file => {
        addAttachment(file, 'file');
    });
    event.target.value = ''; // 같은 파일 재선택 가능하도록
}

// 이미지 선택 처리
function handleImageSelect(event) {
    const files = Array.from(event.target.files);
    files.forEach(file => {
        addAttachment(file, 'image');
    });
    event.target.value = ''; // 같은 파일 재선택 가능하도록
}

// 오디오 선택 처리
function handleAudioSelect(event) {
    const files = Array.from(event.target.files);
    files.forEach(file => {
        addAttachment(file, 'audio');
    });
    event.target.value = ''; // 같은 파일 재선택 가능하도록
}

// 첨부파일 추가
function addAttachment(file, type) {
    const fileId = Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    const attachment = {
        id: fileId,
        file: file,
        type: type,
        name: file.name,
        size: file.size
    };
    
    attachedFiles.push(attachment);
    updateAttachmentPreview();
}

// 첨부파일 미리보기 업데이트
function updateAttachmentPreview() {
    const previewContainer = document.getElementById('attachmentPreview');
    
    if (attachedFiles.length === 0) {
        previewContainer.style.display = 'none';
        return;
    }
    
    previewContainer.style.display = 'flex';
    previewContainer.innerHTML = '';
    
    attachedFiles.forEach(attachment => {
        const item = document.createElement('div');
        item.className = 'attachment-item' + (attachment.type === 'image' ? ' image' : '');
        
        if (attachment.type === 'image') {
            // 이미지 미리보기
            const img = document.createElement('img');
            img.src = URL.createObjectURL(attachment.file);
            img.alt = attachment.name;
            
            const name = document.createElement('span');
            name.textContent = attachment.name;
            name.style.fontSize = '11px';
            name.style.color = '#666';
            
            item.appendChild(img);
            item.appendChild(name);
        } else {
            // 파일 아이콘과 이름
            const icon = document.createElement('i');
            icon.className = 'file-icon fas fa-file';
            
            const name = document.createElement('span');
            name.textContent = attachment.name;
            name.style.overflow = 'hidden';
            name.style.textOverflow = 'ellipsis';
            name.style.whiteSpace = 'nowrap';
            
            const size = document.createElement('div');
            size.textContent = formatFileSize(attachment.size);
            size.style.fontSize = '10px';
            size.style.color = '#999';
            
            item.appendChild(icon);
            item.appendChild(name);
            item.appendChild(size);
        }
        
        // 삭제 버튼
        const removeBtn = document.createElement('button');
        removeBtn.className = 'attachment-remove';
        removeBtn.innerHTML = '×';
        removeBtn.onclick = () => removeAttachment(attachment.id);
        
        item.appendChild(removeBtn);
        previewContainer.appendChild(item);
    });
}

// 첨부파일 제거
function removeAttachment(fileId) {
    attachedFiles = attachedFiles.filter(attachment => attachment.id !== fileId);
    updateAttachmentPreview();
}

// 파일 크기 포맷팅
function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// 첨부파일과 함께 메시지 표시
function displayUserMessageWithAttachments(message, attachments) {
    const chatContainer = document.getElementById('chatContainer');
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message user';
    
    let attachmentHtml = '';
    if (attachments && attachments.length > 0) {
        attachmentHtml = '<div style="margin-bottom: 10px;">';
        attachments.forEach(attachment => {
            if (attachment.type === 'image') {
                attachmentHtml += 
                    '<div style="margin-bottom: 5px;">' +
                        '<img src="' + URL.createObjectURL(attachment.file) + '" ' +
                             'style="max-width: 200px; max-height: 150px; border-radius: 8px; object-fit: cover;" ' +
                             'alt="' + attachment.name + '">' +
                        '<div style="font-size: 11px; color: #ccc; margin-top: 2px;">' + attachment.name + '</div>' +
                    '</div>';
            } else {
                attachmentHtml += 
                    '<div style="background: rgba(255,255,255,0.1); padding: 8px; border-radius: 5px; margin-bottom: 5px; display: flex; align-items: center; gap: 8px;">' +
                        '<i class="fas fa-file" style="color: white;"></i>' +
                        '<span style="font-size: 12px;">' + attachment.name + '</span>' +
                        '<span style="font-size: 10px; opacity: 0.7;">(' + formatFileSize(attachment.size) + ')</span>' +
                    '</div>';
            }
        });
        attachmentHtml += '</div>';
    }
    
    messageDiv.innerHTML = 
        '<div class="message-avatar">' +
            '<i class="fas fa-user"></i>' +
        '</div>' +
        '<div class="message-content">' +
            attachmentHtml +
            (message ? message : '') +
        '</div>';
    
    chatContainer.appendChild(messageDiv);
    chatContainer.scrollTop = chatContainer.scrollHeight;
}

// 사용자별 데이터 초기화 (로그인 사용자가 바뀐 경우)
function clearUserSpecificData() {
    console.log('=== 사용자별 데이터 초기화 ===');
    
    // 질문 기록 초기화
    questionHistory = [];
    
    // 현재 채팅 메시지 초기화
    currentChatMessages = [];
    
    // 첨부파일 초기화
    attachedFiles = [];
    
    // 대화 ID 초기화
    currentConversationId = null;
    
    // 세션 스토리지 초기화
    try {
        sessionStorage.removeItem('currentChat');
        console.log('세션 스토리지 초기화 완료');
    } catch (error) {
        console.warn('세션 스토리지 초기화 실패:', error);
    }
    
    // 채팅 컨테이너 초기화
    const chatContainer = document.getElementById('chatContainer');
    if (chatContainer) {
        chatContainer.innerHTML = `
            <div id="welcomeMessage" class="message ai">
                <div class="message-avatar">
                    <i class="fas fa-robot"></i>
                </div>
                <div class="message-content">
                    <h4>안녕하세요! 프로젝트 추천 AI입니다 🤖</h4>
                    <p>원하는 기자재를 선택하고 팀원 수를 설정한 후, 만들고 싶은 프로젝트에 대해 질문해보세요!</p>
                    <p><strong>예시:</strong></p>
                    <ul style="margin-left: 20px; margin-top: 10px;">
                        <li>스마트 홈 시스템 만들기</li>
                        <li>자동 급수 시스템 제작</li>
                        <li>IoT 환경 모니터링 장치</li>
                        <li>음성 인식 로봇 만들기</li>
                    </ul>
                </div>
            </div>
        `;
    }
    
    // 첨부파일 미리보기 초기화
    updateAttachmentPreview();
    
    console.log('사용자별 데이터 초기화 완료');
}

// 기자재 관련 함수들
function loadAvailableEquipments() {
    console.log('=== 기자재 목록 로드 시작 ===');
    
    const equipmentGrid = document.getElementById('equipmentGrid');
    equipmentGrid.innerHTML = '<div style="text-align: center; color: #999; padding: 20px;"><i class="fas fa-spinner fa-spin"></i> 기자재 목록을 불러오는 중...</div>';
    
    fetch('/ai/equipments')
    .then(response => {
        console.log('기자재 API 응답 상태:', response.status);
        console.log('기자재 API 응답 헤더:', response.headers.get('content-type'));
        if (!response.ok) {
            throw new Error('HTTP ' + response.status + ': ' + response.statusText);
        }
        return response.json();
    })
    .then(data => {
        console.log('기자재 목록 로드 완료:', data);
        console.log('기자재 개수:', Array.isArray(data) ? data.length : '배열이 아님');
        console.log('기자재 타입:', typeof data);
        
        availableEquipments = data || [];
        renderEquipmentGrid();
    })
    .catch(error => {
        console.error('기자재 목록 로드 오류:', error);
        console.error('오류 타입:', error.name);
        console.error('오류 메시지:', error.message);
        
        equipmentGrid.innerHTML = 
            '<div style="text-align: center; color: #ff4444; padding: 20px;">' +
                '<i class="fas fa-exclamation-triangle"></i><br>' +
                '기자재 목록을 불러올 수 없습니다.<br>' +
                '<small>오류: ' + error.message + '</small><br>' +
                '<button onclick="loadAvailableEquipments()" style="margin-top: 10px; padding: 5px 15px; border: none; background: #667eea; color: white; border-radius: 5px; cursor: pointer;">' +
                    '다시 시도' +
                '</button>' +
            '</div>';
    });
}

// 기자재 UI 동적 생성
function renderEquipmentGrid() {
    const equipmentGrid = document.getElementById('equipmentGrid');
    
    if (availableEquipments.length === 0) {
        equipmentGrid.innerHTML = 
            '<div style="text-align: center; color: #999; padding: 20px;">' +
                '<i class="fas fa-box-open"></i><br>' +
                '현재 대여 가능한 기자재가 없습니다.' +
            '</div>';
        return;
    }
    
    let html = '';
    availableEquipments.forEach((equipmentName, index) => {
        const equipmentId = 'eq_' + index;
        html += 
            '<div class="equipment-item">' +
                '<input type="checkbox" id="' + equipmentId + '" class="equipment-checkbox" value="' + equipmentName + '">' +
                '<label for="' + equipmentId + '" class="equipment-label">' + equipmentName + '</label>' +
            '</div>';
    });
    
    equipmentGrid.innerHTML = html;
    
    // 체크박스 이벤트 리스너 추가
    attachEquipmentEventListeners();
    
    console.log('기자재 UI 생성 완료. 총 ' + availableEquipments.length + '개');
}

// 기자재 체크박스 이벤트 리스너 연결
function attachEquipmentEventListeners() {
    const equipmentCheckboxes = document.querySelectorAll('.equipment-checkbox');
    equipmentCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            updateEquipmentSelection();
            // 체크박스 스타일 업데이트
            const item = this.parentElement;
            if (this.checked) {
                item.classList.add('selected');
            } else {
                item.classList.remove('selected');
            }
        });
    });
}

// 기자재 선택 처리
function updateEquipmentSelection() {
    selectedEquipments = [];
    const checkboxes = document.querySelectorAll('.equipment-checkbox:checked');
    checkboxes.forEach(checkbox => {
        const equipmentName = checkbox.value; // 이제 value가 기자재 이름
        selectedEquipments.push({
            id: equipmentName, // 이름을 ID로 사용
            name: equipmentName,
            displayName: equipmentName
        });
    });
    console.log('선택된 기자재:', selectedEquipments);
}

// 메인 프로젝트 요청 함수
function requestMainProject() {
    console.log('=== 메인 프로젝트 추천 요청 시작 ===');
    
    // 기자재 선택 체크
    updateEquipmentSelection();
    if (selectedEquipments.length === 0) {
        alert('최소 1개 이상의 기자재를 선택해주세요!');
        return;
    }
    
    // 질문 입력창에 기본 프로젝트 추천 질문 설정
    const equipmentNames = selectedEquipments.map(eq => eq.name).join(', ');
    const defaultQuestion = '이 기자재들로 만들 수 있는 창의적이고 실현 가능한 프로젝트를 추천해주세요.';
    
    document.getElementById('projectQuestion').value = defaultQuestion;
    
    // 일반 질문 함수 호출 (통합)
    requestProject();
}

// 페이지 로드 후 초기화
document.addEventListener('DOMContentLoaded', function() {
    // 사용자별 데이터 초기화 (로그인 사용자가 바뀐 경우 대비)
    clearUserSpecificData();
    
    // 기자재 목록 로드
    loadAvailableEquipments();
    
    // 질문 기록 로드
    loadQuestionHistory();
    
    // 채팅 세션 복원 (초기화 후)
    restoreChatFromSession();
    
    // 새 대화 버튼 이벤트
    const newChatBtn = document.getElementById('newChatBtn');
    if (newChatBtn) {
        newChatBtn.addEventListener('click', function() {
            // 채팅 초기화
            currentChatMessages = [];
            sessionStorage.removeItem('currentChat');
            
            const chatContainer = document.getElementById('chatContainer');
            chatContainer.innerHTML = `
                <div id="welcomeMessage" class="message ai">
                    <div class="message-avatar">
                        <i class="fas fa-robot"></i>
                    </div>
                    <div class="message-content">
                        <h4>안녕하세요! 프로젝트 추천 AI입니다 🤖</h4>
                        <p>원하는 기자재를 선택하고 팀원 수를 설정한 후, 만들고 싶은 프로젝트에 대해 질문해보세요!</p>
                        <p><strong>예시:</strong></p>
                        <ul style="margin-left: 20px; margin-top: 10px;">
                            <li>스마트 홈 시스템 만들기</li>
                            <li>자동 급수 시스템 제작</li>
                            <li>IoT 환경 모니터링 장치</li>
                            <li>음성 인식 로봇 만들기</li>
                        </ul>
                    </div>
                </div>
            `;
        });
    }
    
    // 채팅 입력창 엔터 이벤트
    const chatInput = document.getElementById('projectQuestion');
    if (chatInput) {
        chatInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                requestProject();
            }
        });
        
        // 자동 높이 조절
        chatInput.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = this.scrollHeight + 'px';
        });
    }
    
    // 팀 사이즈 변경 이벤트
    const teamSizeSelect = document.getElementById('teamSize');
    if (teamSizeSelect) {
        teamSizeSelect.addEventListener('change', function() {
            teamSize = parseInt(this.value);
        });
    }
    
    // 메뉴 외부 클릭 시 닫기
    document.addEventListener('click', function(event) {
        const dropdown = document.querySelector('.attachment-dropdown');
        const menu = document.getElementById('attachmentMenu');
        const btn = document.querySelector('.attachment-btn.main-btn');
        
        if (dropdown && !dropdown.contains(event.target)) {
            menu.classList.remove('show');
            btn.classList.remove('active');
        }
    });
});

// 오른쪽 기록(이전 질문) 리스트 렌더링 함수 예시 추가
function updateHistorySidebar() {
    const sidebarList = document.getElementById('historySidebarList');
    if (!sidebarList) return;
    sidebarList.innerHTML = questionHistory.map((q, idx) => `
        <div class="history-item" onclick="previewQuestionDetail(${idx})">
            <span class="history-category">${q.category || '일반'}</span>
            <span class="history-title"></span>
        </div>
    `).join('');
}

</script>

</body>
</html>