package com.example.test.project;

import java.lang.reflect.Field;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;
import java.util.Collections;
import com.example.test.config.PrivateUploadResourceResolver;
import org.springframework.core.io.FileSystemResource;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.mock.web.MockServletContext;
import org.springframework.web.servlet.HandlerMapping;
import org.springframework.web.servlet.resource.ResourceHttpRequestHandler;
import org.junit.Before;
import org.junit.Test;
import org.springframework.mock.web.MockMultipartFile;
import static org.junit.Assert.*;

public class ReportSecurityTest {
    private ProjectServiceImpl service;
    private AtomicReference<ProjectReportDto> stored;
    private long projectId;

    @Before public void setup() throws Exception {
        projectId = Integer.toUnsignedLong(UUID.randomUUID().hashCode()) + 1;
        service = new ProjectServiceImpl();
        stored = new AtomicReference<>();
        ProjectDao dao = new ProjectDao() {
            @Override public void createReport(ProjectReportDto report) { stored.set(report); }
            @Override public ProjectReportDto findReportById(Long id) { return stored.get(); }
        };
        Field field = ProjectServiceImpl.class.getDeclaredField("projectDao");
        field.setAccessible(true); field.set(service, dao);
    }

    @Test public void activeHtmlCannotBeStoredAsAReport() {
        assertThrows(IllegalArgumentException.class, () -> service.uploadReport(projectId,
            new MockMultipartFile("file", "report.html", "text/html", "<script>test</script>".getBytes()), 1L));
        assertNull(stored.get());
    }

    @Test public void fakePdfContentAndFilenameTraversalAreRejected() {
        assertThrows(IllegalArgumentException.class, () -> service.uploadReport(projectId,
            new MockMultipartFile("file", "report.pdf", "application/pdf", "<script>test</script>".getBytes()), 1L));
        assertThrows(IllegalArgumentException.class, () -> service.uploadReport(projectId,
            new MockMultipartFile("file", "../../report.pdf", "application/pdf", "%PDF-1.7\nsynthetic".getBytes()), 1L));
        assertNull(stored.get());
    }

    @Test public void validPdfUsesGeneratedFilenameAndAttachmentDownload() throws Exception {
        byte[] body = "%PDF-1.7\nsynthetic".getBytes();
        service.uploadReport(projectId,
            new MockMultipartFile("file", "synthetic-report.pdf", "application/pdf", body), 1L);
        assertNotNull(stored.get());
        Path path = Paths.get(stored.get().getFilePath());
        try {
            assertFalse(path.getFileName().toString().contains("synthetic-report"));
            assertArrayEquals(body, Files.readAllBytes(path));
            assertTrue(path.startsWith(Paths.get(System.getenv("UPLOAD_DIR")).toAbsolutePath().normalize()));
            assertTrue(service.downloadReport(1L).getHeaders().getFirst("Content-Disposition").startsWith("attachment;"));
            assertEquals("nosniff", service.downloadReport(1L).getHeaders().getFirst("X-Content-Type-Options"));
        } finally {
            Files.deleteIfExists(path);
            Files.deleteIfExists(path.getParent());
        }
    }

    @Test public void streamLimitDoesNotTrustDeclaredMultipartSize() throws Exception {
        byte[] oversized = new byte[(int)ReportFiles.MAX_BYTES + 1];
        MockMultipartFile file = new MockMultipartFile("file", "too-large.pdf", "application/pdf", oversized) {
            @Override public long getSize() { return 1; }
        };
        assertThrows(IllegalArgumentException.class, () -> service.uploadReport(projectId, file, 1L));
        assertNull(stored.get());
        Path directory = Paths.get(System.getenv("UPLOAD_DIR"), "reports", Long.toString(projectId));
        try (java.util.stream.Stream<Path> files = Files.list(directory)) { assertEquals(0, files.count()); }
        Files.delete(directory);
    }

    @Test public void staticUploadHandlerDeniesReportsButPreservesPublicAssets() throws Exception {
        Path root = Files.createTempDirectory("fourthis-static-synthetic-");
        Path reports = Files.createDirectory(root.resolve("reports"));
        Path privateReport = Files.write(reports.resolve("report.pdf"), "%PDF-synthetic".getBytes());
        Path publicAsset = Files.write(root.resolve("public.txt"), "public-synthetic".getBytes());
        ResourceHttpRequestHandler handler = new ResourceHttpRequestHandler();
        handler.setServletContext(new MockServletContext());
        handler.setLocations(Collections.singletonList(new FileSystemResource(root.toString() + "/")));
        handler.setResourceResolvers(Collections.singletonList(new PrivateUploadResourceResolver(reports)));
        handler.afterPropertiesSet();
        try {
            MockHttpServletRequest denied = new MockHttpServletRequest("GET", "/uploads/reports/report.pdf");
            denied.setAttribute(HandlerMapping.PATH_WITHIN_HANDLER_MAPPING_ATTRIBUTE, "reports/report.pdf");
            MockHttpServletResponse deniedResponse = new MockHttpServletResponse();
            assertThrows(org.springframework.web.servlet.resource.NoResourceFoundException.class,
                () -> handler.handleRequest(denied, deniedResponse));
            MockHttpServletRequest allowed = new MockHttpServletRequest("GET", "/uploads/public.txt");
            allowed.setAttribute(HandlerMapping.PATH_WITHIN_HANDLER_MAPPING_ATTRIBUTE, "public.txt");
            MockHttpServletResponse allowedResponse = new MockHttpServletResponse();
            handler.handleRequest(allowed, allowedResponse);
            assertEquals(200, allowedResponse.getStatus());
            assertEquals("public-synthetic", allowedResponse.getContentAsString());
        } finally {
            Files.deleteIfExists(privateReport); Files.deleteIfExists(publicAsset);
            Files.deleteIfExists(reports); Files.deleteIfExists(root);
        }
    }
}
