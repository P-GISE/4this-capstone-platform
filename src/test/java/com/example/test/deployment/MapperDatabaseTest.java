package com.example.test.deployment;

import org.apache.ibatis.builder.xml.XMLMapperBuilder;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.mapping.SqlCommandType;
import org.apache.ibatis.session.Configuration;
import org.junit.Assume;
import org.junit.Test;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.sql.*;
import java.util.*;
import java.util.regex.*;
import static org.junit.Assert.*;

public class MapperDatabaseTest {
    static Configuration mappers() throws Exception {
        Configuration config=new Configuration();
        config.setMapUnderscoreToCamelCase(true);
        try (DirectoryStream<Path> files=Files.newDirectoryStream(Paths.get("src/main/resources/mapper"),"*.xml")) {
            for(Path path:files) try(InputStream input=Files.newInputStream(path)) {
                new XMLMapperBuilder(input,config,path.toString(),config.getSqlFragments()).parse();
            }
        }
        return config;
    }

    static Map<String,Object> parameters(boolean filtered) throws Exception {
        Map<String,Object> values=new HashMap<>();
        Pattern names=Pattern.compile(Pattern.quote("#{")+"([A-Za-z][A-Za-z0-9_.]*)");
        try(DirectoryStream<Path> files=Files.newDirectoryStream(Paths.get("src/main/resources/mapper"),"*.xml")) {
            for(Path path:files) {
                Matcher found=names.matcher(new String(Files.readAllBytes(path),StandardCharsets.UTF_8));
                while(found.find()) {
                    String key=found.group(1);
                    if(key.contains(".")) continue;
                    String lower=key.toLowerCase(Locale.ROOT);
                    Object value=Long.valueOf(1);
                    if(lower.contains("date")||lower.endsWith("at")||lower.contains("time")) value="2026-10-24 00:00:00";
                    if(Arrays.asList("search","keyword","query","status","category","location","type","userRole","logLevel","loginType","actionType").contains(key)) value=filtered?"SYNTHETIC":"";
                    if(key.equals("year")) value=filtered?"2026":"";
                    values.put(key,value);
                }
            }
        }
        values.put("offset",0); values.put("limit",1); values.put("size",1);
        values.put("sortBy","created"); values.put("sortOrder","desc"); values.put("sort","newest");
        values.put("params",new HashMap<String,Object>() {{
            put("offset",0);put("size",1);put("search",filtered?"SYNTHETIC":"");put("status","");put("urgency","");
        }});
        for(String key:Arrays.asList("list","memberIds","questionIds","userIds")) values.put(key,Arrays.asList(1L));
        values.put("hasFile",filtered?Boolean.TRUE:null);values.put("isPinned",filtered?Boolean.FALSE:null);
        if(!filtered) { values.put("dateFrom",null);values.put("dateTo",null);values.put("startDate",null);values.put("endDate",null); }
        return values;
    }

    static void bind(PreparedStatement statement, BoundSql sql, Map<String,Object> values) throws Exception {
        for(int i=0;i<sql.getParameterMappings().size();i++) {
            String key=sql.getParameterMappings().get(i).getProperty();
            Object value;
            if(sql.hasAdditionalParameter(key)) value=sql.getAdditionalParameter(key);
            else if(key.startsWith("params.")) value=((Map<?,?>)values.get("params")).get(key.substring(7));
            else value=values.get(key);
            statement.setObject(i+1,value);
        }
    }

    @Test
    public void chatRoomPrimaryKeyQueriesExecuteAgainstTheFreshSchema() throws Exception {
        try(Connection connection=DriverManager.getConnection("jdbc:h2:mem:fourthis_mapper;MODE=MySQL;DATABASE_TO_LOWER=TRUE","sa","")) {
            SchemaDatabaseTest.initialize(connection);
            Configuration config=mappers();
            try(Statement seed=connection.createStatement()) {
                seed.executeUpdate("INSERT INTO chat_rooms(name,description) VALUES('Synthetic room','Fixture')");
            }
            Map<String,Object> values=parameters(false);
            values.put("roomId",1L);values.put("roomName","Updated");values.put("roomDescription","Fixture");
            values.put("name","Updated");values.put("description","Fixture");
            for(String shortId:Arrays.asList("updateChatRoom","searchChatRooms","deleteChatRoom")) {
                MappedStatement mapper=config.getMappedStatement("com.example.test.chat.ChatDAO."+shortId);
                BoundSql sql=mapper.getBoundSql(values);
                try(PreparedStatement prepared=connection.prepareStatement(sql.getSql())) {
                    bind(prepared,sql,values);
                    if(mapper.getSqlCommandType()==SqlCommandType.SELECT) prepared.executeQuery().close();
                    else assertEquals(1,prepared.executeUpdate());
                }
            }
        }
    }

    @Test
    public void everySelectPreparesAndExecutesOnAnExplicitEmptyMariaDbFixture() throws Exception {
        String url=System.getenv("TEST_DB_URL");
        Assume.assumeTrue("An isolated MariaDB fixture is required for dialect verification",url!=null&&!url.isEmpty());
        assertTrue("Only a loopback disposable test database may be initialized",
                url.matches("jdbc:mariadb://(127[.]0[.]0[.]1|localhost)(:[0-9]+)?/fourthis_schema_test"));
        try(Connection connection=DriverManager.getConnection(url,System.getenv("TEST_DB_USERNAME"),System.getenv("TEST_DB_PASSWORD"))) {
            try(ResultSet tables=connection.getMetaData().getTables(connection.getCatalog(),null,"%",new String[]{"TABLE"})) {
                assertFalse("Test database must be empty; existing data is never cleared",tables.next());
            }
            SchemaDatabaseTest.initialize(connection);
            Configuration config=mappers();
            Set<String> ids=new TreeSet<>();
            for(String id:config.getMappedStatementNames()) if(id.contains(".")) ids.add(id);
            List<String> failures=new ArrayList<>();
            int checked=0;
            for(boolean filtered:new boolean[]{false,true}) {
                Map<String,Object> values=parameters(filtered);
                for(String id:ids) {
                    MappedStatement mapper=config.getMappedStatement(id);
                    if(mapper.getSqlCommandType()!=SqlCommandType.SELECT) continue;
                    try {
                        BoundSql sql=mapper.getBoundSql(values);
                        try(PreparedStatement prepared=connection.prepareStatement(sql.getSql())) {
                            bind(prepared,sql,values);
                            prepared.setQueryTimeout(5);
                            prepared.executeQuery().close();
                        }
                        checked++;
                    } catch(Exception failure) {
                        String detail=failure instanceof SQLException?((SQLException)failure).getSQLState():failure.getClass().getSimpleName();
                        Matcher column=Pattern.compile("Unknown column '([^']+)'").matcher(String.valueOf(failure.getMessage()));
                        if(column.find()) detail+=" column="+column.group(1);
                        failures.add(id+" filtered="+filtered+" "+detail);
                    }
                }
            }
            assertTrue("Mapper query failures: "+failures,failures.isEmpty());
            assertTrue("Expected broad mapper query coverage",checked>200);
            System.out.println("MariaDB empty-fixture SELECT executions="+checked);
        }
    }
}
