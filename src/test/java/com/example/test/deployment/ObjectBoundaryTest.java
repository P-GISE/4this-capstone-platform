package com.example.test.deployment;

import com.example.test.archive.*;
import com.example.test.auth.AuthDto;
import com.example.test.config.AccessDeniedException;
import com.example.test.project.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.lang.reflect.Field;
import java.lang.reflect.Proxy;
import java.util.Arrays;
import java.util.Collections;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.Test;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.web.servlet.mvc.support.RedirectAttributesModelMap;
import static org.junit.Assert.*;

public class ObjectBoundaryTest {
    private MockHttpSession session(long id, String role) {
        AuthDto user = new AuthDto(); user.setId(id); user.setRole(role);
        MockHttpSession session = new MockHttpSession(); session.setAttribute("loginUser", user);
        return session;
    }

    @Test public void taskMutationRequiresMembershipAndActualTaskProject() throws Exception {
        AtomicInteger writes = new AtomicInteger();
        ProjectDto project = new ProjectDto(); project.setId(20L);
        ProjectTaskDto task = new ProjectTaskDto(); task.setId(30L); task.setProjectId(20L);
        ProjectDetailDto detail = new ProjectDetailDto(); detail.setTasks(Arrays.asList(task));
        ProjectService service = (ProjectService) Proxy.newProxyInstance(ProjectService.class.getClassLoader(),
                new Class<?>[]{ProjectService.class}, (proxy, method, args) -> {
                    if (method.getName().equals("getProjectsForUser"))
                        return Long.valueOf(1L).equals(args[0]) ? Arrays.asList(project) : Collections.emptyList();
                    if (method.getName().equals("getProjectDetail")) return detail;
                    if (method.getName().equals("deleteTask")) writes.incrementAndGet();
                    return null;
                });
        ProjectController controller = new ProjectController(service, new ObjectMapper(), null, null, null, null);
        assertThrows(AccessDeniedException.class, () -> controller.deleteTask(30L, 20L, session(2L, "STUDENT")));
        assertThrows(AccessDeniedException.class, () -> controller.deleteTask(999L, 20L, session(1L, "STUDENT")));
        assertEquals(0, writes.get());
        controller.deleteTask(30L, 20L, session(1L, "STUDENT"));
        assertEquals(1, writes.get());
    }

    @Test public void archiveMutationRequiresAuthorOrAdministrator() throws Exception {
        AtomicInteger writes = new AtomicInteger();
        ArchiveDto archive = new ArchiveDto(); archive.setId(20L); archive.setSubmittedBy(1L);
        ArchiveService service = (ArchiveService) Proxy.newProxyInstance(ArchiveService.class.getClassLoader(),
                new Class<?>[]{ArchiveService.class}, (proxy, method, args) -> {
                    if (method.getName().equals("getArchiveById")) return archive;
                    if (method.getName().equals("deleteArchive")) writes.incrementAndGet();
                    return null;
                });
        ArchiveController controller = new ArchiveController();
        Field field = ArchiveController.class.getDeclaredField("archiveService");
        field.setAccessible(true); field.set(controller, service);
        assertThrows(AccessDeniedException.class, () -> controller.deleteArchive(20L, new RedirectAttributesModelMap(), session(2L, "STUDENT")));
        assertEquals(0, writes.get());
        controller.deleteArchive(20L, new RedirectAttributesModelMap(), session(1L, "STUDENT"));
        controller.deleteArchive(20L, new RedirectAttributesModelMap(), session(2L, "ADMIN"));
        assertEquals(2, writes.get());
    }
}
