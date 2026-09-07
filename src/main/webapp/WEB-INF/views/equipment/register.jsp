<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%@ include file="../layout/head-meta.jsp" %>

<style>
  :root {
    --primary-color: #4751c9;
    --secondary-color: #e9eaff;
    --dark-color: #1e1e1e;
    --light-color: #ffffff;
    --grey-color: #f5f5f7;
    --text-color: #333333;
    --border-color: #eaeaea;
    --success-color: #52c41a;
    --warning-color: #faad14;
    --danger-color: #ff4d4f;
    --info-color: #1890ff;
  }

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

    /* content와 main-body 스타일은 head-meta.jsp에서 관리 */

  .section-title {
    font-size: 2rem;
    font-weight: 700;
    color: #333;
    margin-bottom: 24px;
    text-align: center;
  }

  .write-card {
    background: #fff;
    border-radius: 16px;
    box-shadow: 0 4px 24px rgba(80, 90, 200, 0.08);
    padding: 32px 28px 28px 28px;
    margin: 0 auto;
    max-width: 700px;
    width: 100%;
  }

  .form-section {
    margin-bottom: 32px;
    background: #f9faff;
    border-radius: 10px;
    padding: 24px 18px 18px 18px;
    box-shadow: 0 2px 8px rgba(80, 90, 200, 0.04);
    border: 1px solid #e0e3ef;
  }

  .section-subtitle {
    font-size: 1.15rem;
    color: #4751c9;
    font-weight: 700;
    margin-bottom: 18px;
    margin-top: 0;
  }

  .form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 18px 24px;
    margin-bottom: 16px;
  }

  .form-row.single {
    grid-template-columns: 1fr;
  }

  .form-group {
    display: flex;
    flex-direction: column;
  }

  .form-label {
    font-size: 0.98rem;
    font-weight: 600;
    margin-bottom: 6px;
    color: #333;
  }

  .required-field::after {
    content: ' *';
    color: var(--danger-color);
    font-weight: bold;
  }

  .form-control {
    border: 1px solid #e0e3ef;
    border-radius: 6px;
    padding: 10px 12px;
    font-size: 1rem;
    background: #fff;
    transition: border 0.2s;
  }

  .form-control:focus {
    border: 1.5px solid #4751c9;
    outline: none;
    background: #f9faff;
  }

  .form-control.textarea {
    min-height: 100px;
    resize: vertical;
  }

  .form-help {
    font-size: 0.8rem;
    color: #999;
    margin-top: 5px;
  }

  .button-group {
    display: flex;
    justify-content: center;
    gap: 16px;
    margin-top: 30px;
  }

  .btn {
    display: inline-block;
    border: none;
    border-radius: 6px;
    padding: 10px 28px;
    font-size: 1.05rem;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s, color 0.2s, box-shadow 0.2s;
    text-decoration: none;
    margin: 0 2px;
  }

  .btn-primary {
    background: #4751c9;
    color: #fff;
  }

  .btn-primary:hover {
    background: #6c63ff;
    color: #fff;
    box-shadow: 0 2px 8px rgba(71,81,201,0.12);
  }

  .btn-secondary {
    background: #f3f5fa;
    color: #4751c9;
    border: 1px solid #e0e3ef;
  }

  .btn-secondary:hover {
    background: #e9eaff;
    color: #333;
  }

  @media (max-width: 900px) {
    .main-body {
      padding: 18px 4px;
    }
    .write-card {
      padding: 18px 4px;
      max-width: 100%;
    }
    .form-row {
      grid-template-columns: 1fr;
      gap: 14px;
    }
  }
</style>

<body>
  <div class="sidebar">
    <%@ include file="../layout/sidebar.jsp" %>
  </div>
  <div class="content">
    <%@ include file="../layout/header.jsp" %>

    <div class="main-body">
      <h2 class="section-title">기자재 등록</h2>

      <form action="${pageContext.request.contextPath}/equipment/register" method="post" enctype="multipart/form-data" class="write-card">
        <!-- CSRF -->
        <c:if test="${not empty _csrf}">
          <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
        </c:if>

        <!-- 기본 정보 -->
        <div class="form-section">
          <div class="section-subtitle">기본 정보</div>
          <div class="form-row">
            <div class="form-group">
              <label for="name" class="form-label required-field">기자재명</label>
              <input type="text" id="name" name="name" class="form-control" required />
            </div>
            <div class="form-group">
              <label for="assetCode" class="form-label required-field">자산 코드</label>
              <input type="text" id="assetCode" name="assetCode" class="form-control" required />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label for="category" class="form-label">카테고리</label>
              <select id="category" name="category" class="form-control">
                <option value="">카테고리를 선택하세요</option>
                <option value="컴퓨터/노트북">컴퓨터/노트북</option>
                <option value="마이크로컨트롤러/보드">마이크로컨트롤러/보드</option>
                <option value="센서/모듈">센서/모듈</option>
                <option value="카메라/영상장비">카메라/영상장비</option>
                <option value="전원 및 충전장비">전원 및 충전장비</option>
                <option value="네트워크 장비">네트워크 장비</option>
                <option value="3D 프린팅 관련">3D 프린팅 관련</option>
                <option value="전자기기 주변장치">전자기기 주변장치</option>
                <option value="공구/측정기기">공구/측정기기</option>
                <option value="기타 실습기자재">기타 실습기자재</option>
              </select>
            </div>
            <div class="form-group">
              <label for="manufacturer" class="form-label">제조사</label>
              <input type="text" id="manufacturer" name="manufacturer" class="form-control" />
            </div>
          </div>
        </div>

        <!-- 날짜 정보 -->
        <div class="form-section">
          <div class="section-subtitle">날짜 정보</div>
          <div class="form-row">
            <div class="form-group">
              <label for="purchaseDate" class="form-label">구입일</label>
              <input type="date" id="purchaseDate" name="purchaseDate" class="form-control" />
            </div>
            <div class="form-group">
              <label for="warrantyExpiration" class="form-label">보증 만료일</label>
              <input type="date" id="warrantyExpiration" name="warrantyExpiration" class="form-control" />
            </div>
          </div>
        </div>

        <!-- 위치 및 수량 -->
        <div class="form-section">
          <div class="section-subtitle">위치 및 수량 정보</div>
          <div class="form-row">
            <div class="form-group">
              <label for="location" class="form-label">위치</label>
              <input type="text" id="location" name="location" class="form-control" />
              <div class="form-help">기자재가 보관될 위치를 입력하세요</div>
            </div>
            <div class="form-group">
              <label for="quantity" class="form-label required-field">전체 수량</label>
              <input type="number" id="quantity" name="quantity" class="form-control" min="0" value="0" required />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label for="availableQuantity" class="form-label required-field">대여 가능 수량</label>
              <input type="number" id="availableQuantity" name="availableQuantity" class="form-control" min="0" value="0" required />
            </div>
            <div class="form-group">
              <label for="maxRentalQuantity" class="form-label">1인당 대여 가능 수량</label>
              <input type="number" id="maxRentalQuantity" name="maxRentalQuantity" class="form-control" min="1" value="1" />
              <div class="form-help">한 사람이 한 번에 대여할 수 있는 최대 수량을 설정하세요</div>
            </div>
          </div>
        </div>

        <!-- 추가 정보 -->
        <div class="form-section">
          <div class="section-subtitle">추가 정보</div>
          <div class="form-row single">
            <div class="form-group">
              <label for="description" class="form-label">설명</label>
              <textarea id="description" name="description" class="form-control textarea" placeholder="기자재에 대한 상세 설명을 입력하세요"></textarea>
            </div>
          </div>
          <div class="form-row single">
            <div class="form-group">
              <label for="imagePath" class="form-label">이미지 경로</label>
              <input type="text" id="imagePath" name="imagePath" class="form-control" placeholder="이미지 파일 경로 또는 URL을 입력하세요" />
            </div>
          </div>
        </div>

        <div class="button-group">
          <a href="${pageContext.request.contextPath}/equipment/list" class="btn btn-secondary">취소</a>
          <button type="submit" class="btn btn-primary">등록하기</button>
        </div>
      </form>
    </div>

    <%@ include file="../layout/footer.jsp" %>
  </div>
</body>
</html>
