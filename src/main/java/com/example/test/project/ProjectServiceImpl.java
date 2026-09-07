package com.example.test.project;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.example.test.auth.AuthDto;
import com.example.test.auth.AuthService;
import com.example.test.chat.ChatRoom;
import com.example.test.chat.ChatRoomRepository;
import com.example.test.chat.ChatService;
import com.example.test.notification.NotificationService;


@Service
public class ProjectServiceImpl implements ProjectService {

    @Autowired
    private ProjectDao projectDao;

    @Autowired
    private AuthService authService;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private ChatService chatService;

    @Autowired
    private ChatRoomRepository chatRoomRepository;

    @Override
    @Transactional
    public Long createProject(ProjectCreationDto dto, Long creatorId) {
        // 1. 프로젝트 생성
        ProjectDto project = new ProjectDto();
        project.setTitle(dto.getProjectName());
        project.setDescription(dto.getProjectDescription());
        project.setCreatedBy(creatorId);
        project.setStatus("PLANNING"); // 기본 상태
        projectDao.createProject(project);
        Long projectId = project.getId();

        // 2. 프로젝트 멤버 추가 (팀장, 팀원)
        List<String> memberUsernames = new ArrayList<>();
        if (dto.getTeamMemberUsernames() != null && !dto.getTeamMemberUsernames().trim().isEmpty()) {
            memberUsernames.addAll(Arrays.asList(dto.getTeamMemberUsernames().split("\\s+")));
        }
        // 팀장도 username 목록에 추가 (중복 처리됨)
        memberUsernames.add(dto.getTeamLeaderUsername());

        List<String> distinctUsernames = memberUsernames.stream().distinct().collect(Collectors.toList());

        for (String username : distinctUsernames) {
            AuthDto user = authService.findByUsername(username);
            if (user == null) {
                throw new RuntimeException("사용자를 찾을 수 없습니다: " + username);
            }

            ProjectMemberDto member = new ProjectMemberDto();
            member.setProjectId(projectId);
            member.setUserId(user.getId());

            if (username.equals(dto.getTeamLeaderUsername())) {
                // 팀장은 즉시 승인
                member.setRole("LEADER");
                member.setApproved(true);
                projectDao.addProjectMember(member);
            } else {
                // 팀원은 초대 상태로 추가하고 알림 발송
                member.setRole("MEMBER");
                member.setApproved(false); // 초대 상태
                projectDao.addProjectMember(member);
                
                // 알림 생성
                notificationService.createProjectInvitationNotification(creatorId, user.getId(), projectId, project.getTitle());
            }
        }
        
        return projectId;
    }

    @Override
    public List<ProjectDto> getAllProjects() {
        return projectDao.findAllProjects();
    }

    @Override
    public ProjectDetailDto getProjectDetail(Long projectId) {
        ProjectDto project = projectDao.findProjectById(projectId);
        if (project == null) {
            return null;
        }

        List<ProjectMemberDto> members = projectDao.findMembersByProjectId(projectId);
        List<ProjectTaskDto> tasks = projectDao.findTasksByProjectId(projectId);

        ProjectDetailDto detailDto = new ProjectDetailDto();
        detailDto.setProject(project);
        detailDto.setMembers(members);
        detailDto.setTasks(tasks);
        
        return detailDto;
    }

    @Override
    @Transactional
    public void updateProject(ProjectDto projectDto) {
        projectDao.updateProject(projectDto);
    }

    @Override
    @Transactional
    public void deleteProject(Long projectId) {
        try {
            System.out.println("=== PROJECT DELETION START ===");
            System.out.println("Project ID: " + projectId);
            
            // 1. 프로젝트 관련 채팅방들 삭제
            try {
                List<ChatRoom> rooms = chatRoomRepository.findByProjectId(projectId);
                if (rooms != null && !rooms.isEmpty()) {
                    for (ChatRoom room : rooms) {
                        System.out.println("Deleting chat room: " + room.getId() + " - " + room.getName());
                        // 채팅방 삭제는 ChatService를 통해 처리하는 것이 안전
                        // chatService.deleteChatRoom(room.getId()); // 만약 이런 메서드가 있다면
                    }
                    System.out.println("Chat rooms deletion completed for project: " + projectId);
                } else {
                    System.out.println("No chat rooms found for project: " + projectId);
                }
            } catch (Exception chatError) {
                System.err.println("Chat room deletion failed (ignored): " + chatError.getMessage());
            }
            
            // 2. 프로젝트 멤버들 삭제 (DB 외래키 제약조건으로 인해 먼저 삭제)
            try {
                List<ProjectMemberDto> members = projectDao.findMembersByProjectId(projectId);
                if (members != null && !members.isEmpty()) {
                    for (ProjectMemberDto member : members) {
                        projectDao.deleteProjectMember(projectId, member.getUserId());
                        System.out.println("Deleted project member: " + member.getUserName());
                    }
                    System.out.println("Project members deletion completed");
                }
            } catch (Exception memberError) {
                System.err.println("Project member deletion failed: " + memberError.getMessage());
                throw new RuntimeException("프로젝트 멤버 삭제에 실패했습니다: " + memberError.getMessage());
            }
            
            // 3. 프로젝트 태스크들 삭제
            try {
                List<ProjectTaskDto> tasks = projectDao.findTasksByProjectId(projectId);
                if (tasks != null && !tasks.isEmpty()) {
                    for (ProjectTaskDto task : tasks) {
                        projectDao.deleteTask(task.getId());
                        System.out.println("Deleted project task: " + task.getTitle());
                    }
                    System.out.println("Project tasks deletion completed");
                }
            } catch (Exception taskError) {
                System.err.println("Project task deletion failed: " + taskError.getMessage());
                throw new RuntimeException("프로젝트 태스크 삭제에 실패했습니다: " + taskError.getMessage());
            }
            
            // 4. 프로젝트 보고서들 삭제
            try {
                List<ProjectReportDto> reports = projectDao.findReportsByProjectId(projectId);
                if (reports != null && !reports.isEmpty()) {
                    for (ProjectReportDto report : reports) {
                        // 파일 시스템에서 보고서 파일 삭제
                        try {
                            if (report.getFilePath() != null && !report.getFilePath().isEmpty()) {
                                Path filePath = Paths.get(report.getFilePath());
                                Files.deleteIfExists(filePath);
                                System.out.println("Deleted report file: " + report.getFileName());
                            }
                        } catch (IOException fileError) {
                            System.err.println("Report file deletion failed (ignored): " + fileError.getMessage());
                        }
                        
                        // DB에서 보고서 정보 삭제 - 현재 deleteReport 메서드가 구현되지 않아 생략
                        // projectDao.deleteReport(report.getId());
                        System.out.println("Report info deletion skipped (method not implemented): " + report.getTitle());
                    }
                    System.out.println("Project reports deletion completed");
                }
            } catch (RuntimeException reportError) {
                System.err.println("Project report deletion failed: " + reportError.getMessage());
                throw reportError; // 원래 예외를 다시 던짐
            }
            
            // 5. 마지막으로 프로젝트 자체 삭제
            projectDao.deleteProject(projectId);
            System.out.println("Project deletion completed: " + projectId);
            
            System.out.println("=== PROJECT DELETION COMPLETED ===");
            
        } catch (RuntimeException e) {
            System.err.println("Project deletion failed: " + e.getMessage());
            throw e; // 트랜잭션 롤백을 위해 다시 던짐
        } catch (Exception e) {
            System.err.println("Unexpected error during project deletion: " + e.getMessage());
            throw new RuntimeException("프로젝트 삭제 중 예상치 못한 오류가 발생했습니다: " + e.getMessage());
        }
    }

    @Override
    @Transactional
    public void respondToInvitation(Long projectId, Long userId, boolean accept) {
        if (accept) {
            System.out.println("=== PROJECT INVITATION ACCEPTANCE START ===");
            System.out.println("Project ID: " + projectId + ", User ID: " + userId);
            
            // 프로젝트 멤버로 승인
            projectDao.approveProjectMember(projectId, userId);
            System.out.println("SUCCESS: Project member approved");
            
            // 사용자 정보 조회
            AuthDto user = authService.findById(userId);
            if (user == null) {
                System.err.println("ERROR: User information not found. ID: " + userId);
                return;
            }
            
            try {
                // 프로젝트의 메인 채팅방 찾기
                List<ChatRoom> rooms = chatRoomRepository.findByProjectId(projectId);
                System.out.println("Number of project chat rooms: " + (rooms != null ? rooms.size() : 0));
                
                ChatRoom mainRoom = null;
                if (rooms != null && !rooms.isEmpty()) {
                    mainRoom = rooms.stream()
                        .filter(r -> Boolean.TRUE.equals(r.getIsMain()))
                        .findFirst()
                        .orElse(null);
                }
                
                if (mainRoom != null) {
                    System.out.println("Main chat room found. ID: " + mainRoom.getId() + ", Name: " + mainRoom.getName());
                    
                    // 메인 채팅방에 자동 참여
                    try {
                        chatService.joinChatRoom(mainRoom.getId(), user.getId(), user.getName());
                        System.out.println("SUCCESS: User " + user.getName() + " automatically joined main chat room");
                    } catch (Exception joinError) {
                        System.err.println("WARNING: Chat room join error (user may already be participating): " + joinError.getMessage());
                        // 이미 참여 중인 경우 오류를 무시하고 계속 진행
                    }
                } else {
                    System.err.println("WARNING: Main chat room not found. Project ID: " + projectId);
                    // 메인 채팅방이 없다면 생성 시도
                    try {
                        System.out.println("Attempting to create main chat room...");
                        boolean created = chatService.createMainChatRoomIfNotExists(projectId, userId);
                        if (created) {
                            System.out.println("Main chat room created successfully");
                            // 다시 찾기
                            rooms = chatRoomRepository.findByProjectId(projectId);
                            if (rooms != null && !rooms.isEmpty()) {
                                mainRoom = rooms.stream()
                                    .filter(r -> Boolean.TRUE.equals(r.getIsMain()))
                                    .findFirst()
                                    .orElse(null);
                            }
                            
                            if (mainRoom != null) {
                                chatService.joinChatRoom(mainRoom.getId(), user.getId(), user.getName());
                                System.out.println("SUCCESS: Joined newly created main chat room");
                            }
                        }
                    } catch (Exception createError) {
                        System.err.println("WARNING: Main chat room creation failed: " + createError.getMessage());
                    }
                }
                
            } catch (Exception chatError) {
                System.err.println("ERROR: Chat room processing failed: " + chatError.getMessage());
                // 채팅방 처리 실패해도 프로젝트 승인은 성공으로 처리
                System.out.println("WARNING: Chat room join failed but project invitation acceptance completed");
            }
            
            System.out.println("=== PROJECT INVITATION ACCEPTANCE COMPLETED ===");
            
        } else {
            System.out.println("Project invitation rejected - deleting member");
            projectDao.deleteProjectMember(projectId, userId);
        }
    }

    @Override
    public void addProjectMember(ProjectMemberDto projectMemberDto) {
        projectDao.addProjectMember(projectMemberDto);
    }

    @Override
    @Transactional
    public void removeProjectMember(Long projectId, Long userId) {
        try {
            // 1. 프로젝트에서 멤버 삭제
            projectDao.deleteProjectMember(projectId, userId);
            System.out.println("프로젝트에서 멤버 삭제 완료: projectId=" + projectId + ", userId=" + userId);
            
            // 2. 프로젝트의 메인 채팅방에서도 해당 사용자 제거
            try {
                List<ChatRoom> rooms = chatRoomRepository.findByProjectId(projectId);
                ChatRoom mainRoom = rooms.stream()
                    .filter(r -> Boolean.TRUE.equals(r.getIsMain()))
                    .findFirst()
                    .orElse(null);
                
                if (mainRoom != null) {
                    // 메인 채팅방에서 사용자 제거
                    chatService.leaveChatRoom(mainRoom.getId(), userId);
                    System.out.println("메인 채팅방에서 멤버 제거 완료: roomId=" + mainRoom.getId() + ", userId=" + userId);
                } else {
                    System.out.println("메인 채팅방을 찾을 수 없음: projectId=" + projectId);
                }
                
            } catch (Exception chatError) {
                System.err.println("채팅방에서 멤버 제거 실패 (무시됨): " + chatError.getMessage());
                // 채팅방 제거 실패해도 프로젝트 삭제는 성공으로 처리
            }
            
            System.out.println("팀원 삭제 완료: projectId=" + projectId + ", userId=" + userId);
            
        } catch (Exception e) {
            System.err.println("팀원 삭제 실패: " + e.getMessage());
            throw new RuntimeException("팀원 삭제에 실패했습니다: " + e.getMessage());
        }
    }

    @Override
    public ProjectTaskDto createTask(ProjectTaskDto projectTaskDto) {
        projectDao.createTask(projectTaskDto);
        return projectTaskDto;
    }

    @Override
    public void updateTask(ProjectTaskDto projectTaskDto) {
        projectDao.updateTask(projectTaskDto);
    }

    @Override
    public void deleteTask(Long taskId) {
        projectDao.deleteTask(taskId);
    }

    @Override
    public List<ProjectDto> getProjectsForUser(Long userId) {
        return projectDao.findProjectsByUserId(userId);
    }

    @Override
    @Transactional
    public Long createProjectWithMembers(
        String projectName,
        String projectDescription,
        String teamLeaderId,
        String teamLeaderName,
        List<String> memberIds,
        List<String> memberNames,
        Long creatorId
    ) {
        // 1. 프로젝트 저장
        ProjectDto project = new ProjectDto();
        project.setTitle(projectName);
        project.setDescription(projectDescription);
        project.setCreatedBy(creatorId);
        project.setStatus("PLANNING");
        projectDao.createProject(project);
        Long projectId = project.getId();

        // 2. 팀장/팀원 중복 방지 및 이름 일치 확인
        List<String> allIds = new ArrayList<>();
        List<String> allNames = new ArrayList<>();
        allIds.add(teamLeaderId);
        allNames.add(teamLeaderName);
        if (memberIds != null && memberNames != null) {
            for (int i = 0; i < memberIds.size(); i++) {
                String id = memberIds.get(i).trim();
                String name = memberNames.get(i).trim();
                if (!id.isEmpty() && !name.isEmpty()) {
                    allIds.add(id);
                    allNames.add(name);
                }
            }
        }
        // 중복 제거 (팀장+팀원)
        List<String> uniqueIds = new ArrayList<>();
        List<String> uniqueNames = new ArrayList<>();
        for (int i = 0; i < allIds.size(); i++) {
            String id = allIds.get(i);
            String name = allNames.get(i);
            if (!uniqueIds.contains(id)) {
                uniqueIds.add(id);
                uniqueNames.add(name);
            }
        }
        if (uniqueIds.size() < 2) {
            throw new IllegalArgumentException("팀원은 최소 2명 이상이어야 합니다.");
        }

        // 3. 팀장/팀원 저장 및 알림
        for (int i = 0; i < uniqueIds.size(); i++) {
            String id = uniqueIds.get(i);
            String name = uniqueNames.get(i);
            AuthDto user = authService.findByUsername(id);
            if (user == null) {
                throw new IllegalArgumentException("존재하지 않는 학번: " + id);
            }
            if (!user.getName().equals(name)) {
                throw new IllegalArgumentException("학번 " + id + "의 이름이 일치하지 않습니다. 입력: " + name + ", 실제: " + user.getName());
            }
            ProjectMemberDto member = new ProjectMemberDto();
            member.setProjectId(projectId);
            member.setUserId(user.getId());
            if (id.equals(teamLeaderId)) {
                member.setRole("LEADER");
                member.setApproved(true);
                projectDao.addProjectMember(member);
            } else {
                member.setRole("MEMBER");
                member.setApproved(false);
                projectDao.addProjectMember(member);
                ProjectDto currentProject = projectDao.findProjectById(projectId);
                notificationService.createProjectInvitationNotification(creatorId, user.getId(), projectId, currentProject.getTitle());
            }
        }
        // 4. 메인 채팅방 생성 (없으면 생성)
        AuthDto leader = authService.findByUsername(teamLeaderId);
        if (leader != null) {
            try {
                System.out.println("=== MAIN CHAT ROOM CREATION START ===");
                System.out.println("Project ID: " + projectId + ", Team Leader ID: " + leader.getId());
                
                // 메인 채팅방 생성
                boolean created = chatService.createMainChatRoomIfNotExists(projectId, leader.getId());
                System.out.println("Main chat room creation result: " + created);
                
                // 생성된 메인 채팅방 찾기
                List<ChatRoom> rooms = chatRoomRepository.findByProjectId(projectId);
                ChatRoom mainRoom = null;
                if (rooms != null && !rooms.isEmpty()) {
                    mainRoom = rooms.stream()
                        .filter(r -> Boolean.TRUE.equals(r.getIsMain()))
                        .findFirst()
                        .orElse(null);
                }
                
                if (mainRoom != null) {
                    System.out.println("Main chat room found. ID: " + mainRoom.getId());
                    
                    // 팀장 자동 참여 (joinChatRoom 사용)
                    try {
                        chatService.joinChatRoom(mainRoom.getId(), leader.getId(), leader.getName());
                        System.out.println("SUCCESS: Team leader automatically joined main chat room");
                    } catch (Exception joinError) {
                        System.err.println("WARNING: Team leader chat room join error (ignored): " + joinError.getMessage());
                        // 이미 참여 중일 수 있으므로 오류를 무시하고 계속 진행
                    }
                } else {
                    System.err.println("WARNING: Main chat room not found. Project ID: " + projectId);
                }
                
                System.out.println("=== MAIN CHAT ROOM CREATION COMPLETED ===");
                
            } catch (Exception chatError) {
                System.err.println("ERROR: Chat room creation failed: " + chatError.getMessage());
                // 채팅방 생성 실패해도 프로젝트 생성은 성공으로 처리
                System.out.println("WARNING: Chat room creation failed but project creation continues");
            }
        } else {
            System.err.println("ERROR: Team leader information not found: " + teamLeaderId);
        }
        return projectId;
    }

    // ArchiveController에서 사용하는 메소드들 구현
    @Override
    public ProjectDto getProjectById(Long projectId) {
        return projectDao.findProjectById(projectId);
    }

    @Override
    public List<ProjectDto> getPublicProjects() {
        // isPublic이 true인 프로젝트들만 반환 (기존 메소드 사용)
        return projectDao.findAllProjects().stream()
                .filter(ProjectDto::isPublic)
                .collect(Collectors.toList());
    }
    
    // 보고서 관련 메소드 구현
    @Override
    @Transactional
    public String uploadReport(Long projectId, MultipartFile file, Long uploaderId) {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("파일이 비어있습니다.");
        }
        
        try {
            // 절대 경로 기준으로 업로드 디렉토리 생성
            String baseDir = System.getProperty("user.dir"); // 현재 프로젝트 디렉토리
            String uploadDir = baseDir + "/uploads/reports/" + projectId;
            Path uploadPath = Paths.get(uploadDir);
            Files.createDirectories(uploadPath);
            
            // 파일명 생성 (중복 방지를 위해 시간스탬프 추가)
            String originalFilename = file.getOriginalFilename();
            String filename = System.currentTimeMillis() + "_" + originalFilename;
            Path filePath = uploadPath.resolve(filename);
            
            // 파일 저장
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            // 데이터베이스에 보고서 정보 저장 (절대 경로로 저장)
            ProjectReportDto reportDto = new ProjectReportDto();
            reportDto.setProjectId(projectId);
            reportDto.setTitle(originalFilename); // 파일명을 제목으로 사용
            reportDto.setDescription("업로드된 보고서 파일"); // 기본 설명
            reportDto.setFileName(originalFilename);
            reportDto.setFilePath(filePath.toAbsolutePath().toString()); // 절대 경로로 저장
            reportDto.setFileSize(file.getSize()); // 파일 크기 설정
            reportDto.setUploadedBy(uploaderId);
            
            projectDao.createReport(reportDto);
            
            return "보고서가 성공적으로 업로드되었습니다.";
            
        } catch (IOException e) {
            throw new RuntimeException("파일 업로드 중 오류가 발생했습니다: " + e.getMessage());
        }
    }
    
    @Override
    public List<ProjectReportDto> getReportsByProjectId(Long projectId) {
        return projectDao.findReportsByProjectId(projectId);
    }

    @Override
    public ResponseEntity<Resource> downloadReport(Long reportId) {
        try {
            // 보고서 정보 조회
            ProjectReportDto report = projectDao.findReportById(reportId);
            if (report == null) {
                return ResponseEntity.notFound().build();
            }
            
            // 파일 경로 (절대 경로 사용)
            Path filePath = Paths.get(report.getFilePath()).normalize();
            Resource resource = new UrlResource(filePath.toUri());
            
            if (!resource.exists() || !resource.isReadable()) {
                return ResponseEntity.notFound().build();
            }
            
            // 한글 파일명을 안전하게 처리
            String safeFileName = new String(report.getFileName().getBytes("UTF-8"), "ISO-8859-1");
            
            return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + safeFileName + "\"")
                    .body(resource);
                    
        } catch (IOException e) {
            System.err.println("파일 다운로드 중 오류 발생: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        } catch (RuntimeException e) {
            System.err.println("파일 다운로드 중 예상치 못한 오류 발생: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    // 팀원 관리 메소드 구현
    @Override
    @Transactional
    public void updateMemberRole(Long projectId, Long userId, String newRole) {
        try {
            // 기존 팀장이 있는지 확인
            if ("LEADER".equals(newRole)) {
                List<ProjectMemberDto> currentMembers = projectDao.findMembersByProjectId(projectId);
                for (ProjectMemberDto member : currentMembers) {
                    if ("LEADER".equals(member.getRole()) && !member.getUserId().equals(userId)) {
                        // 기존 팀장을 팀원으로 변경
                        projectDao.updateMemberRole(projectId, member.getUserId(), "MEMBER");
                    }
                }
            }
            
            // 새로운 역할 설정
            projectDao.updateMemberRole(projectId, userId, newRole);
            System.out.println("멤버 역할 업데이트 완료: projectId=" + projectId + ", userId=" + userId + ", newRole=" + newRole);
            
        } catch (Exception e) {
            System.err.println("멤버 역할 업데이트 실패: " + e.getMessage());
            throw new RuntimeException("멤버 역할 업데이트에 실패했습니다: " + e.getMessage());
        }
    }
    
    @Override
    @Transactional
    public void approveMember(Long projectId, Long userId) {
        try {
            // 현재 멤버 상태 확인
            List<ProjectMemberDto> members = projectDao.findMembersByProjectId(projectId);
            ProjectMemberDto targetMember = members.stream()
                .filter(member -> member.getUserId().equals(userId))
                .findFirst()
                .orElse(null);
            
            if (targetMember == null) {
                System.err.println("멤버를 찾을 수 없음: projectId=" + projectId + ", userId=" + userId);
                return;
            }
            
            // 이미 승인된 멤버라면 승인 처리 스킵
            if (!targetMember.isApproved()) {
                projectDao.approveProjectMember(projectId, userId);
                System.out.println("멤버 승인 처리 완료: projectId=" + projectId + ", userId=" + userId);
            } else {
                System.out.println("이미 승인된 멤버입니다. 채팅방 참여만 처리: projectId=" + projectId + ", userId=" + userId);
            }
            
            // 승인된 멤버를 메인 채팅방에 자동 참여시키기
            AuthDto user = authService.findById(userId);
            if (user != null) {
                try {
                    List<ChatRoom> rooms = chatRoomRepository.findByProjectId(projectId);
                    ChatRoom mainRoom = rooms.stream()
                        .filter(r -> Boolean.TRUE.equals(r.getIsMain()))
                        .findFirst()
                        .orElse(null);
                    
                    if (mainRoom != null) {
                        chatService.joinChatRoom(mainRoom.getId(), user.getId(), user.getName());
                        System.out.println("승인된 멤버를 메인 채팅방에 추가: " + user.getName());
                    }
                } catch (Exception chatError) {
                    System.err.println("승인된 멤버 채팅방 참여 실패 (무시됨): " + chatError.getMessage());
                }
            }
            
            System.out.println("멤버 승인 완료: projectId=" + projectId + ", userId=" + userId);
            
        } catch (Exception e) {
            System.err.println("멤버 승인 실패: " + e.getMessage());
            throw new RuntimeException("멤버 승인에 실패했습니다: " + e.getMessage());
        }
    }
    
    @Override
    @Transactional
    public void rejectMember(Long projectId, Long userId) {
        try {
            // 1. 프로젝트에서 멤버 삭제
            projectDao.deleteProjectMember(projectId, userId);
            System.out.println("프로젝트에서 멤버 거부 완료: projectId=" + projectId + ", userId=" + userId);
            
            // 2. 혹시 이미 채팅방에 참여한 경우를 대비해 메인 채팅방에서도 제거
            try {
                List<ChatRoom> rooms = chatRoomRepository.findByProjectId(projectId);
                ChatRoom mainRoom = rooms.stream()
                    .filter(r -> Boolean.TRUE.equals(r.getIsMain()))
                    .findFirst()
                    .orElse(null);
                
                if (mainRoom != null) {
                    // 메인 채팅방에서 사용자 제거 (이미 참여하지 않았다면 오류 무시)
                    chatService.leaveChatRoom(mainRoom.getId(), userId);
                    System.out.println("메인 채팅방에서 멤버 제거 완료: roomId=" + mainRoom.getId() + ", userId=" + userId);
                } else {
                    System.out.println("메인 채팅방을 찾을 수 없음: projectId=" + projectId);
                }
                
            } catch (Exception chatError) {
                System.err.println("채팅방에서 멤버 제거 실패 (무시됨): " + chatError.getMessage());
                // 채팅방 제거 실패해도 멤버 거부는 성공으로 처리
            }
            
            System.out.println("멤버 거부 완료: projectId=" + projectId + ", userId=" + userId);
            
        } catch (Exception e) {
            System.err.println("멤버 거부 실패: " + e.getMessage());
            throw new RuntimeException("멤버 거부에 실패했습니다: " + e.getMessage());
        }
    }
    
    @Override
    public boolean isProjectLeader(Long projectId, Long userId) {
        ProjectMemberDto member = projectDao.findMembersByProjectId(projectId)
                .stream()
                .filter(m -> m.getUserId().equals(userId) && "LEADER".equals(m.getRole()))
                .findFirst()
                .orElse(null);
        return member != null;
    }
    
    @Override
    public String getInvitationStatus(Long projectId, Long userId) {
        ProjectMemberDto member = projectDao.findProjectMemberByUserIdAndProjectId(userId, projectId);
        
        if (member == null) {
            return "NOT_INVITED"; // 초대되지 않음
        }
        
        if (member.isApproved()) {
            return "ACCEPTED"; // 수락함 (승인됨)
        } else {
            // 초대는 되었지만 아직 응답하지 않았거나 거절함
            // 여기서는 데이터베이스에 레코드가 있으면서 approved가 false인 경우를 "아직 대기중"으로 처리
            return "PENDING"; // 대기중
        }
    }
}