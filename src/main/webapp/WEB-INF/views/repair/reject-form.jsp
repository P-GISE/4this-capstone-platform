<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container" style="padding: 30px;">
  <h2>수리 요청 반려 사유 입력</h2>

  <form action="${pageContext.request.contextPath}/repair/admin/reject" method="post">
    <input type="hidden" name="repairId" value="${repairId}" />

    <div style="margin-bottom: 15px;">
      <label for="rejectionReason">반려 사유:</label><br />
      <textarea name="rejectionReason" rows="5" cols="50" required style="width: 100%;"></textarea>
    </div>

    <button type="submit" style="padding: 10px 20px; background-color: #dc3545; color: white; border: none; border-radius: 4px;">
      반려 처리
    </button>
  </form>
</div>
