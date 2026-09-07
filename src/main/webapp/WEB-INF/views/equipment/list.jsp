<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ include file="../layout/head-meta.jsp" %>
<style>
  /* reset + 기본 폰트 */
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

  /* 제목 */
  .equipment-page h1 {
    font-size: 24px;
    color: #333;
    margin-bottom: 20px;
  }

  /* 카드 컨테이너 - 공지사항과 동일한 스타일 */
  .equipment-card {
    background-color: white;
    border-radius: 8px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
    /* 높이 제한 제거 */
  }

  /* 검색 바 & 필터 - 공지사항과 동일한 스타일 */
  .search-filter {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
    align-items: center;
    flex-wrap: wrap;
  }

  .search-input-wrapper {
    position: relative;
    flex: 1;
    min-width: 250px;
  }

  .search-filter input[type="text"] {
    width: 100%;
    padding: 12px 40px 12px 16px;
    border: 2px solid #e1e5e9;
    border-radius: 8px;
    font-size: 14px;
    background: #f8f9fa;
    transition: all 0.3s ease;
  }

  .search-filter input[type="text"]:focus {
    outline: none;
    border-color: #3366ff;
    background: #fff;
    box-shadow: 0 0 0 3px rgba(51, 102, 255, 0.1);
  }

  .search-btn {
    position: absolute;
    right: 8px;
    top: 50%;
    transform: translateY(-50%);
    background: #3366ff;
    border: none;
    border-radius: 6px;
    width: 32px;
    height: 32px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background 0.2s;
  }

  .search-btn:hover {
    background: #254eda;
  }

  .search-btn svg {
    width: 16px;
    height: 16px;
    fill: white;
  }

  .filter-select {
    padding: 12px 16px;
    border: 2px solid #e1e5e9;
    border-radius: 8px;
    font-size: 14px;
    background: #f8f9fa;
    cursor: pointer;
    min-width: 120px;
    transition: all 0.3s ease;
  }

  .filter-select:focus {
    outline: none;
    border-color: #3366ff;
    background: #fff;
    box-shadow: 0 0 0 3px rgba(51, 102, 255, 0.1);
  }

  .status-filter {
    min-width: 140px;
  }

  /* 테이블 */
  table {
    width: 100%;
    border-collapse: collapse;
    background: white;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
    /* 테이블 스크롤 제거 */
  }

  th, td {
    padding: 12px 15px;
    border-bottom: 1px solid #f0f0f0;
    text-align: left;
    font-size: 14px;
    color: #333;
  }

  th {
    background: #fafafa;
    font-weight: 500;
  }

  /* 배지 */
  .badge {
    display: inline-block;
    padding: 4px 10px;
    border-radius: 12px;
    font-size: 12px;
    color: #fff;
  }
  .badge.대여가능  { background: #52c41a; }
  .badge.대여중    { background: #3366ff; }
  .badge.재고없음  { background: #ff4d4f; }
  .badge.예약중    { background: #faad14; }
  .badge.대여불가  { background: #ff4d4f; }

  /* 버튼 */
  .btn {
    display: inline-block;
    padding: 6px 12px;
    font-size: 12px;
    border-radius: 4px;
    text-decoration: none;
    margin-right: 5px;
    border: 1px solid transparent;
    transition: all 0.2s;
  }
  .btn-outline-primary {
    color: #3366ff;
    border-color: #3366ff;
  }
  .btn-outline-primary:hover {
    background: #3366ff;
    color: #fff;
  }
  .btn-secondary {
    color: #888;
    border-color: #888;
  }
  .btn-secondary:hover {
    background: #888;
    color: #fff;
  }
  .btn-warning {
    color: #faad14;
    border-color: #faad14;
  }
  .btn-warning:hover {
    background: #faad14;
    color: #fff;
  }
  .btn-danger {
    color: #ff4d4f;
    border-color: #ff4d4f;
  }
  .btn-danger:hover {
    background: #ff4d4f;
    color: #fff;
  }

  /* 관리자 전용 등록 버튼 */
  .btn-register {
    display: inline-block;
    padding: 6px 12px;
    font-size: 12px;
    border-radius: 4px;
    text-decoration: none;
    border: 1px solid #3366ff;
    color: #3366ff;
    transition: all 0.2s;
    margin-top: 10px;
  }
  .btn-register:hover {
    background: #3366ff;
    color: #fff;
  }

  /* 페이징 - 공지사항과 동일한 스타일 */
  .pagination {
    display: flex;
    list-style: none;
    gap: 8px;
    justify-content: center;
    margin: 30px 0 0;
  }

  .pagination a {
    display: block;
    padding: 8px 12px;
    color: #666;
    border: 1px solid #e0e0e0;
    border-radius: 6px;
    text-decoration: none;
    font-size: 14px;
    transition: all 0.2s;
    min-width: 40px;
    text-align: center;
  }

  .pagination a:hover:not(.disabled) {
    background: #f8f9fa;
    border-color: #3366ff;
    color: #3366ff;
  }

  .pagination .active a {
    background: #3366ff;
    color: #fff;
    border-color: #3366ff;
  }

  .pagination .disabled a {
    color: #ccc;
    pointer-events: none;
    background: #f8f9fa;
  }

  /* 결과 정보 */
  .result-info {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    font-size: 14px;
    color: #666;
  }

  .result-count {
    font-weight: 500;
  }

  .sort-options {
    display: flex;
    gap: 10px;
    align-items: center;
  }

  .sort-select {
    padding: 6px 12px;
    border: 1px solid #e1e5e9;
    border-radius: 6px;
    font-size: 13px;
    background: white;
    cursor: pointer;
  }

  /* 반응형 */
  @media (max-width: 768px) {
    .content {
      padding: 16px;
    }
    
    .search-filter {
      flex-direction: column;
      align-items: stretch;
    }
    
    .search-input-wrapper {
      min-width: unset;
    }
    
    .filter-select {
      min-width: unset;
    }
    
    table {
      font-size: 12px;
    }
    
    th, td {
      padding: 8px 10px;
    }
  }

</style>

<body>
  <%@ include file="../layout/sidebar.jsp" %>
  <div class="content">
    <%@ include file="../layout/header.jsp" %>
    <div class="main-body equipment-page">
      <h1>기자재 정보</h1>
      
      <div class="equipment-card">
        <!-- 검색 및 필터 영역 -->
        <form action="${pageContext.request.contextPath}/equipment/list" method="get" class="search-filter">
          <div class="search-input-wrapper">
            <input type="text" name="keyword" value="${param.keyword}" placeholder="기자재명, 제조사, 자산코드로 검색하세요">
            <button type="submit" class="search-btn">
              <svg viewBox="0 0 24 24">
                <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
              </svg>
            </button>
          </div>
          
          <select name="category" class="filter-select">
            <option value="">카테고리를 선택하세요</option>
            <option value="컴퓨터/노트북" ${param.category == '컴퓨터/노트북' ? 'selected' : ''}>컴퓨터/노트북</option>
            <option value="마이크로컨트롤러/보드" ${param.category == '마이크로컨트롤러/보드' ? 'selected' : ''}>마이크로컨트롤러/보드</option>
            <option value="센서/모듈" ${param.category == '센서/모듈' ? 'selected' : ''}>센서/모듈</option>
            <option value="카메라/영상장비" ${param.category == '카메라/영상장비' ? 'selected' : ''}>카메라/영상장비</option>
            <option value="전원 및 충전장비" ${param.category == '전원 및 충전장비' ? 'selected' : ''}>전원 및 충전장비</option>
            <option value="네트워크 장비" ${param.category == '네트워크 장비' ? 'selected' : ''}>네트워크 장비</option>
            <option value="3D 프린팅 관련" ${param.category == '3D 프린팅 관련' ? 'selected' : ''}>3D 프린팅 관련</option>
            <option value="전자기기 주변장치" ${param.category == '전자기기 주변장치' ? 'selected' : ''}>전자기기 주변장치</option>
            <option value="공구/측정기기" ${param.category == '공구/측정기기' ? 'selected' : ''}>공구/측정기기</option>
            <option value="기타 실습기자재" ${param.category == '기타 실습기자재' ? 'selected' : ''}>기타 실습기자재</option>
          </select>
          
          <select name="status" class="filter-select status-filter">
            <option value="">전체 상태</option>
            <option value="AVAILABLE" ${param.status == 'AVAILABLE' ? 'selected' : ''}>대여 가능</option>
            <option value="IN_USE" ${param.status == 'IN_USE' ? 'selected' : ''}>대여중</option>
            <option value="DAMAGED" ${param.status == 'DAMAGED' ? 'selected' : ''}>손상됨</option>
            <option value="LOST" ${param.status == 'LOST' ? 'selected' : ''}>분실</option>
            <option value="UNAVAILABLE" ${param.status == 'UNAVAILABLE' ? 'selected' : ''}>사용불가</option>
          </select>
          
          <select name="location" class="filter-select">
            <option value="">전체 위치</option>
            <option value="정통과" ${param.location == '정보과' ? 'selected' : ''}>정통과</option>
          </select>
        </form>

        <!-- 결과 정보 및 정렬 옵션 -->
        <div class="result-info">
          <div class="result-count">
            총 <strong>${totalCount}</strong>개의 기자재 (${currentPage}/${totalPages} 페이지)
          </div>
          <div class="sort-options">
            <label for="sortBy">정렬:</label>
            <select name="sortBy" class="sort-select" onchange="changeSortOrder(this.value)">
              <option value="created_at_desc" ${param.sortBy == 'created_at_desc' ? 'selected' : ''}>등록일 최신순</option>
              <option value="created_at_asc" ${param.sortBy == 'created_at_asc' ? 'selected' : ''}>등록일 오래된순</option>
              <option value="name_asc" ${param.sortBy == 'name_asc' ? 'selected' : ''}>이름 가나다순</option>
              <option value="category_asc" ${param.sortBy == 'category_asc' ? 'selected' : ''}>카테고리순</option>
              <option value="available_desc" ${param.sortBy == 'available_desc' ? 'selected' : ''}>재고 많은순</option>
            </select>
          </div>
        </div>

        <table>
          <thead>
            <tr>
              <th style="width: 100px;">기자재명</th>
              <th style="width: 100px;">카테고리</th>
              <th style="width: 100px;">수량</th>
              <th style="width: 100px;">상태</th>
              <th style="width: 100px;">위치</th>
              <th style="width: 100px;">관리</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="e" items="${equipmentList}">
              <tr>
                <td><a href="${pageContext.request.contextPath}/equipment/detail/${e.id}" style="color: inherit; text-decoration: none;">${e.name}</a></td>
                <td>${e.category}</td>
                <td>${e.availableQuantity} / ${e.quantity}</td>
                <td>
                  <%-- 사용자별 맞춤 상태 표시 --%>
                  <c:choose>
                    <%-- 학생인 경우 개인화된 상태 표시 --%>
                    <c:when test="${sessionScope.role == 'STUDENT'}">
                      <c:set var="rental" value="${rentalMap[e.id]}" />
                      <c:set var="repairStatus" value="${repairStatusMap[e.id]}" />
                      
                      <c:choose>
                        <%-- 내가 수리요청한 기자재 --%>
                        <c:when test="${repairStatus == 'PENDING'}">
                          <span class="badge" style="background: #faad14; color: white;">수리요청중</span>
                        </c:when>
                        <c:when test="${repairStatus == 'APPROVED'}">
                          <span class="badge" style="background: #ff9800; color: white;">수리중</span>
                        </c:when>
                        <c:when test="${repairStatus == 'REJECTED'}">
                          <span class="badge" style="background: #f44336; color: white;">수리반려</span>
                        </c:when>
                        <c:when test="${repairStatus == 'COMPLETED'}">
                          <span class="badge 대여가능">수리완료</span>
                        </c:when>
                        
                        <%-- 내가 대여한 기자재 --%>
                        <c:when test="${rental != null && rental.isApproved && rental.returnDate == null}">
                          <span class="badge 대여중">대여중</span>
                        </c:when>
                        <c:when test="${rental != null && rental.status == 'PENDING'}">
                          <span class="badge" style="background: #faad14; color: white;">승인대기중</span>
                        </c:when>
                        <c:when test="${rental != null && rental.status == 'REJECTED'}">
                          <span class="badge" style="background: #f44336; color: white;">대여반려</span>
                        </c:when>
                        
                        <%-- 예약한 기자재 --%>
                        <c:when test="${reservationStatusMap[e.id]}">
                          <span class="badge" style="background: #9c27b0; color: white;">예약중</span>
                        </c:when>
                        
                        <%-- 기본 상태 (다른 사람이 사용중이거나 일반 상태) --%>
                        <c:otherwise>
                          <c:choose>
                            <c:when test="${e.status == 'AVAILABLE'}"><span class="badge 대여가능">대여 가능</span></c:when>
                            <c:when test="${e.status == 'IN_USE'}"><span class="badge 대여중">대여중</span></c:when>
                            <c:when test="${e.status == 'DAMAGED'}"><span class="badge 대여불가">손상됨</span></c:when>
                            <c:when test="${e.status == 'LOST'}"><span class="badge 대여불가">분실</span></c:when>
                            <c:when test="${e.status == 'UNAVAILABLE'}"><span class="badge 대여불가">사용불가</span></c:when>
                            <c:otherwise><span class="badge 대여불가">알 수 없음</span></c:otherwise>
                          </c:choose>
                        </c:otherwise>
                      </c:choose>
                    </c:when>
                    
                    <%-- 관리자나 다른 역할은 기본 상태 표시 --%>
                    <c:otherwise>
                      <c:choose>
                        <c:when test="${e.status == 'AVAILABLE'}"><span class="badge 대여가능">대여 가능</span></c:when>
                        <c:when test="${e.status == 'IN_USE'}"><span class="badge 대여중">대여중</span></c:when>
                        <c:when test="${e.status == 'DAMAGED'}"><span class="badge 대여불가">손상됨</span></c:when>
                        <c:when test="${e.status == 'LOST'}"><span class="badge 대여불가">분실</span></c:when>
                        <c:when test="${e.status == 'UNAVAILABLE'}"><span class="badge 대여불가">사용불가</span></c:when>
                        <c:otherwise><span class="badge 대여불가">알 수 없음</span></c:otherwise>
                      </c:choose>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>${e.location}</td>
                <td>
                  <c:choose>
                    <c:when test="${sessionScope.role == 'ADMIN' or sessionScope.role == 'ASSISTANT' or sessionScope.role == 'STAFF'}">
                      <a href="${pageContext.request.contextPath}/equipment/edit/${e.id}" class="btn btn-outline-primary">수정</a>
                      <form action="${pageContext.request.contextPath}/equipment/delete/${e.id}" method="post" style="display:inline;" onsubmit="return confirm('정말 삭제하시겠습니까?');">
                        <button type="submit" class="btn btn-secondary">삭제</button>
                      </form>
                    </c:when>

                    <c:when test="${sessionScope.role == 'STUDENT'}">
                      <c:set var="rental" value="${rentalMap[e.id]}" />
                      <c:set var="alreadyReserved" value="${reservationStatusMap[e.id]}" />
                      <c:set var="repairStatus" value="${repairStatusMap[e.id]}" />

                      <c:choose>
                        <%-- 대여 상태가 REJECTED인 경우 최우선 처리 --%>
                        <c:when test="${rental != null && rental.status == 'REJECTED'}">
                          <a href="<c:url value='/equipmentrental/request/${e.id}'/>" class="btn btn-outline-primary">재신청</a>
                        </c:when>

                        <%-- 수리 상태가 REJECTED인 경우 우선 처리 --%>
                        <c:when test="${repairStatus == 'REJECTED'}">
                          <c:choose>
                            <%-- 대여중인 상태에서 수리 반려된 경우 --%>
                            <c:when test="${rental != null && rental.isApproved && rental.returnDate == null}">
                              <form action="<c:url value='/equipmentrental/return'/>" method="post" style="display:inline;">
                                <input type="hidden" name="rentalId" value="${rental.id}" />
                                <button type="submit" class="btn btn-secondary">반납하기</button>
                              </form>
                              <a href="<c:url value='/repair/form?equipmentId=${e.id}'/>" class="btn btn-outline-primary">수리재요청</a>
                            </c:when>
                            <%-- 그 외의 경우는 일반 대여 흐름 --%>
                            <c:otherwise>
                              <a href="<c:url value='/equipmentrental/request/${e.id}'/>" class="btn btn-outline-primary">대여신청</a>
                            </c:otherwise>
                          </c:choose>
                        </c:when>

                        <%-- 수리 요청 중 --%>
                        <c:when test="${repairStatus == 'PENDING'}">
                          <span class="btn btn-warning" style="pointer-events:none;">수리 요청중</span>
                        </c:when>

                        <%-- 수리 승인됨 (수리중) --%>
                        <c:when test="${repairStatus == 'APPROVED'}">
                          <span class="btn btn-secondary" style="pointer-events:none;">수리중</span>
                        </c:when>

                        <%-- 수리 완료 --%>
                        <c:when test="${repairStatus == 'COMPLETED'}">
                          <a href="<c:url value='/equipmentrental/request/${e.id}'/>" class="btn btn-outline-primary">대여신청</a>
                        </c:when>

                        <%-- 수리 상태가 없거나 null인 경우 일반 대여 로직 --%>
                        <c:otherwise>
                          <c:choose>
                            <%-- 대여 내역이 없는 경우 --%>
                            <c:when test="${rental == null}">
                              <c:choose>
                                <%-- 재고가 없는 경우 예약 처리 --%>
                                <c:when test="${e.availableQuantity == 0}">
                                  <c:choose>
                                    <c:when test="${alreadyReserved}">
                                      <span class="btn btn-warning" style="pointer-events:none;">예약 완료</span>
                                    </c:when>
                                    <c:otherwise>
                                      <form action="<c:url value='/reservation/create'/>" method="post" style="display:inline;">
                                        <input type="hidden" name="equipmentId" value="${e.id}" />
                                        <button type="submit" class="btn btn-outline-primary">예약하기</button>
                                      </form>
                                    </c:otherwise>
                                  </c:choose>
                                </c:when>
                                <%-- 재고가 있는 경우 대여신청 --%>
                                <c:otherwise>
                                  <a href="<c:url value='/equipmentrental/request/${e.id}'/>" class="btn btn-outline-primary">대여신청</a>
                                </c:otherwise>
                              </c:choose>
                            </c:when>

                            <%-- 대여 내역이 있는 경우 --%>
                            <c:otherwise>
                              <c:choose>
                                <%-- 대여 승인 대기중 --%>
                                <c:when test="${rental.status == 'PENDING' || !rental.isApproved}">
                                  <span class="btn btn-warning" style="pointer-events:none;">승인 대기중</span>
                                </c:when>
                                
                                <%-- 대여중 (승인되었고 반납되지 않은 상태) --%>
                                <c:when test="${rental.isApproved && rental.returnDate == null}">
                                  <form action="<c:url value='/equipmentrental/return'/>" method="post" style="display:inline;">
                                    <input type="hidden" name="rentalId" value="${rental.id}" />
                                    <button type="submit" class="btn btn-secondary">반납하기</button>
                                  </form>
                                  <a href="<c:url value='/repair/form?equipmentId=${e.id}'/>" class="btn btn-outline-primary">수리요청</a>
                                </c:when>
                                
                                <%-- 반납 완료된 경우 재대여 가능 --%>
                                <c:otherwise>
                                  <a href="<c:url value='/equipmentrental/request/${e.id}'/>" class="btn btn-outline-primary">대여신청</a>
                                </c:otherwise>
                              </c:choose>
                            </c:otherwise>
                          </c:choose>
                        </c:otherwise>
                      </c:choose>
                    </c:when>

                    <c:otherwise>
                      <span class="btn btn-secondary" style="pointer-events:none; opacity:0.6;">대여불가</span>
                    </c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty equipmentList}">
              <tr>
                <td colspan="6" style="text-align:center; padding:20px;">조회된 기자재가 없습니다.</td>
              </tr>
            </c:if>
          </tbody>
        </table>

        <%-- 관리자,조교,교직원 전용 등록 버튼 --%>
        <c:if test="${sessionScope.role == 'ADMIN' or sessionScope.role == 'ASSISTANT' or sessionScope.role == 'STAFF'}">
          <div style="text-align: right; margin-top: 20px;">
            <a href="${pageContext.request.contextPath}/equipment/register" class="btn-register">+ 기자재 등록</a>
          </div>
        </c:if>

        <!-- 페이지네이션 -->
        <c:if test="${totalPages > 1}">
          <ul class="pagination">
            <!-- 이전 페이지 -->
            <li class="${currentPage == 1 ? 'disabled' : ''}">
              <a href="<c:url value='/equipment/list'>
                        <c:param name='page' value='${currentPage - 1}'/>
                        <c:param name='keyword' value='${param.keyword}'/>
                        <c:param name='category' value='${param.category}'/>
                        <c:param name='status' value='${param.status}'/>
                        <c:param name='location' value='${param.location}'/>
                        <c:param name='sortBy' value='${param.sortBy}'/>
                      </c:url>">‹</a>
            </li>

            <!-- 페이지 번호 -->
            <c:forEach var="i" begin="${startPage}" end="${endPage}">
              <li class="${i == currentPage ? 'active' : ''}">
                <a href="<c:url value='/equipment/list'>
                          <c:param name='page' value='${i}'/>
                          <c:param name='keyword' value='${param.keyword}'/>
                          <c:param name='category' value='${param.category}'/>
                          <c:param name='status' value='${param.status}'/>
                          <c:param name='location' value='${param.location}'/>
                          <c:param name='sortBy' value='${param.sortBy}'/>
                        </c:url>">${i}</a>
              </li>
            </c:forEach>

            <!-- 다음 페이지 -->
            <li class="${currentPage == totalPages ? 'disabled' : ''}">
              <a href="<c:url value='/equipment/list'>
                        <c:param name='page' value='${currentPage + 1}'/>
                        <c:param name='keyword' value='${param.keyword}'/>
                        <c:param name='category' value='${param.category}'/>
                        <c:param name='status' value='${param.status}'/>
                        <c:param name='location' value='${param.location}'/>
                        <c:param name='sortBy' value='${param.sortBy}'/>
                      </c:url>">›</a>
            </li>
          </ul>
        </c:if>
      </div>
    </div>
    <%@ include file="../layout/footer.jsp" %>
  </div>

  <script>
    function changeSortOrder(sortBy) {
      const currentUrl = new URL(window.location);
      currentUrl.searchParams.set('sortBy', sortBy);
      currentUrl.searchParams.set('page', '1'); // 정렬 변경 시 첫 페이지로
      window.location.href = currentUrl.toString();
    }

    // 엔터 키로 검색 실행
    document.querySelector('input[name="keyword"]').addEventListener('keypress', function(e) {
      if (e.key === 'Enter') {
        e.preventDefault();
        this.closest('form').submit();
      }
    });
  </script>
</body>
</html>