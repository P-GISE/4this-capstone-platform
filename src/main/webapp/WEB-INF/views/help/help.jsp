<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../layout/head-meta.jsp" %>

<body>
  <%-- 사이드바 --%>
  <%@ include file="../layout/sidebar.jsp" %>

  <div class="content">
    <%-- 헤더 --%>
    <%@ include file="../layout/header.jsp" %>

    <div class="main-body help-page">
      <h1>도움말</h1>

      <section>
        <h2>1. 기본 기능</h2>
        <ul>
          <li><strong>프로젝트 관리</strong> – 좌측 메뉴에서 “프로젝트 관리”를 클릭하세요.</li>
          <li><strong>AI 기술지원</strong> – “AI 기술지원” 메뉴에서 지원 요청을 할 수 있습니다.</li>
          <li><strong>문의사항</strong> – “문의사항”에서 관리자에게 질문을 남길 수 있습니다.</li>
        </ul>
      </section>

      <section>
        <h2>2. 계정 관리</h2>
        <ul>
          <li><strong>로그인/로그아웃</strong> – 우측 상단 프로필 드롭다운에서 “로그아웃”을 클릭합니다.</li>
          <li><strong>비밀번호 찾기</strong> – 로그인 화면에서 “비밀번호 찾기”를 통해 이메일로 임시비밀번호를 받을 수 있습니다.</li>
          <li><strong>이메일 인증</strong> – 회원가입 후 이메일로 전송된 링크를 클릭해야 정상 로그인 가능합니다.</li>
        </ul>
      </section>

      <section>
        <h2>3. 자주 묻는 질문 (FAQ)</h2>
        <dl>
          <dt>Q1. 비밀번호를 변경하고 싶습니다.</dt>
          <dd>A. 로그인 후, 프로필 메뉴 → 계정관리 페이지에서 변경 가능합니다.</dd>

          <dt>Q2. 지원 가능한 AI 기술 종류는?</dt>
          <dd>A. 이미지 처리, 자연어 처리, 음성 인식 등 다양한 AI 기술을 지원합니다.</dd>
        </dl>
      </section>

      <section>
        <h2>4. 문의 연락처</h2>
        <p>문제가 있거나 도움이 필요하시면 아래로 연락주세요.</p>
        <ul>
          <li>이메일: support@example.com</li>
          <li>전화: 1566-9178</li>
        </ul>
      </section>
    </div>

    <%-- 푸터 --%>
    <%@ include file="../layout/footer.jsp" %>
  </div>

  <%@ include file="../layout/scripts.jsp" %>
</body>
</html>
