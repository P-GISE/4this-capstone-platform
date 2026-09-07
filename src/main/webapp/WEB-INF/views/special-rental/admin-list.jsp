<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>특별 대여 신청 관리</title>
    <%@ include file="../layout/head-meta.jsp" %>
    <style>
        /* 기본 스타일 */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', sans-serif;
        }

        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f8f9fa;
            color: #2d3748;
            line-height: 1.6;
        }

        /* content와 main-body 스타일은 head-meta.jsp에서 관리 */

        /* 페이지 헤더 */
        .page-header {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .page-title {
            font-size: 24px;
            color: #333;
        }

        .stats-summary {
            display: flex;
            gap: 20px;
        }

        .stat-item {
            text-align: center;
            padding: 10px 15px;
            background: #f8f9fa;
            border-radius: 6px;
            min-width: 80px;
        }

        .stat-number {
            font-size: 20px;
            font-weight: 600;
            color: #3366ff;
        }

        .stat-label {
            font-size: 12px;
            color: #666;
            margin-top: 2px;
        }

        /* 디버깅 정보 */
        .debug-info {
            background: #e8f4fd;
            padding: 15px;
            margin: 10px 0;
            border-radius: 6px;
            font-size: 13px;
            color: #0066cc;
            border: 1px solid #bee5eb;
            line-height: 1.5;
        }

        .debug-row {
            margin-bottom: 5px;
        }

        .debug-title {
            font-weight: 600;
            color: #004085;
        }

        /* 필터 영역 */
        .filter-section {
            background: #fff;
            padding: 15px 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }

        .filter-row {
            display: flex;
            gap: 15px;
            align-items: end;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .filter-label {
            font-size: 12px;
            color: #666;
            font-weight: 500;
        }

        .filter-control {
            padding: 8px 12px;
            border: 1px solid #d9d9d9;
            border-radius: 4px;
            font-size: 14px;
            min-width: 120px;
        }

        .btn-filter {
            padding: 8px 16px;
            background: #3366ff;
            color: #fff;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }

        .btn-filter:hover {
            background: #254eda;
        }

        /* 테이블 스타일 */
        .table-container {
            background: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .table {
            width: 100%;
            border-collapse: collapse;
        }

        .table th {
            background: #f8f9fa;
            padding: 12px 10px;
            text-align: left;
            font-weight: 600;
            color: #333;
            border-bottom: 1px solid #e9ecef;
            font-size: 13px;
        }

        .table td {
            padding: 12px 10px;
            border-bottom: 1px solid #f0f0f0;
            vertical-align: middle;
            font-size: 13px;
        }

        .table tr:hover {
            background: #f8f9fa;
        }

        /* 배지 스타일 */
        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 500;
            color: #fff;
        }

        .badge-warning {
            background: #faad14;
        }

        .badge-success {
            background: #52c41a;
        }

        .badge-danger {
            background: #ff4d4f;
        }

        .badge-secondary {
            background: #8c8c8c;
        }

        .badge-info {
            background: #1890ff;
        }

        .badge-orange {
            background: #ff7a00;
        }

        /* 액션 버튼 */
        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 5px;
            transition: all 0.2s;
        }

        .btn-success {
            background: #52c41a;
            color: #fff;
        }

        .btn-success:hover {
            background: #46a116;
            transform: translateY(-1px);
        }

        .btn-danger {
            background: #ff4d4f;
            color: #fff;
        }

        .btn-danger:hover {
            background: #e63d40;
            transform: translateY(-1px);
        }

        .btn-info {
            background: #1890ff;
            color: #fff;
        }

        .btn-info:hover {
            background: #1573d4;
            transform: translateY(-1px);
        }

        /* 상세 정보 스타일 */
        .detail-info {
            font-size: 11px;
            color: #666;
            margin-top: 3px;
        }

        .reason-text {
            max-width: 200px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            cursor: pointer;
            color: #0066cc;
            padding: 4px 8px;
            background: #f0f8ff;
            border-radius: 4px;
            border: 1px dashed #0066cc;
        }

        .reason-text:hover {
            background: #e6f3ff;
            text-decoration: underline;
        }

        .no-data {
            text-align: center;
            padding: 40px;
            color: #999;
            background: #f8f9fa;
        }

        /* 모달 스타일 */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            animation: fadeIn 0.3s ease;
        }

        .modal.show {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-content {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            width: 500px;
            max-width: 90%;
            max-height: 80vh;
            overflow-y: auto;
            animation: slideIn 0.3s ease;
        }

        .modal-header {
            padding: 20px;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-title {
            font-size: 18px;
            font-weight: 600;
            color: #333;
            margin: 0;
        }

        .modal-close {
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: #999;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
        }

        .modal-close:hover {
            background: #f8f9fa;
            color: #666;
        }

        .modal-body {
            padding: 20px;
        }

        .modal-footer {
            padding: 15px 20px;
            border-top: 1px solid #e9ecef;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #333;
            font-size: 14px;
        }

        .form-control {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #d9d9d9;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.2s;
        }

        .form-control:focus {
            outline: none;
            border-color: #3366ff;
            box-shadow: 0 0 0 2px rgba(51, 102, 255, 0.1);
        }

        textarea.form-control {
            resize: vertical;
            min-height: 100px;
        }

        .btn-modal {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-modal-primary {
            background: #3366ff;
            color: #fff;
        }

        .btn-modal-primary:hover {
            background: #254eda;
        }

        .btn-modal-success {
            background: #52c41a;
            color: #fff;
        }

        .btn-modal-success:hover {
            background: #46a116;
        }

        .btn-modal-danger {
            background: #ff4d4f;
            color: #fff;
        }

        .btn-modal-danger:hover {
            background: #e63d40;
        }

        .btn-modal-secondary {
            background: #6c757d;
            color: #fff;
        }

        .btn-modal-secondary:hover {
            background: #5a6268;
        }

        .request-info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 15px;
        }

        .request-info h4 {
            margin: 0 0 10px 0;
            color: #333;
            font-size: 16px;
        }

        .info-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 5px;
            font-size: 14px;
        }

        .info-label {
            font-weight: 500;
            color: #666;
        }

        .info-value {
            color: #333;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes slideIn {
            from { transform: scale(0.9) translateY(-50px); opacity: 0; }
            to { transform: scale(1) translateY(0); opacity: 1; }
        }
    </style>
</head>

<body>
    <%@ include file="../layout/sidebar.jsp" %>
    <div class="content">
        <%@ include file="../layout/header.jsp" %>
        <div class="main-body">
            
            <!-- 페이지 헤더 -->
            <div class="page-header">
                <h1 class="page-title">🚨 특별 대여 신청 관리</h1>
                <div class="stats-summary">
                    <div class="stat-item">
                        <div class="stat-number">${totalCount != null ? totalCount : 0}</div>
                        <div class="stat-label">총 신청</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">${pendingCount != null ? pendingCount : 0}</div>
                        <div class="stat-label">승인 대기</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">${emergencyCount != null ? emergencyCount : 0}</div>
                        <div class="stat-label">긴급</div>
                    </div>
                </div>
            </div>

            <!-- 디버깅 정보 -->
            <div class="debug-info">
                <div class="debug-title">🔍 디버깅 정보</div>
                <div class="debug-row">표시된 요청 목록: ${requests != null ? requests.size() : 0}개</div>
                <div class="debug-row">통계 - 총 ${totalCount != null ? totalCount : 0}개, 승인대기 ${pendingCount != null ? pendingCount : 0}개, 긴급 ${emergencyCount != null ? emergencyCount : 0}개</div>
                <div class="debug-row">현재 페이지: ${currentPage != null ? currentPage : 1}</div>
                <div class="debug-row">필터: 상태=${not empty param.status ? param.status : '전체'}, 긴급도=${not empty param.urgency ? param.urgency : '전체'}</div>
            </div>

            <!-- 필터 영역 -->
            <div class="filter-section">
                <form method="get" action="<c:url value='/special-rental/admin/list'/>">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label class="filter-label">상태</label>
                            <select name="status" class="filter-control">
                                <option value="">전체</option>
                                <option value="PENDING" ${param.status == 'PENDING' ? 'selected' : ''}>승인 대기</option>
                                <option value="APPROVED" ${param.status == 'APPROVED' ? 'selected' : ''}>승인됨</option>
                                <option value="REJECTED" ${param.status == 'REJECTED' ? 'selected' : ''}>반려됨</option>
                                <option value="CANCELLED" ${param.status == 'CANCELLED' ? 'selected' : ''}>취소됨</option>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label class="filter-label">긴급도</label>
                            <select name="urgency" class="filter-control">
                                <option value="">전체</option>
                                <option value="EMERGENCY" ${param.urgency == 'EMERGENCY' ? 'selected' : ''}>긴급</option>
                                <option value="HIGH" ${param.urgency == 'HIGH' ? 'selected' : ''}>높음</option>
                                <option value="MEDIUM" ${param.urgency == 'MEDIUM' ? 'selected' : ''}>보통</option>
                                <option value="LOW" ${param.urgency == 'LOW' ? 'selected' : ''}>낮음</option>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label class="filter-label">검색</label>
                            <input type="text" name="search" class="filter-control" placeholder="학번, 이름, 기자재명" value="${not empty param.search ? param.search : ''}" />
                        </div>
                        <div class="filter-group">
                            <label class="filter-label">&nbsp;</label>
                            <button type="submit" class="btn-filter">검색</button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- 테이블 영역 -->
            <div class="table-container">
                <table class="table">
                    <thead>
                        <tr>
                            <th>신청번호</th>
                            <th>신청자</th>
                            <th>기자재</th>
                            <th>수량</th>
                            <th>신청사유</th>
                            <th>긴급도</th>
                            <th>상태</th>
                            <th>신청일</th>
                            <th>액션</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty requests}">
                                <c:forEach var="request" items="${requests}" varStatus="status">
                                    <tr>
                                        <td>#${request.id != null ? request.id : 'N/A'}</td>
                                        <td>
                                            <strong>${not empty request.userName ? request.userName : '사용자'}</strong><br>
                                            <small class="detail-info">${not empty request.userUsername ? request.userUsername : '-'}</small>
                                        </td>
                                        <td>
                                            <strong>${not empty request.equipmentName ? request.equipmentName : (request.equipmentId != null ? request.equipmentId : 'N/A')}</strong><br>
                                            <small class="detail-info">${not empty request.equipmentCategory ? request.equipmentCategory : '일반'}</small>
                                        </td>
                                        <td>${request.requestedQuantity != null ? request.requestedQuantity : 0}개</td>
                                        <td>
                                            <div class="reason-text" title="사용 목적 상세보기">
                                                <c:choose>
                                                    <c:when test="${not empty request.purpose}">
                                                        ${fn:length(request.purpose) > 15 ? fn:substring(request.purpose, 0, 15).concat("...") : request.purpose}
                                                    </c:when>
                                                    <c:otherwise>
                                                        사용 목적 없음
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                        <td>

                                            
                                            <c:choose>
                                                <c:when test="${request.urgencyLevel == 'EMERGENCY'}">
                                                    <span class="badge badge-danger">🚨 긴급</span>
                                                </c:when>
                                                <c:when test="${request.urgencyLevel == 'HIGH'}">
                                                    <span class="badge badge-orange">높음</span>
                                                </c:when>
                                                <c:when test="${request.urgencyLevel == 'MEDIUM'}">
                                                    <span class="badge badge-warning">보통</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-secondary">낮음</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${request.status == 'PENDING'}">
                                                    <span class="badge badge-warning">대기중</span>
                                                </c:when>
                                                <c:when test="${request.status == 'APPROVED'}">
                                                    <span class="badge badge-success">승인됨</span>
                                                </c:when>
                                                <c:when test="${request.status == 'REJECTED'}">
                                                    <span class="badge badge-danger">반려됨</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-secondary">취소됨</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${request.createdAtAsDate != null}">
                                                    <fmt:formatDate value="${request.createdAtAsDate}" pattern="MM-dd HH:mm" />
                                                </c:when>
                                                <c:otherwise>
                                                    -
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${request.status == 'PENDING'}">
                                                    <button type="button" class="btn-sm btn-success approval-btn"
                                                            data-id="${request.id}"
                                                            data-equipment="${fn:escapeXml(request.equipmentName)}"
                                                            data-user="${fn:escapeXml(request.userName)}"
                                                            data-quantity="${request.requestedQuantity}"
                                                            data-purpose="${fn:escapeXml(request.purpose)}">
                                                        ✅ 승인
                                                    </button>
                                                    <button type="button" class="btn-sm btn-danger rejection-btn"
                                                            data-id="${request.id}"
                                                            data-equipment="${fn:escapeXml(request.equipmentName)}"
                                                            data-user="${fn:escapeXml(request.userName)}"
                                                            data-quantity="${request.requestedQuantity}"
                                                            data-purpose="${fn:escapeXml(request.purpose)}">
                                                        ❌ 반려
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="btn-sm btn-info" style="pointer-events: none;">처리완료</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="9" class="no-data">
                                        특별 대여 신청이 없습니다.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 승인 모달 -->
    <div id="approvalModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">✅ 특별 대여 신청 승인</h3>
                <button class="modal-close" onclick="closeApprovalModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="request-info">
                    <h4>신청 정보</h4>
                    <div class="info-item">
                        <span class="info-label">신청자:</span>
                        <span class="info-value" id="approvalUserName"></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">기자재:</span>
                        <span class="info-value" id="approvalEquipmentName"></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">수량:</span>
                        <span class="info-value" id="approvalQuantity"></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">사용 목적:</span>
                        <span class="info-value" id="approvalPurpose"></span>
                    </div>
                </div>
                <form id="approvalForm" method="post">
                    <div class="form-group">
                        <label class="form-label">승인 사유 (선택사항)</label>
                        <textarea name="approvalReason" class="form-control" placeholder="승인 사유를 입력하세요... (예: 요구사항이 적절하여 승인함)">관리자 승인</textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modal btn-modal-secondary" onclick="closeApprovalModal()">취소</button>
                <button type="button" class="btn-modal btn-modal-success" onclick="confirmApproval()">✅ 승인 확정</button>
            </div>
        </div>
    </div>

    <!-- 반려 모달 -->
    <div id="rejectionModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">❌ 특별 대여 신청 반려</h3>
                <button class="modal-close" onclick="closeRejectionModal()">&times;</button>
            </div>
            <div class="modal-body">
                <div class="request-info">
                    <h4>신청 정보</h4>
                    <div class="info-item">
                        <span class="info-label">신청자:</span>
                        <span class="info-value" id="rejectionUserName"></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">기자재:</span>
                        <span class="info-value" id="rejectionEquipmentName"></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">수량:</span>
                        <span class="info-value" id="rejectionQuantity"></span>
                    </div>
                    <div class="info-item">
                        <span class="info-label">사용 목적:</span>
                        <span class="info-value" id="rejectionPurpose"></span>
                    </div>
                </div>
                <form id="rejectionForm" method="post">
                    <div class="form-group">
                        <label class="form-label">반려 사유 <span style="color: #ff4d4f;">*</span></label>
                        <textarea name="rejectionReason" class="form-control" required placeholder="반려 사유를 구체적으로 입력하세요...&#10;예:&#10;- 사용 목적이 부적절함&#10;- 신청 수량이 과도함&#10;- 필요한 서류가 부족함"></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-modal btn-modal-secondary" onclick="closeRejectionModal()">취소</button>
                <button type="button" class="btn-modal btn-modal-danger" onclick="confirmRejection()">❌ 반려 확정</button>
            </div>
        </div>
    </div>

    <script>
    let currentRequestId = null;

    // DOM 로드 완료 후 이벤트 리스너 등록
    document.addEventListener('DOMContentLoaded', function() {
        // 승인 버튼 이벤트 리스너
        document.querySelectorAll('.approval-btn').forEach(button => {
            button.addEventListener('click', function() {
                const requestId = this.getAttribute('data-id');
                const equipmentName = this.getAttribute('data-equipment');
                const userName = this.getAttribute('data-user');
                const quantity = this.getAttribute('data-quantity');
                const purpose = this.getAttribute('data-purpose');
                
                openApprovalModal(requestId, equipmentName, userName, quantity, purpose);
            });
        });

        // 반려 버튼 이벤트 리스너
        document.querySelectorAll('.rejection-btn').forEach(button => {
            button.addEventListener('click', function() {
                const requestId = this.getAttribute('data-id');
                const equipmentName = this.getAttribute('data-equipment');
                const userName = this.getAttribute('data-user');
                const quantity = this.getAttribute('data-quantity');
                const purpose = this.getAttribute('data-purpose');
                
                openRejectionModal(requestId, equipmentName, userName, quantity, purpose);
            });
        });
    });

    // 승인 모달 열기
    function openApprovalModal(requestId, equipmentName, userName, quantity, purpose) {
        currentRequestId = requestId;
        
        document.getElementById('approvalUserName').textContent = userName || '사용자';
        document.getElementById('approvalEquipmentName').textContent = equipmentName || '기자재';
        document.getElementById('approvalQuantity').textContent = (quantity || 0) + '개';
        document.getElementById('approvalPurpose').textContent = purpose || '사용 목적 없음';
        
        document.getElementById('approvalForm').action = '/special-rental/admin/approve/' + requestId;
        document.getElementById('approvalModal').classList.add('show');
    }

    // 승인 모달 닫기
    function closeApprovalModal() {
        document.getElementById('approvalModal').classList.remove('show');
        document.querySelector('#approvalForm textarea[name="approvalReason"]').value = '관리자 승인';
        currentRequestId = null;
    }

    // 승인 확정
    function confirmApproval() {
        const form = document.getElementById('approvalForm');
        const formData = new FormData(form);
        
        fetch(form.action, {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('✅ 특별 대여 신청이 승인되었습니다!\n기자재 수량이 차감되고 사용자에게 알림이 발송됩니다.');
                closeApprovalModal();
                location.reload();
            } else {
                alert('❌ 승인 처리 중 오류가 발생했습니다:\n' + data.message);
            }
        })
        .catch(error => {
            alert('❌ 승인 처리 중 네트워크 오류가 발생했습니다.');
            console.error('Error:', error);
        });
    }

    // 반려 모달 열기
    function openRejectionModal(requestId, equipmentName, userName, quantity, purpose) {
        currentRequestId = requestId;
        
        document.getElementById('rejectionUserName').textContent = userName || '사용자';
        document.getElementById('rejectionEquipmentName').textContent = equipmentName || '기자재';
        document.getElementById('rejectionQuantity').textContent = (quantity || 0) + '개';
        document.getElementById('rejectionPurpose').textContent = purpose || '사용 목적 없음';
        
        document.getElementById('rejectionForm').action = '/special-rental/admin/reject/' + requestId;
        document.getElementById('rejectionModal').classList.add('show');
    }

    // 반려 모달 닫기
    function closeRejectionModal() {
        document.getElementById('rejectionModal').classList.remove('show');
        document.querySelector('#rejectionForm textarea[name="rejectionReason"]').value = '';
        currentRequestId = null;
    }

    // 반려 확정
    function confirmRejection() {
        const form = document.getElementById('rejectionForm');
        const reasonTextarea = form.querySelector('textarea[name="rejectionReason"]');
        
        if (!reasonTextarea.value.trim()) {
            alert('❌ 반려 사유를 입력해주세요.');
            reasonTextarea.focus();
            return;
        }
        
        const formData = new FormData(form);
        
        fetch(form.action, {
            method: 'POST',
            body: formData
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('❌ 특별 대여 신청이 반려되었습니다.\n사용자에게 반려 사유와 함께 알림이 발송됩니다.');
                closeRejectionModal();
                location.reload();
            } else {
                alert('❌ 반려 처리 중 오류가 발생했습니다:\n' + data.message);
            }
        })
        .catch(error => {
            alert('❌ 반려 처리 중 네트워크 오류가 발생했습니다.');
            console.error('Error:', error);
        });
    }

    // 모달 외부 클릭 시 닫기
    window.onclick = function(event) {
        const approvalModal = document.getElementById('approvalModal');
        const rejectionModal = document.getElementById('rejectionModal');
        
        if (event.target === approvalModal) {
            closeApprovalModal();
        }
        if (event.target === rejectionModal) {
            closeRejectionModal();
        }
    }

    // ESC 키로 모달 닫기
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape') {
            closeApprovalModal();
            closeRejectionModal();
        }
    });
    </script>
</body>
</html> 