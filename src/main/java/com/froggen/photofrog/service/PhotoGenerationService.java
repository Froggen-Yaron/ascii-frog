package com.froggen.photofrog.service;

import com.froggen.photofrog.model.FrogTemplate;
import com.froggen.photofrog.model.PhotoRequest;
import com.froggen.photofrog.model.PhotoResponse;
import com.froggen.photofrog.util.ImageUtils;
import com.froggen.photofrog.util.PhotoFilters;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

/**
 * Service for generating photo-realistic frog images.
 */
@Service
public class PhotoGenerationService {
    
    private final TemplateService templateService;
    private final ImageUtils imageUtils;
    private final PhotoFilters photoFilters;

    @Autowired
    public PhotoGenerationService(TemplateService templateService, ImageUtils imageUtils, PhotoFilters photoFilters) {
        this.templateService = templateService;
        this.imageUtils = imageUtils;
        this.photoFilters = photoFilters;
    }

    /**
     * Generate a frog photo based on the request parameters.
     */
    public PhotoResponse generatePhoto(PhotoRequest request) {
        try {
            // Validate template exists
            Optional<FrogTemplate> templateOpt = templateService.getTemplateById(request.getTemplate());
            if (templateOpt.isEmpty()) {
                return new PhotoResponse("Template not found: " + request.getTemplate());
            }

            FrogTemplate template = templateOpt.get();

            // Validate size is supported
            if (!templateService.isSizeSupported(request.getTemplate(), request.getSize())) {
                return new PhotoResponse("Size not supported for template: " + request.getSize());
            }

            // Validate expression is supported
            if (!templateService.isExpressionSupported(request.getTemplate(), request.getExpression())) {
                return new PhotoResponse("Expression not supported for template: " + request.getExpression());
            }

            // Generate the image
            String imageUrl = generateImage(template, request);
            
            return new PhotoResponse(imageUrl, request.getFormat(), request.getSize());

        } catch (Exception e) {
            return new PhotoResponse("Error generating photo: " + e.getMessage());
        }
    }

    /**
     * Generate the actual image using the template and request parameters.
     */
    private String generateImage(FrogTemplate template, PhotoRequest request) {
        // For now, return a placeholder image URL
        // In a real implementation, this would use OpenCV to process the template
        // and apply the requested modifications
        
        String baseUrl = "/images/generated/";
        String filename = String.format("frog_%s_%s_%s.%s", 
            template.getId(), 
            request.getSize(), 
            request.getExpression(), 
            request.getFormat());
        
        return baseUrl + filename;
    }

    /**
     * Get available sizes for a template.
     */
    public String[] getAvailableSizes(String templateId) {
        return templateService.getTemplateById(templateId)
                .map(FrogTemplate::getAvailableSizes)
                .orElse(new String[0]);
    }

    /**
     * Get available expressions for a template.
     */
    public String[] getAvailableExpressions(String templateId) {
        return templateService.getTemplateById(templateId)
                .map(FrogTemplate::getAvailableExpressions)
                .orElse(new String[0]);
    }

    /**
     * Generate photo with performance monitoring.
     */
    public PhotoResponse generatePhotoWithPerformance(PhotoRequest request) {
        long startTime = System.currentTimeMillis();
        
        PhotoResponse response = generatePhoto(request);
        
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;
        
        // Log performance metrics
        System.out.println("Photo generation took " + duration + "ms for template: " + request.getTemplate());
        
        return response;
    }

    /**
     * Apply expression filter to an image.
     */
    public java.awt.image.BufferedImage applyExpressionFilter(java.awt.image.BufferedImage image, String expression) {
        return photoFilters.applyExpressionFilter(image, expression);
    }
}
