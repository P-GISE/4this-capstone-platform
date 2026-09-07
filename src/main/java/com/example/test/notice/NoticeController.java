package com.example.test.notice;

import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.nio.file.Paths;
import java.util.List;

import javax.servlet.http.HttpSession;
import java.nio.file.Path;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.test.auth.AuthDto;

@Controller
@RequestMapping("/notice")
public class NoticeController {

    private static final Logger logger = LoggerFactory.getLogger(NoticeController.class);

    @Autowired
    NoticeService noticeService;

    /**
     * 공지사항 목록 화면 - 사용자 역할에 따른 필터링 + 페이징 적용
     */
    @GetMapping("/list")
    public String noticeList(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "category", required = false) String category,
            @RequestParam(value = "search", required = false) String search,
            @RequestParam(value = "tab", defaultValue = "notice") String tab,
            Model model,
            HttpSession session) {

        int pageSize = 10;
        int offset = (page - 1) * pageSize;
        if (offset < 0) offset = 0;

        // 로그인 사용자
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        String userRole = "ALL";
        if (loginUser != null) {
            userRole = loginUser.getRole();
            model.addAttribute("userRole", userRole);
            model.addAttribute("loginUser", loginUser);
        }

        model.addAttribute("tab", tab);

        if ("files".equals(tab)) {
            int totalCount = noticeService.countAttachments(category, search);
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);
            List<NoticeAttachmentDto> files = noticeService.getPagedFiles(offset, pageSize, category, search);
        
            model.addAttribute("files", files);
            model.addAttribute("currentPage", page);
            model.addAttribute("totalPages", totalPages);
            model.addAttribute("totalCount", totalCount); // 🔵 추가
            model.addAttribute("category", category);
            model.addAttribute("search", search);
            return "notice/list";
        } else {
            // 🔵 공지사항 탭일 경우 - 역할별 필터링 추가
            int totalCount;
            List<NoticeDto> noticeList;

            if ((category != null && !category.isEmpty()) || (search != null && !search.isEmpty())) {
                // 검색이 있는 경우 - 역할별 필터링과 검색 조건을 함께 적용
                if ("ADMIN".equals(userRole)) {
                    // 관리자는 모든 공지를 볼 수 있음
                    totalCount = noticeService.searchCount(category, search);
                    noticeList = noticeService.searchPaged(offset, pageSize, category, search);
                } else {
                    // 일반 사용자는 역할별 필터링된 검색 결과만
                    totalCount = noticeService.searchCountByRole(category, search, userRole);
                    noticeList = noticeService.searchPagedByRole(offset, pageSize, category, search, userRole);
                }
            } else {
                // 검색이 없는 경우 - 기본 목록에 역할별 필터링 적용
                if ("ADMIN".equals(userRole)) {
                    // 관리자는 모든 공지를 볼 수 있음
                    totalCount = noticeService.countNotices();
                    noticeList = noticeService.listPaged(offset, pageSize);
                } else {
                    // 일반 사용자는 역할별 필터링된 목록만
                    totalCount = noticeService.countNoticesByRole(userRole);
                    noticeList = noticeService.listPagedByRole(offset, pageSize, userRole);
                }
            }

            int totalPages = (int) Math.ceil((double) totalCount / pageSize);

            model.addAttribute("notices", noticeList);
            model.addAttribute("currentPage", page);
            model.addAttribute("totalPages", totalPages);
            model.addAttribute("totalCount", totalCount); // 🔵 추가
            model.addAttribute("pageSize", pageSize);     // 🔵 추가 (10으로 고정)
            model.addAttribute("category", category);
            model.addAttribute("search", search);

            return "notice/list";
        }
    }

    @GetMapping("/write")
    public String writePage() {
        return "notice/write";
    }

    @PostMapping("/write")
    public String writeSubmit(@ModelAttribute NoticeDto noticeDto,
                          @RequestParam("attachFile") List<MultipartFile> files,
                          HttpSession session,
                          RedirectAttributes redirectAttrs) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null || "STUDENT".equals(loginUser.getRole())) {
            redirectAttrs.addFlashAttribute("errorMessage", "권한이 없습니다.");
            return "redirect:/notice/list";
        }

        noticeDto.setWriterId(loginUser.getId());
        noticeDto.setWriterName(loginUser.getName());

        String uploadDir = "/your/upload/folder/path";
        noticeService.insertWithFiles(noticeDto, files, uploadDir);
        redirectAttrs.addFlashAttribute("successMessage", "공지사항이 등록되었습니다.");
        return "redirect:/notice/list";
    }

    @GetMapping("/view")
    public String viewNotice(@RequestParam("id") Long id, Model model, HttpSession session) {
        NoticeDto notice = noticeService.selectById(id);
        if (notice == null) {
            model.addAttribute("errorMessage", "존재하지 않는 공지사항입니다.");
            return "redirect:/notice/list";
        }

        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        String userRole = loginUser != null ? loginUser.getRole() : "ALL";

        if (!"ADMIN".equals(userRole)) {
            if (notice.getTargetRole() != null && 
                !notice.getTargetRole().equals("ALL") && 
                !notice.getTargetRole().equals(userRole)) {
                model.addAttribute("errorMessage", "해당 공지사항을 볼 권한이 없습니다.");
                return "redirect:/notice/list";
            }
        }

        String key = "viewed_notice_" + id;
        Long lastViewTime = (Long) session.getAttribute(key);
        long currentTime = System.currentTimeMillis();

        if (lastViewTime == null || (currentTime - lastViewTime) > 3600000) {
            noticeService.increaseViewCount(id);
            session.setAttribute(key, currentTime);
        }

        if (loginUser != null) {
            model.addAttribute("userRole", loginUser.getRole());
            model.addAttribute("loginUser", loginUser);
        }

        model.addAttribute("notice", notice);
        List<NoticeAttachmentDto> attachments = noticeService.getAttachmentsByNoticeId(id);
        model.addAttribute("attachments", attachments);

        return "notice/view";
    }

    @GetMapping("/edit")
    public String editPage(@RequestParam("id") Long id,
                        Model model,
                        HttpSession session,
                        RedirectAttributes redirectAttrs) {

        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null || "STUDENT".equals(loginUser.getRole())) {
            redirectAttrs.addFlashAttribute("errorMessage", "권한이 없습니다.");
            return "redirect:/notice/list";
        }

        NoticeDto notice = noticeService.selectById(id);
        if (notice == null) {
            redirectAttrs.addFlashAttribute("errorMessage", "수정할 공지사항이 존재하지 않습니다.");
            return "redirect:/notice/list";
        }

        // 작성자 권한 확인 - 작성자만 수정 가능
        if (!loginUser.getId().equals(notice.getWriterId())) {
            redirectAttrs.addFlashAttribute("errorMessage", "작성자만 수정할 수 있습니다.");
            return "redirect:/notice/list";
        }

        // ✅ 이 부분이 없으면 edit.jsp에서 ${attachments} 때문에 터짐
        List<NoticeAttachmentDto> attachments = noticeService.getAttachmentsByNoticeId(id);
        model.addAttribute("attachments", attachments);

        model.addAttribute("notice", notice);
        return "notice/edit";
    }

    @PostMapping("/update")
    public String updateNotice(@RequestParam Long id,
                            @ModelAttribute NoticeDto dto,
                            @RequestParam(value = "attachFile[]", required = false) List<MultipartFile> files,
                            @RequestParam(value = "deleteFileIds", required = false) List<Long> deleteFileIds,
                            HttpSession session,
                            RedirectAttributes redirectAttributes) {

        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null || "STUDENT".equals(loginUser.getRole())) {
            redirectAttributes.addFlashAttribute("errorMessage", "권한이 없습니다.");
            return "redirect:/notice/list";
        }

        // 공지사항 조회 및 작성자 권한 확인
        NoticeDto notice = noticeService.selectById(id);
        if (notice == null) {
            redirectAttributes.addFlashAttribute("errorMessage", "수정할 공지사항이 존재하지 않습니다.");
            return "redirect:/notice/list";
        }

        // 작성자 권한 확인 - 작성자만 수정 가능
        if (!loginUser.getId().equals(notice.getWriterId())) {
            redirectAttributes.addFlashAttribute("errorMessage", "작성자만 수정할 수 있습니다.");
            return "redirect:/notice/list";
        }

        if (loginUser != null) {
            dto.setUpdatedBy(loginUser.getId());
        }

        dto.setId(id);
        noticeService.updateNoticeWithFiles(dto, files, deleteFileIds);

        redirectAttributes.addFlashAttribute("successMessage", "공지사항이 수정되었습니다.");
        return "redirect:/notice/view?id=" + id;
    }

    @PostMapping("/delete")
    public String deleteNotice(@RequestParam Long id,
                            HttpSession session,
                            RedirectAttributes redirectAttributes) {

        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null || "STUDENT".equals(loginUser.getRole())) {
            redirectAttributes.addFlashAttribute("errorMessage", "권한이 없습니다.");
            return "redirect:/notice/list";
        }

        // 공지사항 조회 및 작성자 권한 확인
        NoticeDto notice = noticeService.selectById(id);
        if (notice == null) {
            redirectAttributes.addFlashAttribute("errorMessage", "삭제할 공지사항이 존재하지 않습니다.");
            return "redirect:/notice/list";
        }

        // 작성자 권한 확인 - 작성자만 삭제 가능
        if (!loginUser.getId().equals(notice.getWriterId())) {
            redirectAttributes.addFlashAttribute("errorMessage", "작성자만 삭제할 수 있습니다.");
            return "redirect:/notice/list";
        }

        boolean success = noticeService.deleteNotice(id);

        if (success) {
            redirectAttributes.addFlashAttribute("successMessage", "공지사항이 삭제되었습니다.");
        } else {
            redirectAttributes.addFlashAttribute("errorMessage", "삭제에 실패했습니다.");
        }

        return "redirect:/notice/list";
    }

    @GetMapping("/download")
    public ResponseEntity<Resource> downloadFile(@RequestParam("file") String fileName,
                                                @RequestParam("original") String originalFileName) {
        try {
            String uploadPath = "/your/upload/folder/path";
            Path filePath = Paths.get(uploadPath).resolve(fileName);
            Resource resource = new UrlResource(filePath.toUri());

            if (!resource.exists() || !resource.isReadable()) {
                return ResponseEntity.notFound().build();
            }

            String encodedName = java.net.URLEncoder.encode(originalFileName, "UTF-8").replaceAll("\\+", "%20");

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encodedName)
                    .body(resource);

        } catch (UnsupportedEncodingException | MalformedURLException e) {
            logger.error("파일 다운로드 오류: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError().build();
        }
    }


    
    
}