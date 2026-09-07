<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ include file="../layout/head-meta.jsp" %>
<body>
<%@ include file="../layout/sidebar.jsp" %>

<div class="content">
  <%@ include file="../layout/header.jsp" %>

  <div class="main-body">
    <div class="form-wrapper">
      <h1 class="title">📦 기자재 대여 신청</h1>

      <div class="form-card">
        <c:if test="${not empty errorMessage}">
          <div class="error-message">${errorMessage}</div>
        </c:if>

        <!-- 최대 수량 계산 -->
        <c:set var="maxQtyLimit" value="${equipment.maxRentalQuantity != null && equipment.maxRentalQuantity lt equipment.availableQuantity 
                                           ? equipment.maxRentalQuantity 
                                           : equipment.availableQuantity}" />

        <form action="<c:url value='/equipmentrental/request'/>" method="post">
          <input type="hidden" name="equipmentId" value="${equipment.id}" />

          <div class="form-group">
            <label>기자재명</label>
            <input type="text" value="${equipment.name}" disabled />
          </div>

          <div class="form-group">
            <label for="rentDate">대여 일시</label>
            <input type="datetime-local" id="rentDate" name="rentDate" value="${defaultStart}" required />
            <small class="form-help">오늘부터 1개월 이내에서 선택해주세요</small>
          </div>

          <div class="form-group">
            <label for="expectedReturnDate">반납 예정일시</label>
            <input type="datetime-local" id="expectedReturnDate" name="expectedReturnDate" value="${defaultEnd}" required />
            <small class="form-help">대여일부터 1개월 이내에서 선택해주세요</small>
          </div>

          <div class="form-group">
            <label for="requestedQuantity">대여 수량</label>
            <input type="number" id="requestedQuantity" name="requestedQuantity" min="1" max="${maxQtyLimit}" value="1" required />
            <small>
              대여 가능 수량: ${equipment.availableQuantity}개
              <c:if test="${not empty equipment.maxRentalQuantity}">
                , 1인당 최대: ${equipment.maxRentalQuantity}개
              </c:if>
            </small>
          </div>

          <div class="form-group">
            <label for="purpose">대여 사유</label>
            <textarea id="purpose" name="purpose" required>${param.purpose != null ? param.purpose : ""}</textarea>
          </div>

          <div class="button-group">
            <a href="<c:url value='/equipment/list'/>" class="btn btn-secondary">취소</a>
            <button type="submit" class="btn btn-primary">신청하기</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <%@ include file="../layout/footer.jsp" %>
</div>

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
  .main-body {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 100px 30px 30px 30px;
    max-width: none;
    background-color: #f5f5f5;
  }

  .form-wrapper {
    width: 100%;
    max-width: 700px;
  }

  .title {
    font-size: 24px;
    font-weight: 700;
    text-align: center;
    margin-bottom: 30px;
    color: #2d3748;
  }

  .form-card {
    background: #fff;
    border-radius: 12px;
    padding: 30px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  }

  .form-group {
    margin-bottom: 20px;
  }

  .form-group label {
    font-weight: 600;
    color: #4a5568;
    display: block;
    margin-bottom: 6px;
  }

  .form-group input,
  .form-group textarea {
    width: 100%;
    padding: 10px;
    font-size: 14px;
    border-radius: 6px;
    border: 1px solid #cbd5e0;
    box-sizing: border-box;
  }

  .form-group textarea {
    resize: vertical;
    min-height: 80px;
  }

  .form-group small {
    color: #718096;
    font-size: 13px;
  }

  .button-group {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 25px;
  }

  .btn {
    padding: 10px 20px;
    font-weight: 600;
    border-radius: 8px;
    font-size: 14px;
    cursor: pointer;
    text-decoration: none;
    border: none;
  }

  .btn-primary {
    background-color: #3366ff;
    color: white;
  }

  .btn-primary:hover {
    background-color: #254eda;
  }

  .btn-secondary {
    background-color: #e2e8f0;
    color: #2d3748;
  }

  .btn-secondary:hover {
    background-color: #cbd5e0;
  }

  .error-message {
    background-color: #fff5f5;
    color: #c53030;
    padding: 10px 15px;
    border: 1px solid #fed7d7;
    border-radius: 6px;
    margin-bottom: 20px;
  }

  .form-help {
    color: #718096;
    font-size: 12px;
    margin-top: 4px;
    display: block;
  }
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const rentDateInput = document.getElementById('rentDate');
    const returnDateInput = document.getElementById('expectedReturnDate');
    
    // 현재 날짜와 시간 계산
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    
    // 1개월 후 날짜 계산
    const oneMonthLater = new Date(today);
    oneMonthLater.setMonth(oneMonthLater.getMonth() + 1);
    
    // 날짜를 datetime-local 형식으로 변환하는 함수
    function toDateTimeLocal(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        return `${year}-${month}-${day}T${hours}:${minutes}`;
    }
    
    // 대여일시 제한 설정 (오늘부터 1개월 후까지)
    rentDateInput.min = toDateTimeLocal(now);
    rentDateInput.max = toDateTimeLocal(oneMonthLater);
    
    // 초기 반납예정일시 제한 설정
    function updateReturnDateLimits() {
        if (rentDateInput.value) {
            const rentDate = new Date(rentDateInput.value);
            const maxReturnDate = new Date(rentDate);
            maxReturnDate.setMonth(maxReturnDate.getMonth() + 1);
            
            returnDateInput.min = rentDateInput.value;
            returnDateInput.max = toDateTimeLocal(maxReturnDate);
            
            // 반납예정일이 새로운 제한을 벗어나면 조정
            if (returnDateInput.value) {
                const currentReturnDate = new Date(returnDateInput.value);
                if (currentReturnDate < rentDate) {
                    returnDateInput.value = rentDateInput.value;
                } else if (currentReturnDate > maxReturnDate) {
                    returnDateInput.value = toDateTimeLocal(maxReturnDate);
                }
            }
        }
    }
    
    // 대여일시 변경시 반납예정일시 제한 업데이트
    rentDateInput.addEventListener('change', updateReturnDateLimits);
    
    // 초기 설정
    updateReturnDateLimits();
    
    // 폼 제출 전 유효성 검사
    document.querySelector('form').addEventListener('submit', function(e) {
        const rentDate = new Date(rentDateInput.value);
        const returnDate = new Date(returnDateInput.value);
        const now = new Date();
        
        // 대여일이 현재 시간보다 이전인지 확인
        if (rentDate < now) {
            alert('대여일시는 현재 시간 이후로 선택해주세요.');
            e.preventDefault();
            return;
        }
        
        // 대여일이 1개월 이후인지 확인
        const oneMonthFromNow = new Date(now);
        oneMonthFromNow.setMonth(oneMonthFromNow.getMonth() + 1);
        if (rentDate > oneMonthFromNow) {
            alert('대여일시는 1개월 이내로 선택해주세요.');
            e.preventDefault();
            return;
        }
        
        // 반납예정일이 대여일보다 이전인지 확인
        if (returnDate <= rentDate) {
            alert('반납예정일시는 대여일시보다 이후로 선택해주세요.');
            e.preventDefault();
            return;
        }
        
        // 반납예정일이 대여일로부터 1개월 이후인지 확인
        const oneMonthFromRent = new Date(rentDate);
        oneMonthFromRent.setMonth(oneMonthFromRent.getMonth() + 1);
        if (returnDate > oneMonthFromRent) {
            alert('반납예정일시는 대여일로부터 1개월 이내로 선택해주세요.');
            e.preventDefault();
            return;
        }
    });
    
    console.log('=== 기자재 대여 날짜 제한 설정 완료 ===');
    console.log('대여일 제한:', rentDateInput.min, '~', rentDateInput.max);
    console.log('현재 대여일:', rentDateInput.value);
    console.log('반납예정일 제한:', returnDateInput.min, '~', returnDateInput.max);
    console.log('현재 반납예정일:', returnDateInput.value);
});
</script>

</body>
</html>