<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<nav class="sidebar">
  <div class="menu-group">
    <div class="group-title">
      <span>메인</span>
    </div>
    
    <a href="/dashboard" class="menu-item">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z"/>
      </svg>
      <span>대시보드</span>
    </a>
    
    <a href="/notice/list" class="menu-item">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
      </svg>
      <span>공지사항</span>
    </a>
  </div>

  <div class="menu-separator"></div>

  <c:if test="${sessionScope.loginUser != null and (sessionScope.loginUser.role == 'ADMIN' or sessionScope.loginUser.role == 'STUDENT' or sessionScope.loginUser.role == 'PROFESSOR')}">
    <div class="menu-group">
      <div class="group-title">
        <span>협업</span>
      </div>
      
      <!-- 팀 커뮤니케이션 -->
      <c:if test="${sessionScope.loginUser.role == 'ADMIN' or sessionScope.loginUser.role == 'STUDENT' or sessionScope.loginUser.role == 'PROFESSOR'}">
        <a href="/chat" class="menu-item">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
            <path d="M20 2H4c-1.1 0-1.99.9-1.99 2L2 22l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12H6v-2h12v2zm0-3H6V9h12v2zm0-3H6V6h12v2z"/>
          </svg>
          <span>팀 커뮤니케이션</span>
        </a>
      </c:if>
      
      <!-- 프로젝트 관리 -->
      <c:if test="${sessionScope.loginUser.role == 'STUDENT' or sessionScope.loginUser.role == 'PROFESSOR'}">
        <a href="/projects" class="menu-item">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
            <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>
          </svg>
          <span>프로젝트 관리</span>
        </a>
      </c:if>
    </div>
    <div class="menu-separator"></div>
  </c:if>

  <div class="menu-group">
    <div class="group-title">
      <span>리소스</span>
    </div>
    
    <div class="menu-item" style="cursor: pointer;" onclick="toggleSubmenu(this)">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M20.54 5.23l-1.39-1.68C18.88 3.21 18.47 3 18 3H6c-.47 0-.88.21-1.16.55L3.46 5.23C3.17 5.57 3 6.02 3 6.5V19c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V6.5c0-.48-.17-.93-.46-1.27zM12 17.5L6.5 12H10v-2h4v2h3.5L12 17.5zM5.12 5l.81-1h12l.94 1H5.12z"/>
      </svg>
      <span>아카이브</span>
      <svg class="submenu-arrow" style="width: 12px; height: 12px; margin-left: auto; fill: #64748b; transition: transform 0.2s ease;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M7 10l5 5 5-5z"/>
      </svg>
    </div>

    <c:if test="${sessionScope.loginUser != null}">
      <ul class="submenu">
        <li>
          <a href="${pageContext.request.contextPath}/archive/list">전체 아카이브</a>
        </li>

        <c:if test="${sessionScope.loginUser.role == 'STUDENT'}">
          <li>
            <a href="${pageContext.request.contextPath}/archive/my">내 아카이브</a>
          </li>
        </c:if>
      </ul>
    </c:if>
    
    <div class="menu-item" style="cursor: pointer;" onclick="toggleSubmenu(this)">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M20 18c1.1 0 1.99-.9 1.99-2L22 6c0-1.1-.9-2-2-2H4c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2H0v2h24v-2h-4zM4 6h16v10H4V6z"/>
      </svg>
      <span>기자재 정보</span>
      <svg class="submenu-arrow" style="width: 12px; height: 12px; margin-left: auto; fill: #64748b; transition: transform 0.2s ease;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M7 10l5 5 5-5z"/>
      </svg>
    </div>
    
    <!-- 기자재 하위 메뉴 (모든 사용자용) -->
    <c:if test="${sessionScope.loginUser != null}">
      <ul class="submenu">
        <li>
          <a href="${pageContext.request.contextPath}/equipment/list">전체 기자재</a>
        </li>
        <!-- 학생용 추가 메뉴 -->
        <c:if test="${sessionScope.loginUser.role == 'STUDENT'}">
          <li>
            <a href="${pageContext.request.contextPath}/reservation/my">나의 대여 내역</a>
          </li>
          <li>
            <a href="${pageContext.request.contextPath}/special-rental/request">특별 대여 신청</a>
          </li>
        </c:if>
      </ul>
    </c:if>
  </div>

  <div class="menu-separator"></div>

  <div class="menu-group">
    <div class="group-title">
      <span>지원</span>
    </div>
    
    <a href="/inquiry/list" class="menu-item">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M11 18h2v-2h-2v2zm1-16C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm0-14c-2.21 0-4 1.79-4 4h2c0-1.1.9-2 2-2s2 .9 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5 0-2.21-1.79-4-4-4z"/>
      </svg>
      <span>문의사항</span>
    </a>
    
    <!-- AI 기술지원 메뉴 (ADMIN 제외한 모든 역할) -->
    <c:if test="${sessionScope.loginUser != null and sessionScope.loginUser.role != 'ADMIN'}">
      <a href="${pageContext.request.contextPath}/ai/chatbot" class="menu-item">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-3 12l-2-2v2H9v-2l-2 2-2-2 4-4 4 4-2 2z"/>
        </svg>
        <span>AI 기술지원</span>
      </a>
    </c:if>
  </div>

  <!-- 관리자 메뉴 -->
  <c:if test="${not empty sessionScope.loginUser and sessionScope.loginUser.role eq 'ADMIN'}">
    <div class="menu-separator"></div>
    
    <div class="menu-group">
      <div class="group-title">
        <span>관리</span>
      </div>
      
      <div class="menu-item" style="cursor: pointer;" onclick="toggleSubmenu(this)">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <path d="M19.14,12.94c0.04-0.3,0.06-0.61,0.06-0.94c0-0.32-0.02-0.64-0.07-0.94l2.03-1.58c0.18-0.14,0.23-0.41,0.12-0.61 l-1.92-3.32c-0.12-0.22-0.37-0.29-0.59-0.22l-2.39,0.96c-0.5-0.38-1.03-0.7-1.62-0.94L14.4,2.81c-0.04-0.24-0.24-0.41-0.48-0.41 h-3.84c-0.24,0-0.43,0.17-0.47,0.41L9.25,5.35C8.66,5.59,8.12,5.92,7.63,6.29L5.24,5.33c-0.22-0.08-0.47,0-0.59,0.22L2.74,8.87 C2.62,9.08,2.66,9.34,2.86,9.48l2.03,1.58C4.84,11.36,4.8,11.69,4.8,12s0.02,0.64,0.07,0.94l-2.03,1.58 c-0.18,0.14-0.23,0.41-0.12,0.61l1.92,3.32c0.12,0.22,0.37,0.29,0.59,0.22l2.39-0.96c0.5,0.38,1.03,0.7,1.62,0.94l0.36,2.54 c0.05,0.24,0.24,0.41,0.48,0.41h3.84c0.24,0,0.44-0.17,0.47-0.41l0.36-2.54c0.59-0.24,1.13-0.56,1.62-0.94l2.39,0.96 c0.22,0.08,0.47,0,0.59-0.22l1.92-3.32c0.12-0.22,0.07-0.47-0.12-0.61L19.14,12.94z M12,15.6c-1.98,0-3.6-1.62-3.6-3.6 s1.62-3.6,3.6-3.6s3.6,1.62,3.6,3.6S13.98,15.6,12,15.6z"/>
        </svg>
        <span>시스템 관리</span>
        <svg class="submenu-arrow" style="width: 12px; height: 12px; margin-left: auto; fill: #64748b; transition: transform 0.2s ease;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
          <path d="M7 10l5 5 5-5z"/>
        </svg>
      </div>
      
      <ul class="submenu">
        <c:if test="${sessionScope.loginUser.role eq 'ADMIN'}">
          <li>
            <a href="${pageContext.request.contextPath}/admin/users">사용자 관리</a>
          </li>
        </c:if>
        <c:if test="${sessionScope.loginUser.role eq 'ADMIN' or sessionScope.loginUser.role eq 'ASSISTANT'}">
          <li>
            <a href="${pageContext.request.contextPath}/equipmentrental/admin/pending">신청 현황 관리</a>
          </li>
        </c:if>
        <c:if test="${sessionScope.loginUser.role eq 'ADMIN'}">
          <li>
            <a href="${pageContext.request.contextPath}/repair/admin/list">수리 요청 관리</a>
          </li>
        </c:if>
        <c:if test="${sessionScope.loginUser.role eq 'ADMIN' or sessionScope.loginUser.role eq 'ASSISTANT'}">
          <li>
            <a href="${pageContext.request.contextPath}/special-rental/admin/list">특별 대여 관리</a>
          </li>
        </c:if>
        <li>
          <a href="${pageContext.request.contextPath}/archive/admin/pending">아카이브 승인</a>
        </li>
      </ul>
      
      <c:if test="${sessionScope.loginUser.role eq 'ADMIN'}">
        <div class="menu-item" style="cursor: pointer;" onclick="toggleSubmenu(this)">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
            <path d="M9 17H7v-7h2v7zm4 0h-2V7h2v10zm4 0h-2v-4h2v4zm2.5 2.25l1.41-1.41L15.5 12.5 13 15l-3.5-3.5-4.5 4.5 1.41 1.41L10 13.91l3.5 3.5 2-2z"/>
          </svg>
          <span>로그 & 통계</span>
          <svg class="submenu-arrow" style="width: 12px; height: 12px; margin-left: auto; fill: #64748b; transition: transform 0.2s ease;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
            <path d="M7 10l5 5 5-5z"/>
          </svg>
        </div>
      
        <ul class="submenu">
          <li>
            <a href="${pageContext.request.contextPath}/admin/logs/list">관리자 활동 로그</a>
          </li>
          <li>
            <a href="${pageContext.request.contextPath}/admin/logs/stats">관리자 통계</a>
          </li>
          <li>
            <a href="${pageContext.request.contextPath}/admin/logs/my-activity">내 활동 로그</a>
          </li>
          <li>
            <a href="${pageContext.request.contextPath}/admin/user-logs/list">사용자 접속 로그</a>
          </li>
          <li>
            <a href="${pageContext.request.contextPath}/admin/user-logs/stats">접속 통계</a>
          </li>
        </ul>
      </c:if>
    </div>
  </c:if>
</nav>

<script>
// 서브메뉴 토글 함수
function toggleSubmenu(menuItem) {
  const submenu = menuItem.nextElementSibling;
  if (submenu && submenu.classList.contains('submenu')) {
    submenu.classList.toggle('collapsed');
    menuItem.classList.toggle('expanded');
  }
}

// 페이지 로드 시 현재 페이지에 해당하는 메뉴 활성화
document.addEventListener('DOMContentLoaded', function() {
  const currentPath = window.location.pathname;
  const contextPath = '${pageContext.request.contextPath}';
  
  // 모든 메뉴 아이템과 서브메뉴 링크 확인
  document.querySelectorAll('.menu-item, .submenu a').forEach(function(item) {
    const href = item.getAttribute('href');
    if (href && currentPath.includes(href.replace(contextPath, ''))) {
      item.classList.add('active');
      
      // 서브메뉴 항목이 활성화된 경우 부모 메뉴도 열기
      const parentSubmenu = item.closest('.submenu');
      if (parentSubmenu) {
        parentSubmenu.classList.remove('collapsed');
        const parentMenuItem = parentSubmenu.previousElementSibling;
        if (parentMenuItem && parentMenuItem.classList.contains('menu-item')) {
          parentMenuItem.classList.add('expanded', 'active');
        }
      }
    }
  });
  
  // 서브메뉴가 있는 메뉴 아이템 중 활성화된 서브메뉴가 있으면 자동으로 열기
  document.querySelectorAll('.submenu').forEach(function(submenu) {
    if (submenu.querySelector('a.active')) {
      submenu.classList.remove('collapsed');
      const menuItem = submenu.previousElementSibling;
      if (menuItem && menuItem.classList.contains('menu-item')) {
        menuItem.classList.add('expanded');
      }
    }
  });
  
  // 모든 서브메뉴에 화살표가 있는 메뉴 아이템은 기본적으로 expanded 상태로 설정
  document.querySelectorAll('.menu-item').forEach(function(menuItem) {
    if (menuItem.querySelector('.submenu-arrow')) {
      menuItem.classList.add('expanded');
    }
  });
});
</script>
