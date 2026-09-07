<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../layout/head-meta.jsp" %>

<head>
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
        
        /* content와 main-body 스타일은 head-meta.jsp에서 관리하므로 여기서는 제거 */


        .rental-summary {
            display: flex;
            gap: 30px;
            margin-bottom: 30px;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
        }
        
        .summary-item {
            text-align: center;
        }
        
        .summary-item .number {
            font-size: 24px;
            font-weight: bold;
            color: #007bff;
        }
        
        .summary-item .label {
            font-size: 14px;
            color: #666;
            margin-top: 5px;
        }
        
        .tab-container {
            margin-bottom: 30px;
        }
        
        .tab-buttons {
            display: flex;
            border-bottom: 2px solid #e9ecef;
            margin-bottom: 20px;
        }
        
        .tab-button {
            padding: 12px 24px;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 16px;
            color: #666;
            border-bottom: 2px solid transparent;
            transition: all 0.3s ease;
        }
        
        .tab-button.active {
            color: #007bff;
            border-bottom-color: #007bff;
            font-weight: bold;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        .rental-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
            table-layout: fixed;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .rental-table th,
        .rental-table td {
            padding: 15px 10px;
            text-align: center;
            border-bottom: 1px solid #e9ecef;
            font-size: 14px;
            word-break: break-word;
        }
        
        .rental-table th {
            background-color: #f8f9fa;
            font-weight: 600;
            color: #495057;
            border-bottom: 2px solid #dee2e6;
        }
        
        /* 각 탭별 컬럼 너비 통일 */
        
        /* 전체 탭 (6컬럼) - 기자재명, 대여일, 반납예정일, 반납일, 상태, 관리 */
        #all-tab .rental-table th:nth-child(1), 
        #all-tab .rental-table td:nth-child(1) { width: 22%; }
        #all-tab .rental-table th:nth-child(2), 
        #all-tab .rental-table td:nth-child(2) { width: 16%; }
        #all-tab .rental-table th:nth-child(3), 
        #all-tab .rental-table td:nth-child(3) { width: 16%; }
        #all-tab .rental-table th:nth-child(4), 
        #all-tab .rental-table td:nth-child(4) { width: 16%; }
        #all-tab .rental-table th:nth-child(5), 
        #all-tab .rental-table td:nth-child(5) { width: 12%; }
        #all-tab .rental-table th:nth-child(6), 
        #all-tab .rental-table td:nth-child(6) { width: 18%; }
        
        /* 대여중 탭 (5컬럼) - 기자재명, 대여일, 반납예정일, 상태, 관리 */
        #current-tab .rental-table th:nth-child(1), 
        #current-tab .rental-table td:nth-child(1) { width: 28%; }
        #current-tab .rental-table th:nth-child(2), 
        #current-tab .rental-table td:nth-child(2) { width: 20%; }
        #current-tab .rental-table th:nth-child(3), 
        #current-tab .rental-table td:nth-child(3) { width: 20%; }
        #current-tab .rental-table th:nth-child(4), 
        #current-tab .rental-table td:nth-child(4) { width: 14%; }
        #current-tab .rental-table th:nth-child(5), 
        #current-tab .rental-table td:nth-child(5) { width: 18%; }
        
        /* 반납완료 탭 (5컬럼) - 기자재명, 대여일, 반납예정일, 반납일, 상태 */
        #returned-tab .rental-table th:nth-child(1), 
        #returned-tab .rental-table td:nth-child(1) { width: 28%; }
        #returned-tab .rental-table th:nth-child(2), 
        #returned-tab .rental-table td:nth-child(2) { width: 20%; }
        #returned-tab .rental-table th:nth-child(3), 
        #returned-tab .rental-table td:nth-child(3) { width: 20%; }
        #returned-tab .rental-table th:nth-child(4), 
        #returned-tab .rental-table td:nth-child(4) { width: 18%; }
        #returned-tab .rental-table th:nth-child(5), 
        #returned-tab .rental-table td:nth-child(5) { width: 14%; }
        
        /* 예약중 탭 (5컬럼) - 기자재명, 예약일시, 예약상태, 비고, 관리 */
        #reserved-tab .rental-table th:nth-child(1), 
        #reserved-tab .rental-table td:nth-child(1) { width: 25%; }
        #reserved-tab .rental-table th:nth-child(2), 
        #reserved-tab .rental-table td:nth-child(2) { width: 20%; }
        #reserved-tab .rental-table th:nth-child(3), 
        #reserved-tab .rental-table td:nth-child(3) { width: 15%; }
        #reserved-tab .rental-table th:nth-child(4), 
        #reserved-tab .rental-table td:nth-child(4) { width: 22%; }
        #reserved-tab .rental-table th:nth-child(5), 
        #reserved-tab .rental-table td:nth-child(5) { width: 18%; }
        
        /* 수리요청중 탭 (6컬럼) - 기자재명, 대여일, 수리요청일, 수리내용, 상태, 관리 */
        #repair-tab .rental-table th:nth-child(1), 
        #repair-tab .rental-table td:nth-child(1) { width: 20%; }
        #repair-tab .rental-table th:nth-child(2), 
        #repair-tab .rental-table td:nth-child(2) { width: 15%; }
        #repair-tab .rental-table th:nth-child(3), 
        #repair-tab .rental-table td:nth-child(3) { width: 15%; }
        #repair-tab .rental-table th:nth-child(4), 
        #repair-tab .rental-table td:nth-child(4) { width: 20%; }
        #repair-tab .rental-table th:nth-child(5), 
        #repair-tab .rental-table td:nth-child(5) { width: 12%; }
        #repair-tab .rental-table th:nth-child(6), 
        #repair-tab .rental-table td:nth-child(6) { width: 18%; }
        
        /* 특별 대여 신청 탭 (6컬럼) - 기자재명, 신청일, 처리일, 사유, 상태, 관리 */
        #special-tab .rental-table th:nth-child(1), 
        #special-tab .rental-table td:nth-child(1) { width: 22%; }
        #special-tab .rental-table th:nth-child(2), 
        #special-tab .rental-table td:nth-child(2) { width: 15%; }
        #special-tab .rental-table th:nth-child(3), 
        #special-tab .rental-table td:nth-child(3) { width: 15%; }
        #special-tab .rental-table th:nth-child(4), 
        #special-tab .rental-table td:nth-child(4) { width: 20%; }
        #special-tab .rental-table th:nth-child(5), 
        #special-tab .rental-table td:nth-child(5) { width: 12%; }
        #special-tab .rental-table th:nth-child(6), 
        #special-tab .rental-table td:nth-child(6) { width: 16%; }
        
        .rental-table tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        /* 버튼 스타일 - list.jsp와 동일하게 */
        .btn {
            display: inline-block;
            padding: 6px 12px;
            font-size: 12px;
            border-radius: 4px;
            text-decoration: none;
            margin-right: 5px;
            border: 1px solid transparent;
            transition: all 0.2s;
            cursor: pointer;
        }
        
        .btn-outline-primary {
            color: #3366ff;
            border-color: #3366ff;
            background: white;
        }
        
        .btn-outline-primary:hover {
            background: #3366ff;
            color: #fff;
        }
        
        .btn-secondary {
            color: #888;
            border-color: #888;
            background: white;
        }
        
        .btn-secondary:hover {
            background: #888;
            color: #fff;
        }
        
        .btn-warning {
            color: #faad14;
            border-color: #faad14;
            background: white;
            pointer-events: none;
        }
        
        .btn-danger {
            color: #dc3545;
            border-color: #dc3545;
            background: white;
        }
        
        .btn-danger:hover {
            background: #dc3545;
            color: #fff;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            margin-top: 20px;
        }
        
        .pagination button {
            padding: 8px 12px;
            border: 1px solid #dee2e6;
            background: white;
            cursor: pointer;
            border-radius: 4px;
        }
        
        .pagination button:hover {
            background-color: #e9ecef;
        }
        
        .pagination button.active {
            background-color: #007bff;
            color: white;
            border-color: #007bff;
        }
        
        .pagination button:disabled {
            cursor: not-allowed;
            opacity: 0.5;
        }
        
        .empty-message {
            text-align: center;
            padding: 40px;
            color: #666;
            font-style: italic;
        }
        
        /* 상태 배지 스타일 */
        .status-badge {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-rented { background: #28a745; color: white; }
        .status-returned { background: #6c757d; color: white; }
        .status-overdue { background: #dc3545; color: white; }
        .status-reserved { background: #ffc107; color: white; }
        .status-repair { background: #fd7e14; color: white; }
        .status-pending { background: #007bff; color: white; }
        .status-approved { background: #28a745; color: white; }
        .status-rejected { background: #dc3545; color: white; }
        .status-cancelled { background: #6c757d; color: white; }
    </style>
</head>

<body>
<%@ include file="../layout/sidebar.jsp" %>

<div class="content">
    <%@ include file="../layout/header.jsp" %>
    
    <div class="main-body">
        <h1>나의 기자재 대여 이력</h1>
        
        <!-- 📊 요약 통계 -->
        <div class="rental-summary">
            <div class="summary-item">
                <div class="number">${fn:length(currentRentals)}</div>
                <div class="label">현재 대여중</div>
            </div>
            <div class="summary-item">
                <div class="number">${fn:length(reservations)}</div>
                <div class="label">예약중</div>
            </div>
            <div class="summary-item">
                <div class="number">${overdueCount}</div>
                <div class="label">연체</div>
            </div>
            <div class="summary-item">
                <div class="number">${repairRequestCount}</div>
                <div class="label">수리요청중</div>
            </div>
            <div class="summary-item">
                <div class="number">${specialRequestCount}</div>
                <div class="label">특별 대여 신청</div>
            </div>
            <div class="summary-item">
                <div class="number">${rentalTotalCount}</div>
                <div class="label">총 대여 횟수</div>
            </div>
        </div>
        
        <!-- 📋 탭 컨테이너 -->
        <div class="tab-container">
            <div class="tab-buttons">
                <button class="tab-button active" onclick="showTab('all')">전체</button>
                <button class="tab-button" onclick="showTab('current')">대여중</button>
                <button class="tab-button" onclick="showTab('returned')">반납완료</button>
                <button class="tab-button" onclick="showTab('reserved')">예약중</button>
                <button class="tab-button" onclick="showTab('repair')">수리요청중</button>
                <button class="tab-button" onclick="showTab('special')">특별 대여 신청</button>
            </div>
            
            <!-- 전체 탭 -->
            <div id="all-tab" class="tab-content active">
                <table class="rental-table">
                    <thead>
                        <tr>
                            <th>기자재명</th>
                            <th>대여일</th>
                            <th>반납예정일</th>
                            <th>반납일</th>
                            <th>상태</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- 현재 대여중 항목들 -->
                        <c:forEach var="rental" items="${currentRentals}">
                            <tr>
                                <td>기자재 ID: ${rental.equipmentId}</td>
                                <td>${rental.rentDate}</td>
                                <td>${rental.expectedReturnDate}</td>
                                <td>-</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${repairStatusMap[rental.equipmentId]}">
                                            <span class="status-badge status-repair">수리요청중</span>
                                        </c:when>
                                        <c:when test="${rental.status == 'OVERDUE'}">
                                            <span class="status-badge status-overdue">연체</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-rented">대여중</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${repairStatusMap[rental.equipmentId]}">
                                            <span class="btn btn-warning">수리요청중</span>
                                        </c:when>
                                        <c:otherwise>
                                            <form action="<c:url value='/equipmentrental/return'/>" method="post" style="display:inline;">
                                                <input type="hidden" name="rentalId" value="${rental.id}" />
                                                <button type="submit" class="btn btn-danger">반납하기</button>
                                            </form>
                                            <form action="<c:url value='/repair/form'/>" method="get" style="display:inline;">
                                                <input type="hidden" name="rentalId" value="${rental.id}" />
                                                <button type="submit" class="btn btn-secondary">수리 요청</button>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <!-- 반납완료 항목들 -->
                        <c:forEach var="rental" items="${returnedRentals}">
                            <tr>
                                <td>기자재 ID: ${rental.equipmentId}</td>
                                <td>${rental.rentDate}</td>
                                <td>${rental.expectedReturnDate}</td>
                                <td>${rental.returnDate}</td>
                                <td><span class="status-badge status-returned">반납완료</span></td>
                                <td>-</td>
                            </tr>
                        </c:forEach>
                        
                        <!-- 예약중 항목들 -->
                        <c:forEach var="reservation" items="${reservations}">
                            <tr>
                                <td>기자재 ID: ${reservation.equipmentId}</td>
                                <td>-</td>
                                <td>-</td>
                                <td>-</td>
                                <td><span class="status-badge status-reserved">예약중</span></td>
                                <td>
                                    <button onclick="cancelReservation('${reservation.id}')" class="btn btn-secondary">예약취소</button>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <!-- 특별 대여 신청 항목들 -->
                        <c:forEach var="request" items="${specialRequests}">
                            <tr>
                                <td>${request.equipmentName != null ? request.equipmentName : request.equipmentId}</td>
                                <td>${request.createdAt}</td>
                                <td>-</td>
                                <td>${request.reviewedAt != null ? request.reviewedAt : '-'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${request.status == 'PENDING'}">
                                            <span class="status-badge status-pending">특별신청 대기중</span>
                                        </c:when>
                                        <c:when test="${request.status == 'APPROVED'}">
                                            <span class="status-badge status-approved">특별신청 승인됨</span>
                                        </c:when>
                                        <c:when test="${request.status == 'REJECTED'}">
                                            <span class="status-badge status-rejected">특별신청 거절됨</span>
                                        </c:when>
                                        <c:when test="${request.status == 'CANCELLED'}">
                                            <span class="status-badge status-cancelled">특별신청 취소됨</span>
                                        </c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${request.status == 'PENDING'}">
                                            <button onclick="cancelSpecialRequest('${request.id}')" class="btn btn-danger">취소</button>
                                        </c:when>
                                        <c:when test="${request.status == 'APPROVED'}">
                                            <span class="btn btn-secondary" style="pointer-events: none;">승인완료</span>
                                        </c:when>
                                        <c:when test="${request.status == 'REJECTED'}">
                                            <a href="/special-rental/request?equipmentId=${request.equipmentId}" class="btn btn-secondary">재신청</a>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="btn btn-secondary" style="pointer-events: none;">처리완료</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        
                        <c:if test="${empty currentRentals && empty returnedRentals && empty reservations && empty specialRequests}">
                            <tr>
                                <td colspan="6" class="empty-message">대여 이력이 없습니다.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            
            <!-- 대여중 탭 -->
            <div id="current-tab" class="tab-content">
                <table class="rental-table">
                    <thead>
                        <tr>
                            <th>기자재명</th>
                            <th>대여일</th>
                            <th>반납예정일</th>
                            <th>상태</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:if test="${empty currentRentals}">
                            <tr>
                                <td colspan="5" class="empty-message">현재 대여중인 기자재가 없습니다.</td>
                            </tr>
                        </c:if>
                        <c:forEach var="rental" items="${currentRentals}">
                            <tr>
                                <td>기자재 ID: ${rental.equipmentId}</td>
                                <td>${rental.rentDate}</td>
                                <td>${rental.expectedReturnDate}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${repairStatusMap[rental.equipmentId]}">
                                            <span class="status-badge status-repair">수리요청중</span>
                                        </c:when>
                                        <c:when test="${rental.status == 'OVERDUE'}">
                                            <span class="status-badge status-overdue">연체</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-rented">대여중</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${repairStatusMap[rental.equipmentId]}">
                                            <span class="btn btn-warning">수리요청중</span>
                                        </c:when>
                                        <c:otherwise>
                                            <form action="<c:url value='/equipmentrental/return'/>" method="post" style="display:inline;">
                                                <input type="hidden" name="rentalId" value="${rental.id}" />
                                                <button type="submit" class="btn btn-danger">반납하기</button>
                                            </form>
                                            <form action="<c:url value='/repair/form'/>" method="get" style="display:inline;">
                                                <input type="hidden" name="rentalId" value="${rental.id}" />
                                                <button type="submit" class="btn btn-secondary">수리 요청</button>
                                            </form>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            
            <!-- 반납완료 탭 -->
            <div id="returned-tab" class="tab-content">
                <table class="rental-table">
                    <thead>
                        <tr>
                            <th>기자재명</th>
                            <th>대여일</th>
                            <th>반납예정일</th>
                            <th>반납일</th>
                            <th>상태</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:if test="${empty returnedRentals}">
                            <tr>
                                <td colspan="5" class="empty-message">반납 완료된 기자재가 없습니다.</td>
                            </tr>
                        </c:if>
                        <c:forEach var="rental" items="${returnedRentals}">
                            <tr>
                                <td>기자재 ID: ${rental.equipmentId}</td>
                                <td>${rental.rentDate}</td>
                                <td>${rental.expectedReturnDate}</td>
                                <td>${rental.returnDate}</td>
                                <td><span class="status-badge status-returned">반납완료</span></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            
            <!-- 예약중 탭 -->
            <div id="reserved-tab" class="tab-content">
                <table class="rental-table">
                    <thead>
                        <tr>
                            <th>기자재명</th>
                            <th>예약일시</th>
                            <th>예약상태</th>
                            <th>비고</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:if test="${empty reservations}">
                            <tr>
                                <td colspan="5" class="empty-message">예약중인 기자재가 없습니다.</td>
                            </tr>
                        </c:if>
                        <c:forEach var="reservation" items="${reservations}">
                            <tr>
                                <td>기자재 ID: ${reservation.equipmentId}</td>
                                <td>${reservation.reservedAt}</td>
                                <td><span class="status-badge status-reserved">예약중</span></td>
                                <td>${reservation.note != null ? reservation.note : '-'}</td>
                                <td>
                                    <button onclick="cancelReservation('${reservation.id}')" class="btn btn-secondary">예약취소</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
            
            <!-- 수리요청중 탭 -->
            <div id="repair-tab" class="tab-content">
                <table class="rental-table">
                    <thead>
                        <tr>
                            <th>기자재명</th>
                            <th>대여일</th>
                            <th>수리요청일</th>
                            <th>수리내용</th>
                            <th>상태</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:set var="hasRepairRequests" value="false" />
                        <c:forEach var="rental" items="${currentRentals}">
                            <c:if test="${repairStatusMap[rental.equipmentId] != null}">
                                <c:set var="hasRepairRequests" value="true" />
                                <tr>
                                    <td>기자재 ID: ${rental.equipmentId}</td>
                                    <td>${rental.rentDate}</td>
                                    <td>${repairRequestDateMap[rental.equipmentId] != null ? repairRequestDateMap[rental.equipmentId] : '-'}</td>
                                    <td>${repairContentMap[rental.equipmentId] != null ? repairContentMap[rental.equipmentId] : '수리 필요'}</td>
                                    <td>
                                        <span class="status-badge status-repair">수리요청중</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${equipmentStatusMap[rental.equipmentId] == 'AVAILABLE'}">
                                                <form action="/equipmentrental/request" method="get">
                                                    <input type="hidden" name="equipmentId" value="${rental.equipmentId}" />
                                                    <button type="submit" class="btn btn-outline-primary">대여신청</button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="btn btn-warning">처리중</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:if>
                        </c:forEach>
                        <c:if test="${!hasRepairRequests}">
                            <tr>
                                <td colspan="6" class="empty-message">수리 요청중인 기자재가 없습니다.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
            
            <!-- 특별 대여 신청 탭 -->
            <div id="special-tab" class="tab-content">
                <table class="rental-table">
                    <thead>
                        <tr>
                            <th>기자재명</th>
                            <th>신청일</th>
                            <th>처리일</th>
                            <th>사유</th>
                            <th>상태</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:if test="${empty specialRequests}">
                            <tr>
                                <td colspan="6" class="empty-message">특별 대여 신청이 없습니다.</td>
                            </tr>
                        </c:if>
                        <c:forEach var="request" items="${specialRequests}">
                            <tr>
                                <td>${request.equipmentName != null ? request.equipmentName : request.equipmentId}</td>
                                <td>${request.createdAt}</td>
                                <td>${request.reviewedAt != null ? request.reviewedAt : '-'}</td>
                                <td>${request.purpose}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${request.status == 'PENDING'}">
                                            <span class="status-badge status-pending">대기중</span>
                                        </c:when>
                                        <c:when test="${request.status == 'APPROVED'}">
                                            <span class="status-badge status-approved">승인됨</span>
                                        </c:when>
                                        <c:when test="${request.status == 'REJECTED'}">
                                            <span class="status-badge status-rejected">거절됨</span>
                                        </c:when>
                                        <c:when test="${request.status == 'CANCELLED'}">
                                            <span class="status-badge status-cancelled">취소됨</span>
                                        </c:when>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${request.status == 'PENDING'}">
                                            <button onclick="cancelSpecialRequest('${request.id}')" class="btn btn-danger">취소</button>
                                        </c:when>
                                        <c:when test="${request.status == 'APPROVED'}">
                                            <span class="btn btn-secondary" style="pointer-events: none;">승인완료</span>
                                        </c:when>
                                        <c:when test="${request.status == 'REJECTED'}">
                                            <a href="/special-rental/request?equipmentId=${request.equipmentId}" class="btn btn-secondary">재신청</a>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="btn btn-secondary" style="pointer-events: none;">처리완료</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
        
        <!-- 📄 페이지네이션 -->
        <div class="pagination">
            <button onclick="goToPage('prev')" ${currentPage <= 1 ? 'disabled' : ''}>‹</button>
            <button class="active">1</button>
            <button onclick="goToPage('next')">›</button>
        </div>
    </div>
    
    <%@ include file="../layout/footer.jsp" %>
</div>

<script>
    // 탭 전환 함수
    function showTab(tabName) {
        // 모든 탭 컨텐츠 숨기기
        const tabContents = document.querySelectorAll('.tab-content');
        tabContents.forEach(content => {
            content.classList.remove('active');
        });
        
        // 모든 탭 버튼 비활성화
        const tabButtons = document.querySelectorAll('.tab-button');
        tabButtons.forEach(button => {
            button.classList.remove('active');
        });
        
        // 선택된 탭 활성화
        document.getElementById(tabName + '-tab').classList.add('active');
        event.target.classList.add('active');
    }
    
    // 예약 취소 함수
    function cancelReservation(reservationId) {
        if (confirm('예약을 취소하시겠습니까?')) {
            fetch('/reservation/cancel', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ reservationId: parseInt(reservationId) })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('예약이 취소되었습니다.');
                    location.reload();
                } else {
                    alert('예약 취소 중 오류가 발생했습니다.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('예약 취소 중 오류가 발생했습니다.');
            });
        }
    }
    // 반납 처리 함수 (AJAX)
    function returnEquipment(rentalId) {
        if (!confirm("정말 반납하시겠습니까?")) return;

        fetch("/equipmentrental/return", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            body: new URLSearchParams({ rentalId })
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                alert(data.message); // "반납 완료"
                window.location.href = "/equipment/list";
            } else {
                alert("반납 실패: " + data.message);
            }
        })
        .catch(err => {
            console.error("반납 오류:", err);
            alert("서버 오류가 발생했습니다.");
        });
    }

    // 페이지네이션 함수
    function goToPage(direction) {
        console.log('Go to page:', direction);
        // 실제 구현에서는 서버에 페이지 요청을 보내야 합니다
    }

    // 특별 대여 신청 취소 함수
    function cancelSpecialRequest(requestId) {
        if (confirm('특별 대여 신청을 취소하시겠습니까?')) {
            fetch('/special-rental/cancel', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ requestId: parseInt(requestId) })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('특별 대여 신청이 취소되었습니다.');
                    location.reload();
                } else {
                    alert('취소 중 오류가 발생했습니다: ' + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('취소 중 오류가 발생했습니다.');
            });
        }
    }
</script>

</body>
</html>