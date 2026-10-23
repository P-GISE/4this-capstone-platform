<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>요청 안내 · 4this</title>
</head>
<body>
  <main>
    <h1>요청을 처리할 수 없습니다</h1>
    <p><c:out value="${errorMessage}" default="잠시 후 다시 시도해 주세요." /></p>
    <p><a href="/auth/login">로그인 화면으로 이동</a></p>
  </main>
</body>
</html>
