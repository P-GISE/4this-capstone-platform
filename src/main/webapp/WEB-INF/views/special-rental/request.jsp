<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ include file="../layout/head-meta.jsp" %>
<style>
/* 기본 스타일 */
* {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f8f9fa;
            color: #2d3748;
            line-height: 1.6;
        }

.content {
    padding: 20px;
}

/* 페이지 헤더 */
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

.page-description {
    color: #666;
    font-size: 14px;
}

/* 폼 컨테이너 */
.form-container {
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    overflow: hidden;
}

.form-section {
    padding: 20px;
    border-bottom: 1px solid #f0f0f0;
}

.form-section:last-child {
    border-bottom: none;
}

.section-title {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    margin-bottom: 15px;
    display: flex;
    align-items: center;
}

.section-title::before {
    content: '';
    width: 4px;
    height: 16px;
    background: #3366ff;
    margin-right: 10px;
}

/* 기자재 정보 표시 */
.equipment-info {
    background: #f8f9fa;
    border-radius: 6px;
    padding: 15px;
    margin-bottom: 15px;
}

.equipment-name {
    font-size: 18px;
    font-weight: 600;
    color: #333;
    margin-bottom: 8px;
}

.equipment-details {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 10px;
    font-size: 14px;
    color: #666;
}

.equipment-detail-item {
    display: flex;
    justify-content: space-between;
}

/* 폼 그룹 */
.form-group {
    margin-bottom: 20px;
}

.form-label {
    display: block;
    font-weight: 500;
    color: #333;
    margin-bottom: 5px;
    font-size: 14px;
}

.required {
    color: #ff4d4f;
}

.form-control {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #d9d9d9;
    border-radius: 4px;
    font-size: 14px;
    transition: border-color 0.2s;
}

.form-control:focus {
    outline: none;
    border-color: #3366ff;
    box-shadow: 0 0 0 2px rgba(51, 102, 255, 0.1);
}

.form-control-sm {
    padding: 8px 10px;
    width: auto;
    min-width: 120px;
}

textarea.form-control {
    resize: vertical;
    min-height: 80px;
}

/* 인라인 폼 그룹 */
.form-inline {
    display: flex;
    gap: 15px;
    align-items: center;
    flex-wrap: wrap;
}

.form-inline .form-group {
    margin-bottom: 0;
    flex: 1;
    min-width: 200px;
}

/* 신청 유형 선택 */
.request-type-group {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 10px;
    margin-bottom: 15px;
}

.request-type-item {
    border: 1px solid #d9d9d9;
    border-radius: 6px;
    padding: 15px;
    cursor: pointer;
    transition: all 0.2s;
    background: #fff;
}

.request-type-item:hover {
    border-color: #3366ff;
    background: #f6f8ff;
}

.request-type-item.selected {
    border-color: #3366ff;
    background: #f6f8ff;
    box-shadow: 0 0 0 2px rgba(51, 102, 255, 0.1);
}

.request-type-item input[type="radio"] {
    margin-right: 8px;
}

.request-type-title {
    font-weight: 500;
    color: #333;
    margin-bottom: 5px;
}

.request-type-desc {
    font-size: 12px;
    color: #666;
}

/* 긴급도 선택 */
.urgency-group {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}

.urgency-item {
    flex: 1;
    min-width: 100px;
    border: 1px solid #d9d9d9;
    border-radius: 6px;
    padding: 10px;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s;
}

.urgency-item:hover {
    border-color: #3366ff;
}

.urgency-item.selected {
    border-color: #3366ff;
    background: #f6f8ff;
}

.urgency-item input[type="radio"] {
    display: none;
}

.urgency-level {
    font-weight: 500;
    margin-bottom: 3px;
}

.urgency-desc {
    font-size: 11px;
    color: #666;
}

/* 경고 메시지 */
.warning-box {
    background: #fff7e6;
    border: 1px solid #ffd666;
    border-radius: 6px;
    padding: 15px;
    margin-bottom: 20px;
}

.warning-title {
    color: #d48806;
    font-weight: 500;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
}

.warning-title::before {
    content: '⚠️';
    margin-right: 5px;
}

.warning-content {
    color: #ad6800;
    font-size: 13px;
    line-height: 1.4;
}

/* 버튼 그룹 */
.button-group {
    display: flex;
    gap: 10px;
    justify-content: center;
    padding: 20px;
}

.btn {
    padding: 12px 24px;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    text-decoration: none;
    display: inline-block;
    text-align: center;
    min-width: 100px;
}

.btn-primary {
    background: #3366ff;
    color: #fff;
}

.btn-primary:hover {
    background: #254eda;
}

.btn-secondary {
    background: #6c757d;
    color: #fff;
}

.btn-secondary:hover {
    background: #545b62;
}

.btn-outline {
    background: #fff;
    color: #666;
    border: 1px solid #d9d9d9;
}

.btn-outline:hover {
    background: #f8f9fa;
    border-color: #999;
}

/* 알림 메시지 */
.alert {
    padding: 12px 16px;
    border-radius: 6px;
    margin-bottom: 20px;
    font-size: 14px;
}

.alert-success {
    background: #f6ffed;
    border: 1px solid #b7eb8f;
    color: #52c41a;
}

.alert-error {
    background: #fff2f0;
    border: 1px solid #ffccc7;
    color: #ff4d4f;
}

/* 첨부파일 영역 */
.file-upload-area {
    border: 2px dashed #d9d9d9;
    border-radius: 6px;
    padding: 20px;
    text-align: center;
    transition: border-color 0.2s;
    background: #fafafa;
}

.file-upload-area:hover {
    border-color: #3366ff;
    background: #f6f8ff;
}

.file-upload-icon {
    font-size: 32px;
    color: #d9d9d9;
    margin-bottom: 10px;
}

.file-upload-text {
    color: #666;
    font-size: 14px;
}

.file-input {
    margin-top: 10px;
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
                <p class="page-description">
                    현재 대여중인 기자재에 대해 추가 대여나 제한 초과 신청을 할 수 있습니다. 특별한 사유가 있는 경우에만 신청해주세요.
                </p>
            </div>

            <!-- 성공/오류 메시지 -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success">
                    ${successMessage}
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-error">
                    ${errorMessage}
                </div>
            </c:if>

            <form action="<c:url value='/special-rental/request'/>" method="post" enctype="multipart/form-data">
                <div class="form-container">
                    
                    <!-- 기자재 정보 섹션 -->
                    <div class="form-section">
                        <div class="section-title">📱 대상 기자재</div>
                        
                        <c:choose>
                            <c:when test="${not empty equipment}">
                                <!-- 미리 선택된 기자재가 있는 경우 -->
                                <div class="equipment-info">
                                    <div class="equipment-name">${equipment.name}</div>
                                    <div class="equipment-details">
                                        <div class="equipment-detail-item">
                                            <span>카테고리:</span>
                                            <span>${equipment.category}</span>
                                        </div>
                                        <div class="equipment-detail-item">
                                            <span>현재 대여 가능 수량:</span>
                                            <span>${equipment.availableQuantity}/${equipment.quantity}</span>
                                        </div>
                                        <c:if test="${equipment.maxRentalQuantity != null}">
                                            <div class="equipment-detail-item">
                                                <span>1인당 대여 제한:</span>
                                                <span>${equipment.maxRentalQuantity}개</span>
                                            </div>
                                        </c:if>
                                        <div class="equipment-detail-item">
                                            <span>위치:</span>
                                            <span>${equipment.location}</span>
                                        </div>
                                    </div>
                                </div>
                                <input type="hidden" name="equipmentId" value="${equipment.id}" />
                            </c:when>
                            <c:otherwise>
                                <!-- 기자재 선택 필요 -->
                                <div class="form-group">
                                    <label class="form-label">기자재 선택 <span class="required">*</span></label>
                                    <select name="equipmentId" class="form-control" required>
                                        <option value="">기자재를 선택해주세요</option>
                                        <!-- AJAX로 기자재 목록 로드 -->
                                    </select>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- 신청 유형 섹션 -->
                    <div class="form-section">
                        <div class="section-title">📋 신청 유형</div>
                        
                        <div class="request-type-group">
                            <div class="request-type-item" onclick="selectRequestType('ADDITIONAL_RENTAL', this)">
                                <input type="radio" name="requestType" value="ADDITIONAL_RENTAL" />
                                <div class="request-type-title">추가 대여 신청</div>
                                <div class="request-type-desc">현재 대여 중인 기자재와 동일한 기자재를 추가로 대여</div>
                            </div>
                            <div class="request-type-item" onclick="selectRequestType('LIMIT_EXCEED', this)">
                                <input type="radio" name="requestType" value="LIMIT_EXCEED" />
                                <div class="request-type-title">제한 초과 신청</div>
                                <div class="request-type-desc">1인당 대여 제한 수량을 초과하여 신청</div>
                            </div>
                        </div>
                    </div>

                    <!-- 신청 상세 정보 섹션 -->
                    <div class="form-section">
                        <div class="section-title">📝 신청 상세 정보</div>
                        
                        <div class="form-inline">
                            <div class="form-group">
                                <label class="form-label">신청 수량 <span class="required">*</span></label>
                                <input type="number" name="requestedQuantity" class="form-control form-control-sm" 
                                       min="1" max="99" value="1" required />
                            </div>
                            <div class="form-group">
                                <label class="form-label">예상 사용 기간 <span class="required">*</span></label>
                                <select name="expectedUsagePeriod" class="form-control" required>
                                    <option value="">선택해주세요</option>
                                    <option value="1">1일</option>
                                    <option value="3">3일</option>
                                    <option value="7">1주일</option>
                                    <option value="14">2주일</option>
                                    <option value="30">1개월</option>
                                    <option value="0">직접 입력</option>
                                </select>
                            </div>
                        </div>

                        <div class="form-inline">
                            <div class="form-group">
                                <label class="form-label">사용 시작 예정일 <span class="required">*</span></label>
                                <input type="date" name="expectedStartDate" class="form-control" required 
                                       min="<fmt:formatDate value='<%=new java.util.Date()%>' pattern='yyyy-MM-dd'/>" />
                            </div>
                            <div class="form-group">
                                <label class="form-label">사용 종료 예정일 <span class="required">*</span></label>
                                <input type="date" name="expectedEndDate" class="form-control" required 
                                       min="<fmt:formatDate value='<%=new java.util.Date()%>' pattern='yyyy-MM-dd'/>" />
                            </div>
                        </div>
                    </div>

                    <!-- 사용 목적 및 특별 사유 섹션 -->
                    <div class="form-section">
                        <div class="section-title">💭 사용 목적 및 특별 사유</div>
                        
                        <div class="form-group">
                            <label class="form-label">사용 목적 <span class="required">*</span></label>
                            <textarea name="purpose" class="form-control" required 
                                      placeholder="기자재를 어떤 용도로 사용하실 예정인지 구체적으로 작성해주세요."></textarea>
                        </div>

                        <div class="form-group">
                            <label class="form-label">특별 신청 사유 <span class="required">*</span></label>
                            <textarea name="specialReason" class="form-control" required 
                                      placeholder="왜 일반 대여가 아닌 특별 대여가 필요한지 자세한 사유를 작성해주세요. (예: 프로젝트 마감 임박, 연구 실험 일정, 팀 프로젝트 규모 등)"></textarea>
                        </div>
                    </div>

                    <!-- 긴급도 섹션 -->
                    <div class="form-section">
                        <div class="section-title">⚡ 긴급도</div>
                        
                        <div class="urgency-group">
                            <div class="urgency-item" onclick="selectUrgency('LOW', this)">
                                <input type="radio" name="urgencyLevel" value="LOW" />
                                <div class="urgency-level">낮음</div>
                                <div class="urgency-desc">여유 있음</div>
                            </div>
                            <div class="urgency-item selected" onclick="selectUrgency('MEDIUM', this)">
                                <input type="radio" name="urgencyLevel" value="MEDIUM" checked />
                                <div class="urgency-level">보통</div>
                                <div class="urgency-desc">일반적</div>
                            </div>
                            <div class="urgency-item" onclick="selectUrgency('HIGH', this)">
                                <input type="radio" name="urgencyLevel" value="HIGH" />
                                <div class="urgency-level">높음</div>
                                <div class="urgency-desc">빠른 처리 필요</div>
                            </div>
                            <div class="urgency-item" onclick="selectUrgency('EMERGENCY', this)">
                                <input type="radio" name="urgencyLevel" value="EMERGENCY" />
                                <div class="urgency-level">긴급</div>
                                <div class="urgency-desc">즉시 처리 필요</div>
                            </div>
                        </div>

                        <div class="form-group" style="margin-top: 15px;">
                            <label>
                                <input type="checkbox" name="isEmergency" value="true" style="margin-right: 5px;" />
                                이 신청을 긴급 신청으로 분류 (관리자가 우선적으로 검토)
                            </label>
                        </div>
                    </div>

                    <!-- 첨부파일 섹션 -->
                    <div class="form-section">
                        <div class="section-title">📎 첨부파일 (선택사항)</div>
                        
                        <div class="file-upload-area">
                            <div class="file-upload-icon">📎</div>
                            <div class="file-upload-text">
                                특별 신청 사유를 뒷받침할 수 있는 자료를 첨부해주세요<br>
                                (프로젝트 계획서, 실험 계획서, 지도교수 추천서 등)
                            </div>
                            <input type="file" name="attachments" class="file-input" multiple 
                                   accept=".pdf,.doc,.docx,.jpg,.jpeg,.png,.gif" />
                        </div>
                        <div style="margin-top: 10px; font-size: 12px; color: #666;">
                            지원 형식: PDF, Word, 이미지 파일 (최대 10MB)
                        </div>
                    </div>

                    <!-- 경고 메시지 -->
                    <div class="form-section">
                        <div class="warning-box">
                            <div class="warning-title">특별 대여 신청 안내</div>
                            <div class="warning-content">
                                • 특별 대여 신청은 관리자의 검토를 거쳐 승인/반려가 결정됩니다.<br>
                                • 허위 사유나 부적절한 신청의 경우 반려될 수 있습니다.<br>
                                • 긴급 신청의 경우 24시간 내에 검토 결과를 알려드립니다.<br>
                                • 승인된 특별 대여도 일반 대여와 동일한 관리 규정이 적용됩니다.
                            </div>
                        </div>
                    </div>
                    
                    <!-- 버튼 그룹 -->
                    <div class="button-group">
                        <a href="javascript:history.back()" class="btn btn-outline">취소</a>
                        <button type="submit" class="btn btn-primary">특별 대여 신청</button>
                    </div>
                </div>
            </form>
        </div>
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <script>
    // 페이지 로드 시 기자재 목록 로드
    document.addEventListener('DOMContentLoaded', function() {
        loadEquipmentList();
    });

    // 기자재 목록 로드
    function loadEquipmentList() {
        const equipmentSelect = document.querySelector('select[name="equipmentId"]');
        
        // 기자재 선택 섹션이 있는 경우에만 로드
        if (!equipmentSelect) {
            console.log('기자재 선택 요소가 없습니다.');
            return;
        }
        
        console.log('기자재 목록 로드 시작...');
        
        fetch('/special-rental/api/equipments')
            .then(response => {
                console.log('API 응답 상태:', response.status);
                console.log('응답 헤더:', response.headers.get('content-type'));
                if (!response.ok) {
                    throw new Error('HTTP ' + response.status + ': ' + response.statusText);
                }
                return response.json();
            })
            .then(data => {
                console.log('=== 기자재 API 상세 응답 ===');
                console.log('전체 응답:', data);
                console.log('success:', data.success);
                console.log('message:', data.message);
                console.log('equipments:', data.equipments);
                console.log('equipments 타입:', typeof data.equipments);
                console.log('equipments 배열 여부:', Array.isArray(data.equipments));
                if (data.equipments) {
                    console.log('equipments 길이:', data.equipments.length);
                    data.equipments.forEach((eq, idx) => {
                        console.log(`기자재 ${idx}:`, eq);
                    });
                }
                
                if (data.success && data.equipments && Array.isArray(data.equipments)) {
                    console.log('기자재 개수:', data.equipments.length);
                    
                    if (data.equipments.length === 0) {
                        // 대여중인 기자재가 없는 경우
                        equipmentSelect.innerHTML = '<option value="">현재 대여중인 기자재가 없습니다</option>';
                        
                        // 폼 비활성화 및 안내 메시지 추가
                        const formContainer = document.querySelector('.form-container');
                        if (formContainer) {
                            const warningBox = document.createElement('div');
                            warningBox.className = 'alert alert-error';
                            warningBox.style.marginTop = '15px';
                            warningBox.innerHTML = 
                                '<strong>특별 대여 신청 불가</strong><br>' +
                                '현재 대여중인 기자재가 없어서 특별 대여 신청을 할 수 없습니다.<br>' +
                                '먼저 일반 대여를 진행한 후 특별 대여 신청을 해주세요.';
                            
                            const equipmentSection = formContainer.querySelector('.form-section');
                            equipmentSection.appendChild(warningBox);
                        }
                        
                        // 신청 버튼 비활성화
                        const submitBtn = document.querySelector('button[type="submit"]');
                        if (submitBtn) {
                            submitBtn.disabled = true;
                            submitBtn.style.opacity = '0.5';
                            submitBtn.textContent = '신청 불가';
                        }
                        
                        return;
                    }
                    
                    // 기존 옵션 제거 (첫 번째 기본 옵션 제외)
                    equipmentSelect.innerHTML = '<option value="">현재 대여중인 기자재를 선택해주세요</option>';
                    
                    // 기자재 목록 추가
                    data.equipments.forEach((equipment, index) => {
                        console.log('=== 기자재 상세 처리 ===');
                        console.log('Index:', index);
                        console.log('전체 equipment 객체:', equipment);
                        console.log('equipment.name:', equipment.name);
                        console.log('equipment.category:', equipment.category);
                        console.log('equipment.rentedQuantity:', equipment.rentedQuantity);
                        console.log('equipment.id:', equipment.id);
                        
                        const option = document.createElement('option');
                        option.value = equipment.id || '';
                        
                        // 기자재 이름과 카테고리
                        let optionText = equipment.name || '이름 없음';
                        console.log('기본 이름:', optionText);
                        
                        // 카테고리 추가 (없으면 "일반"으로 표시)
                        const category = equipment.category || '일반';
                        console.log('카테고리:', category);
                        console.log('카테고리 타입:', typeof category);
                        optionText = optionText + ' (' + category + ')';
                        console.log('카테고리 추가 후:', optionText);
                        
                        // 대여 수량 정보 추가 (상세 디버깅)
                        console.log('=== 대여 수량 처리 시작 ===');
                        console.log('equipment.rentedQuantity (원본 값):', equipment.rentedQuantity);
                        console.log('equipment.rentedQuantity 타입:', typeof equipment.rentedQuantity);
                        console.log('equipment.rentedQuantity === null:', equipment.rentedQuantity === null);
                        console.log('equipment.rentedQuantity === undefined:', equipment.rentedQuantity === undefined);
                        
                        let rentedQty = 1; // 기본값
                        if (equipment.rentedQuantity !== undefined && equipment.rentedQuantity !== null) {
                            console.log('rentedQuantity가 존재함, 파싱 시도...');
                            rentedQty = parseInt(equipment.rentedQuantity);
                            console.log('parseInt 결과:', rentedQty);
                            console.log('parseInt 결과 타입:', typeof rentedQty);
                            console.log('isNaN 체크:', isNaN(rentedQty));
                            
                            if (isNaN(rentedQty) || rentedQty <= 0) {
                                console.log('유효하지 않은 값, 기본값 1로 설정');
                                rentedQty = 1;
                            }
                        } else {
                            console.log('rentedQuantity가 null/undefined, 기본값 1 사용');
                        }
                        
                        console.log('최종 대여 수량:', rentedQty);
                        console.log('최종 대여 수량 타입:', typeof rentedQty);
                        
                        const beforeText = optionText;
                        // 문자열 연결 방식으로 변경
                        optionText = optionText + ' - ' + rentedQty + '개 대여중';
                        console.log('텍스트 추가 전:', beforeText);
                        console.log('텍스트 추가 후:', optionText);
                        console.log('=== 대여 수량 처리 완료 ===');
                        
                        option.textContent = optionText;
                        equipmentSelect.appendChild(option);
                        console.log('=== 기자재 처리 완료 ===\n');
                    });
                    
                    console.log('기자재 목록 로드 완료:', equipmentSelect.options.length - 1, '개');
                    
                    // 성공 메시지 표시
                    if (data.message) {
                        console.log('서버 메시지:', data.message);
                    }
                } else {
                    console.error('잘못된 응답 형식:', data);
                    equipmentSelect.innerHTML = '<option value="">기자재 목록을 불러올 수 없습니다</option>';
                }
            })
            .catch(error => {
                console.error('기자재 목록 로드 중 오류:', error);
                equipmentSelect.innerHTML = '<option value="">오류: 기자재 목록 로드 실패</option>';
            });
    }

    // 신청 유형 선택
    function selectRequestType(type, element) {
        // 모든 항목에서 selected 클래스 제거
        document.querySelectorAll('.request-type-item').forEach(item => {
            item.classList.remove('selected');
        });
        
        // 선택된 항목에 selected 클래스 추가
        element.classList.add('selected');
        
        // 라디오 버튼 체크
        element.querySelector('input[type="radio"]').checked = true;
    }

    // 긴급도 선택
    function selectUrgency(level, element) {
        // 모든 항목에서 selected 클래스 제거
        document.querySelectorAll('.urgency-item').forEach(item => {
            item.classList.remove('selected');
        });
        
        // 선택된 항목에 selected 클래스 추가
        element.classList.add('selected');
        
        // 라디오 버튼 체크
        element.querySelector('input[type="radio"]').checked = true;
    }

    // 날짜 검증
    document.addEventListener('DOMContentLoaded', function() {
        const startDateInput = document.querySelector('input[name="expectedStartDate"]');
        const endDateInput = document.querySelector('input[name="expectedEndDate"]');
        
        startDateInput.addEventListener('change', function() {
            endDateInput.min = this.value;
        });
        
        endDateInput.addEventListener('change', function() {
            if (this.value < startDateInput.value) {
                alert('종료일은 시작일보다 빨라질 수 없습니다.');
                this.value = startDateInput.value;
            }
        });
    });

    // URL 파라미터에서 신청 유형 자동 선택
    document.addEventListener('DOMContentLoaded', function() {
        // URL 파라미터 확인
        const urlParams = new URLSearchParams(window.location.search);
        const type = urlParams.get('type');
        
        if (type === 'additional') {
            const additionalItem = document.querySelector('input[value="ADDITIONAL_RENTAL"]').closest('.request-type-item');
            if (additionalItem) {
                selectRequestType('ADDITIONAL_RENTAL', additionalItem);
            }
        }
    });
    </script>
</body>
</html> 