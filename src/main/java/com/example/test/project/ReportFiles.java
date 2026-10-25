package com.example.test.project;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.Locale;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import org.springframework.web.multipart.MultipartFile;

final class ReportFiles {
    static final long MAX_BYTES = 10 * 1024 * 1024;

    private ReportFiles() { }

    static Path save(Path root, Long projectId, MultipartFile file) throws IOException {
        String name = file.getOriginalFilename();
        if (projectId == null || projectId <= 0 || file.isEmpty() || file.getSize() > MAX_BYTES
                || name == null || name.isEmpty() || name.length() > 200
                || name.matches(".*[\\\\/\\p{Cntrl}].*")) throw invalid();
        int dot = name.lastIndexOf('.');
        String extension = dot < 0 ? "" : name.substring(dot + 1).toLowerCase(Locale.ROOT);
        if (!Arrays.asList("pdf", "txt", "hwp", "hwpx", "docx", "xlsx", "pptx").contains(extension)) throw invalid();
        Files.createDirectories(root);
        Path realRoot = root.toRealPath();
        Path directory = realRoot.resolve(projectId.toString());
        Files.createDirectories(directory);
        if (Files.isSymbolicLink(directory) || !directory.toRealPath().startsWith(realRoot)) throw invalid();
        Path target = Files.createTempFile(directory, "report-", "." + extension);
        try {
            try (InputStream input = file.getInputStream(); OutputStream output = Files.newOutputStream(target,
                    StandardOpenOption.WRITE, StandardOpenOption.TRUNCATE_EXISTING, LinkOption.NOFOLLOW_LINKS)) {
                byte[] buffer = new byte[8192];
                long total = 0;
                int count;
                while ((count = input.read(buffer)) != -1) {
                    total += count;
                    if (total > MAX_BYTES) throw invalid();
                    output.write(buffer, 0, count);
                }
                if (total == 0) throw invalid();
            }
            validateContent(target, extension);
            return target;
        } catch (IOException | RuntimeException failed) {
            Files.deleteIfExists(target);
            throw failed;
        }
    }

    static Path downloadPath(Path root, String storedPath) throws IOException {
        Path path = java.nio.file.Paths.get(storedPath);
        if (Files.isSymbolicLink(path) || !Files.isRegularFile(path, LinkOption.NOFOLLOW_LINKS)) throw invalid();
        Path real = path.toRealPath();
        if (!real.startsWith(root.toRealPath())) throw invalid();
        return real;
    }

    private static void validateContent(Path path, String extension) throws IOException {
        byte[] prefix;
        try (InputStream input = Files.newInputStream(path)) { prefix = input.readNBytes(8); }
        if ("pdf".equals(extension)) {
            if (!new String(prefix, StandardCharsets.US_ASCII).startsWith("%PDF-")) throw invalid();
        } else if ("hwp".equals(extension)) {
            if (!Arrays.equals(prefix, new byte[]{(byte)0xd0,(byte)0xcf,0x11,(byte)0xe0,(byte)0xa1,(byte)0xb1,0x1a,(byte)0xe1})) throw invalid();
        } else if ("txt".equals(extension)) {
            byte[] body = Files.readAllBytes(path);
            try { StandardCharsets.UTF_8.newDecoder().decode(java.nio.ByteBuffer.wrap(body)); }
            catch (java.nio.charset.CharacterCodingException invalidText) { throw invalid(); }
            for (byte value : body) if (value == 0) throw invalid();
        } else {
            String required = "docx".equals(extension) ? "word/document.xml"
                    : "xlsx".equals(extension) ? "xl/workbook.xml"
                    : "pptx".equals(extension) ? "ppt/presentation.xml" : "Contents/section0.xml";
            try (ZipFile archive = new ZipFile(path.toFile())) {
                if (archive.size() > 2048 || archive.getEntry(required) == null) throw invalid();
                Enumeration<? extends ZipEntry> entries = archive.entries();
                while (entries.hasMoreElements()) {
                    if (entries.nextElement().getName().toLowerCase(Locale.ROOT).contains("vbaproject")) throw invalid();
                }
            }
        }
    }

    private static IllegalArgumentException invalid() {
        return new IllegalArgumentException("10MB 이하의 PDF, TXT, HWP, HWPX, DOCX, XLSX, PPTX 보고서만 사용할 수 있습니다.");
    }
}
