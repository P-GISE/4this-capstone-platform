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
      <h1 class="page-title">사용자 관리</h1>
      
      <div class="modern-card">
        <!-- 검색 및 필터 영역 -->
        <form action="${pageContext.request.contextPath}/admin/users" method="get" class="search-filter">
          <div class="filter-row">
            <div class="filter-group">
              <label>검색어</label>
              <input type="text" name="keyword" value="${param.keyword}" placeholder="이름, 학번, 이메일 검색" class="form-control">
            </div>
            
            <div class="filter-group">
              <label>역할</label>
              <select name="role" class="form-control">
                <option value="">전체</option>
                <option value="STUDENT" ${param.role == 'STUDENT' ? 'selected' : ''}>학생</option>
                <option value="PROFESSOR" ${param.role == 'PROFESSOR' ? 'selected' : ''}>교수</option>
                <option value="STAFF" ${param.role == 'STAFF' ? 'selected' : ''}>직원</option>
                <option value="ADMIN" ${param.role == 'ADMIN' ? 'selected' : ''}>관리자</option>
              </select>
            </div>
            
            <div class="filter-group">
              <label>상태</label>
              <select name="status" class="form-control">
                <option value="">전체</option>
                <option value="ACTIVE" ${param.status == 'ACTIVE' ? 'selected' : ''}>활성</option>
                <option value="INACTIVE" ${param.status == 'INACTIVE' ? 'selected' : ''}>비활성</option>
                <option value="SUSPENDED" ${param.status == 'SUSPENDED' ? 'selected' : ''}>정지</option>
              </select>
            </div>
            
            <div class="filter-actions">
              <button type="submit" class="btn btn-primary">검색</button>
              <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">초기화</a>
            </div>
          </div>
        </form>

        <!-- 사용자 목록 테이블 -->
        <div class="table-container">
          <table class="table">
            <thead>
              <tr>
                <th>이름</th>
                <th>학번/사번</th>
                <th>이메일</th>
                <th>역할</th>
                <th>상태</th>
                <th>가입일</th>
              </tr>
            </thead>
            <tbody>
              <c:forEach var="user" items="${userList}">
                <tr>
                  <td>
                    <div class="user-info">
                      <strong>${user.name}</strong>
                      <c:if test="${not empty user.department}">
                        <small>${user.department}</small>
                      </c:if>
                    </div>
                  </td>
                  <td>${user.studentId}</td>
                  <td>${user.email}</td>
                  <td>
                    <c:choose>
                      <c:when test="${user.role == 'STUDENT'}">
                        <span class="role-badge role-student">학생</span>
                      </c:when>
                      <c:when test="${user.role == 'PROFESSOR'}">
                        <span class="role-badge role-professor">교수</span>
                      </c:when>
                      <c:when test="${user.role == 'STAFF'}">
                        <span class="role-badge role-staff">직원</span>
                      </c:when>
                      <c:when test="${user.role == 'ADMIN'}">
                        <span class="role-badge role-admin">관리자</span>
                      </c:when>
                      <c:otherwise>
                        <span class="role-badge role-unknown">알 수 없음</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${user.status == 'ACTIVE'}">
                        <span class="status-badge status-active">활성</span>
                      </c:when>
                      <c:when test="${user.status == 'INACTIVE'}">
                        <span class="status-badge status-inactive">비활성</span>
                      </c:when>
                      <c:when test="${user.status == 'SUSPENDED'}">
                        <span class="status-badge status-suspended">정지</span>
                      </c:when>
                      <c:otherwise>
                        <span class="status-badge status-unknown">알 수 없음</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td><fmt:formatDate value="${user.createdAt}" pattern="yyyy-MM-dd"/></td>
                  <td>
                    <div class="action-buttons">
                      <c:if test="${user.status == 'ACTIVE'}">
                        <button onclick="changeUserStatus('${user.id}', 'SUSPENDED')" class="btn btn-secondary btn-sm">정지</button>
                      </c:if>
                      <c:if test="${user.status == 'SUSPENDED'}">
                        <button onclick="changeUserStatus('${user.id}', 'ACTIVE')" class="btn btn-primary btn-sm">활성화</button>
                      </c:if>
                    </div>
                  </td>
                </tr>
              </c:forEach>
              <c:if test="${empty userList}">
                <tr>
                  <td colspan="7" class="text-center">조회된 사용자가 없습니다.</td>
                </tr>
              </c:if>
            </tbody>
          </table>
        </div>

        <!-- 통계 정보 -->
        <div class="stats-section">
          <h3>사용자 통계</h3>
          <div class="stats-grid">
            <div class="stat-item">
              <div class="stat-number">${totalUsers}</div>
              <div class="stat-label">전체 사용자</div>
            </div>
            <div class="stat-item">
              <div class="stat-number">${studentCount}</div>
              <div class="stat-label">학생</div>
            </div>
            <div class="stat-item">
              <div class="stat-number">${professorCount}</div>
              <div class="stat-label">교수</div>
            </div>
            <div class="stat-item">
              <div class="stat-number">${staffCount}</div>
              <div class="stat-label">교직원</div>
            </div>
            <div class="stat-item">
              <div class="stat-number">${assistantCount}</div>
              <div class="stat-label">조교</div>
            </div>
            <div class="stat-item">
              <div class="stat-number">${adminCount}</div>
              <div class="stat-label">관리자</div>
            </div>
          </div>
        </div>

        <!-- 페이지네이션 -->
        <c:if test="${totalPages > 1}">
          <div class="pagination">
            <c:if test="${currentPage > 1}">
              <a href="?page=${currentPage - 1}&keyword=${param.keyword}&role=${param.role}&status=${param.status}" class="page-link">이전</a>
            </c:if>
            
            <c:forEach var="i" begin="${startPage}" end="${endPage}">
              <a href="?page=${i}&keyword=${param.keyword}&role=${param.role}&status=${param.status}" 
                 class="page-link ${i == currentPage ? 'active' : ''}">${i}</a>
            </c:forEach>
            
            <c:if test="${currentPage < totalPages}">
              <a href="?page=${currentPage + 1}&keyword=${param.keyword}&role=${param.role}&status=${param.status}" class="page-link">다음</a>
            </c:if>
          </div>
        </c:if>
      </div>
    </div>

    <!-- 푸터 -->
    <%@ include file="../layout/footer.jsp" %>
  </div>

  <!-- 스크립트 -->
  <%@ include file="../layout/scripts.jsp" %>

  <style>

    * {
        box-sizing: border-box;
        font-family: 'Segoe UI', sans-serif;
    }
    
    body {
        font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
        background: #f8f9fa;
        color: #111827;
        line-height: 1.6;
    }
    
    /* content 스타일은 head-meta.jsp에서 관리 */

    /* 검색 필터 */
    .search-filter {
      margin-bottom: 24px;
      padding-bottom: 24px;
      border-bottom: 1px solid #e5e7eb;
    }

    .filter-row {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 16px;
      align-items: end;
    }

    .filter-group {
      display: flex;
      flex-direction: column;
    }

    .filter-group label {
      font-weight: 500;
      color: #374151;
      margin-bottom: 4px;
      font-size: 14px;
    }

    .filter-actions {
      display: flex;
      gap: 8px;
    }

    /* 테이블 */
    .table-container {
      overflow-x: auto;
      margin-bottom: 24px;
    }

    .user-info strong {
      display: block;
      color: #111827;
    }

    .user-info small {
      color: #6b7280;
      font-size: 12px;
    }

    .role-badge {
      padding: 4px 8px;
      border-radius: 6px;
      font-size: 12px;
      font-weight: 500;
    }

    .role-student { background: #dbeafe; color: #1e40af; }
    .role-professor { background: #fef3c7; color: #92400e; }
    .role-staff { background: #d1fae5; color: #065f46; }
    .role-admin { background: #fce7f3; color: #be185d; }
    .role-unknown { background: #f3f4f6; color: #6b7280; }

    .status-badge {
      padding: 4px 8px;
      border-radius: 6px;
      font-size: 12px;
      font-weight: 500;
    }

    .status-active { background: #dcfce7; color: #166534; }
    .status-inactive { background: #f3f4f6; color: #6b7280; }
    .status-suspended { background: #fee2e2; color: #991b1b; }
    .status-unknown { background: #f3f4f6; color: #6b7280; }

    .action-buttons {
      display: flex;
      gap: 4px;
      flex-wrap: wrap;
    }

    .btn-sm {
      padding: 4px 8px;
      font-size: 11px;
    }

    /* 통계 섹션 */
    .stats-section {
      margin-top: 32px;
      padding-top: 24px;
      border-top: 1px solid #e5e7eb;
    }

    .stats-section h3 {
      font-size: 1.25rem;
      font-weight: 600;
      color: #111827;
      margin: 0 0 16px 0;
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
      gap: 12px;
    }

    .stat-item {
      background: #f8f9fa;
      padding: 20px;
      border-radius: 12px;
      text-align: center;
      border: 1px solid #e5e7eb;
    }

    .stat-number {
      font-size: 2rem;
      font-weight: 700;
      color: #3b82f6;
      margin-bottom: 4px;
    }

    .stat-label {
      font-size: 14px;
      color: #6b7280;
      font-weight: 500;
    }

    /* 페이지네이션 */
    .pagination {
      display: flex;
      justify-content: center;
      gap: 8px;
      margin-top: 24px;
    }

    .page-link {
      padding: 8px 12px;
      border: 1px solid #d1d5db;
      border-radius: 6px;
      color: #374151;
      text-decoration: none;
      transition: all 0.2s ease;
    }

    .page-link:hover {
      background: #f3f4f6;
    }

    .page-link.active {
      background: #3b82f6;
      border-color: #3b82f6;
      color: white;
    }

    .text-center {
      text-align: center;
      padding: 40px;
      color: #6b7280;
    }

    /* 반응형 */
    @media (max-width: 768px) {
      .filter-row {
        grid-template-columns: 1fr;
      }
      
      .filter-actions {
        justify-content: stretch;
      }
      
      .filter-actions .btn {
        flex: 1;
      }

      .action-buttons {
        flex-direction: column;
      }

      .stats-grid {
        grid-template-columns: repeat(2, 1fr);
        gap: 8px;
      }
      
      .stat-item {
        padding: 16px;
      }
      
      .stat-number {
        font-size: 1.5rem;
      }
    }
  </style>

  <script>
    function changeUserStatus(userId, newStatus) {
      const statusText = newStatus === 'ACTIVE' ? '활성화' : '정지';
      
      if (confirm(`해당 사용자를 ${statusText} 상태로 변경하시겠습니까?`)) {
        fetch(`${pageContext.request.contextPath}/admin/user/status`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            userId: userId,
            status: newStatus
          })
        })
        .then(response => response.json())
        .then(data => {
          if (data.success) {
            alert(`사용자 상태가 ${statusText}로 변경되었습니다.`);
            location.reload();
          } else {
            alert('상태 변경에 실패했습니다.');
          }
        })
        .catch(error => {
          console.error('Error:', error);
          alert('오류가 발생했습니다.');
        });
      }
    }
  </script>
</body>
</html>
