<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%-- 현재 사용자가 채팅방 관리자인지 확인 --%>
<c:set var="isCurrentUserAdmin" value="false" />
<c:forEach items="${participants}" var="participant">
    <c:if test="${participant.userId == user.id and participant.isAdmin}">
        <c:set var="isCurrentUserAdmin" value="true" />
    </c:if>
</c:forEach>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>${chatRoom.name} - 채팅방</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/boxicons@2.0.7/css/boxicons.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700&display=swap');
        
        /* 전체 페이지 스타일 */
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            overflow: hidden;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        }
        
        .chat-container {
            height: 100vh;
            display: flex;
            flex-direction: column;
            background: #ffffff;
            border-radius: 20px;
            overflow: visible;
            box-shadow: 0 32px 64px -12px rgba(0, 0, 0, 0.15);
            margin: 16px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            backdrop-filter: blur(20px);
        }
        
        /* 채팅 헤더 - 4this 스타일 적용 */
        .chat-header {
            padding: 24px 28px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            flex-shrink: 0;
            border-bottom: none;
            position: relative;
            overflow: visible;
        }
        
        .chat-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(255,255,255,0.1) 0%, transparent 100%);
            pointer-events: none;
        }
        
        .user-profile {
            display: flex;
            align-items: center;
            position: relative;
            z-index: 2;
        }
        
        .user-avatar {
            width: 52px;
            height: 52px;
            border-radius: 16px;
            background: rgba(255, 255, 255, 0.25);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            margin-right: 18px;
            font-size: 20px;
            backdrop-filter: blur(10px);
            border: 2px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }
        
        .user-info h5 {
            margin: 0;
            font-size: 22px;
            font-weight: 700;
            color: white;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .user-status {
            font-size: 14px;
            color: rgba(255, 255, 255, 0.85);
            margin: 6px 0 0 0;
            font-weight: 500;
            display: flex;
            align-items: center;
        }
        
        .user-status::before {
            content: '';
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #10b981;
            margin-right: 8px;
            box-shadow: 0 0 0 2px rgba(16, 185, 129, 0.3);
        }
        
        .chat-actions {
            display: flex;
            gap: 8px;
            position: relative;
            z-index: 2;
            align-items: center;
            justify-content: flex-end;
        }
        
        .nav-btn {
            background: rgba(255, 255, 255, 0.15);
            border: none;
            padding: 12px 14px;
            color: white;
            border-radius: 10px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            font-size: 16px;
            cursor: pointer;
            min-width: 44px;
            min-height: 44px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .nav-btn:hover {
            background: rgba(255, 255, 255, 0.25);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        }
        
        .nav-btn:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.3);
        }
        
        /* 채팅 메시지 영역 */
        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 28px;
            background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
            min-height: 0;
            position: relative;
        }
        
        .chat-messages::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(0,0,0,0.1), transparent);
        }
        
        /* 날짜 구분선 */
        .chat-day-title {
            text-align: center;
            margin: 36px 0;
            position: relative;
        }
        
        .chat-day-title::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, #e2e8f0, transparent);
        }
        
        .chat-day-title .title {
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            padding: 10px 18px;
            border-radius: 25px;
            font-size: 13px;
            color: #64748b;
            font-weight: 600;
            display: inline-block;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            border: 1px solid rgba(226, 232, 240, 0.8);
            position: relative;
            z-index: 1;
        }
        
        /* 메시지 스타일 */
        .message {
            margin-bottom: 24px;
            animation: fadeInUp 0.3s ease-out;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .conversation-list {
            margin-bottom: 18px;
        }
        
        .ctext-wrap {
            display: flex;
            align-items: flex-start;
            gap: 14px;
            max-width: 85%;
        }
        
        .ctext-wrap-content {
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            padding: 18px 22px;
            border-radius: 20px 20px 20px 6px;
            position: relative;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
            border: 1px solid rgba(226, 232, 240, 0.6);
            min-width: 200px;
            backdrop-filter: blur(10px);
        }
        
        .ctext-wrap-content::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, rgba(255,255,255,0.5) 0%, transparent 100%);
            border-radius: 20px 20px 20px 6px;
            pointer-events: none;
        }
        
        .conversation-name {
            font-size: 14px;
            margin-bottom: 10px;
            font-weight: 600;
            display: flex;
            align-items: center;
            position: relative;
            z-index: 1;
        }
        
        .user-name {
            color: #1e293b;
            text-decoration: none;
            font-weight: 700;
        }
        
        .time {
            font-size: 11px;
            color: #64748b;
            margin-left: 10px;
            font-weight: 500;
            background: rgba(100, 116, 139, 0.1);
            padding: 5px 10px;
            border-radius: 12px;
            backdrop-filter: blur(5px);
        }
        
        .message-content {
            margin: 0;
            line-height: 1.6;
            word-wrap: break-word;
            font-size: 15px;
            color: #334155;
            position: relative;
            z-index: 1;
        }
        
        /* 내가 보낸 메시지 (오른쪽 정렬) */
        .message.right {
            display: flex;
            justify-content: flex-end;
        }
        
        .message.right .ctext-wrap {
            flex-direction: row-reverse;
        }
        
        .message.right .ctext-wrap-content {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 20px 20px 6px 20px;
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.25);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .message.right .ctext-wrap-content::before {
            background: linear-gradient(135deg, rgba(255,255,255,0.2) 0%, transparent 100%);
            border-radius: 20px 20px 6px 20px;
        }
        
        .message.right .user-name {
            color: white;
        }
        
        .message.right .conversation-name {
            text-align: right;
        }
        
        .message.right .time {
            color: rgba(255, 255, 255, 0.8);
            background: rgba(255, 255, 255, 0.15);
        }
        
        .message.right .message-content {
            color: white;
        }
        
        /* 파일 첨부 스타일 */
        .file-attachments {
            margin-top: 14px;
        }
        
        .file-attachment {
            background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%);
            padding: 14px 18px;
            border-radius: 16px;
            margin: 10px 0;
            display: flex;
            align-items: center;
            font-size: 14px;
            border: 1px solid rgba(226, 232, 240, 0.8);
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }
        
        .file-attachment:hover {
            background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }
        
        .message.right .file-attachment {
            background: linear-gradient(135deg, rgba(255,255,255,0.2) 0%, rgba(255,255,255,0.1) 100%);
            border: 1px solid rgba(255, 255, 255, 0.3);
            color: white;
        }
        
        .message.right .file-attachment:hover {
            background: linear-gradient(135deg, rgba(255,255,255,0.3) 0%, rgba(255,255,255,0.2) 100%);
        }
        
        .file-attachment i {
            color: #667eea;
            margin-right: 14px;
            font-size: 18px;
        }
        
        .message.right .file-attachment i {
            color: white;
        }
        
        .file-attachment .download-btn {
            margin-left: auto;
            padding: 8px 16px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            border: none;
            border-radius: 12px;
            text-decoration: none;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }
        
        .file-attachment .download-btn:hover {
            background: linear-gradient(135deg, #059669 0%, #047857 100%);
            color: white;
            text-decoration: none;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.4);
        }
        
        /* 메시지 입력 영역 */
        .chat-input-section {
            padding: 24px 28px;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            flex-shrink: 0;
            border-top: 1px solid rgba(226, 232, 240, 0.8);
            backdrop-filter: blur(20px);
        }
        
        .chat-input {
            border: 2px solid #e2e8f0;
            border-radius: 16px;
            padding: 16px 20px;
            font-size: 15px;
            transition: all 0.3s ease;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }
        
        .chat-input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.15);
            background: #ffffff;
            outline: none;
        }
        
        .chat-send {
            padding: 16px 28px;
            border-radius: 16px;
            font-weight: 600;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            color: white;
            transition: all 0.3s ease;
            font-size: 15px;
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
        }
        
        .chat-send:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(102, 126, 234, 0.4);
            background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
        }
        
        /* 파일 첨부 버튼 */
        .btn-outline-secondary {
            border: 2px solid #e2e8f0;
            color: #64748b;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border-radius: 16px;
            padding: 16px 18px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }
        
        .btn-outline-secondary:hover {
            background: linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%);
            border-color: #cbd5e1;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }
        
        /* 참여자 사이드바 */
        .participants-sidebar {
            width: 300px;
            border-left: 1px solid rgba(226, 232, 240, 0.8);
            background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
            flex-shrink: 0;
            backdrop-filter: blur(20px);
            display: flex;
            flex-direction: column;
        }
        
        .participants-header {
            padding: 24px 20px;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border-bottom: 1px solid rgba(226, 232, 240, 0.8);
            backdrop-filter: blur(20px);
            flex-shrink: 0;
            position: relative;
        }
        
        .participants-header .d-flex {
            align-items: center;
            justify-content: space-between;
            gap: 12px;
        }
        
        .participants-header h6 {
            font-weight: 700;
            color: #1e293b;
            margin: 0;
            font-size: 16px;
        }
        
        .participants-header small {
            color: #64748b;
            font-size: 12px;
            margin-top: 2px;
            display: block;
        }
        
        .participants-list {
            padding: 16px;
            flex: 1;
            overflow-y: auto;
            min-height: 0;
        }
        
        .participant-item {
            padding: 18px;
            border-radius: 16px;
            margin-bottom: 12px;
            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
            border: 1px solid rgba(226, 232, 240, 0.6);
            display: flex;
            align-items: center;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }
        
        .participant-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        }
        
        .participant-avatar {
            width: 44px;
            height: 44px;
            border-radius: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            margin-right: 16px;
            font-size: 18px;
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.25);
        }
        
        .participant-info {
            flex: 1;
            min-width: 0;
        }
        
        .participant-name {
            font-size: 15px;
            font-weight: 600;
            margin: 0;
            color: #1e293b;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .participant-status {
            font-size: 12px;
            color: #64748b;
            margin: 4px 0 0 0;
        }
        
        /* 드롭다운 메뉴 */
        .dropdown-menu {
            z-index: 9999 !important;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
            border: 1px solid #e5e7eb;
            border-radius: 10px;
            padding: 6px;
            min-width: 180px;
            background: white;
            position: fixed;
            display: none;
            opacity: 0;
            transform: translateY(-5px);
            transition: all 0.2s ease;
            pointer-events: none;
        }
        
        .dropdown-menu.show {
            display: block !important;
            opacity: 1;
            transform: translateY(0);
            pointer-events: auto;
        }
        
        /* 드롭다운 애니메이션 */
        .dropdown-menu {
            will-change: transform, opacity;
        }
        
        .dropdown {
            position: relative;
            display: inline-block;
            z-index: 9999;
        }
        
        .dropdown-toggle {
            position: relative;
            z-index: 1000;
            background: rgba(255, 255, 255, 0.15);
            border: none;
            padding: 12px 14px;
            color: white;
            border-radius: 10px;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            font-size: 16px;
            cursor: pointer;
            min-width: 44px;
            min-height: 44px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .dropdown-toggle:hover {
            background: rgba(255, 255, 255, 0.25);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        }
        
        .dropdown-toggle:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.3);
        }
        
        .dropdown-toggle::after {
            display: none;
        }
        
        .dropdown-item {
            border-radius: 6px;
            padding: 8px 12px;
            transition: all 0.2s ease;
            color: #374151;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 2px;
        }
        
        .dropdown-item:hover {
            background: linear-gradient(135deg, #f3f4f6 0%, #e5e7eb 100%);
            color: #1f2937;
            text-decoration: none;
            transform: translateX(4px);
        }
        
        .dropdown-item:focus {
            background: linear-gradient(135deg, #f3f4f6 0%, #e5e7eb 100%);
            color: #1f2937;
            outline: none;
        }
        
        .dropdown-item:active {
            background: linear-gradient(135deg, #e5e7eb 0%, #d1d5db 100%);
            transform: translateX(2px);
        }
        
        .dropdown-item i {
            width: 16px;
            text-align: center;
            font-size: 14px;
        }
        
        .dropdown-item.danger {
            color: #dc2626;
        }
        
        .dropdown-item.danger:hover {
            background: linear-gradient(135deg, #fef2f2 0%, #fee2e2 100%);
            color: #b91c1c;
        }
        
        /* 읽음 상태 표시 */
        .read-status {
            font-size: 11px;
            color: #9ca3af;
            margin-top: 6px;
            text-align: right;
            padding: 4px 8px;
            border-radius: 12px;
            background: #f3f4f6;
            display: inline-block;
            min-width: 60px;
            font-weight: 500;
        }
        
        .read-status.read {
            color: #10b981;
            background: #ecfdf5;
        }
        
        .message.right .read-status {
            background: #f3f4f6;
            color: #9ca3af;
        }
        
        .message.right .read-status.read {
            background: #ecfdf5;
            color: #10b981;
        }
        
        /* 검색 바 스타일 */
        .search-bar {
            padding: 16px 24px;
            background: #f8fafc;
            flex-shrink: 0;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .search-input-group {
            display: flex;
            align-items: center;
            background: white;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            padding: 12px 16px;
        }
        
        .search-input {
            flex: 1;
            border: none;
            outline: none;
            font-size: 14px;
            padding: 4px 0;
        }
        
        .search-controls {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-left: 12px;
        }
        
        .search-results-count {
            font-size: 12px;
            color: #6b7280;
            white-space: nowrap;
            font-weight: 500;
        }
        
        .search-nav-btn, .search-close-btn {
            background: #f3f4f6;
            border: none;
            padding: 8px;
            color: #6b7280;
            border-radius: 8px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            transition: all 0.2s ease;
        }
        
        .search-nav-btn:hover, .search-close-btn:hover {
            background: #e5e7eb;
            color: #374151;
            transform: translateY(-1px);
        }
        
        .search-nav-btn:disabled {
            opacity: 0.4;
            cursor: not-allowed;
        }
        
        .search-nav-btn:disabled:hover {
            background: #f3f4f6;
            color: #6b7280;
            transform: none;
        }
        
        /* 검색 하이라이트 스타일 */
        .search-highlight {
            background: #fef3c7;
            padding: 2px 4px;
            border-radius: 4px;
            font-weight: 600;
        }
        
        .search-highlight.current {
            background: #f59e0b;
            color: white;
        }
        
        .message.search-result {
            border-left: 4px solid #6366f1;
            background: rgba(99, 102, 241, 0.05);
        }
        
        .message.search-result.current-result {
            border-left: 4px solid #f59e0b;
            background: rgba(245, 158, 11, 0.1);
        }
        
        /* 상태 배지 스타일 */
        .badge {
            border-radius: 8px;
            font-weight: 600;
            font-size: 11px;
            padding: 4px 8px;
        }
        
        .badge.bg-warning {
            background: #f59e0b !important;
        }
        
        .badge.bg-secondary {
            background: #6b7280 !important;
        }
        
        /* 뒤로가기 버튼 스타일 */
        .btn-secondary {
            background: #6b7280;
            border: none;
            border-radius: 10px;
            padding: 10px 16px;
            font-weight: 500;
            transition: all 0.2s ease;
        }
        
        .btn-secondary:hover {
            background: #4b5563;
            transform: translateY(-1px);
        }
        
        /* 파일 프리뷰 스타일 */
        .file-preview-item {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 12px;
            margin-bottom: 8px;
        }
        
        /* 스크롤바 스타일 */
        .chat-messages::-webkit-scrollbar,
        .participants-list::-webkit-scrollbar {
            width: 6px;
        }
        
        .chat-messages::-webkit-scrollbar-track,
        .participants-list::-webkit-scrollbar-track {
            background: #f1f5f9;
            border-radius: 3px;
        }
        
        .chat-messages::-webkit-scrollbar-thumb,
        .participants-list::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 3px;
        }
        
        .chat-messages::-webkit-scrollbar-thumb:hover,
        .participants-list::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
        }
        
        /* 반응형 */
        @media (max-width: 768px) {
            .participants-sidebar {
                display: none;
            }
            
            .chat-container {
                margin: 8px;
                border-radius: 12px;
            }
            
            .chat-header {
                padding: 16px 20px;
            }
            
            .chat-header .row {
                align-items: center;
            }
            
            .chat-header .col-8 {
                flex: 1;
                max-width: none;
            }
            
            .chat-header .col-4 {
                flex: 0 0 auto;
                max-width: none;
                width: auto;
            }
            
            .user-profile {
                flex-wrap: wrap;
                gap: 8px;
            }
            
            .user-avatar {
                width: 44px;
                height: 44px;
                margin-right: 12px;
                font-size: 18px;
            }
            
            .user-info h5 {
                font-size: 18px;
                margin: 0;
            }
            
            .user-status {
                font-size: 13px;
                margin: 2px 0 0 0;
            }
            
            .chat-actions {
                gap: 8px;
                flex-shrink: 0;
            }
            
            .nav-btn {
                padding: 12px 12px;
                min-width: 44px;
                min-height: 44px;
                font-size: 14px;
            }
            
            .dropdown-menu {
                min-width: 180px;
                margin-top: 4px;
                right: 0;
                left: auto;
            }
            
            .chat-messages {
                padding: 16px;
            }
            
            .chat-input-section {
                padding: 16px 20px;
            }
        }
        
        @media (max-width: 576px) {
            .chat-header {
                padding: 12px 16px;
            }
            
            .user-avatar {
                width: 40px;
                height: 40px;
                margin-right: 8px;
                font-size: 16px;
            }
            
            .user-info h5 {
                font-size: 16px;
            }
            
            .user-status {
                font-size: 12px;
            }
            
            .chat-actions {
                gap: 6px;
            }
            
            .nav-btn {
                padding: 10px 10px;
                min-width: 40px;
                min-height: 40px;
                font-size: 14px;
            }
            
            .dropdown-menu {
                min-width: 160px;
                font-size: 14px;
            }
            
            .dropdown-item {
                padding: 8px 10px;
            }
        }
        
        /* 애니메이션 */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .message {
            animation: fadeIn 0.3s ease-out;
        }
        
        /* 상태 드롭다운 스타일 */
        .status-dropdown {
            position: relative;
            display: inline-block;
        }
        
        .status-dropdown .dropdown-toggle {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            font-size: 13px;
            padding: 10px 14px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 6px;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
            min-width: 80px;
            justify-content: center;
        }
        
        .status-dropdown .dropdown-toggle:hover {
            background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }
        
        .status-dropdown .dropdown-toggle:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.3);
        }
        
        .status-dropdown .dropdown-toggle::after {
            display: none;
        }
        
        .status-dropdown .dropdown-menu {
            position: absolute;
            bottom: 100%;
            right: 0;
            left: auto;
            z-index: 1070 !important;
            min-width: 200px;
            margin-bottom: 8px;
            background: white;
            border: 1px solid rgba(226, 232, 240, 0.8);
            border-radius: 12px;
            box-shadow: 0 -20px 25px -5px rgba(0, 0, 0, 0.1), 0 -10px 10px -5px rgba(0, 0, 0, 0.04);
            padding: 8px;
            max-height: 300px;
            overflow-y: auto;
        }
        
        .status-dropdown .dropdown-menu.show {
            display: block;
        }
        
        .status-dropdown .dropdown-header {
            padding: 8px 12px;
            font-size: 12px;
            font-weight: 600;
            color: #6b7280;
            text-transform: uppercase;
            border-bottom: 1px solid #e5e7eb;
            margin-bottom: 4px;
        }
        
        .status-dropdown .dropdown-item {
            padding: 10px 12px;
            border-radius: 8px;
            transition: all 0.2s ease;
            color: #374151;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 2px;
            font-size: 14px;
        }
        
        .status-dropdown .dropdown-item:hover {
            background: #f3f4f6;
            color: #374151;
            text-decoration: none;
            transform: translateX(2px);
        }
        
        .status-dropdown .dropdown-item:focus {
            background: #f3f4f6;
            color: #374151;
            outline: none;
        }
        
        .status-dropdown .dropdown-item i {
            width: 16px;
            text-align: center;
            font-size: 12px;
        }
        
        /* 상태 변경 모달 스타일 */
        .status-modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(8px);
            z-index: 9999;
            display: none;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transition: opacity 0.3s ease;
        }
        
        .status-modal-overlay.show {
            display: flex;
            opacity: 1;
        }
        
        .status-modal {
            background: white;
            border-radius: 20px;
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
            min-width: 300px;
            max-width: 400px;
            width: 90%;
            max-height: 80vh;
            overflow-y: auto;
            transform: scale(0.9);
            transition: transform 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .status-modal-overlay.show .status-modal {
            transform: scale(1);
        }
        
        .status-modal-header {
            padding: 24px 24px 16px;
            border-bottom: 1px solid #e5e7eb;
            background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
            border-radius: 20px 20px 0 0;
        }
        
        .status-modal-header h3 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
            color: #1e293b;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .status-modal-header p {
            margin: 8px 0 0;
            color: #64748b;
            font-size: 14px;
        }
        
        .status-modal-body {
            padding: 20px 24px;
        }
        
        .status-option {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 16px 20px;
            margin-bottom: 12px;
            border-radius: 16px;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 2px solid transparent;
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
        }
        
        .status-option:hover {
            background: linear-gradient(135deg, #e2e8f0 0%, #cbd5e1 100%);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
            border-color: #cbd5e1;
        }
        
        .status-option:active {
            transform: translateY(0);
        }
        
        .status-option-icon {
            width: 40px;
            height: 40px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }
        
        .status-option-icon.online {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
        }
        
        .status-option-icon.away {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
        }
        
        .status-option-icon.busy {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
            color: white;
        }
        
        .status-option-icon.offline {
            background: linear-gradient(135deg, #6b7280 0%, #4b5563 100%);
            color: white;
        }
        
        .status-option-content {
            flex: 1;
            min-width: 0;
        }
        
        .status-option-title {
            font-weight: 600;
            color: #1e293b;
            font-size: 16px;
            margin-bottom: 4px;
        }
        
        .status-option-desc {
            color: #64748b;
            font-size: 13px;
            line-height: 1.4;
        }
        
        .status-modal-footer {
            padding: 16px 24px 24px;
            border-top: 1px solid #e5e7eb;
            background: #f8fafc;
            border-radius: 0 0 20px 20px;
            display: flex;
            justify-content: flex-end;
            gap: 12px;
        }
        
        .status-modal-close {
            background: #6b7280;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .status-modal-close:hover {
            background: #4b5563;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(107, 114, 128, 0.3);
        }
        
        /* 상태 버튼 스타일 업데이트 */
        .status-dropdown {
            position: relative;
            display: inline-block;
        }
        
        .status-dropdown .status-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white;
            font-size: 13px;
            padding: 10px 14px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 6px;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
            min-width: 80px;
            justify-content: center;
        }
        
        .status-dropdown .status-btn:hover {
            background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }
        
        .status-dropdown .status-btn:focus {
            outline: none;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.3);
        }
        
        /* 기존 드롭다운 스타일 제거 */
        .status-dropdown .dropdown-menu {
            display: none !important;
        }
    </style>
</head>
<body>
    <div class="d-flex" style="height: 100vh; overflow: hidden;">
        <!-- 메인 채팅 영역 -->
        <div class="flex-grow-1">
            <div class="chat-container">
                <!-- 채팅 헤더 -->
                <div class="chat-header">
                    <div class="row align-items-center">
                        <div class="col-8">
                            <div class="user-profile">
                                <div class="user-avatar">
                                    ${chatRoom.name.substring(0,1)}
                                </div>
                                <div class="user-info">
                                    <h5>${chatRoom.name}</h5>
                                    <p class="user-status">온라인</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-4">
                            <div class="chat-actions justify-content-end d-flex">
                                <button class="nav-btn" type="button" onclick="toggleSearch()">
                                    <i class="bx bx-search"></i>
                                </button>
                                <div class="dropdown">
                                    <button class="nav-btn dropdown-toggle" type="button">
                                        <i class="bx bx-dots-horizontal-rounded"></i>
                                    </button>
                                    <div class="dropdown-menu dropdown-menu-end">
                                        <c:if test="${isCurrentUserAdmin}">
                                            <a class="dropdown-item" href="/chat/room/${chatRoom.roomId}/settings">
                                                <i class="fas fa-cog"></i> 채팅방 설정
                                            </a>
                                        </c:if>
                                        <a class="dropdown-item" href="/chat/notifications/settings" onclick="console.log('알림 설정 클릭됨');">
                                            <i class="fas fa-bell"></i> 알림 설정
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- 검색 바 (숨김/표시) -->
                <div class="search-bar" id="searchBar" style="display: none;">
                    <div class="search-container">
                        <div class="search-input-group">
                            <input type="text" id="messageSearchInput" class="search-input" 
                                   placeholder="메시지 검색..." autocomplete="off">
                            <div class="search-controls">
                                <span class="search-results-count" id="searchResultsCount"></span>
                                <button type="button" class="search-nav-btn" id="searchPrevBtn" onclick="goToPreviousResult()" disabled>
                                    <i class="fas fa-chevron-up"></i>
                                </button>
                                <button type="button" class="search-nav-btn" id="searchNextBtn" onclick="goToNextResult()" disabled>
                                    <i class="fas fa-chevron-down"></i>
                                </button>
                                <button type="button" class="search-close-btn" onclick="closeSearch()">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- 채팅 메시지 영역 -->
                <div class="chat-messages" id="chatMessages">
                    <div class="chat-day-title">
                        <span class="title">오늘</span>
                    </div>
                    
                    <c:forEach items="${messages}" var="message" varStatus="status">
                        <div class="message ${message.userId == user.id ? 'right' : ''}" data-message-id="${message.id}">
                            <div class="conversation-list">
                                <div class="ctext-wrap">
                                    <div class="ctext-wrap-content">
                                        <!-- 상대방 메시지인 경우에만 이름 표시 -->
                                        <c:if test="${message.userId != user.id}">
                                            <h5 class="conversation-name">
                                                <a href="javascript:void(0)" class="user-name">
                                                    <c:choose>
                                                        <c:when test="${not empty message.senderName}">
                                                            ${message.senderName}
                                                        </c:when>
                                                        <c:otherwise>
                                                            사용자${message.userId}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </a>
                                                <span class="time">${message.createdAt}</span>
                                            </h5>
                                        </c:if>
                                        
                                        <c:if test="${message.userId == user.id}">
                                            <h5 class="conversation-name">
                                                <a href="javascript:void(0)" class="user-name">나</a>
                                                <span class="time">${message.createdAt}</span>
                                            </h5>
                                        </c:if>
                                        
                                        <p class="message-content">${message.content}</p>
                                        
                                        <!-- 파일 첨부가 있는 경우 표시 -->
                                        <c:if test="${not empty message.files}">
                                            <div class="file-attachments">
                                                <c:forEach items="${message.files}" var="file" varStatus="fileStatus">
                                                    <div class="file-attachment">
                                                        <i class="fas fa-file"></i>
                                                        <span>${file.originalFileName}</span>
                                                        <small class="file-size" data-size="${file.fileSize}">
                                                            (<c:choose>
                                                                <c:when test="${file.fileSize > 1024*1024}">
                                                                    ${Math.round(file.fileSize / (1024*1024) * 100) / 100} MB
                                                                </c:when>
                                                                <c:when test="${file.fileSize > 1024}">
                                                                    ${Math.round(file.fileSize / 1024 * 100) / 100} KB
                                                                </c:when>
                                                                <c:otherwise>
                                                                    ${file.fileSize} bytes
                                                                </c:otherwise>
                                                            </c:choose>)
                                                        </small>
                                                        <!-- 다운로드 버튼 -->
                                                        <c:choose>
                                                            <c:when test="${not empty file.id and file.id > 0}">
                                                                <a href="/chat/download/${file.id}" 
                                                                   class="download-btn"
                                                                   download="${file.originalFileName}">
                                                                    📥 다운로드
                                                                </a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <button onclick="alert('파일 ID가 없습니다. 파일ID: ${file.id}')" 
                                                                        class="download-btn" style="background: #dc3545;">
                                                                    ❌ ID 없음
                                                                </button>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:if>
                                        
                                        <!-- 자신이 보낸 메시지에만 읽음 상태 표시 -->
                                        <c:if test="${message.userId == user.id}">
                                            <div class="read-status" id="read-status-${message.id}">전송됨</div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                
                <!-- 메시지 입력 영역 -->
                <div class="chat-input-section">
                    <div class="row g-0">
                        <div class="col">
                            <div class="position-relative">
                                <input type="text" id="messageInput" class="form-control chat-input" placeholder="메시지를 입력하세요..." />
                                <input type="file" id="fileInput" class="d-none" multiple onchange="handleFileSelect(event)">
                            </div>
                        </div>
                        <div class="col-auto">
                            <button class="btn btn-outline-secondary me-2" onclick="document.getElementById('fileInput').click()">
                                📎
                            </button>
                            <button type="button" class="btn btn-primary chat-send" onclick="sendMessage()">
                                <span class="d-none d-sm-inline-block me-2">Send</span>
                                <i class="mdi mdi-send"></i>
                            </button>
                        </div>
                    </div>
                    <div id="filePreview" class="mt-2"></div>
                    <div class="mt-3">
                        <button class="btn btn-secondary btn-sm" onclick="goBackToList()">채팅방 목록으로 돌아가기</button>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- 참여자 목록 사이드바 -->
        <div class="participants-sidebar">
            <div class="participants-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h6><i class="fas fa-users"></i> 참여자 목록</h6>
                        <small class="text-muted">${participants.size()}명</small>
                    </div>
                    <!-- 상태 드롭다운 버튼을 처음부터 표시 -->
                    <div class="status-dropdown" style="display: inline-block;">
                        <button class="btn btn-sm status-btn" type="button" id="statusBtn" title="내 상태 변경">
                            <i class="fas fa-user-circle"></i> 상태
                        </button>
                    </div>
                </div>
            </div>
            <div class="participants-list" id="participantsContainer">
                <!-- JavaScript가 동적으로 참여자 목록을 생성합니다 -->
                <div class="text-center p-4 text-muted">
                    <i class="fas fa-spinner fa-spin fa-2x mb-2"></i>
                    <p>참여자 목록을 불러오는 중...</p>
                </div>
            </div>
        </div>
    </div>

    <!-- 상태 변경 모달 -->
    <div class="status-modal-overlay" id="statusModal">
        <div class="status-modal">
            <div class="status-modal-header">
                <h3>
                    <i class="fas fa-user-circle"></i>
                    상태 변경
                </h3>
                <p>현재 상태를 선택해주세요</p>
            </div>
            <div class="status-modal-body">
                <div class="status-option" onclick="selectStatus('ONLINE', '온라인')">
                    <div class="status-option-icon online">
                        <i class="fas fa-circle"></i>
                    </div>
                    <div class="status-option-content">
                        <div class="status-option-title">온라인</div>
                        <div class="status-option-desc">활성 상태로 표시됩니다</div>
                    </div>
                </div>
                <div class="status-option" onclick="selectStatus('AWAY', '자리비움')">
                    <div class="status-option-icon away">
                        <i class="fas fa-moon"></i>
                    </div>
                    <div class="status-option-content">
                        <div class="status-option-title">자리비움</div>
                        <div class="status-option-desc">잠시 자리를 비웠습니다</div>
                    </div>
                </div>
                <div class="status-option" onclick="selectStatus('BUSY', '바쁨')">
                    <div class="status-option-icon busy">
                        <i class="fas fa-minus-circle"></i>
                    </div>
                    <div class="status-option-content">
                        <div class="status-option-title">바쁨</div>
                        <div class="status-option-desc">방해받고 싶지 않습니다</div>
                    </div>
                </div>
                <div class="status-option" onclick="selectStatus('OFFLINE', '오프라인')">
                    <div class="status-option-icon offline">
                        <i class="fas fa-circle"></i>
                    </div>
                    <div class="status-option-content">
                        <div class="status-option-title">오프라인</div>
                        <div class="status-option-desc">비활성 상태로 표시됩니다</div>
                    </div>
                </div>
            </div>
            <div class="status-modal-footer">
                <button class="status-modal-close" onclick="closeStatusModal()">취소</button>
            </div>
        </div>
    </div>

    <script>
        let stompClient = null;
        let isFileUploading = false;
        const roomId = "${chatRoom.roomId}";
        const userId = "${user.id}";
        const userName = "${user.name}";
        const userStudentId = "${user.studentProfile != null ? user.studentProfile.studentId : user.username}";
        const senderId = userId;
        const pageLoadTime = new Date().getTime();

        console.log('채팅방 정보:', {
            roomId: roomId,
            userId: userId,
            userName: userName,
            roomName: "${chatRoom.name}"
        });

        function connect() {
            const socket = new SockJS('/ws');
            stompClient = Stomp.over(socket);
            stompClient.debug = null;
            
            stompClient.connect({}, 
                function(frame) {
                    console.log('Connected: ' + frame);
          
                    stompClient.subscribe('/topic/chat/' + roomId, function(message) {
                        showMessage(JSON.parse(message.body));
                    });
                    
                    stompClient.subscribe('/topic/user-status', function(message) {
                        console.log('사용자 상태 변경:', message.body);
                        const currentTime = new Date().getTime();
                        if (currentTime - pageLoadTime > 3000) {
                            refreshEnhancedParticipantsList();
                        }
                    });
                    
                    startHeartbeat();
                    updateUserStatus('ONLINE', '');
                },
                function(error) {
                    console.error('Connection error:', error);
                    setTimeout(connect, 5000);
                }
            );
        }

        function sendMessage() {
            const messageInput = document.getElementById('messageInput');
            const content = messageInput.value.trim();
            
            if (isFileUploading) {
                console.log('파일 업로드 중이므로 메시지 전송 차단');
                return;
            }
            
            if ((content || selectedFiles.length > 0) && stompClient) {
                if (selectedFiles.length > 0) {
                    isFileUploading = true;
                    console.log('파일 업로드 시작 - WebSocket 메시지 차단');
                    
                    uploadFiles().then(uploadedFiles => {
                        console.log('=== 파일 업로드 성공 ===');
                        console.log('업로드된 파일 수:', uploadedFiles.length);
                        
                        alert('파일이 성공적으로 업로드되었습니다!');
                        window.location.reload();
                        
                    }).catch(error => {
                        console.error('파일 업로드 실패:', error);
                        alert('파일 업로드에 실패했습니다.');
                        isFileUploading = false;
                    });
                } else {
                    if (content.trim()) {
                        const message = {
                            roomId: roomId,
                            senderId: senderId,
                            content: content,
                            messageType: 'TEXT',
                            sendTime: new Date().toISOString().replace('T', ' ').replace('Z', '').substring(0, 19),
                            files: []
                        };
                        
                        stompClient.send('/app/chat.sendMessage', {}, JSON.stringify(message));
                        document.getElementById('messageInput').value = '';
                    }
                }
            }
        }

        function showMessage(message) {
            console.log('=== showMessage 디버깅 ===');
            console.log('받은 message 객체:', JSON.stringify(message, null, 2));
            
            const chatMessages = document.getElementById('chatMessages');
            const messageDiv = document.createElement('div');
            messageDiv.className = 'message ' + (message.senderId == senderId ? 'right' : '');
            
            const safeContent = (message.content && String(message.content).trim() !== '' && String(message.content) !== 'null' && String(message.content) !== 'undefined') 
                ? String(message.content) : '[메시지 내용 없음]';
            
            let safeSenderName;
            if (message.senderId == senderId) {
                safeSenderName = userName + '/' + userStudentId;
            } else {
                safeSenderName = (message.senderName && String(message.senderName).trim() !== '' && String(message.senderName) !== 'null' && String(message.senderName) !== 'undefined') 
                    ? String(message.senderName) : ('사용자' + message.senderId);
            }
            
            let fileHtml = '';
            if (message.files && message.files.length > 0) {
                console.log('=== 실시간 파일 처리 시작 ===');
                fileHtml = '<div class="file-attachments">';
                message.files.forEach((file, index) => {
                    const displayFileName = file.originalFileName || file.fileName || 'unknown_file';
                    const formattedSize = formatFileSize(file.fileSize || 0);
                    const safeDisplayFileName = (displayFileName || 'unknown_file').replace(/'/g, "\\'");
                    
                    fileHtml += 
                        '<div class="file-attachment">' +
                            '<i class="fas fa-file"></i>' +
                            '<span>' + safeDisplayFileName + '</span>' +
                            '<small class="file-size">(' + formattedSize + ')</small>' +
                            '<a href="/chat/download/' + file.id + '" ' +
                               'class="download-btn" ' +
                               'download="' + safeDisplayFileName + '">' +
                                '📥 다운로드' +
                            '</a>' +
                        '</div>';
                });
                fileHtml += '</div>';
                console.log('=== 실시간 파일 처리 완료 ===');
            }
            
            const currentTime = new Date().toLocaleTimeString('ko-KR', {
                hour: '2-digit',
                minute: '2-digit',
                hour12: false
            });
            
            let messageHtml = '<div class="conversation-list">';
            
            if (message.senderId != senderId) {
                messageHtml += '<div class="conversation-name">';
                messageHtml += '<a href="javascript:void(0)" class="user-name">' + safeSenderName + '</a>';
                messageHtml += '<span class="time">' + (message.createdAt || currentTime) + '</span>';
                messageHtml += '</div>';
            } else {
                messageHtml += '<div class="conversation-name">';
                messageHtml += '<a href="javascript:void(0)" class="user-name">나</a>';
                messageHtml += '<span class="time">' + currentTime + '</span>';
                messageHtml += '</div>';
            }
            
            messageHtml += 
                '<div class="ctext-wrap">' +
                    '<div class="ctext-wrap-content">' +
                        '<p class="message-content">' + safeContent + '</p>' +
                        fileHtml +
                    '</div>';
            
            if (message.senderId == senderId) {
                messageHtml += '<div class="read-status" id="read-status-' + (message.id || 'temp-' + Date.now()) + '">전송됨</div>';
            }
            
            messageHtml += '</div>';
            messageHtml += '</div>';
            
            messageDiv.innerHTML = messageHtml;
            messageDiv.setAttribute('data-message-id', message.id || 'temp-' + Date.now());
            
            chatMessages.appendChild(messageDiv);
            chatMessages.scrollTop = chatMessages.scrollHeight;
            
            if (message.id) {
                if (message.senderId == senderId) {
                    setTimeout(function() {
                        updateMessageReadStatus(message.id);
                    }, 1000);
                } else {
                    markMessageAsRead(message.id);
                    setTimeout(function() {
                        updateMessageReadStatus(message.id);
                    }, 1000);
                }
            }
        }
        
        function refreshParticipantsList() {
            console.log('🔄 참여자 목록 새로고침 시작');
            
            fetch('/chat/room/' + roomId + '/participants/list')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('HTTP error! status: ' + response.status);
                    }
                    return response.json();
                })
                .then(participants => {
                    console.log('=== 📋 API 응답 데이터 ===');
                    console.log('참여자 수:', participants.length);
                    updateParticipantsList(participants);
                })
                .catch(error => {
                    console.error('❌ 참여자 목록 새로고침 실패:', error);
                });
        }
        
        function updateParticipantsList(participants) {
            const participantsContainer = document.querySelector('.participants-list');
            const participantCountElement = document.querySelector('.participants-header small');
            
            if (!participantsContainer || !participantCountElement) {
                console.log('참여자 목록 컨테이너를 찾을 수 없습니다.');
                return;
            }
            
            participantCountElement.textContent = participants.length + '명';
            
            let participantsHtml = '';
            participants.forEach((participant, index) => {
                const firstChar = participant.nickname ? participant.nickname.charAt(0) : 'U';
                const isAdmin = participant.isAdmin || false;
                const isOnline = participant.isOnline || false;
                
                const statusClass = isOnline ? 'text-success' : 'text-muted';
                const statusIcon = isOnline ? 'fas fa-circle' : 'fas fa-circle';
                const statusText = isOnline ? '온라인' : '오프라인';
                
                const participantHtml = 
                    '<div class="participant-item">' +
                        '<div class="participant-avatar">' +
                            firstChar +
                        '</div>' +
                        '<div class="participant-info flex-grow-1">' +
                            '<div class="participant-name">' +
                                participant.nickname +
                            '</div>' +
                            '<small class="text-muted">' +
                                (isAdmin ? 
                                    '<span class="badge bg-warning text-dark">관리자</span>' : 
                                    '<span class="badge bg-secondary">멤버</span>') +
                            '</small>' +
                        '</div>' +
                        '<div class="participant-status">' +
                            '<small class="' + statusClass + ' online-status">' +
                                '<i class="' + statusIcon + '" style="font-size: 8px;"></i> ' + statusText +
                            '</small>' +
                        '</div>' +
                    '</div>';
                
                participantsHtml += participantHtml;
            });
            
            if (participants.length === 0) {
                participantsHtml = 
                    '<div class="text-center p-4 text-muted">' +
                        '<i class="fas fa-users fa-2x mb-2"></i>' +
                        '<p>참여자가 없습니다.</p>' +
                    '</div>';
            }
            
            participantsContainer.innerHTML = participantsHtml;
            console.log('참여자 목록 HTML 업데이트 완료');
        }

        function scrollToBottom() {
            const chatMessages = document.getElementById('chatMessages');
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        document.getElementById('messageInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                sendMessage();
            }
        });

        let selectedFiles = [];
        
        function handleFileSelect(event) {
            const files = Array.from(event.target.files);
            selectedFiles = files;
            
            const preview = document.getElementById('filePreview');
            preview.innerHTML = '';
            
            files.forEach((file, index) => {
                const fileDiv = document.createElement('div');
                fileDiv.className = 'file-preview-item d-flex align-items-center justify-content-between p-2 border rounded mb-2';
                fileDiv.innerHTML = 
                    '<div>' +
                        '<i class="fas fa-file"></i>' +
                        '<span class="ml-2">' + file.name + '</span>' +
                        '<small class="text-muted ml-2">(' + formatFileSize(file.size) + ')</small>' +
                    '</div>' +
                    '<button class="btn btn-sm btn-outline-danger" onclick="removeFile(' + index + ')">' +
                        '<i class="fas fa-times"></i>' +
                    '</button>';
                preview.appendChild(fileDiv);
            });
        }
        
        function removeFile(index) {
            selectedFiles.splice(index, 1);
            const fileInput = document.getElementById('fileInput');
            const dt = new DataTransfer();
            selectedFiles.forEach(file => dt.items.add(file));
            fileInput.files = dt.files;
            
            handleFileSelect({target: {files: selectedFiles}});
        }
        
        function formatFileSize(bytes) {
            if (bytes === 0) return '0 Bytes';
            const k = 1024;
            const sizes = ['Bytes', 'KB', 'MB', 'GB'];
            const i = Math.floor(Math.log(bytes) / Math.log(k));
            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
        }

        function uploadFiles() {
            if (selectedFiles.length === 0) return Promise.resolve([]);
            
            const formData = new FormData();
            selectedFiles.forEach(file => {
                formData.append('files', file);
            });
            formData.append('roomId', roomId);
            
            return fetch('/chat/upload', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                console.log('=== 파일 업로드 응답 ===');
                console.log('전체 응답:', data);
                
                if (data.success) {
                    return data.files;
                } else {
                    throw new Error('파일 업로드 실패');
                }
            });
        }

        function refreshEnhancedParticipantsList() {
            console.log('🔄 개선된 참여자 목록 새로고침 시작');
            
            fetch('/chat/room/' + roomId + '/participants/enhanced')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('HTTP error! status: ' + response.status);
                    }
                    return response.json();
                })
                .then(participants => {
                    console.log('=== 📋 개선된 참여자 목록 데이터 ===');
                    console.log('참여자 수:', participants.length);
                    
                    updateParticipantsDisplay(participants);
                    console.log('✅ 참여자 목록 업데이트 완료');
                })
                .catch(error => {
                    console.error('❌ 개선된 참여자 목록 조회 실패:', error);
                });
        }
        
        function updateParticipantsDisplay(participants) {
            const participantsContainer = document.getElementById('participantsContainer');
            if (!participantsContainer) {
                console.error('참여자 컨테이너를 찾을 수 없습니다.');
                return;
            }
            
            let participantsHtml = '';
            
            participants.forEach((participant, index) => {
                const firstChar = participant.nickname ? participant.nickname.substring(0, 1) : '?';
                const isAdmin = participant.isAdmin || false;
                const nickname = participant.nickname || '알 수 없음';
                
                const status = participant.status || 'OFFLINE';
                const isOnline = participant.isOnline || false;
                
                let statusClass, statusIcon, statusText;
                if (isOnline) {
                    switch (status) {
                        case 'ONLINE':
                            statusClass = 'text-success';
                            statusIcon = 'fas fa-circle';
                            statusText = '온라인';
                            break;
                        case 'AWAY':
                            statusClass = 'text-warning';
                            statusIcon = 'fas fa-moon';
                            statusText = '자리비움';
                            break;
                        case 'BUSY':
                            statusClass = 'text-danger';
                            statusIcon = 'fas fa-minus-circle';
                            statusText = '바쁨';
                            break;
                        default:
                            statusClass = 'text-muted';
                            statusIcon = 'fas fa-circle';
                            statusText = '오프라인';
                    }
                } else {
                    statusClass = 'text-muted';
                    statusIcon = 'fas fa-circle';
                    statusText = '오프라인';
                }
                
                const participantHtml = 
                    '<div class="participant-item">' +
                        '<div class="participant-avatar">' +
                            firstChar +
                        '</div>' +
                        '<div class="participant-info flex-grow-1">' +
                            '<div class="participant-name">' +
                                nickname +
                            '</div>' +
                            '<small class="text-muted">' +
                                (isAdmin ? 
                                    '<span class="badge bg-warning text-dark">관리자</span>' : 
                                    '<span class="badge bg-secondary">멤버</span>') +
                            '</small>' +
                        '</div>' +
                        '<div class="participant-status">' +
                            '<small class="' + statusClass + ' online-status">' +
                                '<i class="' + statusIcon + '" style="font-size: 8px;"></i> ' + statusText +
                            '</small>' +
                        '</div>' +
                    '</div>';
                
                participantsHtml += participantHtml;
            });
            
            if (participants.length === 0) {
                participantsHtml = 
                    '<div class="text-center p-4 text-muted">' +
                        '<i class="fas fa-users fa-2x mb-2"></i>' +
                        '<p>참여자가 없습니다.</p>' +
                    '</div>';
            }
            
            participantsContainer.innerHTML = participantsHtml;
            
            const participantCountElement = document.querySelector('.participants-header small');
            if (participantCountElement) {
                participantCountElement.textContent = participants.length + '명';
            }
            
            console.log('✅ 참여자 목록 표시 업데이트 완료');
        }

        function addStatusMenu() {
            console.log('🎯 상태 메뉴 추가 시작');
            
            const participantsHeader = document.querySelector('.participants-header');
            if (!participantsHeader) {
                console.log('참여자 목록 헤더를 찾을 수 없습니다.');
                return;
            }
            
            const existingButton = participantsHeader.querySelector('.status-dropdown');
            if (existingButton) {
                existingButton.remove();
            }
            
            const statusButtonHtml = 
                '<div class="status-dropdown">' +
                    '<button class="btn btn-sm status-btn" type="button" id="statusBtn" title="내 상태 변경">' +
                        '<i class="fas fa-user-circle"></i> 상태' +
                    '</button>' +
                '</div>';
            
            // 헤더의 d-flex 컨테이너에 추가
            const headerContainer = participantsHeader.querySelector('.d-flex');
            if (headerContainer) {
                headerContainer.insertAdjacentHTML('beforeend', statusButtonHtml);
            } else {
                participantsHeader.insertAdjacentHTML('beforeend', statusButtonHtml);
            }
            
            // 상태 버튼 이벤트 리스너 추가
            setTimeout(() => {
                setupStatusButton();
            }, 100);
            
            console.log('✅ 상태 메뉴 추가 완료');
        }
        
        function setupStatusButton() {
            const statusBtn = document.getElementById('statusBtn');
            
            if (statusBtn) {
                statusBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    openStatusModal();
                });
                
                console.log('✅ 상태 버튼 이벤트 리스너 설정 완료');
            }
        }
        
        function openStatusModal() {
            const modal = document.getElementById('statusModal');
            if (modal) {
                modal.classList.add('show');
                document.body.style.overflow = 'hidden';
                
                // 모달 외부 클릭 시 닫기
                modal.addEventListener('click', function(e) {
                    if (e.target === modal) {
                        closeStatusModal();
                    }
                });
                
                // ESC 키로 닫기
                document.addEventListener('keydown', handleModalEscape);
            }
        }
        
        function closeStatusModal() {
            const modal = document.getElementById('statusModal');
            if (modal) {
                modal.classList.remove('show');
                document.body.style.overflow = '';
                document.removeEventListener('keydown', handleModalEscape);
            }
        }
        
        function handleModalEscape(e) {
            if (e.key === 'Escape') {
                closeStatusModal();
            }
        }
        
        function selectStatus(status, statusText) {
            console.log('🎯 상태 선택:', status, statusText);
            
            // 모달 닫기
            closeStatusModal();
            
            // 상태 메시지 설정
            let statusMessage = '';
            switch (status) {
                case 'AWAY':
                    statusMessage = '잠시 자리를 비웠습니다';
                    break;
                case 'BUSY':
                    statusMessage = '바쁩니다';
                    break;
                default:
                    statusMessage = '';
            }
            
            // 상태 업데이트
            updateUserStatus(status, statusMessage);
        }
        
        function adjustDropdownPosition(menu) {
            // 모달 방식으로 변경했으므로 더 이상 필요하지 않음
            console.log('드롭다운 위치 조정 함수는 더 이상 사용되지 않습니다.');
        }
        
        function setupStatusDropdown() {
            // 모달 방식으로 변경했으므로 더 이상 필요하지 않음
            console.log('모달 방식으로 변경되어 드롭다운 설정은 더 이상 필요하지 않습니다.');
        }
        
        function updateUserStatus(status, statusMessage) {
            console.log('🔄 상태 변경 요청:', { status, statusMessage });
            
            const params = new URLSearchParams();
            params.append('status', status);
            if (statusMessage) {
                params.append('statusMessage', statusMessage);
            }
            
            fetch('/chat/status', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    console.log('✅ 상태 업데이트 성공:', data.status, data.statusMessage);
                    
                    updateCurrentUserStatusDisplay(data.status, data.statusMessage);
                    
                    setTimeout(() => {
                        console.log('🔄 참여자 목록 새로고침 시작...');
                        refreshEnhancedParticipantsList();
                    }, 500);
                } else {
                    console.warn('❌ 상태 업데이트 실패:', data.message);
                    alert('상태 변경에 실패했습니다: ' + data.message);
                }
            })
            .catch(error => {
                console.error('💥 상태 업데이트 오류:', error);
                alert('상태 변경 중 오류가 발생했습니다.');
            });
        }
        
        function updateCurrentUserStatusDisplay(status, statusMessage) {
            const currentUserElement = document.querySelector('[data-user-id="' + userId + '"]');
            if (currentUserElement) {
                let statusClass, statusIcon, statusText;
                
                switch (status) {
                    case 'ONLINE':
                        statusClass = 'text-success';
                        statusIcon = 'fas fa-circle';
                        statusText = '온라인';
                        break;
                    case 'AWAY':
                        statusClass = 'text-warning';
                        statusIcon = 'fas fa-moon';
                        statusText = '자리비움';
                        break;
                    case 'BUSY':
                        statusClass = 'text-danger';
                        statusIcon = 'fas fa-minus-circle';
                        statusText = '바쁨';
                        break;
                    default:
                        statusClass = 'text-muted';
                        statusIcon = 'fas fa-circle';
                        statusText = '오프라인';
                }
                
                const statusHtml = 
                    '<small class="' + statusClass + ' online-status">' +
                        '<i class="' + statusIcon + '" style="font-size: 8px;"></i> ' + statusText +
                    '</small>' +
                    (statusMessage ? '<div style="font-size: 11px; color: #666; font-style: italic; margin-left: 55px;">' + statusMessage + '</div>' : '');
                
                currentUserElement.innerHTML = statusHtml;
                console.log('✅ 현재 사용자 상태 즉시 반영 완료:', statusText);
            }
        }

        function sendHeartbeat() {
            fetch('/chat/heartbeat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    console.log('💓 하트비트 전송 성공:', data.timestamp);
                } else {
                    console.warn('하트비트 전송 실패:', data.message);
                }
            })
            .catch(error => {
                console.error('하트비트 전송 오류:', error);
            });
        }

        function startHeartbeat() {
            sendHeartbeat();
            setInterval(sendHeartbeat, 30000);
            setInterval(refreshEnhancedParticipantsList, 300000);
            console.log('💓 하트비트 시스템 시작됨');
        }

        function goBackToList() {
            console.log('채팅방 목록으로 돌아가기 시작');
            
            if (stompClient && stompClient.connected) {
                try {
                    stompClient.send("/app/chat.leave", {}, 
                        JSON.stringify({
                            type: 'LEAVE',
                            roomId: roomId,
                            senderId: senderId,
                            content: '퇴장하였습니다.'
                        })
                    );
                    console.log('퇴장 메시지 전송 완료');
                } catch (error) {
                    console.error('퇴장 메시지 전송 실패:', error);
                }
            }
            
            const isInIframe = window.self !== window.top;
            console.log('iframe 실행 여부:', isInIframe);
            
            if (isInIframe) {
                try {
                    window.parent.postMessage({
                        type: 'CHAT_BACK_TO_LIST',
                        action: 'hideIframe'
                    }, '*');
                    console.log('부모 창에 메시지 전송 완료');
                    
                    setTimeout(function() {
                        try {
                            if (window.parent && window.parent.document) {
                                const parentDoc = window.parent.document;
                                const chatFrame = parentDoc.getElementById('chatFrame');
                                const chatWelcome = parentDoc.getElementById('chatWelcome');
                                
                                if (chatFrame && chatWelcome) {
                                    chatFrame.style.display = 'none';
                                    chatWelcome.style.display = 'flex';
                                    
                                    const activeRooms = parentDoc.querySelectorAll('.room-item.active');
                                    activeRooms.forEach(room => room.classList.remove('active'));
                                    
                                    console.log('부모 창 직접 접근 성공');
                                }
                            }
                        } catch (directError) {
                            console.log('부모 창 직접 접근 실패 (정상적임):', directError.message);
                        }
                    }, 100);
                    
                } catch (error) {
                    console.error('부모 창 통신 실패:', error);
                    try {
                        window.top.location.href = '/chat';
                    } catch (topError) {
                        console.error('최상위 창 접근 실패:', topError);
                        window.location.href = '/chat';
                    }
                }
            } else {
                console.log('직접 접근 - 채팅 목록으로 이동');
                window.location.href = '/chat';
            }
        }

        function markMessageAsRead(messageId) {
            fetch('/chat/message/' + messageId + '/read?userId=' + senderId, {
                method: 'POST'
            })
            .then(response => response.text())
            .then(result => {
                if (result === 'success') {
                    console.log('메시지 읽음 처리 완료:', messageId);
                }
            })
            .catch(error => {
                console.error('메시지 읽음 처리 실패:', error);
            });
        }
        
        function updateMessageReadStatus(messageId) {
            fetch('/chat/message/' + messageId + '/read-status')
            .then(response => {
                if (!response.ok) {
                    throw new Error('HTTP error! status: ' + response.status);
                }
                return response.text();
            })
            .then(text => {
                try {
                    const data = JSON.parse(text);
                    const readStatusElement = document.getElementById('read-status-' + messageId);
                    if (readStatusElement) {
                        const readCount = parseInt(data.read_count) || 0;
                        const unreadCount = parseInt(data.unread_count) || 0;
                        
                        if (readCount === 0) {
                            readStatusElement.textContent = '전송됨';
                            readStatusElement.className = 'read-status';
                        } else if (unreadCount === 0) {
                            readStatusElement.textContent = '읽음';
                            readStatusElement.className = 'read-status read';
                        } else {
                            readStatusElement.textContent = readCount + '명 읽음';
                            readStatusElement.className = 'read-status read';
                        }
                    }
                } catch (parseError) {
                    console.error('JSON 파싱 오류:', parseError);
                    const readStatusElement = document.getElementById('read-status-' + messageId);
                    if (readStatusElement) {
                        readStatusElement.textContent = '전송됨';
                        readStatusElement.className = 'read-status';
                    }
                }
            })
            .catch(error => {
                console.error('읽음 상태 업데이트 실패:', error);
                const readStatusElement = document.getElementById('read-status-' + messageId);
                if (readStatusElement) {
                    readStatusElement.textContent = '전송됨';
                    readStatusElement.className = 'read-status';
                }
            });
        }
        
        function updateAllMessageReadStatus() {
            const messageElements = document.querySelectorAll('[data-message-id]');
            messageElements.forEach(element => {
                const messageId = element.getAttribute('data-message-id');
                if (messageId && !messageId.startsWith('temp-')) {
                    updateMessageReadStatus(messageId);
                }
            });
        }
        
        window.addEventListener('focus', function() {
            setTimeout(function() {
                fetch('/chat/room/' + roomId + '/mark-all-read', {
                    method: 'POST'
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        console.log('모든 메시지를 읽음으로 표시했습니다.');
                        updateAllMessageReadStatus();
                    }
                })
                .catch(error => {
                    console.error('읽음 처리 실패:', error);
                });
            }, 500);
        });

        function initializeReadStatus() {
            console.log('=== 기존 메시지 읽음 상태 초기화 시작 ===');
            
            const otherUserMessages = document.querySelectorAll('[data-message-id]:not(.right)');
            otherUserMessages.forEach(function(messageElement) {
                const messageId = messageElement.getAttribute('data-message-id');
                if (messageId && messageId !== 'null') {
                    markMessageAsRead(messageId);
                }
            });
            
            setTimeout(function() {
                updateAllMessageReadStatus();
            }, 2000);
            
            console.log('=== 기존 메시지 읽음 상태 초기화 완료 ===');
        }

        // 검색 관련 변수
        let searchResults = [];
        let currentSearchIndex = -1;
        let searchQuery = '';
        let isSearchMode = false;

        function toggleSearch() {
            const searchBar = document.getElementById('searchBar');
            const searchInput = document.getElementById('messageSearchInput');
            
            if (searchBar.style.display === 'none') {
                searchBar.style.display = 'block';
                searchInput.focus();
                isSearchMode = true;
                
                searchInput.addEventListener('input', handleSearchInput);
                searchInput.addEventListener('keydown', handleSearchKeyDown);
            } else {
                closeSearch();
            }
        }

        function closeSearch() {
            const searchBar = document.getElementById('searchBar');
            const searchInput = document.getElementById('messageSearchInput');
            
            searchBar.style.display = 'none';
            isSearchMode = false;
            
            clearSearchResults();
            searchInput.value = '';
            
            searchInput.removeEventListener('input', handleSearchInput);
            searchInput.removeEventListener('keydown', handleSearchKeyDown);
        }

        function handleSearchInput(event) {
            const query = event.target.value.trim();
            searchQuery = query;
            
            if (query.length === 0) {
                clearSearchResults();
                return;
            }
            
            performRealtimeSearch(query);
        }

        function handleSearchKeyDown(event) {
            switch(event.key) {
                case 'Escape':
                    closeSearch();
                    break;
                case 'Enter':
                    event.preventDefault();
                    if (event.shiftKey) {
                        goToPreviousResult();
                    } else {
                        goToNextResult();
                    }
                    break;
                case 'ArrowDown':
                    event.preventDefault();
                    goToNextResult();
                    break;
                case 'ArrowUp':
                    event.preventDefault();
                    goToPreviousResult();
                    break;
            }
        }

        function performRealtimeSearch(query) {
            clearSearchResults();
            
            if (!query) return;
            
            const messages = document.querySelectorAll('.message .message-content');
            searchResults = [];
            
            messages.forEach((messageElement, index) => {
                const text = messageElement.textContent.toLowerCase();
                const searchTerm = query.toLowerCase();
                
                if (text.includes(searchTerm)) {
                    const messageDiv = messageElement.closest('.message');
                    searchResults.push({
                        element: messageDiv,
                        contentElement: messageElement,
                        index: index
                    });
                    
                    messageDiv.classList.add('search-result');
                    highlightText(messageElement, query);
                }
            });
            
            updateSearchResultsCount();
            
            if (searchResults.length > 0) {
                currentSearchIndex = 0;
                scrollToSearchResult(0);
            }
        }

        function highlightText(element, query) {
            const originalText = element.textContent;
            const lowerText = originalText.toLowerCase();
            const lowerQuery = query.toLowerCase();
            let highlightedText = '';
            let startIndex = 0;
            let foundIndex = lowerText.indexOf(lowerQuery);
            
            while (foundIndex !== -1) {
                highlightedText += originalText.substring(startIndex, foundIndex);
                highlightedText += '<span class="search-highlight">' + 
                                 originalText.substring(foundIndex, foundIndex + query.length) + 
                                 '</span>';
                startIndex = foundIndex + query.length;
                foundIndex = lowerText.indexOf(lowerQuery, startIndex);
            }
            highlightedText += originalText.substring(startIndex);
            element.innerHTML = highlightedText;
        }

        function clearSearchResults() {
            document.querySelectorAll('.search-highlight').forEach(element => {
                const parent = element.parentNode;
                parent.replaceChild(document.createTextNode(element.textContent), element);
                parent.normalize();
            });
            
            document.querySelectorAll('.search-result').forEach(element => {
                element.classList.remove('search-result', 'current-result');
            });
            
            searchResults = [];
            currentSearchIndex = -1;
            
            updateSearchResultsCount();
            updateNavigationButtons();
        }

        function goToNextResult() {
            if (searchResults.length === 0) return;
            
            if (currentSearchIndex < searchResults.length - 1) {
                currentSearchIndex++;
            } else {
                currentSearchIndex = 0;
            }
            
            scrollToSearchResult(currentSearchIndex);
        }

        function goToPreviousResult() {
            if (searchResults.length === 0) return;
            
            if (currentSearchIndex > 0) {
                currentSearchIndex--;
            } else {
                currentSearchIndex = searchResults.length - 1;
            }
            
            scrollToSearchResult(currentSearchIndex);
        }

        function scrollToSearchResult(index) {
            if (index < 0 || index >= searchResults.length) return;
            
            document.querySelectorAll('.current-result').forEach(element => {
                element.classList.remove('current-result');
            });
            
            const currentResult = searchResults[index];
            currentResult.element.classList.add('current-result');
            
            const highlights = currentResult.contentElement.querySelectorAll('.search-highlight');
            highlights.forEach(highlight => {
                highlight.classList.add('current');
            });
            
            currentResult.element.scrollIntoView({
                behavior: 'smooth',
                block: 'center'
            });
            
            updateSearchResultsCount();
            updateNavigationButtons();
        }

        function updateSearchResultsCount() {
            const countElement = document.getElementById('searchResultsCount');
            
            if (searchResults.length === 0) {
                countElement.textContent = searchQuery ? '검색 결과 없음' : '';
            } else {
                countElement.textContent = (currentSearchIndex + 1) + '/' + searchResults.length;
            }
        }

        function updateNavigationButtons() {
            const prevBtn = document.getElementById('searchPrevBtn');
            const nextBtn = document.getElementById('searchNextBtn');
            
            const hasResults = searchResults.length > 0;
            
            prevBtn.disabled = !hasResults;
            nextBtn.disabled = !hasResults;
        }

        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape' && isSearchMode) {
                closeSearch();
            }
        });

        window.onload = function() {
            console.log('🚀 페이지 로드 완료 - 초기화 시작');
            
            scrollToBottom();
            
            // 드롭다운 메뉴 초기화 (숨김 상태 확실히 설정)
            const dropdownMenus = document.querySelectorAll('.dropdown-menu');
            dropdownMenus.forEach(menu => {
                menu.classList.remove('show');
                menu.style.display = 'none';
            });
            
            // 상태 메뉴를 즉시 추가 (기존 1초 지연 제거)
            addStatusMenu();
            console.log('🎯 상태 메뉴 즉시 추가 완료');
            
            console.log('=== 파일 크기 포맷팅 시작 ===');
            const fileSizeElements = document.querySelectorAll('.file-size');
            fileSizeElements.forEach(function(element) {
                const size = element.getAttribute('data-size');
                if (size) {
                    const formattedSize = formatFileSize(parseInt(size));
                    element.textContent = '(' + formattedSize + ')';
                    console.log('파일 크기 포맷팅: ' + size + ' -> ' + formattedSize);
                }
            });
            console.log('=== 파일 크기 포맷팅 완료 ===');
            
            console.log('📋 즉시 참여자 목록 로드 시작');
            refreshEnhancedParticipantsList();
            
            setTimeout(function() {
                initializeReadStatus();
            }, 3000);
            
            connect();
            
            const backButton = document.querySelector('a[href="/chat"]');
            if (backButton) {
                backButton.addEventListener('click', function(e) {
                    console.log('돌아가기 버튼 클릭됨');
                    setTimeout(function() {
                        window.location.href = '/chat';
                    }, 100);
                    e.preventDefault();
                });
            }
            
            console.log('✅ 페이지 초기화 완료');
        };
        
        window.addEventListener('beforeunload', function(e) {
            console.log('beforeunload 이벤트 발생 - 퇴장 메시지 전송 비활성화됨');
        });

        // 드롭다운 메뉴 수동 토글 기능 추가
        document.addEventListener('DOMContentLoaded', function() {
            // 채팅 헤더의 메인 드롭다운 (알림 설정 등)
            const dropdownToggle = document.querySelector('.chat-header .dropdown-toggle');
            const dropdownMenu = document.querySelector('.chat-header .dropdown-menu');
            
            console.log('드롭다운 요소 확인:', {
                toggle: dropdownToggle,
                menu: dropdownMenu
            });
            
            if (dropdownToggle && dropdownMenu) {
                // 새로운 이벤트 리스너 추가
                dropdownToggle.addEventListener('click', function(e) {
                    console.log('드롭다운 버튼 클릭됨');
                    e.preventDefault();
                    e.stopPropagation();
                    
                    // 상태 모달이 열려있으면 닫기
                    const statusModal = document.getElementById('statusModal');
                    if (statusModal && statusModal.classList.contains('show')) {
                        statusModal.classList.remove('show');
                    }
                    
                    // 다른 열린 드롭다운 메뉴들을 닫기
                    document.querySelectorAll('.dropdown-menu.show').forEach(menu => {
                        if (menu !== dropdownMenu) {
                            menu.classList.remove('show');
                        }
                    });
                    
                    // 현재 드롭다운 메뉴 토글
                    const isVisible = dropdownMenu.classList.contains('show');
                    if (isVisible) {
                        dropdownMenu.classList.remove('show');
                        console.log('드롭다운 메뉴 숨김');
                    } else {
                        // 위치 조정 후 바로 표시
                        adjustMainDropdownPosition(dropdownMenu);
                        dropdownMenu.classList.add('show');
                        console.log('드롭다운 메뉴 표시');
                    }
                });
                
                console.log('✅ 메인 드롭다운 이벤트 리스너 설정 완료');
            } else {
                console.error('❌ 드롭다운 요소를 찾을 수 없습니다');
            }
            
            // 전역 드롭다운 외부 클릭 및 ESC 키 이벤트
            document.addEventListener('click', function(e) {
                // 드롭다운 영역 외부를 클릭했는지 확인
                const clickedElement = e.target;
                const isDropdownClick = clickedElement.closest('.dropdown');
                const isStatusModal = clickedElement.closest('.status-modal-overlay');
                
                if (!isDropdownClick && !isStatusModal) {
                    // 모든 드롭다운 메뉴 닫기
                    document.querySelectorAll('.dropdown-menu.show').forEach(menu => {
                        menu.classList.remove('show');
                    });
                    console.log('외부 클릭으로 드롭다운 메뉴 닫음');
                }
            });
            
            // ESC 키로 모든 드롭다운 닫기
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    document.querySelectorAll('.dropdown-menu.show').forEach(menu => {
                        menu.classList.remove('show');
                    });
                    console.log('ESC 키로 드롭다운 메뉴 닫음');
                }
            });
        });
        
        // 메인 드롭다운 위치 조정 함수
        function adjustMainDropdownPosition(menu) {
            const button = document.querySelector('.chat-header .dropdown-toggle');
            if (!button) return;
            
            const buttonRect = button.getBoundingClientRect();
            const viewportHeight = window.innerHeight;
            const viewportWidth = window.innerWidth;
            
            // 메뉴를 임시로 표시하여 실제 크기 계산
            menu.style.visibility = 'hidden';
            menu.style.display = 'block';
            const menuRect = menu.getBoundingClientRect();
            const menuHeight = menuRect.height;
            const menuWidth = menuRect.width;
            menu.style.visibility = '';
            menu.style.display = '';
            
            // 기본 위치: 버튼 바로 아래쪽 (간격 줄임)
            let top = buttonRect.bottom + 4;
            let left = buttonRect.right - menuWidth;
            
            // 화면 아래쪽으로 나가는 경우 위쪽으로 표시
            if (top + menuHeight > viewportHeight - 10) {
                top = buttonRect.top - menuHeight - 4;
            }
            
            // 화면 왼쪽으로 나가는 경우 오른쪽으로 이동
            if (left < 10) {
                left = buttonRect.left;
            }
            
            // 화면 오른쪽으로 나가는 경우 왼쪽으로 이동
            if (left + menuWidth > viewportWidth - 10) {
                left = buttonRect.right - menuWidth;
            }
            
            menu.style.position = 'fixed';
            menu.style.top = top + 'px';
            menu.style.left = left + 'px';
            menu.style.right = 'auto';
            menu.style.bottom = 'auto';
            menu.style.marginTop = '0';
            menu.style.marginBottom = '0';
            
            console.log('메인 드롭다운 위치 조정 완료:', { top, left, menuHeight, menuWidth });
        }
    </script>
</body>
</html>