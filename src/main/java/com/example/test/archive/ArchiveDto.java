package com.example.test.archive;

import lombok.Data;
import java.sql.Timestamp;

@Data
public class ArchiveDto {
    private Long id;
    private Long projectId;
    private String title;
    private String description;
    private Long submittedBy;
    private Boolean isPublic;
    private Boolean isSubmitted;
    private Boolean isDeleted;
    private String version;
    private Boolean approved;
    private Long approvedBy;
    private Timestamp approvedAt;
    private Timestamp submittedAt;

    // JOIN용 컬럼
    private String submittedByName;
    private String projectTitle;
    
    // 기자재 정보 (JSON 형태로 저장)
    private String equipmentInfo;

    private String category;
    

    
}
