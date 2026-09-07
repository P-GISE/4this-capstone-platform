package com.example.test.archive;

import lombok.Data;
import java.sql.Timestamp;

@Data
public class ArchiveFileDto {
    private Long id;
    private Long archiveId;
    private String fileName;
    private String originalFileName;
    private String filePath;
    private String fileType;
    private Long fileSize;
    private Integer downloadCount;
    private Boolean isDeleted;
    private Timestamp uploadedAt;
}