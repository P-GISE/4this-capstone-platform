package com.example.test.archive;

import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.test.auth.AuthDto;
import com.example.test.equipment.EquipmentDto;
import com.example.test.equipment.EquipmentService;
import com.example.test.equipmentrental.EquipmentRentalDto;
import com.example.test.equipmentrental.EquipmentRentalService;
import com.example.test.notification.NotificationService;
import com.example.test.project.ProjectDetailDto;
import com.example.test.project.ProjectDto;
import com.example.test.project.ProjectMemberDto;
import com.example.test.project.ProjectService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

@Controller
@RequestMapping("/archive")
public class ArchiveController {
    private ArchiveDto requireArchiveOwner(Long id, HttpSession session) {
        AuthDto actor = (AuthDto) session.getAttribute("loginUser");
        ArchiveDto archive = archiveService.getArchiveById(id);
        if (archive == null || actor == null || !("ADMIN".equals(actor.getRole())
                || java.util.Objects.equals(actor.getId(), archive.getSubmittedBy()))) {
            throw new com.example.test.config.AccessDeniedException();
        }
        return archive;
    }

    private void requireArchiveProject(Long projectId, HttpSession session) {
        AuthDto actor = (AuthDto) session.getAttribute("loginUser");
        if (actor == null || (projectId != null && !"ADMIN".equals(actor.getRole())
                && projectService.getProjectsForUser(actor.getId()).stream()
                    .noneMatch(project -> java.util.Objects.equals(projectId, project.getId())))) {
            throw new com.example.test.config.AccessDeniedException();
        }
    }


    @Autowired
    private ArchiveService archiveService;

    @Autowired
    private ProjectService projectService;
    
    @Autowired
    private EquipmentRentalService equipmentRentalService;
    
    @Autowired
    private EquipmentService equipmentService;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Autowired
    private NotificationService notificationService;

    @GetMapping("/list")
    public String archiveList(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String year,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "6") int size,
            Model model) {
        
        // 검색 조건 설정
        java.util.Map<String, Object> searchParams = new java.util.HashMap<>();
        searchParams.put("search", search != null ? search.trim() : "");
        searchParams.put("category", category != null ? category.trim() : "");
        searchParams.put("year", year != null ? year.trim() : "");
        searchParams.put("page", page);
        searchParams.put("size", size);
        searchParams.put("offset", (page - 1) * size);
        
        // 전체 개수 조회
        int totalCount = archiveService.getArchiveCount(searchParams);
        
        // 페이지네이션 정보 계산
        int totalPages = Math.max(1, (int) Math.ceil((double) totalCount / size));
        int startPage = Math.max(1, page - 2);
        int endPage = Math.min(totalPages, page + 2);
        
        // 아카이브 목록 조회
        List<ArchiveDto> archives = archiveService.getArchiveListWithPaging(searchParams);
        
        // 🔍 디버깅 로그
        System.out.println("=== 아카이브 조회 결과 ===");
        System.out.println("검색어: " + (search != null ? search : "null"));
        System.out.println("카테고리: " + (category != null ? category : "null"));
        System.out.println("연도: " + (year != null ? year : "null"));
        System.out.println("페이지: " + page);
        System.out.println("페이지 크기: " + size);
        System.out.println("오프셋: " + ((page - 1) * size));
        System.out.println("총 개수: " + totalCount);
        System.out.println("총 페이지: " + totalPages);
        System.out.println("조회된 개수: " + archives.size());
        for(int i = 0; i < Math.min(archives.size(), 5); i++) {
            ArchiveDto archive = archives.get(i);
            System.out.println((i+1) + ". ID:" + archive.getId() + 
                            ", Title:" + archive.getTitle() + 
                            ", Category:" + archive.getCategory());
        }
        if (archives.size() > 5) {
            System.out.println("... 외 " + (archives.size() - 5) + "개 더");
        }
        System.out.println("=======================");
        
        model.addAttribute("archives", archives);
        model.addAttribute("search", search);
        model.addAttribute("category", category);
        model.addAttribute("year", year);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("startPage", startPage);
        model.addAttribute("endPage", endPage);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("size", size);
        
        return "archive/list";
    }

    @GetMapping("/write")
    public String archiveWriteForm(@RequestParam(required = false) Long projectId, Model model, HttpSession session) {
        // 로그인 확인
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        ArchiveDto archiveDto = new ArchiveDto();

        if (projectId != null) {
            ProjectDto project = projectService.getProjectById(projectId);
            if (project != null) {
                archiveDto.setProjectId(project.getId());
                archiveDto.setTitle(project.getTitle());
                archiveDto.setDescription(project.getDescription());
            }
        }

        // 로그인한 사용자가 속한 프로젝트만 가져오기
        List<ProjectDto> projectList = projectService.getProjectsForUser(loginUser.getId());
        
        // 디버깅 로그 추가
        System.out.println("=== 사용자 프로젝트 조회 ===");
        System.out.println("사용자 ID: " + loginUser.getId());
        System.out.println("사용자 이름: " + loginUser.getName());
        System.out.println("프로젝트 개수: " + projectList.size());
        for (ProjectDto project : projectList) {
            System.out.println("- " + project.getTitle() + " (ID: " + project.getId() + ")");
        }
        System.out.println("=========================");
        
        model.addAttribute("archive", archiveDto);
        model.addAttribute("projectList", projectList);
        return "archive/write";
    }

    @PostMapping("/write")
    public String saveArchive(@ModelAttribute ArchiveDto archiveDto, 
                             @RequestParam(value = "attachFile", required = false) List<MultipartFile> files,
                             HttpSession session,
                             RedirectAttributes redirectAttrs) {
        requireArchiveProject(archiveDto.getProjectId(), session);
        Long loginUserId = ((AuthDto) session.getAttribute("loginUser")).getId();
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");

        if (loginUserId != null) {
            archiveDto.setSubmittedBy(loginUserId);
        }

        // ✅ 작성자 이름 자동 입력
        if ((archiveDto.getSubmittedByName() == null || archiveDto.getSubmittedByName().trim().isEmpty())
            && loginUser != null) {
            archiveDto.setSubmittedByName(loginUser.getName());
        }

        if (archiveDto.getIsPublic() == null) {
            archiveDto.setIsPublic(true);
        }

        archiveDto.setIsSubmitted(true);     // 항상 제출 상태
        archiveDto.setApproved(false); 

        if (archiveDto.getVersion() == null || archiveDto.getVersion().isEmpty()) {
            archiveDto.setVersion("v1.0");
        }

        // 프로젝트 기자재 정보 수집
        if (archiveDto.getProjectId() != null) {
            try {
                ProjectDetailDto projectDetail = projectService.getProjectDetail(archiveDto.getProjectId());
                if (projectDetail != null) {
                    // 프로젝트 멤버 ID 수집
                    List<Long> memberIds = projectDetail.getMembers().stream()
                            .map(ProjectMemberDto::getUserId)
                            .collect(java.util.stream.Collectors.toList());
                    
                    // 현재 대여중인 기자재 조회
                    List<EquipmentRentalDto> equipmentRentals = equipmentRentalService.getCurrentRentalsByProjectMembers(memberIds);
                    
                    // 기자재 상세 정보와 함께 JSON 생성
                    List<java.util.Map<String, Object>> equipmentInfoList = new java.util.ArrayList<>();
                    for (EquipmentRentalDto rental : equipmentRentals) {
                        EquipmentDto equipment = equipmentService.getEquipmentById(rental.getEquipmentId());
                        ProjectMemberDto member = projectDetail.getMembers().stream()
                                .filter(m -> m.getUserId().equals(rental.getUserId()))
                                .findFirst()
                                .orElse(null);
                        
                        if (equipment != null && member != null) {
                            java.util.Map<String, Object> equipmentInfo = new java.util.HashMap<>();
                            equipmentInfo.put("equipmentName", equipment.getName());
                            equipmentInfo.put("category", equipment.getCategory());
                            equipmentInfo.put("manufacturer", equipment.getManufacturer());
                            equipmentInfo.put("quantity", rental.getRequestedQuantity());
                            equipmentInfo.put("renterName", member.getUserName());
                            equipmentInfo.put("rentDate", rental.getRentDate());
                            equipmentInfo.put("expectedReturnDate", rental.getExpectedReturnDate());
                            equipmentInfo.put("purpose", rental.getPurpose());
                            equipmentInfoList.add(equipmentInfo);
                        }
                    }
                    
                    // JSON으로 변환해서 저장
                    if (!equipmentInfoList.isEmpty()) {
                        String equipmentJson = objectMapper.writeValueAsString(equipmentInfoList);
                        archiveDto.setEquipmentInfo(equipmentJson);
                    }
                }
            } catch (JsonProcessingException e) {
                System.err.println("기자재 정보 JSON 처리 중 오류: " + e.getMessage());
                // 오류가 발생해도 아카이브 저장은 계속 진행
            } catch (RuntimeException e) {
                System.err.println("기자재 정보 수집 중 시스템 오류: " + e.getMessage());
                // 오류가 발생해도 아카이브 저장은 계속 진행
            }
        }

        String uploadDir = com.example.test.config.RuntimePaths.uploads("archives");
        archiveService.saveArchiveWithFiles(archiveDto, files, uploadDir);
        
        redirectAttrs.addFlashAttribute("successMessage", "아카이브가 등록되었습니다.");
        return "redirect:/archive/list";
    }

    @GetMapping("/detail/{id}")
    public String archiveDetail(@PathVariable("id") Long id, Model model) {
        ArchiveDto archive = archiveService.getArchiveById(id);
        List<ArchiveFileDto> files = archiveService.getArchiveFiles(id);
        
        // 기자재 정보 파싱 (JSON을 List로 변환)
        List<java.util.Map<String, Object>> equipmentList = new java.util.ArrayList<>();
        if (archive.getEquipmentInfo() != null && !archive.getEquipmentInfo().trim().isEmpty()) {
            try {
                TypeReference<List<java.util.Map<String, Object>>> typeRef = new TypeReference<List<java.util.Map<String, Object>>>() {};
                equipmentList = objectMapper.readValue(archive.getEquipmentInfo(), typeRef);
                System.out.println("=== 아카이브 기자재 정보 ===");
                System.out.println("기자재 개수: " + equipmentList.size());
                for (java.util.Map<String, Object> equipment : equipmentList) {
                    System.out.println("- " + equipment.get("equipmentName") + " (대여자: " + equipment.get("renterName") + ")");
                }
                System.out.println("===========================");
            } catch (JsonProcessingException e) {
                System.err.println("기자재 정보 JSON 파싱 중 오류: " + e.getMessage());
                equipmentList = new java.util.ArrayList<>();
            } catch (RuntimeException e) {
                System.err.println("기자재 정보 처리 중 시스템 오류: " + e.getMessage());
                equipmentList = new java.util.ArrayList<>();
            }
        }
        
        // 프로젝트 상세 정보 조회 (프로젝트 ID가 있는 경우)
        if (archive.getProjectId() != null) {
            try {
                com.example.test.project.ProjectDetailDto projectDetail = projectService.getProjectDetail(archive.getProjectId());
                model.addAttribute("projectDetail", projectDetail);
                
                // 프로젝트 보고서 조회
                List<com.example.test.project.ProjectReportDto> projectReports = projectService.getReportsByProjectId(archive.getProjectId());
                model.addAttribute("projectReports", projectReports);
                
                // 디버깅 로그
                System.out.println("=== 아카이브 상세 - 프로젝트 정보 ===");
                System.out.println("프로젝트 ID: " + archive.getProjectId());
                if (projectDetail != null) {
                    System.out.println("프로젝트 제목: " + projectDetail.getProject().getTitle());
                    System.out.println("팀원 수: " + projectDetail.getMembers().size());
                    System.out.println("작업 수: " + projectDetail.getTasks().size());
                    System.out.println("보고서 수: " + projectReports.size());
                } else {
                    System.out.println("프로젝트 정보를 찾을 수 없음");
                }
                System.out.println("=====================================");
                
            } catch (Exception e) {
                System.out.println("프로젝트 정보 조회 중 오류: " + e.getMessage());
            }
        }
        
        model.addAttribute("archive", archive);
        model.addAttribute("files", files);
        model.addAttribute("equipmentList", equipmentList);
        return "archive/detail";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable("id") Long id, Model model, HttpSession session) {
        // 로그인 확인
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        ArchiveDto archive = requireArchiveOwner(id, session);
        
        // 로그인한 사용자가 속한 프로젝트만 가져오기
        List<ProjectDto> projectList = projectService.getProjectsForUser(loginUser.getId());
        List<ArchiveFileDto> files = archiveService.getArchiveFiles(id);
        
        model.addAttribute("archive", archive);
        model.addAttribute("projectList", projectList);
        model.addAttribute("files", files);
        return "archive/edit";
    }

    @PostMapping("/edit")
    public String updateArchive(@ModelAttribute ArchiveDto archiveDto,
                               @RequestParam(value = "attachFile", required = false) List<MultipartFile> files,
                               @RequestParam(value = "deleteFileIds", required = false) List<Long> deleteFileIds,
                               RedirectAttributes redirectAttrs, HttpSession session) {
        ArchiveDto existing = requireArchiveOwner(archiveDto.getId(), session);
        requireArchiveProject(archiveDto.getProjectId(), session);
        archiveDto.setSubmittedByName(existing.getSubmittedByName());
        if (deleteFileIds != null) {
            for (Long fileId : deleteFileIds) {
                ArchiveFileDto file = archiveService.getFileById(fileId);
                if (file == null || !java.util.Objects.equals(existing.getId(), file.getArchiveId())) {
                    throw new com.example.test.config.AccessDeniedException();
                }
            }
        }

        // 디버깅 로그 추가
        System.out.println("=== 아카이브 수정 요청 ===");
        System.out.println("아카이브 ID: " + archiveDto.getId());
        System.out.println("제목: " + archiveDto.getTitle());
        System.out.println("새 파일 개수: " + (files != null ? files.size() : 0));
        System.out.println("삭제할 파일 ID 개수: " + (deleteFileIds != null ? deleteFileIds.size() : 0));
        if (deleteFileIds != null && !deleteFileIds.isEmpty()) {
            System.out.println("삭제할 파일 ID들: " + deleteFileIds);
        }
        System.out.println("=========================");
        
        // 아카이브 수정 및 파일 처리 (공지사항과 동일한 방식)
        archiveService.updateArchiveWithFiles(archiveDto, files, deleteFileIds);
        
        redirectAttrs.addFlashAttribute("successMessage", "아카이브가 수정되었습니다.");
        return "redirect:/archive/detail/" + archiveDto.getId();
    }

    @PostMapping("/delete/{id}")
    public String deleteArchive(@PathVariable("id") Long id, RedirectAttributes redirectAttrs, HttpSession session) {
        requireArchiveOwner(id, session);
        archiveService.deleteArchive(id);
        redirectAttrs.addFlashAttribute("successMessage", "아카이브가 삭제되었습니다.");
        return "redirect:/archive/list";
    }

    

    /**
     * 내 아카이브 목록 (승인 대기중 포함)
     */
    @GetMapping("/my")
    public String myArchives(Model model, HttpSession session) {
        // 로그인 확인
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        System.out.println("=== 내 아카이브 목록 조회 ===");
        System.out.println("사용자: " + loginUser.getName() + " (ID: " + loginUser.getId() + ")");
        
        List<ArchiveDto> myArchives = archiveService.getArchivesByUser(loginUser.getId());
        System.out.println("내 아카이브 개수: " + myArchives.size());
        
        for (ArchiveDto archive : myArchives) {
            String status = archive.getApproved() ? "승인됨" : "승인 대기중";
            System.out.println("- " + archive.getTitle() + " (ID: " + archive.getId() + ", 상태: " + status + ")");
        }
        System.out.println("========================");
        
        model.addAttribute("myArchives", myArchives);
        model.addAttribute("userName", loginUser.getName());
        return "archive/my-list";
    }
    
    /**
     * 관리자용 승인 대기 목록
     */
    @GetMapping("/admin/pending")
    public String pendingArchives(Model model, HttpSession session) {
        // 로그인 사용자 확인
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        // 관리자 권한 확인
        boolean isAdmin = "ADMIN".equals(loginUser.getRole())
                        || "ASSISTANT".equals(loginUser.getRole()) 
                        || "STAFF".equals(loginUser.getRole());
        if (!isAdmin) {
            return "redirect:/access-denied";
        }
        
        System.out.println("=== 아카이브 승인 대기 목록 조회 ===");
        System.out.println("관리자: " + loginUser.getName() + " (ID: " + loginUser.getId() + ")");
        
        List<ArchiveDto> pendingArchives = archiveService.getPendingArchives();
        System.out.println("승인 대기중인 아카이브 개수: " + pendingArchives.size());
        
        for (ArchiveDto archive : pendingArchives) {
            System.out.println("- " + archive.getTitle() + " (ID: " + archive.getId() + ", 작성자: " + archive.getSubmittedByName() + ")");
        }
        System.out.println("===============================");
        
        model.addAttribute("pendingArchives", pendingArchives);
        return "archive/admin-pending";
    }
    
    /**
     * 아카이브 승인 처리
     */
    @PostMapping("/admin/approve/{id}")
    @ResponseBody
    public ResponseEntity<java.util.Map<String, Object>> approveArchive(
            @PathVariable("id") Long id, 
            HttpSession session) {
        
        java.util.Map<String, Object> response = new java.util.HashMap<>();
        
        try {
            // 로그인 사용자 확인
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(401).body(response);
            }
            
            // 관리자 권한 확인
            boolean isAdmin = "ADMIN".equals(loginUser.getRole()) 
                            || "ASSISTANT".equals(loginUser.getRole()) 
                            || "STAFF".equals(loginUser.getRole());                  
            
            if (!isAdmin) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(401).body(response);
            }
            
            System.out.println("=== 아카이브 승인 요청 ===");
            System.out.println("아카이브 ID: " + id);
            System.out.println("관리자 ID: " + loginUser.getId());
            System.out.println("관리자 이름: " + loginUser.getName());
            System.out.println("관리자 역할: " + loginUser.getRole());
            System.out.println("=======================");
            
            // 아카이브 정보 조회
            ArchiveDto archive = archiveService.getArchiveById(id);
            if (archive == null) {
                response.put("success", false);
                response.put("message", "아카이브를 찾을 수 없습니다.");
                return ResponseEntity.status(404).body(response);
            }
            
            // 승인 처리
            archiveService.approveArchive(id, loginUser.getId());
            
            // 승인 알림 발송
            try {
                if (archive.getSubmittedBy() != null) {
                    notificationService.createNotification(
                        archive.getSubmittedBy(),
                        "ARCHIVE_APPROVED",
                        "✅ 아카이브가 승인되었습니다",
                        "'" + archive.getTitle() + "' 아카이브가 승인되어 공개되었습니다.",
                        "/archive/detail/" + id
                    );
                    System.out.println("아카이브 승인 알림 발송 완료 - 사용자 ID: " + archive.getSubmittedBy());
                }
            } catch (Exception e) {
                System.err.println("아카이브 승인 알림 발송 실패: " + e.getMessage());
                // 알림 발송 실패해도 승인 처리는 성공으로 처리
            }
            
            response.put("success", true);
            response.put("message", "아카이브가 승인되었습니다.");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("아카이브 승인 처리 중 오류: " + e.getMessage());
            response.put("success", false);
            response.put("message", "승인 처리 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 파일 다운로드 (다운로드 카운트 증가 포함)
     */
    @GetMapping("/download")
    @ResponseBody
    public ResponseEntity<Resource> downloadFile(@RequestParam(value = "fileId", required = false) Long fileId,
                                               @RequestParam("file") String fileName,
                                               @RequestParam("original") String originalFileName) {
        try {
            // 파일 ID가 제공된 경우 다운로드 카운트 증가
            if (fileId != null) {
                archiveService.incrementDownloadCount(fileId);
                System.out.println("파일 다운로드 카운트 증가: 파일ID=" + fileId);
            }
            
            String uploadPath = com.example.test.config.RuntimePaths.uploads("archives");
            Path basePath = Paths.get(uploadPath).toAbsolutePath().normalize();
            Path filePath = basePath.resolve(fileName).normalize();
            if (!filePath.startsWith(basePath)) return ResponseEntity.status(403).build();
            Resource resource = new UrlResource(filePath.toUri());

            if (!resource.exists() || !resource.isReadable()) {
                return ResponseEntity.notFound().build();
            }

            // 한글 파일명 인코딩 처리 개선
            String encodedName;
            try {
                encodedName = java.net.URLEncoder.encode(originalFileName, "UTF-8").replaceAll("\\+", "%20");
            } catch (UnsupportedEncodingException e) {
                // UTF-8 인코딩 실패 시 기본 인코딩 사용
                encodedName = java.net.URLEncoder.encode(originalFileName, "ISO-8859-1");
            }

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encodedName)
                    .header(HttpHeaders.CONTENT_TYPE, "application/octet-stream")
                    .body(resource);

        } catch (UnsupportedEncodingException | MalformedURLException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @PostMapping("/approve/{id}")
    public String approve(@PathVariable("id") Long id, HttpSession session, RedirectAttributes redirectAttrs) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        // 관리자 권한 확인
        boolean isAdmin = "ADMIN".equals(loginUser.getRole()) 
                        || "ASSISTANT".equals(loginUser.getRole()) 
                        || "STAFF".equals(loginUser.getRole());
        if (!isAdmin) {
            redirectAttrs.addFlashAttribute("errorMessage", "관리자 권한이 필요합니다.");
            return "redirect:/access-denied";
        }
        
        try {
            System.out.println("=== 아카이브 승인 (폼 방식) ===");
            System.out.println("아카이브 ID: " + id);
            System.out.println("관리자: " + loginUser.getName());
            
            archiveService.approveArchive(id, loginUser.getId());
            redirectAttrs.addFlashAttribute("successMessage", "승인 완료!");
            
            System.out.println("승인 처리 완료");
            System.out.println("==============================");
            
        } catch (Exception e) {
            System.err.println("승인 처리 중 오류: " + e.getMessage());
            redirectAttrs.addFlashAttribute("errorMessage", "승인 처리 중 오류가 발생했습니다.");
        }
        
        return "redirect:/archive/admin/pending";
    }
}