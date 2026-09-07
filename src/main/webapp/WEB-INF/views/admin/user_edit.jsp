<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<body>
  <!-- 사이드바 -->
  <div class="sidebar">
    <%@ include file="../layout/sidebar.jsp" %>
  </div>

  <!-- 메인 콘텐츠 -->
  <div class="content">
    <!-- 헤더 -->
    <%@ include file="../layout/header.jsp" %>
    
    <!-- 본문 영역 -->
    <div class="main-body">
      <h1 class="page-title">사용자 정보 수정</h1>
      
      <div class="modern-card">
        <form action="${pageContext.request.contextPath}/admin/user/edit/${user.id}" method="post">
          <!-- 기본 정보 -->
          <div class="form-section">
            <h3>기본 정보</h3>
            <div class="form-grid">
              <div class="form-group">
                <label for="name">이름 *</label>
                <input type="text" id="name" name="name" class="form-control" value="${user.name}" required>
              </div>
              
              <div class="form-group">
                <label for="email">이메일 *</label>
                <input type="email" id="email" name="email" class="form-control" value="${user.email}" required>
              </div>
              
              <div class="form-group">
                <label for="phone">전화번호</label>
                <input type="tel" id="phone" name="phone" class="form-control" value="${user.phone}">
              </div>
              
              <div class="form-group">
                <label for="studentId">학번/사번</label>
                <input type="text" id="studentId" name="studentId" class="form-control" value="${user.studentId}">
              </div>
            </div>
          </div>

          <!-- 역할 및 상태 -->
          <div class="form-section">
            <h3>역할 및 상태</h3>
            <div class="form-grid">
              <div class="form-group">
                <label for="role">역할 *</label>
                <select id="role" name="role" class="form-control" required>
                  <option value="">선택하세요</option>
                  <option value="STUDENT" ${user.role == 'STUDENT' ? 'selected' : ''}>학생</option>
                  <option value="PROFESSOR" ${user.role == 'PROFESSOR' ? 'selected' : ''}>교수</option>
                  <option value="STAFF" ${user.role == 'STAFF' ? 'selected' : ''}>직원</option>
                  <option value="ADMIN" ${user.role == 'ADMIN' ? 'selected' : ''}>관리자</option>
                </select>
              </div>
              
              <div class="form-group">
                <label for="status">상태 *</label>
                <select id="status" name="status" class="form-control" required>
                  <option value="ACTIVE" ${user.status == 'ACTIVE' ? 'selected' : ''}>활성</option>
                  <option value="INACTIVE" ${user.status == 'INACTIVE' ? 'selected' : ''}>비활성</option>
                  <option value="SUSPENDED" ${user.status == 'SUSPENDED' ? 'selected' : ''}>정지</option>
                </select>
              </div>
              
              <div class="form-group">
                <label for="department">학과/부서</label>
                <input type="text" id="department" name="department" class="form-control" value="${user.department}">
              </div>
              
              <div class="form-group">
                <label for="position">직책</label>
                <input type="text" id="position" name="position" class="form-control" value="${user.position}">
              </div>
            </div>
          </div>

          <!-- 계정 정보 -->
          <div class="form-section">
            <h3>계정 정보</h3>
            <div class="form-grid">
              <div class="form-group">
                <label for="username">사용자명</label>
                <input type="text" id="username" name="username" class="form-control" value="${user.username}" readonly>
                <small class="form-text">사용자명은 변경할 수 없습니다.</small>
              </div>
              
              <div class="form-group">
                <label for="newPassword">새 비밀번호</label>
                <input type="password" id="newPassword" name="newPassword" class="form-control">
                <small class="form-text">비밀번호를 변경하지 않으려면 비워두세요.</small>
              </div>
              
              <div class="form-group">
                <label for="confirmPassword">비밀번호 확인</label>
                <input type="password" id="confirmPassword" name="confirmPassword" class="form-control">
              </div>
              
              <div class="form-group">
                <label>가입일</label>
                <input type="text" class="form-control" 
                       value="<fmt:formatDate value='${user.createdAt}' pattern='yyyy-MM-dd HH:mm'/>" readonly>
              </div>
            </div>
          </div>

          <!-- 추가 정보 -->
          <div class="form-section">
            <h3>추가 정보</h3>
            <div class="form-grid">
              <div class="form-group">
                <label for="address">주소</label>
                <input type="text" id="address" name="address" class="form-control" value="${user.address}">
              </div>
              
              <div class="form-group">
                <label for="birthDate">생년월일</label>
                <input type="date" id="birthDate" name="birthDate" class="form-control" 
                       value="<fmt:formatDate value='${user.birthDate}' pattern='yyyy-MM-dd'/>">
              </div>
              
              <div class="form-group">
                <label for="gender">성별</label>
                <select id="gender" name="gender" class="form-control">
                  <option value="">선택하세요</option>
                  <option value="M" ${user.gender == 'M' ? 'selected' : ''}>남성</option>
                  <option value="F" ${user.gender == 'F' ? 'selected' : ''}>여성</option>
                </select>
              </div>
              
              <div class="form-group">
                <label>마지막 로그인</label>
                <input type="text" class="form-control" 
                       value="<fmt:formatDate value='${user.lastLoginAt}' pattern='yyyy-MM-dd HH:mm'/>" readonly>
              </div>
            </div>
          </div>

          <!-- 권한 설정 (관리자 전용) -->
          <c:if test="${sessionScope.role == 'ADMIN'}">
            <div class="form-section">
              <h3>권한 설정</h3>
              <div class="permission-grid">
                <div class="permission-group">
                  <h4>시스템 권한</h4>
                  <div class="permission-item">
                    <label>
                      <input type="checkbox" name="permissions" value="USER_MANAGE" 
                             ${user.permissions.contains('USER_MANAGE') ? 'checked' : ''}>
                      사용자 관리
                    </label>
                  </div>
                  <div class="permission-item">
                    <label>
                      <input type="checkbox" name="permissions" value="EQUIPMENT_MANAGE" 
                             ${user.permissions.contains('EQUIPMENT_MANAGE') ? 'checked' : ''}>
                      기자재 관리
                    </label>
                  </div>
                  <div class="permission-item">
                    <label>
                      <input type="checkbox" name="permissions" value="RENTAL_MANAGE" 
                             ${user.permissions.contains('RENTAL_MANAGE') ? 'checked' : ''}>
                      대여 관리
                    </label>
                  </div>
                </div>
                
                <div class="permission-group">
                  <h4>콘텐츠 권한</h4>
                  <div class="permission-item">
                    <label>
                      <input type="checkbox" name="permissions" value="NOTICE_MANAGE" 
                             ${user.permissions.contains('NOTICE_MANAGE') ? 'checked' : ''}>
                      공지사항 관리
                    </label>
                  </div>
                  <div class="permission-item">
                    <label>
                      <input type="checkbox" name="permissions" value="ARCHIVE_MANAGE" 
                             ${user.permissions.contains('ARCHIVE_MANAGE') ? 'checked' : ''}>
                      아카이브 관리
                    </label>
                  </div>
                  <div class="permission-item">
                    <label>
                      <input type="checkbox" name="permissions" value="INQUIRY_MANAGE" 
                             ${user.permissions.contains('INQUIRY_MANAGE') ? 'checked' : ''}>
                      문의사항 관리
                    </label>
                  </div>
                </div>
              </div>
            </div>
          </c:if>

          <!-- 메모 -->
          <div class="form-section">
            <h3>관리자 메모</h3>
            <div class="form-group">
              <label for="adminNote">메모</label>
              <textarea id="adminNote" name="adminNote" class="form-control" rows="4" 
                        placeholder="관리자 전용 메모를 입력하세요">${user.adminNote}</textarea>
            </div>
          </div>

          <!-- 버튼 -->
          <div class="form-actions">
            <button type="submit" class="btn btn-primary">저장</button>
            <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">취소</a>
            <c:if test="${user.status == 'ACTIVE'}">
              <button type="button" onclick="suspendUser()" class="btn btn-danger">계정 정지</button>
            </c:if>
            <c:if test="${user.status == 'SUSPENDED'}">
              <button type="button" onclick="activateUser()" class="btn btn-success">계정 활성화</button>
            </c:if>
          </div>
        </form>
      </div>
    </div>

    <!-- 푸터 -->
    <%@ include file="../layout/footer.jsp" %>
  </div>

  <!-- 스크립트 -->
  <%@ include file="../layout/scripts.jsp" %>

  <style>
    /* 폼 섹션 */
    .form-section {
      margin-bottom: 32px;
      padding-bottom: 24px;
      border-bottom: 1px solid #e5e7eb;
    }

    .form-section:last-of-type {
      border-bottom: none;
    }

    .form-section h3 {
      font-size: 1.25rem;
      font-weight: 600;
      color: #111827;
      margin: 0 0 20px 0;
    }

    /* 폼 그리드 */
    .form-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 20px;
    }

    .form-group {
      display: flex;
      flex-direction: column;
    }

    .form-group label {
      font-weight: 500;
      color: #374151;
      margin-bottom: 6px;
      font-size: 14px;
    }

    .form-text {
      font-size: 12px;
      color: #6b7280;
      margin-top: 4px;
    }

    /* 읽기 전용 입력 */
    .form-control[readonly] {
      background-color: #f9fafb;
      color: #6b7280;
      cursor: not-allowed;
    }

    /* 권한 설정 */
    .permission-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 24px;
    }

    .permission-group {
      background: #f8f9fa;
      padding: 20px;
      border-radius: 12px;
      border: 1px solid #e5e7eb;
    }

    .permission-group h4 {
      font-size: 1rem;
      font-weight: 600;
      color: #111827;
      margin: 0 0 16px 0;
    }

    .permission-item {
      margin-bottom: 12px;
    }

    .permission-item label {
      display: flex;
      align-items: center;
      gap: 8px;
      cursor: pointer;
      font-weight: 400;
      color: #374151;
    }

    .permission-item input[type="checkbox"] {
      width: 16px;
      height: 16px;
      margin: 0;
    }

    /* 폼 액션 */
    .form-actions {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
      margin-top: 32px;
      padding-top: 24px;
      border-top: 1px solid #e5e7eb;
    }

    .btn-success {
      background-color: #10b981;
      color: white;
    }

    .btn-success:hover {
      background-color: #059669;
    }

    .btn-danger {
      background-color: #ef4444;
      color: white;
    }

    .btn-danger:hover {
      background-color: #dc2626;
    }

    /* 반응형 디자인 */
    @media (max-width: 768px) {
      .form-grid {
        grid-template-columns: 1fr;
      }
      
      .permission-grid {
        grid-template-columns: 1fr;
      }
      
      .form-actions {
        flex-direction: column;
      }
      
      .form-actions .btn {
        width: 100%;
      }
    }
  </style>

  <script>
    // 비밀번호 확인 검증
    document.getElementById('confirmPassword').addEventListener('input', function() {
      const password = document.getElementById('newPassword').value;
      const confirmPassword = this.value;
      
      if (password && confirmPassword && password !== confirmPassword) {
        this.setCustomValidity('비밀번호가 일치하지 않습니다.');
      } else {
        this.setCustomValidity('');
      }
    });

    // 폼 제출 시 유효성 검사
    document.querySelector('form').addEventListener('submit', function(e) {
      const password = document.getElementById('newPassword').value;
      const confirmPassword = document.getElementById('confirmPassword').value;
      
      if (password && password !== confirmPassword) {
        e.preventDefault();
        alert('비밀번호가 일치하지 않습니다.');
        return false;
      }
    });

    // 계정 정지
    function suspendUser() {
      if (confirm('이 사용자의 계정을 정지하시겠습니까?')) {
        document.getElementById('status').value = 'SUSPENDED';
        document.querySelector('form').submit();
      }
    }

    // 계정 활성화
    function activateUser() {
      if (confirm('이 사용자의 계정을 활성화하시겠습니까?')) {
        document.getElementById('status').value = 'ACTIVE';
        document.querySelector('form').submit();
      }
    }
  </script>
</body>
</html>
                                