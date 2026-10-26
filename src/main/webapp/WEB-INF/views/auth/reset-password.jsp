<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!doctype html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="referrer" content="no-referrer">
    <title>비밀번호 재설정 · 4this</title>
</head>
<body>
<main>
    <h1>비밀번호 재설정</h1>
    <p>이메일로 받은 링크는 15분 동안 한 번만 사용할 수 있습니다.</p>
    <c:if test="${not empty error}"><p role="alert"><c:out value="${error}" /></p></c:if>
    <form action="/auth/reset-password" method="post">
        <input id="reset-token" type="hidden" name="token" value="<c:out value='${resetToken}' />">
        <p><label for="new-password">새 비밀번호</label>
            <input id="new-password" type="password" name="password" minlength="8" maxlength="72" autocomplete="new-password" required></p>
        <p><label for="confirm-password">새 비밀번호 확인</label>
            <input id="confirm-password" type="password" name="passwordConfirm" minlength="8" maxlength="72" autocomplete="new-password" required></p>
        <button type="submit">비밀번호 변경</button>
    </form>
    <p><a href="/auth/find-password">재설정 링크 다시 요청</a> · <a href="/auth/login">로그인</a></p>
</main>
<script src="/resources/js/password-reset.js" defer></script>
</body>
</html>
