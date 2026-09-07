package com.example.test.chat;

import java.io.UnsupportedEncodingException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.test.auth.AuthDto;
import com.example.test.notification.NotificationService;
import com.example.test.project.ProjectDao;
import com.example.test.project.ProjectDto;
import com.example.test.project.ProjectMemberDto;
import com.example.test.project.ProjectService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ChatService {

    @Autowired
    private ChatRoomRepository chatRoomRepository;
    
    @Autowired
    private ChatParticipantRepository chatParticipantRepository;
    
    @Autowired
    private ChatMessageRepository chatMessageRepository;
    
    @Autowired
    private ChatInvitationRepository chatInvitationRepository;
    
    @Autowired
    private ChatDAO chatDAO;
    
    @Autowired
    private HttpSession session;
    
    @Autowired
    private NotificationService notificationService;
    
    @Autowired
    private ProjectService projectService;
    
    @Autowired
    private ProjectDao projectDao;
    
    @Transactional(readOnly = true)
    public ChatDTO getChatRoom(Long roomId) {
        return chatDAO.getChatRoom(roomId);
    }
    
    @Transactional(readOnly = true)
    public List<ChatParticipant> getRoomParticipants(Long roomId) {
        return chatParticipantRepository.findByRoomId(roomId);
    }
    
    @Transactional(readOnly = true)
    public List<ChatMessage> getRoomMessages(Long roomId) {
        try {
        return chatMessageRepository.findByRoomIdOrderByCreatedAtDesc(roomId);
        } catch (Exception e) {
            // 임시: MyBatis 매핑 문제로 인한 오류 발생 시 빈 리스트 반환
            System.out.println("ChatMessage 조회 오류 (임시 처리): " + e.getMessage());
            return new ArrayList<>();
        }
    }
    
    @Transactional(readOnly = true)
    public List<ChatMessage> getRoomMessagesWithFiles(Long roomId) {
        System.out.println("=== getRoomMessagesWithFiles 시작 ===");
        System.out.println("roomId: " + roomId);
        
        // 메시지 조회
        List<ChatMessage> messages = chatMessageRepository.findByRoomIdOrderByCreatedAtDesc(roomId);
        System.out.println("조회된 메시지 수: " + messages.size());
        
        if (messages.isEmpty()) {
            return messages;
        }
        
        // 모든 메시지 ID 수집
        List<Long> messageIds = messages.stream()
            .map(ChatMessage::getId)
            .collect(Collectors.toList());
        
        // 배치로 모든 파일 정보 조회
        List<ChatMessageFileDTO> allFiles = chatDAO.getMessageFilesByMessageIds(messageIds);
        System.out.println("조회된 총 파일 수: " + allFiles.size());
        
        // 메시지 ID별로 파일 그룹화
        Map<Long, List<ChatMessageFileDTO>> filesByMessageId = allFiles.stream()
            .collect(Collectors.groupingBy(ChatMessageFileDTO::getMessageId));
        
        // 각 메시지에 파일 정보 설정
        for (ChatMessage message : messages) {
            List<ChatMessageFileDTO> messageFiles = filesByMessageId.getOrDefault(message.getId(), new ArrayList<>());
            message.setFiles(messageFiles);
            System.out.println("메시지 ID " + message.getId() + ": 파일 " + messageFiles.size() + "개");
        }
        
        System.out.println("=== getRoomMessagesWithFiles 완료 ===");
        return messages;
    }
    
    @Transactional
    public void addParticipant(Long roomId, Long userId, String nickname) {
        if (chatParticipantRepository.existsByRoomIdAndUserId(roomId, userId)) {
            throw new RuntimeException("이미 참여 중인 채팅방입니다.");
        }

        ChatParticipant participant = new ChatParticipant();
        participant.setRoomId(roomId);
        participant.setUserId(userId);
        participant.setNickname(nickname);
        participant.setIsAdmin(false);
        participant.setJoinedAt(LocalDateTime.now());
        chatParticipantRepository.insert(participant);
        
        // 참여자 수는 실시간으로 조회됨
    }
    
    @Transactional
    public void removeParticipant(Long roomId, Long userId) {
        chatParticipantRepository.deleteByRoomIdAndUserId(roomId, userId);
    }
    
    @Transactional
    public ChatMessage saveMessage(Long roomId, Long senderId, String content, MessageType messageType) {
        ChatMessage message = new ChatMessage();
        message.setRoomId(roomId);
        message.setUserId(senderId);
        message.setContent(content);
        message.setMessageType(messageType);
        message.setCreatedAt(LocalDateTime.now());
        chatMessageRepository.insert(message);
        return message;
    }
    
    @Transactional
    public boolean createMainChatRoomIfNotExists(Long projectId, Long userId) {
        System.out.println("=== createMainChatRoomIfNotExists DETAILED DEBUG ===");
        System.out.println("Input - projectId: " + projectId + ", userId: " + userId);
        
        // 프로젝트 존재 여부 검증
        if (projectId != null) {
            try {
                System.out.println("Checking project existence... ID: " + projectId);
                ProjectDto project = projectService.getProjectById(projectId);
                System.out.println("Retrieved project: " + project);
                
                if (project == null) {
                    System.err.println("Project not found: ID = " + projectId);
                    throw new RuntimeException("Project does not exist. (ID: " + projectId + ")");
                }
                System.out.println("Project verification success: " + project.getTitle());
            } catch (RuntimeException e) {
                System.err.println("Error during project lookup: " + e.getMessage());
                throw new RuntimeException("Error occurred during project lookup. Please enter correct project ID. (ID: " + projectId + ")", e);
            }
        } else {
            System.err.println("ProjectId is null!");
        }
        
        try {
            System.out.println("Checking main chat room existence...");
            boolean exists = chatRoomRepository.existsByProjectIdAndIsMainTrue(projectId);
            System.out.println("Main chat room exists: " + exists);
            
            if (!exists) {
                System.out.println("Main chat room not found -> Starting new creation");
                
                // 프로젝트 정보 다시 가져오기 (이름 포함하기 위해)
                ProjectDto project = projectService.getProjectById(projectId);
                String projectTitle = (project != null) ? project.getTitle() : "Unknown Project";
                
                // 프로젝트 멤버 수 조회
                List<ProjectMemberDto> projectMembers = projectDao.findMembersByProjectId(projectId);
                int memberCount = (projectMembers != null) ? projectMembers.size() : 1;
                System.out.println("Project member count: " + memberCount);
                
                            ChatRoom chatRoom = new ChatRoom();
                chatRoom.setName(projectTitle + " 메인 채팅방"); // 깔끔한 제목
                chatRoom.setDescription(projectTitle + " 프로젝트의 메인 채팅방입니다. (비공개)"); // 비공개 표시 추가
                chatRoom.setMaxParticipants(memberCount + 5); // 프로젝트 멤버 수 + 여유분 5명
                chatRoom.setIsPrivate(true); // 프로젝트 채팅방은 비공개
            chatRoom.setAllowInvite(true);
            chatRoom.setSaveMessageHistory(true);
            chatRoom.setIsMain(true);
            chatRoom.setProjectId(projectId);
            chatRoom.setCreatedAt(LocalDateTime.now());
            chatRoom.setUpdatedAt(LocalDateTime.now());
                
                System.out.println("Chat room object to create: " + chatRoom);
                System.out.println("Calling chatRoomRepository.insert...");
                
                try {
            chatRoomRepository.insert(chatRoom);
                    System.out.println("SUCCESS: chatRoomRepository.insert completed!");
                    System.out.println("Generated chat room ID: " + chatRoom.getId());
                    
                    // 즉시 다시 확인
                    boolean existsAfterInsert = chatRoomRepository.existsByProjectIdAndIsMainTrue(projectId);
                    System.out.println("Existence check after INSERT: " + existsAfterInsert);
                    
                    if (existsAfterInsert) {
                        System.out.println("SUCCESS: Main chat room successfully created!");
            return true;
                    } else {
                        System.err.println("FAILURE: INSERT was successful but room not found on re-check (transaction issue?)");
                        return false;
                    }
                    
                } catch (Exception insertException) {
                    System.err.println("ERROR during INSERT: " + insertException.getMessage());
                    throw insertException;
                }
            } else {
                System.out.println("Main chat room already exists");
                
                // 실제로 조회해서 확인
                List<ChatRoom> existingRooms = chatRoomRepository.findByProjectId(projectId);
                System.out.println("Actually retrieved chat room count: " + (existingRooms != null ? existingRooms.size() : "null"));
                
                if (existingRooms != null) {
                    for (ChatRoom room : existingRooms) {
                        System.out.println("- Chat room: " + room.getName() + " (ID: " + room.getId() + ", Main: " + room.getIsMain() + ")");
                    }
                }
                
        return false;
            }
            
        } catch (Exception e) {
            System.err.println("ERROR: createMainChatRoomIfNotExists overall error: " + e.getMessage());
            throw e;
        } finally {
            System.out.println("=== createMainChatRoomIfNotExists DEBUG COMPLETED ===");
        }
    }
    
    // 채팅방 목록 조회
    public List<ChatRoom> getChatRooms(Long projectId) {
        return chatRoomRepository.findByProjectId(projectId);
    }
    
    // 메시지 저장
    @Transactional
    public void saveMessage(ChatMessageDTO message) {
        if (message.getSendTime() == null) {
            message.setSendTime(LocalDateTime.now());
        }
        chatDAO.saveChatMessage(message);
        
        // 메시지 저장 후 다른 참여자들에게 알림 생성
        createChatNotifications(message);
    }
    
    /**
     * 채팅 메시지 알림 생성
     */
    @Transactional
    public void createChatNotifications(ChatMessageDTO message) {
        try {
            // 채팅방 참여자 목록 조회
            List<ChatParticipant> participants = chatParticipantRepository.findByRoomId(message.getRoomId());
            
            // 발신자 제외한 참여자들에게 알림 생성
            for (ChatParticipant participant : participants) {
                if (!participant.getUserId().equals(message.getSenderId())) {
                    String senderName = message.getSenderName() != null ? message.getSenderName() : "알 수 없는 사용자";
                    String messageContent = message.getContent();
                    
                    // 메시지가 너무 길면 자르기
                    if (messageContent.length() > 50) {
                        messageContent = messageContent.substring(0, 50) + "...";
                    }
                    
                    notificationService.createChatNotification(
                        participant.getUserId(), 
                        senderName, 
                        messageContent, 
                        message.getRoomId()
                    );
                }
            }
        } catch (Exception e) {
            // 알림 생성 실패해도 메시지 저장은 성공으로 처리
            System.err.println("채팅 알림 생성 실패: " + e.getMessage());
        }
    }
    
    // 메시지 목록 조회
    public List<ChatMessageDTO> getMessages(Long roomId, int offset, int limit) {
        List<ChatMessage> messages = chatMessageRepository.findByRoomIdOrderByCreatedAtDesc(roomId);
        return messages.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    private ChatMessageDTO convertToDTO(ChatMessage message) {
        ChatMessageDTO dto = new ChatMessageDTO();
        dto.setId(message.getId());
        dto.setRoomId(message.getRoomId());
        dto.setSenderId(message.getUserId());
        dto.setContent(message.getContent());
        dto.setMessageType(message.getMessageType());
        dto.setSendTime(message.getCreatedAt());
        return dto;
    }
    
    // 참여자 추가
    @Transactional
    public void addParticipant(ChatParticipantDTO participant) {
        ChatParticipant chatParticipant = new ChatParticipant();
        chatParticipant.setRoomId(participant.getRoomId());
        chatParticipant.setUserId(participant.getUserId());
        chatParticipant.setNickname(participant.getNickname());
        chatParticipant.setIsAdmin(participant.getIsAdmin());
        chatParticipant.setJoinedAt(participant.getJoinedAt());
        chatParticipantRepository.insert(chatParticipant);
    }
    
    // 참여자 목록 조회
    public List<ChatParticipantDTO> getParticipants(Long roomId) {
        List<ChatParticipant> participants = chatParticipantRepository.findByRoomId(roomId);
        return participants.stream()
                .map(this::convertToParticipantDTO)
                .collect(Collectors.toList());
    }
    
    // 참여자 존재 여부 확인
    public boolean isParticipantExists(Long roomId, Long userId) {
        return chatParticipantRepository.existsByRoomIdAndUserId(roomId, userId);
    }
    
    private ChatParticipantDTO convertToParticipantDTO(ChatParticipant participant) {
        ChatParticipantDTO dto = new ChatParticipantDTO();
        // id 필드 제거됨
        dto.setRoomId(participant.getRoomId());
        dto.setUserId(participant.getUserId());
        dto.setNickname(participant.getNickname());
        dto.setIsAdmin(participant.getIsAdmin());
        dto.setJoinedAt(participant.getJoinedAt());
        return dto;
    }
    
    // 마지막 읽은 시간 업데이트
    @Transactional
    public void updateLastReadTime(Long roomId, Long userId) {
        ChatParticipant participant = chatParticipantRepository.findByRoomIdAndUserId(roomId, userId);
        if (participant == null) {
            throw new RuntimeException("참여자를 찾을 수 없습니다.");
        }
        participant.setLastReadAt(LocalDateTime.now());
        chatParticipantRepository.insert(participant);
    }
    
    // 읽지 않은 메시지 수 조회
    public int getUnreadMessageCount(Long roomId, Long userId) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("userId", userId);
        return chatDAO.getUnreadMessageCount(params);
    }
    
    // 채팅방 CRUD
    @Transactional
    public Map<String, Object> createChatRoom(ChatDTO chatDTO) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            System.out.println("=== Creating chat room START ===");
            System.out.println("Request data: " + chatDTO.toString());
            
            // 프로젝트 존재 여부 확인
            ProjectDto project = projectService.getProjectById(chatDTO.getProjectId());
            if (project == null) {
                System.err.println("Project not found: " + chatDTO.getProjectId());
                result.put("success", false);
                result.put("message", "Project not found: " + chatDTO.getProjectId());
                return result;
            }
            
            System.out.println("Project verified: " + project.getTitle());
            
            // 채팅방 생성
            System.out.println("Calling chatDAO.createChatRoom...");
        chatDAO.createChatRoom(chatDTO);
            System.out.println("Generated roomId: " + chatDTO.getRoomId());
            
            if (chatDTO.getRoomId() != null) {
                // 생성자를 참여자로 추가
                ChatParticipantDTO participant = new ChatParticipantDTO();
                participant.setRoomId(chatDTO.getRoomId());
                participant.setUserId(chatDTO.getCreatedBy());
                participant.setUserName((String) session.getAttribute("name"));
                
                System.out.println("Adding creator as participant...");
                chatDAO.addChatParticipant(participant);
                
                System.out.println("=== Chat room created successfully ===");
                result.put("success", true);
                result.put("message", "Chat room created successfully");
                result.put("roomId", chatDTO.getRoomId());
                
                // 수동 커밋 시도
                try {
                    System.out.println("Attempting manual commit...");
                    // Spring 트랜잭션이 자동으로 커밋하지만, 확실히 하기 위해 로그 추가
                    System.out.println("Transaction should auto-commit");
                } catch (Exception commitError) {
                    System.err.println("Commit error: " + commitError.getMessage());
                }
                
            } else {
                System.err.println("Failed to create chat room - no rows affected or no roomId");
                result.put("success", false);
                result.put("message", "Failed to create chat room");
            }
            
        } catch (Exception e) {
            System.err.println("Error creating chat room: " + e.getMessage());
            result.put("success", false);
            result.put("message", "Error: " + e.getMessage());
            throw e; // 트랜잭션 롤백을 위해 예외 재발생
        }
        
        return result;
    }
    
    // 트랜잭션 없는 간단한 생성 메서드 추가
    public Map<String, Object> createChatRoomSimple(Long projectId, String roomName) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            System.out.println("=== Simple chat room creation START ===");
            System.out.println("ProjectId: " + projectId + ", RoomName: " + roomName);
            
            // ChatDTO 생성
            ChatDTO chatDTO = new ChatDTO();
            chatDTO.setProjectId(projectId);
            chatDTO.setName(roomName);
            chatDTO.setDescription("Auto-created main chat room");
            chatDTO.setMaxParticipants(50);
            chatDTO.setIsPrivate(false);
            chatDTO.setAllowInvite(true);
            chatDTO.setSaveMessageHistory(true);
            chatDTO.setIsMain(true);
            chatDTO.setCreatedBy((Long) session.getAttribute("id"));
            
            System.out.println("Calling chatDAO.createChatRoom directly...");
            chatDAO.createChatRoom(chatDTO);
            System.out.println("Simple creation - Generated roomId: " + chatDTO.getRoomId());
            
            if (chatDTO.getRoomId() != null) {
                result.put("success", true);
                result.put("message", "Simple chat room created");
                result.put("roomId", chatDTO.getRoomId());
                
                // 즉시 검증
                try {
                    ChatDTO createdRoom = chatDAO.getChatRoom(chatDTO.getRoomId());
                    if (createdRoom != null) {
                        System.out.println("✅ Verification: Room exists in database");
                        result.put("verified", true);
                    } else {
                        System.out.println("❌ Verification: Room NOT found in database");
                        result.put("verified", false);
                    }
                } catch (Exception verifyError) {
                    System.err.println("Verification error: " + verifyError.getMessage());
                    result.put("verified", false);
                }
                
            } else {
                System.err.println("Simple creation failed");
                result.put("success", false);
                result.put("message", "Simple creation failed");
            }
            
        } catch (Exception e) {
            System.err.println("Simple creation error: " + e.getMessage());
            result.put("success", false);
            result.put("message", "Error: " + e.getMessage());
        }
        
        return result;
    }
    
    @Transactional
    public ChatRoom updateChatRoom(Long roomId, ChatDTO chatDTO) {
        ChatRoom chatRoom = chatRoomRepository.findById(roomId);
        if (chatRoom == null) {
            throw new RuntimeException("채팅방을 찾을 수 없습니다.");
        }
        chatRoom.setName(chatDTO.getName());
        chatRoom.setDescription(chatDTO.getDescription());
        chatRoom.setMaxParticipants(chatDTO.getMaxParticipants());
        chatRoom.setIsPrivate(chatDTO.getIsPrivate());
        chatRoom.setAllowInvite(chatDTO.getAllowInvite());
        chatRoom.setSaveMessageHistory(chatDTO.getSaveMessageHistory());
        chatRoom.setUpdatedAt(LocalDateTime.now());
        chatRoomRepository.update(chatRoom);
        return chatRoom;
    }
    
    @Transactional
    public void deleteChatRoom(Long roomId, Long userId) {
        ChatRoom room = chatRoomRepository.findById(roomId);
        if (room == null) {
            throw new RuntimeException("채팅방을 찾을 수 없습니다.");
        }
        
        // 권한 확인 로직 추가 (실제 운영 시 필요)
        /*
        if (room.getCreatedBy() == null || !room.getCreatedBy().equals(userId)) {
            throw new RuntimeException("채팅방을 삭제할 권한이 없습니다.");
        }
        */
        
        chatRoomRepository.delete(roomId);
    }
    
    // 검색
    public List<ChatDTO> searchChatRooms(Long projectId, String keyword) {
        System.out.println("=== searchChatRooms called ===");
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            System.out.println("[PERMISSION] No logged in user -> returning empty search results");
            return new ArrayList<>();
        }
        
        if ("ADMIN".equals(loginUser.getRole())) {
            System.out.println("[PERMISSION] Admin user -> searching all rooms in project " + projectId);
        List<ChatRoom> rooms = chatRoomRepository.searchRoomsByName(keyword);
            List<ChatDTO> result = rooms.stream()
                .filter(room -> projectId == null || projectId.equals(room.getProjectId()))
                .map(this::convertToChatDTO)
                .collect(Collectors.toList());
            System.out.println("[PERMISSION] Admin search found " + result.size() + " rooms");
            return result;
        }
        
        // 일반 사용자: 본인이 속한 프로젝트의 채팅방만 검색 가능
        System.out.println("[PERMISSION] Regular user searching in project " + projectId);
        List<ProjectDto> myProjects = projectDao.findProjectsByUserId(loginUser.getId());
        if (myProjects == null || myProjects.isEmpty()) {
            System.out.println("[PERMISSION] User not member of any project -> returning empty search results");
            return new ArrayList<>();
        }
        
        // 요청된 프로젝트가 사용자의 프로젝트인지 확인
        boolean hasAccess = myProjects.stream().anyMatch(p -> p.getId().equals(projectId));
        if (!hasAccess) {
            System.out.println("[PERMISSION] User does not have access to project " + projectId + " -> returning empty results");
            return new ArrayList<>();
        }
        
        System.out.println("[PERMISSION] User has access to project " + projectId + " -> proceeding with search");
        List<ChatRoom> rooms = chatRoomRepository.searchRoomsByName(keyword);
        List<ChatDTO> result = rooms.stream()
            .filter(room -> projectId.equals(room.getProjectId()))
            .map(this::convertToChatDTO)
            .collect(Collectors.toList());
        System.out.println("[PERMISSION] Search found " + result.size() + " accessible rooms");
        return result;
    }
    
    private ChatDTO convertToChatDTO(ChatRoom room) {
        ChatDTO dto = new ChatDTO();
        dto.setRoomId(room.getId());
        
        // 실제 참여자 수 조회
        int actualParticipantCount = chatParticipantRepository.countByRoomId(room.getId());
        
        // 채팅방 이름에서 [X명] 부분 제거
        String cleanName = room.getName().replaceFirst("^\\[\\d+명\\]\\s*", "");
        dto.setName(cleanName);
        
        // participantCount 필드에 실제 참여자 수 설정
        dto.setParticipantCount(actualParticipantCount);
        
        dto.setDescription(room.getDescription());
        dto.setMaxParticipants(room.getMaxParticipants());
        dto.setIsPrivate(room.getIsPrivate());
        dto.setAllowInvite(room.getAllowInvite());
        dto.setSaveMessageHistory(room.getSaveMessageHistory());
        dto.setIsMain(room.getIsMain());
        dto.setProjectId(room.getProjectId());
        dto.setCreatedAt(room.getCreatedAt());
        dto.setUpdatedAt(room.getUpdatedAt());
        return dto;
    }
    
    /**
     * 채팅방 이름에서 참여자 수를 실제 수로 업데이트
     */
    private String updateRoomNameWithParticipantCount(String originalName, int actualCount) {
        // "[X명]"으로 시작하는 패턴을 찾아서 실제 참여자 수로 교체
        if (originalName.matches("^\\[\\d+명\\].*")) {
            return originalName.replaceFirst("^\\[\\d+명\\]", "[" + actualCount + "명]");
        }
        // 패턴이 없으면 앞에 추가
        return "[" + actualCount + "명] " + originalName;
    }
    
    /**
     * 채팅방의 실제 참여자 수로 채팅방 이름을 업데이트
     */
    @Transactional
    public void updateChatRoomParticipantCount(Long roomId) {
        try {
            ChatRoom room = chatRoomRepository.findById(roomId);
            if (room != null) {
                int actualCount = chatParticipantRepository.countByRoomId(roomId);
                String updatedName = updateRoomNameWithParticipantCount(room.getName(), actualCount);
                
                if (!updatedName.equals(room.getName())) {
                    room.setName(updatedName);
                    room.setUpdatedAt(LocalDateTime.now());
                    chatRoomRepository.update(room);
                    System.out.println("✅ 채팅방 이름 업데이트: " + updatedName);
                }
            }
        } catch (Exception e) {
            System.err.println("채팅방 참여자 수 업데이트 실패: " + e.getMessage());
        }
    }
    
    public List<ChatMessageDTO> searchChatMessages(Long roomId, String keyword, int offset, int limit) {
        List<ChatMessage> messages = chatMessageRepository.findByRoomIdAndContentContaining(roomId, keyword);
        return messages.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    // 참여자 관리
    @Transactional
    public void leaveChatRoom(Long roomId, Long userId) {
        ChatParticipant participant = chatParticipantRepository.findByRoomIdAndUserId(roomId, userId);
        if (participant == null) {
            throw new RuntimeException("참여자를 찾을 수 없습니다.");
        }
        chatParticipantRepository.deleteByRoomIdAndUserId(roomId, userId);
        
        // 참여자 수는 실시간으로 조회됨
    }
    
    @Transactional
    public void rejoinChatRoom(Long roomId, Long userId) {
        ChatParticipant participant = chatParticipantRepository.findByRoomIdAndUserId(roomId, userId);
        if (participant != null) {
            // 이미 참여중인 경우 아무것도 하지 않음
            return;
        }
        // 새로운 참여자로 추가
        addParticipant(roomId, userId, "사용자" + userId);
    }

    // 채팅방 초대 관련
    @Transactional
    public void inviteToChatRoom(Long roomId, Long inviterId, Long inviteeId) {
        if (chatInvitationRepository.existsByRoomIdAndInviteeId(roomId, inviteeId)) {
            throw new RuntimeException("이미 초대된 사용자입니다.");
        }

        ChatInvitation invitation = new ChatInvitation();
        invitation.setRoomId(roomId);
        invitation.setInviterId(inviterId);
        invitation.setInviteeId(inviteeId);
        invitation.setStatus("PENDING");
        invitation.setCreatedAt(LocalDateTime.now());
        chatInvitationRepository.insert(invitation);
    }

    @Transactional
    public void acceptInvitation(Long roomId, Long inviteeId) {
        ChatInvitation invitation = chatInvitationRepository.findByRoomIdAndInviteeId(roomId, inviteeId);
        if (invitation == null) {
            throw new RuntimeException("초대를 찾을 수 없습니다.");
        }
        invitation.setStatus("ACCEPTED");
        invitation.setUpdatedAt(LocalDateTime.now());
        chatInvitationRepository.update(invitation);

        ChatParticipant participant = new ChatParticipant();
        participant.setRoomId(roomId);
        participant.setUserId(inviteeId);
        participant.setIsAdmin(false);
        participant.setJoinedAt(LocalDateTime.now());
        chatParticipantRepository.insert(participant);
    }

    @Transactional
    public void rejectInvitation(Long roomId, Long inviteeId) {
        ChatInvitation invitation = chatInvitationRepository.findByRoomIdAndInviteeId(roomId, inviteeId);
        if (invitation == null) {
            throw new RuntimeException("초대를 찾을 수 없습니다.");
        }
        invitation.setStatus("REJECTED");
        invitation.setUpdatedAt(LocalDateTime.now());
        chatInvitationRepository.update(invitation);
    }

    public List<Map<String, Object>> getPendingInvitations(Long userId) {
        List<ChatInvitation> invitations = chatInvitationRepository.findByInviteeIdAndStatus(userId, "PENDING");
        return invitations.stream()
                .map(this::convertInvitationToMap)
                .collect(Collectors.toList());
    }
    
    private Map<String, Object> convertInvitationToMap(ChatInvitation invitation) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", invitation.getId());
        map.put("roomId", invitation.getRoomId());
        map.put("inviterId", invitation.getInviterId());
        map.put("inviteeId", invitation.getInviteeId());
        map.put("status", invitation.getStatus());
        map.put("createdAt", invitation.getCreatedAt());
        map.put("updatedAt", invitation.getUpdatedAt());
        return map;
    }

    // 채팅방 권한 관리
    @Transactional
    public void setUserPermission(Long roomId, Long userId, String permissionType, Long grantedBy) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("userId", userId);
        params.put("permissionType", permissionType);
        params.put("grantedBy", grantedBy);
        chatDAO.setRoomPermission(params);
    }

    public List<String> getUserPermissions(Long roomId, Long userId) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("userId", userId);
        return chatDAO.getUserPermissions(params);
    }

    public boolean hasPermission(Long roomId, Long userId, String permissionType) {
        List<String> permissions = getUserPermissions(roomId, userId);
        return permissions.contains(permissionType);
    }

    // 메시지 검색
    public List<ChatMessageDTO> searchMessages(Long roomId, String keyword, String startDate, String endDate, int offset, int limit) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("keyword", keyword);
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        params.put("offset", offset);
        params.put("limit", limit);
        return chatDAO.searchMessages(params);
    }

    // 채팅방 통계
    public Map<String, Object> getRoomStatistics(Long roomId) {
        return chatDAO.getRoomStatistics(roomId);
    }

    public List<Map<String, Object>> getUserActivityStats(Long roomId) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        return chatDAO.getUserActivityStats(params);
    }

    public List<Map<String, Object>> getMessageStats(Long roomId, String startDate, String endDate) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        return chatDAO.getMessageStats(params);
    }

    // 채팅방 알림 설정
    @Transactional
    public void updateNotificationSettings(Long roomId, Long userId, boolean enabled, String type) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("userId", userId);
        params.put("enabled", enabled);
        params.put("type", type);
        chatDAO.updateNotificationSettings(params);
    }

    public Map<String, Object> getNotificationSettings(Long roomId, Long userId) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("userId", userId);
        return chatDAO.getNotificationSettings(params);
    }

    // 채팅방별 알림 설정 조회 (chat_participants 테이블에서)
    public Map<String, Object> getRoomNotificationSettings(Long roomId, Long userId) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("userId", userId);
        return chatDAO.getRoomNotificationSettings(params);
    }

    // 사용자 전체 알림 설정 저장
    public void saveUserNotificationSettings(Long userId, Boolean enableNotifications, Boolean soundEnabled, 
            Boolean desktopNotifications, String doNotDisturbStart, String doNotDisturbEnd) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("enableNotifications", enableNotifications);
        params.put("soundEnabled", soundEnabled);
        params.put("desktopNotifications", desktopNotifications);
        params.put("doNotDisturbStart", doNotDisturbStart);
        params.put("doNotDisturbEnd", doNotDisturbEnd);
        
        chatDAO.saveUserNotificationSettings(params);
    }

    // 사용자 전체 알림 설정 조회
    public Map<String, Object> getUserNotificationSettings(Long userId) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        return chatDAO.getNotificationSettings(params);
    }

    // 검색 메시지 개수 조회
    public int getSearchMessageCount(Map<String, Object> params) {
        return chatDAO.getSearchMessageCount(params);
    }

    // 채팅방 즐겨찾기
    @Transactional
    public void addFavoriteRoom(Long userId, Long roomId) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("roomId", roomId);
        chatDAO.createRoomSettings(params);
    }

    @Transactional
    public void removeFavoriteRoom(Long userId, Long roomId) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("roomId", roomId);
        chatDAO.deleteRoomShare(params);
    }

    public List<ChatDTO> getFavoriteRooms(Long userId) {
        System.out.println("=== getFavoriteRooms called ===");
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            System.out.println("[PERMISSION] No logged in user -> returning empty favorite rooms");
            return new ArrayList<>();
        }
        
        if ("ADMIN".equals(loginUser.getRole())) {
            System.out.println("[PERMISSION] Admin user -> getting favorites for user " + userId);
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
            List<ChatDTO> result = chatDAO.searchRooms(params);
            System.out.println("[PERMISSION] Admin found " + result.size() + " favorite rooms");
            return result;
        }
        
        // 일반 사용자는 자신의 즐겨찾기만 조회 가능
        if (!loginUser.getId().equals(userId)) {
            System.out.println("[PERMISSION] User trying to access other user's favorites -> denied");
            return new ArrayList<>();
        }
        
        System.out.println("[PERMISSION] User accessing own favorites");
        List<ProjectDto> myProjects = projectDao.findProjectsByUserId(loginUser.getId());
        if (myProjects == null || myProjects.isEmpty()) {
            System.out.println("[PERMISSION] User not member of any project -> returning empty favorites");
            return new ArrayList<>();
        }
        
        List<Long> myProjectIds = myProjects.stream().map(ProjectDto::getId).collect(Collectors.toList());
        System.out.println("[PERMISSION] User belongs to projects: " + myProjectIds);
        
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        List<ChatDTO> allFavorites = chatDAO.searchRooms(params);
        List<ChatDTO> filteredFavorites = allFavorites.stream()
            .filter(room -> myProjectIds.contains(room.getProjectId()))
            .collect(Collectors.toList());
        
        System.out.println("[PERMISSION] Filtered favorite rooms: " + filteredFavorites.size() + " accessible rooms");
        return filteredFavorites;
    }

    // 채팅방 태그
    @Transactional
    public void addRoomTag(Long roomId, String tagName, Long createdBy) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("tagName", tagName);
        params.put("createdBy", createdBy);
        chatDAO.createRoomSettings(params);
    }

    @Transactional
    public void removeRoomTag(Long roomId, String tagName) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("tagName", tagName);
        chatDAO.updateRoomSettings(params);
    }

    public List<String> getRoomTags(Long roomId) {
        Map<String, String> settings = chatDAO.getRoomSettings(roomId);
        if (settings == null) {
            return new ArrayList<>();
        }
        String tags = settings.get("tags");
        if (tags == null) {
            return new ArrayList<>();
        }
        return Arrays.asList(tags.split(","));
    }

    public List<ChatDTO> searchRoomsByTag(String tagName) {
        System.out.println("=== searchRoomsByTag called ===");
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            System.out.println("[PERMISSION] No logged in user -> returning empty tag search results");
            return new ArrayList<>();
        }
        
        if ("ADMIN".equals(loginUser.getRole())) {
            System.out.println("[PERMISSION] Admin user -> searching all rooms by tag: " + tagName);
        Map<String, Object> params = new HashMap<>();
        params.put("tagName", tagName);
            List<ChatDTO> result = chatDAO.searchRooms(params);
            System.out.println("[PERMISSION] Admin tag search found " + result.size() + " rooms");
            return result;
        }
        
        // 일반 사용자: 본인이 속한 프로젝트의 채팅방만 태그 검색 가능
        System.out.println("[PERMISSION] Regular user -> filtering tag search to user's projects");
        List<ProjectDto> myProjects = projectDao.findProjectsByUserId(loginUser.getId());
        if (myProjects == null || myProjects.isEmpty()) {
            System.out.println("[PERMISSION] User not member of any project -> returning empty tag search results");
            return new ArrayList<>();
        }
        
        List<Long> myProjectIds = myProjects.stream().map(ProjectDto::getId).collect(Collectors.toList());
        System.out.println("[PERMISSION] User belongs to projects: " + myProjectIds);
        
        Map<String, Object> params = new HashMap<>();
        params.put("tagName", tagName);
        List<ChatDTO> allResults = chatDAO.searchRooms(params);
        List<ChatDTO> filteredResults = allResults.stream()
            .filter(room -> myProjectIds.contains(room.getProjectId()))
            .collect(Collectors.toList());
        
        System.out.println("[PERMISSION] Filtered tag search results: " + filteredResults.size() + " accessible rooms");
        return filteredResults;
    }

    // 채팅방 백업
    public Map<String, Object> backupChatRoom(Long roomId) {
        return chatDAO.exportRoomData(roomId);
    }

    @Transactional
    public void restoreChatRoom(Map<String, Object> backupData) {
        chatDAO.createRoomFromTemplate(backupData);
    }

    // 채팅방 검색 및 필터링
    public List<ChatDTO> searchRooms(String keyword, String type, String startDate, String endDate, 
                                   Long userId, String sortBy, String sortOrder, int offset, int limit) {
        System.out.println("=== searchRooms called ===");
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            System.out.println("[PERMISSION] No logged in user -> returning empty search results");
            return new ArrayList<>();
        }
        
        if ("ADMIN".equals(loginUser.getRole())) {
            System.out.println("[PERMISSION] Admin user -> searching all rooms with full access");
        Map<String, Object> params = new HashMap<>();
        params.put("keyword", keyword);
        params.put("type", type);
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        params.put("userId", userId);
        params.put("sortBy", sortBy);
        params.put("sortOrder", sortOrder);
        params.put("offset", offset);
        params.put("limit", limit);
            List<ChatDTO> result = chatDAO.searchRooms(params);
            System.out.println("[PERMISSION] Admin search found " + result.size() + " rooms");
            return result;
        }
        
        // 일반 사용자: 본인이 속한 프로젝트의 채팅방만 검색 가능
        System.out.println("[PERMISSION] Regular user -> filtering search to user's projects");
        List<ProjectDto> myProjects = projectDao.findProjectsByUserId(loginUser.getId());
        if (myProjects == null || myProjects.isEmpty()) {
            System.out.println("[PERMISSION] User not member of any project -> returning empty search results");
            return new ArrayList<>();
        }
        
        // 사용자의 프로젝트 ID 목록 생성
        List<Long> myProjectIds = myProjects.stream().map(ProjectDto::getId).collect(Collectors.toList());
        System.out.println("[PERMISSION] User belongs to projects: " + myProjectIds);
        
        // 모든 채팅방에서 검색한 후 권한 필터링
        Map<String, Object> params = new HashMap<>();
        params.put("keyword", keyword);
        params.put("type", type);
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        params.put("userId", userId);
        params.put("sortBy", sortBy);
        params.put("sortOrder", sortOrder);
        params.put("offset", 0); // 필터링 전이므로 모든 결과를 가져온 후 필터링
        params.put("limit", 1000); // 충분히 큰 값
        
        List<ChatDTO> allResults = chatDAO.searchRooms(params);
        List<ChatDTO> filteredResults = allResults.stream()
            .filter(room -> myProjectIds.contains(room.getProjectId()))
            .skip(offset)
            .limit(limit)
            .collect(Collectors.toList());
        
        System.out.println("[PERMISSION] Filtered search results: " + filteredResults.size() + " accessible rooms");
        return filteredResults;
    }

    // 채팅방 공유
    @Transactional
    public String createRoomShare(Long roomId, Long sharedBy, String shareType, String expiresAt) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("sharedBy", sharedBy);
        params.put("shareType", shareType);
        params.put("expiresAt", expiresAt);
        chatDAO.createRoomShare(params);
        return UUID.randomUUID().toString();
    }

    public Map<String, Object> getRoomShare(String shareToken) {
        return chatDAO.getRoomShare(shareToken);
    }

    @Transactional
    public void deleteRoomShare(Long roomId, Long sharedBy) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("sharedBy", sharedBy);
        chatDAO.deleteRoomShare(params);
    }

    // 채팅방 내보내기
    public Map<String, Object> exportRoomData(Long roomId) {
        return chatDAO.exportRoomData(roomId);
    }

    public byte[] exportRoomToFile(Long roomId, String format) {
        Map<String, Object> data = exportRoomData(roomId);
        try {
            switch (format.toLowerCase()) {
                case "json": {
                    ObjectMapper mapper = new ObjectMapper();
                    return mapper.writeValueAsBytes(data);
                }
                case "csv":
                    return convertToCsv(data).getBytes("UTF-8");
                default:
                    throw new IllegalArgumentException("지원하지 않는 형식입니다.");
            }
        } catch (UnsupportedEncodingException | JsonProcessingException e) {
            throw new RuntimeException("파일 변환 중 오류가 발생했습니다.", e);
        }
    }

    // 메시지 분석
    public List<Map<String, Object>> analyzeMessagePatterns(Long roomId, String startDate, String endDate) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        return chatDAO.analyzeMessagePatterns(params);
    }

    public List<Map<String, Object>> getUserMessageStats(Long roomId) {
        return chatDAO.getUserMessageStats(roomId);
    }

    // 활동 로그
    @Transactional
    public void logRoomActivity(Long roomId, Long userId, String activityType, String activityDetails) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("userId", userId);
        params.put("activityType", activityType);
        params.put("activityDetails", activityDetails);
        chatDAO.logRoomActivity(params);
    }

    public List<Map<String, Object>> getRoomActivityLogs(Long roomId, int offset, int limit) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("offset", offset);
        params.put("limit", limit);
        return chatDAO.getRoomActivityLogs(params);
    }

    // 채팅방 설정
    @Transactional
    public void setRoomSetting(Long roomId, String settingKey, String settingValue, Long createdBy) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("settingKey", settingKey);
        params.put("settingValue", settingValue);
        params.put("createdBy", createdBy);
        chatDAO.createRoomSettings(params);
    }

    @Transactional
    public void updateRoomSetting(Long roomId, String settingKey, String settingValue) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("settingKey", settingKey);
        params.put("settingValue", settingValue);
        chatDAO.updateRoomSettings(params);
    }

    public Map<String, String> getRoomSettings(Long roomId) {
        return chatDAO.getRoomSettings(roomId);
    }

    // 채팅방 템플릿
    @Transactional
    public void createRoomTemplate(String templateName, String templateDescription, 
                                 String roomType, Map<String, Object> defaultSettings, Long createdBy) {
        Map<String, Object> params = new HashMap<>();
        params.put("templateName", templateName);
        params.put("templateDescription", templateDescription);
        params.put("roomType", roomType);
        params.put("defaultSettings", defaultSettings);
        params.put("createdBy", createdBy);
        chatDAO.createRoomTemplate(params);
    }

    public List<Map<String, Object>> getRoomTemplates(String roomType) {
        return chatDAO.getRoomTemplates(roomType);
    }

    public Map<String, Object> getRoomTemplate(Long templateId) {
        return chatDAO.getRoomTemplate(templateId);
    }

    @Transactional
    public Long createRoomFromTemplate(Long templateId, String roomName, String roomDescription, Long createdBy) {
        Map<String, Object> params = new HashMap<>();
        params.put("templateId", templateId);
        params.put("roomName", roomName);
        params.put("roomDescription", roomDescription);
        params.put("createdBy", createdBy);
        chatDAO.createRoomFromTemplate(params);
        return (Long) params.get("roomId");
    }

    // 메시지 필터링
    public List<ChatMessageDTO> filterMessages(Long roomId, String messageType, Long senderId, 
                                            String startDate, String endDate, Boolean hasFile, 
                                            Boolean isPinned, int offset, int limit) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("messageType", messageType);
        params.put("senderId", senderId);
        params.put("startDate", startDate);
        params.put("endDate", endDate);
        params.put("hasFile", hasFile);
        params.put("isPinned", isPinned);
        params.put("offset", offset);
        params.put("limit", limit);
        return chatDAO.filterMessages(params);
    }

    // 참여자 관리
    @Transactional
    public void updateParticipantRole(Long roomId, Long userId, String role) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("userId", userId);
        params.put("role", role);
        chatDAO.updateParticipantRole(params);
    }

    public List<Map<String, Object>> getParticipantRoles(Long roomId) {
        return chatDAO.getParticipantRoles(roomId);
    }

    public List<ChatParticipantDTO> getParticipantsByRole(Long roomId, String role) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("role", role);
        return chatDAO.getParticipantsByRole(params);
    }

    // 알림 설정
    @Transactional
    public void updateNotificationPreferences(Long roomId, Long userId, boolean emailNotifications,
                                           boolean pushNotifications, boolean desktopNotifications,
                                           String notificationSound) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("userId", userId);
        params.put("emailNotifications", emailNotifications);
        params.put("pushNotifications", pushNotifications);
        params.put("desktopNotifications", desktopNotifications);
        params.put("notificationSound", notificationSound);
        chatDAO.updateNotificationPreferences(params);
    }

    public Map<String, Object> getNotificationPreferences(Long roomId, Long userId) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("userId", userId);
        return chatDAO.getNotificationPreferences(params);
    }

    // 메시지 포맷팅
    @Transactional
    public void updateMessageFormat(Long messageId, String messageFormat, String formattedMessage) {
        Map<String, Object> params = new HashMap<>();
        params.put("messageId", messageId);
        params.put("messageFormat", messageFormat);
        params.put("formattedMessage", formattedMessage);
        chatDAO.updateMessageFormat(params);
    }

    public List<Map<String, Object>> getMessageFormats(Long roomId, int limit) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("limit", limit);
        return chatDAO.getMessageFormats(params);
    }

    public List<Map<String, Object>> getMessageFormatStats(Long roomId) {
        return chatDAO.getMessageFormatStats(roomId);
    }

    public List<ChatMessageDTO> getMessageReplies(Long messageId) {
        return chatDAO.getMessageReplies(messageId);
    }

    @Transactional
    public void updateMessage(Long messageId, Long senderId, String newMessage) {
        Map<String, Object> params = new HashMap<>();
        params.put("messageId", messageId);
        params.put("senderId", senderId);
        params.put("newMessage", newMessage);
        chatDAO.updateMessage(params);
    }

    @Transactional
    public void deleteMessage(Long messageId, Long senderId) {
        Map<String, Object> params = new HashMap<>();
        params.put("messageId", messageId);
        params.put("senderId", senderId);
        chatDAO.deleteMessage(params);
    }

    @Transactional
    public void togglePinMessage(Long messageId) {
        chatDAO.togglePinMessage(messageId);
    }

    @Transactional
    public Long saveMessageFile(ChatMessageFileDTO file) {
        chatDAO.saveMessageFile(file);
        return file.getId(); // MyBatis에서 자동 생성된 ID 반환
    }

    public List<ChatMessageFileDTO> getMessageFiles(Long messageId) {
        return chatDAO.getMessageFiles(messageId);
    }
    
    public ChatMessageFileDTO getMessageFileById(Long fileId) {
        return chatDAO.getMessageFileById(fileId);
    }

    @Transactional
    public void markMessageAsRead(Long messageId, Long userId) {
        Map<String, Object> params = new HashMap<>();
        params.put("messageId", messageId);
        params.put("userId", userId);
        chatDAO.markMessageAsRead(params);
    }

    private String convertToCsv(Map<String, Object> data) {
        StringBuilder csv = new StringBuilder();
        // CSV 헤더
        csv.append("id,name,description,created_at,updated_at\n");
        // CSV 데이터
        csv.append(String.format("%s,%s,%s,%s,%s\n",
                data.get("id"),
                data.get("name"),
                data.get("description"),
                data.get("createdAt"),
                data.get("updatedAt")));
        return csv.toString();
    }

    public List<ChatDTO> getAllChatRooms() {
        System.out.println("=== getAllChatRooms called ===");
        AuthDto loginUser = (AuthDto) session.getAttribute("loginUser");
        if (loginUser == null) {
            System.out.println("[PERMISSION] No logged in user -> returning empty list");
            return new ArrayList<>();
        }
        
        if ("ADMIN".equals(loginUser.getRole())) {
            System.out.println("[PERMISSION] Admin user -> returning all chat rooms");
            List<ChatRoom> allRooms = chatRoomRepository.findAll();
            List<ChatDTO> result = allRooms.stream().map(this::convertToChatDTO).collect(Collectors.toList());
            System.out.println("[PERMISSION] Admin can see " + result.size() + " chat rooms");
            return result;
        }
        
        // 팀장/팀원: 본인이 속한 프로젝트의 채팅방만 반환
        System.out.println("[PERMISSION] Regular user (" + loginUser.getRole() + ") -> checking user's projects");
        List<ProjectDto> myProjects = projectDao.findProjectsByUserId(loginUser.getId());
        if (myProjects == null || myProjects.isEmpty()) {
            System.out.println("[PERMISSION] User not member of any project -> returning empty list");
            return new ArrayList<>();
        }
        
        System.out.println("[PERMISSION] User is member of " + myProjects.size() + " project(s)");
        List<ChatDTO> result = new ArrayList<>();
        for (ProjectDto project : myProjects) {
            List<ChatRoom> rooms = chatRoomRepository.findByProjectId(project.getId());
            if (rooms != null) {
                System.out.println("[PERMISSION] Project '" + project.getTitle() + "' has " + rooms.size() + " chat room(s)");
                for (ChatRoom room : rooms) {
                    result.add(convertToChatDTO(room));
                }
            }
        }
        System.out.println("[PERMISSION] User can see " + result.size() + " chat room(s) from their projects");
        return result;
    }

    @Transactional(readOnly = true)
    public List<ChatRoom> searchRoomsByName(String keyword) {
        return chatRoomRepository.searchRoomsByName(keyword);
    }

    public List<ChatInvitation> getInvitedUsers(Long roomId) {
        return chatInvitationRepository.findByRoomId(roomId);
    }

    @Transactional
    public ChatParticipant joinChatRoom(Long roomId, Long userId, String nickname) {
        System.out.println("=== joinChatRoom START ===");
        System.out.println("roomId: " + roomId + ", userId: " + userId + ", nickname: " + nickname);
        
        // 이미 참여 중인지 확인
        boolean alreadyParticipating = chatParticipantRepository.existsByRoomIdAndUserId(roomId, userId);
        System.out.println("Already participating? " + alreadyParticipating);
        
        if (alreadyParticipating) {
            System.out.println("SUCCESS: User already participating - returning existing participant info");
            // 예외를 던지지 않고 기존 참여자 정보를 반환
            ChatParticipant existingParticipant = chatParticipantRepository.findByRoomIdAndUserId(roomId, userId);
            if (existingParticipant != null) {
                System.out.println("Existing participant: " + existingParticipant.getNickname());
                return existingParticipant;
            }
        }

        try {
            // 새로운 참여자 추가
            System.out.println("Adding new participant...");
        ChatParticipant participant = new ChatParticipant();
        participant.setRoomId(roomId);
        participant.setUserId(userId);
        participant.setNickname(nickname);
            participant.setIsAdmin(false); // 기본값을 false로 설정
        participant.setJoinedAt(LocalDateTime.now());
            
            // 디버깅: 설정된 값들 확인
            System.out.println("participant.getRoomId(): " + participant.getRoomId());
            System.out.println("participant.getUserId(): " + participant.getUserId());
            System.out.println("participant.getNickname(): " + participant.getNickname());
            System.out.println("participant.getIsAdmin(): " + participant.getIsAdmin());
            System.out.println("participant.getJoinedAt(): " + participant.getJoinedAt());
            
                    chatParticipantRepository.insert(participant);
            System.out.println("SUCCESS: New participant added successfully");

            // 참여자 수는 실시간으로 조회됨 (더 이상 DB 업데이트 불필요)

            // 입장 시스템 메시지 생성 비활성화됨

            System.out.println("=== joinChatRoom SUCCESS COMPLETED ===");
        return participant;
            
        } catch (Exception e) {
            System.err.println("ERROR: joinChatRoom failed: " + e.getMessage());
            throw new RuntimeException("Failed to join chat room: " + e.getMessage());
        }
    }

    @Transactional
    public void deleteChatRoom(Long roomId) {
        chatMessageRepository.deleteByRoomId(roomId);
        chatParticipantRepository.deleteByRoomId(roomId);
        chatRoomRepository.delete(roomId);
    }

    public List<ChatRoom> getPublicChatRooms() {
        return chatRoomRepository.findByIsPrivate(false);
    }

    public List<ChatMessage> getChatMessages(Long roomId) {
        return chatMessageRepository.findByRoomIdOrderByCreatedAtDesc(roomId);
    }

    public List<ChatParticipant> getChatParticipants(Long roomId) {
        return chatParticipantRepository.findByRoomId(roomId);
    }

    public List<Map<String, Object>> searchChatRooms(String keyword) {
        List<ChatRoom> rooms = chatRoomRepository.findByName(keyword);
        return rooms.stream()
                .map(this::convertToChatDTO)
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }
    
    public List<Map<String, Object>> searchChatMessages(Long roomId, String keyword) {
        List<ChatMessage> messages = chatMessageRepository.findByRoomIdAndContentContaining(roomId, keyword);
        return messages.stream()
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }
    
    public List<Map<String, Object>> getChatRoomHistory(Long roomId) {
        List<ChatMessage> messages = chatMessageRepository.findByRoomIdOrderByCreatedAtDesc(roomId);
        return messages.stream()
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }
    
    public List<Map<String, Object>> getChatRoomParticipants(Long roomId) {
        List<ChatParticipant> participants = chatParticipantRepository.findByRoomId(roomId);
        return participants.stream()
                .map(this::convertToParticipantDTO)
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }

    public List<Map<String, Object>> getChatRoomsByUser(Long userId) {
        List<ChatParticipant> participants = chatParticipantRepository.findByUserId(userId);
        return participants.stream()
                .map(p -> chatRoomRepository.findById(p.getRoomId()))
                .filter(room -> room != null)
                .map(this::convertToChatDTO)
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }
    
    public List<Map<String, Object>> getChatRoomsByType(String type) {
        List<ChatRoom> rooms = chatRoomRepository.findByType(type);
        return rooms.stream()
                .map(this::convertToChatDTO)
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }
    
    public List<Map<String, Object>> getChatRoomsByStatus(String status) {
        List<ChatRoom> rooms = chatRoomRepository.findByStatus(status);
        return rooms.stream()
                .map(this::convertToChatDTO)
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }
    
    public List<Map<String, Object>> getChatRoomsByCreatedAt(LocalDateTime startDate, LocalDateTime endDate) {
        List<ChatRoom> rooms = chatRoomRepository.findByCreatedAtBetween(startDate, endDate);
        return rooms.stream()
                .map(this::convertToChatDTO)
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }
    
    public List<Map<String, Object>> getChatRoomsByUpdatedAt(LocalDateTime startDate, LocalDateTime endDate) {
        List<ChatRoom> rooms = chatRoomRepository.findByUpdatedAtBetween(startDate, endDate);
        return rooms.stream()
                .map(this::convertToChatDTO)
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }
    
    public List<Map<String, Object>> getChatRoomsByParticipantCount(int minCount, int maxCount) {
        List<ChatRoom> rooms = chatRoomRepository.findAll();
        return rooms.stream()
                .filter(room -> {
                    int count = chatParticipantRepository.countByRoomId(room.getId());
                    return count >= minCount && count <= maxCount;
                })
                .map(this::convertToChatDTO)
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }
    
    public List<Map<String, Object>> getChatRoomsByMessageCount(int minCount, int maxCount) {
        List<ChatRoom> rooms = chatRoomRepository.findAll();
        return rooms.stream()
                .filter(room -> {
                    int count = chatMessageRepository.countByRoomId(room.getId());
                    return count >= minCount && count <= maxCount;
                })
                .map(this::convertToChatDTO)
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }
    
    public List<Map<String, Object>> getChatRoomsByLastMessageAt(LocalDateTime startDate, LocalDateTime endDate) {
        List<ChatRoom> rooms = chatRoomRepository.findAll();
        return rooms.stream()
                .filter(room -> {
                    Optional<ChatMessage> lastMessage = chatMessageRepository.findFirstByRoomIdOrderByCreatedAtDesc(room.getId());
                    return lastMessage.isPresent() && 
                           lastMessage.get().getCreatedAt().isAfter(startDate) && 
                           lastMessage.get().getCreatedAt().isBefore(endDate);
                })
                .map(this::convertToChatDTO)
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }
    
    public List<Map<String, Object>> getChatRoomsByUnreadCount(Long userId, int minCount, int maxCount) {
        List<ChatParticipant> participants = chatParticipantRepository.findByUserId(userId);
        return participants.stream()
                .filter(p -> {
                    int count = getUnreadMessageCount(p.getRoomId(), userId);
                    return count >= minCount && count <= maxCount;
                })
                .map(p -> chatRoomRepository.findById(p.getRoomId()))
                .filter(room -> room != null)
                .map(this::convertToChatDTO)
                .map(this::convertToMap)
                .collect(Collectors.toList());
    }

    private Map<String, Object> convertToMap(Object obj) {
        Map<String, Object> map = new HashMap<>();
        if (obj instanceof ChatMessage) {
            ChatMessage message = (ChatMessage) obj;
            map.put("id", message.getId());
            map.put("roomId", message.getRoomId());
            map.put("senderId", message.getUserId());
            map.put("content", message.getContent());
            map.put("messageType", message.getMessageType());
            map.put("sendTime", message.getCreatedAt());
            map.put("createdAt", message.getCreatedAt());
        } else if (obj instanceof ChatParticipantDTO) {
            ChatParticipantDTO participant = (ChatParticipantDTO) obj;
            // id 필드 제거됨
            map.put("roomId", participant.getRoomId());
            map.put("userId", participant.getUserId());
            map.put("nickname", participant.getNickname());
            map.put("isAdmin", participant.getIsAdmin());
            map.put("joinedAt", participant.getJoinedAt());
        } else {
            // 알 수 없는 타입은 무시
        }
        return map;
    }

    // chat_reads 테이블을 활용한 새로운 읽음 상태 메서드들
    
    /**
     * 특정 메시지의 읽음 상태 조회
     */
    public Map<String, Object> getMessageReadStatus(Long messageId) {
        return chatDAO.getMessageReadStatus(messageId);
    }
    
    /**
     * 채팅방의 모든 메시지를 읽음으로 표시
     */
    @Transactional
    public void markAllMessagesAsRead(Long roomId, Long userId) {
        Map<String, Object> params = new HashMap<>();
        params.put("roomId", roomId);
        params.put("userId", userId);
        chatDAO.markAllMessagesAsRead(params);
    }
    
    /**
     * 특정 메시지를 읽은 사용자 목록 조회
     */
    public List<Map<String, Object>> getMessageReaders(Long messageId) {
        return chatDAO.getMessageReaders(messageId);
    }
    
    /**
     * 채팅방에서 읽지 않은 메시지가 있는 사용자 목록 조회
     */
    public List<Map<String, Object>> getUsersWithUnreadMessages(Long roomId) {
        return chatDAO.getUsersWithUnreadMessages(roomId);
    }
} 