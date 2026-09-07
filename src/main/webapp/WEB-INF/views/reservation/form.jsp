<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ include file="../layout/head-meta.jsp" %>

<body>
  <%@ include file="../layout/sidebar.jsp" %>

  <div class="content">
    <%@ include file="../layout/header.jsp" %>

    <div class="main-body">
      <h2>기자재 예약 신청</h2>

      <form action="${pageContext.request.contextPath}/reservation/submit" method="post">
        <input type="hidden" name="equipmentId" value="${equipmentId}" />

        <div style="margin-bottom: 15px;">
          <label for="note">메모 (선택)</label><br/>
          <textarea name="note" rows="4" style="width: 100%;" placeholder="예약 사유나 요청사항을 입력해주세요."></textarea>
        </div>

        <button type="submit" class="btn btn-outline-primary">예약 신청</button>
        <a href="${pageContext.request.contextPath}/equipment/list" class="btn btn-secondary">취소</a>
      </form>
    </div>

    <%@ include file="../layout/footer.jsp" %>
  </div>
</body>
</html>
