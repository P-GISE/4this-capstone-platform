<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<head>
    <%@ include file="/WEB-INF/views/layout/head-meta.jsp" %>
    <title>아카이브 승인 관리</title>
    <style>
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
        
        .page-header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
            text-align: center;
            box-shadow: 0 8px 32px rgba(102, 126, 234, 0.3);
        }
        
        .page-title {
            font-size: 2.2em;
            font-weight: 700;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }
        
        .archive-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
            gap: 25px;
            margin-top: 20px;
        }
        
        .archive-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);
            border: 1px solid #e2e8f0;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .archive-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #667eea, #764ba2);
        }
        
        .archive-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.15);
            border-color: #667eea;
        }
        
        .archive-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 20px;
        }
        
        .archive-title {
            font-size: 1.3em;
            font-weight: 700;
            color: #2d3748;
            margin: 0;
            line-height: 1.4;
            flex: 1;
            margin-right: 15px;
        }
        
        .status-badge {
            background: #fbbf24;
            color: white;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.8em;
            font-weight: 600;
            white-space: nowrap;
        }
        
        .archive-meta {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #6c757d;
            font-size: 0.9em;
        }
        
        .meta-item i {
            color: #667eea;
            width: 16px;
        }
        
        .meta-value {
            color: #2d3748;
            font-weight: 500;
        }
        
        .archive-description {
            color: #4a5568;
            line-height: 1.6;
            margin-bottom: 20px;
            max-height: 60px;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .archive-actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            padding-top: 20px;
            border-top: 1px solid #f1f3f4;
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            font-size: 0.9em;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(16, 185, 129, 0.4);
        }
        
        .btn-secondary {
            background: #e2e8f0;
            color: #4a5568;
        }
        
        .btn-secondary:hover {
            background: #cbd5e0;
        }
        
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            color: #6c757d;
        }
        
        .empty-state i {
            font-size: 4em;
            margin-bottom: 20px;
            opacity: 0.3;
        }
        
        .empty-state h3 {
            margin-bottom: 10px;
            font-weight: 600;
        }
        
        .stats-bar {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            border: 1px solid #e2e8f0;
            text-align: center;
        }
        
        .stats-number {
            font-size: 2em;
            font-weight: 700;
            color: #667eea;
            margin-bottom: 5px;
        }
        
        .stats-label {
            color: #6c757d;
            font-weight: 500;
        }
        
        /* 로딩 스피너 */
        .loading {
            opacity: 0.6;
            pointer-events: none;
        }
        
        .loading .btn-primary {
            background: #cbd5e0;
        }
        
        /* 반응형 */
        @media (max-width: 768px) {
            .main-body {
                padding: 120px 20px 20px 20px;
            }
            
            .archive-grid {
                grid-template-columns: 1fr;
            }
            
            .page-title {
                font-size: 1.8em;
            }
            
            .archive-meta {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>
<div class="sidebar">
    <%@ include file="/WEB-INF/views/layout/sidebar.jsp" %>
</div>

<div class="content">
    <%@ include file="/WEB-INF/views/layout/header.jsp" %>
    
    <div class="main-body">
        <!-- 페이지 헤더 -->
        <div class="page-header">
            <h1 class="page-title">
                <i class="fas fa-clock"></i>
                아카이브 승인 관리
            </h1>
            <p style="margin: 10px 0 0 0; opacity: 0.9;">승인 대기중인 아카이브를 관리할 수 있습니다</p>
        </div>
        
        <!-- 통계 -->
        <div class="stats-bar">
            <div class="stats-number">${fn:length(pendingArchives)}</div>
            <div class="stats-label">승인 대기중인 아카이브</div>
        </div>
        
        <!-- 아카이브 목록 -->
        <c:choose>
            <c:when test="${not empty pendingArchives}">
                <div class="archive-grid">
                    <c:forEach items="${pendingArchives}" var="archive" varStatus="status">
                        <!-- 디버깅 정보 -->
                        <!-- 아카이브 ${status.index + 1}: ID=${archive.id}, 제목=${archive.title} -->
                        <!-- 
                        DEBUG: archive.id = [${archive.id}]
                        DEBUG: archive.title = [${archive.title}]
                        DEBUG: archive object = ${archive}
                        -->
                        <div class="archive-card" data-archive-id="${archive.id}"
                             data-debug-id="${archive.id}"
                             data-debug-title="${archive.title}">
                            <div class="archive-header">
                                <h3 class="archive-title">
                                    <c:out value="${archive.title}" />
                                </h3>
                                <span class="status-badge">
                                    <i class="fas fa-clock"></i> 대기중
                                </span>
                            </div>
                            
                            <div class="archive-meta">
                                <div class="meta-item">
                                    <i class="fas fa-user"></i>
                                    <span>작성자</span>
                                    <span class="meta-value"><c:out value="${archive.submittedByName}" /></span>
                                </div>
                                <div class="meta-item">
                                    <i class="fas fa-calendar"></i>
                                    <span>제출일</span>
                                    <span class="meta-value">
                                        <fmt:formatDate value="${archive.submittedAt}" pattern="MM/dd" />
                                    </span>
                                </div>
                                <div class="meta-item">
                                    <i class="fas fa-tag"></i>
                                    <span>카테고리</span>
                                    <span class="meta-value"><c:out value="${archive.category}" /></span>
                                </div>
                                <div class="meta-item">
                                    <i class="fas fa-code-branch"></i>
                                    <span>버전</span>
                                    <span class="meta-value"><c:out value="${archive.version}" /></span>
                                </div>
                            </div>
                            
                            <c:if test="${not empty archive.description}">
                                <div class="archive-description">
                                    <c:out value="${archive.description}" />
                                </div>
                            </c:if>
                            
                            <div class="archive-actions">
                                <a href="${pageContext.request.contextPath}/archive/detail/${archive.id}" 
                                   class="btn btn-secondary">
                                    <i class="fas fa-eye"></i> 상세보기
                                </a>
                                <button type="button" 
                                        class="btn btn-primary approve-btn" 
                                        data-archive-id="<c:out value='${archive.id}'/>"
                                        data-archive-title="<c:out value='${archive.title}'/>">
                                    <i class="fas fa-check"></i> 승인
                                </button>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="empty-state">
                    <i class="fas fa-clipboard-check"></i>
                    <h3>승인 대기중인 아카이브가 없습니다</h3>
                    <p>모든 아카이브가 처리되었습니다.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <%@ include file="/WEB-INF/views/layout/footer.jsp" %>
</div>

<%@ include file="/WEB-INF/views/layout/scripts.jsp" %>

<script>
// 컨텍스트 패스 설정
const contextPath = '<c:out value="${pageContext.request.contextPath}"/>';

document.addEventListener('DOMContentLoaded', function() {
    console.log('=== 페이지 로드 완료 ===');
    console.log('컨텍스트 패스:', contextPath);
    
    const approveButtons = document.querySelectorAll('.approve-btn');
    console.log('승인 버튼 개수:', approveButtons.length);
    
    // 각 버튼의 데이터 확인
    approveButtons.forEach((button, index) => {
        console.log(`=== 버튼 ${index + 1} 상세 정보 ===`);
        console.log('DOM Element:', button);
        console.log('outerHTML:', button.outerHTML);
        console.log('dataset 전체:', button.dataset);
        console.log('data-archive-id 속성:', button.getAttribute('data-archive-id'));
        console.log('data-debug-id 속성:', button.getAttribute('data-debug-id'));
        console.log('dataset.archiveId:', button.dataset.archiveId);
        console.log('dataset.debugId:', button.dataset.debugId);
        console.log('===========================');
    });
    
    // 승인 버튼 이벤트
    approveButtons.forEach(button => {
        button.addEventListener('click', function() {
            const archiveId = this.dataset.archiveId;
            const archiveTitle = this.dataset.archiveTitle;
            
            console.log('=== 승인 버튼 클릭 ===');
            console.log('버튼 요소:', this);
            console.log('dataset:', this.dataset);
            console.log('archiveId:', archiveId);
            console.log('archiveId 타입:', typeof archiveId);
            console.log('archiveTitle:', archiveTitle);
            console.log('contextPath:', contextPath);
            console.log('====================');
            
            if (!archiveId || archiveId === '' || archiveId === 'undefined' || archiveId === 'null') {
                alert('아카이브 ID가 유효하지 않습니다: ' + archiveId);
                return;
            }
            
            if (confirm(`"${archiveTitle}" 아카이브를 승인하시겠습니까?\n\n승인 후에는 다른 사용자들이 볼 수 있게 됩니다.`)) {
                approveArchive(archiveId, this);
            }
        });
    });
});

function approveArchive(archiveId, buttonElement) {
    // ID 유효성 검사
    if (!archiveId || archiveId === 'undefined') {
        alert('아카이브 ID를 찾을 수 없습니다.');
        return;
    }
    
    // 버튼 로딩 상태
    const originalContent = buttonElement.innerHTML;
    buttonElement.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 승인중...';
    buttonElement.disabled = true;
    
    // 카드도 로딩 상태로
    const card = buttonElement.closest('.archive-card');
    card.classList.add('loading');
    
    // URL을 단계별로 구성 (디버깅용)
    const baseUrl = contextPath + '/archive/admin/approve/';
    const requestUrl = baseUrl + archiveId;
    
    console.log('=== 승인 요청 시작 ===');
    console.log('아카이브 ID:', archiveId);
    console.log('아카이브 ID 타입:', typeof archiveId);
    console.log('아카이브 ID 길이:', archiveId ? archiveId.length : 'undefined');
    console.log('컨텍스트 패스:', contextPath);
    console.log('기본 URL:', baseUrl);
    console.log('최종 요청 URL:', requestUrl);
    console.log('====================');
    
    fetch(requestUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        }
    })
    .then(response => {
        console.log('응답 상태:', response.status);
        console.log('응답 헤더:', response.headers);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        return response.json();
    })
    .then(data => {
        console.log('응답 데이터:', data);
        
        if (data.success) {
            // 성공 메시지
            showSuccessMessage(data.message);
            
            // 카드를 서서히 사라지게 하고 제거
            card.style.transition = 'all 0.5s ease';
            card.style.opacity = '0';
            card.style.transform = 'scale(0.9)';
            
            setTimeout(() => {
                card.remove();
                
                // 남은 아카이브가 없으면 empty state 표시
                const remainingCards = document.querySelectorAll('.archive-card');
                if (remainingCards.length === 0) {
                    location.reload(); // 페이지 새로고침으로 empty state 표시
                } else {
                    // 통계 업데이트
                    const statsNumber = document.querySelector('.stats-number');
                    if (statsNumber) {
                        statsNumber.textContent = remainingCards.length;
                    }
                }
            }, 500);
            
        } else {
            // 실패 시 원상복구
            buttonElement.innerHTML = originalContent;
            buttonElement.disabled = false;
            card.classList.remove('loading');
            
            showErrorMessage(data.message || '승인 처리 중 오류가 발생했습니다.');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        
        // 오류 시 원상복구
        buttonElement.innerHTML = originalContent;
        buttonElement.disabled = false;
        card.classList.remove('loading');
        
        showErrorMessage('승인 처리 중 네트워크 오류가 발생했습니다.');
    });
}

function showSuccessMessage(message) {
    // 간단한 성공 알림
    const alert = document.createElement('div');
    alert.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: #10b981;
        color: white;
        padding: 15px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        z-index: 10000;
        font-weight: 600;
    `;
    alert.innerHTML = `<i class="fas fa-check-circle"></i> ${message}`;
    document.body.appendChild(alert);
    
    setTimeout(() => {
        alert.remove();
    }, 3000);
}

function showErrorMessage(message) {
    // 간단한 오류 알림
    const alert = document.createElement('div');
    alert.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: #ef4444;
        color: white;
        padding: 15px 20px;
        border-radius: 8px;
        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
        z-index: 10000;
        font-weight: 600;
    `;
    alert.innerHTML = `<i class="fas fa-exclamation-circle"></i> ${message}`;
    document.body.appendChild(alert);
    
    setTimeout(() => {
        alert.remove();
    }, 4000);
}
</script>

</body>
</html> 