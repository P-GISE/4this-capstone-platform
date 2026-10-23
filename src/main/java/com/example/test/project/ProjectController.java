package com.example.test.project;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.example.test.auth.AuthDto;
import com.example.test.equipment.EquipmentService;
import com.example.test.equipmentrental.EquipmentRentalService;
import com.example.test.notification.NotificationService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

@Controller
@RequestMapping("/projects")
public class ProjectController {
    private void requireProjectMember(Long projectId, HttpSession session) {
        AuthDto actor = (AuthDto) session.getAttribute("loginUser");
        boolean allowed = actor != null && ("ADMIN".equals(actor.getRole())
                || projectService.getProjectsForUser(actor.getId()).stream()
                    .anyMatch(project -> java.util.Objects.equals(projectId, project.getId())));
        if (!allowed) throw new com.example.test.config.AccessDeniedException();
    }

    private void requireProjectTask(Long projectId, Long taskId, HttpSession session) {
        requireProjectMember(projectId, session);
        ProjectDetailDto detail = projectService.getProjectDetail(projectId);
        if (detail == null || detail.getTasks() == null || detail.getTasks().stream()
                .noneMatch(task -> java.util.Objects.equals(taskId, task.getId()))) {
            throw new com.example.test.config.AccessDeniedException();
        }
    }


    private final ProjectService projectService;
    private final ObjectMapper objectMapper;
    private final NotificationService notificationService;
    @SuppressWarnings("unused")
    private final EquipmentRentalService equipmentRentalService;
    @SuppressWarnings("unused")
    private final EquipmentService equipmentService;
    private final ProjectEquipmentService projectEquipmentService;

    @Autowired
    public ProjectController(ProjectService projectService, ObjectMapper objectMapper, 
                           NotificationService notificationService, EquipmentRentalService equipmentRentalService,
                           EquipmentService equipmentService, ProjectEquipmentService projectEquipmentService) {
        this.projectService = projectService;
        this.objectMapper = objectMapper.copy();
        this.objectMapper.registerModule(new JavaTimeModule());
        this.objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        this.notificationService = notificationService;
        this.equipmentRentalService = equipmentRentalService;
        this.equipmentService = equipmentService;
        this.projectEquipmentService = projectEquipmentService;
    }

    @GetMapping
    public String showProjects(HttpSession session, Model model) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }

        List<ProjectDto> projects = projectService.getProjectsForUser(loginUser.getId());

        if (projects.isEmpty()) {
            return "redirect:/projects/create";
        } else {
            model.addAttribute("projects", projects);
            return "project/list";
        }
    }

    @GetMapping("/{projectId}")
    public String projectDetail(@PathVariable("projectId") Long projectId, Model model, HttpSession session) {
        requireProjectMember(projectId, session);
        ProjectDetailDto projectDetail = projectService.getProjectDetail(projectId);
        if (projectDetail == null) {
            return "redirect:/projects";
        }
        model.addAttribute("projectDetail", projectDetail);
        
        // 보고서 목록도 함께 조회
        List<ProjectReportDto> reports = projectService.getReportsByProjectId(projectId);
        model.addAttribute("reports", reports);
        
        // 프로젝트에 등록된 기자재 목록 조회 (새로운 시스템)
        List<ProjectEquipmentDto> projectEquipments = projectEquipmentService.getProjectEquipments(projectId);
        model.addAttribute("projectEquipments", projectEquipments);
        
        // 프로젝트 멤버들이 대여중이면서 프로젝트에 등록 가능한 기자재 목록
        List<Long> memberIds = projectDetail.getMembers().stream()
                .map(ProjectMemberDto::getUserId)
                .collect(java.util.stream.Collectors.toList());
        List<ProjectEquipmentDto> availableEquipments = projectEquipmentService.getAvailableEquipmentsForProjectMembers(projectId, memberIds);
        model.addAttribute("availableEquipments", availableEquipments);
        
        try {
            String tasksJson = objectMapper.writeValueAsString(projectDetail.getTasks());
            model.addAttribute("tasksJson", tasksJson);
        } catch (com.fasterxml.jackson.core.JsonProcessingException e) {
            model.addAttribute("tasksJson", "[]");
        }

        return "project/schedule"; // 간트 차트 및 태스크 보드 페이지
    }

    @GetMapping("/create")
    public String createForm(Model model) {
        return "project/create";
    }

    @PostMapping("/create")
    public String createProject(
        @RequestParam String projectName,
        @RequestParam(required = false) String projectDescription,
        @RequestParam String teamLeaderId,
        @RequestParam String teamLeaderName,
        @RequestParam("memberIds") List<String> memberIds,
        @RequestParam("memberNames") List<String> memberNames,
        HttpSession session,
        Model model
    ) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        try {
            projectService.createProjectWithMembers(
                projectName, projectDescription,
                teamLeaderId, teamLeaderName,
                memberIds, memberNames,
                loginUser.getId()
            );
            model.addAttribute("successMessage", "프로젝트가 성공적으로 생성되었습니다!");
            return "project/create";
        } catch (IllegalArgumentException e) {
            model.addAttribute("errorMessage", e.getMessage());
            return "project/create";
        }
    }

    @PostMapping("/{projectId}/tasks")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createTask(@PathVariable("projectId") Long projectId, @RequestBody ProjectTaskDto taskDto, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            requireProjectMember(projectId, session);
            taskDto.setProjectId(projectId);
            taskDto.setCreatedBy(loginUser.getId());
            ProjectTaskDto createdTask = projectService.createTask(taskDto);
            
            response.put("success", true);
            response.put("message", "태스크가 성공적으로 추가되었습니다.");
            response.put("task", createdTask);
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "태스크 추가 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PostMapping("/tasks/update")
    public String updateTask(@ModelAttribute ProjectTaskDto taskDto, HttpSession session) {
        requireProjectTask(taskDto.getProjectId(), taskDto.getId(), session);
        projectService.updateTask(taskDto);
        return "redirect:/projects/" + taskDto.getProjectId();
    }
    
    @PutMapping("/{projectId}/tasks/{taskId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateTaskAjax(
            @PathVariable("projectId") Long projectId,
            @PathVariable("taskId") Long taskId,
            @RequestBody ProjectTaskDto taskDto,
            HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            // 태스크 ID와 프로젝트 ID 설정
            requireProjectTask(projectId, taskId, session);
            taskDto.setId(taskId);
            taskDto.setProjectId(projectId);
            
            projectService.updateTask(taskDto);
            
            response.put("success", true);
            response.put("message", "작업이 성공적으로 수정되었습니다.");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "작업 수정 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PostMapping("/tasks/delete/{taskId}")
    public String deleteTask(@PathVariable("taskId") Long taskId, @RequestParam Long projectId, HttpSession session) {
        requireProjectTask(projectId, taskId, session);
        projectService.deleteTask(taskId);
        return "redirect:/projects/" + projectId;
    }

    /**
     * 프로젝트 초대 페이지
     */
    @GetMapping("/invitation/{projectId}")
    public String showInvitation(@PathVariable("projectId") Long projectId, HttpSession session, Model model) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }

        ProjectDto project = projectService.getProjectById(projectId);
        if (project == null) {
            return "redirect:/projects";
        }

        // 사용자의 초대 응답 상태 확인
        String invitationStatus = projectService.getInvitationStatus(projectId, loginUser.getId());
        
        model.addAttribute("project", project);
        model.addAttribute("invitationStatus", invitationStatus);
        
        if ("ACCEPTED".equals(invitationStatus)) {
            // 이미 수락한 경우
            return "project/invitation-completed";
        } else if ("NOT_INVITED".equals(invitationStatus)) {
            // 초대되지 않은 경우
            return "redirect:/dashboard";
        } else {
            // 아직 응답하지 않은 경우 (PENDING)
            return "project/invitation";
        }
    }

    /**
     * 프로젝트 초대 승인/거절
     */
    @PostMapping("/invitation/{projectId}/respond")
    public String respondToInvitation(@PathVariable("projectId") Long projectId, 
                                    @RequestParam boolean accept,
                                    HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }

        projectService.respondToInvitation(projectId, loginUser.getId(), accept);
        
        if (accept) {
            return "redirect:/projects";
        } else {
            return "redirect:/dashboard";
        }
    }

    /**
     * 프로젝트 멤버 관리 페이지
     */
    @GetMapping("/{projectId}/members")
    public String projectMembers(@PathVariable("projectId") Long projectId, Model model, HttpSession session) {
        requireProjectMember(projectId, session);
        ProjectDetailDto projectDetail = projectService.getProjectDetail(projectId);
        if (projectDetail == null) {
            return "redirect:/projects";
        }
        model.addAttribute("projectDetail", projectDetail);
        return "project/members";
    }

    /**
     * 프로젝트 보고서 페이지
     */
    @GetMapping("/{projectId}/reports")
    public String projectReports(@PathVariable("projectId") Long projectId, Model model, HttpSession session) {
        requireProjectMember(projectId, session);
        ProjectDetailDto projectDetail = projectService.getProjectDetail(projectId);
        if (projectDetail == null) {
            return "redirect:/projects";
        }
        
        // 보고서 목록 조회
        List<ProjectReportDto> reports = projectService.getReportsByProjectId(projectId);
        
        model.addAttribute("projectDetail", projectDetail);
        model.addAttribute("reports", reports);
        return "project/reports";
    }

    /**
     * 보고서 업로드
     */
    @PostMapping("/{projectId}/reports/upload")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> uploadReport(
            @PathVariable("projectId") Long projectId,
            @RequestParam("file") MultipartFile file,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            requireProjectMember(projectId, session);
            String message = projectService.uploadReport(projectId, file, loginUser.getId());
            
            response.put("success", true);
            response.put("message", message);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "업로드 실패: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 보고서 다운로드
     */
    @GetMapping("/{projectId}/reports/download/{reportId}")
    public ResponseEntity<Resource> downloadReport(
            @PathVariable("projectId") Long projectId,
            @PathVariable("reportId") Long reportId,
            HttpSession session) {
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
            }
            
            requireProjectMember(projectId, session);
            if (projectService.getReportsByProjectId(projectId).stream()
                    .noneMatch(report -> java.util.Objects.equals(reportId, report.getId()))) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
            return projectService.downloadReport(reportId);
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * 태스크 추가 팝업 페이지
     */
    @GetMapping("/{projectId}/tasks/popup")
    public String taskAddPopup(@PathVariable("projectId") Long projectId, Model model, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        ProjectDetailDto projectDetail = projectService.getProjectDetail(projectId);
        if (projectDetail == null) {
            return "redirect:/projects";
        }
        
        model.addAttribute("projectDetail", projectDetail);
        return "project/task-popup";
    }

    /**
     * 팀원 삭제
     */
    @PostMapping("/{projectId}/members/{userId}/remove")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> removeMember(
            @PathVariable("projectId") Long projectId,
            @PathVariable("userId") Long userId,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            // 팀장 권한 확인
            if (!projectService.isProjectLeader(projectId, loginUser.getId())) {
                response.put("success", false);
                response.put("message", "팀장만 팀원을 삭제할 수 있습니다.");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            // 자기 자신은 삭제할 수 없음
            if (loginUser.getId().equals(userId)) {
                response.put("success", false);
                response.put("message", "팀장은 자기 자신을 삭제할 수 없습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            projectService.removeProjectMember(projectId, userId);
            
            response.put("success", true);
            response.put("message", "팀원이 성공적으로 삭제되었습니다.");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "팀원 삭제 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 팀원 역할 변경
     */
    @PostMapping("/{projectId}/members/{userId}/role")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateMemberRole(
            @PathVariable("projectId") Long projectId,
            @PathVariable("userId") Long userId,
            @RequestParam("newRole") String newRole,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            // 팀장 권한 확인
            if (!projectService.isProjectLeader(projectId, loginUser.getId())) {
                response.put("success", false);
                response.put("message", "팀장만 팀원 역할을 변경할 수 있습니다.");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            // 역할 유효성 검사
            if (!"LEADER".equals(newRole) && !"MEMBER".equals(newRole)) {
                response.put("success", false);
                response.put("message", "유효하지 않은 역할입니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            projectService.updateMemberRole(projectId, userId, newRole);
            
            String roleText = "LEADER".equals(newRole) ? "팀장" : "팀원";
            response.put("success", true);
            response.put("message", "역할이 " + roleText + "으로 변경되었습니다.");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "역할 변경 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 팀원 승인
     */
    @PostMapping("/{projectId}/members/{userId}/approve")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> approveMember(
            @PathVariable("projectId") Long projectId,
            @PathVariable("userId") Long userId,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            // 팀장 권한 확인
            if (!projectService.isProjectLeader(projectId, loginUser.getId())) {
                response.put("success", false);
                response.put("message", "팀장만 팀원을 승인할 수 있습니다.");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            projectService.approveMember(projectId, userId);
            
            response.put("success", true);
            response.put("message", "팀원이 승인되었습니다.");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "팀원 승인 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 팀원 거부
     */
    @PostMapping("/{projectId}/members/{userId}/reject")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> rejectMember(
            @PathVariable("projectId") Long projectId,
            @PathVariable("userId") Long userId,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            // 팀장 권한 확인
            if (!projectService.isProjectLeader(projectId, loginUser.getId())) {
                response.put("success", false);
                response.put("message", "팀장만 팀원을 거부할 수 있습니다.");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            projectService.rejectMember(projectId, userId);
            
            response.put("success", true);
            response.put("message", "팀원 초대가 거부되었습니다.");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "팀원 거부 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 프로젝트 삭제
     */
    @PostMapping("/{projectId}/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteProject(
            @PathVariable("projectId") Long projectId,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            // 팀장 권한 확인
            if (!projectService.isProjectLeader(projectId, loginUser.getId())) {
                response.put("success", false);
                response.put("message", "팀장만 프로젝트를 삭제할 수 있습니다.");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            // 프로젝트 정보 조회 (삭제 전 로깅용)
            ProjectDto project = projectService.getProjectById(projectId);
            String projectName = project != null ? project.getTitle() : "Unknown";
            
            // 프로젝트 삭제 (모든 관련 데이터 포함)
            projectService.deleteProject(projectId);
            
            response.put("success", true);
            response.put("message", "프로젝트 '" + projectName + "'이(가) 성공적으로 삭제되었습니다.");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "프로젝트 삭제 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 팀원 추가
     */
    @PostMapping("/{projectId}/members/add")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addMember(
            @PathVariable("projectId") Long projectId,
            @RequestParam("userId") Long userId,
            @RequestParam("userName") String userName,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            // 팀장 권한 확인
            if (!projectService.isProjectLeader(projectId, loginUser.getId())) {
                response.put("success", false);
                response.put("message", "팀장만 팀원을 추가할 수 있습니다.");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            // 이미 팀원인지 확인
            ProjectDetailDto projectDetail = projectService.getProjectDetail(projectId);
            boolean isAlreadyMember = projectDetail.getMembers().stream()
                    .anyMatch(member -> member.getUserId().equals(userId));
            
            if (isAlreadyMember) {
                response.put("success", false);
                response.put("message", "이미 프로젝트 팀원입니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // ProjectMemberDto 생성 (초대 상태로 추가)
            ProjectMemberDto memberDto = new ProjectMemberDto();
            memberDto.setProjectId(projectId);
            memberDto.setUserId(userId);
            memberDto.setUserName(userName);
            memberDto.setRole("MEMBER");
            memberDto.setApproved(false); // 초대 상태 - 팀원이 승인해야 함
            
            // 팀원 초대
            projectService.addProjectMember(memberDto);
            
            // 초대 알림 생성
            try {
                ProjectDto project = projectService.getProjectById(projectId);
                if (project != null) {
                    // 알림 서비스를 통해 초대 알림 생성
                    notificationService.createProjectInvitationNotification(
                        loginUser.getId(),  // 초대한 사람 (팀장)
                        userId,            // 초대받은 사람
                        projectId,         // 프로젝트 ID
                        project.getTitle() // 프로젝트 제목
                    );
                    System.out.println("프로젝트 초대 알림 생성 완료: " + userName + " -> " + project.getTitle());
                }
            } catch (Exception e) {
                System.err.println("초대 알림 생성 실패: " + e.getMessage());
            }
            
            response.put("success", true);
            response.put("message", userName + "님에게 프로젝트 초대를 보냈습니다. 승인을 기다려주세요.");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "팀원 추가 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // ========================================
    // 프로젝트 기자재 관리 API
    // ========================================

    /**
     * 프로젝트에 기자재 추가
     */
    @PostMapping("/{projectId}/equipment/add")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addEquipmentToProject(
            @PathVariable("projectId") Long projectId,
            @RequestBody ProjectEquipmentAddRequestDto request,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            // 프로젝트 멤버인지 확인
            ProjectDetailDto projectDetail = projectService.getProjectDetail(projectId);
            boolean isMember = projectDetail.getMembers().stream()
                    .anyMatch(member -> member.getUserId().equals(loginUser.getId()) && member.isApproved());
            
            if (!isMember) {
                response.put("success", false);
                response.put("message", "프로젝트 멤버만 기자재를 추가할 수 있습니다.");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            // ProjectEquipmentDto 생성
            ProjectEquipmentDto projectEquipment = new ProjectEquipmentDto();
            projectEquipment.setProjectId(projectId);
            projectEquipment.setEquipmentId(request.getEquipmentId());
            projectEquipment.setRentalId(request.getRentalId());
            projectEquipment.setAddedBy(loginUser.getId());
            projectEquipment.setPurpose(request.getPurpose());
            
            projectEquipmentService.addEquipmentToProject(projectEquipment);
            
            response.put("success", true);
            response.put("message", "기자재가 프로젝트에 추가되었습니다.");
            return ResponseEntity.ok(response);
            
        } catch (IllegalArgumentException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "기자재 추가 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 프로젝트에서 기자재 제거
     */
    @PostMapping("/{projectId}/equipment/{projectEquipmentId}/remove")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> removeEquipmentFromProject(
            @PathVariable("projectId") Long projectId,
            @PathVariable("projectEquipmentId") Long projectEquipmentId,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            // 프로젝트 멤버인지 확인
            ProjectDetailDto projectDetail = projectService.getProjectDetail(projectId);
            boolean isMember = projectDetail.getMembers().stream()
                    .anyMatch(member -> member.getUserId().equals(loginUser.getId()) && member.isApproved());
            
            if (!isMember) {
                response.put("success", false);
                response.put("message", "프로젝트 멤버만 기자재를 제거할 수 있습니다.");
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body(response);
            }
            
            projectEquipmentService.removeEquipmentFromProject(projectEquipmentId);
            
            response.put("success", true);
            response.put("message", "기자재가 프로젝트에서 제거되었습니다.");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "기자재 제거 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 프로젝트에 추가 가능한 기자재 목록 조회 (AJAX)
     */
    @GetMapping("/{projectId}/equipment/available")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getAvailableEquipments(
            @PathVariable("projectId") Long projectId,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            // 프로젝트 멤버들의 대여중인 기자재 중 프로젝트에 등록되지 않은 것들
            ProjectDetailDto projectDetail = projectService.getProjectDetail(projectId);
            List<Long> memberIds = projectDetail.getMembers().stream()
                    .filter(ProjectMemberDto::isApproved)
                    .map(ProjectMemberDto::getUserId)
                    .collect(java.util.stream.Collectors.toList());
            
            List<ProjectEquipmentDto> availableEquipments = projectEquipmentService.getAvailableEquipmentsForProjectMembers(projectId, memberIds);
            
            response.put("success", true);
            response.put("equipments", availableEquipments);
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "기자재 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
    
    /**
     * 프로젝트에 등록된 기자재 목록 조회 (AJAX)
     */
    @GetMapping("/{projectId}/equipment/list")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getProjectEquipments(
            @PathVariable("projectId") Long projectId,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
            
            System.out.println("=== 프로젝트 기자재 목록 조회 ===");
            System.out.println("프로젝트 ID: " + projectId);
            System.out.println("요청 사용자: " + loginUser.getName());
            
            // 프로젝트에 등록된 기자재 목록 조회
            List<ProjectEquipmentDto> projectEquipments = projectEquipmentService.getProjectEquipments(projectId);
            
            System.out.println("조회된 기자재 수: " + projectEquipments.size());
            
            // 각 기자재 상세 정보 로깅
            for (int i = 0; i < projectEquipments.size(); i++) {
                ProjectEquipmentDto equipment = projectEquipments.get(i);
                System.out.println("기자재 " + (i + 1) + ":");
                System.out.println("  - ID: " + equipment.getId());
                System.out.println("  - 기자재 ID: " + equipment.getEquipmentId());
                System.out.println("  - 기자재명: " + equipment.getEquipmentName());
                System.out.println("  - 대여자: " + equipment.getRenterName());
                System.out.println("  - 사용 목적: " + equipment.getPurpose());
                System.out.println("  - 추가자: " + equipment.getAddedBy());
            }
            
            response.put("success", true);
            response.put("equipments", projectEquipments);
            response.put("count", projectEquipments.size());
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("프로젝트 기자재 목록 조회 중 오류: " + e.getMessage());
            response.put("success", false);
            response.put("message", "기자재 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

}