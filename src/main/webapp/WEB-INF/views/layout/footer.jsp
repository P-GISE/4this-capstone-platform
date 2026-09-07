<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- layout/footer.jsp -->
<footer class="footer">
  ⓒ 2025 AI 캡스톤디자인 시스템 | by 4차산업연구회 팀
</footer>

<style>
/* ── 푸터 스타일 ── */
footer.footer {
  width: calc(100% + 64px);
  margin-left: -32px;
  margin-right: -32px;
  padding: 16px 24px;
  text-align: center;
  color: #64748b;
  background: linear-gradient(135deg, #f8fafc 0%, #ffffff 100%);
  font-size: 13px;
  font-weight: 500;
  border-top: 1px solid #e2e8f0;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.03);
  margin-top: 40px;
  box-sizing: border-box;
}

/* ── 반응형 디자인 ── */
@media (max-width: 768px) {
  footer.footer {
    padding: 12px 20px;
    font-size: 12px;
  }
}

@media (max-width: 480px) {
  footer.footer {
    padding: 10px 16px;
    font-size: 11px;
  }
}
</style>
