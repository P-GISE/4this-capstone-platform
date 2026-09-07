<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
  /* confirm.jsp 전용 스타일 */
  .confirm-container {
    max-width: 600px;
    margin: 80px auto;
    background: #ffffff;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    padding: 30px 20px;
    text-align: center;
  }
  .confirm-container h2 {
    color: #333;
    margin-bottom: 20px;
    font-size: 20px;
  }
  .confirm-container p {
    margin-bottom: 30px;
    font-size: 16px;
    color: #555;
  }
  .confirm-buttons a {
    display: inline-block;
    padding: 8px 16px;
    font-size: 14px;
    border-radius: 4px;
    text-decoration: none;
    border: 1px solid #3366ff;
    color: #3366ff;
    transition: background 0.2s, color 0.2s;
  }
  .confirm-buttons a:hover {
    background: #3366ff;
    color: #fff;
  }
</style>

<div class="confirm-container">
  <h2>대여신청이 완료되었습니다!</h2>
  <p>${message}</p>
  <div class="confirm-buttons">
    <a href="${pageContext.request.contextPath}/equipment/list">목록으로 돌아가기</a>
  </div>
</div>
