package com.example.test.config;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import org.springframework.core.io.Resource;
import org.springframework.web.servlet.resource.PathResourceResolver;

public class PrivateUploadResourceResolver extends PathResourceResolver {
    private final Path reports;

    public PrivateUploadResourceResolver() { this(Paths.get(RuntimePaths.uploads("reports"))); }

    public PrivateUploadResourceResolver(Path reports) { this.reports = reports.toAbsolutePath().normalize(); }

    @Override protected boolean checkResource(Resource resource, Resource location) throws IOException {
        if (!super.checkResource(resource, location)) return false;
        Path privateRoot = Files.exists(reports) ? reports.toRealPath() : reports;
        return !resource.getFile().toPath().toRealPath().startsWith(privateRoot);
    }
}
