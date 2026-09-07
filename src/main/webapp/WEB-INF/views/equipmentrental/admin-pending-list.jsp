<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../layout/head-meta.jsp" %>

<head>
    <meta charset="UTF-8">
    <title>기자재 대여 승인 관리</title>
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

        /* content 스타일은 head-meta.jsp에서 관리 */

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

        .user-avatar {
            width: 32px;
            height: 32px;
            background-color: #007bff;
            color: #fff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 10px;
            font-size: 14px;
            font-weight: 500;
        }

        .empty-state {
            margin: 30px 0;
            padding: 40px 20px;
            background-color: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            text-align: center;
        }

        .approval-summary {
            margin-bottom: 25px;
            padding: 15px 20px;
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 6px;
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
                <h1 class="page-title">🔧 기자재 대여 승인 관리</h1>
                <div class="stats-summary">
                    <div class="stat-item">
                        <div class="stat-number">${fn:length(pendingList)}</div>
                        <div class="stat-label">승인 대기</div>
                    </div>
                </div>
            </div>

            <!-- 승인 대기 없음 -->
            <c:if test="${empty pendingList}">
                <div class="empty-state">
                    <div style="font-size: 48px; color: #6c757d; margin-bottom: 20px;">📋</div>
                    <h3 style="color: #495057; margin-bottom: 15px;">승인 대기 중인 요청이 없습니다</h3>
                    <p style="margin: 0 0 25px 0; font-size: 16px; color: #6c757d;">현재 처리할 대여 요청이 없습니다.</p>
                    <div>
                        <a href="${pageContext.request.contextPath}/equipment/list"
                           style="display: inline-block; padding: 12px 24px; background-color: #28a745; color: #fff; text-decoration: none; border-radius: 6px; font-size: 16px; font-weight: 500;">
                            기자재 관리 페이지로 돌아가기
                        </a>
                    </div>
                </div>
            </c:if>

            <!-- 승인 대기 있음 -->
            <c:if test="${!empty pendingList}">
                <div class="approval-summary">
                    <div style="display: flex; align-items: center; justify-content: space-between;">
                        <div>
                            <strong style="color: #856404;">⏳ 총 ${fn:length(pendingList)}건의 요청이 승인을 기다리고 있습니다</strong>
                        </div>
                        <div>
                            <small style="color: #856404;">각 요청을 검토하고 승인 또는 반려 처리해주세요</small>
                        </div>
                    </div>
                </div>

                <!-- 테이블 영역 -->
                <div class="table-container">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>요청번호</th>
                                <th>기자재 정보</th>
                                <th>대여자</th>
                                <th>대여 기간</th>
                                <th>목적</th>
                                <th>신청일시</th>
                                <th>액션</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="req" items="${pendingList}" varStatus="status">
                                <tr>
                                    <td>#${req.id}</td>
                                    <td>
                                        <strong>기자재 ID: ${req.equipmentId}</strong><br>
                                        <small class="detail-info">신청 수량: ${req.requestedQuantity}개</small>
                                    </td>
                                    <td>
                                        <div style="display: flex; align-items: center;">
                                            <div class="user-avatar">
                                                <c:choose>
                                                    <c:when test="${not empty req.user.name}">
                                                        ${fn:substring(req.user.name, 0, 1)}
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${fn:substring(req.userId, 0, 1)}
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div>
                                                <c:choose>
                                                    <c:when test="${not empty req.user.name}">
                                                        <div style="font-weight: 500; color: #212529;">${req.user.name}</div>
                                                        <div class="detail-info">ID: ${req.user.username}</div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div style="font-weight: 500; color: #212529;">사용자 ID: ${req.userId}</div>
                                                        <div class="detail-info">대여 신청자</div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div>
                                            <strong><fmt:formatDate value="${req.rentDate}" pattern="MM-dd HH:mm" /></strong><br>
                                            <small class="detail-info">~<fmt:formatDate value="${req.expectedReturnDate}" pattern="MM-dd HH:mm" /></small>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${req.purpose}">
                                            ${req.purpose}
                                        </div>
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${req.createdAt}" pattern="MM-dd HH:mm" />
                                    </td>
                                    <td>
                                        <button type="button" class="btn-sm btn-success approval-btn"
                                                data-id="${req.id}"
                                                data-equipment-id="${req.equipmentId}"
                                                data-user-name="${not empty req.user.name ? fn:escapeXml(req.user.name) : req.userId}"
                                                data-quantity="${req.requestedQuantity}"
                                                data-purpose="${fn:escapeXml(req.purpose)}">
                                            ✅ 승인
                                        </button>
                                        <button type="button" class="btn-sm btn-danger rejection-btn"
                                                data-id="${req.id}"
                                                data-equipment-id="${req.equipmentId}"
                                                data-user-name="${not empty req.user.name ? fn:escapeXml(req.user.name) : req.userId}"
                                                data-quantity="${req.requestedQuantity}"
                                                data-purpose="${fn:escapeXml(req.purpose)}">
                                            ❌ 반려
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #e9ecef; display: flex; justify-content: space-between; align-items: center;">
                    <div style="color: #6c757d;">
                        <small>총 ${fn:length(pendingList)}건의 요청 • 신중하게 검토 후 처리해주세요</small>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/equipment/list"
                           style="display: inline-block; padding: 10px 20px; background-color: #007bff; color: #fff; text-decoration: none; border-radius: 5px; font-size: 14px; font-weight: 500;">
                            🔧 기자재 관리로 이동
                        </a>
                    </div>
                </div>
            </c:if>
        </div>
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 승인 모달 -->
    <div id="approvalModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">✅ 기자재 대여 승인</h3>
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
                        <span class="info-value" id="approvalEquipmentId"></span>
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
                <h3 class="modal-title">❌ 기자재 대여 반려</h3>
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
                        <span class="info-value" id="rejectionEquipmentId"></span>
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
                        <textarea name="rejectionReason" class="form-control" required placeholder="반려 사유를 구체적으로 입력하세요...&#10;예:&#10;- 기자재 수량 부족&#10;- 사용 목적이 부적절함&#10;- 필요한 서류가 부족함"></textarea>
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
                const equipmentId = this.getAttribute('data-equipment-id');
                const userName = this.getAttribute('data-user-name');
                const quantity = this.getAttribute('data-quantity');
                const purpose = this.getAttribute('data-purpose');
                
                openApprovalModal(requestId, equipmentId, userName, quantity, purpose);
            });
        });

        // 반려 버튼 이벤트 리스너
        document.querySelectorAll('.rejection-btn').forEach(button => {
            button.addEventListener('click', function() {
                const requestId = this.getAttribute('data-id');
                const equipmentId = this.getAttribute('data-equipment-id');
                const userName = this.getAttribute('data-user-name');
                const quantity = this.getAttribute('data-quantity');
                const purpose = this.getAttribute('data-purpose');
                
                openRejectionModal(requestId, equipmentId, userName, quantity, purpose);
            });
        });
    });

    // 승인 모달 열기
    function openApprovalModal(requestId, equipmentId, userName, quantity, purpose) {
        currentRequestId = requestId;
        
        document.getElementById('approvalUserName').textContent = userName || '사용자';
        document.getElementById('approvalEquipmentId').textContent = '기자재 ID: ' + (equipmentId || 'N/A');
        document.getElementById('approvalQuantity').textContent = (quantity || 0) + '개';
        document.getElementById('approvalPurpose').textContent = purpose || '사용 목적 없음';
        
        document.getElementById('approvalForm').action = '${pageContext.request.contextPath}/equipmentrental/admin/approve/' + requestId;
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
        .then(response => {
            if (response.ok) {
                alert('✅ 기자재 대여 신청이 승인되었습니다!\n사용자에게 알림이 발송됩니다.');
                closeApprovalModal();
                location.reload();
            } else {
                alert('❌ 승인 처리 중 오류가 발생했습니다.');
            }
        })
        .catch(error => {
            alert('❌ 승인 처리 중 네트워크 오류가 발생했습니다.');
            console.error('Error:', error);
        });
    }

    // 반려 모달 열기
    function openRejectionModal(requestId, equipmentId, userName, quantity, purpose) {
        currentRequestId = requestId;
        
        document.getElementById('rejectionUserName').textContent = userName || '사용자';
        document.getElementById('rejectionEquipmentId').textContent = '기자재 ID: ' + (equipmentId || 'N/A');
        document.getElementById('rejectionQuantity').textContent = (quantity || 0) + '개';
        document.getElementById('rejectionPurpose').textContent = purpose || '사용 목적 없음';
        
        document.getElementById('rejectionForm').action = '${pageContext.request.contextPath}/equipmentrental/admin/reject/' + requestId;
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
        .then(response => {
            if (response.ok) {
                alert('❌ 기자재 대여 신청이 반려되었습니다.\n사용자에게 반려 사유와 함께 알림이 발송됩니다.');
                closeRejectionModal();
                location.reload();
            } else {
                alert('❌ 반려 처리 중 오류가 발생했습니다.');
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