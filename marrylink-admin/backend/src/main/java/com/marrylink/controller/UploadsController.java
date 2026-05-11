package com.marrylink.controller;

import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * 文件访问控制器
 * 注意：上传路径统一为 {user.dir}/marrylink-admin/uploads/，此处读取路径必须与之一致
 */
@RestController
@RequestMapping("/uploads")
public class UploadsController {

    /**
     * 获取上传文件的根目录（与 HostController.uploadFile / CorsConfig 保持一致）
     */
    private String getUploadBaseDir() {
        return System.getProperty("user.dir") + File.separator + "marrylink-admin" + File.separator + "uploads";
    }

    @GetMapping("/avatars/{filename}")
    public ResponseEntity<Resource> getAvatar(@PathVariable String filename) {
        return serveFile("avatars", filename);
    }

    @GetMapping("/certificates/{filename}")
    public ResponseEntity<Resource> getCertificate(@PathVariable String filename) {
        return serveFile("certificates", filename);
    }

    @GetMapping("/photos/{filename}")
    public ResponseEntity<Resource> getPhoto(@PathVariable String filename) {
        return serveFile("photos", filename);
    }

    private ResponseEntity<Resource> serveFile(String subDir, String filename) {
        try {
            String uploadDir = getUploadBaseDir() + File.separator + subDir;
            Path filePath = Paths.get(uploadDir).resolve(filename).normalize();

            // 防止路径穿越
            if (!filePath.startsWith(Paths.get(uploadDir))) {
                return ResponseEntity.badRequest().build();
            }

            Resource resource = new UrlResource(filePath.toUri());

            if (resource.exists() && resource.isReadable()) {
                String contentType = "application/octet-stream";
                String lower = filename.toLowerCase();
                if (lower.endsWith(".png")) {
                    contentType = "image/png";
                } else if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
                    contentType = "image/jpeg";
                } else if (lower.endsWith(".gif")) {
                    contentType = "image/gif";
                } else if (lower.endsWith(".webp")) {
                    contentType = "image/webp";
                }

                return ResponseEntity.ok()
                        .contentType(MediaType.parseMediaType(contentType))
                        .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + resource.getFilename() + "\"")
                        .body(resource);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}
