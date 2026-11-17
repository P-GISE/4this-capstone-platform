package com.example.test.deployment;

import java.nio.file.Files;
import java.nio.file.Path;
import org.apache.taglibs.standard.tag.rt.core.OutTag;
import org.junit.Test;
import org.springframework.mock.web.MockPageContext;
import static org.junit.Assert.*;

public class JspOutputSecurityTest {
    @Test public void jstlOutputEscapesUserTextAndAttributeDelimiters() throws Exception {
        MockPageContext page = new MockPageContext();
        OutTag tag = new OutTag();
        tag.setPageContext(page);
        tag.setValue("A&B <tag> \"quoted\" 'single'");
        tag.doStartTag();
        tag.doEndTag();
        String output = page.getContentAsString();
        assertTrue(output.contains("A&amp;B &lt;tag&gt;"));
        assertFalse(output.contains("\"quoted\""));
        assertFalse(output.contains("'single'"));
    }

    @Test public void inquiryAndChatUseEscapedOutputAtPersistedContentSinks() throws Exception {
        Path views = Path.of("src/main/webapp/WEB-INF/views");
        for (String page : new String[]{"inquiry/view.jsp", "inquiry/edit.jsp"}) {
            String source = Files.readString(views.resolve(page));
            assertTrue(page, source.contains("<c:out value='${inquiry.title}' />"));
            assertTrue(page, source.contains("<c:out value='${inquiry.content}' />"));
        }
        String chat = Files.readString(views.resolve("chat/chatRoom.jsp"));
        assertTrue(chat.contains("<c:out value='${message.content}' />"));
        assertTrue(chat.contains("messageText.textContent = safeContent"));
        assertFalse(chat.contains("id=\"chatMessages\"\n                     data-user-id="));
    }
}
