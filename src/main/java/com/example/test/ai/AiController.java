package com.example.test.ai;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.example.test.auth.AuthDto;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;


@Controller
@RequestMapping("/ai")
public class AiController {

    @Autowired
    private AiService aiService;

    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @Autowired
    private com.example.test.project.ProjectService projectService;
    
    // 파일 업로드 디렉토리 설정
    private static final String UPLOAD_DIR = com.example.test.config.RuntimePaths.uploads("ai_files") + "/";
    
    // 파일 저장 메서드
    private String saveUploadedFile(MultipartFile file) throws IOException {
        // 업로드 디렉토리 생성
        Path uploadPath = Paths.get(UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        // 파일명 중복 방지를 위해 UUID 추가
        String originalFilename = file.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        String uniqueFilename = UUID.randomUUID().toString() + extension;
        
        // 파일 저장
        Path filePath = uploadPath.resolve(uniqueFilename);
        Files.copy(file.getInputStream(), filePath);
        
        return filePath.toString();
    }

    // AI 챗봇 메인 페이지 (기자재 기반 프로젝트 추천)
    @GetMapping("/chatbot")
    public String chatbotPage(HttpSession session, Model model) {
        AuthDto user = (AuthDto) session.getAttribute("loginUser");
        if (user == null || "ADMIN".equals(user.getRole())) {
            return "redirect:/auth/login";
        }
        
        model.addAttribute("equipments", aiService.getAvailableEquipments());
        return "ai/chatbot";
    }
    
    // 프로젝트 기반 AI 상담 페이지
    @GetMapping("/project-assistant")
    public String projectAssistantPage(HttpSession session, Model model) {
        AuthDto user = (AuthDto) session.getAttribute("loginUser");
        if (user == null || "ADMIN".equals(user.getRole())) {
            return "redirect:/auth/login";
        }
        
        // 사용자의 프로젝트 목록 조회
        try {
            List<com.example.test.project.ProjectDto> projects = projectService.getProjectsForUser(user.getId());
            model.addAttribute("projects", projects);
            System.out.println("프로젝트 목록 조회 완료: " + projects.size() + "개");
        } catch (RuntimeException e) {
            System.err.println("프로젝트 목록 조회 오류: " + e.getMessage());
            model.addAttribute("projects", new java.util.ArrayList<>());
        }
        
        return "ai/project-assistant";
    }

    // 기존 스트리밍 AI 응답
    @PostMapping("/stream")
    public void aiStream(
            @RequestParam String prompt,
            HttpSession session,
            HttpServletResponse response) throws IOException {

        AuthDto user = (AuthDto) session.getAttribute("loginUser");
        if (user == null || "ADMIN".equals(user.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "관리자는 AI 기능을 사용할 수 없습니다.");
            return;
        }

        // UTF-8 인코딩 명시적 설정
        response.setContentType("text/plain; charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Connection", "keep-alive");

        aiService.streamAiAnswer(prompt, user.getId().toString(), response.getWriter());
    }

    // 파일과 함께 프로젝트 추천 API
    @PostMapping(value = "/recommend-project", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> recommendProject(
            @RequestParam("question") String question,
            @RequestParam("selectedEquipments") String selectedEquipmentsJson,
            @RequestParam("teamSize") Integer teamSize,
            @RequestParam(value = "files", required = false) MultipartFile[] files,
            HttpSession session) {
        try {
            System.out.println("=== 프로젝트 추천 API 호출 ===");
            System.out.println("질문: " + question);
            System.out.println("기자재 JSON: " + selectedEquipmentsJson);
            System.out.println("팀 크기: " + teamSize);
            System.out.println("첨부파일 개수: " + (files != null ? files.length : 0));
            
            // 현재 로그인한 사용자 정보 가져오기
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                System.out.println("로그인되지 않은 사용자의 프로젝트 추천 요청");
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            }

            System.out.println("요청 사용자 ID: " + user.getId());
            System.out.println("요청 사용자 이름: " + user.getName());
            
            // JSON 문자열을 파싱하여 기자재 목록 추출
            ObjectMapper jsonMapper = new ObjectMapper();
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> selectedEquipments = jsonMapper.readValue(selectedEquipmentsJson, List.class);
            
            // 기자재 이름 추출
            List<String> equipmentNames = new ArrayList<>();
            if (selectedEquipments != null) {
                for (Map<String, Object> equipment : selectedEquipments) {
                    String name = (String) equipment.get("name");
                    if (name != null) {
                        equipmentNames.add(name);
                    }
                }
            }
            
            long startTime = System.currentTimeMillis();
            String recommendation = aiService.getProjectRecommendation(equipmentNames, teamSize, question);
            long endTime = System.currentTimeMillis();
            int responseTime = (int) ((endTime - startTime) / 1000);
            
            System.out.println("AI 응답 생성 완료. 소요 시간: " + responseTime + "초");
            System.out.println("응답 길이: " + (recommendation != null ? recommendation.length() : 0));
            
            // 질문과 답변을 데이터베이스에 저장 (올바른 사용자 ID 사용)
            Long questionId = aiService.saveQuestionAndAnswer(user.getId(), "PROJECT", question, recommendation, responseTime);
            System.out.println("데이터베이스 저장 완료. 질문 ID: " + questionId);
            
            // 첨부파일 처리
            if (files != null && files.length > 0) {
                for (MultipartFile file : files) {
                    if (!file.isEmpty()) {
                        try {
                            String savedFilePath = saveUploadedFile(file);
                            aiService.saveQuestionFile(questionId, savedFilePath, file.getOriginalFilename(), 
                                                     file.getContentType(), file.getSize());
                            System.out.println("첨부파일 저장 완료: " + file.getOriginalFilename());
                        } catch (IOException e) {
                            System.err.println("첨부파일 저장 실패 (파일 처리): " + file.getOriginalFilename() + " - " + e.getMessage());
                        } catch (RuntimeException e) {
                            System.err.println("첨부파일 저장 실패 (데이터베이스): " + file.getOriginalFilename() + " - " + e.getMessage());
                        }
                    }
                }
            }
            
            // ObjectMapper를 사용하여 안전한 JSON 응답 생성 (UTF-8 보장)
            ObjectMapper mapper = new ObjectMapper();
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("recommendation", recommendation);
            response.put("responseTime", responseTime);
            
            String jsonResponse = mapper.writeValueAsString(response);
            
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
            
        } catch (IOException e) {
            System.err.println("프로젝트 추천 - 파일/JSON 처리 중 오류: " + e.getMessage());
            // ObjectMapper를 사용하여 안전한 오류 응답 생성
            ObjectMapper errorMapper = new ObjectMapper();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "파일 처리 중 오류가 발생했습니다");
            errorResponse.put("message", e.getMessage());
            
            try {
                String errorJson = errorMapper.writeValueAsString(errorResponse);
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(errorJson);
            } catch (IOException jsonError) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"error\": \"서버 오류가 발생했습니다\"}");
            }
        } catch (RuntimeException e) {
            System.err.println("프로젝트 추천 중 오류: " + e.getMessage());
            // ObjectMapper를 사용하여 안전한 오류 응답 생성
            ObjectMapper errorMapper = new ObjectMapper();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "프로젝트 추천 중 오류가 발생했습니다");
            errorResponse.put("message", e.getMessage());
            
            try {
                String errorJson = errorMapper.writeValueAsString(errorResponse);
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(errorJson);
            } catch (IOException jsonError) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"error\": \"서버 오류가 발생했습니다\"}");
            }
        }
    }

    // 기술 질문 답변 API
    @PostMapping(value = "/technical-answer", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> getTechnicalAnswer(@RequestParam("question") String question, HttpSession session) {
        try {
            System.out.println("=== 기술 질문 API 호출 ===");
            System.out.println("질문: " + question);
            
            // 현재 로그인한 사용자 정보 가져오기
        AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                System.out.println("로그인되지 않은 사용자의 기술 질문 요청");
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"error\": \"로그인이 필요합니다.\"}");
        }

            System.out.println("요청 사용자 ID: " + user.getId());
            System.out.println("요청 사용자 이름: " + user.getName());
            
            long startTime = System.currentTimeMillis();
        String answer = aiService.getTechnicalAnswer(question);
            long endTime = System.currentTimeMillis();
            int responseTime = (int) ((endTime - startTime) / 1000);
            
            System.out.println("AI 응답 생성 완료. 소요 시간: " + responseTime + "초");
            System.out.println("응답 길이: " + (answer != null ? answer.length() : 0));
            
            // 질문과 답변을 데이터베이스에 저장 (올바른 사용자 ID 사용)
            Long questionId = aiService.saveQuestionAndAnswer(user.getId(), "TECHNICAL", question, answer, responseTime);
            System.out.println("데이터베이스 저장 완료. 질문 ID: " + questionId);
            
            // ObjectMapper를 사용하여 안전한 JSON 응답 생성 (UTF-8 보장)
            ObjectMapper mapper = new ObjectMapper();
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            
            Map<String, Object> response = new HashMap<>();
            response.put("answer", answer);
            response.put("responseTime", responseTime);
            
            String jsonResponse = mapper.writeValueAsString(response);
            
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
            
        } catch (IOException e) {
            System.err.println("기술 질문 답변 - JSON 처리 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"error\": \"응답 처리 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } catch (RuntimeException e) {
            System.err.println("기술 질문 답변 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"error\": \"기술 질문 답변 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    // 보고서 생성 API
    @PostMapping(value = "/generate-report", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> generateReport(
            @RequestParam String reportType,
            @RequestParam("equipments[]") String[] equipments,
            @RequestParam int teamSize,
            @RequestParam String question,
            @RequestParam String qaHistory,
            HttpSession session) {
        
        AuthDto user = (AuthDto) session.getAttribute("loginUser");
        if (user == null || "ADMIN".equals(user.getRole())) {
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"error\": \"권한이 없습니다.\"}");
        }

        try {
        List<String> equipmentList = Arrays.asList(equipments);

        // Q&A 히스토리를 파싱 (간단한 구현)
        List<TechnicalQuestionDto> qaList = new ArrayList<>();
        // 실제로는 JSON 파싱을 통해 Q&A 히스토리를 구성해야 함

        String report = aiService.generateReport(reportType, equipmentList, teamSize, question, qaList);
            
            // ObjectMapper를 사용하여 안전한 JSON 응답 생성 (UTF-8 보장)
            ObjectMapper mapper = new ObjectMapper();
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            
            Map<String, Object> response = new HashMap<>();
            response.put("report", report);
            
            String jsonResponse = mapper.writeValueAsString(response);
            
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
                
        } catch (IOException e) {
            System.err.println("보고서 생성 - JSON 처리 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"error\": \"응답 처리 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } catch (RuntimeException e) {
            System.err.println("보고서 생성 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"error\": \"보고서 생성 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    // 사용 가능한 기자재 목록 API
    @GetMapping("/equipments")
    @ResponseBody
    public List<String> getEquipments() {
        return aiService.getAvailableEquipments();
    }
    
    // 사용자 AI 질문 기록 조회 API
    @GetMapping("/my-questions")
    @ResponseBody
    public ResponseEntity<List<QuestionWithAnswerDto>> getMyQuestions(HttpSession session) {
        AuthDto user = (AuthDto) session.getAttribute("loginUser");
        if (user == null) {
            return ResponseEntity.ok(new ArrayList<>());
        }
        
        System.out.println("=== 질문 기록 조회 ===");
        System.out.println("요청 사용자 ID: " + user.getId());
        
        List<QuestionWithAnswerDto> questions = aiService.getUserQuestionsWithAnswers(user.getId());
        System.out.println("조회된 질문 개수: " + questions.size());
        
        return ResponseEntity.ok(questions);
    }
    
    // 특정 질문의 답변 조회 API
    @GetMapping(value = "/answer/{questionId}", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> getAnswer(@PathVariable Long questionId, HttpSession session) {
        AuthDto user = (AuthDto) session.getAttribute("loginUser");
        if (user == null) {
            System.out.println("로그인되지 않은 사용자의 답변 조회 시도");
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("null");
        }
        
        System.out.println("=== 답변 조회 ===");
        System.out.println("사용자 ID: " + user.getId());
        System.out.println("질문 ID: " + questionId);
        
        try {
            AiAnswer answer = aiService.getAnswerByQuestionId(questionId);
            System.out.println("답변 조회 결과: " + (answer != null ? "존재" : "없음"));
            
            // ObjectMapper를 사용하여 안전한 JSON 변환 (UTF-8 인코딩 보장)
            ObjectMapper mapper = new ObjectMapper();
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            
            String jsonResponse = mapper.writeValueAsString(answer);
            System.out.println("답변 JSON 응답 생성 완료");
            
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
        } catch (IOException e) {
            System.err.println("답변 조회 - JSON 처리 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("null");
        } catch (RuntimeException e) {
            System.err.println("답변 조회 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("null");
        }
    }
    
    // 피드백 저장 API
    @PostMapping(value = "/feedback", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> saveFeedback(@RequestBody Map<String, Object> requestData, HttpSession session) {
        AuthDto user = (AuthDto) session.getAttribute("loginUser");
        if (user == null) {
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
        }
        try {
            Long answerId = requestData.get("answerId") != null ? Long.valueOf(requestData.get("answerId").toString()) : null;
            Integer score = requestData.get("score") != null ? Integer.valueOf(requestData.get("score").toString()) : null;
            String feedbackType = (String) requestData.get("feedbackType");
            Boolean isRelevant = requestData.get("isRelevant") != null ? Boolean.valueOf(requestData.get("isRelevant").toString()) : null;
            Boolean requestedEdit = requestData.get("requestedEdit") != null ? Boolean.valueOf(requestData.get("requestedEdit").toString()) : false;
            String comment = (String) requestData.get("comment");
            if (answerId == null || score == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"필수 파라미터가 누락되었습니다.\"}");
            }
            aiService.saveFeedback(answerId, user.getId(), score, comment, feedbackType, isRelevant, requestedEdit);
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": true, \"message\": \"피드백이 저장되었습니다.\"}");
        } catch (RuntimeException e) {
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"피드백 저장 중 오류: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    // 데이터베이스 연결 테스트 API
    @GetMapping("/test-db")
    @ResponseBody
    public String testDatabase(HttpSession session) {
        AuthDto user = (AuthDto) session.getAttribute("loginUser");
        if (user == null) {
            return "{\"error\": \"로그인이 필요합니다.\"}";
        }
        
        try {
            System.out.println("=== 데이터베이스 연결 테스트 ===");
            
            // 간단한 테스트 쿼리 실행
            List<AiQuestion> questions = aiService.getUserQuestions(user.getId());
            
            return "{\"success\": true, \"message\": \"데이터베이스 연결 성공\", \"questionCount\": " + 
                   (questions != null ? questions.size() : 0) + "}";
                   
        } catch (RuntimeException e) {
            System.err.println("데이터베이스 테스트 중 오류: " + e.getMessage());
            
            String errorMsg = e.getMessage();
            if (errorMsg != null && errorMsg.contains("doesn't exist")) {
                return "{\"error\": \"AI 테이블이 존재하지 않습니다. 데이터베이스에 테이블을 생성해주세요.\"}";
            }
            
            return "{\"error\": \"데이터베이스 연결 실패: " + errorMsg + "\"}";
        }
    }

    // 데이터베이스 연결 및 질문 데이터 확인용 테스트 API
    @GetMapping("/test-questions")
    @ResponseBody
    public String testQuestions(HttpSession session) {
        try {
            StringBuilder result = new StringBuilder();
            result.append("=== 질문 데이터 테스트 ===\n");
            
            // 현재 로그인 사용자 확인
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user != null) {
                result.append("현재 사용자 ID: ").append(user.getId()).append("\n");
                result.append("현재 사용자 이름: ").append(user.getName()).append("\n");
                result.append("현재 사용자 역할: ").append(user.getRole()).append("\n");
            } else {
                result.append("로그인된 사용자 없음\n");
            }
            
            // 전체 질문 개수 확인 (모든 사용자)
            String allQuestionsQuery = "SELECT COUNT(*) as total_count FROM ai_questions";
            Integer totalCount = jdbcTemplate.queryForObject(allQuestionsQuery, Integer.class);
            result.append("전체 질문 개수: ").append(totalCount).append("\n");
            
            // 최근 5개 질문 확인 (모든 사용자)
            String recentQuestionsQuery = "SELECT id, user_id, question, created_at FROM ai_questions ORDER BY created_at DESC LIMIT 5";
            List<Map<String, Object>> recentQuestions = jdbcTemplate.queryForList(recentQuestionsQuery);
            result.append("최근 5개 질문:\n");
            for (Map<String, Object> q : recentQuestions) {
                result.append("  ID: ").append(q.get("id"))
                      .append(", 사용자ID: ").append(q.get("user_id"))
                      .append(", 질문: ").append(q.get("question"))
                      .append(", 생성일: ").append(q.get("created_at")).append("\n");
            }
            
            // 현재 사용자의 질문만 확인
            if (user != null) {
                String userQuestionsQuery = "SELECT COUNT(*) as user_count FROM ai_questions WHERE user_id = ?";
                Integer userCount = jdbcTemplate.queryForObject(userQuestionsQuery, Integer.class, user.getId());
                result.append("현재 사용자의 질문 개수: ").append(userCount).append("\n");
                
                if (userCount > 0) {
                    String userRecentQuery = "SELECT id, question, created_at FROM ai_questions WHERE user_id = ? ORDER BY created_at DESC LIMIT 3";
                    List<Map<String, Object>> userRecent = jdbcTemplate.queryForList(userRecentQuery, user.getId());
                    result.append("현재 사용자의 최근 질문:\n");
                    for (Map<String, Object> q : userRecent) {
                        result.append("  ID: ").append(q.get("id"))
                              .append(", 질문: ").append(q.get("question"))
                              .append(", 생성일: ").append(q.get("created_at")).append("\n");
                    }
                }
            }
            
            return result.toString();
            
        } catch (RuntimeException e) {
            return "테스트 중 오류 발생: " + e.getMessage() + "\n" + 
                   "오류 타입: " + e.getClass().getSimpleName();
        }
    }

    // 기존 질문 데이터의 사용자 ID를 현재 로그인 사용자로 업데이트하는 임시 API
    @GetMapping("/update-question-user-id")
    @ResponseBody
    public String updateQuestionUserId(HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return "로그인이 필요합니다.";
            }
            
            System.out.println("=== 질문 사용자 ID 업데이트 ===");
            System.out.println("현재 로그인 사용자 ID: " + user.getId());
            
            // 사용자 ID가 4인 질문들을 현재 로그인 사용자 ID로 업데이트
            String updateQuery = "UPDATE ai_questions SET user_id = ? WHERE user_id = 4";
            int updatedCount = jdbcTemplate.update(updateQuery, user.getId());
            
            System.out.println("업데이트된 질문 개수: " + updatedCount);
            
            return "성공: " + updatedCount + "개의 질문이 사용자 ID " + user.getId() + "로 업데이트되었습니다.";
            
        } catch (RuntimeException e) {
            System.err.println("질문 사용자 ID 업데이트 중 오류: " + e.getMessage());
            return "오류: " + e.getMessage();
        }
    }
    
    // 첨부파일 확인 API
    @GetMapping("/test-files")
    @ResponseBody
    public String testFiles(HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return "로그인이 필요합니다.";
            }
            
            StringBuilder result = new StringBuilder();
            result.append("=== 첨부파일 테스트 ===\n");
            
            String filesQuery = "SELECT f.*, q.question FROM ai_question_files f " +
                               "JOIN ai_questions q ON f.question_id = q.id " +
                               "WHERE q.user_id = ? ORDER BY f.uploaded_at DESC LIMIT 10";
            
            List<Map<String, Object>> files = jdbcTemplate.queryForList(filesQuery, user.getId());
            result.append("사용자의 첨부파일 개수: ").append(files.size()).append("\n");
            
            for (Map<String, Object> file : files) {
                result.append("파일: ").append(file.get("original_file_name"))
                      .append(", 크기: ").append(file.get("file_size"))
                      .append(", 질문: ").append(file.get("question"))
                      .append("\n");
            }
            
            return result.toString();
            
        } catch (RuntimeException e) {
            return "테스트 중 오류: " + e.getMessage();
        }
    }

    // 응답 클래스들
    public static class ProjectRecommendationResponse {
        private String recommendation;
        
        public ProjectRecommendationResponse(String recommendation) {
            this.recommendation = recommendation;
        }
        
        public String getRecommendation() {
            return recommendation;
        }
        
        public void setRecommendation(String recommendation) {
            this.recommendation = recommendation;
        }
    }
    
    public static class TechnicalAnswerResponse {
        private String answer;
        
        public TechnicalAnswerResponse(String answer) {
            this.answer = answer;
        }
        
        public String getAnswer() {
            return answer;
        }
        
        public void setAnswer(String answer) {
            this.answer = answer;
        }
    }

    // 새로운 통합 AI 질문 API (파일 업로드 지원)
    @PostMapping(value = "/ask", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> askAi(
            @RequestParam("question") String question,
            @RequestParam(value = "files", required = false) MultipartFile[] files,
            HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            }
            
            System.out.println("=== AI 질문 API 호출 (파일 지원) ===");
            System.out.println("사용자 ID: " + user.getId());
            System.out.println("질문: " + question);
            System.out.println("첨부파일 개수: " + (files != null ? files.length : 0));
            
            if (question == null || question.trim().isEmpty()) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"질문이 비어있습니다.\"}");
            }
            
            long startTime = System.currentTimeMillis();
            String answer = aiService.getTechnicalAnswer(question);
            long endTime = System.currentTimeMillis();
            int responseTime = (int) ((endTime - startTime) / 1000);
            
            Long questionId = aiService.saveQuestionAndAnswer(
                user.getId(), "TECHNICAL", question, answer, responseTime
            );
            
            // 첨부파일 처리
            if (files != null && files.length > 0 && questionId != null) {
                for (MultipartFile file : files) {
                    if (!file.isEmpty()) {
                        try {
                            String savedFilePath = saveUploadedFile(file);
                            aiService.saveQuestionFile(questionId, savedFilePath, file.getOriginalFilename(), 
                                                     file.getContentType(), file.getSize());
                            System.out.println("첨부파일 저장 완료: " + file.getOriginalFilename());
                        } catch (IOException e) {
                            System.err.println("첨부파일 저장 실패 (파일 처리): " + file.getOriginalFilename() + " - " + e.getMessage());
                        } catch (RuntimeException e) {
                            System.err.println("첨부파일 저장 실패 (데이터베이스): " + file.getOriginalFilename() + " - " + e.getMessage());
                        }
                    }
                }
            }
            
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("answer", answer);
            response.put("questionId", questionId);
            response.put("answeredInSeconds", responseTime);
            String jsonResponse = mapper.writeValueAsString(response);
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
        } catch (IOException e) {
            System.err.println("파일 처리 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"파일 처리 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } catch (RuntimeException e) {
            System.err.println("AI 질문 처리 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"AI 질문 처리 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
    
    // JSON 형태 AI 질문 API (기존 호환성 유지)
    @PostMapping(value = "/ask-json", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> askAiJson(@RequestBody Map<String, Object> requestData, HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            }
            
            // 크레딧 체크 (질문당 5 크레딧 필요)
            final int CREDITS_PER_QUESTION = 5;
            if (!aiService.hasEnoughCredits(user.getId(), CREDITS_PER_QUESTION)) {
                ObjectMapper mapper = new ObjectMapper();
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "AI 크레딧이 부족합니다. 관리자에게 문의하세요.");
                response.put("errorCode", "INSUFFICIENT_CREDITS");
                
                UserAiCreditDto credit = aiService.getUserCredit(user.getId());
                response.put("remainingCredits", credit.getRemainingCredits());
                
                String jsonResponse = mapper.writeValueAsString(response);
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(jsonResponse);
            }
            
            String question = (String) requestData.get("question");
            if (question == null || question.trim().isEmpty()) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"질문이 비어있습니다.\"}");
            }
            
            long startTime = System.currentTimeMillis();
            String answer = aiService.getTechnicalAnswer(question);
            long endTime = System.currentTimeMillis();
            int responseTime = (int) ((endTime - startTime) / 1000);
            Long questionId = aiService.saveQuestionAndAnswer(
                user.getId(), "TECHNICAL", question, answer, responseTime
            );
            
            // 크레딧 차감
            aiService.useCredits(user.getId(), CREDITS_PER_QUESTION, questionId, "AI 질문: " + question.substring(0, Math.min(50, question.length())));
            
            // 남은 크레딧 조회
            UserAiCreditDto credit = aiService.getUserCredit(user.getId());
            
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("answer", answer);
            response.put("questionId", questionId);
            response.put("answeredInSeconds", responseTime);
            response.put("creditsUsed", CREDITS_PER_QUESTION);
            response.put("remainingCredits", credit.getRemainingCredits());
            
            String jsonResponse = mapper.writeValueAsString(response);
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
        } catch (IOException e) {
            System.err.println("JSON 처리 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"응답 처리 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } catch (RuntimeException e) {
            System.err.println("AI 질문 처리 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"AI 질문 처리 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    @GetMapping("/history")
    @ResponseBody
    public List<AiHistoryDto> getHistory(HttpSession session, @RequestParam(defaultValue = "20") int limit) {
        AuthDto user = (AuthDto) session.getAttribute("loginUser");
        if (user == null) return new ArrayList<>();
        return aiService.getUserHistory(user.getId(), limit);
    }

    @GetMapping("/history/{questionId}")
    @ResponseBody
    public Map<String, Object> getHistoryDetail(@PathVariable Long questionId, HttpSession session) {
        AuthDto user = (AuthDto) session.getAttribute("loginUser");
        if (user == null) return new HashMap<>();
        AiHistoryDto dto = aiService.getHistoryByQuestionId(questionId);
        if (dto == null || !dto.getUserId().equals(user.getId())) return new HashMap<>();
        // 질문, 답변, 생성일 등 모든 정보 포함해서 반환
        Map<String, Object> result = new HashMap<>();
        result.put("questionId", dto.getQuestionId());
        result.put("question", dto.getQuestion());
        result.put("answer", dto.getAnswer());
        result.put("createdAt", dto.getQuestionCreatedAt());
        result.put("category", dto.getCategory());
        return result;
    }

    @DeleteMapping("/history/{questionId}")
    @ResponseBody
    public Map<String, Object> deleteHistory(@PathVariable Long questionId, HttpSession session) {
        AuthDto user = (AuthDto) session.getAttribute("loginUser");
        if (user == null) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        AiHistoryDto dto = aiService.getHistoryByQuestionId(questionId);
        if (dto == null || !dto.getUserId().equals(user.getId())) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "권한 없음");
            return result;
        }
        aiService.deleteHistoryByQuestionId(questionId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        return result;
    }
    
    // 질문 삭제 API
    @DeleteMapping("/question/{questionId}")
    @ResponseBody
    public ResponseEntity<String> deleteQuestion(@PathVariable Long questionId, HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            }
            
            System.out.println("=== 질문 삭제 요청 ===");
            System.out.println("질문 ID: " + questionId + ", 사용자 ID: " + user.getId());
            
            boolean deleted = aiService.deleteQuestion(questionId, user.getId());
            
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> response = new HashMap<>();
            
            if (deleted) {
                response.put("success", true);
                response.put("message", "질문이 성공적으로 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "질문 삭제에 실패했습니다. 권한이 없거나 존재하지 않는 질문입니다.");
            }
            
            String jsonResponse = mapper.writeValueAsString(response);
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
                
        } catch (IOException e) {
            System.err.println("JSON 처리 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"응답 처리 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } catch (RuntimeException e) {
            System.err.println("질문 삭제 API 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"서버 오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }

    @GetMapping("/statistics")
    @ResponseBody
    public Map<String, Object> getStatistics(HttpSession session) {
        AuthDto user = (AuthDto) session.getAttribute("loginUser");
        Map<String, Object> stats = new HashMap<>();
        if (user == null) {
            stats.put("totalQuestions", 0);
            stats.put("monthlyQuestions", 0);
            return stats;
        }
        stats.put("totalQuestions", aiService.getUserTotalQuestions(user.getId().toString()));
        stats.put("monthlyQuestions", aiService.getUserMonthlyQuestions(user.getId().toString()));
        
        // 크레딧 정보 추가
        try {
            UserAiCreditDto credit = aiService.getUserCredit(user.getId());
            stats.put("totalCredits", credit.getTotalCredits());
            stats.put("usedCredits", credit.getUsedCredits());
            stats.put("remainingCredits", credit.getRemainingCredits());
        } catch (Exception e) {
            stats.put("totalCredits", 0);
            stats.put("usedCredits", 0);
            stats.put("remainingCredits", 0);
        }
        
        return stats;
    }
    
    /**
     * 사용자 크레딧 정보 조회 API
     */
    @GetMapping(value = "/credits", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> getUserCredits(HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            }
            
            UserAiCreditDto credit = aiService.getUserCredit(user.getId());
            
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("totalCredits", credit.getTotalCredits());
            response.put("usedCredits", credit.getUsedCredits());
            response.put("remainingCredits", credit.getRemainingCredits());
            response.put("lastRechargedAt", credit.getLastRechargedAt());
            
            String jsonResponse = mapper.writeValueAsString(response);
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
        } catch (IOException e) {
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"응답 처리 중 오류가 발생했습니다.\"}");
        } catch (RuntimeException e) {
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"크레딧 조회 중 오류가 발생했습니다.\"}");
        }
    }
    
    /**
     * 크레딧 사용 내역 조회 API
     */
    @GetMapping(value = "/credit-logs", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> getCreditLogs(
            @RequestParam(defaultValue = "20") int limit,
            HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            }
            
            List<AiCreditLogDto> logs = aiService.getCreditLogs(user.getId(), limit);
            
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("logs", logs);
            response.put("totalCount", logs.size());
            
            String jsonResponse = mapper.writeValueAsString(response);
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
        } catch (IOException e) {
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"응답 처리 중 오류가 발생했습니다.\"}");
        } catch (RuntimeException e) {
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"로그 조회 중 오류가 발생했습니다.\"}");
        }
    }

    // 첨부파일 다운로드 API
    @GetMapping("/download/{questionId}/{fileIndex}")
    @ResponseBody
    public ResponseEntity<Resource> downloadFile(
            @PathVariable Long questionId, 
            @PathVariable int fileIndex,
            HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return ResponseEntity.notFound().build();
            }
            
            System.out.println("파일 다운로드 요청 - 질문ID: " + questionId + ", 파일인덱스: " + fileIndex);
            
            // 질문의 첨부파일 목록 조회
            List<AttachmentFileDto> attachments = aiService.getAttachmentsByQuestionId(questionId);
            if (attachments == null || fileIndex >= attachments.size()) {
                System.out.println("첨부파일을 찾을 수 없음");
                return ResponseEntity.notFound().build();
            }
            
            AttachmentFileDto attachment = attachments.get(fileIndex);
            
            // 파일 경로 확인 및 읽기
            Path filePath = Paths.get(attachment.getFilePath());
            if (!Files.exists(filePath)) {
                System.out.println("실제 파일이 존재하지 않음: " + filePath);
                return ResponseEntity.notFound().build();
            }
            
            byte[] fileBytes = Files.readAllBytes(filePath);
            ByteArrayResource resource = new ByteArrayResource(fileBytes);
            
            // 헤더 설정
            HttpHeaders headers = new HttpHeaders();
            String encodedFilename = URLEncoder.encode(attachment.getOriginalFileName(), "UTF-8")
                                                .replaceAll("\\+", "%20");
            headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encodedFilename);
            
            // 미디어 타입 설정
            MediaType mediaType = MediaType.APPLICATION_OCTET_STREAM;
            if (attachment.getFileType() != null) {
                try {
                    mediaType = MediaType.parseMediaType(attachment.getFileType());
                } catch (Exception e) {
                    // 파싱 실패 시 기본값 사용
                }
            }
            
            System.out.println("파일 다운로드 성공: " + attachment.getOriginalFileName());
            
            return ResponseEntity.ok()
                .headers(headers)
                .contentLength(attachment.getFileSize())
                .contentType(mediaType)
                .body(resource);
                
        } catch (IOException e) {
            System.err.println("파일 다운로드 - 파일 처리 중 오류: " + e.getMessage());
            return ResponseEntity.notFound().build();
        } catch (RuntimeException e) {
            System.err.println("파일 다운로드 - 시스템 오류: " + e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }
    
    // 프로젝트 상세 정보 조회 API
    @GetMapping("/project/{projectId}")
    @ResponseBody
    public ResponseEntity<String> getProjectDetail(@PathVariable Long projectId, HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            }
            
            System.out.println("프로젝트 상세 정보 조회: " + projectId);
            
            com.example.test.project.ProjectDetailDto projectDetail = projectService.getProjectDetail(projectId);
            if (projectDetail == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"프로젝트를 찾을 수 없습니다.\"}");
            }
            
            // ObjectMapper를 사용하여 안전한 JSON 변환
            ObjectMapper mapper = new ObjectMapper();
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("project", projectDetail.getProject());
            response.put("members", projectDetail.getMembers());
            response.put("tasks", projectDetail.getTasks());
            
            String jsonResponse = mapper.writeValueAsString(response);
            
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
                
        } catch (IOException e) {
            System.err.println("JSON 처리 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"응답 처리 중 오류가 발생했습니다.\"}");
        } catch (RuntimeException e) {
            System.err.println("프로젝트 상세 정보 조회 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"프로젝트 정보 조회 중 오류가 발생했습니다.\"}");
        }
    }
    
    // 프로젝트 기반 AI 상담 API
    @PostMapping(value = "/project-chat", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> projectChat(
            @RequestParam("projectId") Long projectId,
            @RequestParam("question") String question,
            @RequestParam(value = "files", required = false) MultipartFile[] files,
            HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            }
            
            System.out.println("=== 프로젝트 기반 AI 상담 ===");
            System.out.println("프로젝트 ID: " + projectId);
            System.out.println("질문: " + question);
            
            // 프로젝트 정보 조회
            com.example.test.project.ProjectDetailDto projectDetail = projectService.getProjectDetail(projectId);
            if (projectDetail == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"프로젝트를 찾을 수 없습니다.\"}");
            }
            
            // 프로젝트 정보를 포함한 AI 질문 생성
            String projectInfo = String.format(
                "프로젝트 정보:\n" +
                "- 제목: %s\n" +
                "- 설명: %s\n" +
                "- 팀원 수: %d명\n" +
                "- 진행 작업 수: %d개\n" +
                "\n" +
                "질문: %s",
                projectDetail.getProject().getTitle(),
                projectDetail.getProject().getDescription() != null ? projectDetail.getProject().getDescription() : "설명 없음",
                projectDetail.getMembers().size(),
                projectDetail.getTasks().size(),
                question
            );
            
            long startTime = System.currentTimeMillis();
            String answer = aiService.getTechnicalAnswer(projectInfo);
            long endTime = System.currentTimeMillis();
            int responseTime = (int) ((endTime - startTime) / 1000);
            
            // 질문과 답변 저장
            Long questionId = aiService.saveQuestionAndAnswer(user.getId(), "PROJECT", projectInfo, answer, responseTime);
            
            // 첨부파일 처리
            if (files != null && files.length > 0) {
                for (MultipartFile file : files) {
                    if (!file.isEmpty()) {
                        try {
                            String savedFilePath = saveUploadedFile(file);
                            aiService.saveQuestionFile(questionId, savedFilePath, file.getOriginalFilename(), 
                                                     file.getContentType(), file.getSize());
                        } catch (IOException e) {
                            System.err.println("첨부파일 저장 실패: " + e.getMessage());
                        }
                    }
                }
            }
            
            // 응답 생성
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("answer", answer);
            response.put("questionId", questionId);
            response.put("responseTime", responseTime);
            
            String jsonResponse = mapper.writeValueAsString(response);
            
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
                
        } catch (IOException e) {
            System.err.println("프로젝트 AI 상담 - 파일 처리 중 오류: " + e.getMessage());
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "파일 처리 중 오류가 발생했습니다: " + e.getMessage());
            
            try {
                String errorJson = mapper.writeValueAsString(errorResponse);
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(errorJson);
            } catch (IOException jsonError) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"서버 오류가 발생했습니다\"}");
            }
        } catch (RuntimeException e) {
            System.err.println("프로젝트 AI 상담 중 오류: " + e.getMessage());
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "AI 상담 중 오류가 발생했습니다: " + e.getMessage());
            
            try {
                String errorJson = mapper.writeValueAsString(errorResponse);
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(errorJson);
            } catch (IOException jsonError) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"서버 오류가 발생했습니다\"}");
            }
        }
    }
    
    // JSON 기반 프로젝트 AI 상담 API (모달용)
    @PostMapping(value = "/project-chat-json", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> projectChatJson(@RequestBody Map<String, Object> requestData, HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            }
            
            String projectId = (String) requestData.get("projectId");
            String question = (String) requestData.get("question");
            @SuppressWarnings("unchecked")
            Map<String, Object> context = (Map<String, Object>) requestData.get("context");
            
            System.out.println("=== 프로젝트 AI 상담 (JSON) ===");
            System.out.println("사용자: " + user.getName());
            System.out.println("프로젝트 ID: " + projectId);
            System.out.println("질문: " + question);
            
            // 프로젝트 컨텍스트를 포함한 프롬프트 생성
            StringBuilder promptBuilder = new StringBuilder();
            
            promptBuilder.append("=== 프로젝트 AI 상담 ===\n");
            promptBuilder.append("당신은 대학교 연구실의 프로젝트 관리 AI 상담사입니다.\n\n");
            
            if (context != null) {
                promptBuilder.append("=== 현재 프로젝트 정보 ===\n");
                promptBuilder.append("프로젝트명: ").append(context.get("projectTitle")).append("\n");
                promptBuilder.append("진행 상태: ").append(context.get("projectStatus")).append("\n");
                promptBuilder.append("팀원 수: ").append(context.get("memberCount")).append("명\n");
                promptBuilder.append("작업 수: ").append(context.get("taskCount")).append("개\n");
                
                // 기자재 정보 추가
                Object equipmentCountObj = context.get("equipmentCount");
                int equipmentCount = (equipmentCountObj != null) ? Integer.parseInt(equipmentCountObj.toString()) : 0;
                promptBuilder.append("등록된 기자재 수: ").append(equipmentCount).append("개\n");
                
                System.out.println("기자재 정보 처리 - 개수: " + equipmentCount);
                System.out.println("기자재 데이터 존재 여부: " + (context.get("equipments") != null));
                
                if (equipmentCount > 0 && context.get("equipments") != null) {
                    promptBuilder.append("\n=== ⚠️ 중요: 프로젝트에 등록된 기자재 목록 ⚠️ ===\n");
                    promptBuilder.append("!!! 답변 시 아래 기자재들의 **정확한 이름**을 반드시 언급하세요 !!!\n\n");
                    
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> equipments = (List<Map<String, Object>>) context.get("equipments");
                    
                    System.out.println("기자재 목록 크기: " + equipments.size());
                    
                    for (int i = 0; i < equipments.size(); i++) {
                        Map<String, Object> equipment = equipments.get(i);
                        System.out.println("기자재 " + (i + 1) + " 데이터: " + equipment);
                        
                        String name = (String) equipment.get("name");
                        String renter = (String) equipment.get("renter");
                        String purpose = (String) equipment.get("purpose");
                        
                        System.out.println("추출된 정보 - 이름: " + name + ", 대여자: " + renter + ", 목적: " + purpose);
                        
                        promptBuilder.append("📋 ").append(i + 1).append(". ");
                        promptBuilder.append("**").append(name != null ? name : "정보없음").append("** ");
                        promptBuilder.append("(대여자: ").append(renter != null ? renter : "정보없음").append(", ");
                        promptBuilder.append("사용목적: ").append(purpose != null ? purpose : "미지정").append(")\n");
                    }
                    
                    promptBuilder.append("\n💡 이 기자재들의 **구체적인 이름**을 반드시 답변에 포함하세요!\n");
                } else {
                    System.out.println("기자재 정보 없음 - 카운트: " + equipmentCount + ", 데이터: " + context.get("equipments"));
                    promptBuilder.append("\n=== 기자재 정보 ===\n");
                    promptBuilder.append("현재 프로젝트에 등록된 기자재가 없습니다.\n");
                }
                promptBuilder.append("\n");
                
                // 채팅 히스토리 추가 (최근 대화 참고)
                if (context.get("chatHistory") != null) {
                    promptBuilder.append("=== 최근 대화 내용 ===\n");
                    @SuppressWarnings("unchecked")
                    List<Map<String, Object>> history = (List<Map<String, Object>>) context.get("chatHistory");
                    for (Map<String, Object> msg : history) {
                        String type = (String) msg.get("type");
                        String message = (String) msg.get("message");
                        if ("user".equals(type)) {
                            promptBuilder.append("사용자: ").append(message).append("\n");
                        } else {
                            promptBuilder.append("AI: ").append(message).append("\n");
                        }
                    }
                    promptBuilder.append("\n");
                }
            }
            
            promptBuilder.append("=== 사용자 질문 ===\n");
            promptBuilder.append(question).append("\n\n");
            
            promptBuilder.append("=== 답변 지침 ===\n");
            promptBuilder.append("- 위 프로젝트 정보를 바탕으로 구체적이고 실용적인 답변을 제공하세요\n");
            promptBuilder.append("- 프로젝트 관리, 팀워크, 기술적 조언을 포함하세요\n");
            promptBuilder.append("- 기자재 관련 질문의 경우, 위에 나열된 **구체적인 기자재명**을 반드시 언급하여 답변하세요\n");
            promptBuilder.append("- 기자재 목록이 있다면 '굴삭', '시발아' 등 실제 기자재명을 명시적으로 사용하세요\n");
            promptBuilder.append("- 단순히 '기자재'라고만 말하지 말고, 각 기자재의 이름을 구체적으로 언급하세요\n");
            promptBuilder.append("- 답변은 친근하고 도움이 되는 톤으로 작성하세요\n");
            promptBuilder.append("- 가능하다면 구체적인 액션 아이템을 제안하세요\n");
            promptBuilder.append("- 한국어로 답변하세요\n");
            
            String finalPrompt = promptBuilder.toString();
            
            System.out.println("AI 프롬프트 생성 완료 (길이: " + finalPrompt.length() + ")");
            System.out.println("=== 생성된 AI 프롬프트 ===");
            System.out.println(finalPrompt);
            System.out.println("=== 프롬프트 끝 ===");
            
            long startTime = System.currentTimeMillis();
            String answer = aiService.getTechnicalAnswer(finalPrompt);
            long endTime = System.currentTimeMillis();
            int responseTime = (int) ((endTime - startTime) / 1000);
            
            System.out.println("AI 응답 생성 완료 (소요시간: " + responseTime + "초, 응답길이: " + answer.length() + ")");
            
            // 질문과 답변 저장
            String questionForDb = "프로젝트 AI 상담: " + question;
            Long questionId = aiService.saveQuestionAndAnswer(user.getId(), "PROJECT", questionForDb, answer, responseTime);
            
            // 응답 생성
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("answer", answer);
            response.put("questionId", questionId);
            response.put("responseTime", responseTime);
            response.put("projectId", projectId);
            
            String jsonResponse = mapper.writeValueAsString(response);
            
            System.out.println("JSON 응답 생성 완료");
            
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
                
        } catch (IOException e) {
            System.err.println("프로젝트 AI 상담 (JSON) - JSON 처리 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"응답 처리 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } catch (RuntimeException e) {
            System.err.println("프로젝트 AI 상담 (JSON) 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"AI 상담 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.\"}");
        }
    }
    
    // 프로젝트 보고서 생성 API
    @PostMapping(value = "/generate-project-report", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> generateProjectReport(
            @RequestParam("projectId") Long projectId,
            @RequestParam("reportType") String reportType,
            HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            }
            
            System.out.println("=== 프로젝트 보고서 생성 ===");
            System.out.println("프로젝트 ID: " + projectId);
            System.out.println("보고서 유형: " + reportType);
            
            // 프로젝트 정보 조회
            com.example.test.project.ProjectDetailDto projectDetail = projectService.getProjectDetail(projectId);
            if (projectDetail == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"프로젝트를 찾을 수 없습니다.\"}");
            }
            
            // 보고서 생성 프롬프트 작성
            String reportPrompt = String.format(
                "다음 프로젝트 정보를 바탕으로 %s를 작성해주세요.\n" +
                "\n" +
                "프로젝트 정보:\n" +
                "- 제목: %s\n" +
                "- 설명: %s\n" +
                "- 팀원 수: %d명\n" +
                "- 진행 작업 수: %d개\n" +
                "- 상태: %s\n" +
                "\n" +
                "보고서는 다음 형식으로 작성해주세요:\n" +
                "1. 프로젝트 개요\n" +
                "2. 팀원 구성 및 역할\n" +
                "3. 진행 상황\n" +
                "4. 주요 성과\n" +
                "5. 향후 계획\n" +
                "6. 결론\n" +
                "\n" +
                "전문적이고 체계적인 보고서로 작성해주세요.",
                reportType,
                projectDetail.getProject().getTitle(),
                projectDetail.getProject().getDescription() != null ? projectDetail.getProject().getDescription() : "설명 없음",
                projectDetail.getMembers().size(),
                projectDetail.getTasks().size(),
                projectDetail.getProject().getStatus() != null ? projectDetail.getProject().getStatus() : "진행중"
            );
            
            long startTime = System.currentTimeMillis();
            String report = aiService.getTechnicalAnswer(reportPrompt);
            long endTime = System.currentTimeMillis();
            int responseTime = (int) ((endTime - startTime) / 1000);
            
            // 보고서 생성 기록 저장
            String questionText = "프로젝트 보고서 생성 요청 (" + reportType + ")";
            Long questionId = aiService.saveQuestionAndAnswer(user.getId(), "PROJECT", questionText, report, responseTime);
            
            // 응답 생성
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("report", report);
            response.put("questionId", questionId);
            response.put("responseTime", responseTime);
            
            String jsonResponse = mapper.writeValueAsString(response);
            
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
                
        } catch (IOException e) {
            System.err.println("프로젝트 보고서 생성 - JSON 처리 중 오류: " + e.getMessage());
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "응답 처리 중 오류가 발생했습니다: " + e.getMessage());
            
            try {
                String errorJson = mapper.writeValueAsString(errorResponse);
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(errorJson);
            } catch (IOException jsonError) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"서버 오류가 발생했습니다\"}");
            }
        } catch (RuntimeException e) {
            System.err.println("프로젝트 보고서 생성 중 오류: " + e.getMessage());
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", "보고서 생성 중 오류가 발생했습니다: " + e.getMessage());
            
            try {
                String errorJson = mapper.writeValueAsString(errorResponse);
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(errorJson);
            } catch (IOException jsonError) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"서버 오류가 발생했습니다\"}");
            }
        }
    }
    
    // 프로젝트 채팅 기록 조회 API
    @GetMapping(value = "/project-chat-history/{projectId}", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public ResponseEntity<String> getProjectChatHistory(@PathVariable Long projectId, HttpSession session) {
        try {
            AuthDto user = (AuthDto) session.getAttribute("loginUser");
            if (user == null) {
                return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .body("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            }
            
            System.out.println("=== 프로젝트 채팅 기록 조회 ===");
            System.out.println("사용자: " + user.getName() + " (ID: " + user.getId() + ")");
            System.out.println("프로젝트 ID: " + projectId);
            
            // 프로젝트 관련 AI 질문/답변 기록 조회
            String sql = "SELECT " +
                "    q.id as question_id," +
                "    q.question," +
                "    q.created_at as question_time," +
                "    a.answer," +
                "    a.created_at as answer_time " +
                "FROM ai_questions q " +
                "LEFT JOIN ai_answers a ON q.id = a.question_id " +
                "WHERE q.user_id = ? " +
                "  AND q.context_type = 'PROJECT' " +
                "  AND (q.question LIKE CONCAT('%프로젝트 ID: ', ?, '%') " +
                "       OR q.question LIKE '%프로젝트 AI 상담%') " +
                "ORDER BY q.created_at ASC " +
                "LIMIT 20";
            
            List<Map<String, Object>> conversations = jdbcTemplate.queryForList(sql, user.getId(), projectId);
            
            System.out.println("조회된 대화 기록: " + conversations.size() + "개");
            
            // 응답 포맷 변환
            List<Map<String, Object>> formattedConversations = new ArrayList<>();
            for (Map<String, Object> conv : conversations) {
                Map<String, Object> conversation = new HashMap<>();
                String question = (String) conv.get("question");
                
                // 프로젝트 관련 질문에서 실제 질문 부분만 추출
                if (question != null && question.contains("프로젝트 AI 상담:")) {
                    question = question.substring(question.indexOf("프로젝트 AI 상담:") + "프로젝트 AI 상담:".length()).trim();
                }
                
                conversation.put("question", question);
                conversation.put("answer", conv.get("answer"));
                conversation.put("questionTime", conv.get("question_time"));
                conversation.put("answerTime", conv.get("answer_time"));
                
                formattedConversations.add(conversation);
            }
            
            // 응답 생성
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("conversations", formattedConversations);
            response.put("totalCount", formattedConversations.size());
            
            String jsonResponse = mapper.writeValueAsString(response);
            
            System.out.println("채팅 기록 조회 완료");
            
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(jsonResponse);
                
        } catch (IOException e) {
            System.err.println("채팅 기록 조회 - JSON 처리 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"응답 처리 중 오류가 발생했습니다: " + e.getMessage().replace("\"", "\\\"") + "\"}");
        } catch (RuntimeException e) {
            System.err.println("채팅 기록 조회 중 오류: " + e.getMessage());
            return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body("{\"success\": false, \"message\": \"채팅 기록 조회 중 오류가 발생했습니다.\"}");
        }
    }
} 