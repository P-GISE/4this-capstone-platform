<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/layout/head-meta.jsp" %>
    <title>팀원 관리 - ${projectDetail.project.title}</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        * {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
        }
        
        body {
            font-weight: 400;
            line-height: 1.6;
            color: #333;
        }
        
        h1, h2, h3, h4, h5, h6 {
            font-weight: 500;
            line-height: 1.4;
        }
        
        .font-weight-bold {
            font-weight: 500 !important;
        }
        
        .text-muted {
            color: #666 !important;
        }
        
        .btn {
            font-weight: 500;
            letter-spacing: -0.3px;
        }
        
        .modal-title {
            font-weight: 500;
        }
        
        .card-header h6 {
            font-weight: 500;
            font-size: 14px;
            color: #333;
        }
        
        small {
            font-size: 12px;
            font-weight: 400;
        }
        
        .member-card {
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            background: #fff;
            transition: box-shadow 0.3s ease;
        }
        .member-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .member-role {
            font-size: 0.9rem;
            font-weight: 500;
            padding: 4px 12px;
            border-radius: 20px;
        }
        .role-leader {
            background: #e8f0fe;
            color: #1a73e8;
        }
        .role-member {
            background: #e6f4ea;
            color: #137333;
        }
        .project-info-header {
            background: #f8f9fa;
            color: #333;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            border: 1px solid #e0e0e0;
        }
        .btn-back {
            background: #4285f4;
            border: 1px solid #4285f4;
            color: white;
            transition: all 0.3s ease;
        }
        .btn-back:hover {
            background: #3367d6;
            border-color: #3367d6;
            color: white;
        }
        .user-search-result {
            padding: 10px;
            border-bottom: 1px solid #eee;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .user-search-result:hover {
            background-color: #f8f9fa;
        }
        .user-search-result:last-child {
            border-bottom: none;
        }
        .search-avatar {
            width: 40px;
            height: 40px;
            background: #4285f4;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            margin-right: 12px;
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <%@ include file="/WEB-INF/views/layout/sidebar.jsp" %>
    </div>
    <div class="content">
        <%@ include file="/WEB-INF/views/layout/header.jsp" %>

        <div class="container-fluid" style="padding: 30px; margin-top: 80px;">
            <!-- 프로젝트 정보 헤더 -->
            <div class="project-info-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="mb-2">${projectDetail.project.title}</h2>
                        <p class="mb-0 opacity-75">팀원 관리</p>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/projects/${projectDetail.project.id}" class="btn btn-back">
                            ← 프로젝트로 돌아가기
                        </a>
                    </div>
                </div>
            </div>

            <!-- 팀원 목록 -->
            <div class="row">
                <div class="col-md-8">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h4 class="mb-0">팀원 목록 (${fn:length(projectDetail.members)}명)</h4>
                        
                        <!-- 팀장인 경우만 팀원 추가 버튼 표시 -->
                        <c:if test="${sessionScope.loginUser != null}">
                            <c:set var="isLeader" value="false" />
                            <c:forEach items="${projectDetail.members}" var="checkMember">
                                <c:if test="${checkMember.userId == sessionScope.loginUser.id && checkMember.role == 'LEADER' && checkMember.approved}">
                                    <c:set var="isLeader" value="true" />
                                </c:if>
                            </c:forEach>
                            
                            <c:if test="${isLeader}">
                                <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#addMemberModal">
                                    + 팀원 추가
                                </button>
                            </c:if>
                        </c:if>
                    </div>
                    
                    <c:forEach items="${projectDetail.members}" var="member">
                    <div class="member-card" id="member-${member.userId}">
                        <div class="row align-items-center">
                            <div class="col-md-6">
                                <div class="d-flex align-items-center">
                                    <div class="mr-3">
                                        <div style="width: 50px; height: 50px; background: #4285f4; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-weight: bold; font-size: 1.2rem;">
                                            ${fn:substring(member.userName, 0, 1)}
                                        </div>
                                    </div>
                                    <div>
                                        <h6 class="mb-1">${member.userName}</h6>
                                        <small class="text-muted">사용자 ID: ${member.userId}</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 text-center">
                                <c:choose>
                                    <c:when test="${member.role == 'LEADER'}">
                                        <span class="member-role role-leader">👑 팀장</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="member-role role-member">👤 팀원</span>
                                    </c:otherwise>
                                </c:choose>
                                
                                <c:if test="${!member.approved}">
                                    <br><small class="text-warning mt-1">⏳ 승인 대기중</small>
                                </c:if>
                            </div>
                            <div class="col-md-3 text-right">
                                <!-- 팀장인 경우만 관리 버튼 표시 -->
                                <c:if test="${sessionScope.loginUser != null}">
                                    <c:set var="isLeader" value="false" />
                                    <c:forEach items="${projectDetail.members}" var="checkMember">
                                        <c:if test="${checkMember.userId == sessionScope.loginUser.id && checkMember.role == 'LEADER' && checkMember.approved}">
                                            <c:set var="isLeader" value="true" />
                                        </c:if>
                                    </c:forEach>
                                    
                                    <c:if test="${isLeader}">
                                        
                                        <!-- 승인된 멤버 (본인 제외) -->
                                        <c:if test="${member.approved && member.userId != sessionScope.loginUser.id}">
                                            <div class="btn-group-vertical btn-group-sm">
                                                <c:if test="${member.role == 'MEMBER'}">
                                                    <button class="btn btn-outline-success btn-sm mb-1" onclick="changeRole('${projectDetail.project.id}', '${member.userId}', '${member.userName}', 'LEADER')" title="팀장으로 변경">
                                                        👑 팀장
                                                    </button>
                                                </c:if>
                                                <c:if test="${member.role == 'LEADER'}">
                                                    <button class="btn btn-outline-primary btn-sm mb-1" onclick="changeRole('${projectDetail.project.id}', '${member.userId}', '${member.userName}', 'MEMBER')" title="팀원으로 변경">
                                                        👤 팀원
                                                    </button>
                                                </c:if>
                                                <button class="btn btn-outline-danger btn-sm" onclick="removeMember('${projectDetail.project.id}', '${member.userId}', '${member.userName}')" title="팀원 삭제">
                                                    🗑️ 삭제
                                                </button>
                                            </div>
                                        </c:if>
                                    </c:if>
                                </c:if>
                            </div>
                        </div>
                    </div>
                    </c:forEach>
                </div>
                
                <div class="col-md-4">
                    <!-- 프로젝트 통계 -->
                    <div class="card">
                        <div class="card-header">
                            <h6 class="mb-0">프로젝트 통계</h6>
                        </div>
                        <div class="card-body">
                            <div class="mb-3">
                                <small class="text-muted">총 팀원 수</small>
                                <div class="font-weight-bold text-primary">${fn:length(projectDetail.members)}명</div>
                            </div>
                            <div class="mb-3">
                                <small class="text-muted">승인된 팀원</small>
                                <div class="font-weight-bold text-success">
                                    <c:set var="approvedCount" value="0"/>
                                    <c:forEach items="${projectDetail.members}" var="member">
                                        <c:if test="${member.approved}">
                                            <c:set var="approvedCount" value="${approvedCount + 1}"/>
                                        </c:if>
                                    </c:forEach>
                                    ${approvedCount}명
                                </div>
                            </div>
                            <div class="mb-3">
                                <small class="text-muted">대기중인 팀원</small>
                                <div class="font-weight-bold text-warning">${fn:length(projectDetail.members) - approvedCount}명</div>
                            </div>
                            <div class="mb-3">
                                <small class="text-muted">총 작업</small>
                                <div class="font-weight-bold">${fn:length(projectDetail.tasks)}개</div>
                            </div>
                        </div>
                    </div>

                    <!-- 프로젝트 정보 -->
                    <div class="card mt-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h6 class="mb-0">프로젝트 정보</h6>
                            
                            <!-- 팀장인 경우만 프로젝트 삭제 버튼 표시 -->
                            <c:if test="${sessionScope.loginUser != null}">
                                <c:set var="isLeader" value="false" />
                                <c:forEach items="${projectDetail.members}" var="checkMember">
                                    <c:if test="${checkMember.userId == sessionScope.loginUser.id && checkMember.role == 'LEADER' && checkMember.approved}">
                                        <c:set var="isLeader" value="true" />
                                    </c:if>
                                </c:forEach>
                                
                                <c:if test="${isLeader}">
                                    <button type="button" class="btn btn-danger btn-sm" onclick="deleteProject('${projectDetail.project.id}', '${projectDetail.project.title}')" title="프로젝트 삭제">
                                        🗑️ 프로젝트 삭제
                                    </button>
                                </c:if>
                            </c:if>
                        </div>
                        <div class="card-body">
                            <div class="mb-2">
                                <small class="text-muted">상태</small>
                                <div class="font-weight-bold">${projectDetail.project.status}</div>
                            </div>
                            <div class="mb-2">
                                <small class="text-muted">시작일</small>
                                <div>${projectDetail.project.startDate}</div>
                            </div>
                            <div class="mb-2">
                                <small class="text-muted">종료일</small>
                                <div>${projectDetail.project.endDate}</div>
                            </div>
                            <div class="mb-2">
                                <small class="text-muted">설명</small>
                                <div style="word-break: break-word;">${projectDetail.project.description}</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 팀원 추가 모달 -->
        <div class="modal fade" id="addMemberModal" tabindex="-1" role="dialog">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">팀원 추가</h5>
                        <button type="button" class="close" data-dismiss="modal">
                            <span>&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="form-group">
                            <label for="userSearch">사용자 검색</label>
                            <input type="text" class="form-control" id="userSearch" placeholder="사용자 이름 또는 ID를 입력하세요">
                            <small class="form-text text-muted">최소 2글자 이상 입력해주세요.</small>
                        </div>
                        <div id="searchResults" class="border rounded mt-2" style="display: none; max-height: 300px; overflow-y: auto;">
                            <!-- 검색 결과가 여기에 표시됩니다 -->
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">취소</button>
                    </div>
                </div>
            </div>
        </div>

        <%@ include file="/WEB-INF/views/layout/footer.jsp" %>
    </div>

    <%@ include file="/WEB-INF/views/layout/scripts.jsp" %>
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
    <script>
        const contextPath = '${pageContext.request.contextPath}';
        
        // 페이지 로드 후 초기화
        $(document).ready(function() {
            console.log('팀원 관리 페이지 로드 완료');
        });
        
        // 사용자 검색
        let searchTimeout;
        $('#userSearch').on('input', function() {
            const query = $(this).val().trim();
            
            clearTimeout(searchTimeout);
            
            if (query.length < 2) {
                $('#searchResults').hide();
                return;
            }
            
            searchTimeout = setTimeout(function() {
                searchUsers(query);
            }, 500);
        });
        
        function searchUsers(query) {
            $.ajax({
                url: contextPath + '/auth/search',
                type: 'GET',
                data: { query: query },
                success: function(users) {
                    displaySearchResults(users);
                },
                error: function() {
                    $('#searchResults').html('<div class="p-3 text-center text-muted">검색 중 오류가 발생했습니다.</div>').show();
                }
            });
        }
        
                 function displaySearchResults(users) {
             const results = $('#searchResults');
             
             if (users.length === 0) {
                 results.html('<div class="p-3 text-center text-muted">검색 결과가 없습니다.</div>').show();
                 return;
             }
             
             let html = '';
             users.forEach(function(user) {
                 // 이미 팀원인지 확인
                 const existingMembers = [
                     <c:forEach items="${projectDetail.members}" var="member" varStatus="status">
                         ${member.userId}<c:if test="${!status.last}">,</c:if>
                     </c:forEach>
                 ];
                 const isAlreadyMember = existingMembers.includes(user.id);
                 
                 if (!isAlreadyMember) {
                     // 역할별 표시 텍스트 설정
                     let roleText = '';
                     switch(user.role) {
                         case 'STUDENT':
                             roleText = '학생';
                             break;
                         case 'PROFESSOR':
                             roleText = '교수';
                             break;
                         case 'STAFF':
                             roleText = '교직원';
                             break;
                         case 'ASSISTANT':
                             roleText = '조교';
                             break;
                         case 'ADMIN':
                             roleText = '관리자';
                             break;
                         default:
                             roleText = user.role || '기타';
                     }
                     
                     html += '<div class="user-search-result d-flex align-items-center" onclick="addMemberToProject(' + 
                         '\'${projectDetail.project.id}\', \'' + user.id + '\', \'' + user.name + '\')">' +
                         '<div class="search-avatar">' + user.name.substring(0, 1) + '</div>' +
                         '<div>' +
                         '<div class="font-weight-bold">' + user.name + '</div>' +
                         '<small class="text-muted">' + roleText + ' | ' + (user.roleId || user.username) + '</small>' +
                         '</div>' +
                         '</div>';
                 }
             });
             
             if (html === '') {
                 results.html('<div class="p-3 text-center text-muted">추가할 수 있는 사용자가 없습니다.</div>').show();
             } else {
                 results.html(html).show();
             }
         }
        
                 // 팀원 추가
         function addMemberToProject(projectId, userId, userName) {
             if (confirm(userName + '님을 팀원으로 추가하시겠습니까?')) {
                $.ajax({
                    url: contextPath + '/projects/' + projectId + '/members/add',
                    type: 'POST',
                    data: {
                        userId: userId,
                        userName: userName
                    },
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            $('#addMemberModal').modal('hide');
                            location.reload();
                        } else {
                            alert('오류: ' + response.message);
                        }
                    },
                    error: function() {
                        alert('팀원 추가 중 오류가 발생했습니다.');
                    }
                });
            }
        }
        
                 // 팀원 역할 변경
         function changeRole(projectId, userId, userName, newRole) {
             const roleText = newRole === 'LEADER' ? '팀장' : '팀원';
             if (confirm(userName + '님을 ' + roleText + '으로 변경하시겠습니까?')) {
                $.ajax({
                    url: contextPath + '/projects/' + projectId + '/members/' + userId + '/role',
                    type: 'POST',
                    data: { newRole: newRole },
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            location.reload();
                        } else {
                            alert('오류: ' + response.message);
                        }
                    },
                    error: function() {
                        alert('역할 변경 중 오류가 발생했습니다.');
                    }
                });
            }
        }

                 // 팀원 삭제
         function removeMember(projectId, userId, userName) {
             if (confirm(userName + '님을 팀에서 제거하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.')) {
                $.ajax({
                    url: contextPath + '/projects/' + projectId + '/members/' + userId + '/remove',
                    type: 'POST',
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            // 해당 멤버 카드를 화면에서 제거
                            $('#member-' + userId).fadeOut(300, function() {
                                $(this).remove();
                                updateMemberCount();
                            });
                        } else {
                            alert('오류: ' + response.message);
                        }
                    },
                    error: function() {
                        alert('팀원 삭제 중 오류가 발생했습니다.');
                    }
                });
            }
        }

                 // 팀원 수 업데이트
         function updateMemberCount() {
             const memberCount = $('.member-card').length;
             $('h4:contains("팀원 목록")').text('팀원 목록 (' + memberCount + '명)');
             
             setTimeout(function() {
                 location.reload();
             }, 1000);
         }

         // 프로젝트 삭제
         function deleteProject(projectId, projectName) {
             if (confirm('정말로 프로젝트 "' + projectName + '"을(를) 삭제하시겠습니까?\n\n⚠️ 이 작업은 되돌릴 수 없으며, 다음 데이터가 모두 삭제됩니다:\n- 모든 팀원 정보\n- 모든 작업(태스크)\n- 모든 보고서\n- 관련 채팅방\n- 프로젝트 기록\n\n삭제하시려면 "확인"을 클릭하세요.')) {
                 $.ajax({
                     url: contextPath + '/projects/' + projectId + '/delete',
                     type: 'POST',
                     success: function(response) {
                         if (response.success) {
                             alert(response.message);
                             // 프로젝트가 삭제되었으므로 프로젝트 목록으로 이동
                             window.location.href = contextPath + '/projects';
                         } else {
                             alert('오류: ' + response.message);
                         }
                     },
                     error: function() {
                         alert('프로젝트 삭제 중 오류가 발생했습니다.');
                     }
                 });
             }
         }
    </script>
</body>
</html> 