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
            <h1 class="page-title">실패 로그인 모니터링</h1>
            
            <div class="modern-card">
                <div class="card-header">
                    <div class="header-actions">
                        <a href="${pageContext.request.contextPath}/admin/user-logs/list" class="btn btn-primary">전체 로그</a>
                    </div>
                </div>

                <!-- 필터 영역 -->
                <form method="get" class="search-filter">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label>시작일</label>
                            <input type="date" name="dateFrom" value="${dateFrom}" class="form-control">
                        </div>
                        <div class="filter-group">
                            <label>종료일</label>
                            <input type="date" name="dateTo" value="${dateTo}" class="form-control">
                        </div>
                        <div class="filter-group">
                            <label>IP 주소</label>
                            <input type="text" name="ipAddress" value="${ipAddress}" placeholder="IP 주소로 필터링" class="form-control">
                        </div>
                        <div class="filter-actions">
                            <button type="submit" class="btn btn-primary">조회</button>
                        </div>
                    </div>
                </form>

                <!-- 보안 알림 -->
                <c:if test="${not empty suspiciousIps}">
                    <div class="alert alert-warning">
                        <h4>⚠️ 의심스러운 활동 감지</h4>
                        <div class="suspicious-activities">
                            <c:forEach var="ip" items="${suspiciousIps}">
                                <div class="suspicious-item">
                                    <span class="ip-address">${ip.ipAddress}</span>
                                    <span class="attempt-count">${ip.attemptCount}회 실패</span>
                                    <span class="time-info">최근 ${ip.timeWindow}분 내</span>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <!-- 결과 정보 -->
                <div class="result-info">
                    <span>총 <strong>${result.totalCount}</strong>건의 실패 로그인 기록</span>
                </div>

                <!-- 실패 로그인 테이블 -->
                <div class="table-container">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>시도한 아이디</th>
                                <th>IP 주소</th>
                                <th>실패 사유</th>
                                <th>시도 시간</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty result.logs}">
                                    <tr>
                                        <td colspan="5" class="text-center">실패 로그인 기록이 없습니다.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="log" items="${result.logs}">
                                        <tr>
                                            <td>${log.id}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty log.failureReason and log.failureReason.contains('ID:')}">
                                                        <span class="attempted-id">
                                                            ${log.failureReason.substring(log.failureReason.indexOf('ID:') + 3, log.failureReason.indexOf(')'))}
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">알 수 없음</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="ip-address">${log.ipAddress}</td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${log.failureReason.startsWith('잘못된 아이디 또는 비밀번호')}">
                                                        <span class="badge badge-warning">잘못된 인증 정보</span>
                                                    </c:when>
                                                    <c:when test="${log.failureReason.contains('계정이 잠김')}">
                                                        <span class="badge badge-danger">계정 잠김</span>
                                                    </c:when>
                                                    <c:when test="${log.failureReason.contains('계정이 비활성화')}">
                                                        <span class="badge badge-secondary">계정 비활성화</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-info">기타</span>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div class="failure-detail">${log.failureReason}</div>
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
        .alert {
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 24px;
        }

        .alert-warning {
            background-color: #fef3c7;
            border: 1px solid #f59e0b;
            color: #92400e;
        }

        .alert h4 {
            margin-bottom: 12px;
            font-weight: 600;
        }

        .suspicious-activities {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .suspicious-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 8px;
            background: rgba(255, 255, 255, 0.5);
            border-radius: 6px;
        }

        .ip-address {
            font-family: 'Courier New', monospace;
            font-weight: 600;
            color: #374151;
        }

        .attempt-count {
            color: #dc2626;
            font-weight: 600;
        }

        .time-info {
            color: #6b7280;
            font-size: 0.875rem;
        }

        .attempted-id {
            font-family: 'Courier New', monospace;
            font-weight: 600;
            color: #1f2937;
        }

        .failure-detail {
            font-size: 0.75rem;
            color: #6b7280;
            margin-top: 4px;
        }

        .datetime-info div {
            font-weight: 500;
        }

        .datetime-info small {
            color: #6b7280;
        }
    </style>
</body>
</html> 