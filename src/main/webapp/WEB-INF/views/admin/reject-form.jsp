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
      <h1 class="page-title">대여 신청 반려</h1>
      
      <div class="modern-card">
        <!-- 신청 정보 확인 -->
        <div class="request-info">
          <h3>신청 정보</h3>
          <div class="info-grid">
            <div class="info-item">
              <label>신청자</label>
              <span>${rental.user.name} (${rental.user.studentId})</span>
            </div>
            <div class="info-item">
              <label>기자재</label>
              <span>${rental.equipment.name}</span>
            </div>
            <div class="info-item">
              <label>신청 수량</label>
              <span>${rental.quantity}개</span>
            </div>
            <div class="info-item">
              <label>신청일</label>
              <span><fmt:formatDate value="${rental.requestDate}" pattern="yyyy-MM-dd HH:mm"/></span>
            </div>
            <div class="info-item">
              <label>희망 대여기간</label>
              <span>
                <fmt:formatDate value="${rental.startDate}" pattern="yyyy-MM-dd"/> ~ 
                <fmt:formatDate value="${rental.endDate}" pattern="yyyy-MM-dd"/>
              </span>
            </div>
            <div class="info-item">
              <label>사용 목적</label>
              <span>${rental.purpose}</span>
            </div>
          </div>
        </div>

        <!-- 반려 사유 입력 -->
        <form action="${pageContext.request.contextPath}/admin/rental/reject/${rental.id}" method="post">
          <div class="form-section">
            <h3>반려 사유</h3>
            
            <!-- 미리 정의된 반려 사유 -->
            <div class="reject-reasons">
              <div class="reason-group">
                <h4>일반적인 반려 사유</h4>
                <div class="reason-options">
                  <label class="reason-option">
                    <input type="radio" name="rejectReason" value="기자재 재고 부족">
                    <span>기자재 재고 부족</span>
                  </label>
                  <label class="reason-option">
                    <input type="radio" name="rejectReason" value="대여 기간 중복">
                    <span>대여 기간 중복</span>
                  </label>
                  <label class="reason-option">
                    <input type="radio" name="rejectReason" value="기자재 점검 중">
                    <span>기자재 점검 중</span>
                  </label>
                  <label class="reason-option">
                    <input type="radio" name="rejectReason" value="사용 목적 부적절">
                    <span>사용 목적 부적절</span>
                  </label>
                </div>
              </div>
              
              <div class="reason-group">
                <h4>자격 관련</h4>
                <div class="reason-options">
                  <label class="reason-option">
                    <input type="radio" name="rejectReason" value="대여 자격 미충족">
                    <span>대여 자격 미충족</span>
                  </label>
                  <label class="reason-option">
                    <input type="radio" name="rejectReason" value="이전 대여 미반납">
                    <span>이전 대여 미반납</span>
                  </label>
                  <label class="reason-option">
                    <input type="radio" name="rejectReason" value="연체 이력 존재">
                    <span>연체 이력 존재</span>
                  </label>
                  <label class="reason-option">
                    <input type="radio" name="rejectReason" value="대여 한도 초과">
                    <span>대여 한도 초과</span>
                  </label>
                </div>
              </div>
              
              <div class="reason-group">
                <h4>기타</h4>
                <div class="reason-options">
                  <label class="reason-option">
                    <input type="radio" name="rejectReason" value="서류 미비">
                    <span>서류 미비</span>
                  </label>
                  <label class="reason-option">
                    <input type="radio" name="rejectReason" value="승인 권한 부족">
                    <span>승인 권한 부족</span>
                  </label>
                  <label class="reason-option">
                    <input type="radio" name="rejectReason" value="기타">
                    <span>기타 (직접 입력)</span>
                  </label>
                </div>
              </div>
            </div>

            <!-- 상세 반려 사유 -->
            <div class="form-group">
              <label for="detailReason">상세 반려 사유 *</label>
              <textarea id="detailReason" name="detailReason" class="form-control" rows="5" 
                        placeholder="반려 사유를 상세히 입력해주세요. 신청자가 이해할 수 있도록 구체적으로 작성해주세요." required></textarea>
              <small class="form-text">이 내용은 신청자에게 전달됩니다.</small>
            </div>

            <!-- 추가 옵션 -->
            <div class="additional-options">
              <h4>추가 옵션</h4>
              <div class="option-group">
                <label class="option-item">
                  <input type="checkbox" name="sendEmail" value="true" checked>
                  <span>이메일로 반려 통지 발송</span>
                </label>
                <label class="option-item">
                  <input type="checkbox" name="allowReapply" value="true" checked>
                  <span>재신청 허용</span>
                </label>
                <label class="option-item">
                  <input type="checkbox" name="blockUser" value="true">
                  <span>일시적 대여 차단 (7일)</span>
                </label>
              </div>
            </div>

            <!-- 관리자 메모 -->
            <div class="form-group">
              <label for="adminMemo">관리자 메모</label>
              <textarea id="adminMemo" name="adminMemo" class="form-control" rows="3" 
                        placeholder="관리자 전용 메모 (신청자에게 보이지 않음)"></textarea>
              <small class="form-text">이 메모는 관리자만 볼 수 있습니다.</small>
            </div>
          </div>

          <!-- 버튼 -->
          <div class="form-actions">
            <button type="submit" class="btn btn-danger">반려 처리</button>
            <a href="${pageContext.request.contextPath}/admin/rentals" class="btn btn-secondary">취소</a>
            <a href="${pageContext.request.contextPath}/admin/rental/detail/${rental.id}" class="btn btn-secondary">신청 상세보기</a>
          </div>
        </form>
      </div>
    </div>

    <!-- 푸터 -->
    <%@ include file="../layout/footer.jsp" %>
  </div>

  <!-- 스크립트 -->
  <%@ include file="../layout/scripts.jsp" %>

  <style>
    /* 신청 정보 */
    .request-info {
      margin-bottom: 32px;
      padding-bottom: 24px;
      border-bottom: 1px solid #e5e7eb;
    }

    .request-info h3 {
      font-size: 1.25rem;
      font-weight: 600;
      color: #111827;
      margin: 0 0 20px 0;
    }

    .info-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 16px;
    }

    .info-item {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }

    .info-item label {
      font-weight: 500;
      color: #374151;
      font-size: 14px;
    }

    .info-item span {
      color: #111827;
      font-size: 15px;
    }

    /* 폼 섹션 */
    .form-section {
      margin-bottom: 32px;
    }

    .form-section h3 {
      font-size: 1.25rem;
      font-weight: 600;
      color: #111827;
      margin: 0 0 24px 0;
    }

    /* 반려 사유 선택 */
    .reject-reasons {
      margin-bottom: 24px;
    }

    .reason-group {
      margin-bottom: 24px;
      padding: 20px;
      background: #f8f9fa;
      border-radius: 12px;
      border: 1px solid #e5e7eb;
    }

    .reason-group h4 {
      font-size: 1rem;
      font-weight: 600;
      color: #111827;
      margin: 0 0 16px 0;
    }

    .reason-options {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 12px;
    }

    .reason-option {
      display: flex;
      align-items: center;
      gap: 8px;
      cursor: pointer;
      padding: 8px;
      border-radius: 6px;
      transition: background-color 0.2s ease;
    }

    .reason-option:hover {
      background-color: #e5e7eb;
    }

    .reason-option input[type="radio"] {
      width: 16px;
      height: 16px;
      margin: 0;
    }

    .reason-option span {
      font-size: 14px;
      color: #374151;
    }

    /* 폼 그룹 */
    .form-group {
      margin-bottom: 24px;
    }

    .form-group label {
      font-weight: 500;
      color: #374151;
      margin-bottom: 6px;
      font-size: 14px;
      display: block;
    }

    .form-text {
      font-size: 12px;
      color: #6b7280;
      margin-top: 4px;
    }

    /* 추가 옵션 */
    .additional-options {
      margin-bottom: 24px;
      padding: 20px;
      background: #f8f9fa;
      border-radius: 12px;
      border: 1px solid #e5e7eb;
    }

    .additional-options h4 {
      font-size: 1rem;
      font-weight: 600;
      color: #111827;
      margin: 0 0 16px 0;
    }

    .option-group {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }

    .option-item {
      display: flex;
      align-items: center;
      gap: 8px;
      cursor: pointer;
    }

    .option-item input[type="checkbox"] {
      width: 16px;
      height: 16px;
      margin: 0;
    }

    .option-item span {
      font-size: 14px;
      color: #374151;
    }

    /* 폼 액션 */
    .form-actions {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
      margin-top: 32px;
      padding-top: 24px;
      border-top: 1px solid #e5e7eb;
    }

    .btn-danger {
      background-color: #ef4444;
      color: white;
    }

    .btn-danger:hover {
      background-color: #dc2626;
    }

    /* 반응형 디자인 */
    @media (max-width: 768px) {
      .info-grid {
        grid-template-columns: 1fr;
      }
      
      .reason-options {
        grid-template-columns: 1fr;
      }
      
      .form-actions {
        flex-direction: column;
      }
      
      .form-actions .btn {
        width: 100%;
      }
    }
  </style>

  <script>
    // 기타 선택 시 상세 사유 입력란에 포커스
    document.addEventListener('DOMContentLoaded', function() {
      const reasonRadios = document.querySelectorAll('input[name="rejectReason"]');
      const detailReasonTextarea = document.getElementById('detailReason');
      
      reasonRadios.forEach(radio => {
        radio.addEventListener('change', function() {
          if (this.value !== '기타') {
            detailReasonTextarea.value = this.value + '\n\n';
            detailReasonTextarea.focus();
            detailReasonTextarea.setSelectionRange(detailReasonTextarea.value.length, detailReasonTextarea.value.length);
          } else {
            detailReasonTextarea.value = '';
            detailReasonTextarea.focus();
          }
        });
      });
    });

    // 폼 제출 시 확인
    document.querySelector('form').addEventListener('submit', function(e) {
      const detailReason = document.getElementById('detailReason').value.trim();
      
      if (!detailReason) {
        e.preventDefault();
        alert('상세 반려 사유를 입력해주세요.');
        document.getElementById('detailReason').focus();
        return false;
      }
      
      if (!confirm('정말로 이 신청을 반려하시겠습니까?\n\n반려 처리 후에는 취소할 수 없습니다.')) {
        e.preventDefault();
        return false;
      }
    });
  </script>
</body>
</html>
