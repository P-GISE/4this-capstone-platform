FROM maven:3.9-eclipse-temurin-26 AS build
WORKDIR /src
COPY pom.xml ./
COPY src ./src
COPY database ./database
RUN mvn -B -ntp clean package

FROM tomcat:11.0.27-jdk21-temurin-noble@sha256:6e0d99d18e38a23a95574a67bd7849d46844b649c9b5238d91a3d0a3bf5f489a
RUN useradd --system --uid 10001 --create-home app \
    && mkdir -p /app/uploads \
    && chown -R app:app /app /usr/local/tomcat \
    && rm -rf /usr/local/tomcat/webapps/*
COPY --from=build --chown=app:app /src/target/ROOT.war /usr/local/tomcat/webapps/ROOT.war
COPY docker/context.xml /usr/local/tomcat/conf/context.xml
COPY docker/logging.properties /usr/local/tomcat/conf/logging.properties
RUN sed -i '/<Valve className="org.apache.catalina.valves.AccessLogValve"/,/\/>/d' /usr/local/tomcat/conf/server.xml
USER app
ENV JAVA_OPTS="-Xms128m -Xmx512m -Djava.awt.headless=true"
EXPOSE 8080
CMD ["catalina.sh", "run"]
