<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<head>
    <%@ include file="../layout/head-meta.jsp" %>
    <title>프로젝트 관리</title>
    <!-- 간단한 간트 차트 사용 (외부 라이브러리 없음) -->
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        /* 글로벌 폰트 설정 */
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
        
        /* 전체 레이아웃 - 반응형 */
        /* content 스타일은 head-meta.jsp에서 관리 */
        
        * {
            box-sizing: border-box;
        }
        
        .main-body { 
            padding: 20px;
            width: 100%;
            max-width: 100vw;
            margin-top: 80px;
            box-sizing: border-box;
        }
        
        /* 프로젝트 정보 카드 - 깔끔한 디자인 */
        .project-info-card { 
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            border: 1px solid #e0e0e0;
            max-width: 100%;
            box-sizing: border-box;
        }
        
        .project-info-card .detail-item i {
            color: #6c757d !important;
        }
        
        .project-title { 
            color: #2d3748; 
            font-weight: 500; 
            font-size: 24px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .project-title i {
            color: #6c757d;
            font-size: 20px;
        }
        
        .project-details { 
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }
        
        .detail-item {
            background: #f8f9fa;
            padding: 16px;
            border-radius: 8px;
            border-left: 3px solid #6c757d;
        }
        
        .detail-item strong {
            color: #495057;
            font-size: 13px;
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }
        
        .detail-item span {
            color: #2d3748;
            font-weight: 400;
            font-size: 14px;
        }
        
        /* 액션 버튼들 - 깔끔한 디자인 */
        .project-actions {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            max-width: 100%;
            box-sizing: border-box;
        }
        
        .action-btn {
            padding: 12px 20px;
            border-radius: 8px;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.2s ease;
            border: none;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .action-btn:hover {
            background: #e9ecef;
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .btn-ai-chat:hover {
            background: #3367d6;
            transform: translateY(-1px);
            box-shadow: 0 3px 8px rgba(66, 133, 244, 0.3);
        }
        
        .btn-list {
            background: #f8f9fa;
            color: #495057;
            border: 1px solid #dee2e6;
        }
        
        .btn-members {
            background: #f8f9fa;
            color: #495057;
            border: 1px solid #dee2e6;
        }
        
        .btn-reports {
            background: #f8f9fa;
            color: #495057;
            border: 1px solid #dee2e6;
        }
        
        .btn-ai-chat {
            background: #4285f4;
            color: white;
            border: none;
        }
        
        /* 탭 디자인 - 깔끔한 스타일 */
        .project-tabs { 
            margin: 25px 0;
            background: white;
            border-radius: 12px;
            padding: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            max-width: 100%;
            box-sizing: border-box;
        }
        
        .project-tabs .nav-tabs {
            border: none;
            display: flex;
            justify-content: space-around;
            flex-wrap: wrap;
            max-width: 100%;
        }
        
        .project-tabs .nav-link { 
            border: none; 
            color: #6c757d; 
            padding: 14px 20px; 
            font-weight: 500;
            border-radius: 8px;
            transition: all 0.2s ease;
            position: relative;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }
        
        .project-tabs .nav-link:hover {
            background: #f8f9fa;
            color: #495057;
        }
        
        .project-tabs .nav-link.active { 
            background: #3b82f6;
            color: white;
            box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
        }
        
        /* 컨텐츠 섹션 - 반응형 */
        .content-section { 
            background: white;
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            margin-top: 15px;
            min-height: 500px;
            max-width: 100%;
            box-sizing: border-box;
        }
        
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .section-title {
            font-size: 20px;
            font-weight: 500;
            color: #2d3748;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .section-title i {
            color: #6c757d;
        }
        
        /* 간트 차트 스타일 - 반응형 */
        .gantt-container {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            min-height: 400px;
            border: 1px solid #e0e0e0;
            overflow-x: auto;
        }
        
        #gantt-chart { 
            margin-top: 15px;
            min-height: 350px;
            border-radius: 8px;
            background-color: #fafafa;
        }
        
        /* 간단한 간트 차트만 사용 - Frappe Gantt CSS 제거됨 */
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }
        
        .empty-state i {
            font-size: 4em;
            margin-bottom: 20px;
            opacity: 0.3;
        }
        
        .empty-state h5 {
            margin-bottom: 10px;
            font-weight: 600;
        }
        
        .empty-state p {
            opacity: 0.7;
        }
        
        /* 버튼 스타일 - 깔끔한 디자인 */
        .btn-add-task {
            background: #4285f4;
            border: none;
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }
        
        .btn-add-task:hover {
            background: #3367d6;
            transform: translateY(-1px);
            box-shadow: 0 3px 8px rgba(66, 133, 244, 0.3);
            color: white;
        }
        
        /* 테이블 스타일 */
        .custom-table {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        }
        
        .custom-table thead {
            background: #f8f9fa;
            color: #495057;
            border-bottom: 2px solid #dee2e6;
        }
        
        .custom-table th {
            font-weight: 600 !important;
            padding: 15px !important;
            border: none !important;
        }
        
        .custom-table td {
            padding: 12px 15px !important;
            border-bottom: 1px solid #f1f3f4 !important;
            vertical-align: middle !important;
        }
        
        .custom-table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        /* 스크롤바 스타일 */
        .content-section::-webkit-scrollbar,
        .gantt-container::-webkit-scrollbar {
            width: 6px;
        }
        
        .content-section::-webkit-scrollbar-track,
        .gantt-container::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 3px;
        }
        
        .content-section::-webkit-scrollbar-thumb,
        .gantt-container::-webkit-scrollbar-thumb {
            background: #c1c1c1;
            border-radius: 3px;
        }
        
        .content-section::-webkit-scrollbar-thumb:hover,
        .gantt-container::-webkit-scrollbar-thumb:hover {
            background: #a8a8a8;
        }
        
        /* 보고서 미리보기 스타일 */
        .reports-preview {
            margin-top: 20px;
        }
        
        .reports-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        
        .report-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px;
            background: #f8f9fc;
            border-radius: 10px;
            border: 1px solid #e2e8f0;
            transition: all 0.3s ease;
        }
        
        .report-item:hover {
            background: #eef2ff;
            border-color: #667eea;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.15);
        }
        
        .report-icon {
            width: 40px;
            height: 40px;
            background: #3b82f6;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.2em;
        }
        
        .report-info {
            flex: 1;
        }
        
        .report-name {
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 5px;
            font-size: 0.95em;
        }
        
        .report-date {
            color: #6c757d;
            font-size: 0.85em;
        }
        
        .report-actions .btn {
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 0.9em;
        }
        
        .more-reports {
            text-align: center;
            padding: 10px;
        }
        
        .more-reports a {
            color: #667eea;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.9em;
        }
        
        .more-reports a:hover {
            text-decoration: underline;
        }
        
        /* 섹션 헤더에 버튼 정렬 */
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        /* 기자재 카드 호버 효과 */
        .equipment-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.15) !important;
            border-color: #667eea !important;
        }

        /* 반응형 디자인 */
        @media (max-width: 1200px) {
            .main-body {
                padding: 15px;
            }
            
            .project-details {
                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            }
        }
        
        @media (max-width: 900px) {
            .main-body {
                padding: 12px;
            }
            
            .project-details {
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            }
            
            .project-actions {
                justify-content: center;
            }
            
            .project-tabs .nav-tabs {
                justify-content: center;
            }
        }
        
        @media (max-width: 768px) {
            .main-body {
                padding: 10px;
                margin-top: 70px;
            }
            
            .project-info-card {
                padding: 20px;
                margin-bottom: 20px;
            }
            
            .project-title {
                font-size: 20px;
            }
            
            .project-details {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .project-actions {
                flex-direction: column;
                align-items: stretch;
                gap: 10px;
            }
            
            .action-btn {
                justify-content: center;
                width: 100%;
                padding: 14px 20px;
            }
            
            .project-tabs {
                margin: 20px 0;
                padding: 6px;
            }
            
            .project-tabs .nav-tabs {
                flex-wrap: wrap;
                gap: 5px;
            }
            
            .project-tabs .nav-link {
                padding: 10px 12px;
                font-size: 12px;
                min-width: 80px;
                text-align: center;
            }
            
            .section-header {
                flex-direction: column;
                gap: 15px;
                align-items: flex-start;
            }
            
            .content-section {
                padding: 20px;
            }
            
            .kanban-board {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .gantt-container {
                padding: 15px;
            }
        }
        
        @media (max-width: 480px) {
            .main-body {
                padding: 8px;
                margin-top: 60px;
            }
            
            .project-info-card {
                padding: 15px;
                margin-bottom: 15px;
            }
            
            .project-title {
                font-size: 18px;
                flex-direction: column;
                align-items: flex-start;
                gap: 8px;
            }
            
            .detail-item {
                padding: 12px;
            }
            
            .project-actions {
                gap: 8px;
            }
            
            .action-btn {
                padding: 12px 16px;
                font-size: 13px;
            }
            
            .project-tabs {
                padding: 4px;
                margin: 15px 0;
            }
            
            .project-tabs .nav-tabs {
                gap: 3px;
            }
            
            .project-tabs .nav-link {
                padding: 8px 10px;
                font-size: 11px;
                min-width: 70px;
            }
            
            .content-section {
                padding: 15px;
            }
        }
        
        /* 애니메이션 */
        .project-info-card,
        .content-section,
        .project-tabs {
            animation: fadeInUp 0.6s ease-out;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* AI 상담 모달 스타일 */
        .ai-chat-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 10000;
            backdrop-filter: blur(5px);
        }

        .ai-chat-modal-content {
            background: white;
            border-radius: 20px;
            width: 800px;
            max-width: 90vw;
            height: 700px;
            max-height: 85vh;
            display: flex;
            flex-direction: column;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            overflow: hidden;
            animation: modalSlideIn 0.3s ease-out;
        }

        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: scale(0.9) translateY(50px);
            }
            to {
                opacity: 1;
                transform: scale(1) translateY(0);
            }
        }

        .ai-chat-header {
            background: #3b82f6;
            color: white;
            padding: 20px 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(59, 130, 246, 0.3);
        }

        .ai-chat-header h3 {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .ai-chat-close {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .ai-chat-close:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: rotate(90deg);
        }

        .project-context-section {
            background: linear-gradient(135deg, #f8f9fc 0%, #eef2ff 100%);
            padding: 20px 25px;
            border-bottom: 1px solid #e2e8f0;
        }

        .project-context-info h4 {
            margin: 0 0 10px 0;
            color: #2d3748;
            font-size: 16px;
            font-weight: 600;
        }

        .context-details {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
        }

        .context-details span {
            color: #4a5568;
            font-size: 14px;
            background: white;
            padding: 8px 12px;
            border-radius: 20px;
            border: 1px solid #e2e8f0;
        }

        .ai-chat-container {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .ai-chat-messages {
            flex: 1;
            padding: 25px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 20px;
            scroll-behavior: smooth;
        }

        .chat-message {
            display: flex;
            gap: 12px;
            align-items: flex-start;
            animation: messageSlideIn 0.3s ease-out;
        }

        @keyframes messageSlideIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .chat-message.user {
            flex-direction: row-reverse;
        }

        .message-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 16px;
            flex-shrink: 0;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.2);
        }

        .chat-message.ai .message-avatar {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }

        .chat-message.user .message-avatar {
            background: #3b82f6;
        }

        .message-content {
            max-width: 70%;
            padding: 16px 20px;
            border-radius: 18px;
            position: relative;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .chat-message.ai .message-content {
            background: linear-gradient(135deg, #f8f9fc 0%, #ffffff 100%);
            color: #2d3748;
            border-bottom-left-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        .chat-message.user .message-content {
            background: #3b82f6;
            color: white;
            border-bottom-right-radius: 8px;
        }

        .message-text {
            line-height: 1.6;
            word-wrap: break-word;
            white-space: pre-wrap;
        }

        .message-time {
            font-size: 11px;
            opacity: 0.6;
            margin-top: 8px;
            text-align: right;
        }

        .ai-quick-actions {
            padding: 15px 25px;
            background: #f8f9fc;
            border-top: 1px solid #e2e8f0;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: center;
        }

        .quick-action-btn {
            background: linear-gradient(135deg, #ffffff 0%, #f8f9fc 100%);
            border: 2px solid #e2e8f0;
            color: #4a5568;
            padding: 10px 16px;
            border-radius: 25px;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .quick-action-btn:hover {
            background: #3b82f6;
            color: white;
            border-color: #3b82f6;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(59, 130, 246, 0.3);
        }

        .ai-chat-input-area {
            padding: 20px 25px;
            background: white;
            border-top: 1px solid #e2e8f0;
            display: flex;
            gap: 15px;
            align-items: flex-end;
        }

        #aiChatInput {
            flex: 1;
            border: 2px solid #e2e8f0;
            border-radius: 15px;
            padding: 12px 16px;
            font-size: 14px;
            resize: none;
            transition: all 0.3s ease;
            font-family: inherit;
        }

        #aiChatInput:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        #aiSendBtn {
            background: #3b82f6;
            border: none;
            color: white;
            width: 45px;
            height: 45px;
            border-radius: 50%;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 3px 10px rgba(59, 130, 246, 0.3);
        }

        #aiSendBtn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(59, 130, 246, 0.4);
        }

        /* 스크롤바 스타일 */
        .ai-chat-messages::-webkit-scrollbar {
            width: 6px;
        }

        .ai-chat-messages::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 3px;
        }

        .ai-chat-messages::-webkit-scrollbar-thumb {
            background: #c1c1c1;
            border-radius: 3px;
        }

        .ai-chat-messages::-webkit-scrollbar-thumb:hover {
            background: #a8a8a8;
        }

        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .ai-chat-modal-content {
                width: 95vw;
                height: 90vh;
                border-radius: 15px;
            }

            .ai-chat-header {
                padding: 15px 20px;
            }

            .ai-chat-header h3 {
                font-size: 16px;
            }

            .ai-chat-messages {
                padding: 20px;
            }

            .message-content {
                max-width: 85%;
                padding: 12px 16px;
            }

            .context-details {
                flex-direction: column;
                gap: 10px;
            }

            .ai-quick-actions {
                padding: 12px 20px;
            }

            .quick-action-btn {
                width: 100%;
                text-align: center;
            }
        }

        /* 간단한 간트 차트 스타일 - 깔끔한 디자인 */
        .simple-gantt {
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            overflow: hidden;
            background: white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .gantt-header {
            display: grid;
            grid-template-columns: 200px repeat(12, 1fr);
            background: #f8f9fa;
            border-bottom: 1px solid #e0e0e0;
        }

        .gantt-task-header, .gantt-month-header {
            padding: 12px 8px;
            font-weight: 500;
            text-align: center;
            border-right: 1px solid #e0e0e0;
            color: #495057;
            font-size: 13px;
        }
        
        .gantt-month-header {
            background: white;
            color: #333;
            border-bottom: 1px solid #e0e0e0;
        }

        .gantt-task-header {
            background: #4285f4;
            color: white;
            text-align: left;
            padding-left: 16px;
        }

        .gantt-row {
            display: grid;
            grid-template-columns: 200px repeat(12, 1fr);
            border-bottom: 1px solid #f1f3f4;
            min-height: 45px;
        }

        .gantt-row:hover {
            background: #f8f9fa;
        }

        .gantt-task-name {
            padding: 12px 16px;
            font-weight: 400;
            border-right: 1px solid #e0e0e0;
            display: flex;
            align-items: center;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            background: white;
            font-size: 14px;
            color: #333;
        }

        .gantt-month-cell {
            border-right: 1px solid rgba(224, 224, 224, 0.5);
            position: relative;
            min-height: 45px;
            display: flex;
            align-items: center;
            padding: 0;
        }
        
        /* 태스크가 있는 셀의 경계선 완전 제거 */
        .gantt-month-cell.gantt-task-bar {
            border-right: none;
        }
        
        /* 연속적인 태스크 바를 위한 개선된 스타일 */
        .task-bar-start {
            margin-right: 0;
            border-top-right-radius: 0 !important;
            border-bottom-right-radius: 0 !important;
        }
        
        .task-bar-middle {
            margin: 0;
            border-radius: 0 !important;
        }
        
        .task-bar-end {
            margin-left: 0;
            border-top-left-radius: 0 !important;
            border-bottom-left-radius: 0 !important;
        }

        .gantt-task-bar .task-bar {
            height: 28px;
            width: 100%;
            margin: 0;
            border-radius: 14px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.12);
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .gantt-task-bar .task-bar:hover {
            transform: translateY(-2px) scale(1.02);
            box-shadow: 0 8px 25px rgba(0,0,0,0.2);
            z-index: 10;
        }

        .gantt-task-bar .task-bar::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(255,255,255,0.3) 0%, transparent 50%, rgba(255,255,255,0.1) 100%);
            pointer-events: none;
        }

        .gantt-task-bar .task-bar::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(45deg, transparent 30%, rgba(255,255,255,0.4) 50%, transparent 70%);
            transform: translateX(-100%);
            transition: transform 2s ease-in-out;
            pointer-events: none;
        }

        .gantt-task-bar .task-bar:hover::after {
            transform: translateX(100%);
        }

        /* 더 깔끔한 호버 효과 */
        .gantt-task-bar .task-bar:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 16px rgba(0,0,0,0.2);
        }

        /* 간트 차트 전체적인 개선 - 깔끔한 스타일 */
        .simple-gantt {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .gantt-header {
            background: #f8f9fa;
            border-bottom: 1px solid #e0e0e0;
        }
        
        /* 월별 헤더 깔끔한 스타일 */
        .gantt-header .gantt-month-header {
            background: white;
            color: #333;
        }

        .gantt-task-header {
            background: #4285f4;
            color: white;
            font-weight: 500;
            letter-spacing: normal;
        }

        /* 칸반 보드 스타일 - 깔끔한 디자인 */
        .kanban-board {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            padding: 0;
            min-height: 500px;
        }

        .kanban-column {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            display: flex;
            flex-direction: column;
            min-height: 450px;
            transition: all 0.2s ease;
            border: 1px solid #e0e0e0;
        }

        .kanban-column:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }

        .kanban-header {
            padding: 18px 20px;
            border-bottom: 1px solid #e0e0e0;
            background: #f8f9fa;
            color: #333;
            border-radius: 12px 12px 0 0;
        }

        .kanban-title {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-weight: 500;
            font-size: 16px;
        }

        .kanban-title i {
            margin-right: 8px;
            font-size: 16px;
            color: #4285f4;
        }

        .task-count {
            background: #4285f4;
            color: white;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
            min-width: 24px;
            text-align: center;
        }

        .kanban-content {
            flex: 1;
            padding: 15px;
            overflow-y: auto;
            max-height: 400px;
        }

        .task-card {
            background: white;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 12px;
            cursor: grab;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }

        .task-card:hover {
            border-color: #667eea;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.15);
            transform: translateY(-2px);
        }

        .task-card:active {
            cursor: grabbing;
            transform: rotate(5deg);
        }

        .task-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
        }

        .task-title {
            font-weight: 600;
            color: #2d3748;
            font-size: 14px;
            line-height: 1.4;
            flex: 1;
            margin-right: 10px;
        }

        .task-actions {
            display: flex;
            gap: 5px;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .task-card:hover .task-actions {
            opacity: 1;
        }

        .btn-task-edit {
            background: #f7fafc;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            padding: 6px 8px;
            color: #4a5568;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 12px;
        }

        .btn-task-edit:hover {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }

        .task-meta {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .task-assignee, .task-due-date {
            display: flex;
            align-items: center;
            font-size: 12px;
            color: #6c757d;
        }

        .task-assignee i, .task-due-date i {
            margin-right: 6px;
            width: 12px;
            font-size: 11px;
        }



        /* 드래그 앤 드롭 스타일 */
        .kanban-column.drag-over {
            background: rgba(102, 126, 234, 0.1);
            border: 2px dashed #667eea;
        }

        .task-card.dragging {
            opacity: 0.5;
            transform: rotate(5deg);
        }

        /* 칸반 컬럼 깔끔한 색상 */
        .kanban-column[data-status="TODO"] .kanban-header {
            background: #f8f9fa;
            color: #495057;
            border-bottom: 3px solid #6c757d;
        }

        .kanban-column[data-status="IN_PROGRESS"] .kanban-header {
            background: #f8f9fa;
            color: #495057;
            border-bottom: 3px solid #4285f4;
        }

        .kanban-column[data-status="DONE"] .kanban-header {
            background: #f8f9fa;
            color: #495057;
            border-bottom: 3px solid #28a745;
        }

        /* 반응형 디자인 */
        @media (max-width: 1024px) {
            .kanban-board {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .kanban-column {
                min-height: 300px;
            }
        }

        @media (max-width: 768px) {
            .kanban-board {
                padding: 15px;
            }
            
            .task-card {
                padding: 12px;
            }
            
            .task-title {
                font-size: 13px;
            }
        }

        /* 편집 모달 스타일 - 깔끔한 디자인 */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }

        .modal-overlay.show {
            opacity: 1;
            visibility: visible;
        }

        .modal-content {
            background: white;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
            width: 500px;
            max-width: 90vw;
            max-height: 90vh;
            overflow: hidden;
            transform: scale(0.9);
            transition: transform 0.3s ease;
        }

        .modal-overlay.show .modal-content {
            transform: scale(1);
        }

        .modal-header {
            background: #4285f4;
            color: white;
            padding: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-header h3 {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
        }

        .modal-header h3 i {
            margin-right: 10px;
        }

        .modal-close {
            background: none;
            border: none;
            color: white;
            font-size: 18px;
            cursor: pointer;
            padding: 5px;
            border-radius: 50%;
            transition: all 0.3s ease;
        }

        .modal-close:hover {
            background: rgba(255, 255, 255, 0.2);
        }

        .modal-body {
            padding: 25px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #2d3748;
            font-size: 14px;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.3s ease;
            box-sizing: border-box;
            background: white;
            font-family: inherit;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        .form-group textarea {
            resize: vertical;
            min-height: 80px;
        }

        .form-group select {
            cursor: pointer;
        }

        .form-group select option {
            padding: 8px;
        }

        .modal-footer {
            padding: 20px 25px;
            background: #f8f9fc;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }

        .btn-secondary {
            background: #e2e8f0;
            color: #4a5568;
        }

        .btn-secondary:hover {
            background: #cbd5e0;
        }

        .btn-primary {
            background: #4285f4;
            color: white;
        }

        .btn-primary:hover {
            background: #3367d6;
            transform: translateY(-1px);
            box-shadow: 0 3px 8px rgba(66, 133, 244, 0.3);
        }

        /* 토스트 메시지 스타일 */
        .toast-message {
            position: fixed;
            top: 20px;
            right: 20px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
            padding: 15px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            z-index: 10000;
            transform: translateX(100%);
            transition: transform 0.3s ease;
            min-width: 300px;
        }

        .toast-message.show {
            transform: translateX(0);
        }

        .toast-message.success {
            border-left: 4px solid #10b981;
        }

        .toast-message.success i {
            color: #10b981;
            font-size: 18px;
        }

        .toast-message.error {
            border-left: 4px solid #ef4444;
        }

        .toast-message.error i {
            color: #ef4444;
            font-size: 18px;
        }

        .toast-message span {
            color: #2d3748;
            font-weight: 500;
        }
        


    </style>
</head>
<body>
<div class="sidebar">
    <%@ include file="../layout/sidebar.jsp" %>
</div>
<div class="content">
    <%@ include file="../layout/header.jsp" %>>
    <div class="main-body">
        <!-- 프로젝트 정보 카드 -->
        <div class="project-info-card">
             <div style="display: flex; justify-content: space-between; align-items: start; flex-wrap: wrap; gap: 20px;">
                <div style="flex: 1; min-width: 300px;">
                    <div class="project-title">
                        <i class="fas fa-project-diagram"></i>
                        ${projectDetail.project.title}
                    </div>
                    <div class="project-details">
                        <div class="detail-item">
                            <strong><i class="fas fa-info-circle"></i> 프로젝트 설명</strong>
                            <span>${projectDetail.project.description}</span>
                        </div>
                        <div class="detail-item">
                            <strong><i class="fas fa-flag"></i> 상태</strong>
                            <span>${projectDetail.project.status}</span>
                        </div>
                        <div class="detail-item">
                            <strong><i class="fas fa-calendar-alt"></i> 기간</strong>
                            <span>${projectDetail.project.startDate} ~ ${projectDetail.project.endDate}</span>
                        </div>
                        <div class="detail-item">
                            <strong><i class="fas fa-crown"></i> 팀장</strong>
                        <c:set var="leaderName" value=""/>
                        <c:forEach items="${projectDetail.members}" var="member">
                            <c:if test="${member.role == 'LEADER'}">
                                <c:set var="leaderName" value="${member.userName}"/>
                            </c:if>
                        </c:forEach>
                            <span>${leaderName}</span>
                        </div>
                        <div class="detail-item">
                            <strong><i class="fas fa-users"></i> 팀원</strong>
                            <span>
                            <c:forEach items="${projectDetail.members}" var="member" varStatus="status">
                                <c:if test="${member.role != 'LEADER'}">
                                    ${member.userName}<c:if test="${not status.last}">, </c:if>
                                </c:if>
                            </c:forEach>
                            </span>
                        </div>
                    </div>
                </div>
                <div class="project-actions">
                    <a href="${pageContext.request.contextPath}/projects" class="action-btn btn-list">
                        <i class="fas fa-list"></i> 목록으로
                    </a>
                    <a href="${pageContext.request.contextPath}/projects/${projectDetail.project.id}/members" class="action-btn btn-members">
                        <i class="fas fa-user-friends"></i> 팀원 관리
                    </a>
                    <a href="${pageContext.request.contextPath}/projects/${projectDetail.project.id}/reports" class="action-btn btn-reports">
                        <i class="fas fa-file-alt"></i> 보고서
                    </a>
                    <button class="action-btn btn-ai-chat" id="openAiChatBtn" onclick="openAiChat()">
                        <i class="fas fa-robot"></i> 🤖 AI 상담
                    </button>
                </div>
            </div>
        </div>

        <!-- 탭 네비게이션 -->
        <div class="project-tabs">
            <ul class="nav nav-tabs">
                <li class="nav-item">
                    <a class="nav-link active" href="#" data-tab="schedule">
                        <i class="fas fa-calendar-check"></i> 프로젝트 일정
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" data-tab="tasks">
                        <i class="fas fa-tasks"></i> 작업 목록
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" data-tab="equipment">
                        <i class="fas fa-tools"></i> 기자재
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" data-tab="report">
                        <i class="fas fa-chart-bar"></i> 보고서
                    </a>
                </li>
            </ul>
        </div>

        <!-- 일정 섹션 -->
        <div id="schedule" class="content-section">
            <div class="section-header">
                 <h4 class="section-title">
                     <i class="fas fa-chart-gantt"></i>
                     간트 차트
                 </h4>
                                 <button class="btn btn-add-task" onclick="openTaskModal()">
                    <i class="fas fa-plus"></i> 태스크 추가
                </button>
            </div>
            <div class="gantt-container">
                <div id="gantt-chart"></div>
            </div>
        </div>

        <!-- 작업 목록 섹션 (칸반 보드) -->
        <div id="tasks" class="content-section" style="display:none;">
            <div class="section-header">
                <h4 class="section-title">
                    <i class="fas fa-tasks"></i>
                    작업 목록 (To-Do List)
                </h4>
                <button class="btn btn-add-task" onclick="openTaskModal()">
                    <i class="fas fa-plus"></i> 새 작업 추가
                </button>
            </div>
            
            <div class="kanban-board">
                <!-- To Do 컬럼 -->
                <div class="kanban-column" data-status="TODO">
                    <div class="kanban-header">
                        <div class="kanban-title">
                            <i class="fas fa-clipboard-list"></i>
                            <span>To Do</span>
                            <span class="task-count" id="todo-count">0</span>
                        </div>
                    </div>
                    <div class="kanban-content" id="todo-tasks">
                    <c:forEach items="${projectDetail.tasks}" var="task">
                            <c:if test="${task.status == 'TODO'}">
                                <div class="task-card" data-task-id="${task.id}" draggable="true">
                                    <div class="task-header">
                                        <span class="task-title">${task.title}</span>
                                        <div class="task-actions">
                                            <button class="btn-task-edit">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                        </div>
                                    </div>
                                    <div class="task-meta">
                                        <div class="task-assignee">
                                            <i class="fas fa-user"></i>
                                            <span><c:choose><c:when test="${not empty task.assignedToUserName}">${task.assignedToUserName}</c:when><c:otherwise>담당자 미지정</c:otherwise></c:choose></span>
                                        </div>
                                        <div class="task-due-date">
                                            <i class="fas fa-calendar"></i>
                                            <span><c:choose><c:when test="${not empty task.dueDate}">${task.dueDate}</c:when><c:otherwise>날짜 미지정</c:otherwise></c:choose></span>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                    </c:forEach>
        </div>

        </div>

                <!-- In Progress 컬럼 -->
                <div class="kanban-column" data-status="IN_PROGRESS">
                    <div class="kanban-header">
                        <div class="kanban-title">
                            <i class="fas fa-spinner"></i>
                            <span>In Progress</span>
                            <span class="task-count" id="progress-count">0</span>
        </div>
                    </div>
                    <div class="kanban-content" id="progress-tasks">
                        <c:forEach items="${projectDetail.tasks}" var="task">
                            <c:if test="${task.status == 'IN_PROGRESS'}">
                                <div class="task-card" data-task-id="${task.id}" draggable="true">
                                    <div class="task-header">
                                        <span class="task-title">${task.title}</span>
                                        <div class="task-actions">
                                            <button class="btn-task-edit">
                                                <i class="fas fa-edit"></i>
                                            </button>
                                        </div>
                                    </div>
                                    <div class="task-meta">
                                        <div class="task-assignee">
                                            <i class="fas fa-user"></i>
                                            <span><c:choose><c:when test="${not empty task.assignedToUserName}">${task.assignedToUserName}</c:when><c:otherwise>담당자 미지정</c:otherwise></c:choose></span>
                                        </div>
                                        <div class="task-due-date">
                                            <i class="fas fa-calendar"></i>
                                            <span><c:choose><c:when test="${not empty task.dueDate}">${task.dueDate}</c:when><c:otherwise>날짜 미지정</c:otherwise></c:choose></span>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>

    </div>

                <!-- Done 컬럼 -->
                <div class="kanban-column" data-status="DONE">
                    <div class="kanban-header">
                        <div class="kanban-title">
                            <i class="fas fa-check-circle"></i>
                            <span>Done</span>
                            <span class="task-count" id="done-count">0</span>
                        </div>
                    </div>
                    <div class="kanban-content" id="done-tasks">
                        <c:forEach items="${projectDetail.tasks}" var="task">
                            <c:if test="${task.status == 'DONE'}">
                                <div class="task-card" data-task-id="${task.id}" draggable="true">
                                    <div class="task-header">
                                        <span class="task-title">${task.title}</span>
                                        <div class="task-actions">
                                            <button class="btn-task-edit">
                                                <i class="fas fa-edit"></i>
                        </button>
                    </div>
                        </div>
                                    <div class="task-meta">
                                        <div class="task-assignee">
                                            <i class="fas fa-user"></i>
                                            <span><c:choose><c:when test="${not empty task.assignedToUserName}">${task.assignedToUserName}</c:when><c:otherwise>담당자 미지정</c:otherwise></c:choose></span>
                        </div>
                                        <div class="task-due-date">
                                            <i class="fas fa-calendar"></i>
                                            <span><c:choose><c:when test="${not empty task.dueDate}">${task.dueDate}</c:when><c:otherwise>날짜 미지정</c:otherwise></c:choose></span>
                            </div>
                            </div>
                        </div>
                            </c:if>
                                </c:forEach>
                        </div>

                    </div>
                    </div>
            </div>
        
                <!-- 보고서 섹션 -->
        <div id="report" class="content-section" style="display:none;">
             <div class="section-header">
                 <h4 class="section-title">
                     <i class="fas fa-file-upload"></i>
                     보고서 관리
                 </h4>
                 <a href="${pageContext.request.contextPath}/projects/${projectDetail.project.id}/reports" class="btn btn-primary">
                     <i class="fas fa-external-link-alt"></i> 보고서 페이지로 이동
                 </a>
             </div>
             
             <!-- 업로드된 보고서 목록 미리보기 -->
             <div class="reports-preview">
                 <c:choose>
                     <c:when test="${not empty reports}">
                         <div class="reports-list">
                             <c:forEach items="${reports}" var="report" varStatus="status">
                                 <c:if test="${status.index < 3}"> <!-- 최대 3개만 미리보기 -->
                                     <div class="report-item">
                                         <div class="report-icon">
                                             <i class="fas fa-file-alt"></i>
                                         </div>
                                         <div class="report-info">
                                             <div class="report-name">${report.fileName}</div>
                                             <div class="report-date">업로드: ${report.uploadedAt}</div>
                                         </div>
                                         <div class="report-actions">
                                             <a href="${pageContext.request.contextPath}/projects/${projectDetail.project.id}/reports/download/${report.id}" 
                                                class="btn btn-sm btn-outline-primary">
                                                 <i class="fas fa-download"></i>
                                             </a>
                                         </div>
                                     </div>
                                 </c:if>
                             </c:forEach>
                             <c:if test="${fn:length(reports) > 3}">
                                 <div class="more-reports">
                                     <a href="${pageContext.request.contextPath}/projects/${projectDetail.project.id}/reports">
                                         +${fn:length(reports) - 3}개 더 보기
                                     </a>
                                 </div>
                             </c:if>
                         </div>
                     </c:when>
                     <c:otherwise>
                         <div class="empty-state">
                             <i class="fas fa-file-alt"></i>
                             <h5>업로드된 보고서가 없습니다</h5>
                             <p>보고서 페이지로 이동하여 파일을 업로드해보세요.</p>
                         </div>
                     </c:otherwise>
                 </c:choose>
        </div>
    </div>

    <!-- 기자재 섹션 -->
    <div id="equipment" class="content-section" style="display:none;">
        <div class="section-header" style="display: flex; justify-content: space-between; align-items: center;">
            <div>
                <h4 class="section-title">
                    <i class="fas fa-tools"></i>
                    프로젝트 기자재 현황
                </h4>
                <small style="color: #6c757d;">이 프로젝트에서 사용중인 기자재 목록입니다</small>
            </div>
            <c:if test="${not empty availableEquipments}">
                <button onclick="showAddEquipmentModal()" class="btn btn-primary" style="background: #3b82f6; color: white; padding: 10px 20px; border-radius: 8px; border: none; font-weight: 600;">
                    <i class="fas fa-plus" style="margin-right: 6px;"></i>기자재 추가
                </button>
            </c:if>
        </div>
        
        <c:choose>
            <c:when test="${not empty projectEquipments}">
                <div class="equipment-list" style="margin-top: 20px;">
                    <c:forEach items="${projectEquipments}" var="equipment">
                        <div class="equipment-item" style="background: white; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px; margin-bottom: 15px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); transition: all 0.3s ease;">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 20px;">
                                <!-- 기자재 정보 -->
                                <div style="flex: 1;">
                                    <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 12px;">
                                                        <div style="width: 50px; height: 50px; background: #3b82f6; border-radius: 10px; display: flex; align-items: center; justify-content: center;">
                    <i class="fas fa-tools" style="color: white; font-size: 20px;"></i>
                </div>
                                        <div>
                                            <h5 style="margin: 0; color: #2d3748; font-weight: 600; font-size: 16px;">
                                                <c:out value="${equipment.equipmentName}" />
                                            </h5>
                                            <small style="color: #6c757d; font-size: 13px;">
                                                기자재 ID: ${equipment.equipmentId}
                                            </small>
                                        </div>
                                    </div>
                                    
                                    <!-- 대여/사용 정보 -->
                                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-top: 15px;">
                                        <div>
                                            <strong style="color: #4a5568; font-size: 13px; display: block; margin-bottom: 4px;">
                                                <i class="fas fa-user" style="margin-right: 6px;"></i>대여자
                                            </strong>
                                            <span style="color: #2d3748; font-weight: 500;">
                                                <c:out value="${equipment.renterName}" />
                                            </span>
                                        </div>
                                    </div>
                                    
                                    <!-- 프로젝트 사용 목적 -->
                                    <c:if test="${not empty equipment.purpose}">
                                        <div style="margin-top: 15px; padding: 12px; background: #f7fafc; border-radius: 8px; border-left: 4px solid #667eea;">
                                            <strong style="color: #4a5568; font-size: 13px; display: block; margin-bottom: 4px;">
                                                <i class="fas fa-comment-alt" style="margin-right: 6px;"></i>프로젝트에서 사용 목적
                                            </strong>
                                            <span style="color: #2d3748; font-size: 14px; line-height: 1.4;">
                                                <c:out value="${equipment.purpose}" />
                                            </span>
                                        </div>
                                    </c:if>
                                </div>
                                
                                <!-- 상태 및 액션 -->
                                <div style="text-align: center;">
                                    <div style="background: #10b981; color: white; padding: 8px 16px; border-radius: 20px; font-size: 13px; font-weight: 600; margin-bottom: 12px;">
                                        <i class="fas fa-check-circle" style="margin-right: 6px;"></i>프로젝트 사용중
                                    </div>
                                    <div style="display: flex; flex-direction: column; gap: 8px;">
                                        <a href="${pageContext.request.contextPath}/equipment/detail/${equipment.equipmentId}" 
                                           class="btn btn-sm" 
                                           style="background: #e2e8f0; color: #4a5568; padding: 8px 16px; border-radius: 8px; text-decoration: none; font-size: 13px; font-weight: 500;">
                                            <i class="fas fa-info-circle" style="margin-right: 6px;"></i>상세정보
                                        </a>
                                        <button onclick="removeEquipmentFromProject('${equipment.id}')" 
                                                class="btn btn-sm" 
                                                style="background: #fed7d7; color: #e53e3e; padding: 8px 16px; border-radius: 8px; border: none; font-size: 13px; font-weight: 500; cursor: pointer;">
                                            <i class="fas fa-times" style="margin-right: 6px;"></i>제거
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state" style="text-align: center; padding: 60px 20px; color: #3c3d3d;">
                    <i class="fas fa-tools" style="font-size: 4em; margin-bottom: 20px; opacity: 0.3;"></i>
                    <h5 style="margin-bottom: 10px; font-weight: 600;">프로젝트에 등록된 기자재가 없습니다</h5>
                    <p style="opacity: 0.7; margin-bottom: 20px;">팀원들이 대여중인 기자재를 프로젝트에 추가해보세요.</p>
                    <a href="${pageContext.request.contextPath}/equipment/list" 
                       class="btn btn-primary" 
                       style="background: #60a5fa; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600;">
                        <i class="fas fa-search" style="margin-right: 8px;"></i>기자재 둘러보기
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- 기자재 추가 모달 -->
    <div id="addEquipmentModal" class="modal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5);">
        <div class="modal-content" style="background-color: #fefefe; margin: 10% auto; padding: 20px; border-radius: 12px; width: 80%; max-width: 600px; max-height: 70vh; overflow-y: auto;">
            <div class="modal-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid #e9ecef;">
                <h3 style="margin: 0; color: #2d3748;">
                    <i class="fas fa-plus-circle" style="margin-right: 10px; color: #667eea;"></i>프로젝트에 기자재 추가
                </h3>
                <button onclick="closeAddEquipmentModal()" style="background: none; border: none; font-size: 24px; color: #6c757d; cursor: pointer;">&times;</button>
            </div>
            <div class="modal-body">
                <p style="color: #6c757d; margin-bottom: 20px;">팀원들이 현재 대여중인 기자재 중에서 이 프로젝트에 사용할 기자재를 선택하세요.</p>
                <div id="availableEquipmentsList">
                    <c:forEach items="${availableEquipments}" var="available">
                        <div class="available-equipment-item" style="border: 1px solid #e9ecef; border-radius: 8px; padding: 15px; margin-bottom: 10px; cursor: pointer; transition: all 0.2s;" 
                             data-rental-id="${available.rentalId}" 
                             data-equipment-id="${available.equipmentId}">
                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <div>
                                    <h6 style="margin: 0 0 5px 0; color: #2d3748; font-weight: 600;" data-equipment-name="<c:out value='${available.equipmentName}' />">
                                        <c:out value="${available.equipmentName}" />
                                    </h6>
                                    <small style="color: #6c757d;" data-renter-name="<c:out value='${available.renterName}' />">
                                        대여자: <c:out value="${available.renterName}" /> | 기자재 ID: ${available.equipmentId}
                                    </small>
                                </div>
                                <div style="color: #667eea;">
                                    <i class="fas fa-arrow-right"></i>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </div>
    </div>

    </div>

    

    <%@ include file="../layout/footer.jsp" %>
</div>
<%@ include file="/WEB-INF/views/layout/scripts.jsp" %>

<!-- 프로젝트 멤버 데이터 (JSON) -->
<script type="application/json" id="projectMembersData">
[
<c:forEach items="${projectDetail.members}" var="member" varStatus="status">
  {"id": ${member.userId}, "name": "<c:out value='${member.userName}' />", "role": "<c:out value='${member.role}' />"}
  <c:if test="${not status.last}">,</c:if>
</c:forEach>
]
</script>

<script>
    // Tab switching with smooth animation
    document.querySelectorAll('.project-tabs .nav-link').forEach(tab => {
        tab.addEventListener('click', function(e) {
            e.preventDefault();

            // 비활성화
            document.querySelectorAll('.project-tabs .nav-link').forEach(t => t.classList.remove('active'));
            document.querySelectorAll('.content-section').forEach(s => {
                s.style.display = 'none';
                s.style.opacity = '0';
            });
            
            // 활성화
            this.classList.add('active');
            const tabId = this.dataset.tab;
            const contentToShow = document.getElementById(tabId);
            if(contentToShow) {
                contentToShow.style.display = 'block';
                setTimeout(() => {
                    contentToShow.style.opacity = '1';
                }, 50);
            }
        });
    });

    // Global variables
    let ganttChart = null;
    let currentTasks = [];
    let isInitializing = false;
    let projectMembers = [];

    // Initialize Gantt Chart
    function initGanttChart() {
        if (isInitializing) {
            console.log("Already initializing, skipping...");
            return;
        }
        
        isInitializing = true;
        console.log("===== 간트 차트 초기화 시작 =====");
        const tasksJson = '${tasksJson}';
        console.log("Raw tasksJson:", tasksJson);
        console.log("tasksJson length:", tasksJson ? tasksJson.length : 0);
        
        // 프로젝트 팀원 정보 로드
        initProjectMembers();
        
        if (tasksJson && tasksJson !== '' && tasksJson !== 'null') {
            try {
                currentTasks = JSON.parse(tasksJson.replace(/\\"/g, '"'));
                console.log("Parsed tasks:", currentTasks);
                console.log("Tasks count:", currentTasks.length);
                
                // 각 태스크의 날짜 정보 상세 출력
                currentTasks.forEach((task, index) => {
                    console.log(`Task ${index}:`, {
                        id: task.id,
                        title: task.title,
                        startDate: task.startDate,
                        dueDate: task.dueDate,
                        status: task.status
                    });
                });
                
                if (currentTasks && currentTasks.length > 0) {
                    console.log("Tasks found, rendering simple gantt chart");
                    renderSimpleGanttChart(prepareTasksForGantt(currentTasks));
                } else {
                    console.log("No tasks found, rendering empty chart");
                    renderEmptyGanttChart();
                }
            } catch(e) {
                console.error("Gantt Chart data parsing error:", e);
                console.error("Raw data:", tasksJson);
                renderEmptyGanttChart();
            }
        } else {
            console.log("No tasks data, rendering empty chart");
            renderEmptyGanttChart();
        }
        
        isInitializing = false;
    }

    // 프로젝트 팀원 정보 초기화
    function initProjectMembers() {
        try {
            const membersElement = document.getElementById('projectMembersData');
            if (membersElement) {
                projectMembers = JSON.parse(membersElement.textContent);
                console.log("Project members loaded:", projectMembers);
                console.log("Members count:", projectMembers.length);
            } else {
                projectMembers = [];
            }
        } catch (e) {
            console.error("Error parsing project members:", e);
            projectMembers = [];
        }
    }

    // Render Empty Gantt Chart
    function renderEmptyGanttChart() {
        const chartElement = document.getElementById('gantt-chart');
        chartElement.innerHTML = `
            <div class="empty-state" style="padding: 40px;">
                <i class="fas fa-chart-gantt"></i>
                <h5>등록된 태스크가 없습니다</h5>
                <p>새로운 태스크를 추가하여 프로젝트 일정을 관리해보세요.</p>
            </div>
        `;
    }

    // 태스크 데이터 준비
    function prepareTasksForGantt(tasks) {
        console.log("===== prepareTasksForGantt 시작 =====");
        console.log("받은 tasks:", tasks);
        
        return tasks.map((task, index) => {
            console.log(`Processing task ${index}:`, task.title);
            // 안전한 날짜 파싱
            let startDate = '2025-01-01';
            let endDate = '2025-01-01';
            
            try {
                if (task.startDate) {
                    startDate = task.startDate.substring(0, 10);
                } else {
                    startDate = new Date().toISOString().substring(0, 10);
                }
                
                if (task.dueDate) {
                    endDate = task.dueDate.substring(0, 10);
                } else {
                    endDate = startDate;
                }
                
                // 시작일이 종료일보다 늦으면 수정
                if (new Date(startDate) > new Date(endDate)) {
                    endDate = startDate;
                }
                
                console.log('Task ' + index + ' processed dates:', {
                    title: task.title,
                    originalStart: task.startDate,
                    originalEnd: task.dueDate,
                    processedStart: startDate,
                    processedEnd: endDate
                });
            } catch (e) {
                console.log('Date parsing error for task ' + index + ':', e);
                const today = new Date().toISOString().substring(0, 10);
                startDate = today;
                endDate = today;
            }
            
                const ganttTask = {
                id: 'task_' + task.id,
                name: (task.title || 'Untitled Task').substring(0, 30),
                start: startDate,  // 수정된 날짜 사용
                end: endDate,      // 수정된 날짜 사용
                color: task.color || '#667eea',
                progress: task.status === 'DONE' ? 100 : (task.status === 'IN_PROGRESS' ? 50 : 0)
                };
                
                console.log(`Created gantt task ${index}:`, ganttTask);
                console.log(`Using corrected dates - start: ${startDate}, end: ${endDate}`);
                return ganttTask;
            });
    }

        // 이 함수는 더 이상 사용하지 않습니다 (간단한 간트 차트 사용)
    
    // 간단한 간트 차트 렌더링 (개선된 버전)
    function renderSimpleGanttChart(tasks) {
        const chartElement = document.getElementById('gantt-chart');
        
        // 차트 요소 완전 정리
        chartElement.innerHTML = '';
        chartElement.removeAttribute('style');
        
        console.log("Rendering simple gantt chart with", tasks.length, "tasks");
        
        // 동적 연도 및 월 생성 (현재 연도 기준)
        const currentYear = new Date().getFullYear();
        const months = [];
        for (let i = 1; i <= 12; i++) {
            months.push(i + '월');
        }
        
        let html = '<div class="simple-gantt">';
        
        // 헤더 생성
        html += '<div class="gantt-header">';
        html += '<div class="gantt-task-header">작업 (' + currentYear + '년)</div>';
        months.forEach(month => {
            html += '<div class="gantt-month-header">' + month + '</div>';
        });
        html += '</div>';
        
        // 태스크 행 생성
        tasks.forEach(task => {
            // 실제 날짜에서 월 추출
            const startMonth = getMonthFromDate(task.start);
            const endMonth = getMonthFromDate(task.end);
            
            console.log('===== GANTT TASK RENDERING =====');
            console.log('Task:', task.name);
            console.log('Start date string:', task.start);
            console.log('End date string:', task.end);
            console.log('Start month:', startMonth);
            console.log('End month:', endMonth);
            console.log('=====================================');
            
            html += '<div class="gantt-row">';
            html += '<div class="gantt-task-name" title="' + task.name + '">' + task.name + '</div>';
            
            for (let month = 1; month <= 12; month++) {
                let cellClass = 'gantt-month-cell';
                let cellContent = '';
                
                // 실제 작업 기간에만 태스크 바 표시
                if (month >= startMonth && month <= endMonth) {
                    cellClass += ' gantt-task-bar';
                    
                    // 더 간단하고 깔끔한 태스크 바 스타일링
                    let taskBarClass = 'task-bar';
                    let borderRadius = '14px';
                    
                    if (startMonth === endMonth) {
                        // 한 달짜리 태스크 - 완전히 둥글게
                        borderRadius = '14px';
                    } else if (month === startMonth) {
                        // 시작 월 - 왼쪽만 둥글게
                        borderRadius = '14px 0 0 14px';
                        taskBarClass += ' task-bar-start';
                    } else if (month === endMonth) {
                        // 끝 월 - 오른쪽만 둥글게  
                        borderRadius = '0 14px 14px 0';
                        taskBarClass += ' task-bar-end';
        } else {
                        // 중간 월들 - 직각
                        borderRadius = '0';
                        taskBarClass += ' task-bar-middle';
                    }
                    
                    cellContent = '<div class="' + taskBarClass + '" style="background: linear-gradient(135deg, ' + task.color + ', ' + adjustBrightness(task.color, -15) + '); border-radius: ' + borderRadius + '; border: none;"></div>';
                    console.log('Showing task bar in month:', month);
                }
                
                html += '<div class="' + cellClass + '">' + cellContent + '</div>';
            }
            html += '</div>';
        });
        
        html += '</div>';
        
        console.log("Generated HTML length:", html.length);
        console.log("Sample HTML:", html.substring(0, 500) + "...");
        
        chartElement.innerHTML = html;
        
        console.log("Simple gantt chart rendered successfully");
        console.log("Chart element children count:", chartElement.children.length);
    }
    
    // 날짜에서 월 추출
    function getMonthFromDate(dateStr) {
        try {
            // YYYY-MM-DD 형식에서 직접 월 추출
            if (dateStr && dateStr.length >= 7) {
                const monthStr = dateStr.substring(5, 7); // MM 부분 추출
                const month = parseInt(monthStr, 10);
                if (month >= 1 && month <= 12) {
                    console.log('Extracted month from', dateStr, ':', month);
                    return month;
                }
            }
            console.log('Failed to extract month from', dateStr, ', using current month');
            return new Date().getMonth() + 1; // 현재 월 반환 (0-based이므로 +1)
        } catch (e) {
            console.log('Error extracting month from', dateStr, ':', e);
            return new Date().getMonth() + 1;
        }
    }
    

    // 더 이상 사용하지 않는 함수 (간단한 간트 차트에서는 색상을 직접 적용)
    
    // 색상 밝기 조절 함수
    function adjustBrightness(color, amount) {
        const usePound = color[0] === "#";
        const col = usePound ? color.slice(1) : color;
        const num = parseInt(col, 16);
        let r = (num >> 16) + amount;
        let g = (num >> 8 & 0x00FF) + amount;
        let b = (num & 0x0000FF) + amount;
        r = r > 255 ? 255 : r < 0 ? 0 : r;
        g = g > 255 ? 255 : g < 0 ? 0 : g;
        b = b > 255 ? 255 : b < 0 ? 0 : b;
        return (usePound ? "#" : "") + (r << 16 | g << 8 | b).toString(16).padStart(6, '0');
    }

        // Open Task Popup
    function openTaskPopup(projectId, status) {
        let url = '${pageContext.request.contextPath}/projects/' + projectId + '/tasks/popup';
        if (status) {
            url += '?status=' + status;
        }
        
        const popup = window.open(
            url,
            'addTask',
            'width=500,height=700,scrollbars=yes,resizable=yes,left=' + 
            (screen.width/2 - 250) + ',top=' + (screen.height/2 - 350)
        );
        popup.focus();
    }

        // 칸반 보드 기능
        function initKanbanBoard() {
            updateTaskCounts();
            initDragAndDrop();
            initButtonEvents();
            updateAssigneeNames(); // 담당자 이름 업데이트
        }

        // 담당자 이름 업데이트 (ID를 실제 이름으로 변경)
        function updateAssigneeNames() {
            console.log("Updating assignee names...");
            console.log("Current tasks:", currentTasks);
            console.log("Project members:", projectMembers);
            
            if (!projectMembers || projectMembers.length === 0) {
                console.error("No project members available!");
                return;
            }
            
            currentTasks.forEach(task => {
                console.log(`Processing task ${task.id}: assignedTo=${task.assignedTo}, assignedToUserName=${task.assignedToUserName}`);
                
                if (task.assignedTo) {
                    const assignedMember = projectMembers.find(member => {
                        console.log(`Comparing member ${member.id} with task assignedTo ${task.assignedTo}`);
                        return member.id == task.assignedTo;
                    });
                    
                    if (assignedMember) {
                        console.log(`Found member:`, assignedMember);
                        
                        // task 객체 업데이트
                        task.assignedToUserName = assignedMember.name;
                        
                        // DOM에서 해당 태스크 카드 찾기
                        const taskCard = document.querySelector('[data-task-id="' + task.id + '"]');
                        if (taskCard) {
                            const assigneeSpan = taskCard.querySelector('.task-assignee span');
                            if (assigneeSpan) {
                                assigneeSpan.textContent = assignedMember.name;
                                console.log('Updated task', task.id, 'assignee DOM to:', assignedMember.name);
        } else {
                                console.error('Assignee span not found for task', task.id);
                            }
                        } else {
                            console.error('Task card not found for task', task.id);
                        }
                    } else {
                        console.error(`No member found for assignedTo ${task.assignedTo}`);
                    }
                } else {
                    console.log(`Task ${task.id} has no assignedTo value`);
                }
            });
        }

        // 버튼 이벤트 초기화
        function initButtonEvents() {
            // 편집 버튼 이벤트 리스너 추가
            document.querySelectorAll('.btn-task-edit').forEach(button => {
                button.addEventListener('click', function(e) {
        e.preventDefault();
                    e.stopPropagation();
                    const taskCard = this.closest('.task-card');
                    const taskId = taskCard.dataset.taskId;
                    console.log('Edit button clicked for task:', taskId);
                    editTask(taskId);
                });
            });
        }

        // 작업 개수 업데이트
        function updateTaskCounts() {
            const todoCount = document.querySelectorAll('#todo-tasks .task-card').length;
            const progressCount = document.querySelectorAll('#progress-tasks .task-card').length;
            const doneCount = document.querySelectorAll('#done-tasks .task-card').length;
            
            document.getElementById('todo-count').textContent = todoCount;
            document.getElementById('progress-count').textContent = progressCount;
            document.getElementById('done-count').textContent = doneCount;
        }

        // 드래그 앤 드롭 초기화
        function initDragAndDrop() {
            const taskCards = document.querySelectorAll('.task-card');
            const kanbanColumns = document.querySelectorAll('.kanban-content');

            // 태스크 카드 드래그 이벤트
            taskCards.forEach(card => {
                card.addEventListener('dragstart', function(e) {
                    e.dataTransfer.setData('text/plain', this.dataset.taskId);
                    this.classList.add('dragging');
                });

                card.addEventListener('dragend', function(e) {
                    this.classList.remove('dragging');
                });
            });

            // 컬럼 드롭 이벤트
            kanbanColumns.forEach(column => {
                column.addEventListener('dragover', function(e) {
                    e.preventDefault();
                    this.parentElement.classList.add('drag-over');
                });

                column.addEventListener('dragleave', function(e) {
                    if (!this.contains(e.relatedTarget)) {
                        this.parentElement.classList.remove('drag-over');
                    }
                });

                column.addEventListener('drop', function(e) {
                    e.preventDefault();
                    const taskId = e.dataTransfer.getData('text/plain');
                    const newStatus = this.parentElement.dataset.status;
                    
                    updateTaskStatus(taskId, newStatus);
                    this.parentElement.classList.remove('drag-over');
                });
            });
        }

        // 작업 상태 업데이트
        function updateTaskStatus(taskId, newStatus) {
            console.log('Updating task', taskId, 'to status', newStatus);
            
            // 현재 작업 데이터 가져오기
            const currentTask = currentTasks.find(task => task.id == taskId);
            if (!currentTask) {
                console.error('Task not found:', taskId);
                return;
            }
            
            // 서버로 전송할 데이터 준비 (상태만 변경)
            const taskData = {
                title: currentTask.title,
                description: currentTask.description || '',
                assignedTo: currentTask.assignedTo,
                startDate: currentTask.startDate,
                dueDate: currentTask.dueDate,
                status: newStatus,
                priority: currentTask.priority || 'MEDIUM',
                color: currentTask.color || '#3498db'
            };

            // 서버로 AJAX 요청 전송
            fetch('/projects/${projectDetail.project.id}/tasks/' + taskId, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(taskData)
            })
            .then(response => {
                console.log('Status update response:', response.status);
                return response.json();
            })
        .then(data => {
            if (data.success) {
                    // currentTasks 배열 업데이트
                    const taskIndex = currentTasks.findIndex(task => task.id == taskId);
                    if (taskIndex !== -1) {
                        currentTasks[taskIndex].status = newStatus;
                    }
                    
                    // DOM 이동
                    const taskCard = document.querySelector('[data-task-id="' + taskId + '"]');
                    if (taskCard) {
                        let targetContainer;
                        switch(newStatus) {
                            case 'TODO':
                                targetContainer = document.getElementById('todo-tasks');
                                break;
                            case 'IN_PROGRESS':
                                targetContainer = document.getElementById('progress-tasks');
                                break;
                            case 'DONE':
                                targetContainer = document.getElementById('done-tasks');
                                break;
                        }
                        
                        if (targetContainer) {
                            targetContainer.appendChild(taskCard);
                            updateTaskCounts();
                        }
                    }
                    
                    console.log('Task status updated successfully');
                } else {
                    throw new Error(data.message || '상태 변경에 실패했습니다.');
                }
            })
            .catch(error => {
                console.error('Error updating task status:', error);
                // 오류 발생 시 원래 위치로 되돌리기는 복잡하므로, 페이지 새로고침 권장
                showErrorMessage('상태 변경 중 오류가 발생했습니다. 페이지를 새로고침해주세요.');
            });
        }

        // 작업 편집
        function editTask(taskId) {
            console.log('Editing task:', taskId);
            
            // 현재 작업 카드 정보 가져오기
            const taskCard = document.querySelector('[data-task-id="' + taskId + '"]');
            if (!taskCard) {
                console.error('Task card not found for ID:', taskId);
                return;
            }
            
            const titleElement = taskCard.querySelector('.task-title');
            const assigneeElement = taskCard.querySelector('.task-assignee span');
            const dueDateElement = taskCard.querySelector('.task-due-date span');
            
            console.log('Title element:', titleElement);
            console.log('Assignee element:', assigneeElement);
            console.log('Due date element:', dueDateElement);
            
            const currentTitle = titleElement ? titleElement.textContent.trim() : '';
            let currentAssignee = assigneeElement ? assigneeElement.textContent.trim() : '담당자 미지정';
            const currentDueDate = dueDateElement ? dueDateElement.textContent.trim() : '';
            
            // 현재 태스크 데이터에서 설명 및 담당자 ID 가져오기
            const currentTask = currentTasks.find(task => task.id == taskId);
            const currentDescription = currentTask ? currentTask.description || '' : '';
            
            // 담당자 ID로 실제 이름 찾기
            if (currentTask && currentTask.assignedTo) {
                const assignedMember = projectMembers.find(member => member.id == currentTask.assignedTo);
                if (assignedMember) {
                    currentAssignee = assignedMember.name;
                    console.log('Found assignee by ID:', currentAssignee);
                }
            }
            
            console.log('Current data:', {
                title: currentTitle,
                description: currentDescription,
                assignee: currentAssignee,
                dueDate: currentDueDate
            });
            
            // 편집 모달 생성
            showEditTaskModal(taskId, currentTitle, currentDescription, currentAssignee, currentDueDate);
        }

        // 작업 편집 모달 표시
        function showEditTaskModal(taskId, title, description, assignee, dueDate) {
            // 기존 모달이 있으면 제거
            const existingModal = document.getElementById('editTaskModal');
            if (existingModal) {
                existingModal.remove();
            }

            // 날짜 형식 정규화 (YYYY-MM-DD)
            let formattedDate = dueDate;
            if (dueDate && !dueDate.match(/^\d{4}-\d{2}-\d{2}$/)) {
                try {
                    const date = new Date(dueDate);
                    formattedDate = date.toISOString().split('T')[0];
                } catch (e) {
                    formattedDate = new Date().toISOString().split('T')[0];
                }
            }

            // 모달 HTML 생성
            const modalHTML = `
                <div id="editTaskModal" class="modal-overlay">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h3><i class="fas fa-edit"></i> 작업 편집</h3>
                            <button class="modal-close" onclick="closeEditTaskModal()">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                        <div class="modal-body">
                            <form id="editTaskForm">
                                <div class="form-group">
                                    <label for="editTaskTitle">작업 제목</label>
                                    <input type="text" id="editTaskTitle" value="" required>
                                </div>
                                <div class="form-group">
                                    <label for="editTaskDescription">작업 설명</label>
                                    <textarea id="editTaskDescription" rows="3" placeholder="작업에 대한 상세 설명을 입력하세요"></textarea>
                                </div>
                                <div class="form-group">
                                    <label for="editTaskAssignee">담당자</label>
                                    <select id="editTaskAssignee" required>
                                        <option value="">담당자를 선택하세요</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label for="editTaskDueDate">마감일</label>
                                    <input type="date" id="editTaskDueDate" value="" required>
                                </div>
                                <input type="hidden" id="editTaskId" value="">
                            </form>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" onclick="closeEditTaskModal()">
                                취소
                            </button>
                            <button type="button" class="btn btn-primary" id="saveTaskButton">
                                <i class="fas fa-save"></i> 저장
                            </button>
                        </div>
                    </div>
                </div>
            `;

            // 모달을 body에 추가
            document.body.insertAdjacentHTML('beforeend', modalHTML);
            
                        // 값 설정 (HTML 삽입 후)
                setTimeout(() => {
                document.getElementById('editTaskTitle').value = title;
                document.getElementById('editTaskDescription').value = description;
                document.getElementById('editTaskId').value = taskId;
                
                // 담당자 드롭다운 설정
                const assigneeSelect = document.getElementById('editTaskAssignee');
                
                // 기존 옵션들 제거 (기본 옵션 제외)
                while (assigneeSelect.children.length > 1) {
                    assigneeSelect.removeChild(assigneeSelect.lastChild);
                }
                
                // 프로젝트 팀원들을 옵션으로 추가
                projectMembers.forEach(member => {
                    const option = document.createElement('option');
                    option.value = member.name;
                    option.textContent = member.name + (member.role === 'LEADER' ? ' (팀장)' : ' (팀원)');
                    assigneeSelect.appendChild(option);
                });
                
                // 현재 담당자 선택 - 정확한 매칭 시도
                console.log('Trying to match assignee:', assignee);
                console.log('Available members:', projectMembers.map(m => m.name));
                
                if (assignee && assignee !== '담당자 미지정') {
                    // 직접 매칭 시도
                    let found = false;
                    for (let option of assigneeSelect.options) {
                        if (option.value === assignee) {
                            option.selected = true;
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        console.log('Assignee not found in dropdown, keeping default selection');
                    }
                }
                
                document.getElementById('editTaskDueDate').value = formattedDate;
                
                // 저장 버튼 이벤트 리스너 추가
                document.getElementById('saveTaskButton').addEventListener('click', function() {
                    const currentTaskId = document.getElementById('editTaskId').value;
                    saveTaskChanges(currentTaskId);
                });
                
                // 모달 표시
                document.getElementById('editTaskModal').classList.add('show');
            }, 10);
        }

        // 편집 모달 닫기
        function closeEditTaskModal() {
            const modal = document.getElementById('editTaskModal');
            if (modal) {
                            modal.classList.remove('show');
                setTimeout(() => {
                    modal.remove();
                }, 300);
            }
        }

        // 작업 변경사항 저장
        function saveTaskChanges(taskId) {
            console.log('saveTaskChanges called with taskId:', taskId);
            
            if (!taskId || taskId === 'undefined' || taskId === '') {
                console.error('Invalid taskId:', taskId);
                alert('작업 ID가 유효하지 않습니다.');
                return;
            }
            
            const title = document.getElementById('editTaskTitle').value.trim();
            const description = document.getElementById('editTaskDescription').value.trim();
            const assignee = document.getElementById('editTaskAssignee').value.trim();
            const dueDate = document.getElementById('editTaskDueDate').value;

            console.log('Form values:', { title, description, assignee, dueDate });

            if (!title || !assignee || !dueDate) {
                alert('제목, 담당자, 마감일은 필수 입력 항목입니다.');
                return;
            }

            // 담당자 이름을 ID로 변환
            let assignedToId = null;
            if (assignee && assignee !== '담당자 미지정') {
                const assignedMember = projectMembers.find(member => member.name === assignee);
                if (assignedMember) {
                    assignedToId = assignedMember.id;
                }
            }

            // 기존 작업 데이터에서 startDate 가져오기
            const currentTask = currentTasks.find(task => task.id == taskId);
            const startDate = currentTask ? currentTask.startDate : dueDate;
            
            // 서버로 전송할 데이터 준비
            const taskData = {
                title: title,
                description: description,
                assignedTo: assignedToId,
                startDate: startDate,
                dueDate: dueDate,
                status: currentTask ? currentTask.status : 'TODO',
                priority: currentTask ? currentTask.priority : 'MEDIUM',
                color: currentTask ? currentTask.color : '#3498db'
            };

            console.log('Saving task changes:', { taskId, taskData });

            // 버튼 비활성화
            const saveButton = document.querySelector('#editTaskModal .btn-primary');
            const originalText = saveButton.innerHTML;
            saveButton.disabled = true;
            saveButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 저장 중...';

            // 서버로 AJAX 요청 전송
            fetch('/projects/${projectDetail.project.id}/tasks/' + taskId, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(taskData)
            })
            .then(response => {
                console.log('Server response status:', response.status);
                return response.json();
            })
            .then(data => {
                console.log('Server response:', data);
                if (data.success) {
                    // currentTasks 배열 업데이트
                    const taskIndex = currentTasks.findIndex(task => task.id == taskId);
                    if (taskIndex !== -1) {
                        currentTasks[taskIndex] = {
                            ...currentTasks[taskIndex],
                            title: title,
                            description: description,
                            assignedTo: assignedToId,
                            assignedToUserName: assignee,
                            dueDate: dueDate
                        };
                    }
                    
                    // DOM 업데이트
                    updateTaskCardUI(taskId, title, assignee, dueDate);
                    closeEditTaskModal();
                    
                    // 성공 메시지
                    showSuccessMessage('작업이 성공적으로 수정되었습니다.');
            } else {
                    throw new Error(data.message || '저장에 실패했습니다.');
            }
        })
        .catch(error => {
                console.error('Error saving task:', error);
                alert('작업 저장 중 오류가 발생했습니다: ' + error.message);
        })
        .finally(() => {
                // 버튼 활성화
                saveButton.disabled = false;
                saveButton.innerHTML = originalText;
            });
        }

        // 작업 카드 UI 업데이트
        function updateTaskCardUI(taskId, title, assignee, dueDate) {
            const taskCard = document.querySelector('[data-task-id="' + taskId + '"]');
            if (taskCard) {
                taskCard.querySelector('.task-title').textContent = title;
                taskCard.querySelector('.task-assignee span').textContent = assignee;
                taskCard.querySelector('.task-due-date span').textContent = dueDate;
            }
        }

        // 성공 메시지 표시
        function showSuccessMessage(message) {
            const toast = document.createElement('div');
            toast.className = 'toast-message success';
            toast.innerHTML = `
                <i class="fas fa-check-circle"></i>
                <span>${message}</span>
            `;
            
            document.body.appendChild(toast);
            
            setTimeout(() => {
                toast.classList.add('show');
            }, 10);
            
            setTimeout(() => {
                toast.classList.remove('show');
                setTimeout(() => {
                    toast.remove();
                }, 300);
            }, 3000);
        }

        // 에러 메시지 표시
        function showErrorMessage(message) {
            const toast = document.createElement('div');
            toast.className = 'toast-message error';
            toast.innerHTML = `
                <i class="fas fa-exclamation-circle"></i>
                <span>${message}</span>
            `;
            
            document.body.appendChild(toast);
            
            setTimeout(() => {
                toast.classList.add('show');
            }, 10);
            
            setTimeout(() => {
                toast.classList.remove('show');
                setTimeout(() => {
                    toast.remove();
                }, 300);
            }, 4000);
        }

    // Initialize chart on page load
        document.addEventListener('DOMContentLoaded', function() {
                            console.log("DOM loaded, initializing components...");
                
                // 약간의 지연 후 초기화 (DOM 완전 로드 보장)
                setTimeout(function() {
    initGanttChart();
                    setTimeout(function() {
                        initKanbanBoard();
                        // 추가로 1초 후에 한번 더 강제 업데이트
                        setTimeout(function() {
                            console.log("=== FORCE UPDATE ASSIGNEES ===");
                            updateAssigneeNames();
                        }, 1000);
                    }, 200); // 칸반 보드는 좀 더 늦게 초기화
                }, 100);
        });

    // ========================================
    // 프로젝트 기자재 관리 JavaScript 함수들
    // ========================================

    // 기자재 추가 모달 표시
    function showAddEquipmentModal() {
        const modal = document.getElementById('addEquipmentModal');
        if (modal) {
            modal.style.display = 'block';
            // 애니메이션을 위한 작은 지연
            setTimeout(() => {
                modal.classList.add('show');
            }, 10);
        }
    }

    // 기자재 추가 모달 닫기
    function closeAddEquipmentModal() {
        const modal = document.getElementById('addEquipmentModal');
        if (modal) {
            modal.classList.remove('show');
            setTimeout(() => {
                modal.style.display = 'none';
            }, 300);
        }
    }

    // 기자재 선택 및 추가 함수 (중복 제거됨 - 아래 JSON 방식 사용)

    // 모달 외부 클릭 시 닫기
    window.onclick = function(event) {
        const modal = document.getElementById('addEquipmentModal');
        if (event.target === modal) {
            closeAddEquipmentModal();
        }
        
        // AI 채팅 기능 제거됨
    }
    
    // ========================================
    // AI 상담 기능 관련 코드 (정리됨)
</script>

<!-- AI 관련 코드 제거됨 -->

<script>
    // 프로젝트 데이터를 JavaScript 변수로 전달 (안전한 방식)
    const projectDetailJson = {
        project: {
            id: '${projectDetail.project.id}',
            title: '<c:out value="${projectDetail.project.title}" />',
            description: '<c:out value="${projectDetail.project.description}" />',
            status: '${projectDetail.project.status}',
            startDate: '${projectDetail.project.startDate}',
            endDate: '${projectDetail.project.endDate}'
        },
        memberCount: <c:out value="${fn:length(projectDetail.members)}" default="0" />,
        taskCount: <c:out value="${fn:length(projectDetail.tasks)}" default="0" />,
        equipmentCount: <c:out value="${fn:length(projectEquipments)}" default="0" />
    };
    
    console.log('프로젝트 정보 로드 완료:', projectDetailJson);
</script>

<script>
    // 모든 칸반 작업 카드에 카운트 업데이트
    updateTaskCounts();
    
    // 모달 외부 클릭 시 닫기
    window.onclick = function(event) {
        const modal = document.getElementById('addEquipmentModal');
        if (event.target === modal) {
            closeAddEquipmentModal();
        }
    }
    
    // 기자재 추가/제거 함수들
    function showAddEquipmentModal() {
        document.getElementById('addEquipmentModal').style.display = 'block';
    }
    
    function closeAddEquipmentModal() {
        document.getElementById('addEquipmentModal').style.display = 'none';
    }
    
    function selectEquipment(rentalId, equipmentId, element) {
        const equipmentName = element.querySelector('[data-equipment-name]').getAttribute('data-equipment-name');
        const renterName = element.querySelector('[data-renter-name]').getAttribute('data-renter-name');
        
        if (confirm('"' + equipmentName + '"을(를) 이 프로젝트에 추가하시겠습니까?')) {
            addEquipmentToProject(rentalId, equipmentId, equipmentName, renterName);
        }
    }
    
    function addEquipmentToProject(rentalId, equipmentId, equipmentName, renterName) {
        const purpose = prompt('"' + equipmentName + '"의 프로젝트 사용 목적을 간단히 입력해주세요:', '');
        
        if (purpose === null) return;
        
        const projectId = '${projectDetail.project.id}';
        
        fetch('${pageContext.request.contextPath}/projects/' + projectId + '/equipment/add', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                rentalId: rentalId,
                equipmentId: equipmentId,
                purpose: purpose || ''
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('기자재가 프로젝트에 추가되었습니다.');
                location.reload();
            } else {
                alert('기자재 추가 중 오류가 발생했습니다: ' + (data.message || '알 수 없는 오류'));
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('기자재 추가 중 오류가 발생했습니다.');
        });
    }
    
    function removeEquipmentFromProject(projectEquipmentId) {
        if (confirm('이 기자재를 프로젝트에서 제거하시겠습니까?')) {
            const projectId = '${projectDetail.project.id}';
            
            fetch('${pageContext.request.contextPath}/projects/' + projectId + '/equipment/' + projectEquipmentId + '/remove', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('기자재가 프로젝트에서 제거되었습니다.');
                    location.reload();
                } else {
                    alert('기자재 제거 중 오류가 발생했습니다: ' + (data.message || '알 수 없는 오류'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('기자재 제거 중 오류가 발생했습니다.');
            });
        }
    }
    
    // 페이지 로드 시 초기화
    document.addEventListener('DOMContentLoaded', function() {
        console.log('DOM 로드 완료 - schedule.jsp');
        
        // 간트 차트 초기화
        initGanttChart();
        
        // 기본 탭 표시
        const defaultTab = document.querySelector('.nav-link[data-tab="schedule"]');
        if (defaultTab) {
            defaultTab.click();
        }
        
        // 기자재 선택 이벤트 리스너 추가
        document.querySelectorAll('.available-equipment-item').forEach(item => {
            item.addEventListener('click', function() {
                const rentalId = this.getAttribute('data-rental-id');
                const equipmentId = this.getAttribute('data-equipment-id');
                selectEquipment(rentalId, equipmentId, this);
            });
        });
    });
    
    // AI 상담 관련 함수들
    function openAiChat() {
        const modal = document.getElementById('aiChatModal');
        if (modal) {
            modal.style.display = 'flex';
            // 기존 채팅 기록 불러오기
            loadChatHistory();
        } else {
            // 모달이 없으면 동적으로 생성
            createAiChatModal();
        }
    }
    
    function closeAiChat() {
        const modal = document.getElementById('aiChatModal');
        if (modal) {
            modal.style.display = 'none';
        }
    }
    
        function createAiChatModal() {
        // 프로젝트 정보를 JavaScript 변수로 가져오기
        const projectTitle = '<c:out value="${projectDetail.project.title}" />';
        const projectStatus = '<c:out value="${projectDetail.project.status}" />';
        const memberCount = '<c:out value="${fn:length(projectDetail.members)}" default="0" />';
        
        const modalHtml = 
            '<div id="aiChatModal" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); display: flex; justify-content: center; align-items: center; z-index: 10000;">' +
                '<div style="background: white; border-radius: 15px; width: 700px; max-width: 90vw; height: 600px; max-height: 85vh; display: flex; flex-direction: column; box-shadow: 0 20px 60px rgba(0,0,0,0.3);">' +
                    '<!-- 헤더 -->' +
                    '<div style="background: #3b82f6; color: white; padding: 20px; border-radius: 15px 15px 0 0; display: flex; justify-content: space-between; align-items: center;">' +
                        '<h3 style="margin: 0; font-size: 18px;"><i class="fas fa-robot"></i> AI 프로젝트 상담</h3>' +
                        '<button onclick="closeAiChat()" style="background: rgba(255,255,255,0.2); border: none; color: white; width: 35px; height: 35px; border-radius: 50%; cursor: pointer; font-size: 18px;">×</button>' +
                    '</div>' +
                    
                    '<!-- 프로젝트 정보 -->' +
                    '<div style="background: #f8f9fc; padding: 15px 20px; border-bottom: 1px solid #e2e8f0;">' +
                        '<h4 style="margin: 0 0 8px 0; color: #2d3748;"><i class="fas fa-project-diagram"></i> ' + projectTitle + '</h4>' +
                        '<div style="display: flex; gap: 15px; font-size: 14px; color: #4a5568;">' +
                            '<span><strong>상태:</strong> ' + projectStatus + '</span>' +
                            '<span><strong>팀원:</strong> ' + memberCount + '명</span>' +
                        '</div>' +
                    '</div>' +
                    
                    '<!-- 채팅 영역 -->' +
                    '<div id="aiChatMessages" style="flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 15px;">' +
                        '<div style="display: flex; gap: 10px; align-items: flex-start;">' +
                            '<div style="width: 35px; height: 35px; border-radius: 50%; background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); display: flex; align-items: center; justify-content: center; color: white; font-size: 14px;">' +
                                '<i class="fas fa-robot"></i>' +
                            '</div>' +
                            '<div style="max-width: 70%; padding: 12px 16px; border-radius: 15px; background: #f1f3f4; color: #2d3748;">' +
                                '안녕하세요! AI 프로젝트 상담사입니다! 🤖<br><br>' +
                                '<strong>' + projectTitle + '</strong> 프로젝트에 대해 도움을 드릴게요!<br><br>' +
                                '<div id="equipmentInfoSection">기자재 정보를 불러오는 중...</div><br>' +
                                '다음과 같은 질문을 해보세요:<br>' +
                                '• 📊 "현재 프로젝트 진행 상황은?"<br>' +
                                '• 🔧 "등록된 기자재들은 어떻게 활용되고 있어?"<br>' +
                                '• 💡 "다음에 할 일은 뭐야?"<br>' +
                                '• 📝 "보고서 작성해줘"' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                    
                    '<!-- 빠른 액션 버튼들 -->' +
                    '<div style="padding: 15px 20px; background: #f8f9fc; border-top: 1px solid #e2e8f0; display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">' +
                                            '<button onclick="sendQuickMessage(\'현재 프로젝트 진행 상황을 분석해줘. 팀원 구성, 작업 진행도와 함께 등록된 각 기자재의 구체적인 이름과 활용 현황을 상세히 설명해줘\')" style="background: #667eea; color: white; border: none; padding: 8px 16px; border-radius: 20px; font-size: 14px; cursor: pointer;">📊 진행 상황</button>' +
                    '<button onclick="sendQuickMessage(\'프로젝트 보고서를 작성해줘. 등록된 모든 기자재의 구체적인 이름을 명시하고 각각의 활용 현황과 성과를 포함해서 작성해줘\')" style="background: #667eea; color: white; border: none; padding: 8px 16px; border-radius: 20px; font-size: 14px; cursor: pointer;">📝 보고서 생성</button>' +
                    '<button onclick="sendQuickMessage(\'프로젝트 개선 방안을 제안해줘. 등록된 각 기자재의 구체적인 이름을 언급하면서 효율적 활용 방안을 제안해줘\')" style="background: #667eea; color: white; border: none; padding: 8px 16px; border-radius: 20px; font-size: 14px; cursor: pointer;">💡 개선 방안</button>' +
                    '</div>' +
                    
                    '<!-- 입력 영역 -->' +
                    '<div style="padding: 20px; background: white; border-top: 1px solid #e2e8f0; display: flex; gap: 10px;">' +
                        '<input type="text" id="aiChatInput" placeholder="프로젝트에 대해 질문해보세요..." style="flex: 1; border: 2px solid #e2e8f0; border-radius: 20px; padding: 12px 16px; outline: none; font-size: 14px;" onkeypress="if(event.key===\'Enter\') sendAiMessage()">' +
                        '<button onclick="sendAiMessage()" style="width: 45px; height: 45px; border-radius: 50%; border: none; background: #3b82f6; color: white; cursor: pointer;">' +
                            '<i class="fas fa-paper-plane"></i>' +
                        '</button>' +
                    '</div>' +
                '</div>' +
            '</div>';
        
        document.body.insertAdjacentHTML('beforeend', modalHtml);
        
        // 모달 생성 후 환영 메시지에 기자재 정보 추가
        updateWelcomeMessageWithEquipments();
        
        // 모달 생성 후 채팅 기록 불러오기
        loadChatHistory();
    }
    
    function sendQuickMessage(message) {
        console.log('빠른 메시지 전송:', message);
        addUserMessage(message);
        callAiApi(message);
    }
    
    function sendAiMessage() {
        const input = document.getElementById('aiChatInput');
        const message = input.value.trim();
        if (!message) return;
        
        addUserMessage(message);
        input.value = '';
        callAiApi(message);
    }
    
    function addUserMessage(message) {
        console.log('addUserMessage 호출됨:', message);
        const container = document.getElementById('aiChatMessages');
        
        if (!container) {
            console.error('aiChatMessages 컨테이너를 찾을 수 없습니다!');
            return;
        }
        
        const messageHtml = 
            '<div style="display: flex; gap: 10px; align-items: flex-start; flex-direction: row-reverse;">' +
                '<div style="width: 35px; height: 35px; border-radius: 50%; background: #3b82f6; display: flex; align-items: center; justify-content: center; color: white; font-size: 14px;">' +
                    '<i class="fas fa-user"></i>' +
                '</div>' +
                '<div style="max-width: 70%; padding: 12px 16px; border-radius: 15px; background: #3b82f6; color: white; white-space: pre-wrap; word-wrap: break-word;">' +
                    message.replace(/\n/g, '<br>') +
                '</div>' +
            '</div>';
        
        console.log('사용자 메시지 HTML 추가:', messageHtml.substring(0, 100) + '...');
        container.insertAdjacentHTML('beforeend', messageHtml);
        container.scrollTop = container.scrollHeight;
        console.log('사용자 메시지 추가 완료');
    }
    
    function addAiMessage(message, isError = false) {
        console.log('addAiMessage 호출됨:', {message: message, isError: isError});
        const container = document.getElementById('aiChatMessages');
        console.log('채팅 컨테이너:', container);
        
        if (!container) {
            console.error('aiChatMessages 컨테이너를 찾을 수 없습니다!');
            return;
        }
        
        const bgColor = isError ? '#fed7d7' : '#f1f3f4';
        const textColor = isError ? '#c53030' : '#2d3748';
        
        const messageHtml = 
            '<div style="display: flex; gap: 10px; align-items: flex-start;">' +
                '<div style="width: 35px; height: 35px; border-radius: 50%; background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); display: flex; align-items: center; justify-content: center; color: white; font-size: 14px;">' +
                    '<i class="fas fa-robot"></i>' +
                '</div>' +
                '<div style="max-width: 70%; padding: 12px 16px; border-radius: 15px; background: ' + bgColor + '; color: ' + textColor + '; white-space: pre-wrap; word-wrap: break-word;">' +
                    message.replace(/\n/g, '<br>') +
                '</div>' +
            '</div>';
        
        console.log('HTML 추가 전 컨테이너 내용:', container.innerHTML.length);
        container.insertAdjacentHTML('beforeend', messageHtml);
        console.log('HTML 추가 후 컨테이너 내용:', container.innerHTML.length);
        container.scrollTop = container.scrollHeight;
    }
    
    function callAiApi(message) {
        console.log('AI API 호출 시작:', message);
        // 로딩 메시지 표시
        addAiMessage('<i class="fas fa-spinner fa-spin"></i> AI가 답변을 생성하고 있습니다...');
        
        const projectId = projectDetailJson.project.id;
        
        // 기자재 정보를 동적으로 가져와서 컨텍스트에 추가
        getProjectEquipments().then(equipments => {
            console.log('기자재 정보 가져옴 (원본):', equipments);
            
            // 기자재 데이터 상세 로깅
            if (equipments && equipments.length > 0) {
                console.log('첫 번째 기자재 상세:', equipments[0]);
                equipments.forEach((eq, index) => {
                    console.log(`기자재 ${index + 1}:`, {
                        id: eq.id,
                        equipmentId: eq.equipmentId,
                        equipmentName: eq.equipmentName,
                        renterName: eq.renterName,
                        purpose: eq.purpose
                    });
                });
            }
            
            const processedEquipments = equipments.map(eq => ({
                name: eq.equipmentName || '알 수 없는 기자재',
                renter: eq.renterName || '대여자 정보 없음',
                purpose: eq.purpose || '사용 목적 미지정'
            }));
            
            console.log('처리된 기자재 정보:', processedEquipments);
            
            const requestData = {
                projectId: projectId,
                question: message,
                context: {
                    projectTitle: projectDetailJson.project.title,
                    projectStatus: projectDetailJson.project.status,
                    memberCount: projectDetailJson.memberCount,
                    taskCount: projectDetailJson.taskCount,
                    equipmentCount: equipments.length,
                    equipments: processedEquipments
                }
            };
            
            console.log('AI 요청 데이터 (기자재 포함):', requestData);
            console.log('컨텍스트 상세:', requestData.context);
            
            sendAiRequest(requestData);
        }).catch(error => {
            console.error('기자재 정보 가져오기 실패:', error);
            console.error('에러 상세:', error.stack);
            
            // 기자재 정보 없이 요청
            const requestData = {
                projectId: projectId,
                question: message,
                context: {
                    projectTitle: projectDetailJson.project.title,
                    projectStatus: projectDetailJson.project.status,
                    memberCount: projectDetailJson.memberCount,
                    taskCount: projectDetailJson.taskCount,
                    equipmentCount: 0,
                    equipments: []
                }
            };
            
            console.log('요청 데이터 (기자재 없음):', requestData);
            sendAiRequest(requestData);
        });
    }
    
    function sendAiRequest(requestData) {
        fetch('${pageContext.request.contextPath}/ai/project-chat-json', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: JSON.stringify(requestData)
        })
        .then(response => {
            // 로딩 메시지 제거
            const messages = document.getElementById('aiChatMessages');
            const lastMessage = messages.lastElementChild;
            if (lastMessage && lastMessage.innerHTML.includes('fa-spinner')) {
                lastMessage.remove();
            }
            
            if (!response.ok) {
                throw new Error('네트워크 응답 오류: ' + response.status);
            }
            return response.json();
        })
        .then(data => {
            console.log('AI API 응답 받음:', data);
            if (data.success) {
                console.log('AI 답변 내용:', data.answer);
                addAiMessage(data.answer);
                console.log('AI 메시지 추가 완료');
            } else {
                console.log('AI API 오류:', data.message);
                addAiMessage('죄송합니다. 답변 생성 중 오류가 발생했습니다: ' + (data.message || '알 수 없는 오류'), true);
            }
        })
        .catch(error => {
            // 로딩 메시지 제거
            const messages = document.getElementById('aiChatMessages');
            const lastMessage = messages.lastElementChild;
            if (lastMessage && lastMessage.innerHTML.includes('fa-spinner')) {
                lastMessage.remove();
            }
            
            console.error('AI API 오류:', error);
            addAiMessage('죄송합니다. 현재 AI 서비스에 일시적인 문제가 있습니다. 잠시 후 다시 시도해주세요.', true);
        });
         }
     
     // 환영 메시지에 기자재 정보 업데이트 함수
     function updateWelcomeMessageWithEquipments() {
         const equipmentSection = document.getElementById('equipmentInfoSection');
         if (equipmentSection) {
             getProjectEquipments().then(equipments => {
                 let equipmentInfo = '';
                 if (equipments && equipments.length > 0) {
                     equipmentInfo = '🔧 <strong>등록된 기자재:</strong><br>';
                     equipments.forEach((eq, index) => {
                         equipmentInfo += (index + 1) + '. <strong>' + (eq.equipmentName || '기자재') + '</strong> (대여자: ' + (eq.renterName || '정보없음') + ')<br>';
                     });
                     equipmentInfo += '<br>💡 기자재에 대해 질문할 때는 구체적인 이름을 언급해주세요!';
                 } else {
                     equipmentInfo = '현재 등록된 기자재가 없습니다.';
                 }
                 equipmentSection.innerHTML = equipmentInfo;
             }).catch(error => {
                 console.error('환영 메시지 기자재 정보 로드 실패:', error);
                 equipmentSection.innerHTML = '기자재 정보 로드 중 오류가 발생했습니다.';
             });
         }
     }
     
     // 채팅 기록 불러오기 함수
     function loadChatHistory() {
         console.log('채팅 기록 불러오기 시작');
         const projectId = projectDetailJson.project.id;
         
         fetch('${pageContext.request.contextPath}/ai/project-chat-history/' + projectId, {
             method: 'GET',
             headers: {
                 'Content-Type': 'application/json',
                 'X-Requested-With': 'XMLHttpRequest'
             }
         })
         .then(response => {
             if (!response.ok) {
                 throw new Error('채팅 기록 조회 실패: ' + response.status);
             }
             return response.json();
         })
         .then(data => {
             console.log('채팅 기록 받음:', data);
             if (data.success && data.conversations && data.conversations.length > 0) {
                 displayChatHistory(data.conversations);
             } else {
                 console.log('이전 채팅 기록이 없습니다.');
             }
         })
         .catch(error => {
             console.error('채팅 기록 조회 오류:', error);
         });
     }
     
     // 채팅 기록 표시 함수
     function displayChatHistory(conversations) {
         console.log('채팅 기록 표시:', conversations.length + '개');
         const container = document.getElementById('aiChatMessages');
         
         if (!container) {
             console.error('채팅 컨테이너를 찾을 수 없습니다.');
             return;
         }
         
         // 기존 환영 메시지 제거
         container.innerHTML = '';
         
         // 환영 메시지 다시 추가 (기자재 정보 포함)
         const projectTitle = projectDetailJson.project.title;
         
         // 기자재 정보 가져와서 환영 메시지에 포함
         getProjectEquipments().then(equipments => {
             let equipmentInfo = '';
             if (equipments && equipments.length > 0) {
                 equipmentInfo = '<br><br>🔧 <strong>등록된 기자재:</strong><br>';
                 equipments.forEach((eq, index) => {
                     equipmentInfo += (index + 1) + '. <strong>' + (eq.equipmentName || '기자재') + '</strong> (대여자: ' + (eq.renterName || '정보없음') + ')<br>';
                 });
                 equipmentInfo += '<br>기자재에 대해 궁금한 점이 있으시면 구체적인 이름을 언급해서 질문해주세요!';
             } else {
                 equipmentInfo = '<br><br>현재 등록된 기자재가 없습니다.';
             }
             
             const welcomeMessage = 
                 '<div style="display: flex; gap: 10px; align-items: flex-start;">' +
                     '<div style="width: 35px; height: 35px; border-radius: 50%; background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); display: flex; align-items: center; justify-content: center; color: white; font-size: 14px;">' +
                         '<i class="fas fa-robot"></i>' +
                     '</div>' +
                     '<div style="max-width: 70%; padding: 12px 16px; border-radius: 15px; background: #f1f3f4; color: #2d3748; white-space: pre-wrap; word-wrap: break-word;">' +
                         '안녕하세요! AI 프로젝트 상담사입니다! 🤖<br><br>' +
                         '<strong>' + projectTitle + '</strong> 프로젝트에 대해 도움을 드릴게요!' +
                         equipmentInfo + '<br><br>' +
                         '이전 대화 기록을 불러왔습니다. 계속 질문해보세요!' +
                     '</div>' +
                 '</div>';
             
             container.insertAdjacentHTML('beforeend', welcomeMessage);
         }).catch(error => {
             // 기자재 정보 없이 기본 환영 메시지
             const welcomeMessage = 
                 '<div style="display: flex; gap: 10px; align-items: flex-start;">' +
                     '<div style="width: 35px; height: 35px; border-radius: 50%; background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); display: flex; align-items: center; justify-content: center; color: white; font-size: 14px;">' +
                         '<i class="fas fa-robot"></i>' +
                     '</div>' +
                     '<div style="max-width: 70%; padding: 12px 16px; border-radius: 15px; background: #f1f3f4; color: #2d3748; white-space: pre-wrap; word-wrap: break-word;">' +
                         '안녕하세요! AI 프로젝트 상담사입니다! 🤖<br><br>' +
                         '<strong>' + projectTitle + '</strong> 프로젝트에 대해 도움을 드릴게요!<br><br>' +
                         '이전 대화 기록을 불러왔습니다. 계속 질문해보세요!' +
                     '</div>' +
                 '</div>';
             
             container.insertAdjacentHTML('beforeend', welcomeMessage);
         });
         
         // 채팅 기록 추가
         conversations.forEach(conv => {
             // 사용자 질문 추가
             if (conv.question) {
                              const userMessage = 
                 '<div style="display: flex; gap: 10px; align-items: flex-start; flex-direction: row-reverse;">' +
                     '<div style="width: 35px; height: 35px; border-radius: 50%; background: #3b82f6; display: flex; align-items: center; justify-content: center; color: white; font-size: 14px;">' +
                         '<i class="fas fa-user"></i>' +
                     '</div>' +
                     '<div style="max-width: 70%; padding: 12px 16px; border-radius: 15px; background: #3b82f6; color: white; white-space: pre-wrap; word-wrap: break-word;">' +
                         conv.question.replace(/\n/g, '<br>') +
                     '</div>' +
                 '</div>';
                 container.insertAdjacentHTML('beforeend', userMessage);
             }
             
             // AI 답변 추가
             if (conv.answer) {
                 const aiMessage = 
                     '<div style="display: flex; gap: 10px; align-items: flex-start;">' +
                         '<div style="width: 35px; height: 35px; border-radius: 50%; background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); display: flex; align-items: center; justify-content: center; color: white; font-size: 14px;">' +
                             '<i class="fas fa-robot"></i>' +
                         '</div>' +
                         '<div style="max-width: 70%; padding: 12px 16px; border-radius: 15px; background: #f1f3f4; color: #2d3748; white-space: pre-wrap; word-wrap: break-word;">' +
                             conv.answer.replace(/\n/g, '<br>') +
                         '</div>' +
                     '</div>';
                 container.insertAdjacentHTML('beforeend', aiMessage);
             }
         });
         
         // 스크롤을 맨 아래로
         container.scrollTop = container.scrollHeight;
         console.log('채팅 기록 표시 완료');
     }
     
     // 기자재 정보 가져오기 함수
     function getProjectEquipments() {
         const projectId = projectDetailJson.project.id;
         
         console.log('기자재 정보 조회 시작 - 프로젝트 ID:', projectId);
         
         return fetch('${pageContext.request.contextPath}/projects/' + projectId + '/equipment/list', {
             method: 'GET',
             headers: {
                 'Content-Type': 'application/json',
                 'X-Requested-With': 'XMLHttpRequest'
             }
         })
         .then(response => {
             console.log('기자재 API 응답 상태:', response.status);
             if (!response.ok) {
                 throw new Error('기자재 정보 조회 실패: ' + response.status);
             }
             return response.json();
         })
         .then(data => {
             console.log('기자재 API 응답 데이터 (전체):', data);
             
             if (data.success && data.equipments) {
                 console.log('기자재 목록 추출 성공:', data.equipments);
                 console.log('기자재 개수:', data.equipments.length);
                 
                 // 각 기자재 정보 상세 로깅
                 data.equipments.forEach((eq, index) => {
                     console.log(`API 응답 기자재 ${index + 1}:`, eq);
                 });
                 
                 return data.equipments;
             } else {
                 console.warn('기자재 데이터가 비어있거나 API 실패:', data);
                 return [];
             }
         })
         .catch(error => {
             console.error('기자재 정보 조회 오류:', error);
             console.error('오류 상세:', error.stack);
             return [];
         });
     }
     
     // 작업 모달 관련 함수들
     function openTaskModal() {
         const modal = document.getElementById('taskModal');
         if (modal) {
             modal.style.display = 'flex';
         }
     }
     
     function closeTaskModal() {
         const modal = document.getElementById('taskModal');
         if (modal) {
             modal.style.display = 'none';
         }
         // 폼 초기화
         document.getElementById('taskTitle').value = '';
         document.getElementById('taskDescription').value = '';
         document.getElementById('taskAssignedTo').value = '';
         document.getElementById('taskFormAlert').style.display = 'none';
     }
     
     function saveTask() {
         const alertDiv = document.getElementById('taskFormAlert');
         const projectId = document.getElementById('projectIdForTask').value;
         
         const title = document.getElementById('taskTitle').value.trim();
         const description = document.getElementById('taskDescription').value.trim();
         const startMonth = document.getElementById('taskStartMonth').value;
         const endMonth = document.getElementById('taskEndMonth').value;
         const assignedTo = document.getElementById('taskAssignedTo').value;
         
         if (!title) {
             alertDiv.className = 'alert alert-danger';
             alertDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> 제목을 입력해주세요.';
             alertDiv.style.cssText = 'padding: 12px 15px; border-radius: 8px; margin-bottom: 15px; font-size: 0.9em; display: block; background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;';
             return;
         }
         
         const projectYear = 2025;
         const startDate = projectYear + '-' + String(startMonth).padStart(2, '0') + '-01';
         const endDate = projectYear + '-' + String(endMonth).padStart(2, '0') + '-28';
         
         const requestData = {
             title: title,
             description: description,
             startDate: startDate,
             dueDate: endDate,
             status: 'TODO',
             assignedTo: assignedTo || null,
             priority: 'MEDIUM'
         };
         
         alertDiv.style.display = 'none';
         
         fetch('${pageContext.request.contextPath}/projects/' + projectId + '/tasks', {
             method: 'POST',
             headers: {
                 'Content-Type': 'application/json',
             },
             body: JSON.stringify(requestData)
         })
         .then(response => response.json())
         .then(data => {
             if (data.success) {
                 alertDiv.className = 'alert alert-success';
                 alertDiv.innerHTML = '<i class="fas fa-check-circle"></i> ' + data.message;
                 alertDiv.style.cssText = 'padding: 12px 15px; border-radius: 8px; margin-bottom: 15px; font-size: 0.9em; display: block; background: #d4edda; color: #155724; border: 1px solid #c3e6cb;';
                 
                 setTimeout(function() {
                     closeTaskModal();
                     location.reload();
                 }, 1500);
             } else {
                 alertDiv.className = 'alert alert-danger';
                 alertDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + data.message;
                 alertDiv.style.cssText = 'padding: 12px 15px; border-radius: 8px; margin-bottom: 15px; font-size: 0.9em; display: block; background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;';
             }
         })
         .catch(error => {
             console.error('요청 오류:', error);
             alertDiv.className = 'alert alert-danger';
             alertDiv.innerHTML = '<i class="fas fa-exclamation-circle"></i> 작업 추가 중 오류가 발생했습니다.';
             alertDiv.style.cssText = 'padding: 12px 15px; border-radius: 8px; margin-bottom: 15px; font-size: 0.9em; display: block; background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;';
         });
     }
 </script>

<!-- AI 상담 기능은 추후 추가 예정 -->

<!-- 작업 추가 모달 -->
<div id="taskModal" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); display: none; justify-content: center; align-items: center; z-index: 9999;">
    <div style="background: white; border-radius: 15px; width: 500px; max-width: 90vw; max-height: 85vh; overflow-y: auto; box-shadow: 0 20px 60px rgba(0,0,0,0.3);">
        <!-- 헤더 -->
        <div style="background: #3b82f6; color: white; padding: 20px 25px; text-align: center; position: relative; border-radius: 15px 15px 0 0;">
            <h5 style="margin: 0; font-size: 1.3em; font-weight: 600; display: flex; align-items: center; justify-content: center; gap: 10px;">
                <i class="fas fa-plus"></i> 작업 추가
            </h5>
            <button onclick="closeTaskModal()" style="position: absolute; right: 15px; top: 50%; transform: translateY(-50%); background: rgba(255,255,255,0.2); border: none; color: white; font-size: 1.5em; cursor: pointer; padding: 5px; border-radius: 50%;">
                <i class="fas fa-times"></i>
            </button>
        </div>
        
        <!-- 폼 영역 -->
        <div style="padding: 25px;">
            <div id="taskFormAlert" style="padding: 12px 15px; border-radius: 8px; margin-bottom: 15px; font-size: 0.9em; display: none;"></div>
            
            <div style="margin-bottom: 18px;">
                <label style="font-size: 0.9em; font-weight: 600; color: #495057; margin-bottom: 6px; display: block;">제목</label>
                <input type="text" id="taskTitle" placeholder="작업 제목을 입력하세요" style="width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 8px; font-size: 0.9em;">
            </div>
            
            <div style="margin-bottom: 18px;">
                <label style="font-size: 0.9em; font-weight: 600; color: #495057; margin-bottom: 6px; display: block;">설명</label>
                <textarea id="taskDescription" rows="3" placeholder="작업 설명을 입력하세요" style="width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 8px; font-size: 0.9em; resize: vertical;"></textarea>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 18px;">
                <div>
                    <label style="font-size: 0.9em; font-weight: 600; color: #495057; margin-bottom: 6px; display: block;">시작월</label>
                    <select id="taskStartMonth" style="width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 8px; font-size: 0.9em;">
                        <option value="1">1월</option>
                        <option value="2">2월</option>
                        <option value="3">3월</option>
                        <option value="4">4월</option>
                        <option value="5">5월</option>
                        <option value="6">6월</option>
                        <option value="7" selected>7월</option>
                        <option value="8">8월</option>
                        <option value="9">9월</option>
                        <option value="10">10월</option>
                        <option value="11">11월</option>
                        <option value="12">12월</option>
                    </select>
                </div>
                <div>
                    <label style="font-size: 0.9em; font-weight: 600; color: #495057; margin-bottom: 6px; display: block;">종료월</label>
                    <select id="taskEndMonth" style="width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 8px; font-size: 0.9em;">
                        <option value="1">1월</option>
                        <option value="2">2월</option>
                        <option value="3">3월</option>
                        <option value="4">4월</option>
                        <option value="5">5월</option>
                        <option value="6">6월</option>
                        <option value="7" selected>7월</option>
                        <option value="8">8월</option>
                        <option value="9">9월</option>
                        <option value="10">10월</option>
                        <option value="11">11월</option>
                        <option value="12">12월</option>
                    </select>
                </div>
            </div>
            
            <div style="margin-bottom: 18px;">
                <label style="font-size: 0.9em; font-weight: 600; color: #495057; margin-bottom: 6px; display: block;">담당자</label>
                <select id="taskAssignedTo" style="width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 8px; font-size: 0.9em;">
                    <option value="">-- 담당자를 선택해주세요 --</option>
                    <c:forEach items="${projectDetail.members}" var="member">
                        <option value="${member.userId}">${member.userName}</option>
                    </c:forEach>
                </select>
            </div>
            
            <input type="hidden" id="projectIdForTask" value="${projectDetail.project.id}">
        </div>
        
        <!-- 버튼 영역 -->
        <div style="background: #f8f9fa; padding: 20px 25px; display: flex; justify-content: flex-end; gap: 10px; border-radius: 0 0 15px 15px;">
            <button onclick="closeTaskModal()" style="padding: 12px 25px; border-radius: 25px; font-size: 0.9em; font-weight: 600; border: none; cursor: pointer; background: #6c757d; color: white;">
                <i class="fas fa-times"></i> 취소
            </button>
            <button onclick="saveTask()" style="padding: 12px 25px; border-radius: 25px; font-size: 0.9em; font-weight: 600; border: none; cursor: pointer; background: #3b82f6; color: white;">
                <i class="fas fa-check"></i> 저장
            </button>
        </div>
    </div>
</div>

</body>
</html>

