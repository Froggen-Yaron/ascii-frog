package com.froggen.photofrog.service;

import com.froggen.photofrog.model.FrogTemplate;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("TemplateService Tests")
public class TemplateServiceTest {

    private TemplateService templateService;

    @BeforeEach
    void setUp() {
        templateService = new TemplateService();
    }

    @Test
    @DisplayName("Should return all templates")
    void shouldReturnAllTemplates() {
        List<FrogTemplate> templates = templateService.getAllTemplates();
        
        assertNotNull(templates);
        assertFalse(templates.isEmpty());
        assertEquals(5, templates.size()); // 5 default templates
    }

    @Test
    @DisplayName("Should find template by valid ID")
    void shouldFindTemplateByValidId() {
        Optional<FrogTemplate> template = templateService.getTemplateById("frog1");
        
        assertTrue(template.isPresent());
        assertEquals("frog1", template.get().getId());
        assertEquals("Sitting Frog", template.get().getName());
    }

    @Test
    @DisplayName("Should return empty for invalid template ID")
    void shouldReturnEmptyForInvalidId() {
        Optional<FrogTemplate> template = templateService.getTemplateById("invalid");
        
        assertFalse(template.isPresent());
    }

    @Test
    @DisplayName("Should return templates by category")
    void shouldReturnTemplatesByCategory() {
        List<FrogTemplate> sittingTemplates = templateService.getTemplatesByCategory("sitting");
        
        assertNotNull(sittingTemplates);
        assertEquals(1, sittingTemplates.size());
        assertEquals("sitting", sittingTemplates.get(0).getCategory());
    }

    @Test
    @DisplayName("Should validate supported size")
    void shouldValidateSupportedSize() {
        assertTrue(templateService.isSizeSupported("frog1", "small"));
        assertTrue(templateService.isSizeSupported("frog1", "medium"));
        assertTrue(templateService.isSizeSupported("frog1", "large"));
        assertTrue(templateService.isSizeSupported("frog1", "custom"));
    }

    @Test
    @DisplayName("Should validate unsupported size")
    void shouldValidateUnsupportedSize() {
        assertFalse(templateService.isSizeSupported("frog1", "extra-large"));
        assertFalse(templateService.isSizeSupported("invalid", "small"));
    }

    @Test
    @DisplayName("Should validate supported expression")
    void shouldValidateSupportedExpression() {
        assertTrue(templateService.isExpressionSupported("frog1", "happy"));
        assertTrue(templateService.isExpressionSupported("frog1", "sad"));
        assertTrue(templateService.isExpressionSupported("frog1", "surprised"));
    }

    @Test
    @DisplayName("Should validate unsupported expression")
    void shouldValidateUnsupportedExpression() {
        assertFalse(templateService.isExpressionSupported("frog1", "angry"));
        assertFalse(templateService.isExpressionSupported("invalid", "happy"));
    }

    @Test
    @DisplayName("Should have correct template structure")
    void shouldHaveCorrectTemplateStructure() {
        Optional<FrogTemplate> template = templateService.getTemplateById("frog1");
        
        assertTrue(template.isPresent());
        FrogTemplate frog = template.get();
        
        assertNotNull(frog.getId());
        assertNotNull(frog.getName());
        assertNotNull(frog.getDescription());
        assertNotNull(frog.getImagePath());
        assertNotNull(frog.getCategory());
        assertNotNull(frog.getAvailableSizes());
        assertNotNull(frog.getAvailableExpressions());
        
        assertTrue(frog.getAvailableSizes().length > 0);
        assertTrue(frog.getAvailableExpressions().length > 0);
    }
}
