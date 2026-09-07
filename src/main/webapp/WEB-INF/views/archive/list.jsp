<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<%@ include file="../layout/head-meta.jsp" %>
<body>
    <!-- 1) 사이드바 -->
    <div class="sidebar">
        <%@ include file="../layout/sidebar.jsp" %>
    </div>

    <!-- 2) 메인 콘텐츠 -->
    <div class="content">
        <!-- 2-1) 헤더 -->
        <%@ include file="../layout/header.jsp" %>

        <!-- 2-2) 본문 영역 -->
        <div class="main-body archive-page">
            <!-- 상단 섹션 -->
            <div class="archive-header">
                <h2 class="section-title">아카이브/결과물</h2>
                <c:if test="${sessionScope.loginUser.role eq 'STUDENT'}">
                    <button class="btn-primary archive-submit-btn">결과물 등록</button>
                </c:if>
            </div>

            <!-- 검색 및 필터 섹션 -->
            <div class="search-filter-section">
                <form method="GET" action="${pageContext.request.contextPath}/archive/list" id="searchForm">
                    <div class="search-box">
                        <input type="text" name="search" placeholder="프로젝트명, 키워드 검색" class="search-input" value="${search}">
                        <button type="submit" class="search-btn">검색</button>
                    </div>
                    <div class="filter-options">
                        <select name="year" class="filter-select" onchange="this.form.submit()">
                            <option value="">연도: 전체</option>
                            <option value="2024"<c:if test="${year eq '2024'}"> selected</c:if>>2024년</option>
                            <option value="2023"<c:if test="${year eq '2023'}"> selected</c:if>>2023년</option>
                            <option value="2022"<c:if test="${year eq '2022'}"> selected</c:if>>2022년</option>
                        </select>
                        <select name="category" class="filter-select" onchange="this.form.submit()">
                            <option value="">분야: 전체</option>
                            <option value="IoT"<c:if test="${category eq 'IoT'}"> selected</c:if>>IoT</option>
                            <option value="로봇"<c:if test="${category eq '로봇'}"> selected</c:if>>로봇</option>
                            <option value="AI/머신러닝"<c:if test="${category eq 'AI/머신러닝'}"> selected</c:if>>AI/머신러닝</option>
                            <option value="웹개발"<c:if test="${category eq '웹개발'}"> selected</c:if>>웹개발</option>
                            <option value="모바일"<c:if test="${category eq '모바일'}"> selected</c:if>>모바일</option>
                            <option value="기타"<c:if test="${category eq '기타'}"> selected</c:if>>기타</option>
                        </select>
                    </div>
                    <!-- 페이지 리셋을 위한 hidden input -->
                    <input type="hidden" name="page" value="1">
                </form>
            </div>

            <!-- 카테고리 태그 -->
            <div class="category-tags">
                <c:choose>
                    <c:when test="${empty category}">
                        <button class="tag-btn active" onclick="filterByCategory('')">전체</button>
                    </c:when>
                    <c:otherwise>
                        <button class="tag-btn" onclick="filterByCategory('')">전체</button>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${category eq 'IoT'}">
                        <button class="tag-btn active" onclick="filterByCategory('IoT')">IoT</button>
                    </c:when>
                    <c:otherwise>
                        <button class="tag-btn" onclick="filterByCategory('IoT')">IoT</button>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${category eq '로봇'}">
                        <button class="tag-btn active" onclick="filterByCategory('로봇')">로봇</button>
                    </c:when>
                    <c:otherwise>
                        <button class="tag-btn" onclick="filterByCategory('로봇')">로봇</button>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${category eq 'AI/머신러닝'}">
                        <button class="tag-btn active" onclick="filterByCategory('AI/머신러닝')">AI/머신러닝</button>
                    </c:when>
                    <c:otherwise>
                        <button class="tag-btn" onclick="filterByCategory('AI/머신러닝')">AI/머신러닝</button>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${category eq '웹개발'}">
                        <button class="tag-btn active" onclick="filterByCategory('웹개발')">웹개발</button>
                    </c:when>
                    <c:otherwise>
                        <button class="tag-btn" onclick="filterByCategory('웹개발')">웹개발</button>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${category eq '모바일'}">
                        <button class="tag-btn active" onclick="filterByCategory('모바일')">모바일</button>
                    </c:when>
                    <c:otherwise>
                        <button class="tag-btn" onclick="filterByCategory('모바일')">모바일</button>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${category eq '기타'}">
                        <button class="tag-btn active" onclick="filterByCategory('기타')">기타</button>
                    </c:when>
                    <c:otherwise>
                        <button class="tag-btn" onclick="filterByCategory('기타')">기타</button>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- 아카이브 카드 그리드 -->
            <div class="archive-grid">
                <c:forEach var="archive" items="${archives}" varStatus="status">
                    <div class="archive-card" onclick="location.href='${pageContext.request.contextPath}/archive/detail/${archive.id}'" style="cursor: pointer;">
                        <!-- 카드 썸네일 영역 -->
                        <div class="card-thumbnail">
                            <div class="play-button">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
                                    <path d="M8 5V19L19 12L8 5Z" fill="white"/>
                                </svg>
                            </div>
                            <!-- 배경색을 다양하게 설정 -->
                            <c:choose>
                                <c:when test="${status.index % 4 == 0}">
                                    <div class="gradient-bg gradient-blue"></div>
                                </c:when>
                                <c:when test="${status.index % 4 == 1}">
                                    <div class="gradient-bg gradient-orange"></div>
                                </c:when>
                                <c:when test="${status.index % 4 == 2}">
                                    <div class="gradient-bg gradient-blue"></div>
                                </c:when>
                                <c:otherwise>
                                    <div class="gradient-bg gradient-green"></div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- 카드 정보 영역 -->
                        <div class="card-content">
                            <h3 class="card-title">
                                <c:out value="${archive.title}" />
                            </h3>
                            
                            <div class="card-tags">
                                <span class="tag tag-category">
                                    <c:out value="${archive.category}" />
                                </span>
                                <span class="tag tag-year">
                                    <fmt:formatDate value="${archive.submittedAt}" pattern="yyyy년" />
                                </span>
                                <span class="tag tag-level">프로젝트</span>
                            </div>

                            <p class="card-description">
                                <c:choose>
                                    <c:when test="${fn:length(archive.description) > 50}">
                                        <c:out value="${fn:substring(archive.description, 0, 50)}..." />
                                    </c:when>
                                    <c:otherwise>
                                        <c:out value="${archive.description}" />
                                    </c:otherwise>
                                </c:choose>
                            </p>

                            <!-- 카드 하단 정보 -->
                            <div class="card-footer">
                                <div class="author-info">
                                    <span class="author-name">
                                        <c:out value="${archive.submittedByName}" />
                                    </span>
                                </div>
                                
                                <div class="card-actions">
                                    <span class="action-item">보고서</span>
                                    <span class="action-item">코드</span>
                                    <span class="action-item">동영상</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <!-- 빈 상태 처리 -->
                <c:if test="${empty archives}">
                    <div class="empty-state">
                        <c:choose>
                            <c:when test="${not empty search or not empty category or not empty year}">
                                <p>검색 조건에 맞는 아카이브가 없습니다.</p>
                                <p>다른 검색어나 필터를 시도해보세요.</p>
                            </c:when>
                            <c:otherwise>
                                <p>등록된 아카이브가 없습니다.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>
            </div>

            <!-- 페이지네이션 -->
            <c:if test="${totalPages > 1}">
                <c:set var="prevPage" value="${currentPage-1}" />
                <c:set var="nextPage" value="${currentPage+1}" />
                <div class="pagination">
                    <!-- 이전 페이지 -->
                    <c:if test="${currentPage > 1}">
                        <button class="page-btn" onclick="goToPage('${prevPage}')">‹</button>
                    </c:if>
                    <!-- 페이지 번호들 -->
                    <c:forEach begin="${startPage}" end="${endPage}" var="pageNum">
                        <c:choose>
                            <c:when test="${pageNum eq currentPage}">
                                <button class="page-btn active" onclick="goToPage('${pageNum}')">${pageNum}</button>
                            </c:when>
                            <c:otherwise>
                                <button class="page-btn" onclick="goToPage('${pageNum}')">${pageNum}</button>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <!-- 다음 페이지 -->
                    <c:if test="${currentPage < totalPages}">
                        <button class="page-btn" onclick="goToPage('${nextPage}')">›</button>
                    </c:if>
                </div>
            </c:if>
            
            <!-- 검색 결과 정보 -->
            <c:if test="${not empty search or not empty category or not empty year}">
                <div class="search-result-info">
                    <p>검색 결과: 총 ${totalCount}건</p>
                    <button onclick="clearSearch()" class="clear-search-btn">검색 초기화</button>
                </div>
            </c:if>
        </div>

        <!-- 2-3) 푸터 -->
        <%@ include file="../layout/footer.jsp" %>
    </div>

    <!-- 3) 페이지 전용 CSS -->
    <style>
        :root {
            --primary-color: #4751c9;
            --card-bg: #ffffff;
            --card-shadow: rgba(0, 0, 0, 0.06);
            --text-dark: #333333;
            --text-muted: #888888;
            --light-gray: #f5f5f7;
            --secondary-color: #e9eaff;
            --dark-color: #1e1e1e;
            --light-color: #ffffff;
            --accent-color: #ff7043;
            --grey-color: #f5f5f7;
            --light-purple: #e9e6ff;
            --active-purple: #6c63ff;
            --border-color: #eaeaea;
            --button-color: #f0f2f5;
        }

        .archive-page {
            padding: 20px;
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

        

        /* 헤더 섹션 */
        .archive-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--text-dark);
            margin: 0;
        }

        .archive-submit-btn {
            background-color: var(--active-purple);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .archive-submit-btn:hover {
            background-color: #5a52d5;
        }

        /* 검색 및 필터 섹션 */
        .search-filter-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            gap: 20px;
        }

        .search-box {
            display: flex;
            flex: 1;
            max-width: 400px;
        }

        .search-input {
            flex: 1;
            padding: 12px 16px;
            border: 1px solid var(--border-color);
            border-radius: 8px 0 0 8px;
            font-size: 14px;
            outline: none;
        }

        .search-btn {
            background-color: var(--active-purple);
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 0 8px 8px 0;
            cursor: pointer;
            font-weight: 500;
        }

        .filter-options {
            display: flex;
            gap: 10px;
        }

        .filter-select {
            padding: 10px 12px;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            background: white;
            font-size: 14px;
            min-width: 120px;
        }

        /* 카테고리 태그 */
        .category-tags {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }

        .tag-btn {
            padding: 8px 16px;
            border: 1px solid var(--border-color);
            background: white;
            border-radius: 20px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .tag-btn.active {
            background-color: var(--active-purple);
            color: white;
            border-color: var(--active-purple);
        }

        .tag-btn:hover:not(.active) {
            background-color: var(--light-gray);
        }

        /* 아카이브 그리드 */
        .archive-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }

        /* 아카이브 카드 */
        .archive-card {
            background: var(--card-bg);
            border-radius: 12px;
            box-shadow: 0 2px 8px var(--card-shadow);
            overflow: hidden;
            transition: transform 0.2s, box-shadow 0.2s;
            
            /* 텍스트 넘침 방지를 위한 추가 안전장치 */
            width: 100%;
            max-width: 100%;
            box-sizing: border-box;
        }

        .archive-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
        }

        /* 카드 썸네일 */
        .card-thumbnail {
            height: 200px;
            position: relative;
            overflow: hidden;
        }

        .gradient-bg {
            width: 100%;
            height: 100%;
            position: absolute;
            top: 0;
            left: 0;
        }

        .gradient-blue {
            background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);
        }

        .gradient-orange {
            background: linear-gradient(135deg, #fd79a8 0%, #fdcb6e 100%);
        }

        .gradient-green {
            background: linear-gradient(135deg, #00b894 0%, #55efc4 100%);
        }

        .play-button {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 60px;
            height: 60px;
            background-color: rgba(255, 255, 255, 0.9);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .play-button:hover {
            background-color: white;
        }

        /* 카드 컨텐츠 */
        .card-content {
            padding: 20px;
            overflow: hidden;
            width: 100%;
            box-sizing: border-box;
        }

        .card-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 12px;
            line-height: 1.4;
            
            /* 텍스트 줄바꿈 관련 속성 추가 */
            word-wrap: break-word;
            word-break: break-word;
            overflow-wrap: break-word;
            white-space: normal;
            max-width: 100%;
            box-sizing: border-box;
        }

        .card-tags {
            display: flex;
            gap: 8px;
            margin-bottom: 12px;
            flex-wrap: wrap;
            width: 100%;
            box-sizing: border-box;
        }

        .tag {
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
        }

        .tag-category {
            background-color: var(--light-purple);
            color: var(--active-purple);
        }

        .tag-year {
            background-color: #e8f4fd;
            color: #1890ff;
        }

        .tag-level {
            background-color: #fff2e8;
            color: #fa8c16;
        }

        .card-description {
            color: var(--text-muted);
            font-size: 14px;
            line-height: 1.5;
            margin-bottom: 16px;
            
            /* 텍스트 줄바꿈 관련 속성 추가 */
            word-wrap: break-word;
            word-break: break-word;
            overflow-wrap: break-word;
            white-space: normal;
            max-width: 100%;
            box-sizing: border-box;
        }

        /* 카드 푸터 */
        .card-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 12px;
            border-top: 1px solid #f0f0f0;
        }

        .author-info {
            display: flex;
            align-items: center;
        }

        .author-name {
            font-size: 14px;
            color: var(--text-muted);
            
            /* 텍스트 줄바꿈 관련 속성 추가 */
            word-wrap: break-word;
            word-break: break-word;
            overflow-wrap: break-word;
            max-width: 150px;
        }

        .card-actions {
            display: flex;
            gap: 8px;
        }

        .action-item {
            font-size: 12px;
            color: var(--text-muted);
            padding: 4px 8px;
            border-radius: 4px;
            background-color: var(--light-gray);
        }

        /* 페이지네이션 */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 40px;
        }

        .page-btn {
            width: 40px;
            height: 40px;
            border: 1px solid var(--border-color);
            background: white;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .page-btn.active {
            background-color: var(--active-purple);
            color: white;
            border-color: var(--active-purple);
        }

        .page-btn:hover:not(.active) {
            background-color: var(--light-gray);
        }

        /* 빈 상태 */
        .empty-state {
            grid-column: 1 / -1;
            text-align: center;
            padding: 60px 20px;
            color: var(--text-muted);
        }

        /* 검색 결과 정보 */
        .search-result-info {
            text-align: center;
            margin-top: 20px;
            padding: 15px;
            background-color: var(--light-gray);
            border-radius: 8px;
            color: var(--text-muted);
        }

        .search-result-info p {
            margin: 0 0 10px 0;
            font-size: 14px;
        }

        .clear-search-btn {
            background-color: var(--accent-color);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 12px;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .clear-search-btn:hover {
            background-color: #e55a3a;
        }



        /* 반응형 */
        @media (max-width: 768px) {
            .archive-grid {
                grid-template-columns: 1fr;
            }
            
            .search-filter-section {
                flex-direction: column;
                align-items: stretch;
                gap: 15px;
            }
            
            .search-box {
                max-width: none;
            }
            
            .filter-options {
                justify-content: space-between;
            }
            
            .archive-header {
                flex-direction: column;
                align-items: stretch;
                gap: 15px;
            }
        }

        @media (max-width: 480px) {
            .category-tags {
                overflow-x: auto;
                flex-wrap: nowrap;
                padding-bottom: 10px;
            }
            
            .tag-btn {
                white-space: nowrap;
            }
        }
    </style>

    <!-- 4) 공통 스크립트 -->
    <%@ include file="../layout/scripts.jsp" %>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // 카테고리 태그 클릭 이벤트
            const tagBtns = document.querySelectorAll('.tag-btn');
            tagBtns.forEach(btn => {
                btn.addEventListener('click', function() {
                    tagBtns.forEach(b => b.classList.remove('active'));
                    this.classList.add('active');
                });
            });

            // 검색 기능
            const searchBtn = document.querySelector('.search-btn');
            const searchInput = document.querySelector('.search-input');
            
            searchBtn.addEventListener('click', function() {
                const searchTerm = searchInput.value.trim();
                if (searchTerm) {
                    // 검색 로직 구현
                    console.log('검색어:', searchTerm);
                }
            });

            searchInput.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    searchBtn.click();
                }
            });

            // 결과물 등록 버튼
            const submitBtn = document.querySelector('.archive-submit-btn');
            submitBtn.addEventListener('click', function() {
                // 결과물 등록 페이지로 이동
                location.href = '${pageContext.request.contextPath}/archive/write';
            });

            // 필터 변경 시 자동 제출 방지 (이미 onchange로 처리됨)
            const filterSelects = document.querySelectorAll('.filter-select');
            filterSelects.forEach(select => {
                select.addEventListener('change', function() {
                    // 페이지를 1로 리셋
                    const pageInput = document.querySelector('input[name="page"]');
                    if (pageInput) {
                        pageInput.value = '1';
                    }
                });
            });
        });

        // 카테고리 필터링 함수
        function filterByCategory(category) {
            const url = new URL(window.location);
            if (category) {
                url.searchParams.set('category', category);
            } else {
                url.searchParams.delete('category');
            }
            // 페이지를 1로 리셋
            url.searchParams.set('page', '1');
            window.location.href = url.toString();
        }

        // 페이지 이동 함수
        function goToPage(page) {
            const url = new URL(window.location);
            url.searchParams.set('page', page);
            window.location.href = url.toString();
        }

        // 검색 초기화 함수
        function clearSearch() {
            const url = new URL(window.location);
            url.searchParams.delete('search');
            url.searchParams.delete('category');
            url.searchParams.delete('year');
            url.searchParams.set('page', '1');
            window.location.href = url.toString();
        }
    </script>
</body>
</html>