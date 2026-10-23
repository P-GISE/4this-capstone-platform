package com.example.test.chat;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.example.test.auth.AuthDto;
import com.example.test.project.ProjectCreationDto;
import com.example.test.project.ProjectDto;
import com.example.test.project.ProjectService;

@Controller
@RequestMapping("/chat")
public class ChatController {
    
    private final ChatService chatService;
    private final HttpSession session;
    private final OnlineUserService onlineUserService;
    private final UserStatusService userStatusService;
    private final ProjectService projectService;
    
    @Autowired
    public ChatController(ChatService chatService, HttpSession session, OnlineUserService onlineUserService, UserStatusService userStatusService, ProjectService projectService) {
        this.chatService = chatService;
        this.session = session;
        this.onlineUserService = onlineUserService;
        this.userStatusService = userStatusService;
        this.projectService = projectService;
    }
    
    @GetMapping("")
    public String showChatMain(HttpSession session, Model model) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        // 채팅방 목록 로드
        List<ChatDTO> rooms = chatService.getAllChatRooms();
        model.addAttribute("rooms", rooms);
        model.addAttribute("user", loginUser);
        return "chat/chatRoomList";
    }
    
    @PostMapping("/createMainRoom")
    @ResponseBody
    public String createMainChatRoom(@RequestParam Long projectId, @RequestParam Long userId) {
        try {
        boolean created = chatService.createMainChatRoomIfNotExists(projectId, userId);
        return created ? "success" : "already_exists";
        } catch (RuntimeException e) {
            System.err.println("메인 채팅방 생성 실패: " + e.getMessage());
            return "error: " + e.getMessage();
        } catch (Exception e) {
            System.err.println("메인 채팅방 생성 중 예상치 못한 오류: " + e.getMessage());
            return "error: 채팅방 생성 중 오류가 발생했습니다.";
        }
    }
    
    @GetMapping("/rooms")
    @ResponseBody
    public List<ChatDTO> getChatRooms() {
        return chatService.getAllChatRooms();
    }
    
    @PostMapping("/message")
    @ResponseBody
    public ResponseEntity<Map<String, Long>> saveMessage(@RequestBody ChatMessageDTO message) {
        chatService.saveMessage(message);
        Map<String, Long> response = new HashMap<>();
        response.put("messageId", message.getId());
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/messages")
    @ResponseBody
    public List<ChatMessageDTO> getMessages(
            @RequestParam Long roomId,
            @RequestParam(defaultValue = "0") int offset,
            @RequestParam(defaultValue = "50") int limit) {
        return chatService.getMessages(roomId, offset, limit);
    }
    
    @GetMapping("/message/{messageId}/replies")
    @ResponseBody
    public List<ChatMessageDTO> getMessageReplies(@PathVariable Long messageId) {
        return chatService.getMessageReplies(messageId);
    }
    
    @PutMapping("/message/{messageId}")
    @ResponseBody
    public ResponseEntity<String> updateMessage(
            @PathVariable Long messageId,
            @RequestParam Long senderId,
            @RequestBody String newMessage) {
        chatService.updateMessage(messageId, senderId, newMessage);
        return ResponseEntity.ok("success");
    }
    
    @DeleteMapping("/message/{messageId}")
    @ResponseBody
    public ResponseEntity<String> deleteMessage(
            @PathVariable Long messageId,
            @RequestParam Long senderId) {
        chatService.deleteMessage(messageId, senderId);
        return ResponseEntity.ok("success");
    }
    
    @PostMapping("/message/{messageId}/pin")
    @ResponseBody
    public ResponseEntity<String> togglePinMessage(@PathVariable Long messageId) {
        chatService.togglePinMessage(messageId);
        return ResponseEntity.ok("success");
    }
    
    @PostMapping("/message/file")
    @ResponseBody
    public ResponseEntity<String> saveMessageFile(@RequestBody ChatMessageFileDTO file) {
        chatService.saveMessageFile(file);
        return ResponseEntity.ok("success");
    }
    
    @PostMapping("/upload")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> uploadFiles(
            @RequestParam("files") MultipartFile[] files,
            @RequestParam("roomId") Long roomId) {
        Map<String, Object> response = new HashMap<>();
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.ok(response);
            }
            
            List<Map<String, Object>> uploadedFiles = new ArrayList<>();
            
            // 업로드 디렉토리 생성
            String uploadDir = com.example.test.config.RuntimePaths.uploads("chat");
            java.io.File uploadDirFile = new java.io.File(uploadDir);
            if (!uploadDirFile.exists()) {
                uploadDirFile.mkdirs();
            }
            
            for (MultipartFile file : files) {
                if (!file.isEmpty()) {
                    // 파일명 생성 (중복 방지)
                    String originalFileName = file.getOriginalFilename();
                    String fileName = System.currentTimeMillis() + "_" + originalFileName;
                    String filePath = uploadDir + "/" + fileName;
                    
                    // 실제 파일 저장
                    java.io.File dest = new java.io.File(filePath);
                    file.transferTo(dest);
                    
                    // 먼저 파일 첨부 메시지를 생성
                    ChatMessageDTO messageDTO = new ChatMessageDTO();
                    messageDTO.setRoomId(roomId);
                    messageDTO.setSenderId(loginUser.getId());
                    messageDTO.setSenderName(loginUser.getName());
                    messageDTO.setContent("📎 파일이 첨부되었습니다: " + originalFileName);
                    messageDTO.setMessageType(MessageType.FILE);
                    messageDTO.setSendTime(java.time.LocalDateTime.now());
                    
                    // 메시지 저장하고 ID 받기
                    chatService.saveMessage(messageDTO);
                    Long messageId = messageDTO.getId(); // saveMessage에서 생성된 ID 가져오기
                    
                    // 파일 정보 생성
                    Map<String, Object> fileInfo = new HashMap<>();
                    fileInfo.put("fileName", originalFileName);
                    fileInfo.put("filePath", "/uploads/" + fileName); // 웹 접근 경로
                    fileInfo.put("fileSize", file.getSize());
                    fileInfo.put("fileType", file.getContentType());
                    fileInfo.put("messageId", messageId);
                    
                    // 데이터베이스에 파일 정보 저장 (message_id 포함)
                    ChatMessageFileDTO fileDTO = new ChatMessageFileDTO();
                    fileDTO.setMessageId(messageId); // 중요: 메시지 ID 설정
                    fileDTO.setFileName(originalFileName);
                    fileDTO.setFilePath("/uploads/" + fileName);
                    fileDTO.setFileSize(file.getSize());
                    fileDTO.setFileType(file.getContentType());
                    fileDTO.setOriginalFileName(originalFileName);
                    
                    Long fileId = chatService.saveMessageFile(fileDTO); // 파일 ID 받기
                    
                    // 디버깅: 파일 ID 로깅
                    System.out.println("=== 파일 업로드 디버깅 ===");
                    System.out.println("파일명: " + originalFileName);
                    System.out.println("메시지 ID: " + messageId);
                    System.out.println("생성된 파일 ID: " + fileId);
                    System.out.println("fileDTO.getId(): " + fileDTO.getId());
                    System.out.println("==========================");
                    
                    // 파일 ID를 fileInfo에 추가
                    fileInfo.put("id", fileId);
                    fileInfo.put("originalFileName", originalFileName); // 추가
                    
                    uploadedFiles.add(fileInfo);
                }
            }
            
            response.put("success", true);
            response.put("files", uploadedFiles);
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            System.err.println("파일 업로드 중 IO 오류: " + e.getMessage());
            response.put("success", false);
            response.put("message", "파일 업로드 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            System.err.println("파일 업로드 중 런타임 오류: " + e.getMessage());
            response.put("success", false);
            response.put("message", "파일 처리 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }
    
    @GetMapping("/message/{messageId}/files")
    @ResponseBody
    public List<ChatMessageFileDTO> getMessageFiles(@PathVariable Long messageId) {
        return chatService.getMessageFiles(messageId);
    }
    
    @GetMapping("/download/{fileId}")
    public ResponseEntity<Resource> downloadFile(@PathVariable Long fileId) {
        try {
            // 파일 정보 조회
            ChatMessageFileDTO fileInfo = chatService.getMessageFileById(fileId);
            if (fileInfo == null) {
                return ResponseEntity.notFound().build();
            }
            
            // 실제 파일 경로 (uploads 디렉토리 기준)
            String filePath = System.getProperty("user.dir") + fileInfo.getFilePath();
            java.io.File file = new java.io.File(filePath);
            
            if (!file.exists()) {
                return ResponseEntity.notFound().build();
            }
            
            // 파일 리소스 생성
            Resource resource = new FileSystemResource(file);
            
            // 파일명 인코딩 (한글 파일명 지원)
            String encodedFileName = java.net.URLEncoder.encode(fileInfo.getOriginalFileName(), "UTF-8")
                    .replaceAll("\\+", "%20");
            
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, 
                            "attachment; filename*=UTF-8''" + encodedFileName)
                    .header(HttpHeaders.CONTENT_TYPE, "application/octet-stream")
                    .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(file.length()))
                    .body(resource);
                    
        } catch (IOException | RuntimeException e) {
            System.err.println("파일 다운로드 중 오류: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @GetMapping("/download/by-name/{fileName:.+}")
    public ResponseEntity<Resource> downloadFileByName(@PathVariable String fileName, @RequestParam Long roomId) {
        try {
            System.out.println("=== 파일명으로 다운로드 시도 ===");
            System.out.println("파일명: " + fileName);
            System.out.println("채팅방 ID: " + roomId);
            
            // 해당 채팅방의 모든 파일 중에서 파일명이 일치하는 것 찾기
            List<ChatMessage> messages = chatService.getRoomMessages(roomId);
            ChatMessageFileDTO targetFile = null;
            
            for (ChatMessage message : messages) {
                List<ChatMessageFileDTO> files = chatService.getMessageFiles(message.getId());
                for (ChatMessageFileDTO file : files) {
                    if (fileName.equals(file.getOriginalFileName())) {
                        targetFile = file;
                        System.out.println("파일을 찾았습니다: " + file.getId());
                        break;
                    }
                }
                if (targetFile != null) break;
            }
            
            if (targetFile == null) {
                System.out.println("파일을 찾을 수 없습니다.");
                return ResponseEntity.notFound().build();
            }
            
            // 실제 파일 경로 (uploads 디렉토리 기준)
            String filePath = System.getProperty("user.dir") + targetFile.getFilePath();
            java.io.File file = new java.io.File(filePath);
            
            if (!file.exists()) {
                System.out.println("실제 파일이 존재하지 않습니다: " + filePath);
                return ResponseEntity.notFound().build();
            }
            
            // 파일 리소스 생성
            Resource resource = new FileSystemResource(file);
            
            // 파일명 인코딩 (한글 파일명 지원)
            String encodedFileName = java.net.URLEncoder.encode(targetFile.getOriginalFileName(), "UTF-8")
                    .replaceAll("\\+", "%20");
            
            System.out.println("다운로드 성공!");
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, 
                            "attachment; filename*=UTF-8''" + encodedFileName)
                    .header(HttpHeaders.CONTENT_TYPE, "application/octet-stream")
                    .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(file.length()))
                    .body(resource);
                    
        } catch (IOException | RuntimeException e) {
            System.err.println("파일명 기반 다운로드 중 오류: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @PostMapping("/message/{messageId}/read")
    @ResponseBody
    public ResponseEntity<String> markMessageAsRead(
            @PathVariable Long messageId,
            @RequestParam Long userId) {
        chatService.markMessageAsRead(messageId, userId);
        return ResponseEntity.ok("success");
    }
    
    @PostMapping("/room")
    @ResponseBody
    public Map<String, Object> createChatRoom(@RequestBody ChatDTO chatDTO) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 기본값 설정
            if (chatDTO.getProjectId() == null) {
                response.put("success", false);
                response.put("message", "프로젝트 ID가 필요합니다.");
                return response;
            }
            
            Map<String, Object> createResult = chatService.createChatRoom(chatDTO);
            if ((Boolean) createResult.get("success")) {
            response.put("success", true);
                response.put("roomId", createResult.get("roomId"));
            } else {
                response.put("success", false);
                response.put("message", createResult.get("message"));
            }
            return response;
        } catch (RuntimeException e) {
            // 비즈니스 로직 에러 (프로젝트 존재하지 않음 등)
            response.put("success", false);
            response.put("message", e.getMessage());
            return response;
        } catch (Exception e) {
            // 예상치 못한 에러
            System.err.println("채팅방 생성 중 예상치 못한 오류: " + e.getMessage());
            response.put("success", false);
            response.put("message", "채팅방 생성 중 오류가 발생했습니다: " + e.getMessage());
            return response;
        }
    }
    
    @PutMapping("/room")
    @ResponseBody
    public Map<String, Object> updateChatRoom(@RequestBody ChatDTO chatDTO) {
        Map<String, Object> response = new HashMap<>();
        try {
            chatService.updateChatRoom(chatDTO.getRoomId(), chatDTO);
            response.put("success", true);
            response.put("roomId", chatDTO.getRoomId());
            return response;
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return response;
        }
    }
    
    @DeleteMapping("/room/{roomId}")
    @ResponseBody
    public Map<String, Object> deleteChatRoom(@PathVariable Long roomId) {
        Map<String, Object> response = new HashMap<>();
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            
            Long userId = loginUser.getId();
            chatService.deleteChatRoom(roomId, userId);
            
            response.put("success", true);
            return response;
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "채팅방 삭제 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    @GetMapping("/search/rooms")
    @ResponseBody
    public List<ChatDTO> searchChatRooms(
            @RequestParam Long projectId,
            @RequestParam(required = false) String keyword) {
        return chatService.searchChatRooms(projectId, keyword);
    }
    
    @GetMapping("/search/messages")
    @ResponseBody
    public List<ChatMessageDTO> searchChatMessages(
            @RequestParam Long roomId,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int offset,
            @RequestParam(defaultValue = "50") int limit) {
        return chatService.searchChatMessages(roomId, keyword, offset, limit);
    }
    
    @PostMapping("/leave")
    @ResponseBody
    public ResponseEntity<String> leaveChatRoom(@RequestBody ChatMessageDTO leaveMessage) {
        try {
            // 퇴장 메시지를 저장하고 브로드캐스트
            leaveMessage.setMessageType(MessageType.SYSTEM);
            leaveMessage.setSendTime(java.time.LocalDateTime.now());
            
            // 사용자 정보 가져와서 senderName 설정 (ChatWebSocketController와 동일한 로직)
            // 여기서는 간단히 처리
            chatService.saveMessage(leaveMessage);
            
        return ResponseEntity.ok("success");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("failed: " + e.getMessage());
        }
    }
    
    @PostMapping("/rejoin")
    @ResponseBody
    public ResponseEntity<String> rejoinChatRoom(
            @RequestParam Long roomId,
            @RequestParam Long userId) {
        chatService.rejoinChatRoom(roomId, userId);
        return ResponseEntity.ok("success");
    }

    @GetMapping("/room/{roomId}")
    public String showChatRoom(@PathVariable Long roomId, HttpSession session, Model model) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        ChatDTO room = chatService.getChatRoom(roomId);
        if (room == null) {
            return "redirect:/chat";
        }
        
        model.addAttribute("user", loginUser);
        model.addAttribute("chatRoom", room);
        model.addAttribute("participants", chatService.getRoomParticipants(roomId));
        model.addAttribute("messages", chatService.getRoomMessagesWithFiles(roomId));
        return "chat/chatRoom";
    }

    @PostMapping("/room/{roomId}/join")
    @ResponseBody
    public Map<String, Object> joinChatRoom(@PathVariable Long roomId, @RequestBody Map<String, String> request) {
        String userIdStr = request.get("userId");
        String nickname = request.get("nickname");
        Map<String, Object> response = new HashMap<>();
        
        try {
            Long userId = Long.valueOf(userIdStr);
            chatService.joinChatRoom(roomId, userId, nickname);
            response.put("success", true);
        } catch (NumberFormatException e) {
            response.put("success", false);
            response.put("message", "userId가 올바른 숫자가 아닙니다.");
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
        }
        
        return response;
    }

    @PostMapping("/room/{roomId}/leave")
    @ResponseBody
    public Map<String, Object> leaveChatRoom(@PathVariable Long roomId, @RequestBody Map<String, String> request) {
        String userIdStr = request.get("userId");
        Map<String, Object> response = new HashMap<>();
        
        try {
            Long userId = Long.valueOf(userIdStr);
            chatService.leaveChatRoom(roomId, userId);
            response.put("success", true);
        } catch (NumberFormatException e) {
            response.put("success", false);
            response.put("message", "userId가 올바른 숫자가 아닙니다.");
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
        }
        
        return response;
    }

    // 채팅방 권한 관리
    @PostMapping("/room/{roomId}/permission")
    public ResponseEntity<Void> setUserPermission(
            @PathVariable Long roomId,
            @RequestParam Long userId,
            @RequestParam String permissionType,
            @RequestParam Long grantedBy) {
        chatService.setUserPermission(roomId, userId, permissionType, grantedBy);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/room/{roomId}/permissions")
    public ResponseEntity<List<String>> getUserPermissions(
            @PathVariable Long roomId,
            @RequestParam Long userId) {
        return ResponseEntity.ok(chatService.getUserPermissions(roomId, userId));
    }

    // 메시지 검색
    @GetMapping("/room/{roomId}/messages/search")
    public ResponseEntity<List<ChatMessageDTO>> searchMessages(
            @PathVariable Long roomId,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(defaultValue = "0") int offset,
            @RequestParam(defaultValue = "20") int limit) {
        return ResponseEntity.ok(chatService.searchMessages(roomId, keyword, startDate, endDate, offset, limit));
    }

    // 채팅방 통계
    @GetMapping("/room/{roomId}/statistics")
    public ResponseEntity<Map<String, Object>> getRoomStatistics(
            @PathVariable Long roomId) {
        return ResponseEntity.ok(chatService.getRoomStatistics(roomId));
    }

    @GetMapping("/room/{roomId}/user-activity")
    public ResponseEntity<List<Map<String, Object>>> getUserActivityStats(
            @PathVariable Long roomId) {
        return ResponseEntity.ok(chatService.getUserActivityStats(roomId));
    }

    @GetMapping("/room/{roomId}/message-stats")
    public ResponseEntity<List<Map<String, Object>>> getMessageStats(
            @PathVariable Long roomId,
            @RequestParam String startDate,
            @RequestParam String endDate) {
        return ResponseEntity.ok(chatService.getMessageStats(roomId, startDate, endDate));
    }

    // 채팅방 알림 설정
    @PutMapping("/room/{roomId}/notifications")
    public ResponseEntity<Void> updateNotificationSettings(
            @PathVariable Long roomId,
            @RequestParam Long userId,
            @RequestParam boolean enabled,
            @RequestParam String type) {
        chatService.updateNotificationSettings(roomId, userId, enabled, type);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/room/{roomId}/notifications")
    public ResponseEntity<Map<String, Object>> getNotificationSettings(
            @PathVariable Long roomId,
            @RequestParam Long userId) {
        return ResponseEntity.ok(chatService.getNotificationSettings(roomId, userId));
    }

    // 채팅방 즐겨찾기
    @PostMapping("/room/{roomId}/favorite")
    public ResponseEntity<Void> addFavoriteRoom(
            @PathVariable Long roomId,
            @RequestParam Long userId) {
        chatService.addFavoriteRoom(userId, roomId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/room/{roomId}/favorite")
    public ResponseEntity<Void> removeFavoriteRoom(
            @PathVariable Long roomId,
            @RequestParam Long userId) {
        chatService.removeFavoriteRoom(userId, roomId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/favorites")
    public ResponseEntity<List<ChatDTO>> getFavoriteRooms(
            @RequestParam Long userId) {
        return ResponseEntity.ok(chatService.getFavoriteRooms(userId));
    }

    // 채팅방 태그
    @PostMapping("/room/{roomId}/tag")
    public ResponseEntity<Void> addRoomTag(
            @PathVariable Long roomId,
            @RequestParam String tagName,
            @RequestParam Long createdBy) {
        chatService.addRoomTag(roomId, tagName, createdBy);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/room/{roomId}/tag")
    public ResponseEntity<Void> removeRoomTag(
            @PathVariable Long roomId,
            @RequestParam String tagName) {
        chatService.removeRoomTag(roomId, tagName);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/room/{roomId}/tags")
    public ResponseEntity<List<String>> getRoomTags(
            @PathVariable Long roomId) {
        return ResponseEntity.ok(chatService.getRoomTags(roomId));
    }

    @GetMapping("/rooms/tag")
    public ResponseEntity<List<ChatDTO>> searchRoomsByTag(
            @RequestParam String tagName) {
        return ResponseEntity.ok(chatService.searchRoomsByTag(tagName));
    }

    // 채팅방 백업
    @GetMapping("/room/{roomId}/backup")
    public ResponseEntity<Map<String, Object>> backupChatRoom(
            @PathVariable Long roomId) {
        return ResponseEntity.ok(chatService.backupChatRoom(roomId));
    }

    @PostMapping("/room/restore")
    public ResponseEntity<Void> restoreChatRoom(
            @RequestBody Map<String, Object> backupData) {
        chatService.restoreChatRoom(backupData);
        return ResponseEntity.ok().build();
    }

    // 채팅방 검색 및 필터링
    @GetMapping("/rooms/search")
    public ResponseEntity<List<ChatDTO>> searchRooms(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Long userId,
            @RequestParam(defaultValue = "lastMessage") String sortBy,
            @RequestParam(defaultValue = "desc") String sortOrder,
            @RequestParam(defaultValue = "0") int offset,
            @RequestParam(defaultValue = "20") int limit) {
        return ResponseEntity.ok(chatService.searchRooms(keyword, type, startDate, endDate, 
                                                       userId, sortBy, sortOrder, offset, limit));
    }

    // 채팅방 공유
    @PostMapping("/room/{roomId}/share")
    public ResponseEntity<Map<String, String>> createRoomShare(
            @PathVariable Long roomId,
            @RequestParam Long sharedBy,
            @RequestParam String shareType,
            @RequestParam(required = false) String expiresAt) {
        String shareToken = chatService.createRoomShare(roomId, sharedBy, shareType, expiresAt);
        Map<String, String> result = new HashMap<>();
        result.put("shareToken", shareToken);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/room/share/{shareToken}")
    public ResponseEntity<Map<String, Object>> getRoomShare(
            @PathVariable String shareToken) {
        return ResponseEntity.ok(chatService.getRoomShare(shareToken));
    }

    @DeleteMapping("/room/{roomId}/share")
    public ResponseEntity<Void> deleteRoomShare(
            @PathVariable Long roomId,
            @RequestParam Long sharedBy) {
        chatService.deleteRoomShare(roomId, sharedBy);
        return ResponseEntity.ok().build();
    }

    // 채팅방 내보내기
    @GetMapping("/room/{roomId}/export")
    public ResponseEntity<byte[]> exportRoomToFile(
            @PathVariable Long roomId,
            @RequestParam(defaultValue = "json") String format) {
        byte[] fileData = chatService.exportRoomToFile(roomId, format);
        String contentType = format.equals("json") ? "application/json" : "text/csv";
        return ResponseEntity.ok()
                .contentType(org.springframework.http.MediaType.parseMediaType(contentType))
                .header("Content-Disposition", "attachment; filename=chat_room_" + roomId + "." + format)
                .body(fileData);
    }

    // 메시지 분석
    @GetMapping("/room/{roomId}/message-analysis")
    public ResponseEntity<List<Map<String, Object>>> analyzeMessagePatterns(
            @PathVariable Long roomId,
            @RequestParam String startDate,
            @RequestParam String endDate) {
        return ResponseEntity.ok(chatService.analyzeMessagePatterns(roomId, startDate, endDate));
    }

    @GetMapping("/room/{roomId}/user-stats")
    public ResponseEntity<List<Map<String, Object>>> getUserMessageStats(
            @PathVariable Long roomId) {
        return ResponseEntity.ok(chatService.getUserMessageStats(roomId));
    }

    // 활동 로그
    @PostMapping("/room/{roomId}/activity")
    public ResponseEntity<Void> logRoomActivity(
            @PathVariable Long roomId,
            @RequestParam Long userId,
            @RequestParam String activityType,
            @RequestParam String activityDetails) {
        chatService.logRoomActivity(roomId, userId, activityType, activityDetails);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/room/{roomId}/activity-logs")
    public ResponseEntity<List<Map<String, Object>>> getRoomActivityLogs(
            @PathVariable Long roomId,
            @RequestParam(defaultValue = "0") int offset,
            @RequestParam(defaultValue = "20") int limit) {
        return ResponseEntity.ok(chatService.getRoomActivityLogs(roomId, offset, limit));
    }

    // 채팅방 설정
    @PostMapping("/room/{roomId}/settings")
    public ResponseEntity<Void> setRoomSetting(
            @PathVariable Long roomId,
            @RequestParam String settingKey,
            @RequestParam String settingValue,
            @RequestParam Long createdBy) {
        chatService.setRoomSetting(roomId, settingKey, settingValue, createdBy);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/room/{roomId}/settings")
    public ResponseEntity<Void> updateRoomSetting(
            @PathVariable Long roomId,
            @RequestParam String settingKey,
            @RequestParam String settingValue) {
        chatService.updateRoomSetting(roomId, settingKey, settingValue);
        return ResponseEntity.ok().build();
    }

    // API 메서드 제거 - 페이지용 메서드만 사용

    // 채팅방 템플릿
    @PostMapping("/templates")
    public ResponseEntity<Void> createRoomTemplate(
            @RequestParam String templateName,
            @RequestParam String templateDescription,
            @RequestParam String roomType,
            @RequestBody Map<String, Object> defaultSettings,
            @RequestParam Long createdBy) {
        chatService.createRoomTemplate(templateName, templateDescription, roomType, defaultSettings, createdBy);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/templates")
    public ResponseEntity<List<Map<String, Object>>> getRoomTemplates(
            @RequestParam String roomType) {
        return ResponseEntity.ok(chatService.getRoomTemplates(roomType));
    }

    @GetMapping("/templates/{templateId}")
    public ResponseEntity<Map<String, Object>> getRoomTemplate(
            @PathVariable Long templateId) {
        return ResponseEntity.ok(chatService.getRoomTemplate(templateId));
    }

    @PostMapping("/rooms/from-template")
    public ResponseEntity<Map<String, Long>> createRoomFromTemplate(
            @RequestParam Long templateId,
            @RequestParam String roomName,
            @RequestParam String roomDescription,
            @RequestParam Long createdBy) {
        Long roomId = chatService.createRoomFromTemplate(templateId, roomName, roomDescription, createdBy);
        Map<String, Long> result = new HashMap<>();
        result.put("roomId", roomId);
        return ResponseEntity.ok(result);
    }

    // 메시지 필터링
    @GetMapping("/room/{roomId}/messages/filter")
    public ResponseEntity<List<ChatMessageDTO>> filterMessages(
            @PathVariable Long roomId,
            @RequestParam(required = false) String messageType,
            @RequestParam(required = false) Long senderId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(required = false) Boolean hasFile,
            @RequestParam(required = false) Boolean isPinned,
            @RequestParam(defaultValue = "0") int offset,
            @RequestParam(defaultValue = "20") int limit) {
        return ResponseEntity.ok(chatService.filterMessages(roomId, messageType, senderId,
                                                          startDate, endDate, hasFile,
                                                          isPinned, offset, limit));
    }

    // 참여자 관리
    @PutMapping("/room/{roomId}/participant/{userId}/role")
    public ResponseEntity<Void> updateParticipantRole(
            @PathVariable Long roomId,
            @PathVariable Long userId,
            @RequestParam String role) {
        chatService.updateParticipantRole(roomId, userId, role);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/room/{roomId}/participant-roles")
    public ResponseEntity<List<Map<String, Object>>> getParticipantRoles(
            @PathVariable Long roomId) {
        return ResponseEntity.ok(chatService.getParticipantRoles(roomId));
    }

    @GetMapping("/room/{roomId}/participants/role/{role}")
    public ResponseEntity<List<ChatParticipantDTO>> getParticipantsByRole(
            @PathVariable Long roomId,
            @PathVariable String role) {
        return ResponseEntity.ok(chatService.getParticipantsByRole(roomId, role));
    }

    // 알림 설정
    @PutMapping("/room/{roomId}/notifications/preferences")
    public ResponseEntity<Void> updateNotificationPreferences(
            @PathVariable Long roomId,
            @RequestParam Long userId,
            @RequestParam boolean emailNotifications,
            @RequestParam boolean pushNotifications,
            @RequestParam boolean desktopNotifications,
            @RequestParam String notificationSound) {
        chatService.updateNotificationPreferences(roomId, userId, emailNotifications,
                                                pushNotifications, desktopNotifications,
                                                notificationSound);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/room/{roomId}/notifications/preferences")
    public ResponseEntity<Map<String, Object>> getNotificationPreferences(
            @PathVariable Long roomId,
            @RequestParam Long userId) {
        return ResponseEntity.ok(chatService.getNotificationPreferences(roomId, userId));
    }

    // 메시지 포맷팅
    @PutMapping("/message/{messageId}/format")
    public ResponseEntity<Void> updateMessageFormat(
            @PathVariable Long messageId,
            @RequestParam String messageFormat,
            @RequestParam String formattedMessage) {
        chatService.updateMessageFormat(messageId, messageFormat, formattedMessage);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/room/{roomId}/message-formats")
    public ResponseEntity<List<Map<String, Object>>> getMessageFormats(
            @PathVariable Long roomId,
            @RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(chatService.getMessageFormats(roomId, limit));
    }

    @GetMapping("/room/{roomId}/message-format-stats")
    public ResponseEntity<List<Map<String, Object>>> getMessageFormatStats(
            @PathVariable Long roomId) {
        return ResponseEntity.ok(chatService.getMessageFormatStats(roomId));
    }

    @GetMapping("/chat/rooms")
    public String chatRoomList(Model model) {
        List<ChatDTO> rooms = chatService.getAllChatRooms();
        model.addAttribute("rooms", rooms);
        return "chat/chatRoomList";
    }

    @GetMapping({"/load", "/load/{jspName}"})
    public String loadJsp(@PathVariable(required = false) String jspName, Model model, HttpSession session) {
        if (jspName == null || jspName.isEmpty()) {
            return "chat/main";
        }
        
        // 로그인 사용자 정보 추가
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser != null) {
            model.addAttribute("user", loginUser);
        }
        
        // 확장자 제거
        if (jspName.endsWith(".jsp")) {
            jspName = jspName.substring(0, jspName.length() - 4);
        }
        return "chat/" + jspName;
    }

    // 채팅방 설정 페이지
    @GetMapping("/room/{roomId}/settings")
    public String showChatRoomSettings(@PathVariable Long roomId, Model model, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        ChatDTO chatRoom = chatService.getChatRoom(roomId);
        model.addAttribute("chatRoom", chatRoom);
        model.addAttribute("user", loginUser);
        return "chat/chatRoomSettings";
    }
    
    // 메시지 검색 페이지
    @GetMapping("/room/{roomId}/search")
    public String showMessageSearch(@PathVariable Long roomId, Model model, HttpSession session,
                                   @RequestParam(required = false) String keyword,
                                   @RequestParam(required = false) String date,
                                   @RequestParam(required = false) String user,
                                   @RequestParam(defaultValue = "1") int page) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        ChatDTO chatRoom = chatService.getChatRoom(roomId);
        model.addAttribute("chatRoom", chatRoom);
        model.addAttribute("user", loginUser);
        
        // 검색 결과가 있으면 추가
        if (keyword != null && !keyword.isEmpty()) {
            List<ChatMessageDTO> messages = chatService.searchChatMessages(roomId, keyword, (page-1)*20, 20);
            model.addAttribute("messages", messages);
            model.addAttribute("currentPage", page);
            model.addAttribute("totalPages", (messages.size() + 19) / 20); // 간단한 페이지 계산
        }
        
        return "chat/chatMessageSearch";
    }
    
    // 참여자 관리 페이지
    @GetMapping("/room/{roomId}/participants")
    public String showParticipants(@PathVariable Long roomId, Model model, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        ChatDTO chatRoom = chatService.getChatRoom(roomId);
        List<ChatParticipantDTO> participants = chatService.getParticipants(roomId);
        
        model.addAttribute("chatRoom", chatRoom);
        model.addAttribute("participants", participants);
        model.addAttribute("participantCount", participants.size());
        model.addAttribute("user", loginUser);
        
        // 현재 사용자가 관리자인지 확인
        boolean isRoomAdmin = participants.stream()
            .anyMatch(p -> p.getUserId().equals(loginUser.getId()) && Boolean.TRUE.equals(p.getIsAdmin()));
        model.addAttribute("isRoomAdmin", isRoomAdmin);
        
        return "chat/chatParticipants";
    }
    
    // 참여자 목록 JSON API (실시간 업데이트용)
    @GetMapping("/room/{roomId}/participants/list")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getParticipantsList(@PathVariable Long roomId, HttpSession session) {
        List<ChatParticipant> participants = chatService.getRoomParticipants(roomId);
        List<Map<String, Object>> participantsWithStatus = new ArrayList<>();
        
        // 현재 로그인한 사용자 ID 가져오기
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        Long currentUserId = (loginUser != null) ? loginUser.getId() : null;
        
        for (ChatParticipant participant : participants) {
            Map<String, Object> participantData = new HashMap<>();
            // id 필드 제거됨
            participantData.put("roomId", participant.getRoomId());
            participantData.put("userId", participant.getUserId());
            participantData.put("nickname", participant.getNickname());
            participantData.put("isAdmin", participant.getIsAdmin());
            participantData.put("joinedAt", participant.getJoinedAt());
            participantData.put("lastReadAt", participant.getLastReadAt());
            participantData.put("notificationsEnabled", participant.getNotificationsEnabled());
            
            // 온라인 상태 - 현재 로그인한 사용자만 온라인으로 표시
            boolean isOnline = (currentUserId != null && currentUserId.equals(participant.getUserId()));
            participantData.put("isOnline", isOnline);
            
            System.out.println("참여자: " + participant.getNickname() + " (ID: " + participant.getUserId() + ") - 온라인: " + isOnline + " (현재 사용자 ID: " + currentUserId + ")");
            
            participantsWithStatus.add(participantData);
        }
        
        return ResponseEntity.ok(participantsWithStatus);
    }
    
    // 현재 사용자를 참여자로 추가하는 API
    @PostMapping("/room/{roomId}/participants/add-current")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addCurrentUserAsParticipant(@PathVariable Long roomId, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        Map<String, Object> response = new HashMap<>();
        
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.ok(response);
        }
        
        try {
            // 이미 참여자인지 확인
            if (!chatService.isParticipantExists(roomId, loginUser.getId())) {
                // 사용자 표시명 생성
                String displayName = getUserDisplayName(loginUser);
                
                ChatParticipantDTO participant = new ChatParticipantDTO();
                participant.setRoomId(roomId);
                participant.setUserId(loginUser.getId());
                participant.setNickname(displayName);
                participant.setIsAdmin(false);
                participant.setJoinedAt(LocalDateTime.now());
        
                chatService.addParticipant(participant);
                response.put("success", true);
                response.put("message", "참여자로 추가되었습니다.");
            } else {
                response.put("success", true);
                response.put("message", "이미 참여 중입니다.");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "참여자 추가 실패: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    // 사용자 표시명 생성 헬퍼 메서드
    private String getUserDisplayName(AuthDto user) {
        if (user.getStudentProfile() != null) {
            return user.getName() + "/" + user.getStudentProfile().getStudentId();
        } else if (user.getProfessorProfile() != null) {
            return user.getName() + "/" + user.getProfessorProfile().getProfessorId();
        } else if (user.getStaffProfile() != null) {
            return user.getName() + "/" + user.getStaffProfile().getStaffId();
        } else if (user.getAssistantProfile() != null) {
            return user.getName() + "/" + user.getAssistantProfile().getAssistantId();
        } else {
            return user.getName();
        }
    }
    
    // 알림 설정 페이지
    @GetMapping("/notifications/settings")
    public String showNotificationSettings(Model model, HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/auth/login";
        }
        
        // 사용자의 실제 알림 설정 조회
        Map<String, Object> settings = new HashMap<>();
        try {
            System.out.println("=== 사용자 알림 설정 조회 시작 ===");
            System.out.println("사용자 ID: " + loginUser.getId());
            
            // 전체 알림 설정 조회 (user_notification_settings 테이블에서)
            Map<String, Object> userSettings = chatService.getUserNotificationSettings(loginUser.getId());
            System.out.println("데이터베이스에서 조회한 설정: " + userSettings);
            
            if (userSettings != null) {
                // 데이터베이스에서 조회한 값들을 Boolean으로 변환
                settings.put("enableNotifications", convertToBoolean(userSettings.get("enableNotifications")));
                settings.put("soundEnabled", convertToBoolean(userSettings.get("soundEnabled")));
                settings.put("desktopNotifications", convertToBoolean(userSettings.get("desktopNotifications")));
                settings.put("doNotDisturbStart", convertToString(userSettings.get("doNotDisturbStart")));
                settings.put("doNotDisturbEnd", convertToString(userSettings.get("doNotDisturbEnd")));
                System.out.println("✅ 데이터베이스 설정 적용됨");
            } else {
                // 설정이 없으면 기본값 사용
        settings.put("enableNotifications", true);
        settings.put("soundEnabled", true);
        settings.put("desktopNotifications", false);
        settings.put("doNotDisturbStart", "22:00");
        settings.put("doNotDisturbEnd", "08:00");
                System.out.println("⚠️ 데이터베이스에 설정이 없어서 기본값 사용");
            }
            
            System.out.println("최종 설정값: " + settings);
        } catch (Exception e) {
            System.err.println("❌ 사용자 알림 설정 조회 실패: " + e.getMessage() + 
                             " [" + e.getClass().getSimpleName() + "]");
            // 기본값 사용
            settings.put("enableNotifications", true);
            settings.put("soundEnabled", true);
            settings.put("desktopNotifications", false);
            settings.put("doNotDisturbStart", "22:00");
            settings.put("doNotDisturbEnd", "08:00");
            System.out.println("❌ 조회 실패로 기본값 사용");
        }
        
        // 채팅방별 설정 조회 (실제 알림 설정 상태 포함)
        List<ChatDTO> userRooms = chatService.getAllChatRooms();
        
        // 각 채팅방의 현재 알림 설정 상태 조회
        Map<Long, Boolean> roomNotificationSettings = new HashMap<>();
        System.out.println("=== 채팅방별 알림 설정 조회 시작 ===");
        
        for (ChatDTO room : userRooms) {
            try {
                System.out.println("채팅방 " + room.getRoomId() + " (" + room.getName() + ") 알림 설정 조회 중...");
                Map<String, Object> roomSettings = chatService.getRoomNotificationSettings(room.getRoomId(), loginUser.getId());
                System.out.println("채팅방 " + room.getRoomId() + " 조회 결과: " + roomSettings);
                
                if (roomSettings != null) {
                    Object enabled = roomSettings.get("notifications_enabled");
                    Boolean notificationEnabled = convertToBoolean(enabled);
                    roomNotificationSettings.put(room.getRoomId(), notificationEnabled);
                    System.out.println("✅ 채팅방 " + room.getRoomId() + " 설정 적용: " + notificationEnabled);
                } else {
                    roomNotificationSettings.put(room.getRoomId(), true); // 기본값: 알림 켜짐
                    System.out.println("⚠️ 채팅방 " + room.getRoomId() + " 설정 없음 -> 기본값(true) 사용");
                }
            } catch (Exception e) {
                System.err.println("❌ 채팅방 " + room.getRoomId() + " 알림 설정 조회 실패: " + e.getMessage() + 
                                 " [" + e.getClass().getSimpleName() + "]");
                roomNotificationSettings.put(room.getRoomId(), true); // 기본값
            }
        }
        
        System.out.println("=== 최종 채팅방별 알림 설정 ===");
        for (Map.Entry<Long, Boolean> entry : roomNotificationSettings.entrySet()) {
            System.out.println("채팅방 " + entry.getKey() + ": " + entry.getValue());
        }
        
        model.addAttribute("settings", settings);
        model.addAttribute("roomSettings", userRooms);
        model.addAttribute("roomNotificationSettings", roomNotificationSettings);
        model.addAttribute("user", loginUser);
        
        return "chat/chatNotificationSettings";
    }

    // 알림 설정 저장
    @PostMapping("/settings/notifications")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveNotificationSettings(
            @RequestBody Map<String, Object> settings, 
            HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        System.out.println("=== 알림 설정 저장 요청 시작 ===");
        System.out.println("받은 설정 데이터: " + settings);
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            System.out.println("오류: 로그인 사용자 없음");
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.ok(response);
        }
        
        System.out.println("로그인 사용자 ID: " + loginUser.getId());
        
        try {
            // 알림 설정 저장 로직
            Long userId = loginUser.getId();
            
            // 일반 알림 설정 - 안전한 타입 변환
            Boolean enableNotifications = convertToBoolean(settings.get("enableNotifications"));
            Boolean soundEnabled = convertToBoolean(settings.get("soundEnabled"));
            Boolean desktopNotifications = convertToBoolean(settings.get("desktopNotifications"));
            String doNotDisturbStart = convertToString(settings.get("doNotDisturbStart"));
            String doNotDisturbEnd = convertToString(settings.get("doNotDisturbEnd"));
            
            System.out.println("변환된 설정값:");
            System.out.println("- enableNotifications: " + enableNotifications);
            System.out.println("- soundEnabled: " + soundEnabled);
            System.out.println("- desktopNotifications: " + desktopNotifications);
            System.out.println("- doNotDisturbStart: " + doNotDisturbStart);
            System.out.println("- doNotDisturbEnd: " + doNotDisturbEnd);
            
            // 채팅방별 알림 설정
            @SuppressWarnings("unchecked")
            Map<String, Object> roomNotifications = (Map<String, Object>) settings.get("roomNotifications");
            System.out.println("채팅방별 알림 설정: " + roomNotifications);
            
            // 데이터베이스에 설정 저장
            try {
                System.out.println("사용자 전체 알림 설정 저장 시도...");
                chatService.saveUserNotificationSettings(userId, enableNotifications, soundEnabled, 
                        desktopNotifications, doNotDisturbStart, doNotDisturbEnd);
                System.out.println("✅ 사용자 전체 알림 설정 저장 성공");
            } catch (Exception e) {
                System.err.println("❌ 사용자 알림 설정 저장 실패: " + e.getMessage() + 
                                 " [" + e.getClass().getSimpleName() + "]");
            }
            
            // 채팅방별 알림 설정 저장
            if (roomNotifications != null) {
                System.out.println("채팅방별 알림 설정 저장 시작...");
                int savedCount = 0;
                for (Map.Entry<String, Object> entry : roomNotifications.entrySet()) {
                    try {
                        Long roomId = Long.valueOf(entry.getKey());
                        Boolean enabled = convertToBoolean(entry.getValue());
                        System.out.println("채팅방 " + roomId + " 알림 설정: " + enabled);
                        
                        // 사용자가 채팅방 참여자인지 확인하고, 없으면 추가
                        boolean isParticipant = chatService.isParticipantExists(roomId, userId);
                        if (!isParticipant) {
                            System.out.println("⚠️ 사용자가 채팅방 " + roomId + " 참여자가 아님. 자동 추가 중...");
                            // 참여자로 자동 추가 (기본 닉네임 사용)
                            chatService.addParticipant(roomId, userId, loginUser.getName());
                            System.out.println("✅ 사용자를 채팅방 " + roomId + " 참여자로 추가 완료");
                        }
                        
                        // 알림 설정 저장
                        chatService.updateNotificationSettings(roomId, userId, enabled, "all");
                        savedCount++;
                        System.out.println("✅ 채팅방 " + roomId + " 설정 저장 완료");
                    } catch (NumberFormatException e) {
                        System.err.println("❌ 채팅방 " + entry.getKey() + " ID 형식 오류: " + e.getMessage());
                    } catch (ClassCastException e) {
                        System.err.println("❌ 채팅방 " + entry.getKey() + " 데이터 형식 오류: " + e.getMessage());
                    } catch (RuntimeException e) {
                        System.err.println("❌ 채팅방 " + entry.getKey() + " 설정 저장 실패: " + e.getMessage() + 
                                         " [" + e.getClass().getSimpleName() + "]");
                    } catch (Exception e) {
                        System.err.println("❌ 채팅방 " + entry.getKey() + " 예상치 못한 오류: " + e.getMessage() + 
                                         " [" + e.getClass().getSimpleName() + "]");
                    }
                }
                System.out.println("채팅방별 알림 설정 저장 완료: " + savedCount + "개 저장됨");
            }
            
            response.put("success", true);
            response.put("message", "알림 설정이 저장되었습니다.");
            System.out.println("✅ 전체 저장 프로세스 완료");
            
        } catch (NumberFormatException e) {
            System.err.println("잘못된 숫자 형식: " + e.getMessage() + 
                             " [" + e.getClass().getSimpleName() + "]");
            response.put("success", false);
            response.put("message", "잘못된 채팅방 ID 형식입니다.");
        } catch (ClassCastException e) {
            System.err.println("잘못된 데이터 형식: " + e.getMessage() + 
                             " [" + e.getClass().getSimpleName() + "]");
            response.put("success", false);
            response.put("message", "잘못된 데이터 형식입니다.");
        } catch (IllegalArgumentException e) {
            System.err.println("잘못된 인수: " + e.getMessage() + 
                             " [" + e.getClass().getSimpleName() + "]");
            response.put("success", false);
            response.put("message", "잘못된 요청 데이터입니다: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("알림 설정 저장 중 예상치 못한 오류: " + e.getMessage() + 
                             " [" + e.getClass().getSimpleName() + "]");
            response.put("success", false);
            response.put("message", "시스템 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
        }
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/rooms/{roomId}")
    @ResponseBody
    public ChatDTO getChatRoomJson(@PathVariable Long roomId) {
        return chatService.getChatRoom(roomId);
    }
    
    @PostMapping("/admin/clear-online-users")
    @ResponseBody
    public String clearAllOnlineUsers() {
        onlineUserService.clearAllOnlineUsers();
        return "모든 온라인 사용자 상태가 초기화되었습니다.";
    }
    
    @PostMapping("/admin/force-offline/{userId}")
    @ResponseBody
    public String forceUserOffline(@PathVariable Long userId) {
        onlineUserService.setUserOffline(userId);
        return userId + " 사용자를 오프라인으로 설정했습니다.";
    }
    
    @GetMapping("/admin/debug-online-users")
    @ResponseBody
    public String debugOnlineUsers() {
        Set<Long> onlineUserIds = onlineUserService.getOnlineUserIds();
        return "현재 온라인 사용자 ID 목록: " + onlineUserIds + " (총 " + onlineUserIds.size() + "명)";
    }
    
    @PostMapping("/admin/force-reset-online")
    @ResponseBody
    public String forceResetOnlineUsers(HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        String sessionId = session.getId();
        
        if (loginUser != null) {
            Long currentUserId = loginUser.getId();
            onlineUserService.forceResetWithUser(currentUserId, sessionId);
            return "온라인 상태를 강제 리셋했습니다. 현재 사용자(" + currentUserId + ")만 온라인으로 설정됨.";
        } else {
            onlineUserService.clearAllOnlineUsers();
            return "온라인 상태를 모두 초기화했습니다. (로그인 사용자 없음)";
        }
    }
    
    @PostMapping("/user/set-online")
    @ResponseBody
    public String setCurrentUserOnline(HttpSession session) {
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser != null) {
            onlineUserService.setUserOnline(loginUser.getId(), session.getId());
            return "현재 사용자(" + loginUser.getName() + ", ID: " + loginUser.getId() + ")를 온라인으로 설정했습니다.";
        } else {
            return "로그인 사용자가 없습니다.";
        }
    }
    
    // ===== 사용자 상태 관리 API =====
    
    /**
     * 하트비트 업데이트 - 클라이언트에서 주기적으로 호출
     */
    @PostMapping("/heartbeat")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateHeartbeat(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.ok(response);
        }
        
        try {
            userStatusService.updateHeartbeat(loginUser.getId());
            response.put("success", true);
            response.put("timestamp", LocalDateTime.now());
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "하트비트 업데이트 실패: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 사용자 상태 변경
     */
    @PostMapping("/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateUserStatus(
            @RequestParam String status,
            @RequestParam(required = false) String statusMessage,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.ok(response);
        }
        
        try {
            userStatusService.updateUserStatus(loginUser.getId(), status, statusMessage);
            response.put("success", true);
            response.put("status", status);
            response.put("statusMessage", statusMessage);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "상태 업데이트 실패: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 사용자 상태 조회
     */
    @GetMapping("/status/{userId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getUserStatus(@PathVariable Long userId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            UserStatus userStatus = userStatusService.getUserStatus(userId);
            response.put("success", true);
            response.put("userId", userStatus.getUserId());
            response.put("status", userStatus.getStatus());
            response.put("statusMessage", userStatus.getStatusMessage());
            response.put("lastSeen", userStatus.getLastSeen());
            response.put("lastSeenText", userStatusService.getLastSeenText(userStatus));
            response.put("isOnline", userStatusService.isUserOnline(userId));
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "상태 조회 실패: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 온라인 사용자 목록 조회
     */
    @GetMapping("/online-users")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getOnlineUsers() {
        List<Map<String, Object>> onlineUsers = new ArrayList<>();
        
        try {
            List<UserStatus> users = userStatusService.getOnlineUsers();
            for (UserStatus user : users) {
                Map<String, Object> userInfo = new HashMap<>();
                userInfo.put("userId", user.getUserId());
                userInfo.put("status", user.getStatus());
                userInfo.put("statusMessage", user.getStatusMessage());
                userInfo.put("lastSeen", user.getLastSeen());
                userInfo.put("lastSeenText", userStatusService.getLastSeenText(user));
                onlineUsers.add(userInfo);
            }
        } catch (Exception e) {
            System.err.println("온라인 사용자 조회 실패: " + e.getMessage());
        }
        
        return ResponseEntity.ok(onlineUsers);
    }
    
    /**
     * 상태 메시지만 업데이트
     */
    @PostMapping("/status/message")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateStatusMessage(
            @RequestParam String statusMessage,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.ok(response);
        }
        
        try {
            userStatusService.updateStatusMessage(loginUser.getId(), statusMessage);
            response.put("success", true);
            response.put("statusMessage", statusMessage);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "상태 메시지 업데이트 실패: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 개선된 참여자 목록 (상태 정보 포함)
     */
    @GetMapping("/room/{roomId}/participants/enhanced")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getEnhancedParticipantsList(@PathVariable Long roomId, HttpSession session) {
        List<ChatParticipant> participants = chatService.getRoomParticipants(roomId);
        List<Map<String, Object>> enhancedParticipants = new ArrayList<>();
        
        // 참여자들의 사용자 ID 수집
        List<Long> userIds = participants.stream()
                .map(ChatParticipant::getUserId)
                .collect(java.util.stream.Collectors.toList());
        
        // 사용자 상태 정보 일괄 조회
        Map<Long, UserStatus> userStatuses = userStatusService.getUserStatuses(userIds);
        
        for (ChatParticipant participant : participants) {
            Map<String, Object> participantData = new HashMap<>();
            participantData.put("roomId", participant.getRoomId());
            participantData.put("userId", participant.getUserId());
            participantData.put("nickname", participant.getNickname());
            participantData.put("isAdmin", participant.getIsAdmin());
            participantData.put("joinedAt", participant.getJoinedAt());
            participantData.put("lastReadAt", participant.getLastReadAt());
            participantData.put("notificationsEnabled", participant.getNotificationsEnabled());
            
            // 사용자 상태 정보 추가
            UserStatus userStatus = userStatuses.get(participant.getUserId());
            if (userStatus != null) {
                participantData.put("status", userStatus.getStatus());
                participantData.put("statusMessage", userStatus.getStatusMessage());
                participantData.put("lastSeen", userStatus.getLastSeen());
                participantData.put("lastSeenText", userStatusService.getLastSeenText(userStatus));
                participantData.put("isOnline", userStatusService.isUserOnline(participant.getUserId()));
            } else {
                participantData.put("status", UserStatus.STATUS_OFFLINE);
                participantData.put("statusMessage", null);
                participantData.put("lastSeen", null);
                participantData.put("lastSeenText", "접속 기록 없음");
                participantData.put("isOnline", false);
            }
            
            enhancedParticipants.add(participantData);
        }
        
        return ResponseEntity.ok(enhancedParticipants);
    }
    
    // chat_reads 테이블을 활용한 새로운 읽음 상태 API들
    
    /**
     * 특정 메시지의 읽음 상태 조회
     */
    @GetMapping("/message/{messageId}/read-status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getMessageReadStatus(@PathVariable Long messageId) {
        Map<String, Object> readStatus = chatService.getMessageReadStatus(messageId);
        return ResponseEntity.ok(readStatus);
    }
    
    /**
     * 채팅방의 모든 메시지를 읽음으로 표시
     */
    @PostMapping("/room/{roomId}/mark-all-read")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> markAllMessagesAsRead(
            @PathVariable Long roomId,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.ok(response);
        }
        
        try {
            chatService.markAllMessagesAsRead(roomId, loginUser.getId());
            response.put("success", true);
            response.put("message", "모든 메시지를 읽음으로 표시했습니다.");
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "읽음 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 특정 메시지를 읽은 사용자 목록 조회
     */
    @GetMapping("/message/{messageId}/readers")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getMessageReaders(@PathVariable Long messageId) {
        List<Map<String, Object>> readers = chatService.getMessageReaders(messageId);
        return ResponseEntity.ok(readers);
    }
    
    /**
     * 채팅방의 읽지 않은 메시지 수 조회
     */
    @GetMapping("/room/{roomId}/unread-count")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getUnreadMessageCount(
            @PathVariable Long roomId,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.ok(response);
        }
        
        try {
            int unreadCount = chatService.getUnreadMessageCount(roomId, loginUser.getId());
            response.put("success", true);
            response.put("unreadCount", unreadCount);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "읽지 않은 메시지 수 조회 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * 채팅방에서 읽지 않은 메시지가 있는 사용자 목록 조회
     */
    @GetMapping("/room/{roomId}/unread-users")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> getUsersWithUnreadMessages(@PathVariable Long roomId) {
        List<Map<String, Object>> usersWithUnread = chatService.getUsersWithUnreadMessages(roomId);
        return ResponseEntity.ok(usersWithUnread);
    }
    
    @GetMapping("/debug/projects")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getAvailableProjects(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.ok(response);
            }
            
            // 사용자가 참여한 프로젝트 목록 조회
            List<ProjectDto> projects = projectService.getProjectsForUser(loginUser.getId());
            
            response.put("success", true);
            response.put("userId", loginUser.getId());
            response.put("projects", projects);
            response.put("message", "총 " + projects.size() + "개의 프로젝트가 있습니다.");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("프로젝트 목록 조회 중 오류: " + e.getMessage());
            response.put("success", false);
            response.put("message", "프로젝트 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }
    
    @GetMapping("/debug/all-projects")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getAllProjectsDebug() {
        Map<String, Object> response = new HashMap<>();
        try {
            System.out.println("=== 전체 프로젝트 목록 조회 시작 ===");
            
            // 전체 프로젝트 목록 조회
            List<ProjectDto> allProjects = projectService.getAllProjects();
            System.out.println("데이터베이스에서 조회된 전체 프로젝트 수: " + (allProjects != null ? allProjects.size() : "null"));
            
            if (allProjects != null) {
                for (ProjectDto project : allProjects) {
                    System.out.println("프로젝트 ID: " + project.getId() + ", 제목: " + project.getTitle() + ", 상태: " + project.getStatus());
                }
            }
            
            response.put("success", true);
            response.put("totalProjects", allProjects != null ? allProjects.size() : 0);
            response.put("projects", allProjects);
            response.put("message", "전체 프로젝트 목록을 조회했습니다.");
            
            // 특정 ID로 프로젝트 조회도 테스트
            if (allProjects != null && !allProjects.isEmpty()) {
                Long firstProjectId = allProjects.get(0).getId();
                System.out.println("첫 번째 프로젝트 ID " + firstProjectId + "로 개별 조회 테스트...");
                ProjectDto testProject = projectService.getProjectById(firstProjectId);
                System.out.println("개별 조회 결과: " + (testProject != null ? testProject.getTitle() : "null"));
                response.put("firstProjectTest", testProject);
            }
            
            System.out.println("=== 전체 프로젝트 목록 조회 완료 ===");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("전체 프로젝트 목록 조회 중 오류: " + e.getMessage());
            response.put("success", false);
            response.put("message", "전체 프로젝트 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }
    
    @PostMapping("/debug/create-test-project")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> createTestProject(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.ok(response);
            }
            
            System.out.println("=== 테스트용 프로젝트 생성 시작 ===");
            
            // 테스트용 프로젝트 생성
            ProjectCreationDto projectCreationDto = new ProjectCreationDto();
            projectCreationDto.setProjectName("채팅 테스트 프로젝트");
            projectCreationDto.setProjectDescription("채팅방 생성 테스트를 위한 프로젝트입니다.");
            projectCreationDto.setTeamLeaderUsername(loginUser.getUsername());
            projectCreationDto.setTeamMemberUsernames(""); // 팀원 없이 생성
            
            Long projectId = projectService.createProject(projectCreationDto, loginUser.getId());
            
            System.out.println("테스트 프로젝트 생성 완료! ID: " + projectId);
            
            // 생성된 프로젝트 정보 조회
            ProjectDto createdProject = projectService.getProjectById(projectId);
            
            response.put("success", true);
            response.put("projectId", projectId);
            response.put("project", createdProject);
            response.put("message", "테스트용 프로젝트가 생성되었습니다. 이제 이 ID로 채팅방을 생성할 수 있습니다.");
            
            System.out.println("=== 테스트용 프로젝트 생성 완료 ===");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("테스트 프로젝트 생성 중 오류: " + e.getMessage());
            response.put("success", false);
            response.put("message", "테스트 프로젝트 생성 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }
    
    @PostMapping("/auto-create-main-room")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> autoCreateMainChatRoom(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.ok(response);
            }
            
            System.out.println("=== 자동 메인 채팅방 생성 시작 ===");
            System.out.println("사용자: " + loginUser.getName() + " (ID: " + loginUser.getId() + ")");
            
            // 사용자가 참여한 프로젝트 목록 조회
            List<ProjectDto> userProjects = projectService.getProjectsForUser(loginUser.getId());
            System.out.println("사용자 참여 프로젝트 수: " + userProjects.size());
            
            if (userProjects.isEmpty()) {
                response.put("success", false);
                response.put("message", "참여 중인 프로젝트가 없습니다. 먼저 프로젝트를 생성하거나 초대를 수락하세요.");
                return ResponseEntity.ok(response);
            }
            
            // 첫 번째 프로젝트에 대해 메인 채팅방 생성
            ProjectDto firstProject = userProjects.get(0);
            Long projectId = firstProject.getId();
            
            System.out.println("메인 채팅방 생성 대상 프로젝트: ID=" + projectId + ", 제목=" + firstProject.getTitle());
            
            boolean created = chatService.createMainChatRoomIfNotExists(projectId, loginUser.getId());
            
            if (created) {
                System.out.println("메인 채팅방 생성 완료!");
                response.put("success", true);
                response.put("projectId", projectId);
                response.put("projectTitle", firstProject.getTitle());
                response.put("message", "메인 채팅방이 생성되었습니다.");
            } else {
                System.out.println("메인 채팅방이 이미 존재함");
                response.put("success", true);
                response.put("projectId", projectId);
                response.put("projectTitle", firstProject.getTitle());
                response.put("message", "메인 채팅방이 이미 존재합니다.");
            }
            
            // 생성된 채팅방 목록도 함께 반환
            response.put("chatRooms", new ArrayList<>());
            
            System.out.println("=== 자동 메인 채팅방 생성 완료 ===");
            return ResponseEntity.ok(response);
            
        } catch (RuntimeException e) {
            System.err.println("메인 채팅방 자동 생성 실패: " + e.getMessage());
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            System.err.println("메인 채팅방 자동 생성 중 예상치 못한 오류: " + e.getMessage());
            response.put("success", false);
            response.put("message", "채팅방 생성 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }
    
    @GetMapping("/debug/all-chat-rooms")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getAllChatRoomsDebug() {
        Map<String, Object> response = new HashMap<>();
        try {
            System.out.println("=== 전체 채팅방 목록 조회 시작 ===");
            
            // 전체 채팅방 목록 조회
            List<ChatDTO> allChatRooms = chatService.getAllChatRooms();
            System.out.println("데이터베이스에서 조회된 전체 채팅방 수: " + (allChatRooms != null ? allChatRooms.size() : "null"));
            
            if (allChatRooms != null) {
                for (ChatDTO chatRoom : allChatRooms) {
                    System.out.println("채팅방 - ID: " + chatRoom.getRoomId() + 
                                     ", 이름: " + chatRoom.getName() + 
                                     ", 프로젝트ID: " + chatRoom.getProjectId() + 
                                     ", 메인여부: " + chatRoom.getIsMain());
                }
            }
            
            response.put("success", true);
            response.put("totalChatRooms", allChatRooms != null ? allChatRooms.size() : 0);
            response.put("chatRooms", allChatRooms);
            response.put("message", "전체 채팅방 목록을 조회했습니다.");
            
            System.out.println("=== 전체 채팅방 목록 조회 완료 ===");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("전체 채팅방 목록 조회 중 오류: " + e.getMessage());
            response.put("success", false);
            response.put("message", "전체 채팅방 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }
    
    @PostMapping("/debug/force-reset-main-room")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> forceResetMainRoom(@RequestParam Long projectId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        try {
            AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.ok(response);
            }
            
            System.out.println("=== 강제 메인 채팅방 리셋 시작 ===");
            System.out.println("프로젝트 ID: " + projectId + ", 사용자 ID: " + loginUser.getId());
            
            // 1. 기존 메인 채팅방이 있다면 삭제 (일단 생략)
            System.out.println("기존 메인 채팅방 상태 무시하고 새로 생성...");
            
            // 2. 새로운 메인 채팅방 생성
            try {
                System.out.println("새 메인 채팅방 생성 시작...");
                
                ChatDTO newMainRoom = new ChatDTO();
                newMainRoom.setName("메인 채팅방 (리셋됨)");
                newMainRoom.setDescription("프로젝트의 메인 채팅방입니다.");
                newMainRoom.setMaxParticipants(50);
                newMainRoom.setIsPrivate(false);
                newMainRoom.setAllowInvite(true);
                newMainRoom.setSaveMessageHistory(true);
                newMainRoom.setIsMain(true);
                newMainRoom.setProjectId(projectId);
                newMainRoom.setCreatedBy(loginUser.getId());
                
                System.out.println("생성할 채팅방 데이터: " + newMainRoom);
                
                // 기존 createChatRoom 메서드 사용 (프로젝트 검증 스킵)
                Map<String, Object> createResult = chatService.createChatRoom(newMainRoom);
                System.out.println("✅ Service로 채팅방 생성 완료!");
                System.out.println("생성 결과: " + createResult);
                
                if ((Boolean) createResult.get("success")) {
                    response.put("success", true);
                    response.put("roomId", createResult.get("roomId"));
                    response.put("projectId", projectId);
                    response.put("message", "메인 채팅방이 강제로 리셋되어 새로 생성되었습니다.");
                } else {
                    response.put("success", false);
                    response.put("message", "채팅방 생성 실패: " + createResult.get("message"));
                    return ResponseEntity.ok(response);
                }

            } catch (Exception e) {
                System.err.println("❌ 새 채팅방 생성 중 오류: " + e.getMessage());
                response.put("success", false);
                response.put("message", "새 채팅방 생성 중 오류: " + e.getMessage());
                return ResponseEntity.ok(response);
            }
            
            System.out.println("=== 강제 메인 채팅방 리셋 완료 ===");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("강제 리셋 중 전체 오류: " + e.getMessage());
            response.put("success", false);
            response.put("message", "메인 채팅방 리셋 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.ok(response);
        }
    }
    
    @PostMapping("/debug/simple-create-room")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> simpleCreateRoom(@RequestParam Long projectId, HttpSession session) {
        System.out.println("=== Simple Create Room API ===");
        System.out.println("ProjectId: " + projectId);
        
        // ChatService의 새로운 simple 메서드 사용
        Map<String, Object> result = chatService.createChatRoomSimple(projectId, "Main Chat - Simple");
        return ResponseEntity.ok(result);
    }
    
    // 안전한 Boolean 변환 헬퍼 메서드
    private Boolean convertToBoolean(Object value) {
        if (value == null) {
            return false;
        }
        if (value instanceof Boolean) {
            return (Boolean) value;
        }
        if (value instanceof Number) {
            return ((Number) value).intValue() != 0;  // 1이면 true, 0이면 false
        }
        if (value instanceof String) {
            String strValue = (String) value;
            return "true".equalsIgnoreCase(strValue) || "on".equalsIgnoreCase(strValue) || "1".equals(strValue);
        }
        return false;
    }

    // 안전한 String 변환 헬퍼 메서드
    private String convertToString(Object value) {
        if (value == null) {
            return null;
        }
        return value.toString();
    }

    /**
     * 읽음 상태 기능 테스트용 엔드포인트
     */
    @GetMapping("/test/read-status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> testReadStatus(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.ok(response);
        }
        
        try {
            // 테스트: 첫 번째 메시지의 읽음 상태 확인
            Map<String, Object> testResult = chatService.getMessageReadStatus(1L);
            
            response.put("success", true);
            response.put("message", "읽음 상태 테스트 성공");
            response.put("testResult", testResult);
            response.put("userId", loginUser.getId());
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "읽음 상태 테스트 실패: " + e.getMessage());
            response.put("error", e.toString());
        }
        
        return ResponseEntity.ok(response);
    }
} 