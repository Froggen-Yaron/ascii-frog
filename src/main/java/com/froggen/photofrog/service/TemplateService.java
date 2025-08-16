package com.froggen.photofrog.service;

import com.froggen.photofrog.model.FrogTemplate;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * Service for managing frog templates.
 */
@Service
public class TemplateService {
    
    private final List<FrogTemplate> templates;

    public TemplateService() {
        this.templates = initializeTemplates();
    }

    /**
     * Get all available templates.
     */
    public List<FrogTemplate> getAllTemplates() {
        return new ArrayList<>(templates);
    }

    /**
     * Get template by ID.
     */
    public Optional<FrogTemplate> getTemplateById(String id) {
        return templates.stream()
                .filter(template -> template.getId().equals(id))
                .findFirst();
    }

    /**
     * Get templates by category.
     */
    public List<FrogTemplate> getTemplatesByCategory(String category) {
        return templates.stream()
                .filter(template -> template.getCategory().equals(category))
                .toList();
    }

    /**
     * Initialize default templates.
     */
    private List<FrogTemplate> initializeTemplates() {
        List<FrogTemplate> defaultTemplates = new ArrayList<>();
        
        // Sitting Frog Template
        defaultTemplates.add(new FrogTemplate(
            "frog1",
            "Sitting Frog",
            "A peaceful frog sitting on a lily pad",
            "/images/templates/frog1.jpg",
            "sitting",
            new String[]{"small", "medium", "large", "custom"},
            new String[]{"happy", "sad", "surprised", "excited", "determined"}
        ));
        
        // Jumping Frog Template
        defaultTemplates.add(new FrogTemplate(
            "frog2",
            "Jumping Frog",
            "An energetic frog in mid-jump",
            "/images/templates/frog2.jpg",
            "jumping",
            new String[]{"small", "medium", "large", "custom"},
            new String[]{"happy", "excited", "determined"}
        ));
        
        // Swimming Frog Template
        defaultTemplates.add(new FrogTemplate(
            "frog3",
            "Swimming Frog",
            "A frog swimming in a pond",
            "/images/templates/frog3.jpg",
            "swimming",
            new String[]{"small", "medium", "large", "custom"},
            new String[]{"happy", "sad", "surprised", "excited"}
        ));
        
        // Tree Frog Template
        defaultTemplates.add(new FrogTemplate(
            "frog4",
            "Tree Frog",
            "A colorful tree frog on a branch",
            "/images/templates/frog4.jpg",
            "tree",
            new String[]{"small", "medium", "large", "custom"},
            new String[]{"happy", "surprised", "excited", "determined"}
        ));
        
        // Bullfrog Template
        defaultTemplates.add(new FrogTemplate(
            "frog5",
            "Bullfrog",
            "A large bullfrog in a pond",
            "/images/templates/frog5.jpg",
            "bullfrog",
            new String[]{"medium", "large", "custom"},
            new String[]{"happy", "sad", "determined"}
        ));
        
        return defaultTemplates;
    }

    /**
     * Validate if a template supports the given size.
     */
    public boolean isSizeSupported(String templateId, String size) {
        return getTemplateById(templateId)
                .map(template -> {
                    for (String supportedSize : template.getAvailableSizes()) {
                        if (supportedSize.equals(size)) {
                            return true;
                        }
                    }
                    return false;
                })
                .orElse(false);
    }

    /**
     * Validate if a template supports the given expression.
     */
    public boolean isExpressionSupported(String templateId, String expression) {
        return getTemplateById(templateId)
                .map(template -> {
                    for (String supportedExpression : template.getAvailableExpressions()) {
                        if (supportedExpression.equals(expression)) {
                            return true;
                        }
                    }
                    return false;
                })
                .orElse(false);
    }
}
