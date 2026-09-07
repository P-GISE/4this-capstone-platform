<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<body>
    <!-- 사이드바 -->
    <div class="sidebar">
        <%@ include file="../layout/sidebar.jsp" %>
    </div>

    <!-- 메인 콘텐츠 -->
    <div class="content">
        <!-- 헤더 -->
        <%@ include file="../layout/header.jsp" %>

        <!-- 본문 영역 -->
        <div class="main-body">
            <h1 class="page-title">사용자 접속 로그</h1>
            
            <div class="modern-card">
                <!-- 결과 정보 -->
                <div class="result-info">
                    <span>총 <strong>${result.totalCount}</strong>건의 로그</span>
                </div>

                <!-- 로그 목록 테이블 -->
                <div class="table-container">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>사용자</th>
                                <th>타입</th>
                                <th>IP 주소</th>
                                <th>성공</th>
                                <th>접속 시간</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty result.logs}">
                                    <tr>
                                        <td colspan="6" class="text-center">로그가 없습니다.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="log" items="${result.logs}">
                                        <tr>
                                            <td>${log.id}</td>
                                            <td>
                                                <div class="user-info">
                                                    <strong>${log.userName != null ? log.userName : '미상'}</strong>
                                                    <small>
                                                        <c:choose>
                                                            <c:when test="${log.userRole == 'ADMIN'}">관리자</c:when>
                                                            <c:when test="${log.userRole == 'STUDENT'}">학생</c:when>
                                                            <c:when test="${log.userRole == 'STAFF'}">교직원</c:when>
                                                            <c:when test="${log.userRole == 'ASSISTANT'}">조교</c:when>
                                                            <c:when test="${log.userRole == 'PROFESSOR'}">교수</c:when>
                                                            <c:otherwise>${log.userRole}</c:otherwise>
                                                        </c:choose>
                                                    </small>
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${log.loginType == 'LOGIN'}">
                                                        <span class="badge badge-primary">로그인</span>
                                                    </c:when>
                                                    <c:when test="${log.loginType == 'LOGOUT'}">
                                                        <span class="badge badge-secondary">로그아웃</span>
                                                    </c:when>
                                                    <c:when test="${log.loginType == 'FAILED'}">
                                                        <span class="badge badge-danger">실패</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-info">${log.loginType}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${log.ipAddress}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${log.success}">
                                                        <span class="badge badge-success">성공</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-danger">실패</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="datetime-info">
                                                    <div>${log.formattedCreatedDate}</div>
                                                    <small>${log.formattedCreatedTime}</small>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- 푸터 -->
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>

    <style>
        * {
            box-sizing: border-box;
            font-family: 'Segoe UI', sans-serif;
        }
        
        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f8f9fa;
            color: #2d3748;
            line-height: 1.6;
        }
        
        /* content 스타일은 head-meta.jsp에서 관리 */
        
    </style>
</body>
</html> 
