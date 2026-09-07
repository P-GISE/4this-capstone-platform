package com.example.test.ai;

import java.io.IOException;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

@Service
public class AiService {

    @Autowired
    private AiQuestionRepository aiQuestionRepository;
    
    @Autowired
    private AiAnswerRepository aiAnswerRepository;
    
    @Autowired
    private AiFeedbackRepository aiFeedbackRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private AiHistoryRepository aiHistoryRepository;
    
    @Autowired
    private com.example.test.equipment.EquipmentService equipmentService;
    
    @Autowired
    private com.example.test.ai.mapper.AiCreditMapper aiCreditMapper;

    // @Value("${anthropic.api.key}")
    // private String anthropicApiKey;
    private final String anthropicApiKey = AnthropicApiConfig.getApiKey();

    private static final String ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";
    private static final String MODEL = "claude-3-haiku-20240307";

    public void streamAiAnswer(String prompt, String userId, Writer writer) throws IOException {
        long startTime = System.currentTimeMillis();
        String answer = getTechnicalAnswer(prompt);
        long endTime = System.currentTimeMillis();
        int answeredInSeconds = (int) ((endTime - startTime) / 1000);
        
        writer.write(new String(answer.getBytes(StandardCharsets.UTF_8), StandardCharsets.UTF_8));
        writer.flush();
        saveQuestionAndAnswer(Long.valueOf(userId), "PROJECT", prompt, answer, answeredInSeconds);
    }

    public String getProjectRecommendation(List<String> equipments, int teamSize, String question) {
        try {
            String prompt = String.format(
                "당신은 캡스톤 프로젝트 추천 전문가입니다. 다음 정보를 바탕으로 창의적이고 실현 가능한 프로젝트를 추천해주세요.\n\n" +
                "선택된 기자재: %s\n" +
                "팀원 수: %d명\n" +
                "질문/요구사항: %s\n\n" +
                "다음 형식으로 답변해주세요:\n" +
                "1. 프로젝트 제목\n" +
                "2. 프로젝트 개요 (2-3줄)\n" +
                "3. 주요 기능 (3-4개)\n" +
                "4. 기술적 구현 방법\n" +
                "5. 예상 개발 기간\n" +
                "6. 주의사항 및 팁\n\n" +
                "답변은 한국어로 작성하고, 실제 구현 가능한 수준으로 제안해주세요.",
                String.join(", ", equipments), teamSize, question);

            return callAnthropicAPI(prompt);
        } catch (IOException e) {
            System.err.println("프로젝트 추천 - API 통신 오류: " + e.getMessage());
            return "프로젝트 추천 중 네트워크 오류가 발생했습니다: " + e.getMessage();
        } catch (RuntimeException e) {
            System.err.println("프로젝트 추천 - 시스템 오류: " + e.getMessage());
            return "프로젝트 추천 중 시스템 오류가 발생했습니다: " + e.getMessage();
        }
    }

    public String getTechnicalAnswer(String question) {
        try {
            String prompt = String.format(
                "당신은 IT 기술 전문가입니다. 다음 기술 질문에 대해 정확하고 이해하기 쉽게 답변해주세요.\n\n" +
                "질문: %s\n\n" +
                "답변 시 다음 사항을 포함해주세요:\n" +
                "1. 핵심 개념 설명\n" +
                "2. 실제 구현 예시 (코드 포함 가능)\n" +
                "3. 주의사항이나 베스트 프랙티스\n" +
                "4. 관련 참고 자료나 추가 학습 방향\n\n" +
                "답변은 한국어로 작성하고, 초보자도 이해할 수 있도록 친절하게 설명해주세요.",
                question);

            return callAnthropicAPI(prompt);
        } catch (IOException e) {
            System.err.println("기술 질문 답변 - API 통신 오류: " + e.getMessage());
            return "기술 질문 답변 중 네트워크 오류가 발생했습니다: " + e.getMessage();
        } catch (RuntimeException e) {
            System.err.println("기술 질문 답변 - 시스템 오류: " + e.getMessage());
            return "기술 질문 답변 중 시스템 오류가 발생했습니다: " + e.getMessage();
        }
    }

    public String generateReport(String reportType, List<String> equipments, int teamSize, 
                               String question, List<TechnicalQuestionDto> qaHistory) {
        try {
            StringBuilder qaText = new StringBuilder();
            for (TechnicalQuestionDto qa : qaHistory) {
                qaText.append(String.format("Q: %s\nA: %s\n", qa.getQuestion(), qa.getAnswer()));
            }

            String prompt = String.format(
                "아래 정보를 바탕으로 %s를 한글로 작성해줘.\n" +
                "[프로젝트 정보]\n" +
                "기자재: %s\n" +
                "팀원 수: %d\n" +
                "질문: %s\n" +
                "[Q&A]\n" +
                "%s",
                reportType, String.join(", ", equipments), teamSize, question, qaText.toString());

            return callAnthropicAPI(prompt);
        } catch (IOException e) {
            System.err.println("보고서 생성 - API 통신 오류: " + e.getMessage());
            return "보고서 생성 중 네트워크 오류가 발생했습니다: " + e.getMessage();
        } catch (RuntimeException e) {
            System.err.println("보고서 생성 - 시스템 오류: " + e.getMessage());
            return "보고서 생성 중 시스템 오류가 발생했습니다: " + e.getMessage();
        }
    }

    private String callAnthropicAPI(String prompt) throws IOException {
        OkHttpClient client = new OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(60, TimeUnit.SECONDS)
            .writeTimeout(60, TimeUnit.SECONDS)
            .build();

        JsonObject root = new JsonObject();
        root.addProperty("model", MODEL);
        root.addProperty("max_tokens", 1000); // 비용 절감을 위해 토큰 수 감소

        JsonArray messages = new JsonArray();
        JsonObject msg = new JsonObject();
        msg.addProperty("role", "user");
        msg.addProperty("content", prompt);
        messages.add(msg);
        root.add("messages", messages);

        String jsonBody = root.toString();
        System.out.println("API 요청 본문 길이: " + jsonBody.length());

        // UTF-8 인코딩으로 요청 본문 생성
        RequestBody body = RequestBody.create(jsonBody, MediaType.parse("application/json; charset=UTF-8"));
        Request request = new Request.Builder()
                .url(ANTHROPIC_URL)
                .addHeader("x-api-key", anthropicApiKey)
                .addHeader("anthropic-version", "2023-06-01")
                .addHeader("content-type", "application/json; charset=UTF-8")
                .addHeader("accept", "application/json; charset=UTF-8")
                .post(body)
                .build();
                
        try (Response response = client.newCall(request).execute()) {
            if (response.body() == null) {
                return "API 응답이 null입니다.";
            }
            
            // UTF-8로 응답 읽기 (안전한 null 체크)
            okhttp3.ResponseBody responseBodyObj = response.body();
            String responseBody = responseBodyObj != null ? 
                new String(responseBodyObj.bytes(), "UTF-8") : "응답 본문이 비어있습니다";
            System.out.println("API 응답 상태: " + response.code());
            System.out.println("API 응답 길이: " + responseBody.length());
            
            if (!response.isSuccessful()) {
                System.err.println("API 호출 실패: " + response.code());
                System.err.println("응답 내용: " + responseBody);
                return "API 호출 실패: " + response.code() + "\n오류 내용: " + responseBody;
            }
            
            return extractContentFromResponse(responseBody);
        }
    }

    private String extractContentFromResponse(String jsonResponse) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(jsonResponse);
            // 정상 응답
            if (root.has("content") && root.get("content").isArray()) {
                for (JsonNode node : root.get("content")) {
                    if (node.has("text")) {
                        return node.get("text").asText();
                    }
                }
            }
            // 에러 응답
            if (root.has("error")) {
                return "[API 오류] " + root.get("error").toString();
            }
            return "[파싱 실패] " + jsonResponse;
        } catch (IOException e) {
            System.err.println("JSON 파싱 - 입출력 오류: " + e.getMessage());
            return "[JSON 파싱 오류] " + e.getMessage() + " / 원본: " + jsonResponse;
        } catch (RuntimeException e) {
            System.err.println("JSON 파싱 - 런타임 오류: " + e.getMessage());
            return "[파싱 예외] " + e.getMessage() + " / 원본: " + jsonResponse;
        }
    }



    // 대화방(주제) 자동 생성 및 질문/답변 저장
    public Long saveQuestionAndAnswer(Long userId, String contextType, String question, String answer, int answeredInSeconds) {
        try {
            System.out.println("=== AI 질문/답변 저장 시작 ===");
            System.out.println("사용자 ID: " + userId);
            System.out.println("컨텍스트 타입: " + contextType);
            System.out.println("질문: " + question);
            System.out.println("답변 길이: " + (answer != null ? answer.length() : 0));
            System.out.println("응답 시간: " + answeredInSeconds + "초");
            
            // 1. AiQuestion 저장
            AiQuestion aiQuestion = new AiQuestion();
            aiQuestion.setUserId(userId);
            aiQuestion.setContextType(contextType);
            aiQuestion.setQuestion(question);
            aiQuestion.setCategory(contextType);
            aiQuestion.setIsAnswered(true);
            aiQuestion.setAnsweredInSeconds(answeredInSeconds);
            aiQuestion.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
            
            System.out.println("질문 저장 전 - ID: " + aiQuestion.getId());
            
            // 질문 저장 (ID가 자동 생성됨)
            aiQuestionRepository.insertQuestion(aiQuestion);
            
            System.out.println("질문 저장 후 - ID: " + aiQuestion.getId());
            
            if (aiQuestion.getId() == null) {
                System.err.println("❌ 질문 ID가 null입니다! useGeneratedKeys 또는 테이블 AUTO_INCREMENT 설정을 확인하세요.");
                return null;
            }
            
            // 2. AiAnswer 저장
            AiAnswer aiAnswer = new AiAnswer();
            aiAnswer.setQuestionId(aiQuestion.getId());
            aiAnswer.setAnswer(answer);
            aiAnswer.setTokenUsage(answer != null ? answer.length() : 0); // 임시로 답변 길이를 토큰으로 사용
            aiAnswer.setIsSuccessful(true);
            aiAnswer.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));
            
            System.out.println("답변 저장 전 - QuestionID: " + aiAnswer.getQuestionId());
            
            // 답변 저장 (ID가 자동 생성됨)
            aiAnswerRepository.insertAnswer(aiAnswer);
            
            System.out.println("답변 저장 후 - AnswerID: " + aiAnswer.getId());
            
            if (aiAnswer.getId() == null) {
                System.err.println("❌ 답변 ID가 null입니다! useGeneratedKeys 또는 테이블 AUTO_INCREMENT 설정을 확인하세요.");
                return aiQuestion.getId(); // 질문은 저장되었으므로 질문 ID는 반환
            }
            
            System.out.println("✅ 질문/답변 저장 성공!");
            System.out.println("질문 ID: " + aiQuestion.getId() + ", 답변 ID: " + aiAnswer.getId());
            
            return aiQuestion.getId(); // 질문 ID 반환
            
        } catch (RuntimeException e) {
            System.err.println("❌ 질문/답변 저장 중 오류: " + e.getMessage());
            return null;
        }
    }
    
    // 사용자별 질문 기록 조회
    public List<AiQuestion> getUserQuestions(Long userId) {
        try {
            System.out.println("=== getUserQuestions 호출 ===");
            System.out.println("사용자 ID: " + userId);
            
            // Repository가 null인지 확인
            if (aiQuestionRepository == null) {
                System.err.println("aiQuestionRepository가 null입니다!");
                return new ArrayList<>();
            }
            
            System.out.println("Repository 준비 완료, 쿼리 실행 중...");
            List<AiQuestion> questions = aiQuestionRepository.findByUserId(userId);
            System.out.println("쿼리 실행 완료. 결과 개수: " + (questions != null ? questions.size() : 0));
            
            return questions;
        } catch (RuntimeException e) {
            System.err.println("사용자 질문 조회 중 상세 오류:");
            System.err.println("오류 타입: " + e.getClass().getSimpleName());
            System.err.println("오류 메시지: " + e.getMessage());
            
            // 더 상세한 오류 정보
            if (e.getCause() != null) {
                System.err.println("원인: " + e.getCause().getMessage());
            }
            
            return new ArrayList<>();
        }
    }
    
    // 질문에 대한 답변 조회
    public AiAnswer getAnswerByQuestionId(Long questionId) {
        try {
            return aiAnswerRepository.findByQuestionId(questionId);
        } catch (RuntimeException e) {
            System.err.println("답변 조회 중 오류: " + e.getMessage());
            return null;
        }
    }
    
    // 피드백 저장
    public void saveFeedback(Long answerId, Long userId, Integer score, String comment, String feedbackType, Boolean isRelevant, Boolean requestedEdit) {
        try {
            AiFeedback feedback = new AiFeedback(answerId, userId, score, comment, feedbackType, isRelevant, requestedEdit);
            aiFeedbackRepository.insertFeedback(feedback);
        } catch (RuntimeException e) {
            System.err.println("피드백 저장 중 오류: " + e.getMessage());
        }
    }

    public List<QuestionWithAnswerDto> getUserQuestionsWithAnswers(Long userId) {
        try {
            System.out.println("=== 사용자 질문+답변 조회 ===");
            System.out.println("사용자 ID: " + userId);
            
            // 1. 사용자의 질문들 조회
            List<AiQuestion> questions = aiQuestionRepository.findByUserId(userId);
            System.out.println("조회된 질문 개수: " + (questions != null ? questions.size() : 0));
            
            if (questions == null || questions.isEmpty()) {
                System.out.println("질문이 없어서 빈 리스트 반환");
                return new ArrayList<>();
            }
            
            // 2. 각 질문에 대한 답변과 첨부파일 조회하여 DTO 생성
            List<QuestionWithAnswerDto> result = new ArrayList<>();
            for (AiQuestion question : questions) {
                if (question.getId() != null) {
                    System.out.println("질문 ID: " + question.getId());
                    
                    // 답변 조회
                    AiAnswer answer = aiAnswerRepository.findByQuestionId(question.getId());
                    System.out.println("  답변: " + (answer != null ? "있음" : "없음"));
                    
                    // 첨부파일 조회
                    List<AttachmentFileDto> attachments = getAttachmentsByQuestionId(question.getId());
                    System.out.println("  첨부파일 개수: " + attachments.size());
                    
                    QuestionWithAnswerDto dto = new QuestionWithAnswerDto(question, answer);
                    dto.setAttachments(attachments);
                    result.add(dto);
                } else {
                    System.err.println("⚠️ 질문 ID가 null인 질문이 있습니다: " + question.getQuestion());
                }
            }
            System.out.println("최종 반환 개수: " + result.size());
            return result;
        } catch (RuntimeException e) {
            System.err.println("사용자 질문+답변 조회 중 오류: " + e.getMessage());
            return new ArrayList<>();
        }
    }
    
    // 질문 ID로 첨부파일 목록 조회
    public List<AttachmentFileDto> getAttachmentsByQuestionId(Long questionId) {
        try {
            String sql = "SELECT id, question_id, file_path, original_file_name, file_type, file_size, uploaded_at " +
                        "FROM ai_question_files WHERE question_id = ? ORDER BY uploaded_at ASC";
            
            List<AttachmentFileDto> attachments = new ArrayList<>();
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql, questionId);
            
            for (Map<String, Object> row : rows) {
                AttachmentFileDto attachment = new AttachmentFileDto();
                attachment.setId(((Number) row.get("id")).longValue());
                attachment.setQuestionId(((Number) row.get("question_id")).longValue());
                attachment.setFilePath((String) row.get("file_path"));
                attachment.setOriginalFileName((String) row.get("original_file_name"));
                attachment.setFileType((String) row.get("file_type"));
                
                Object fileSize = row.get("file_size");
                if (fileSize != null) {
                    attachment.setFileSize(((Number) fileSize).longValue());
                }
                
                Object uploadedAt = row.get("uploaded_at");
                if (uploadedAt != null) {
                    attachment.setUploadedAt((java.sql.Timestamp) uploadedAt);
                }
                
                attachments.add(attachment);
            }
            
            return attachments;
        } catch (RuntimeException e) {
            System.err.println("첨부파일 조회 중 오류: " + e.getMessage());
            return new ArrayList<>();
        }
    }
    
    // 질문 삭제 (첨부파일도 함께 삭제)
    public boolean deleteQuestion(Long questionId, Long userId) {
        try {
            System.out.println("=== 질문 삭제 ===");
            System.out.println("질문 ID: " + questionId + ", 사용자 ID: " + userId);
            
            // 1. 권한 확인 - 해당 질문이 요청한 사용자의 것인지 확인
            String checkQuery = "SELECT user_id FROM ai_questions WHERE id = ?";
            List<Map<String, Object>> checkResult = jdbcTemplate.queryForList(checkQuery, questionId);
            
            if (checkResult.isEmpty()) {
                System.err.println("존재하지 않는 질문 ID: " + questionId);
                return false;
            }
            
            Long questionOwnerId = ((Number) checkResult.get(0).get("user_id")).longValue();
            if (!questionOwnerId.equals(userId)) {
                System.err.println("권한 없음 - 질문 소유자: " + questionOwnerId + ", 요청자: " + userId);
                return false;
            }
            
            // 2. 첨부파일 물리적 삭제
            List<AttachmentFileDto> attachments = getAttachmentsByQuestionId(questionId);
            for (AttachmentFileDto attachment : attachments) {
                try {
                    java.nio.file.Path filePath = java.nio.file.Paths.get(attachment.getFilePath());
                    java.nio.file.Files.deleteIfExists(filePath);
                    System.out.println("첨부파일 삭제: " + attachment.getOriginalFileName());
                } catch (java.io.IOException fileError) {
                    System.err.println("첨부파일 삭제 실패 (I/O 오류): " + attachment.getOriginalFileName() + " - " + fileError.getMessage());
                } catch (SecurityException fileError) {
                    System.err.println("첨부파일 삭제 실패 (권한 오류): " + attachment.getOriginalFileName() + " - " + fileError.getMessage());
                } catch (RuntimeException fileError) {
                    System.err.println("첨부파일 삭제 실패 (시스템 오류): " + attachment.getOriginalFileName() + " - " + fileError.getMessage());
                }
            }
            
            // 3. 데이터베이스에서 삭제 (외래키 제약조건에 의해 자동 삭제됨)
            // 첨부파일 정보 삭제
            String deleteFilesQuery = "DELETE FROM ai_question_files WHERE question_id = ?";
            int deletedFiles = jdbcTemplate.update(deleteFilesQuery, questionId);
            System.out.println("삭제된 첨부파일 레코드 수: " + deletedFiles);
            
            // 답변 삭제
            String deleteAnswerQuery = "DELETE FROM ai_answers WHERE question_id = ?";
            int deletedAnswers = jdbcTemplate.update(deleteAnswerQuery, questionId);
            System.out.println("삭제된 답변 수: " + deletedAnswers);
            
            // 피드백 삭제 (답변이 삭제되면 자동으로 삭제되지만 명시적으로 처리)
            String deleteFeedbackQuery = "DELETE FROM ai_feedback WHERE answer_id IN (SELECT id FROM ai_answers WHERE question_id = ?)";
            try {
                int deletedFeedbacks = jdbcTemplate.update(deleteFeedbackQuery, questionId);
                System.out.println("삭제된 피드백 수: " + deletedFeedbacks);
            } catch (org.springframework.dao.DataAccessException e) {
                System.err.println("피드백 삭제 중 데이터베이스 오류: " + e.getMessage());
                System.out.println("피드백 삭제 생략 (답변 이미 삭제됨)");
            } catch (RuntimeException e) {
                System.err.println("피드백 삭제 중 시스템 오류: " + e.getMessage());
                System.out.println("피드백 삭제 생략");
            }
            
            // 질문 삭제
            String deleteQuestionQuery = "DELETE FROM ai_questions WHERE id = ?";
            int deletedQuestions = jdbcTemplate.update(deleteQuestionQuery, questionId);
            System.out.println("삭제된 질문 수: " + deletedQuestions);
            
            if (deletedQuestions > 0) {
                System.out.println("✅ 질문 삭제 완료: " + questionId);
                return true;
            } else {
                System.err.println("❌ 질문 삭제 실패: " + questionId);
                return false;
            }
            
        } catch (RuntimeException e) {
            System.err.println("❌ 질문 삭제 중 오류: " + e.getMessage());
            return false;
        }
    }

    /**
     * 관리자가 등록한 대여 가능한 기자재 목록 조회
     * @return 대여 가능한 기자재 이름 목록
     */
    public List<String> getAvailableEquipments() {
        try {
            System.out.println("=== 실제 기자재 목록 조회 ===");
            
            // 모든 기자재 조회
            List<com.example.test.equipment.EquipmentDto> allEquipments = equipmentService.getAllEquipment();
            System.out.println("전체 기자재 개수: " + allEquipments.size());
            
            // 대여 가능한 기자재만 필터링
            List<String> availableEquipmentNames = new ArrayList<>();
            for (com.example.test.equipment.EquipmentDto equipment : allEquipments) {
                // 조건: 퇴역되지 않음 + 대여 가능 + 재고 있음
                if (equipment.getIsRentable() != null && equipment.getIsRentable() &&
                    (equipment.getIsRetired() == null || !equipment.getIsRetired()) &&
                    equipment.getAvailableQuantity() != null && equipment.getAvailableQuantity() > 0) {
                    
                    availableEquipmentNames.add(equipment.getName());
                }
            }
            
            System.out.println("대여 가능한 기자재 개수: " + availableEquipmentNames.size());
            System.out.println("대여 가능한 기자재 목록: " + availableEquipmentNames);
            
            return availableEquipmentNames;
            
        } catch (org.springframework.dao.DataAccessException e) {
            System.err.println("기자재 목록 조회 중 데이터베이스 오류: " + e.getMessage());
            
            // 오류 발생 시 빈 목록 반환 또는 기본값 반환
            List<String> fallbackEquipments = new ArrayList<>();
            fallbackEquipments.add("데이터베이스 연결 오류로 기자재 목록을 불러올 수 없습니다");
            return fallbackEquipments;
        } catch (RuntimeException e) {
            System.err.println("기자재 목록 조회 중 시스템 오류: " + e.getMessage());
            
            // 오류 발생 시 빈 목록 반환 또는 기본값 반환
            List<String> fallbackEquipments = new ArrayList<>();
            fallbackEquipments.add("시스템 오류로 기자재 목록을 불러올 수 없습니다");
            return fallbackEquipments;
        }
    }
    
    // 질문 첨부파일 저장
    public void saveQuestionFile(Long questionId, String filePath, String originalFileName, String fileType, Long fileSize) {
        try {
            System.out.println("=== 질문 첨부파일 저장 ===");
            System.out.println("질문 ID: " + questionId);
            System.out.println("파일 경로: " + filePath);
            System.out.println("원본 파일명: " + originalFileName);
            System.out.println("파일 타입: " + fileType);
            System.out.println("파일 크기: " + fileSize);
            
            String sql = "INSERT INTO ai_question_files (question_id, file_path, original_file_name, file_type, file_size, uploaded_at) VALUES (?, ?, ?, ?, ?, NOW())";
            
            int result = jdbcTemplate.update(sql, questionId, filePath, originalFileName, fileType, fileSize);
            
            if (result > 0) {
                System.out.println("✅ 첨부파일 정보 저장 완료");
            } else {
                System.err.println("❌ 첨부파일 정보 저장 실패");
            }
            
        } catch (RuntimeException e) {
            System.err.println("❌ 첨부파일 저장 중 오류: " + e.getMessage());
        }
    }

    public void saveHistory(String userId, String question, String answer) {
        AiHistory history = new AiHistory();
        history.setUserId(userId);
        history.setQuestion(question);
        history.setAnswer(answer);
        aiHistoryRepository.insertHistory(history);
    }

    public List<AiHistoryDto> getUserHistory(Long userId, int limit) {
        return aiHistoryRepository.findHistoryByUserId(userId, limit);
    }

    public AiHistoryDto getHistoryByQuestionId(Long questionId) {
        return aiHistoryRepository.findHistoryByQuestionId(questionId);
    }

    public void deleteHistoryByQuestionId(Long questionId) {
        aiHistoryRepository.deleteHistoryByQuestionId(questionId);
    }

    public int getUserTotalQuestions(String userId) {
        return aiHistoryRepository.countByUserId(userId);
    }

    public int getUserMonthlyQuestions(String userId) {
        return aiHistoryRepository.countByUserIdThisMonth(userId);
    }
    
    // ========================================
    // 크레딧 관리 메서드
    // ========================================
    
    /**
     * 사용자 크레딧 조회 (없으면 자동 생성)
     */
    public UserAiCreditDto getUserCredit(Long userId) {
        UserAiCreditDto credit = aiCreditMapper.selectUserCredit(userId);
        
        // 크레딧 정보가 없으면 자동 생성 (기본 100 크레딧)
        if (credit == null) {
            UserAiCreditDto newCredit = new UserAiCreditDto();
            newCredit.setUserId(userId);
            newCredit.setTotalCredits(100);
            newCredit.setUsedCredits(0);
            newCredit.setRemainingCredits(100);
            aiCreditMapper.insertUserCredit(newCredit);
            credit = aiCreditMapper.selectUserCredit(userId);
        }
        
        return credit;
    }
    
    /**
     * 크레딧 충분 여부 확인
     */
    public boolean hasEnoughCredits(Long userId, int requiredCredits) {
        Integer remaining = aiCreditMapper.getRemainingCredits(userId);
        if (remaining == null) {
            // 크레딧 정보가 없으면 자동 생성
            getUserCredit(userId);
            remaining = 100; // 새로 생성된 기본 크레딧
        }
        return remaining >= requiredCredits;
    }
    
    /**
     * 크레딧 사용 (차감)
     */
    public boolean useCredits(Long userId, int creditsToUse, Long questionId, String description) {
        try {
            // 크레딧 차감
            int updated = aiCreditMapper.useCredit(userId, creditsToUse);
            
            if (updated > 0) {
                // 사용 로그 기록
                AiCreditLogDto log = new AiCreditLogDto();
                log.setUserId(userId);
                log.setQuestionId(questionId);
                log.setCreditsUsed(creditsToUse);
                log.setActionType("QUESTION");
                log.setDescription(description);
                aiCreditMapper.insertCreditLog(log);
                
                System.out.println("크레딧 차감 완료: 사용자 " + userId + ", 사용량 " + creditsToUse);
                return true;
            } else {
                System.err.println("크레딧 차감 실패: 잔액 부족");
                return false;
            }
        } catch (Exception e) {
            System.err.println("크레딧 차감 중 오류: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * 크레딧 충전
     */
    public void rechargeCredits(Long userId, int creditsToAdd, String description) {
        try {
            aiCreditMapper.rechargeCredit(userId, creditsToAdd);
            
            // 충전 로그 기록
            AiCreditLogDto log = new AiCreditLogDto();
            log.setUserId(userId);
            log.setCreditsUsed(creditsToAdd);
            log.setActionType("RECHARGE");
            log.setDescription(description);
            aiCreditMapper.insertCreditLog(log);
            
            System.out.println("크레딧 충전 완료: 사용자 " + userId + ", 충전량 " + creditsToAdd);
        } catch (Exception e) {
            System.err.println("크레딧 충전 중 오류: " + e.getMessage());
        }
    }
    
    /**
     * 관리자가 크레딧 부여
     */
    public void adminGrantCredits(Long userId, int creditsToAdd, String reason) {
        try {
            aiCreditMapper.rechargeCredit(userId, creditsToAdd);
            
            // 관리자 부여 로그 기록
            AiCreditLogDto log = new AiCreditLogDto();
            log.setUserId(userId);
            log.setCreditsUsed(creditsToAdd);
            log.setActionType("ADMIN_GRANT");
            log.setDescription("관리자 부여: " + reason);
            aiCreditMapper.insertCreditLog(log);
            
            System.out.println("관리자 크레딧 부여 완료: 사용자 " + userId + ", 부여량 " + creditsToAdd);
        } catch (Exception e) {
            System.err.println("관리자 크레딧 부여 중 오류: " + e.getMessage());
        }
    }
    
    /**
     * 크레딧 사용 내역 조회
     */
    public List<AiCreditLogDto> getCreditLogs(Long userId, Integer limit) {
        try {
            return aiCreditMapper.selectCreditLogs(userId, limit != null ? limit : 20);
        } catch (Exception e) {
            System.err.println("크레딧 로그 조회 중 오류: " + e.getMessage());
            return new ArrayList<>();
        }
    }
} 