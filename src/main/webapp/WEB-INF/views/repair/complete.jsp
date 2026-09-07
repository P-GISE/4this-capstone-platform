<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ include file="../layout/head-meta.jsp" %>

<body>
<%@ include file="../layout/sidebar.jsp" %>
<div class="content">
    <%@ include file="../layout/header.jsp" %>

    <div class="main-body">
        <h2>수리 요청 완료</h2>
        <p>요청이 정상적으로 접수되었습니다. 관리자의 확인 후 처리됩니다.</p>

        <a href="${pageContext.request.contextPath}/equipment/list" class="btn btn-outline-primary" style="margin-top: 20px;">기자재 목록으로 돌아가기</a>
    </div>

    <%@ include file="../layout/footer.jsp" %>
</div>
</body>
</html>
