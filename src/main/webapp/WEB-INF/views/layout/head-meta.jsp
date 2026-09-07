<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title><%= request.getAttribute("title") %></title>
  <style>
    /* ───────────────────────────────────────────────────────────────── */
    /* html, body 기본 설정 - Sticky Footer를 위한 설정 */
    html, body {
      height: 100%;
      margin: 0;
    }
    body {
      display: flex;
      margin: 0;
      background-color: #ffffff;
      color: #000000;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }

    /* 전역 링크 스타일 - 밑줄 제거 및 색상 고정 */
    a {
      text-decoration: none !important;
      color: inherit !important;
    }
    a:link {
      text-decoration: none !important;
      color: inherit !important;
    }
    a:visited {
      text-decoration: none !important;
      color: inherit !important;
    }
    a:hover {
      text-decoration: none !important;
      color: inherit !important;
    }
    a:active {
      text-decoration: none !important;
      color: inherit !important;
    }

    /* ── 사이드바 ────────────────────────────────────────────────── */
    .sidebar {
      position: fixed;
      top: 0; 
      left: 0;
      width: 240px;
      height: 100vh;
      background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%);
      display: flex;
      flex-direction: column;
      justify-content: flex-start;
      padding: 80px 0 40px 0;
      overflow-x: hidden;
      overflow-y: auto;
      border-right: 1px solid #e2e8f0;
      z-index: 999;
      box-shadow: 4px 0 20px rgba(0, 0, 0, 0.05);
    }
    
    /* 사이드바 스크롤바 스타일 */
    .sidebar::-webkit-scrollbar {
      width: 6px;
    }
    
    .sidebar::-webkit-scrollbar-track {
      background: #f1f5f9;
    }
    
    .sidebar::-webkit-scrollbar-thumb {
      background: #cbd5e1;
      border-radius: 3px;
    }
    
    .sidebar::-webkit-scrollbar-thumb:hover {
      background: #94a3b8;
    }

    /* ── 상단 로고 ── */
    .sidebar-header {
      text-align: center;
      margin-bottom: 20px;
      padding: 0 16px;
    }
    .sidebar-logo {
      width: 200px;
      height: 70px;
      margin: 0 auto;
    }
    .sidebar-logo img {
      width: 100%;
      height: 100%;
      object-fit: contain;
      display: block;
    }

    /* ── 메뉴 그룹 ─────────────────────────────────────────────── */
    .menu-group {
      display: flex;
      flex-direction: column;
      margin-bottom: 12px;
      padding: 0 16px;
      flex-shrink: 0;
    }
    
    .menu-item {
      display: flex;
      align-items: center;
      padding: 8px 12px;
      text-decoration: none !important;
      color: #64748b;
      font-size: 14px;
      font-weight: 500;
      border-radius: 8px;
      margin-bottom: 2px;
      transition: all 0.2s ease;
    }
    
    .menu-item:hover {
      background: rgba(37, 99, 235, 0.08);
      color: #2563eb;
    }
    
    /* 사이드바 링크 스타일 */
    .sidebar a,
    .sidebar a:link,
    .sidebar a:visited,
    .sidebar a:hover,
    .sidebar a:active {
      text-decoration: none !important;
      border-bottom: none !important;
    }
    
    /* 모든 영역의 링크 색상 변화 방지 */
    .content a,
    .main-body a,
    .chat-container a,
    .room-item a {
      color: inherit !important;
    }
    
    .content a:hover,
    .main-body a:hover,
    .chat-container a:hover,
    .room-item a:hover {
      color: inherit !important;
      text-decoration: none !important;
    }
    
    /* 버튼은 예외로 원래 색상 유지 */
    .btn,
    .btn:hover,
    .btn:focus,
    .btn:active,
    button,
    button:hover,
    button:focus,
    button:active {
      color: revert !important;
    }
    
    .menu-item svg {
      width: 16px;
      height: 16px;
      margin-right: 10px;
      fill: #64748b;
      flex-shrink: 0;
      transition: fill 0.2s ease;
    }
    
    .menu-item:hover svg {
      fill: #2563eb;
    }
    
    .menu-item span {
      white-space: nowrap;
      opacity: 1;
      font-weight: 500;
    }

    /* ── 그룹 간 구분선 ───────────────────────────────────────── */
    .menu-separator {
      height: 1px;
      margin: 8px 20px;
      background: linear-gradient(90deg, transparent, #e2e8f0, transparent);
    }

    /* ── 그룹 제목 & 서브메뉴 ───────────────────────────────── */
    .group-title {
      display: flex;
      align-items: center;
      padding: 6px 12px;
      font-size: 11px;
      font-weight: 600;
      color: #94a3b8;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-top: 4px;
      margin-bottom: 4px;
    }
    
    .group-title span {
      opacity: 1;
    }

    .submenu {
      list-style: none;
      margin: 0;
      padding: 0;
      max-height: 500px;
      overflow: visible;
      opacity: 1;
      transition: all 0.3s ease;
      margin-top: 4px;
      margin-bottom: 8px;
    }
    
    .submenu.collapsed {
      max-height: 0;
      opacity: 0;
      margin-top: 0;
      margin-bottom: 0;
      overflow: hidden;
    }
    
    .submenu li {
      display: block !important;
      visibility: visible !important;
      opacity: 1 !important;
    }
    
    .submenu li a {
      display: block !important;
      padding: 6px 12px 6px 36px;
      font-size: 13px;
      color: #64748b;
      text-decoration: none !important;
      border-radius: 6px;
      margin: 1px 12px;
      font-weight: 400;
      transition: all 0.2s ease;
      visibility: visible !important;
      opacity: 1 !important;
    }
    
    .submenu li a:hover {
      background: rgba(37, 99, 235, 0.06);
      color: #2563eb;
    }

    /* ── 메인 컨텐트 ───────────────────────────────────────────── */
    .content {
      margin-left: 240px;
      display: flex;
      flex-direction: column;
      flex: 1;
      min-height: 100vh;
      position: relative;
    }

    .sidebar .menu {
      list-style: none;
      margin: 0;
      padding: 0;
    }    
    
    .sidebar li {
      list-style-type: none;
    }
    
    /* 화살표 회전 애니메이션 */
    .menu-item.expanded .submenu-arrow {
      transform: rotate(180deg);
    }
    
    /* 현재 페이지 강조 */
    .menu-item.active,
    .submenu li a.active {
      background: rgba(99, 102, 241, 0.1);
      color: #6366f1;
    }
    
    .menu-item.active svg,
    .submenu li a.active {
      fill: #6366f1;
      color: #6366f1;
    }
    
    /* ── 툴바 ───────────────────────────────────────────────── */
    .toolbar {
      position: fixed;
      top: 0;
      left: 0;
      width: 100vw;
      height: 70px;
      display: flex;
      justify-content: flex-end;
      align-items: center;
      padding: 0 32px;
      background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
      border-bottom: 1px solid #e2e8f0;
      box-sizing: border-box;
      z-index: 1001;
      gap: 24px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
      backdrop-filter: blur(10px);
    }

    /* ── 본문 영역 ───────────────────────────────────────────── */
    .main-body {
      margin-top: 70px;
      flex: 1 0 auto;
      overflow: auto;
      padding: 32px 32px 80px 32px;
      background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
    }

    /* ── 푸터 ───────────────────────────────────────────────── */
    footer.footer {
      flex-shrink: 0;
      margin-top: auto;
    }

    /* help 페이지 제목, 섹션 스타일 */
    .help-page h1 {
      font-size: 28px;
      margin-bottom: 24px;
      color: #1e293b;
      font-weight: 600;
    }
    .help-page section {
      margin-bottom: 32px;
      background: rgba(255, 255, 255, 0.8);
      padding: 28px;
      border-radius: 16px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.08);
      border: 1px solid rgba(226, 232, 240, 0.6);
      backdrop-filter: blur(10px);
    }
    .help-page section h2 {
      font-size: 20px;
      margin-bottom: 16px;
      border-left: 4px solid #2563eb;
      padding-left: 16px;
      color: #2563eb;
      font-weight: 600;
    }
    .help-page section ul,
    .help-page section dl {
      margin-left: 20px;
    }
    .help-page dl dt {
      font-weight: 600;
      margin-top: 12px;
      color: #1e293b;
    }
    .help-page dl dd {
      margin-left: 20px;
      margin-bottom: 12px;
      color: #64748b;
      line-height: 1.6;
    }

    /* ── 반응형 디자인 ── */
    @media (max-width: 1024px) {
      .sidebar {
        width: 240px;
        padding: 80px 0 20px 0;
      }
      .content {
        margin-left: 240px;
      }
    }

    @media (max-width: 768px) {
      .sidebar {
        width: 240px;
        padding: 80px 0 20px 0;
      }
      .content {
        margin-left: 240px;
      }
      .toolbar {
        padding: 0 20px;
        gap: 16px;
        height: 64px;
      }
      .main-body {
        margin-top: 64px;
        padding: 24px 24px 80px 24px;
      }
    }

    /* 사이드바 스크롤바 스타일 */
    .sidebar::-webkit-scrollbar {
      width: 4px;
    }
    
    .sidebar::-webkit-scrollbar-track {
      background: transparent;
    }
    
    .sidebar::-webkit-scrollbar-thumb {
      background-color: rgba(203, 213, 225, 0.6);
      border-radius: 2px;
    }
    
    .sidebar::-webkit-scrollbar-thumb:hover {
      background-color: rgba(148, 163, 184, 0.8);
    }

    /* ── 카드 스타일 ── */
    .card {
      background: rgba(255, 255, 255, 0.8);
      border-radius: 16px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.08);
      padding: 28px;
      margin-bottom: 24px;
      border: 1px solid rgba(226, 232, 240, 0.6);
      backdrop-filter: blur(10px);
      transition: all 0.3s ease;
    }
    
    .card:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 30px rgba(0,0,0,0.12);
    }

    .card-header {
      border-bottom: 1px solid rgba(226, 232, 240, 0.6);
      padding-bottom: 20px;
      margin-bottom: 24px;
    }

    .card-title {
      font-size: 20px;
      font-weight: 600;
      color: #1e293b;
      margin: 0;
    }

    /* ── 버튼 스타일 ── */
    .btn {
      padding: 12px 20px;
      border-radius: 10px;
      border: none;
      font-size: 14px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.3s ease;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }

    .btn-primary {
      background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
      color: white;
      box-shadow: 0 4px 12px rgba(37, 99, 235, 0.3);
    }

    .btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(37, 99, 235, 0.4);
    }

    .btn-secondary {
      background: linear-gradient(135deg, #64748b 0%, #475569 100%);
      color: white;
      box-shadow: 0 4px 12px rgba(100, 116, 139, 0.3);
    }

    .btn-secondary:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(100, 116, 139, 0.4);
    }

    .btn-outline {
      background: rgba(255, 255, 255, 0.8);
      border: 2px solid #2563eb;
      color: #2563eb;
      backdrop-filter: blur(10px);
    }

    .btn-outline:hover {
      background: #2563eb;
      color: white;
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(37, 99, 235, 0.3);
    }

    /* ── 폼 스타일 ── */
    .form-group {
      margin-bottom: 24px;
    }

    .form-label {
      display: block;
      margin-bottom: 8px;
      font-weight: 500;
      color: #1e293b;
    }

    .form-control {
      width: 100%;
      padding: 14px 18px;
      border: 2px solid rgba(226, 232, 240, 0.6);
      border-radius: 10px;
      font-size: 14px;
      transition: all 0.3s ease;
      box-sizing: border-box;
      background: rgba(255, 255, 255, 0.8);
      backdrop-filter: blur(10px);
    }

    .form-control:focus {
      outline: none;
      border-color: #2563eb;
      box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
      background: rgba(255, 255, 255, 0.95);
    }

    /* ── 테이블 스타일 ── */
    .table {
      width: 100%;
      border-collapse: collapse;
      background: rgba(255, 255, 255, 0.8);
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 4px 20px rgba(0,0,0,0.08);
      backdrop-filter: blur(10px);
    }

    .table th,
    .table td {
      padding: 18px;
      text-align: left;
      border-bottom: 1px solid rgba(226, 232, 240, 0.6);
    }

    .table th {
      background: rgba(248, 250, 252, 0.8);
      font-weight: 600;
      color: #1e293b;
    }

    .table tbody tr:hover {
      background: rgba(248, 250, 252, 0.6);
    }

    /* ── 알림 스타일 ── */
    .alert {
      padding: 18px 22px;
      border-radius: 12px;
      margin-bottom: 24px;
      border: 1px solid transparent;
      backdrop-filter: blur(10px);
    }

    .alert-success {
      background: rgba(212, 237, 218, 0.8);
      border-color: rgba(195, 230, 203, 0.8);
      color: #155724;
    }

    .alert-warning {
      background: rgba(255, 243, 205, 0.8);
      border-color: rgba(255, 234, 167, 0.8);
      color: #856404;
    }

    .alert-error {
      background: rgba(248, 215, 218, 0.8);
      border-color: rgba(245, 198, 203, 0.8);
      color: #721c24;
    }

    .alert-info {
      background: rgba(209, 236, 241, 0.8);
      border-color: rgba(190, 229, 235, 0.8);
      color: #0c5460;
    }

    /* ── 로딩 스타일 ── */
    .loading {
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 50px;
      color: #64748b;
    }

    .spinner {
      width: 24px;
      height: 24px;
      border: 3px solid rgba(37, 99, 235, 0.1);
      border-top: 3px solid #2563eb;
      border-radius: 50%;
      animation: spin 1s linear infinite;
      margin-right: 14px;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }

    /* ── 뱃지 스타일 ── */
    .badge {
      display: inline-block;
      padding: 6px 12px;
      font-size: 12px;
      font-weight: 500;
      border-radius: 16px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .badge-primary {
      background: linear-gradient(135deg, #2563eb, #1d4ed8);
      color: white;
    }

    .badge-success {
      background: linear-gradient(135deg, #10b981, #059669);
      color: white;
    }

    .badge-warning {
      background: linear-gradient(135deg, #f59e0b, #d97706);
      color: white;
    }

    .badge-danger {
      background: linear-gradient(135deg, #ef4444, #dc2626);
      color: white;
    }

    /* ── 유틸리티 클래스 ── */
    .text-center { text-align: center; }
    .text-left { text-align: left; }
    .text-right { text-align: right; }
    
    .mt-1 { margin-top: 8px; }
    .mt-2 { margin-top: 16px; }
    .mt-3 { margin-top: 24px; }
    .mt-4 { margin-top: 32px; }
    
    .mb-1 { margin-bottom: 8px; }
    .mb-2 { margin-bottom: 16px; }
    .mb-3 { margin-bottom: 24px; }
    .mb-4 { margin-bottom: 32px; }
    
    .p-1 { padding: 8px; }
    .p-2 { padding: 16px; }
    .p-3 { padding: 24px; }
    .p-4 { padding: 32px; }
    
    .d-flex { display: flex; }
    .d-block { display: block; }
    .d-inline { display: inline; }
    .d-none { display: none; }
    
    .justify-content-center { justify-content: center; }
    .justify-content-between { justify-content: space-between; }
    .justify-content-end { justify-content: flex-end; }
    
    .align-items-center { align-items: center; }
    .align-items-start { align-items: flex-start; }
    .align-items-end { align-items: flex-end; }
    
    .gap-1 { gap: 8px; }
    .gap-2 { gap: 16px; }
    .gap-3 { gap: 24px; }
    
    .w-100 { width: 100%; }
    .h-100 { height: 100%; }
    
    .text-muted { color: #64748b; }
    .text-primary { color: #2563eb; }
    .text-success { color: #10b981; }
    .text-warning { color: #f59e0b; }
    .text-danger { color: #ef4444; }
    
    .fw-bold { font-weight: 600; }
    .fw-normal { font-weight: 400; }
    .fw-light { font-weight: 300; }
    
    .rounded { border-radius: 8px; }
    .rounded-lg { border-radius: 12px; }
    .rounded-circle { border-radius: 50%; }
    
    .shadow-sm { box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    .shadow { box-shadow: 0 4px 12px rgba(0,0,0,0.12); }
    .shadow-lg { box-shadow: 0 8px 20px rgba(0,0,0,0.16); }
  </style>
</head>