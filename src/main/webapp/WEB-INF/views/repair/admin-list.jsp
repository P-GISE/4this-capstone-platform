<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ include file="../layout/head-meta.jsp" %>

<body>
<%@ include file="../layout/sidebar.jsp" %>

<div class="content">
  <%@ include file="../layout/header.jsp" %>

  <div class="main-body repair-list-page">
    <h1>🛠 수리 요청 목록 (대기중)</h1>

    <c:if test="${empty pendingList}">
      <div class="no-request">현재 대기 중인 수리 요청이 없습니다.</div>
    </c:if>

    <c:if test="${not empty pendingList}">
      <table class="repair-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>요청자</th>
            <th>요청일</th>
            <th>사유</th>
            <th>이미지</th>
            <th>처리</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="r" items="${pendingList}">
            <tr>
              <td>#${r.id}</td>
              <td>
                <c:choose>
                  <c:when test="${not empty r.user}">
                    <strong>${r.user.name}</strong><br />
                    <span class="username">(${r.user.username})</span>
                  </c:when>
                  <c:otherwise>
                    <span class="username">ID: ${r.requestedBy}</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td>
                <fmt:formatDate value="${r.requestedAtDate}" pattern="yyyy-MM-dd HH:mm" />
              </td>
              <td>${r.reason}</td>
              <td>
                <c:if test="${not empty r.imagePath}">
                  <img src="${pageContext.request.contextPath}/uploads/repair/${r.imagePath}"
                       alt="첨부 이미지"
                       style="max-width: 80px; border-radius: 6px;" />
                </c:if>
              </td>
              <td>
                <form action="${pageContext.request.contextPath}/repair/admin/approve-form" method="get">
                  <input type="hidden" name="rId" value="${r.id}" />
                  <button type="submit" class="btn btn-primary">승인/반려</button>
                </form>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </c:if>
  </div>

  <%@ include file="../layout/footer.jsp" %>
</div>

<style>

  * {
      box-sizing: border-box;
      font-family: 'Segoe UI', sans-serif;
  }
  
  body {
      font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: #f8f9fa;
      color: #2d3748;
      line-height: 1.6;
  }
  
  /* content 스타일은 head-meta.jsp에서 관리 */
  .repair-list-page {
    padding: 30px;
  }

  .repair-list-page h1 {
    font-size: 1.8em;
    margin-bottom: 20px;
    color: #2d3748;
  }

  .no-request {
    padding: 20px;
    background: #fefcbf;
    color: #744210;
    border: 1px solid #f6e05e;
    border-radius: 8px;
    font-size: 1.1em;
  }

  .repair-table {
    width: 100%;
    border-collapse: collapse;
    background-color: white;
    border: 1px solid #e2e8f0;
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  }

  .repair-table th, .repair-table td {
    padding: 15px;
    text-align: center;
    border-bottom: 1px solid #edf2f7;
    font-size: 0.95em;
  }

  .repair-table th {
    background-color: #f7fafc;
    color: #4a5568;
    font-weight: 600;
  }

  .repair-table tbody tr:hover {
    background-color: #f1f5f9;
  }

  .username {
    color: #718096;
    font-size: 0.85em;
  }

  .btn {
    padding: 8px 16px;
    font-size: 0.9em;
    font-weight: 600;
    border: none;
    border-radius: 8px;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;
  }

  .btn-primary {
    background-color: #667eea;
    color: white;
  }

  .btn-primary:hover {
    background-color: #5a67d8;
  }
</style>
</body>
</html>
