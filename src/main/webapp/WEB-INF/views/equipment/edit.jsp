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

    .status-info {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 12px;
      margin-top: 8px;
      padding: 12px;
      background: #f8f9fa;
      border-radius: 6px;
    }

    .status-item {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 12px;
    }

    .status-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
    }

    .status-dot.available { background: var(--success-color); }
    .status-dot.in-use { background: var(--info-color); }
    .status-dot.damaged { background: var(--danger-color); }
    .status-dot.unavailable { background: #6c757d; }

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
      <h2 class="section-title">기자재 정보 수정</h2>

      <form action="${pageContext.request.contextPath}/equipment/edit/${equipment.id}" method="post">
          <!-- CSRF 토큰 (스프링 시큐리티 사용 시 필요) -->
          <c:if test="${not empty _csrf}">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
          </c:if>

          <!-- 기자재 ID (기존 기자재 수정) -->
          <input type="hidden" name="id" value="${equipment.id}" />

          <!-- 기본 정보 -->
          <div class="form-section">
            <div class="section-subtitle">기본 정보</div>
            <div class="form-row">
              <div class="form-group">
                <label for="name" class="form-label required-field">기자재명</label>
                <input type="text" id="name" name="name" class="form-control" value="${equipment.name}" required />
              </div>
              <div class="form-group">
                <label for="assetCode" class="form-label required-field">자산 코드</label>
                <input type="text" id="assetCode" name="assetCode" class="form-control" value="${equipment.assetCode}" required />
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label for="category" class="form-label">카테고리</label>
                <select id="category" name="category" class="form-control">
                  <option value="">카테고리를 선택하세요</option>
                  <option value="컴퓨터/노트북" <c:if test="${equipment.category == '컴퓨터/노트북'}">selected</c:if>>컴퓨터/노트북</option>
                  <option value="마이크로컨트롤러/보드" <c:if test="${equipment.category == '마이크로컨트롤러/보드'}">selected</c:if>>마이크로컨트롤러/보드</option>
                  <option value="센서/모듈" <c:if test="${equipment.category == '센서/모듈'}">selected</c:if>>센서/모듈</option>
                  <option value="카메라/영상장비" <c:if test="${equipment.category == '카메라/영상장비'}">selected</c:if>>카메라/영상장비</option>
                  <option value="전원 및 충전장비" <c:if test="${equipment.category == '전원 및 충전장비'}">selected</c:if>>전원 및 충전장비</option>
                  <option value="네트워크 장비" <c:if test="${equipment.category == '네트워크 장비'}">selected</c:if>>네트워크 장비</option>
                  <option value="3D 프린팅 관련" <c:if test="${equipment.category == '3D 프린팅 관련'}">selected</c:if>>3D 프린팅 관련</option>
                  <option value="전자기기 주변장치" <c:if test="${equipment.category == '전자기기 주변장치'}">selected</c:if>>전자기기 주변장치</option>
                  <option value="공구/측정기기" <c:if test="${equipment.category == '공구/측정기기'}">selected</c:if>>공구/측정기기</option>
                  <option value="기타 실습기자재" <c:if test="${equipment.category == '기타 실습기자재'}">selected</c:if>>기타 실습기자재</option>
                </select>
              </div>
              <div class="form-group">
                <label for="manufacturer" class="form-label">제조사</label>
                <input type="text" id="manufacturer" name="manufacturer" class="form-control" value="${equipment.manufacturer}" />
              </div>
            </div>
          </div>

          <!-- 날짜 정보 -->
          <div class="form-section">
            <div class="section-subtitle">날짜 정보</div>
            <div class="form-row">
              <div class="form-group">
                <label for="purchaseDate" class="form-label">구입일</label>
                <input type="date" id="purchaseDate" name="purchaseDate" class="form-control" value="${equipment.purchaseDate}" />
              </div>
              <div class="form-group">
                <label for="warrantyExpiration" class="form-label">보증 만료일</label>
                <input type="date" id="warrantyExpiration" name="warrantyExpiration" class="form-control" value="${equipment.warrantyExpiration}" />
              </div>
            </div>
          </div>

          <!-- 위치 및 수량 -->
          <div class="form-section">
            <div class="section-subtitle">위치 및 수량 정보</div>
            <div class="form-row">
              <div class="form-group">
                <label for="location" class="form-label">위치</label>
                <input type="text" id="location" name="location" class="form-control" value="${equipment.location}" />
                <div class="form-help">기자재가 보관될 위치를 입력하세요</div>
              </div>
              <div class="form-group">
                <label for="quantity" class="form-label required-field">전체 수량</label>
                <input type="number" id="quantity" name="quantity" class="form-control" min="0" 
                       value="${equipment.quantity != null ? equipment.quantity : 0}" required />
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label for="availableQuantity" class="form-label required-field">대여 가능 수량</label>
                <input type="number" id="availableQuantity" name="availableQuantity" class="form-control" min="0" 
                       value="${equipment.availableQuantity != null ? equipment.availableQuantity : 0}" required />
              </div>
              <div class="form-group">
                <label for="maxRentalQuantity" class="form-label">1인당 대여 가능 수량</label>
                <input type="number" id="maxRentalQuantity" name="maxRentalQuantity" class="form-control" min="1" 
                       value="${equipment.maxRentalQuantity != null ? equipment.maxRentalQuantity : 1}" />
                <div class="form-help">한 사람이 한 번에 대여할 수 있는 최대 수량을 설정하세요</div>
              </div>
            </div>
          </div>

          <!-- 상태 정보 -->
          <div class="form-section">
            <div class="section-subtitle">상태 정보</div>
            <div class="form-row">
              <div class="form-group">
                <label for="isRentable" class="form-label">대여 가능 여부</label>
                <select id="isRentable" name="isRentable" class="form-control" required>
                  <option value="true" <c:if test="${equipment.isRentable == true}">selected</c:if>>예</option>
                  <option value="false" <c:if test="${equipment.isRentable == false}">selected</c:if>>아니오</option>
                </select>
              </div>
              <div class="form-group">
                <label for="isRetired" class="form-label">폐기 여부</label>
                <select id="isRetired" name="isRetired" class="form-control" required>
                  <option value="false" <c:if test="${equipment.isRetired == false}">selected</c:if>>아니오</option>
                  <option value="true" <c:if test="${equipment.isRetired == true}">selected</c:if>>예</option>
                </select>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label for="status" class="form-label">기자재 상태</label>
                <select id="status" name="status" class="form-control" required>
                  <option value="AVAILABLE" <c:if test="${equipment.status == 'AVAILABLE'}">selected</c:if>>AVAILABLE (사용 가능)</option>
                  <option value="IN_USE" <c:if test="${equipment.status == 'IN_USE'}">selected</c:if>>IN_USE (사용 중)</option>
                  <option value="DAMAGED" <c:if test="${equipment.status == 'DAMAGED'}">selected</c:if>>DAMAGED (손상)</option>
                  <option value="LOST" <c:if test="${equipment.status == 'LOST'}">selected</c:if>>LOST (분실)</option>
                  <option value="UNAVAILABLE" <c:if test="${equipment.status == 'UNAVAILABLE'}">selected</c:if>>UNAVAILABLE (사용불가)</option>
                </select>
                <div class="status-info">
                  <div class="status-item">
                    <div class="status-dot available"></div>
                    <span>AVAILABLE (사용 가능)</span>
                  </div>
                  <div class="status-item">
                    <div class="status-dot in-use"></div>
                    <span>IN_USE (사용 중)</span>
                  </div>
                  <div class="status-item">
                    <div class="status-dot damaged"></div>
                    <span>DAMAGED (손상)</span>
                  </div>
                  <div class="status-item">
                    <div class="status-dot damaged"></div>
                    <span>LOST (분실)</span>
                  </div>
                  <div class="status-item">
                    <div class="status-dot unavailable"></div>
                    <span>UNAVAILABLE (사용불가)</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- 추가 정보 -->
          <div class="form-section">
            <div class="section-subtitle">추가 정보</div>
            <div class="form-row single">
              <div class="form-group">
                <label for="description" class="form-label">설명</label>
                <textarea id="description" name="description" class="form-control textarea" 
                          placeholder="기자재에 대한 상세 설명을 입력하세요">${equipment.description}</textarea>
              </div>
            </div>
            <div class="form-row single">
              <div class="form-group">
                <label for="imagePath" class="form-label">이미지 경로</label>
                <input type="text" id="imagePath" name="imagePath" class="form-control" 
                       value="${equipment.imagePath}" placeholder="이미지 파일 경로 또는 URL을 입력하세요" />
              </div>
            </div>
          </div>

          <div class="button-group">
            <a href="${pageContext.request.contextPath}/equipment/list" class="btn btn-secondary">취소</a>
            <button type="submit" class="btn btn-primary">수정 완료</button>
          </div>
        </form>
    </div>
    
    <%@ include file="../layout/footer.jsp" %>
  </div>
</body>
</html>