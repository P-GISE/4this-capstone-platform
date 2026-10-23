-- Fresh database only. Derived from mapper/JDBC contracts; no accounts or business data are seeded.
-- Existing databases must use an explicitly reviewed migration, never this initializer.
-- Logical references use indexes; historical deletion ordering is not safe for inferred FK cascades.

-- Source: AdminLogMapper.xml
CREATE TABLE admin_logs (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `action_type` VARCHAR(255),
  `admin_id` BIGINT,
  `after_value` LONGTEXT,
  `before_value` LONGTEXT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `description` LONGTEXT,
  `http_method` VARCHAR(255),
  `ip_address` VARCHAR(255),
  `is_successful` BOOLEAN DEFAULT FALSE,
  `log_level` VARCHAR(255),
  `request_uri` VARCHAR(255),
  `target_id` BIGINT,
  `target_table` VARCHAR(255),
  `user_agent` LONGTEXT,
  PRIMARY KEY (`id`),
  KEY `idx_admin_logs_admin_id` (`admin_id`),
  KEY `idx_admin_logs_target_id` (`target_id`)
);

-- Source: AuthMapper.xml
CREATE TABLE admin_profiles (
  `access_level` VARCHAR(255),
  `admin_id` VARCHAR(255),
  `birth_date` DATE NULL,
  `department` VARCHAR(255),
  `department_code` VARCHAR(255),
  `gender` VARCHAR(255),
  `position` VARCHAR(255),
  `role_type` VARCHAR(255),
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`user_id`)
);

-- Source: AiAnswerMapper.xml, AiHistoryMapper.xml
CREATE TABLE ai_answers (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `answer` LONGTEXT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `is_successful` BOOLEAN DEFAULT FALSE,
  `question_id` BIGINT,
  `token_usage` INT DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_ai_answers_question_id` (`question_id`)
);

-- Source: AiConversationMapper.xml
CREATE TABLE ai_conversations (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `title` VARCHAR(255),
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_ai_conversations_user_id` (`user_id`)
);

-- Source: AiCreditMapper.xml
CREATE TABLE ai_credit_logs (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `action_type` VARCHAR(255),
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `credits_used` INT DEFAULT 0,
  `description` LONGTEXT,
  `question_id` BIGINT,
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_ai_credit_logs_question_id` (`question_id`),
  KEY `idx_ai_credit_logs_user_id` (`user_id`)
);

-- Source: AiFeedbackMapper.xml
CREATE TABLE ai_feedback (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `answer_id` BIGINT,
  `comment` LONGTEXT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `feedback_type` VARCHAR(255),
  `is_relevant` BOOLEAN DEFAULT FALSE,
  `requested_edit` LONGTEXT,
  `score` INT DEFAULT 0,
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_ai_feedback_answer_id` (`answer_id`),
  KEY `idx_ai_feedback_user_id` (`user_id`)
);

-- Source: AiHistoryMapper.xml
CREATE TABLE ai_history (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `answer` LONGTEXT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `question` LONGTEXT,
  `question_id` BIGINT,
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_ai_history_question_id` (`question_id`),
  KEY `idx_ai_history_user_id` (`user_id`)
);

-- Source: AiService.java
CREATE TABLE ai_question_files (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `file_path` LONGTEXT,
  `file_size` BIGINT DEFAULT 0,
  `file_type` VARCHAR(255),
  `original_file_name` VARCHAR(255),
  `question_id` BIGINT,
  `uploaded_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ai_question_files_question_id` (`question_id`)
);

-- Source: AiHistoryMapper.xml, AiQuestionMapper.xml
CREATE TABLE ai_questions (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `answered_in_seconds` INT DEFAULT 0,
  `attachment_id` BIGINT,
  `category` VARCHAR(255),
  `context_type` VARCHAR(255),
  `conversation_id` BIGINT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `is_answered` BOOLEAN DEFAULT FALSE,
  `question` LONGTEXT,
  `target_id` BIGINT,
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_ai_questions_attachment_id` (`attachment_id`),
  KEY `idx_ai_questions_conversation_id` (`conversation_id`),
  KEY `idx_ai_questions_target_id` (`target_id`),
  KEY `idx_ai_questions_user_id` (`user_id`)
);

-- Source: ArchiveMapper.xml
CREATE TABLE archive_files (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `archive_id` BIGINT,
  `download_count` INT DEFAULT 0,
  `file_name` VARCHAR(255),
  `file_path` LONGTEXT,
  `file_size` BIGINT DEFAULT 0,
  `file_type` VARCHAR(255),
  `is_deleted` BOOLEAN DEFAULT FALSE,
  `original_file_name` VARCHAR(255),
  `uploaded_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_archive_files_archive_id` (`archive_id`)
);

-- Source: ArchiveMapper.xml
CREATE TABLE archives (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `approved` BOOLEAN DEFAULT FALSE,
  `approved_at` TIMESTAMP NULL,
  `approved_by` BIGINT,
  `category` VARCHAR(255),
  `description` LONGTEXT,
  `equipment_info` LONGTEXT,
  `is_deleted` BOOLEAN DEFAULT FALSE,
  `is_public` BOOLEAN DEFAULT FALSE,
  `is_submitted` BOOLEAN DEFAULT FALSE,
  `project_id` BIGINT,
  `submitted_at` TIMESTAMP NULL,
  `submitted_by` BIGINT,
  `submitted_by_name` VARCHAR(255),
  `title` VARCHAR(255),
  `version` VARCHAR(255),
  PRIMARY KEY (`id`),
  KEY `idx_archives_approved_by` (`approved_by`),
  KEY `idx_archives_project_id` (`project_id`),
  KEY `idx_archives_submitted_by` (`submitted_by`)
);

-- Source: AuthMapper.xml, ChatMessageMapper.xml, ChatParticipantMapper.xml
CREATE TABLE assistant_profiles (
  `assistant_id` VARCHAR(255),
  `birth_date` DATE NULL,
  `department` VARCHAR(255),
  `gender` VARCHAR(255),
  `lab_name` VARCHAR(255),
  `major_field` VARCHAR(255),
  `university_name` VARCHAR(255),
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`user_id`)
);

-- Source: ChatMapper.xml
CREATE TABLE chat_invitations (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `invitee_id` BIGINT,
  `inviter_id` BIGINT,
  `room_id` BIGINT,
  `status` VARCHAR(255) DEFAULT 'PENDING',
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_chat_invitations_invitee_id` (`invitee_id`),
  KEY `idx_chat_invitations_inviter_id` (`inviter_id`),
  KEY `idx_chat_invitations_room_id` (`room_id`)
);

-- Source: ChatMapper.xml
CREATE TABLE chat_message_files (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `deleted_at` TIMESTAMP NULL,
  `file_name` VARCHAR(255),
  `file_path` LONGTEXT,
  `file_size` BIGINT DEFAULT 0,
  `file_type` VARCHAR(255),
  `is_deleted` BOOLEAN DEFAULT FALSE,
  `message_id` BIGINT,
  `original_file_name` VARCHAR(255),
  `uploaded_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_chat_message_files_message_id` (`message_id`)
);

-- Source: ChatMapper.xml, ChatMessageMapper.xml
CREATE TABLE chat_messages (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `bot_response` LONGTEXT,
  `bot_type` VARCHAR(255),
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `edited` BOOLEAN DEFAULT FALSE,
  `formatted_message` LONGTEXT,
  `is_deleted` BOOLEAN DEFAULT FALSE,
  `is_pinned` BOOLEAN DEFAULT FALSE,
  `message` LONGTEXT,
  `message_format` VARCHAR(255),
  `message_summary` LONGTEXT,
  `message_type` VARCHAR(255),
  `parent_message_id` BIGINT,
  `room_id` BIGINT,
  `sender_id` BIGINT,
  `sent_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `sentiment_score` DECIMAL(10,4),
  `sentiment_type` VARCHAR(255),
  `summary_type` VARCHAR(255),
  `translated_message` LONGTEXT,
  `translation_language` VARCHAR(255),
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_chat_messages_parent_message_id` (`parent_message_id`),
  KEY `idx_chat_messages_room_id` (`room_id`),
  KEY `idx_chat_messages_sender_id` (`sender_id`)
);

-- Source: ChatMapper.xml, ChatParticipantMapper.xml
CREATE TABLE chat_participants (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `desktop_notifications` BOOLEAN DEFAULT TRUE,
  `email_notifications` BOOLEAN DEFAULT TRUE,
  `is_admin` BOOLEAN DEFAULT FALSE,
  `joined_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `last_read_at` TIMESTAMP NULL,
  `left_at` TIMESTAMP NULL,
  `nickname` VARCHAR(255),
  `notification_sound` BOOLEAN DEFAULT TRUE,
  `notifications_enabled` BOOLEAN DEFAULT TRUE,
  `push_notifications` BOOLEAN DEFAULT TRUE,
  `role` VARCHAR(255),
  `room_id` BIGINT,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `user_id` BIGINT,
  `user_name` VARCHAR(255),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_chat_participants_0` (`room_id`,`user_id`),
  KEY `idx_chat_participants_room_id` (`room_id`),
  KEY `idx_chat_participants_user_id` (`user_id`)
);

-- Source: ChatMapper.xml
CREATE TABLE chat_reads (
  `message_id` BIGINT NOT NULL,
  `read_at` TIMESTAMP NULL,
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`message_id`,`user_id`)
);

-- Source: ChatMapper.xml
CREATE TABLE chat_room_activity_logs (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `activity_details` LONGTEXT,
  `activity_type` VARCHAR(255),
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `room_id` BIGINT,
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_chat_room_activity_logs_room_id` (`room_id`),
  KEY `idx_chat_room_activity_logs_user_id` (`user_id`)
);

-- Source: ChatMapper.xml
CREATE TABLE chat_room_permissions (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `granted_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `granted_by` BIGINT,
  `permission_type` VARCHAR(255),
  `room_id` BIGINT,
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_chat_room_permissions_0` (`room_id`,`user_id`,`permission_type`),
  KEY `idx_chat_room_permissions_granted_by` (`granted_by`),
  KEY `idx_chat_room_permissions_room_id` (`room_id`),
  KEY `idx_chat_room_permissions_user_id` (`user_id`)
);

-- Source: ChatMapper.xml
CREATE TABLE chat_room_settings (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT,
  `room_id` BIGINT,
  `setting_key` VARCHAR(255),
  `setting_value` LONGTEXT,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_chat_room_settings_0` (`room_id`,`setting_key`),
  KEY `idx_chat_room_settings_created_by` (`created_by`),
  KEY `idx_chat_room_settings_room_id` (`room_id`)
);

-- Source: ChatMapper.xml
CREATE TABLE chat_room_shares (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` TIMESTAMP NULL,
  `room_id` BIGINT,
  `share_token` VARCHAR(255),
  `share_type` VARCHAR(255),
  `shared_by` BIGINT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_chat_room_shares_0` (`share_token`),
  KEY `idx_chat_room_shares_room_id` (`room_id`),
  KEY `idx_chat_room_shares_shared_by` (`shared_by`)
);

-- Source: ChatMapper.xml
CREATE TABLE chat_room_tags (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `room_id` BIGINT,
  `tag_name` VARCHAR(255),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_chat_room_tags_0` (`room_id`,`tag_name`),
  KEY `idx_chat_room_tags_room_id` (`room_id`)
);

-- Source: ChatMapper.xml
CREATE TABLE chat_room_templates (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT,
  `default_settings` LONGTEXT,
  `room_type` VARCHAR(255),
  `template_description` VARCHAR(255),
  `template_name` VARCHAR(255),
  PRIMARY KEY (`id`),
  KEY `idx_chat_room_templates_created_by` (`created_by`)
);

-- Source: ChatMapper.xml, ChatRoomMapper.xml
CREATE TABLE chat_rooms (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `allow_invite` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT,
  `deleted_at` TIMESTAMP NULL,
  `description` LONGTEXT,
  `is_deleted` BOOLEAN DEFAULT FALSE,
  `is_main` BOOLEAN DEFAULT FALSE,
  `is_private` BOOLEAN DEFAULT FALSE,
  `last_message_at` TIMESTAMP NULL,
  `max_participants` INT DEFAULT 0,
  `name` VARCHAR(255),
  `project_id` BIGINT,
  `save_message_history` BOOLEAN DEFAULT TRUE,
  `status` VARCHAR(255) DEFAULT 'ACTIVE',
  `type` VARCHAR(255) DEFAULT 'GROUP',
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_chat_rooms_created_by` (`created_by`),
  KEY `idx_chat_rooms_project_id` (`project_id`)
);

-- Source: ConversationMapper.xml
CREATE TABLE conversations (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `answer` LONGTEXT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `question` LONGTEXT,
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_conversations_user_id` (`user_id`)
);

-- Source: EquipmentMapper.xml, ProjectEquipmentMapper.xml, SpecialRentalRequestMapper.xml
CREATE TABLE equipment (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `asset_code` VARCHAR(255),
  `available_quantity` INT DEFAULT 0,
  `category` VARCHAR(255),
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `description` LONGTEXT,
  `image_path` LONGTEXT,
  `is_rentable` BOOLEAN DEFAULT TRUE,
  `is_retired` BOOLEAN DEFAULT FALSE,
  `location` VARCHAR(255),
  `managed_by` BIGINT,
  `manufacturer` VARCHAR(255),
  `max_rental_quantity` INT DEFAULT 0,
  `name` VARCHAR(255),
  `purchase_date` DATE NULL,
  `quantity` INT DEFAULT 0,
  `status` VARCHAR(255) DEFAULT 'AVAILABLE',
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `warranty_expiration` DATE NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_equipment_0` (`asset_code`),
  KEY `idx_equipment_managed_by` (`managed_by`)
);

-- Source: EquipmentRentalMapper.xml, ProjectEquipmentMapper.xml
CREATE TABLE equipment_rentals (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `approved_by` BIGINT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `equipment_id` BIGINT,
  `expected_return_date` DATE NULL,
  `extension_count` INT DEFAULT 0,
  `is_approved` BOOLEAN DEFAULT FALSE,
  `purpose` LONGTEXT,
  `rejection_reason` LONGTEXT,
  `rent_date` DATE NULL,
  `requested_quantity` INT DEFAULT 0,
  `return_date` DATE NULL,
  `status` VARCHAR(255) DEFAULT 'PENDING',
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_equipment_rentals_approved_by` (`approved_by`),
  KEY `idx_equipment_rentals_equipment_id` (`equipment_id`),
  KEY `idx_equipment_rentals_user_id` (`user_id`)
);

-- Source: insertRepair.xml
CREATE TABLE equipment_repairs (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `handled_at` TIMESTAMP NULL,
  `handled_by` BIGINT,
  `image_path` LONGTEXT,
  `reason` LONGTEXT,
  `rejection_reason` LONGTEXT,
  `rental_id` BIGINT,
  `requested_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `requested_by` BIGINT,
  `status` VARCHAR(255) DEFAULT 'PENDING',
  PRIMARY KEY (`id`),
  KEY `idx_equipment_repairs_handled_by` (`handled_by`),
  KEY `idx_equipment_repairs_rental_id` (`rental_id`),
  KEY `idx_equipment_repairs_requested_by` (`requested_by`)
);

-- Source: EquipmentReservationMapper.xml
CREATE TABLE equipment_reservations (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `canceled_at` TIMESTAMP NULL,
  `equipment_id` BIGINT,
  `fulfilled_at` TIMESTAMP NULL,
  `note` VARCHAR(255),
  `reserved_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `status` VARCHAR(255) DEFAULT 'WAITING',
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_equipment_reservations_equipment_id` (`equipment_id`),
  KEY `idx_equipment_reservations_user_id` (`user_id`)
);

-- Source: InquiryMapper.xml
CREATE TABLE inquiries (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `answered_at` TIMESTAMP NULL,
  `category` VARCHAR(255),
  `content` LONGTEXT,
  `context_type` VARCHAR(255),
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `has_attachment` BOOLEAN DEFAULT FALSE,
  `is_deleted` BOOLEAN DEFAULT FALSE,
  `is_reviewed` BOOLEAN DEFAULT FALSE,
  `is_urgent` BOOLEAN DEFAULT FALSE,
  `status` VARCHAR(255) DEFAULT 'PENDING',
  `target_id` BIGINT,
  `title` VARCHAR(255),
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_inquiries_target_id` (`target_id`),
  KEY `idx_inquiries_user_id` (`user_id`)
);

-- Source: InquiryMapper.xml
CREATE TABLE inquiry_answers (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `admin_id` BIGINT,
  `answer` LONGTEXT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `has_attachment` BOOLEAN DEFAULT FALSE,
  `inquiry_id` BIGINT,
  `is_edited` BOOLEAN DEFAULT FALSE,
  `is_read_by_user` BOOLEAN DEFAULT FALSE,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_inquiry_answers_admin_id` (`admin_id`),
  KEY `idx_inquiry_answers_inquiry_id` (`inquiry_id`),
  KEY `idx_inquiry_answers_updated_by` (`updated_by`)
);

-- Source: InquiryMapper.xml
CREATE TABLE inquiry_attachments (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `description` LONGTEXT,
  `download_count` INT DEFAULT 0,
  `file_name` VARCHAR(255),
  `file_path` LONGTEXT,
  `file_size` BIGINT DEFAULT 0,
  `file_type` VARCHAR(255),
  `inquiry_answer_id` BIGINT,
  `inquiry_id` BIGINT,
  `is_deleted` BOOLEAN DEFAULT FALSE,
  `is_downloadable` BOOLEAN DEFAULT TRUE,
  `original_file_name` VARCHAR(255),
  `uploaded_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_inquiry_attachments_inquiry_answer_id` (`inquiry_answer_id`),
  KEY `idx_inquiry_attachments_inquiry_id` (`inquiry_id`)
);

-- Source: NoticeMapper.xml
CREATE TABLE notice_attachments (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `download_count` INT DEFAULT 0,
  `file_name` VARCHAR(255),
  `file_path` LONGTEXT,
  `file_size` BIGINT DEFAULT 0,
  `file_type` VARCHAR(255),
  `is_deleted` BOOLEAN DEFAULT FALSE,
  `notice_id` BIGINT,
  `original_file_name` VARCHAR(255),
  `uploaded_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notice_attachments_notice_id` (`notice_id`)
);

-- Source: NoticeMapper.xml
CREATE TABLE notices (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `category` VARCHAR(255),
  `content` LONGTEXT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `is_important` BOOLEAN DEFAULT FALSE,
  `target_role` VARCHAR(255) DEFAULT 'ALL',
  `title` VARCHAR(255),
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` BIGINT,
  `view_count` INT DEFAULT 0,
  `visible_from` TIMESTAMP NULL,
  `visible_until` TIMESTAMP NULL,
  `writer_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_notices_updated_by` (`updated_by`),
  KEY `idx_notices_writer_id` (`writer_id`)
);

-- Source: NotificationMapper.xml
CREATE TABLE notifications (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `is_read` BOOLEAN DEFAULT FALSE,
  `message` LONGTEXT,
  `read_at` TIMESTAMP NULL,
  `target_url` VARCHAR(255),
  `title` VARCHAR(255),
  `type` VARCHAR(255),
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_notifications_user_id` (`user_id`)
);

-- Source: AuthMapper.xml, ChatMessageMapper.xml, ChatParticipantMapper.xml
CREATE TABLE professor_profiles (
  `birth_date` DATE NULL,
  `department` VARCHAR(255),
  `department_code` VARCHAR(255),
  `gender` VARCHAR(255),
  `position` VARCHAR(255),
  `professor_id` VARCHAR(255),
  `university_name` VARCHAR(255),
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`user_id`)
);

-- Source: ProjectEquipmentMapper.xml
CREATE TABLE project_equipment (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `added_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `added_by` BIGINT,
  `equipment_id` BIGINT,
  `project_id` BIGINT,
  `purpose` LONGTEXT,
  `rental_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_project_equipment_added_by` (`added_by`),
  KEY `idx_project_equipment_equipment_id` (`equipment_id`),
  KEY `idx_project_equipment_project_id` (`project_id`),
  KEY `idx_project_equipment_rental_id` (`rental_id`)
);

-- Source: ProjectMapper.xml
CREATE TABLE project_members (
  `is_approved` BOOLEAN DEFAULT FALSE,
  `joined_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `project_id` BIGINT NOT NULL,
  `role` VARCHAR(255),
  `role_description` LONGTEXT,
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`project_id`,`user_id`)
);

-- Source: ProjectMapper.xml
CREATE TABLE project_reports (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `description` LONGTEXT,
  `file_name` VARCHAR(255),
  `file_path` LONGTEXT,
  `file_size` BIGINT DEFAULT 0,
  `project_id` BIGINT,
  `title` VARCHAR(255),
  `uploaded_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `uploaded_by` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_project_reports_project_id` (`project_id`),
  KEY `idx_project_reports_uploaded_by` (`uploaded_by`)
);

-- Source: ProjectMapper.xml
CREATE TABLE project_tasks (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `assigned_to` VARCHAR(255),
  `color` VARCHAR(255),
  `completed_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT,
  `description` LONGTEXT,
  `due_date` DATE NULL,
  `priority` VARCHAR(255),
  `project_id` BIGINT,
  `start_date` DATE NULL,
  `status` VARCHAR(255),
  `title` VARCHAR(255),
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_project_tasks_created_by` (`created_by`),
  KEY `idx_project_tasks_project_id` (`project_id`)
);

-- Source: ProjectMapper.xml
CREATE TABLE projects (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `advisor_id` BIGINT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` BIGINT,
  `description` LONGTEXT,
  `end_date` DATE NULL,
  `is_public` BOOLEAN DEFAULT FALSE,
  `start_date` DATE NULL,
  `status` VARCHAR(255) DEFAULT 'ACTIVE',
  `title` VARCHAR(255),
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_projects_advisor_id` (`advisor_id`),
  KEY `idx_projects_created_by` (`created_by`)
);

-- Source: SpecialRentalRequestMapper.xml
CREATE TABLE special_rental_attachments (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `description` LONGTEXT,
  `file_path` LONGTEXT,
  `file_size` BIGINT DEFAULT 0,
  `file_type` VARCHAR(255),
  `original_filename` VARCHAR(255),
  `special_request_id` BIGINT,
  `stored_filename` VARCHAR(255),
  PRIMARY KEY (`id`),
  KEY `idx_special_rental_attachments_special_request_id` (`special_request_id`)
);

-- Source: SpecialRentalRequestMapper.xml
CREATE TABLE special_rental_logs (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `action_by` BIGINT,
  `action_reason` VARCHAR(255),
  `action_type` VARCHAR(255),
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `new_status` VARCHAR(255),
  `previous_status` VARCHAR(255),
  `special_request_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_special_rental_logs_action_by` (`action_by`),
  KEY `idx_special_rental_logs_special_request_id` (`special_request_id`)
);

-- Source: SpecialRentalRequestMapper.xml
CREATE TABLE special_rental_requests (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `admin_id` BIGINT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `current_available_quantity` INT DEFAULT 0,
  `current_user_rental_count` INT DEFAULT 0,
  `decision_reason` LONGTEXT,
  `equipment_id` BIGINT,
  `expected_end_date` DATE NULL,
  `expected_start_date` DATE NULL,
  `is_emergency` BOOLEAN DEFAULT FALSE,
  `priority_score` INT DEFAULT 0,
  `processed_at` TIMESTAMP NULL,
  `purpose` LONGTEXT,
  `request_type` VARCHAR(255),
  `requested_quantity` INT DEFAULT 0,
  `special_reason` LONGTEXT,
  `status` VARCHAR(255) DEFAULT 'PENDING',
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `urgency` VARCHAR(255),
  `urgency_level` VARCHAR(255),
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_special_rental_requests_admin_id` (`admin_id`),
  KEY `idx_special_rental_requests_equipment_id` (`equipment_id`),
  KEY `idx_special_rental_requests_user_id` (`user_id`)
);

-- Source: AuthMapper.xml, ChatMessageMapper.xml, ChatParticipantMapper.xml
CREATE TABLE staff_profiles (
  `birth_date` DATE NULL,
  `department` VARCHAR(255),
  `department_code` VARCHAR(255),
  `gender` VARCHAR(255),
  `position` VARCHAR(255),
  `staff_id` VARCHAR(255),
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`user_id`)
);

-- Source: AuthMapper.xml, ChatMessageMapper.xml, ChatParticipantMapper.xml
CREATE TABLE student_profiles (
  `admission_year` INT DEFAULT 0,
  `birth_date` DATE NULL,
  `department` VARCHAR(255),
  `department_code` VARCHAR(255),
  `gender` VARCHAR(255),
  `grade` INT DEFAULT 0,
  `student_id` VARCHAR(255),
  `student_status` VARCHAR(255),
  `university_name` VARCHAR(255),
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`user_id`)
);

-- Source: AiCreditMapper.xml
CREATE TABLE user_ai_credits (
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `last_recharged_at` TIMESTAMP NULL,
  `remaining_credits` INT DEFAULT 0,
  `total_credits` INT DEFAULT 0,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `used_credits` INT DEFAULT 0,
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`user_id`)
);

-- Source: UserLogMapper.xml
CREATE TABLE user_logs (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `failure_reason` VARCHAR(255),
  `ip_address` VARCHAR(255),
  `location` VARCHAR(255),
  `login_method` VARCHAR(255),
  `login_type` VARCHAR(255),
  `session_id` BIGINT,
  `success` BOOLEAN DEFAULT FALSE,
  `user_agent` LONGTEXT,
  `user_id` BIGINT,
  PRIMARY KEY (`id`),
  KEY `idx_user_logs_session_id` (`session_id`),
  KEY `idx_user_logs_user_id` (`user_id`)
);

-- Source: UserStatusMapper.xml
CREATE TABLE user_status (
  `last_heartbeat` TIMESTAMP NULL,
  `last_seen` TIMESTAMP NULL,
  `status` VARCHAR(255) DEFAULT 'OFFLINE',
  `status_message` VARCHAR(255),
  `status_updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`user_id`)
);

-- Source: AdminLogMapper.xml, AuthMapper.xml, ChatMapper.xml, ChatMessageMapper.xml, ChatParticipantMapper.xml, InquiryMapper.xml, NoticeMapper.xml, ProjectEquipmentMapper.xml, ProjectMapper.xml, SpecialRentalRequestMapper.xml, UserLogMapper.xml
CREATE TABLE users (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `email` VARCHAR(191) NOT NULL,
  `is_email_verified` BOOLEAN DEFAULT FALSE,
  `last_login_at` TIMESTAMP NULL,
  `name` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(255),
  `role` VARCHAR(255),
  `status` BOOLEAN NOT NULL DEFAULT TRUE,
  `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `username` VARCHAR(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_0` (`username`),
  UNIQUE KEY `uq_users_1` (`email`)
);
