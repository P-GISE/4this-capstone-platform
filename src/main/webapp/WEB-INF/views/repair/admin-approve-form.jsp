<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ include file="../layout/head-meta.jsp" %>

<body>
  <%-- 사이드바 --%>
  <%@ include file="../layout/sidebar.jsp" %>

  <div class="content">
    <%-- 헤더 --%>
    <%@ include file="../layout/header.jsp" %>

    <div class="main-body repair-detail-page">
      <h1>🔧 수리 요청 상세</h1>
      <p class="subtitle">관리자 검토 페이지</p>

      <!-- 요청 정보 섹션 -->
      <section class="detail-section">
        <h2>📋 요청 정보</h2>

        <div class="detail-card">
          <div class="detail-row">
            <div class="detail-label">요청 ID</div>
            <div class="detail-value">
              <strong style="color: #667eea;">#${repair.id}</strong>
            </div>
          </div>

        <div class="detail-row">
        <div class="detail-label">요청자</div>
        <div class="detail-value">
            <c:choose>
            <c:when test="${not empty repair.user}">
                <div style="font-weight: 500; color: #212529;">
                ${repair.user.name} <span style="font-size: 12px; color: #6c757d;">(${repair.user.username})</span>
                </div>
            </c:when>
            <c:otherwise>
                <div style="font-weight: 500; color: #212529;">
                사용자 ID: ${repair.requestedBy}
                </div>
                <div style="font-size: 12px; color: #6c757d;">
                (요청자 정보를 불러올 수 없습니다)
                </div>
            </c:otherwise>
            </c:choose>
        </div>
        </div>



        <div class="detail-row">
        <div class="detail-label">요청일</div>
        <div class="detail-value">
            <c:choose>
            <c:when test="${not empty repairRequestedAtDate}">
                <fmt:formatDate value="${repairRequestedAtDate}" pattern="yyyy년 MM월 dd일 HH:mm" />
            </c:when>
            <c:otherwise>
                <span style="color: #aaa;">(요청일 없음)</span>
            </c:otherwise>
            </c:choose>
        </div>
        </div>


          <div class="detail-row">
            <div class="detail-label">현재 상태</div>
            <div class="detail-value">
              <span class="status-badge status-pending">대기중</span>
            </div>
          </div>

          <div class="detail-row">
            <div class="detail-label">수리 사유</div>
            <div class="detail-value">
              <div class="reason-box">
                ${repair.reason}
              </div>
            </div>
          </div>

          <div class="detail-row">
            <div class="detail-label">첨부 이미지</div>
            <div class="detail-value">
              <c:choose>
                <c:when test="${not empty repair.imagePath}">
                  <div class="image-container">
                    <img src="${pageContext.request.contextPath}/uploads/repair/${repair.imagePath}" 
                         alt="수리 요청 이미지" 
                         onclick="openImageModal(this.src)">
                    <div class="image-hint">
                      📸 이미지를 클릭하면 크게 볼 수 있습니다
                    </div>
                  </div>
                </c:when>
                <c:otherwise>
                  <div class="no-image">
                    📷 첨부된 이미지가 없습니다
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </div>
      </section>

      <!-- 요청 처리 섹션 -->
      <section class="action-section">
        <h2>⚡ 요청 처리</h2>

        <div class="action-form">
          <form action="${pageContext.request.contextPath}/repair/admin/handle" method="post">
            <input type="hidden" name="repairId" value="${repair.id}" />

            <div class="form-group">
              <label for="rejectionReason" class="form-label">
                💬 반려 사유 (반려 시 필수 입력)
              </label>
              <textarea name="rejectionReason" 
                        id="rejectionReason"
                        class="form-textarea" 
                        placeholder="반려하는 경우 구체적인 사유를 입력해주세요. 요청자가 이 내용을 확인할 수 있습니다."></textarea>
            </div>

            <div class="button-group">
              <button type="submit" name="action" value="approve" class="btn btn-approve">
                ✅ 승인
              </button>
              <button type="submit" name="action" value="reject" class="btn btn-reject" 
                      onclick="return validateRejection()">
                ❌ 반려
              </button>
            </div>
          </form>

          <div class="back-action">
            <a href="${pageContext.request.contextPath}/repair/admin/list" class="btn btn-back">
              ← 목록으로 돌아가기
            </a>
          </div>
        </div>
      </section>
    </div>

    <%-- 푸터 --%>
    <%@ include file="../layout/footer.jsp" %>
  </div>

  <!-- 이미지 모달 -->
  <div id="imageModal" class="image-modal" onclick="closeImageModal()">
    <span class="image-modal-close" onclick="closeImageModal()">&times;</span>
    <img class="image-modal-content" id="modalImage">
  </div>

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
    

    .repair-detail-page {
      padding: 20px;
    }

    .repair-detail-page h1 {
      font-size: 2.2em;
      color: #2d3748;
      margin-bottom: 10px;
      font-weight: 700;
    }

    .subtitle {
      color: #718096;
      font-size: 1.1em;
      margin-bottom: 30px;
      opacity: 0.9;
    }

    .detail-section, .action-section {
      margin-bottom: 40px;
    }

    .detail-section h2, .action-section h2 {
      font-size: 1.4em;
      font-weight: 700;
      color: #2d3748;
      margin-bottom: 20px;
      padding-bottom: 10px;
      border-bottom: 2px solid #667eea;
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .detail-card, .action-form {
      background: white;
      border-radius: 15px;
      padding: 30px;
      box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
      border: 1px solid rgba(102, 126, 234, 0.1);
    }

    .detail-row {
      display: flex;
      margin-bottom: 20px;
      padding-bottom: 20px;
      border-bottom: 1px solid #f0f0f0;
    }

    .detail-row:last-child {
      margin-bottom: 0;
      padding-bottom: 0;
      border-bottom: none;
    }

    .detail-label {
      flex: 0 0 140px;
      font-weight: 600;
      color: #4a5568;
      display: flex;
      align-items: flex-start;
      font-size: 1.1em;
    }

    .detail-value {
      flex: 1;
      color: #2d3748;
      line-height: 1.6;
      font-size: 1em;
    }

    .status-badge {
      display: inline-block;
      padding: 8px 16px;
      border-radius: 20px;
      font-size: 0.9em;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .status-pending {
      background: linear-gradient(135deg, #ffd89b, #19547b);
      color: white;
    }

    .reason-box {
      background: #f7fafc;
      padding: 15px;
      border-radius: 8px;
      border-left: 4px solid #667eea;
      line-height: 1.6;
    }

    .image-container {
      max-width: 100%;
      margin-top: 10px;
    }

    .image-container img {
      max-width: 100%;
      height: auto;
      border-radius: 12px;
      box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
      transition: transform 0.3s ease;
      cursor: pointer;
    }

    .image-container img:hover {
      transform: scale(1.02);
    }

    .image-hint {
      margin-top: 10px;
      font-size: 0.9em;
      color: #718096;
    }

    .no-image {
      color: #a0aec0;
      font-style: italic;
      padding: 20px;
      text-align: center;
      background: #f7fafc;
      border-radius: 8px;
      border: 2px dashed #e2e8f0;
    }

    .form-group {
      margin-bottom: 25px;
    }

    .form-label {
      display: block;
      font-weight: 600;
      color: #4a5568;
      margin-bottom: 10px;
      font-size: 1.1em;
    }

    .form-textarea {
      width: 100%;
      padding: 15px;
      border: 2px solid #e2e8f0;
      border-radius: 12px;
      font-size: 1em;
      line-height: 1.6;
      resize: vertical;
      min-height: 120px;
      transition: all 0.3s ease;
      font-family: inherit;
    }

    .form-textarea:focus {
      outline: none;
      border-color: #667eea;
      box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    .button-group {
      display: flex;
      gap: 15px;
      flex-wrap: wrap;
      margin-bottom: 20px;
    }

    .back-action {
      padding-top: 20px;
      border-top: 1px solid #e2e8f0;
    }

    .btn {
      padding: 15px 30px;
      border: none;
      border-radius: 12px;
      font-size: 1.1em;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s ease;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      min-width: 120px;
      justify-content: center;
    }

    .btn-approve {
      background: linear-gradient(135deg, #48bb78, #38a169);
      color: white;
      box-shadow: 0 5px 15px rgba(72, 187, 120, 0.3);
    }

    .btn-approve:hover {
      background: linear-gradient(135deg, #38a169, #2f855a);
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(72, 187, 120, 0.4);
    }

    .btn-reject {
      background: linear-gradient(135deg, #f56565, #e53e3e);
      color: white;
      box-shadow: 0 5px 15px rgba(245, 101, 101, 0.3);
    }

    .btn-reject:hover {
      background: linear-gradient(135deg, #e53e3e, #c53030);
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(245, 101, 101, 0.4);
    }

    .btn-back {
      background: linear-gradient(135deg, #667eea, #764ba2);
      color: white;
      box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
      text-decoration: none;
    }

    .btn-back:hover {
      background: linear-gradient(135deg, #5a67d8, #6b46c1);
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
      text-decoration: none;
      color: white;
    }

    /* 이미지 모달 스타일 */
    .image-modal {
      display: none;
      position: fixed;
      z-index: 1000;
      left: 0;
      top: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0, 0, 0, 0.9);
      animation: fadeIn 0.3s ease;
    }

    .image-modal-content {
      display: block;
      margin: auto;
      max-width: 90%;
      max-height: 90%;
      margin-top: 5%;
      border-radius: 10px;
    }

    .image-modal-close {
      position: absolute;
      top: 20px;
      right: 35px;
      color: #fff;
      font-size: 40px;
      font-weight: bold;
      cursor: pointer;
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    /* 반응형 디자인 */
    @media (max-width: 768px) {
      .repair-detail-page {
        padding: 15px;
      }

      .repair-detail-page h1 {
        font-size: 1.8em;
      }

      .detail-card, .action-form {
        padding: 20px;
      }

      .detail-row {
        flex-direction: column;
        gap: 5px;
      }

      .detail-label {
        flex: none;
        margin-bottom: 5px;
      }

      .button-group {
        flex-direction: column;
      }

      .btn {
        width: 100%;
      }
    }

    @media (max-width: 480px) {
      .repair-detail-page {
        padding: 10px;
      }

      .repair-detail-page h1 {
        font-size: 1.6em;
      }

      .detail-card, .action-form {
        padding: 15px;
      }
    }
  </style>

  <script>
    // 반려 버튼 클릭 시 사유 입력 확인
    function validateRejection() {
      const rejectionReason = document.getElementById('rejectionReason').value.trim();
      if (!rejectionReason) {
        alert('반려 사유를 입력해주세요.');
        document.getElementById('rejectionReason').focus();
        return false;
      }
      return confirm('정말로 이 요청을 반려하시겠습니까?');
    }

    // 이미지 모달 기능
    function openImageModal(src) {
      document.getElementById('imageModal').style.display = 'block';
      document.getElementById('modalImage').src = src;
      document.body.style.overflow = 'hidden';
    }

    function closeImageModal() {
      document.getElementById('imageModal').style.display = 'none';
      document.body.style.overflow = 'auto';
    }

    // ESC 키로 모달 닫기
    document.addEventListener('keydown', function(event) {
      if (event.key === 'Escape') {
        closeImageModal();
      }
    });

    // 폼 제출 시 확인
    document.querySelector('form').addEventListener('submit', function(e) {
      const action = e.submitter.value;
      if (action === 'approve') {
        if (!confirm('이 수리 요청을 승인하시겠습니까?')) {
          e.preventDefault();
        }
      }
    });
  </script>
</body>
</html>