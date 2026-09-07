<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="toolbar">
  <!-- 4this 로고 -->
  <div class="logo-wrapper">
    <div class="logo-icon">
      <svg viewBox="0 0 400 120" xmlns="http://www.w3.org/2000/svg">
        <!-- 왼쪽 세로선 -->
        <rect x="20" y="20" width="4" height="80" fill="#2563eb"/>
        
        <!-- 4this 텍스트 -->
        <text x="50" y="85" font-family="system-ui, -apple-system, sans-serif" font-size="56" font-weight="700" fill="#1e293b">4this</text>
        
        <!-- 배경 점들 패턴 -->
        <defs>
          <pattern id="dots" x="0" y="0" width="20" height="20" patternUnits="userSpaceOnUse">
            <circle cx="10" cy="10" r="1" fill="#e2e8f0"/>
          </pattern>
        </defs>
        
        <!-- 배경 점들 적용 -->
        <rect x="0" y="0" width="400" height="120" fill="url(#dots)" opacity="0.5"/>
      </svg>
    </div>
  </div>

  <div class="toolbar-right">
    <!-- 알림 아이콘 -->
    <div class="notification-wrapper">
    <div class="icon-wrapper notification" onclick="toggleNotificationMenu(event)">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M12 22C13.1 22 14 21.1 14 20H10C10 21.1 10.9 22 12 22ZM18 16V11C18 7.93 16.36 5.36 13.5 4.68V4C13.5 3.17 12.83 2.5 12 2.5C11.17 2.5 10.5 3.17 10.5 4V4.68C7.63 5.36 6 7.92 6 11V16L4 18V19H20V18L18 16Z" fill="#64748b"/>
      </svg>
      <span class="notification-badge" id="notificationBadge" style="display: none;">0</span>
    </div>
    
    <!-- 알림 드롭다운 메뉴 -->
    <div class="notification-dropdown" id="notificationDropdown">
      <div class="notification-header">
        <h4>알림</h4>
        <button class="mark-all-read-btn" onclick="markAllNotificationsAsRead()">모두 읽음</button>
      </div>
      <div class="notification-list" id="notificationList">
        <div class="notification-loading">
          <i class="fas fa-spinner fa-spin"></i>
          <span>알림을 불러오는 중...</span>
        </div>
      </div>
      <div class="notification-footer">
        <a href="/notifications" class="view-all-link">모든 알림 보기</a>
      </div>
    </div>
  </div>

  <!-- 프로필 드롭다운 -->
  <c:if test="${not empty sessionScope.loginUser}">
    <c:set var="u" value="${sessionScope.loginUser}" />
    <div class="profile-dropdown">
      <div class="profile-card" onclick="toggleProfileMenu(event)">
        <div class="profile-avatar">
          <span class="avatar-text">${fn:substring(u.name, 0, 1)}</span>
        </div>
        <div class="profile-info">
          <div class="profile-name">${u.name}</div>
          <div class="profile-role">
            <c:choose>
              <c:when test="${u.role=='STUDENT'}">학생</c:when>
              <c:when test="${u.role=='PROFESSOR'}">교수</c:when>
              <c:when test="${u.role=='STAFF'}">교직원</c:when>
              <c:when test="${u.role=='ASSISTANT'}">조교</c:when>
              <c:when test="${u.role=='ADMIN'}">관리자</c:when>
            </c:choose>
          </div>
        </div>
        <div class="profile-arrow">
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M4 6L8 10L12 6" stroke="#64748b" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
      </div>

      <!-- 드롭다운 메뉴 -->
      <div class="dropdown-menu">
        <div class="dropdown-profile">
          <div class="dropdown-avatar">
            <span class="dropdown-avatar-text">${fn:substring(u.name, 0, 1)}</span>
          </div>
          <div class="dropdown-info">
            <div class="dropdown-name">${u.name}</div>
            <div class="dropdown-email">${u.email}</div>
          </div>
        </div>
        <ul class="dropdown-list">
          <li><a href="/mypage">계정관리</a></li>
          <li><a href="/help">도움말</a></li>
          <li class="logout"><a href="/auth/logout" onclick="handleLogout(event)">로그아웃</a></li>
        </ul>
      </div>
    </div>
  </c:if>
  </div>
</div>

<style>
/* ── 툴바 기본 스타일 ── */
.toolbar {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 70px;
  display: flex;
  justify-content: space-between;
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

.toolbar-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

/* ── 4this 로고 ── */
.logo-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.logo-icon {
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-icon svg {
  width: 120px;
  height: 36px;
}

/* ── 알림 시스템 ── */
.notification-wrapper {
  position: relative;
}

.icon-wrapper.notification {
  position: relative;
  cursor: pointer;
  padding: 10px;
  border-radius: 10px;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(255, 255, 255, 0.8);
  border: 1px solid rgba(226, 232, 240, 0.5);
}

.icon-wrapper.notification:hover {
  background: rgba(37, 99, 235, 0.1);
  border-color: rgba(37, 99, 235, 0.2);
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(37, 99, 235, 0.15);
}

.icon-wrapper.notification svg {
  width: 22px;
  height: 22px;
}

.icon-wrapper.notification svg path {
  fill: #64748b;
  transition: fill 0.3s ease;
}

.icon-wrapper.notification:hover svg path {
  fill: #2563eb;
}

.notification-badge {
  position: absolute;
  top: 2px;
  right: 2px;
  background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
  color: white;
  border-radius: 10px;
  padding: 2px 6px;
  font-size: 10px;
  font-weight: 700;
  min-width: 18px;
  height: 18px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid #ffffff;
  box-shadow: 0 2px 8px rgba(239, 68, 68, 0.3);
}

/* ── 프로필 카드 ── */
.profile-card {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 14px;
  background: rgba(255, 255, 255, 0.9);
  border: 1px solid rgba(226, 232, 240, 0.6);
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.profile-card:hover {
  background: rgba(255, 255, 255, 0.95);
  border-color: rgba(37, 99, 235, 0.3);
  transform: translateY(-2px);
  box-shadow: 0 12px 40px rgba(0, 0, 0, 0.12);
}

.profile-avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid rgba(255, 255, 255, 0.8);
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);
}

.avatar-text {
  color: white;
  font-size: 13px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.profile-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
}

.profile-name {
  font-size: 13px;
  font-weight: 600;
  color: #1e293b;
  line-height: 1.2;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.profile-role {
  font-size: 11px;
  color: #64748b;
  line-height: 1.2;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  font-weight: 500;
}

.profile-arrow {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  opacity: 0.7;
  transition: transform 0.3s ease;
}

.profile-dropdown.open .profile-arrow {
  transform: rotate(180deg);
}

.profile-arrow svg {
  width: 14px;
  height: 14px;
}

.profile-arrow svg path {
  stroke: #64748b;
}

/* ── 드롭다운 메뉴 ── */
.dropdown-menu {
  position: absolute;
  top: calc(100% + 12px);
  right: 0;
  width: 280px;
  background: rgba(255, 255, 255, 0.95);
  border: 1px solid rgba(226, 232, 240, 0.6);
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  display: none;
  z-index: 1001;
  overflow: hidden;
  backdrop-filter: blur(20px);
}

.profile-dropdown.open .dropdown-menu {
  display: block;
  animation: dropdownFadeIn 0.3s ease-out;
}

@keyframes dropdownFadeIn {
  from {
    opacity: 0;
    transform: translateY(-12px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.dropdown-profile {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px;
  border-bottom: 1px solid rgba(226, 232, 240, 0.6);
  background: rgba(248, 250, 252, 0.8);
}

.dropdown-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  border: 3px solid rgba(255, 255, 255, 0.8);
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);
}

.dropdown-avatar-text {
  color: white;
  font-size: 16px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.dropdown-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  min-width: 0;
}

.dropdown-name {
  font-size: 16px;
  font-weight: 600;
  color: #1e293b;
  line-height: 1.2;
}

.dropdown-email {
  font-size: 13px;
  color: #64748b;
  line-height: 1.2;
  word-break: break-all;
  font-weight: 500;
}

.dropdown-list {
  list-style: none;
  margin: 0;
  padding: 10px 0;
}

.dropdown-list li {
  margin: 0;
}

.dropdown-list li a {
  display: flex;
  align-items: center;
  padding: 12px 18px;
  font-size: 14px;
  color: #374151;
  text-decoration: none;
  transition: all 0.3s ease;
  border: none;
  font-weight: 500;
}

.dropdown-list li a:hover {
  background: rgba(37, 99, 235, 0.08);
  color: #2563eb;
  transform: translateX(4px);
}

.dropdown-list li.logout a {
  color: #ef4444;
  border-top: 1px solid rgba(226, 232, 240, 0.6);
}

.dropdown-list li.logout a:hover {
  background: rgba(239, 68, 68, 0.08);
  color: #dc2626;
}

/* ── 알림 드롭다운 ── */
.notification-dropdown {
  position: absolute;
  top: calc(100% + 12px);
  right: -50px;
  width: 380px;
  background: rgba(255, 255, 255, 0.95);
  border: 1px solid rgba(226, 232, 240, 0.6);
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  display: none;
  z-index: 1001;
  max-height: 500px;
  overflow: hidden;
  backdrop-filter: blur(20px);
}

.notification-wrapper.open .notification-dropdown {
  display: block;
  animation: dropdownFadeIn 0.3s ease-out;
}

.notification-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid rgba(226, 232, 240, 0.6);
  background: rgba(248, 250, 252, 0.8);
}

.notification-header h4 {
  margin: 0;
  font-size: 17px;
  font-weight: 600;
  color: #1e293b;
}

.mark-all-read-btn {
  background: none;
  border: none;
  color: #2563eb;
  font-size: 13px;
  cursor: pointer;
  padding: 8px 14px;
  border-radius: 8px;
  transition: all 0.3s ease;
  font-weight: 500;
}

.mark-all-read-btn:hover {
  background: rgba(37, 99, 235, 0.1);
  color: #1d4ed8;
}

.notification-list {
  max-height: 340px;
  overflow-y: auto;
}

.notification-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 50px 24px;
  color: #64748b;
  gap: 14px;
}

.notification-item {
  display: flex;
  align-items: flex-start;
  padding: 18px 24px;
  border-bottom: 1px solid rgba(226, 232, 240, 0.4);
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  gap: 14px;
}

.notification-item:hover {
  background: rgba(248, 250, 252, 0.8);
  transform: translateX(4px);
}

.notification-item.unread {
  background: rgba(255, 243, 205, 0.6);
  border-left: 4px solid #f59e0b;
}

.notification-item:last-child {
  border-bottom: none;
}

.notification-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  color: white;
  flex-shrink: 0;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.notification-icon.chat {
  background: linear-gradient(135deg, #10b981, #059669);
}

.notification-icon.notice {
  background: linear-gradient(135deg, #2563eb, #1d4ed8);
}

.notification-icon.inquiry {
  background: linear-gradient(135deg, #06b6d4, #0891b2);
}

.notification-icon.equipment {
  background: linear-gradient(135deg, #f59e0b, #d97706);
}

.notification-content {
  flex: 1;
  min-width: 0;
}

.notification-title {
  font-size: 14px;
  font-weight: 600;
  color: #1e293b;
  margin-bottom: 6px;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.notification-message {
  font-size: 13px;
  color: #64748b;
  margin-bottom: 8px;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.notification-time {
  font-size: 12px;
  color: #94a3b8;
  font-weight: 500;
}

.notification-unread-dot {
  position: absolute;
  top: 18px;
  right: 20px;
  width: 10px;
  height: 10px;
  background: #2563eb;
  border-radius: 50%;
  box-shadow: 0 2px 6px rgba(37, 99, 235, 0.3);
}

.notification-footer {
  padding: 16px 24px;
  border-top: 1px solid rgba(226, 232, 240, 0.6);
  background: rgba(248, 250, 252, 0.8);
  text-align: center;
}

.view-all-link {
  color: #2563eb;
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
  transition: color 0.3s ease;
}

.view-all-link:hover {
  color: #1d4ed8;
  text-decoration: underline;
}

.notification-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 70px 24px;
  color: #64748b;
  text-align: center;
}

.notification-empty i {
  font-size: 52px;
  margin-bottom: 20px;
  opacity: 0.4;
}

.notification-empty p {
  margin: 0;
  font-size: 14px;
  opacity: 0.8;
  font-weight: 500;
}

/* ── 반응형 디자인 ── */
@media (max-width: 768px) {
  .toolbar {
    padding: 0 20px;
    gap: 16px;
    height: 64px;
  }
  
  .profile-card {
    padding: 6px 12px;
    gap: 8px;
  }
  
  .profile-avatar {
    width: 28px;
    height: 28px;
  }
  
  .avatar-text {
    font-size: 12px;
  }
  
  .profile-name {
    font-size: 12px;
  }
  
  .profile-role {
    font-size: 10px;
  }
  
  .dropdown-menu {
    width: 260px;
  }
  
  .notification-dropdown {
    width: 340px;
    right: -80px;
  }
  
  .logo-icon svg {
    width: 100px;
    height: 30px;
  }
}

/* ── 스크롤바 스타일 ── */
.notification-list::-webkit-scrollbar {
  width: 6px;
}

.notification-list::-webkit-scrollbar-track {
  background: rgba(226, 232, 240, 0.3);
}

.notification-list::-webkit-scrollbar-thumb {
  background: rgba(148, 163, 184, 0.5);
  border-radius: 3px;
}

.notification-list::-webkit-scrollbar-thumb:hover {
  background: rgba(100, 116, 139, 0.7);
}
</style>

<script>
// 메뉴 토글 함수들
function toggleProfileMenu(e) {
  e.stopPropagation();
  const profileDropdown = document.querySelector('.profile-dropdown');
  const notificationWrapper = document.querySelector('.notification-wrapper');
  
  // 알림 드롭다운 닫기
  notificationWrapper.classList.remove('open');
  
  // 프로필 드롭다운 토글
  profileDropdown.classList.toggle('open');
}

function toggleNotificationMenu(e) {
  e.stopPropagation();
  const notificationWrapper = document.querySelector('.notification-wrapper');
  const profileDropdown = document.querySelector('.profile-dropdown');
  
  // 프로필 드롭다운 닫기
  profileDropdown.classList.remove('open');
  
  // 알림 드롭다운 토글
  const isOpen = notificationWrapper.classList.contains('open');
  
  if (!isOpen) {
    notificationWrapper.classList.add('open');
    loadNotifications();
  } else {
    notificationWrapper.classList.remove('open');
  }
}

// 문서 클릭 시 드롭다운 닫기
document.addEventListener('click', function(e) {
  if (!e.target.closest('.notification-wrapper')) {
    document.querySelector('.notification-wrapper').classList.remove('open');
  }
  if (!e.target.closest('.profile-dropdown')) {
    document.querySelector('.profile-dropdown').classList.remove('open');
  }
});

// 로그아웃 처리
function handleLogout(event) {
  fetch('/chat/user/offline', {
    method: 'POST'
  }).catch(error => {
    console.log('오프라인 상태 설정 실패:', error);
  });
  
  return true;
}

// 알림 시스템 초기화
document.addEventListener('DOMContentLoaded', function() {
  loadNotifications();
  setInterval(loadNotifications, 30000);
});

// 알림 로드
function loadNotifications() {
  fetch('/notifications/list')
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        updateNotificationBadge(data.unreadCount);
        renderNotifications(data.notifications);
      }
    })
    .catch(error => {
      console.error('알림 로드 실패:', error);
      renderNotificationsError();
    });
}

// 알림 배지 업데이트
function updateNotificationBadge(count) {
  const badge = document.getElementById('notificationBadge');
  if (count > 0) {
    badge.textContent = count > 99 ? '99+' : count;
    badge.style.display = 'flex';
  } else {
    badge.style.display = 'none';
  }
}

// 알림 목록 렌더링
function renderNotifications(notifications) {
  const listContainer = document.getElementById('notificationList');
  
  if (!notifications || notifications.length === 0) {
    listContainer.innerHTML = 
      '<div class="notification-empty">' +
        '<i class="fas fa-bell-slash"></i>' +
        '<p>새로운 알림이 없습니다</p>' +
      '</div>';
    return;
  }
  
  let html = '';
  notifications.forEach(notification => {
    html += renderNotificationItem(notification);
  });
  
  listContainer.innerHTML = html;
}

// 개별 알림 아이템 렌더링
function renderNotificationItem(notification) {
  const iconClass = getNotificationIconClass(notification.type);
  const timeAgo = getTimeAgo(notification.createdAt);
  const unreadClass = notification.isRead ? '' : 'unread';
  const unreadDot = notification.isRead ? '' : '<div class="notification-unread-dot"></div>';
  const iconHtml = getNotificationIcon(notification.type);
  const targetUrl = notification.targetUrl || '';
  
  return '<div class="notification-item ' + unreadClass + '" onclick="handleNotificationClick(' + notification.id + ', \'' + notification.type + '\', \'' + targetUrl + '\')">' +
           '<div class="notification-icon ' + iconClass + '">' +
             '<i class="' + iconHtml + '"></i>' +
           '</div>' +
           '<div class="notification-content">' +
             '<div class="notification-title">' + notification.title + '</div>' +
             '<div class="notification-message">' + notification.message + '</div>' +
             '<div class="notification-time">' + timeAgo + '</div>' +
           '</div>' +
           unreadDot +
         '</div>';
}

// 알림 타입별 아이콘 클래스
function getNotificationIconClass(type) {
  switch(type) {
    case 'CHAT': return 'chat';
    case 'NOTICE': return 'notice';
    case 'INQUIRY': return 'inquiry';
    case 'EQUIPMENT': return 'equipment';
    default: return 'notice';
  }
}

// 알림 타입별 아이콘
function getNotificationIcon(type) {
  switch(type) {
    case 'CHAT': return 'fas fa-comments';
    case 'NOTICE': return 'fas fa-bullhorn';
    case 'INQUIRY': return 'fas fa-question-circle';
    case 'EQUIPMENT': return 'fas fa-tools';
    default: return 'fas fa-bell';
  }
}

// 시간 차이 계산
function getTimeAgo(dateString) {
  if (!dateString) {
    return '알 수 없음';
  }
  
  const now = new Date();
  let date;
  
  if (Array.isArray(dateString)) {
    const [year, month, day, hour, minute, second] = dateString;
    date = new Date(year, month - 1, day, hour || 0, minute || 0, second || 0);
  } else if (typeof dateString === 'string' && dateString.includes('T')) {
    const cleanDateString = dateString.replace('T', ' ');
    date = new Date(cleanDateString);
    
    if (isNaN(date.getTime())) {
      const parts = dateString.split('T');
      if (parts.length === 2) {
        const datePart = parts[0];
        const timePart = parts[1];
        
        const [year, month, day] = datePart.split('-');
        const [hour, minute, second] = timePart.split(':');
        
        date = new Date(
          parseInt(year), 
          parseInt(month) - 1, 
          parseInt(day), 
          parseInt(hour), 
          parseInt(minute), 
          parseInt(second) || 0
        );
      }
    }
  } else {
    date = new Date(dateString);
  }
  
  if (isNaN(date.getTime())) {
    console.warn('날짜 파싱 실패:', dateString);
    return '알 수 없음';
  }
  
  const diffInSeconds = Math.floor((now - date) / 1000);
  
  if (diffInSeconds < 0) {
    return '방금 전';
  }
  
  if (diffInSeconds < 60) return '방금 전';
  if (diffInSeconds < 3600) return Math.floor(diffInSeconds / 60) + '분 전';
  if (diffInSeconds < 86400) return Math.floor(diffInSeconds / 3600) + '시간 전';
  if (diffInSeconds < 2592000) return Math.floor(diffInSeconds / 86400) + '일 전';
  
  const months = Math.floor(diffInSeconds / 2592000);
  if (months > 12) {
    const years = Math.floor(months / 12);
    return years + '년 전';
  }
  
  return months + '개월 전';
}

// 알림 클릭 처리
function handleNotificationClick(notificationId, type, targetUrl) {
  markNotificationAsRead(notificationId);
  document.querySelector('.notification-wrapper').classList.remove('open');
  
  if (type === 'CHAT' && targetUrl) {
    if (window.location.pathname === '/chat' || window.location.pathname.startsWith('/chat/')) {
      const roomIdMatch = targetUrl.match(/\/chat\/room\/(\d+)/);
      if (roomIdMatch) {
        const roomId = roomIdMatch[1];
        if (typeof showChatRoom === 'function') {
          showChatRoom(roomId);
        } else {
          const welcomeMessage = document.getElementById('chatWelcome');
          const chatFrame = document.getElementById('chatFrame');
          if (welcomeMessage && chatFrame) {
            welcomeMessage.style.display = 'none';
            chatFrame.src = '/chat/room/' + roomId;
            chatFrame.style.display = 'block';
          } else {
            window.location.href = targetUrl;
          }
        }
        return;
      }
    }
    window.location.href = '/chat?openRoom=' + (targetUrl.match(/\/chat\/room\/(\d+)/) ? targetUrl.match(/\/chat\/room\/(\d+)/)[1] : '');
    return;
  }
  
  if (targetUrl) {
    window.location.href = targetUrl;
  } else {
    switch(type) {
      case 'CHAT':
        window.location.href = '/chat';
        break;
      case 'NOTICE':
        window.location.href = '/notice';
        break;
      case 'INQUIRY':
        window.location.href = '/inquiry';
        break;
      case 'EQUIPMENT':
        window.location.href = '/equipment';
        break;
      default:
        window.location.href = '/dashboard';
    }
  }
}

// 알림을 읽음으로 표시
function markNotificationAsRead(notificationId) {
  fetch('/notifications/' + notificationId + '/read', {
    method: 'POST'
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      loadNotifications();
    }
  })
  .catch(error => {
    console.error('알림 읽음 처리 실패:', error);
  });
}

// 모든 알림을 읽음으로 표시
function markAllNotificationsAsRead() {
  fetch('/notifications/mark-all-read', {
    method: 'POST'
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      loadNotifications();
    }
  })
  .catch(error => {
    console.error('모든 알림 읽음 처리 실패:', error);
  });
}

// 알림 로드 오류 처리
function renderNotificationsError() {
  const listContainer = document.getElementById('notificationList');
  listContainer.innerHTML = 
    '<div class="notification-empty">' +
      '<i class="fas fa-exclamation-triangle"></i>' +
      '<p>알림을 불러올 수 없습니다</p>' +
    '</div>';
}
</script>