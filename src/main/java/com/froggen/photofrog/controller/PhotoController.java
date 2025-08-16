package com.froggen.photofrog.controller;

import com.froggen.photofrog.model.PhotoRequest;
import com.froggen.photofrog.model.PhotoResponse;
import com.froggen.photofrog.model.FrogTemplate;
import com.froggen.photofrog.service.PhotoGenerationService;
import com.froggen.photofrog.service.TemplateService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller for photo generation endpoints.
 */
@RestController
@RequestMapping("/api")
public class PhotoController {
    
    private final PhotoGenerationService photoGenerationService;
    private final TemplateService templateService;

    @Autowired
    public PhotoController(PhotoGenerationService photoGenerationService, TemplateService templateService) {
        this.photoGenerationService = photoGenerationService;
        this.templateService = templateService;
    }

    /**
     * Generate a frog photo.
     */
    @PostMapping("/generate-photo")
    public ResponseEntity<PhotoResponse> generatePhoto(@Valid @RequestBody PhotoRequest request) {
        PhotoResponse response = photoGenerationService.generatePhoto(request);
        
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * Get all available templates.
     */
    @GetMapping("/templates")
    public ResponseEntity<List<FrogTemplate>> getTemplates() {
        List<FrogTemplate> templates = templateService.getAllTemplates();
        return ResponseEntity.ok(templates);
    }

    /**
     * Get templates by category.
     */
    @GetMapping("/templates/category/{category}")
    public ResponseEntity<List<FrogTemplate>> getTemplatesByCategory(@PathVariable String category) {
        List<FrogTemplate> templates = templateService.getTemplatesByCategory(category);
        return ResponseEntity.ok(templates);
    }

    /**
     * Get a specific template by ID.
     */
    @GetMapping("/templates/{id}")
    public ResponseEntity<FrogTemplate> getTemplateById(@PathVariable String id) {
        return templateService.getTemplateById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Get available sizes for a template.
     */
    @GetMapping("/templates/{id}/sizes")
    public ResponseEntity<String[]> getAvailableSizes(@PathVariable String id) {
        String[] sizes = photoGenerationService.getAvailableSizes(id);
        return ResponseEntity.ok(sizes);
    }

    /**
     * Get available expressions for a template.
     */
    @GetMapping("/templates/{id}/expressions")
    public ResponseEntity<String[]> getAvailableExpressions(@PathVariable String id) {
        String[] expressions = photoGenerationService.getAvailableExpressions(id);
        return ResponseEntity.ok(expressions);
    }

    /**
     * Health check endpoint.
     */
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Photo Frog Generator is running!");
    }
}
