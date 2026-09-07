<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>


<%@ include file="head-meta.jsp" %>
<body>
  <div class="sidebar">
    <%@ include file="sidebar.jsp" %>
  </div>

  <div class="content">
    <%@ include file="header.jsp" %>

    <div class="main-body">
      <%
        String bodyPage = (String) request.getAttribute("page");
        if (bodyPage != null) {
          String fullPath = "/WEB-INF/views/layout/" + bodyPage + ".jsp";
          java.io.File file = new java.io.File(application.getRealPath(fullPath));
          if (file.exists()) {
            RequestDispatcher rd = request.getRequestDispatcher(fullPath);
            rd.include(request, response);
          } else {
            out.println("<div style='color:red;'>요청한 페이지를 찾을 수 없습니다: " + fullPath + "</div>");
          }
        } else {
          out.println("<div>기본 콘텐츠입니다. 페이지가 지정되지 않았습니다.</div>");
        }
      %>
    </div>

    <%@ include file="footer.jsp" %>
  </div>

  <%@ include file="scripts.jsp" %>
</body>
</html>
