<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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
    background: #f8f9fa;
}

.content {
    padding: 20px;
}

.page-header {
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    margin-bottom: 20px;
}

.page-title {
    font-size: 24px;
    color: #333;
    margin-bottom: 10px;
}

.form-container {
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    padding: 20px;
}

.form-group {
    margin-bottom: 20px;
}

.form-label {
    display: block;
    font-weight: 500;
    color: #333;
    margin-bottom: 5px;
}

.form-control {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #d9d9d9;
    border-radius: 4px;
    font-size: 14px;
}

.btn {
    padding: 12px 24px;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;
    text-align: center;
}

.btn-primary {
    background: #3366ff;
    color: #fff;
}

.btn-outline {
    background: #fff;
    color: #666;
    border: 1px solid #d9d9d9;
}
</style>

<body>
    <%@ include file="../layout/sidebar.jsp" %>
    <div class="content">
        <%@ include file="../layout/header.jsp" %>
        <div class="main-body">
            
            <!-- 페이지 헤더 -->
            <div class="page-header">
                <h1 class="page-title">🚨 특별 대여 신청</h1>
                <p>일반 대여 한도를 초과하거나 수량이 부족한 경우 특별 신청을 할 수 있습니다.</p>
            </div>

            <form action="<c:url value='/special-rental/request'/>" method="post">
                <div class="form-container">
                    
                    <!-- 기자재 정보 -->
                    <c:if test="${not empty equipment}">
                        <div class="form-group">
                            <label class="form-label">선택된 기자재</label>
                            <div style="background: #f8f9fa; padding: 15px; border-radius: 6px;">
                                <strong>${equipment.name}</strong><br>
                                현재 대여 가능 수량: ${equipment.availableQuantity}/${equipment.quantity}
                            </div>
                            <input type="hidden" name="equipmentId" value="${equipment.id}" />
                        </div>
                    </c:if>
                    
                    <!-- 신청 수량 -->
                    <div class="form-group">
                        <label class="form-label">신청 수량 *</label>
                        <input type="number" name="requestedQuantity" class="form-control" 
                               min="1" max="99" value="1" required />
                    </div>

                    <!-- 사용 목적 -->
                    <div class="form-group">
                        <label class="form-label">사용 목적 *</label>
                        <textarea name="purpose" class="form-control" required 
                                  placeholder="기자재를 어떤 용도로 사용하실 예정인지 구체적으로 작성해주세요."></textarea>
                    </div>

                    <!-- 특별 신청 사유 -->
                    <div class="form-group">
                        <label class="form-label">특별 신청 사유 *</label>
                        <textarea name="specialReason" class="form-control" required 
                                  placeholder="왜 일반 대여가 아닌 특별 대여가 필요한지 자세한 사유를 작성해주세요."></textarea>
                    </div>

                    <!-- 긴급도 -->
                    <div class="form-group">
                        <label class="form-label">긴급도</label>
                        <select name="urgencyLevel" class="form-control">
                            <option value="LOW">낮음</option>
                            <option value="MEDIUM" selected>보통</option>
                            <option value="HIGH">높음</option>
                            <option value="EMERGENCY">긴급</option>
                        </select>
                    </div>

                    <!-- 신청 유형 -->
                    <div class="form-group">
                        <label class="form-label">신청 유형</label>
                        <select name="requestType" class="form-control">
                            <option value="QUANTITY_EXCEED">수량 초과 신청</option>
                            <option value="ADDITIONAL_RENTAL">추가 대여 신청</option>
                            <option value="LIMIT_EXCEED">제한 초과 신청</option>
                        </select>
                    </div>

                    <!-- 버튼 -->
                    <div style="display: flex; gap: 10px; justify-content: center; margin-top: 30px;">
                        <a href="javascript:history.back()" class="btn btn-outline">취소</a>
                        <button type="submit" class="btn btn-primary">특별 대여 신청</button>
                    </div>
                </div>
            </form>
        </div>
        <%@ include file="../layout/footer.jsp" %>
    </div>
</body>
</html> 