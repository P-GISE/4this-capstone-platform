package com.example.test.inquiry;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import com.example.test.auth.AuthDto;

@Controller
@RequestMapping("/inquiry")
public class InquiryController {

    @Autowired
    private InquiryService inquiryService;

    @GetMapping("/list")
    public String list(@RequestParam(defaultValue = "1") int page,
                    @RequestParam(required = false) String search,
                    @RequestParam(required = false) String status,
                    @RequestParam(required = false, defaultValue = "latest") String sort,
                    Model model) {

        int pageSize = 10;
        int offset = (page - 1) * pageSize;
        int totalCount = inquiryService.count(search, status);
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);

        List<InquiryDto> inquiryList = inquiryService.getPagedList(offset, pageSize, search, status, sort);

        model.addAttribute("inquiryList", inquiryList);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        // 🔵 추가: 번호 계산에 필요한 변수들
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("pageSize", pageSize);

        return "inquiry/list";
    }

    @GetMapping("/view")
    public String view(@RequestParam Long id, 
                      @RequestParam(required = false) String success,
                      @RequestParam(required = false) String error,
                      Model model, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        InquiryDto dto = inquiryService.selectById(id);
        if (dto == null) {
            return "redirect:/inquiry/list?error=not_found";
        }
        
        // 권한 체크: 작성자 또는 관리자만 상세보기 가능
        boolean isAdmin = "관리자".equals(loginUser.getRole()) || "ADMIN".equals(loginUser.getRole());
        boolean isOwner = loginUser.getId().equals(dto.getUserId());
        
        if (!isAdmin && !isOwner) {
            // 권한이 없으면 목록으로 리다이렉트 (에러 메시지와 함께)
            return "redirect:/inquiry/list?error=access_denied";
        }
        
        // 문의사항 첨부파일 조회
        List<InquiryAttachmentDto> attachments = inquiryService.getAttachmentsByInquiryId(id);
        
        // 답변 목록 조회
        List<InquiryAnswerDto> answers = inquiryService.getAnswersByInquiryId(id);
        
        List<List<InquiryAttachmentDto>> answerAttachments = new ArrayList<>();
        for (InquiryAnswerDto answer : answers) {
            List<InquiryAttachmentDto> answerFiles = inquiryService.getAttachmentsByAnswerId(answer.getId());
            if (answerFiles == null) {
                answerFiles = new ArrayList<>();
            }
            // 디버그 로깅
            System.out.println("답변 ID " + answer.getId() + "의 첨부파일 개수: " + answerFiles.size());
            for (InquiryAttachmentDto file : answerFiles) {
                System.out.println("  - 파일: " + file.getOriginalFileName() + " (ID: " + file.getId() + ")");
            }
            answerAttachments.add(answerFiles);
        }

        // 빈 답변이 있을 경우 JSP 오류 방지를 위해 사이즈 동기화 보장
        while (answerAttachments.size() < answers.size()) {
            answerAttachments.add(new ArrayList<>());
        }
        
        // 수정/삭제 가능 여부 (작성자이면서 답변 대기중인 경우에만)
        boolean canEdit = isOwner && "PENDING".equals(dto.getStatus());
        
        // 읽음 처리를 비동기로 처리 (화면 렌더링과 분리)
        if (isOwner && !answers.isEmpty()) {
            new Thread(() -> {
                    try {
                        Thread.sleep(500); // 0.5초 대기 후
                        inquiryService.markAnswerAsRead(id);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                }
            }).start();
        }
        
        model.addAttribute("inquiry", dto);
        model.addAttribute("attachments", attachments);
        model.addAttribute("answers", answers);
        model.addAttribute("answerAttachments", answerAttachments);
        model.addAttribute("isAdmin", isAdmin);
        model.addAttribute("isOwner", isOwner);
        model.addAttribute("canEdit", canEdit);
        model.addAttribute("loginUser", loginUser);
        
        // 성공/오류 메시지 처리
        if (success != null) {
            if ("answer_added".equals(success)) {
                model.addAttribute("successMessage", "답변이 성공적으로 등록되었습니다.");
            }
        }
        if (error != null) {
            if ("answer_failed".equals(error)) {
                model.addAttribute("errorMessage", "답변 등록 중 오류가 발생했습니다.");
            }
        }
        
        return "inquiry/view";
    }

    @GetMapping("/write")
    public String writeForm(Model model) {
        model.addAttribute("inquiry", new InquiryDto());
        return "inquiry/write";
    }

    @PostMapping("/write")
    public String writeSubmit(@ModelAttribute InquiryDto dto,
                            @RequestParam("attachments") List<MultipartFile> attachments,
                            HttpSession session) throws IOException {

        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/auth/login";

        dto.setUserId(loginUser.getId());
        dto.setStatus("PENDING");
        dto.setReviewed(false);
        dto.setDeleted(false);
        dto.setHasAttachment(!attachments.isEmpty() && !attachments.get(0).isEmpty());

        // 문의사항 저장 (id가 dto에 설정됨)
        inquiryService.insert(dto);

        // 첨부파일 저장
        if (dto.isHasAttachment()) {
            String uploadPath = "C:/uploads/inquiry";
            
            Path uploadDir = Paths.get(uploadPath);
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }
            
            for (MultipartFile file : attachments) {
                if (!file.isEmpty()) {
                    String originalName = file.getOriginalFilename();
                    String storedName = UUID.randomUUID() + "_" + originalName;
                    Path filePath = Paths.get(uploadPath, storedName);
                    file.transferTo(filePath.toFile());

                    InquiryAttachmentDto attach = new InquiryAttachmentDto();
                    attach.setInquiryId(dto.getId()); // 문의사항 첨부파일은 inquiry_id 설정
                    attach.setInquiryAnswerId(null); // 문의사항 첨부파일은 inquiry_answer_id가 null
                    attach.setFileName(storedName);
                    attach.setOriginalFileName(originalName);
                    attach.setFilePath(filePath.toString());
                    attach.setFileType(file.getContentType());
                    attach.setFileSize(file.getSize());
                    attach.setDeleted(false);
                    attach.setDescription("사용자 문의 첨부파일");
                    attach.setDownloadable(true);
                    attach.setDownloadCount(0);

                    inquiryService.insertAttachment(attach);
                }
            }
        }

        return "redirect:/inquiry/list";
    }

    // 답변 작성 처리
    @PostMapping("/answer")
    public String submitAnswer(@RequestParam Long inquiryId,
                            @RequestParam String answer,
                            @RequestParam(value = "answerAttachments", required = false) List<MultipartFile> attachments,
                            HttpSession session) {
        
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                return "redirect:/auth/login";
            }
            
            // 최소한의 권한 체크
            boolean isAdmin = "관리자".equals(loginUser.getRole()) || "ADMIN".equals(loginUser.getRole());
            if (!isAdmin) {
                return "redirect:/inquiry/list"; // 리스트로 리다이렉트
            }

            // 첨부파일 확인
            boolean hasAttachments = false;
            if (attachments != null && !attachments.isEmpty()) {
                hasAttachments = attachments.stream().anyMatch(file -> file != null && !file.isEmpty());
            }
            
            // 답변 객체 생성
            InquiryAnswerDto answerDto = new InquiryAnswerDto();
            answerDto.setInquiryId(inquiryId);
            answerDto.setAdminId(loginUser.getId());
            answerDto.setAnswer(answer);
            answerDto.setHasAttachment(hasAttachments);
            answerDto.setEdited(false);
            answerDto.setReadByUser(false);

            // 답변 저장
            inquiryService.insertAnswer(answerDto);
            
            // 첨부파일 처리
            if (hasAttachments && attachments != null) {
                for (MultipartFile file : attachments) {
                    if (file != null && !file.isEmpty()) {
                        try {
                            // 파일 저장 경로
                            String uploadPath = "C:/uploads/inquiry/answers";
                            Path uploadDir = Paths.get(uploadPath);
                            Files.createDirectories(uploadDir);
                            
                            // 파일 저장
                            String storedName = UUID.randomUUID() + "_" + file.getOriginalFilename();
                            Path filePath = Paths.get(uploadPath, storedName);
                            file.transferTo(filePath.toFile());

                            // 첨부파일 정보 저장
                            InquiryAttachmentDto attach = new InquiryAttachmentDto();
                            attach.setInquiryId(null); // 답변 첨부파일은 inquiry_id가 null
                            attach.setInquiryAnswerId(answerDto.getId());
                            attach.setFileName(storedName);
                            attach.setOriginalFileName(file.getOriginalFilename());
                            attach.setFilePath(filePath.toString());
                            attach.setFileSize(file.getSize());
                            attach.setDeleted(false);
                            attach.setDownloadable(true);
                            attach.setDownloadCount(0);
                            attach.setDescription("관리자 답변 첨부파일");

                            inquiryService.insertAttachment(attach);
                            System.out.println("답변 첨부파일 저장 완료: " + attach.getOriginalFileName() + 
                                             " (답변 ID: " + answerDto.getId() + ")");
                            
                        } catch (IOException | IllegalStateException fileError) {
                            // 파일 저장 실패해도 답변은 저장되도록
                            System.err.println("파일 저장 실패: " + fileError.getMessage());
                        }
                    }
                }
            }

            // 문의사항 상태 변경
            inquiryService.updateInquiryStatus(inquiryId, "ANSWERED");
            
        } catch (IllegalStateException e) {
            System.err.println("답변 등록 중 오류: " + e.getMessage());
            return "redirect:/inquiry/view?id=" + inquiryId + "&error=answer_failed"; // 오류 발생시 해당 문의사항으로
        }

        // 답변 등록 완료 후 해당 문의사항으로 리다이렉트
        return "redirect:/inquiry/view?id=" + inquiryId + "&success=answer_added";
    }

    @GetMapping("/answer/download")
    public ResponseEntity<Resource> downloadAnswerFile(@RequestParam Long attachmentId, HttpSession session) throws IOException {
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(401).build(); // Unauthorized
        }
        
        InquiryAttachmentDto attachment = inquiryService.getAttachmentById(attachmentId);
        if (attachment == null || attachment.isDeleted()) {
            return ResponseEntity.notFound().build();
        }
        
        // 답변 첨부파일인지 확인
        if (attachment.getInquiryAnswerId() == null) {
            return ResponseEntity.notFound().build();
        }
        
        // 답변이 속한 문의사항에 대한 권한 체크
        InquiryAnswerDto answer = inquiryService.getAnswerById(attachment.getInquiryAnswerId());
        if (answer != null) {
            InquiryDto inquiry = inquiryService.selectById(answer.getInquiryId());
            if (inquiry != null) {
                boolean isAdmin = "관리자".equals(loginUser.getRole()) || "ADMIN".equals(loginUser.getRole());
                boolean isOwner = loginUser.getId().equals(inquiry.getUserId());
                
                if (!isAdmin && !isOwner) {
                    return ResponseEntity.status(403).build(); // Forbidden
                }
            }
        }
        
        Path filePath = Paths.get(attachment.getFilePath());
        Resource resource = new UrlResource(filePath.toUri());
        
        if (!resource.exists()) {
            return ResponseEntity.notFound().build();
        }
        
        // 다운로드 카운트 증가
        inquiryService.incrementDownloadCount(attachmentId);
        
        String encodedFilename = URLEncoder.encode(attachment.getOriginalFileName(), "UTF-8")
                .replaceAll("\\+", "%20");
        
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION, 
                    "attachment; filename*=UTF-8''" + encodedFilename)
                .body(resource);
    }

    // 문의사항 수정 폼
    @GetMapping("/edit")
    public String editForm(@RequestParam Long id, Model model, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/auth/login";
        
        InquiryDto dto = inquiryService.selectById(id);
        if (dto == null) return "redirect:/inquiry/list";
        
        // 권한 체크: 작성자이면서 답변 대기중인 경우에만 수정 가능
        boolean isOwner = loginUser.getId().equals(dto.getUserId());
        boolean canEdit = isOwner && "PENDING".equals(dto.getStatus());
        
        if (!canEdit) {
            return "redirect:/inquiry/view?id=" + id + "&error=cannot_edit";
        }
        
        List<InquiryAttachmentDto> attachments = inquiryService.getAttachmentsByInquiryId(id);
        
        model.addAttribute("inquiry", dto);
        model.addAttribute("attachments", attachments);
        
        return "inquiry/edit";
    }

    // 문의사항 수정 처리
    @PostMapping("/edit")
    public String editSubmit(@ModelAttribute InquiryDto dto,
                           @RequestParam("attachments") List<MultipartFile> attachments,
                           @RequestParam(value = "deleteAttachmentIds", required = false) String deleteAttachmentIds,
                           HttpSession session) throws IOException {
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/auth/login";
        
        InquiryDto originalDto = inquiryService.selectById(dto.getId());
        if (originalDto == null) return "redirect:/inquiry/list";
        
        // 권한 체크
        boolean isOwner = loginUser.getId().equals(originalDto.getUserId());
        boolean canEdit = isOwner && "PENDING".equals(originalDto.getStatus());
        
        if (!canEdit) {
            return "redirect:/inquiry/view?id=" + dto.getId() + "&error=cannot_edit";
        }
        
        // 기존 정보 유지
        dto.setUserId(originalDto.getUserId());
        dto.setStatus(originalDto.getStatus());
        dto.setReviewed(originalDto.isReviewed());
        dto.setDeleted(originalDto.isDeleted());
        dto.setCreatedAt(originalDto.getCreatedAt());
        
        // 기존 첨부파일 삭제 처리
        if (deleteAttachmentIds != null && !deleteAttachmentIds.trim().isEmpty()) {
            for (String idStr : deleteAttachmentIds.split("\\s*,\\s*")) {
                if (!idStr.isEmpty()) {
                try {
                        inquiryService.deleteAttachment(Long.valueOf(idStr));
                } catch (NumberFormatException e) {
                    System.err.println("잘못된 첨부파일 ID: " + idStr);
                    }
                }
            }
        }
        
        // 새 첨부파일 추가
        boolean hasNewAttachments = !attachments.isEmpty() && !attachments.get(0).isEmpty();
        List<InquiryAttachmentDto> remainingAttachments = inquiryService.getAttachmentsByInquiryId(dto.getId());
        boolean hasRemainingAttachments = !remainingAttachments.isEmpty();
        
        dto.setHasAttachment(hasNewAttachments || hasRemainingAttachments);
        
        // 문의사항 수정
        inquiryService.update(dto);
        
        // 새 첨부파일 저장
        if (hasNewAttachments) {
            String uploadPath = "C:/uploads/inquiry";
            
            Path uploadDir = Paths.get(uploadPath);
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }
            
            for (MultipartFile file : attachments) {
                if (!file.isEmpty()) {
                    String originalName = file.getOriginalFilename();
                    String storedName = UUID.randomUUID() + "_" + originalName;
                    Path filePath = Paths.get(uploadPath, storedName);
                    file.transferTo(filePath.toFile());

                    InquiryAttachmentDto attach = new InquiryAttachmentDto();
                    attach.setInquiryId(dto.getId()); // 문의사항 첨부파일은 inquiry_id 설정
                    attach.setInquiryAnswerId(null); // 문의사항 첨부파일은 inquiry_answer_id가 null
                    attach.setFileName(storedName);
                    attach.setOriginalFileName(originalName);
                    attach.setFilePath(filePath.toString());
                    attach.setFileType(file.getContentType());
                    attach.setFileSize(file.getSize());
                    attach.setDeleted(false);
                    attach.setDescription("사용자 문의 첨부파일");
                    attach.setDownloadable(true);
                    attach.setDownloadCount(0);

                    inquiryService.insertAttachment(attach);
                }
            }
        }
        
        return "redirect:/inquiry/view?id=" + dto.getId();
    }

    // 문의사항 삭제
    @PostMapping("/delete")
    public String delete(@RequestParam Long id, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/auth/login";
        
        InquiryDto dto = inquiryService.selectById(id);
        if (dto == null) return "redirect:/inquiry/list";
        
        // 권한 체크: 작성자이면서 답변 대기중인 경우에만 삭제 가능
        boolean isOwner = loginUser.getId().equals(dto.getUserId());
        boolean canDelete = isOwner && "PENDING".equals(dto.getStatus());
        
        if (!canDelete) {
            return "redirect:/inquiry/view?id=" + id + "&error=cannot_delete";
        }
        
        inquiryService.delete(id);
        return "redirect:/inquiry/list?deleted=true";
    }

    // 파일 다운로드
    @GetMapping("/download")
    public ResponseEntity<Resource> downloadFile(@RequestParam Long attachmentId, HttpSession session) throws IOException {
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return ResponseEntity.status(401).build(); // Unauthorized
        }
        
        InquiryAttachmentDto attachment = inquiryService.getAttachmentById(attachmentId);
        if (attachment == null || attachment.isDeleted()) {
            return ResponseEntity.notFound().build();
        }
        
        // 첨부파일이 문의사항에 속한 경우 권한 체크
        if (attachment.getInquiryId() != null) {
            InquiryDto inquiry = inquiryService.selectById(attachment.getInquiryId());
            if (inquiry != null) {
                boolean isAdmin = "관리자".equals(loginUser.getRole()) || "ADMIN".equals(loginUser.getRole());
                boolean isOwner = loginUser.getId().equals(inquiry.getUserId());
                
                if (!isAdmin && !isOwner) {
                    return ResponseEntity.status(403).build(); // Forbidden
                }
            }
        }
        
        // 첨부파일이 답변에 속한 경우 권한 체크
        if (attachment.getInquiryAnswerId() != null) {
            InquiryAnswerDto answer = inquiryService.getAnswerById(attachment.getInquiryAnswerId());
            if (answer != null) {
                InquiryDto inquiry = inquiryService.selectById(answer.getInquiryId());
                if (inquiry != null) {
                    boolean isAdmin = "관리자".equals(loginUser.getRole()) || "ADMIN".equals(loginUser.getRole());
                    boolean isOwner = loginUser.getId().equals(inquiry.getUserId());
                    
                    if (!isAdmin && !isOwner) {
                        return ResponseEntity.status(403).build(); // Forbidden
                    }
                }
            }
        }
        
        Path filePath = Paths.get(attachment.getFilePath());
        Resource resource = new UrlResource(filePath.toUri());
        
        if (!resource.exists()) {
            return ResponseEntity.notFound().build();
        }
        
        // 다운로드 카운트 증가
        inquiryService.incrementDownloadCount(attachmentId);
        
        String encodedFilename = URLEncoder.encode(attachment.getOriginalFileName(), "UTF-8")
                .replaceAll("\\+", "%20");
        
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .header(HttpHeaders.CONTENT_DISPOSITION, 
                       "attachment; filename*=UTF-8''" + encodedFilename)
                .body(resource);
    }
}