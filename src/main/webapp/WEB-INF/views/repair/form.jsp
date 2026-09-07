<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../layout/head-meta.jsp" %>

<body>
<%@ include file="../layout/sidebar.jsp" %>
<div class="content">
  <%@ include file="../layout/header.jsp" %>

  <div class="main-body repair-request-page">
    <h1 class="page-title">🛠 수리 요청</h1>

    <div class="form-card">
      <form action="<c:url value='/repair/submit'/>" method="post" enctype="multipart/form-data">
        <!-- rentalId가 있는 경우 -->
        <c:if test="${not empty rentalId}">
          <input type="hidden" name="rentalId" value="${rentalId}" />
        </c:if>
        
        <!-- equipmentId가 있는 경우 -->
        <c:if test="${not empty equipmentId}">
          <input type="hidden" name="equipmentId" value="${equipmentId}" />
        </c:if>

        <div class="form-group">
          <label for="reason">고장 사유</label>
          <textarea id="reason" name="reason" rows="5" placeholder="예: 화면이 켜지지 않음, 전원 버튼 불량 등" required></textarea>
        </div>

        <div class="form-group">
          <label for="image">사진 업로드 (선택)</label>
          <input type="file" name="image" id="image" accept="image/*" />
        </div>



        <div class="button-group">
          <button type="submit" class="btn btn-primary">수리 요청 제출</button>
          <a href="<c:url value='/equipment/list'/>" class="btn btn-secondary">취소</a>
        </div>
      </form>
    </div>
  </div>

  <%@ include file="../layout/footer.jsp" %>
</div>

<style>
  .repair-request-page {
    padding: 40px 20px;
    display: flex;
    flex-direction: column;
    align-items: center;
    min-height: 80vh;
    background-color: #f9fafb;
  }

  .page-title {
    font-size: 24px;
    font-weight: 700;
    color: #2d3748;
    margin-bottom: 30px;
    text-align: center;
  }

  .form-card {
    background: #ffffff;
    padding: 30px;
    border-radius: 12px;
    max-width: 600px;
    width: 100%;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  }

  .form-group {
    margin-bottom: 20px;
  }

  .form-group label {
    display: block;
    font-weight: 600;
    margin-bottom: 8px;
    color: #4a5568;
  }

  .form-group textarea,
  .form-group input[type="file"] {
    width: 100%;
    padding: 10px;
    font-size: 14px;
    border: 1px solid #cbd5e0;
    border-radius: 6px;
    box-sizing: border-box;
  }

  .form-group textarea {
    resize: vertical;
    min-height: 100px;
  }

  .button-group {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 20px;
  }

  .btn {
    padding: 10px 20px;
    font-weight: 600;
    font-size: 14px;
    border-radius: 8px;
    text-decoration: none;
    cursor: pointer;
    border: none;
  }

  .btn-primary {
    background-color: #3182ce;
    color: #fff;
  }

  .btn-primary:hover {
    background-color: #2b6cb0;
  }

  .btn-secondary {
    background-color: #e2e8f0;
    color: #2d3748;
  }

  .btn-secondary:hover {
    background-color: #cbd5e0;
  }
</style>
</body>
</html>
