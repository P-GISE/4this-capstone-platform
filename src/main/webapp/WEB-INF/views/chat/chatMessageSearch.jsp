<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>메시지 검색 - ${not empty chatRoom ? chatRoom.name : '채팅방'}</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <style>
        .message-item {
            padding: 10px;
            border-bottom: 1px solid #eee;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .message-item:hover {
            background-color: #f8f9fa;
        }
        .message-item.selected {
            background-color: #e3f2fd;
            border-left: 4px solid #2196f3;
        }
        .message-time {
            font-size: 0.8em;
            color: #6c757d;
        }
        .search-highlight {
            background-color: #fff3cd;
            padding: 2px;
            border-radius: 2px;
            font-weight: bold;
        }
        .search-counter {
            font-size: 0.9em;
            color: #6c757d;
            margin-left: 10px;
        }
        .search-navigation {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .search-navigation button {
            padding: 5px 10px;
            border: 1px solid #ddd;
            background: white;
            cursor: pointer;
            border-radius: 3px;
        }
        .search-navigation button:hover {
            background: #f8f9fa;
        }
        .search-navigation button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div class="container mt-4">
        <div class="row">
            <div class="col-md-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h4>메시지 검색</h4>
                        <a href="/chat/room/<c:out value='${not empty chatRoom ? chatRoom.roomId : ""}'/>" class="btn btn-outline-secondary">채팅방으로 돌아가기</a>
                    </div>
                    <div class="card-body">
                        <form id="searchForm" class="mb-4">
                            <div class="row">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <label for="searchKeyword">검색어</label>
                                        <div class="input-group">
                                            <input type="text" class="form-control" id="searchKeyword" 
                                                   name="keyword" value="${param.keyword}" 
                                                   placeholder="검색어를 입력하고 엔터를 누르세요">
                                            <div class="input-group-append">
                                                <button type="submit" class="btn btn-primary">검색</button>
                                            </div>
                                        </div>
                                        <small class="form-text text-muted">
                                            검색 후 엔터키로 결과 간 이동 가능
                                        </small>
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="form-group">
                                        <label for="searchDate">날짜</label>
                                        <input type="date" class="form-control" id="searchDate" 
                                               name="date" value="${param.date}">
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <div class="form-group">
                                        <label for="searchUser">작성자</label>
                                        <input type="text" class="form-control" id="searchUser" 
                                               name="user" value="${param.user}">
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <div class="form-group">
                                        <label>&nbsp;</label>
                                        <div class="search-navigation">
                                            <button type="button" id="prevBtn" class="btn btn-sm btn-outline-secondary" disabled>
                                                ↑
                                            </button>
                                            <button type="button" id="nextBtn" class="btn btn-sm btn-outline-secondary" disabled>
                                                ↓
                                            </button>
                                            <span id="searchCounter" class="search-counter"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>

                        <div id="searchResults">
                            <c:choose>
                                <c:when test="${not empty messages}">
                                    <c:forEach items="${messages}" var="message" varStatus="status">
                                        <div class="message-item" data-message-id="${message.id}" data-index="${status.index}">
                                            <div class="d-flex justify-content-between">
                                                <strong>${message.senderName}</strong>
                                                <span class="message-time">
                                                    <c:choose>
                                                        <c:when test="${not empty message.sendTime}">
                                                            ${message.sendTime.toString().substring(0, 16).replace('T', ' ')}
                                                        </c:when>
                                                        <c:otherwise>
                                                            -
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            <div class="message-content mt-2">
                                                <c:out value="${message.content}"/>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center text-muted mt-4">
                                        <c:choose>
                                            <c:when test="${not empty param.keyword or not empty param.date or not empty param.user}">
                                                검색 결과가 없습니다.
                                            </c:when>
                                            <c:otherwise>
                                                검색어를 입력해주세요.
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <c:if test="${not empty messages}">
                            <nav class="mt-4">
                                <ul class="pagination justify-content-center">
                                    <c:if test="${currentPage > 1}">
                                        <li class="page-item">
                                            <a class="page-link" href="?page=${currentPage-1}&keyword=${param.keyword}&date=${param.date}&user=${param.user}">이전</a>
                                        </li>
                                    </c:if>
                                    
                                    <c:forEach begin="1" end="${totalPages}" var="i">
                                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                                            <a class="page-link" href="?page=${i}&keyword=${param.keyword}&date=${param.date}&user=${param.user}">${i}</a>
                                        </li>
                                    </c:forEach>
                                    
                                    <c:if test="${currentPage < totalPages}">
                                        <li class="page-item">
                                            <a class="page-link" href="?page=${currentPage+1}&keyword=${param.keyword}&date=${param.date}&user=${param.user}">다음</a>
                                        </li>
                                    </c:if>
                                </ul>
                            </nav>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    //<![CDATA[
        let currentResultIndex = -1;
        let messageItems = [];
        let totalResults = 0;
        const chatRoomId = '<c:choose><c:when test="${not empty chatRoom}"><c:out value="${chatRoom.roomId}"/></c:when><c:otherwise></c:otherwise></c:choose>';

        // 페이지 로드 시 초기화
        document.addEventListener('DOMContentLoaded', function() {
            initializeSearch();
            highlightSearchTerms();
        });

        function initializeSearch() {
            messageItems = document.querySelectorAll('.message-item');
            totalResults = messageItems.length;
            
            if (totalResults > 0) {
                updateSearchCounter();
                updateNavigationButtons();
                
                // 첫 번째 결과 선택
                if (currentResultIndex === -1) {
                    currentResultIndex = 0;
                    selectMessage(0);
                }
                
                // 메시지 아이템 클릭 이벤트
                messageItems.forEach((item, index) => {
                    item.addEventListener('click', function() {
                        selectMessage(index);
                    });
                    
                    item.addEventListener('dblclick', function() {
                        const messageId = this.dataset.messageId;
                        navigateToMessage(messageId);
                    });
                });
            }
        }

        function selectMessage(index) {
            // 이전 선택 해제
            messageItems.forEach(item => item.classList.remove('selected'));
            
            if (index >= 0 && index < messageItems.length) {
                currentResultIndex = index;
                messageItems[index].classList.add('selected');
                
                // 스크롤하여 선택된 메시지 표시
                messageItems[index].scrollIntoView({
                    behavior: 'smooth',
                    block: 'center'
                });
                
                updateSearchCounter();
                updateNavigationButtons();
            }
        }

        function updateSearchCounter() {
            const counter = document.getElementById('searchCounter');
            if (totalResults > 0) {
                counter.textContent = (currentResultIndex + 1) + '/' + totalResults;
            } else {
                counter.textContent = '';
            }
        }

        function updateNavigationButtons() {
            const prevBtn = document.getElementById('prevBtn');
            const nextBtn = document.getElementById('nextBtn');
            
            prevBtn.disabled = currentResultIndex <= 0;
            nextBtn.disabled = currentResultIndex >= totalResults - 1;
        }

        function navigateToMessage(messageId) {
            if (chatRoomId) {
                // 새 창으로 열어서 메시지 위치로 이동
                window.open('/chat/room/' + chatRoomId + '?messageId=' + messageId, '_blank');
            } else {
                alert('채팅방 정보를 가져올 수 없습니다.');
            }
        }

        // 검색어 하이라이트 처리
        function highlightSearchTerms() {
            const keyword = '${param.keyword}';
            if (keyword && keyword.trim() !== '') {
                // 단순 문자열 치환으로 하이라이트 처리
                document.querySelectorAll('.message-content').forEach(element => {
                    const text = element.textContent;
                    if (text && text.trim() !== '') {
                        const lowerText = text.toLowerCase();
                        const lowerKeyword = keyword.toLowerCase();
                        let highlightedText = '';
                        let startIndex = 0;
                        let foundIndex = lowerText.indexOf(lowerKeyword);
                        
                        while (foundIndex !== -1) {
                            highlightedText += text.substring(startIndex, foundIndex);
                            highlightedText += '<span class="search-highlight">' + 
                                             text.substring(foundIndex, foundIndex + keyword.length) + 
                                             '</span>';
                            startIndex = foundIndex + keyword.length;
                            foundIndex = lowerText.indexOf(lowerKeyword, startIndex);
                        }
                        highlightedText += text.substring(startIndex);
                        element.innerHTML = highlightedText;
                    }
                });
            }
        }

        // 검색 폼 유효성 검사
        function validateSearchForm() {
            const keyword = document.getElementById('searchKeyword').value.trim();
            const date = document.getElementById('searchDate').value.trim();
            const user = document.getElementById('searchUser').value.trim();
            
            if (!keyword && !date && !user) {
                alert('검색 조건을 하나 이상 입력해주세요.');
                return false;
            }
            return true;
        }

        // 이벤트 리스너 설정
        document.getElementById('searchForm').addEventListener('submit', function(e) {
            if (!validateSearchForm()) {
                e.preventDefault();
            }
        });

        // 키보드 이벤트 처리
        document.addEventListener('keydown', function(e) {
            if (totalResults > 0) {
                if (e.key === 'Enter' && e.target.id === 'searchKeyword') {
                    // 검색어 입력 필드에서 엔터 시 다음 결과로 이동
                    e.preventDefault();
                    
                    if (document.getElementById('searchKeyword').value.trim()) {
                        // 검색어가 있으면 다음 결과로 이동
                        navigateNext();
                    } else {
                        // 검색어가 없으면 검색 실행
                        document.getElementById('searchForm').submit();
                    }
                } else if (e.key === 'ArrowDown' || (e.key === 'Enter' && e.target.id !== 'searchKeyword')) {
                    e.preventDefault();
                    navigateNext();
                } else if (e.key === 'ArrowUp') {
                    e.preventDefault();
                    navigatePrevious();
                } else if (e.key === 'Enter' && e.target.classList.contains('message-item')) {
                    // 메시지 아이템에서 엔터 시 해당 메시지로 이동
                    const messageId = e.target.dataset.messageId;
                    navigateToMessage(messageId);
                }
            }
        });

        function navigateNext() {
            if (currentResultIndex < totalResults - 1) {
                selectMessage(currentResultIndex + 1);
            }
        }

        function navigatePrevious() {
            if (currentResultIndex > 0) {
                selectMessage(currentResultIndex - 1);
            }
        }

        // 네비게이션 버튼 이벤트
        document.getElementById('prevBtn').addEventListener('click', navigatePrevious);
        document.getElementById('nextBtn').addEventListener('click', navigateNext);
    //]]>
    </script>
</body>
</html> 