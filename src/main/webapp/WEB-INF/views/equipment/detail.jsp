<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ include file="../layout/head-meta.jsp" %>
<style>
  /* reset + 기본 폰트 */
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }
  
  body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans KR', sans-serif;
    background: #f8fafc;
    color: #334155;
    line-height: 1.6;
  }

  html, body {
            height: auto;
  }
  
  /* content와 main-body 스타일은 head-meta.jsp에서 관리 */

  .main-body {
    max-width: 700px;
    margin: 0 auto;
  }

  .footer {
    width: 100%;
    background: #f8f9fa;
    padding: 10px 0;
    text-align: center;
    position: relative;
  }

  .equipment-detail-page {
    position: relative;
    z-index: 1;
  }

  /* 페이지 제목 */
  .equipment-detail-page h1 {
    font-size: 1.75rem;
    color: #1e293b;
    margin: 0 0 24px 0;
    font-weight: 700;
    letter-spacing: -0.025em;
    word-break: keep-all;
    overflow-wrap: break-word;
    line-height: 1.4;
    display: block;
    width: 100%;
    text-align: left;
    padding: 0;
    visibility: visible;
    opacity: 1;
    z-index: 1;
    position: relative;
  }

  /* 메인 컨테이너 */
  .equipment-detail-container {
    background: #ffffff;
    border-radius: 12px;
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
    overflow: visible;
    border: 1px solid #f1f5f9;
    width: 100%;
    max-width: 100%;
    margin: 0 auto 40px auto;
  }

  /* 상단 헤더 영역 */
  .equipment-header {
    background: #f8fafc;
    padding: 20px 24px;
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .equipment-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1e293b;
    letter-spacing: -0.025em;
  }

  .close-btn {
    background: none;
    border: none;
    font-size: 20px;
    color: #64748b;
    cursor: pointer;
    padding: 8px;
    border-radius: 6px;
    transition: all 0.2s ease-in-out;
  }

  .close-btn:hover {
    background: #e2e8f0;
    color: #334155;
  }

  /* 기자재 이미지 영역 */
  .equipment-image-section {
    padding: 32px 20px;
    text-align: center;
    border-bottom: 1px solid #f1f5f9;
    background: #fefefe;
  }

  .equipment-image {
    width: 100%;
    max-width: 300px;
    height: auto;
    min-height: 200px;
    margin: 0 auto 24px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .equipment-image img {
    max-width: 100%;
    max-height: 250px;
    width: auto;
    height: auto;
    border-radius: 8px;
    object-fit: contain;
  }

  /* 기자재 정보 테이블 */
  .equipment-info-section {
    padding: 0;
  }

  .info-table {
    width: 100%;
    border-collapse: collapse;
  }

  .info-table tr {
    border-bottom: 1px solid #f1f5f9;
    transition: background-color 0.2s ease-in-out;
  }

  .info-table tr:hover {
    background-color: #f8fafc;
  }

  .info-table tr:last-child {
    border-bottom: none;
  }

  .info-table td {
    padding: 16px 20px;
    font-size: 1rem;
    vertical-align: top;
  }

  .info-table .label {
    background: #f8fafc;
    color: #64748b;
    font-weight: 600;
    width: 30%;
    min-width: 120px;
    letter-spacing: 0.025em;
  }

  .info-table .value {
    color: #334155;
    font-weight: 500;
  }

  /* 상태 배지 */
  .status-badge {
    display: inline-block;
    padding: 6px 16px;
    border-radius: 20px;
    font-size: 0.875rem;
    font-weight: 600;
    color: #fff;
    margin-left: 12px;
    letter-spacing: 0.025em;
  }

  .status-badge.available {
    background: #059669;
  }

  .status-badge.unavailable {
    background: #dc2626;
  }

  .status-badge.rented {
    background: #2563eb;
  }

  /* 액션 버튼 영역 */
  .action-section {
    padding: 24px 20px;
    background: #f8fafc;
    border-top: 1px solid #e2e8f0;
    display: flex;
    justify-content: center;
    gap: 16px;
    flex-wrap: wrap;
  }

  .action-btn {
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease-in-out;
    text-decoration: none;
    display: inline-block;
    text-align: center;
    min-width: 120px;
    letter-spacing: 0.025em;
  }

  .btn-primary {
    background: #2563eb;
    color: #fff;
    box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  }

  .btn-primary:hover {
    background: #1d4ed8;
    transform: translateY(-1px);
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  }

  .btn-secondary {
    background: #64748b;
    color: #fff;
    box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  }

  .btn-secondary:hover {
    background: #475569;
    transform: translateY(-1px);
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  }

  .btn-outline {
    background: #fff;
    color: #64748b;
    border: 1.5px solid #e2e8f0;
  }

  .btn-outline:hover {
    background: #f1f5f9;
    border-color: #64748b;
    transform: translateY(-1px);
  }

  /* 기자재 소개 영역 */
  .equipment-description {
    padding: 24px 20px;
    border-bottom: 1px solid #f1f5f9;
    background: #fefefe;
  }

  .description-title {
    font-size: 1.25rem;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 16px;
    letter-spacing: -0.025em;
  }

  .description-content {
    color: #64748b;
    line-height: 1.7;
    font-size: 1rem;
    white-space: pre-line;
  }

  /* 사용법 영역 */
  .usage-section {
    padding: 24px 20px;
    border-bottom: 1px solid #f1f5f9;
    background: #fefefe;
  }

  .usage-title {
    font-size: 1.25rem;
    font-weight: 700;
    color: #1e293b;
    margin-bottom: 20px;
    letter-spacing: -0.025em;
  }

  .usage-steps {
    list-style: none;
    counter-reset: step-counter;
  }

  .usage-steps li {
    counter-increment: step-counter;
    margin-bottom: 12px;
    color: #64748b;
    font-size: 1rem;
    line-height: 1.6;
    position: relative;
    padding-left: 32px;
  }

  .usage-steps li::before {
    content: counter(step-counter) ".";
    position: absolute;
    left: 0;
    color: #2563eb;
    font-weight: 700;
  }

  /* 수리 요청 폼 스타일 */
  .repair-form {
    margin-top: 20px;
    padding: 20px;
    background: #f1f5f9;
    border-radius: 8px;
    border: 1px solid #e2e8f0;
  }

  .repair-form textarea {
    width: 100%;
    padding: 14px 16px;
    border: 1.5px solid #e2e8f0;
    border-radius: 6px;
    font-size: 1rem;
    resize: vertical;
    margin-bottom: 16px;
    font-family: inherit;
    line-height: 1.6;
    transition: all 0.2s ease-in-out;
  }

  .repair-form textarea:focus {
    outline: none;
    border-color: #2563eb;
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
  }

  .repair-form input[type="file"] {
    margin-bottom: 20px;
    padding: 8px;
    border: 1.5px solid #e2e8f0;
    border-radius: 6px;
    background: white;
    font-size: 1rem;
  }

  .repair-form label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    color: #334155;
    font-size: 1rem;
  }

  .content, .main-body {
    height: auto !important;
    overflow: visible !important;
  }

  /* 반응형 개선 */
  @media (max-width: 1200px) {
    .main-body {
      max-width: 650px;
      padding: 0 20px;
    }
  }

  @media (max-width: 900px) {
    .main-body {
      max-width: 90%;
      padding: 0 16px;
    }
    
    .equipment-detail-page h1 {
      font-size: 1.5rem;
      margin: 0 0 20px 0;
    }
    
    .equipment-header {
      padding: 20px;
    }
    
    .info-table td {
      padding: 14px 16px;
      font-size: 0.9rem;
    }
  }

  @media (max-width: 768px) {
    .content {
      padding: 12px;
    }

    .main-body {
      max-width: 100%;
      padding: 0 8px;
    }

    .equipment-detail-container {
      margin-bottom: 32px;
    }

    .equipment-detail-page h1 {
      font-size: 1.375rem;
      margin: 0 0 16px 0;
      line-height: 1.3;
    }

    .equipment-header {
      padding: 16px;
      flex-direction: column;
      gap: 12px;
      text-align: center;
    }

    .equipment-title {
      font-size: 1.25rem;
    }

    .equipment-image-section {
      padding: 24px 16px;
    }

    .equipment-image {
      max-width: 250px;
      min-height: 150px;
    }

    .info-table td {
      padding: 12px 16px;
      font-size: 0.875rem;
    }

    .info-table .label {
      width: 35%;
      min-width: 100px;
    }

    .action-section {
      padding: 20px 16px;
      flex-direction: column;
    }

    .action-btn {
      width: 100%;
      margin-bottom: 8px;
    }

    .equipment-description,
    .usage-section,
    .repair-form {
      padding: 20px 16px;
    }
  }

  @media (max-width: 480px) {
    .content {
      padding: 8px;
    }

    .main-body {
      padding: 0 4px;
    }

    .equipment-detail-container {
      margin-bottom: 24px;
    }

    .equipment-detail-page h1 {
      font-size: 1.25rem;
      margin: 0 0 12px 0;
    }

    .equipment-header {
      padding: 12px;
    }

    .equipment-title {
      font-size: 1.125rem;
    }

    .equipment-image-section {
      padding: 20px 12px;
    }

    .info-table td {
      padding: 10px 12px;
      font-size: 0.8rem;
    }

    .info-table .label {
      width: 40%;
      min-width: 80px;
    }

    .action-section {
      padding: 16px 12px;
    }
  }
</style>

<body>
  <%@ include file="../layout/sidebar.jsp" %>
  <div class="content">
    <%@ include file="../layout/header.jsp" %>
    <div class="main-body equipment-detail-page">
      <h1>기자재 상세정보</h1>
      
      <div class="equipment-detail-container">
        <!-- 상단 헤더 -->
        <div class="equipment-header">
          <div class="equipment-title">${equipment.name}</div>
          <button class="close-btn" onclick="history.back()">✕</button>
        </div>

        <!-- 기자재 이미지 -->
        <div class="equipment-image-section">
          <div class="equipment-image">
            <c:choose>
              <c:when test="${not empty equipment.imagePath}">
                <img src="${equipment.imagePath}" alt="${equipment.name}" />
              </c:when>
              <c:otherwise>
                <div style="color: #ccc; font-size: 48px;">📱</div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <!-- 기자재 정보 테이블 -->
        <div class="equipment-info-section">
          <table class="info-table">
            <tr>
              <td class="label">카테고리</td>
              <td class="value">${equipment.category}</td>
            </tr>
            <tr>
              <td class="label">제조사</td>
              <td class="value">${equipment.manufacturer}</td>
            </tr>
            <tr>
              <td class="label">자산 코드</td>
              <td class="value">${equipment.assetCode}</td>
            </tr>
            <tr>
              <td class="label">보유수량</td>
              <td class="value">
                ${equipment.availableQuantity}/${equipment.quantity}
                <c:if test="${equipment.availableQuantity > 0}">
                  <span class="status-badge available">대여가능</span>
                </c:if>
                <c:if test="${equipment.availableQuantity == 0}">
                  <span class="status-badge unavailable">재고없음</span>
                </c:if>
              </td>
            </tr>
            <tr>
              <td class="label">위치</td>
              <td class="value">${equipment.location}</td>
            </tr>
            <tr>
              <td class="label">대여기간</td>
              <td class="value">최대 7일</td>
            </tr>
          </table>
        </div>

        <!-- 기자재 소개 -->
        <c:if test="${not empty equipment.description}">
          <div class="equipment-description">
            <div class="description-title">기자재 소개</div>
            <div class="description-content">
              ${equipment.description}
            </div>
          </div>
        </c:if>

        <!-- 사용 방법 -->
        <!-- <div class="usage-section">
          <div class="usage-title">사용 방법</div>
          <ol class="usage-steps">
            <li>Arduino IDE를 다운로드하여 설치합니다.</li>
            <li>USB 케이블을 통해 Arduino Uno를 컴퓨터에 연결합니다.</li>
            <li>Arduino IDE에서 보드 및 포트를 선택합니다.</li>
            <li>스케치(코드)를 작성하고 업로드하여 실행합니다.</li>
            <li>필요한 경우 브레드보드, 점퍼 케이블, 센서 등을 연결하여 회로를 구성합니다.</li>
          </ol>
        </div> -->

        <!-- 액션 버튼 -->
        <div class="action-section">
          <a href="<c:url value='/equipment/list'/>" class="action-btn btn-outline">목록으로 돌아가기</a>

          <c:if test="${sessionScope.role == 'ADMIN'}">
            <a href="<c:url value='/equipment/edit/${equipment.id}'/>" class="action-btn btn-secondary">수정</a>
            <form action="<c:url value='/equipment/delete/${equipment.id}'/>" method="post" style="display:inline;" onsubmit="return confirm('삭제하시겠습니까?');">
              <button type="submit" class="action-btn btn-secondary">삭제</button>
            </form>
          </c:if>

          <c:if test="${sessionScope.role == 'STUDENT'}">
            <c:choose>
              <c:when test="${rentalInfo == null}">
                <c:if test="${equipment.isRentable && equipment.availableQuantity > 0}">
                  <a href="<c:url value='/equipmentrental/request/${equipment.id}'/>" class="action-btn btn-primary">대여신청</a>
                </c:if>
                <!-- 특별 대여 신청 버튼 (수량이 부족하거나 추가 대여가 필요한 경우) -->
                <a href="<c:url value='/special-rental/request?equipmentId=${equipment.id}'/>" class="action-btn" 
                   style="background:#ff7a00; color:#fff; margin-left: 10px;" 
                   title="수량 부족 시 또는 제한 초과 시 특별 신청">특별 대여 신청</a>
              </c:when>
              <c:when test="${!rentalInfo.isApproved}">
                <span class="action-btn" style="background:#faad14; color:#fff; pointer-events:none;">승인 대기중</span>
                <!-- 승인 대기 중에도 특별 대여 신청 가능 (추가 대여) -->
                <a href="<c:url value='/special-rental/request?equipmentId=${equipment.id}&type=additional'/>" class="action-btn" 
                   style="background:#ff7a00; color:#fff; margin-left: 10px;"
                   title="현재 대여 외 추가 대여 신청">추가 대여 신청</a>
              </c:when>
              <c:when test="${rentalInfo.isApproved && rentalInfo.status == 'RENTED'}">
                <form action="<c:url value='/equipmentrental/return'/>" method="post" style="display:inline;">
                  <input type="hidden" name="rentalId" value="${rentalInfo.id}" />
                  <button type="submit" class="action-btn btn-secondary">반납하기</button>
                </form>
                <button type="button" class="action-btn btn-primary" onclick="document.getElementById('repairForm').style.display='block'">수리 요청</button>
                <!-- 현재 대여 중에도 추가 특별 대여 신청 가능 -->
                <a href="<c:url value='/special-rental/request?equipmentId=${equipment.id}&type=additional&existingRentalId=${rentalInfo.id}'/>" class="action-btn" 
                   style="background:#ff7a00; color:#fff; margin-left: 10px;"
                   title="현재 대여 외 추가 대여 신청">추가 대여 신청</a>
              </c:when>
            </c:choose>
          </c:if>
        </div>

        <!-- 수리 요청 폼 -->
        <div id="repairForm" class="repair-form" style="display:none;">
          <form action="<c:url value='/repair/submit'/>" method="post" enctype="multipart/form-data">
            <input type="hidden" name="rentalId" value="${rentalInfo.id}" />
            <label for="reason" style="display:block; margin-bottom:5px; font-weight:500;">고장 사유:</label>
            <textarea name="reason" required placeholder="고장 사유를 상세히 입력해주세요"></textarea>
            <label for="image" style="display:block; margin-bottom:5px; font-weight:500;">사진 첨부 (선택):</label>
            <input type="file" name="image" accept="image/*" />
            <div style="display:flex; gap:10px; justify-content:flex-end;">
              <button type="button" class="action-btn btn-outline" onclick="document.getElementById('repairForm').style.display='none'">취소</button>
              <button type="submit" class="action-btn btn-primary">수리 요청 제출</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <%@ include file="../layout/footer.jsp" %>
  </div>
</body>
</html>