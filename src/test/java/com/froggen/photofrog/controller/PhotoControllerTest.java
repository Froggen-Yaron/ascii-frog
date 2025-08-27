package com.froggen.photofrog.controller;

import com.froggen.photofrog.model.PhotoRequest;
import com.froggen.photofrog.model.PhotoResponse;
import com.froggen.photofrog.service.PhotoGenerationService;
import com.froggen.photofrog.service.TemplateService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(PhotoController.class)
public class PhotoControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private PhotoGenerationService photoGenerationService;

    @MockBean
    private TemplateService templateService;

    @Test
    public void testHealthEndpoint() throws Exception {
        mockMvc.perform(get("/api/health"))
                .andExpect(status().isOk())
                .andExpect(content().string("Photo Frog Generator is running!"));
    }

    @Test
    public void testGeneratePhotoSuccess() throws Exception {
        PhotoResponse mockResponse = new PhotoResponse("/images/generated/frog1_medium_happy.jpg", "jpeg", "medium");
        
        when(photoGenerationService.generatePhoto(any(PhotoRequest.class)))
                .thenReturn(mockResponse);

        String requestJson = """
            {
                "template": "frog1",
                "size": "medium",
                "expression": "happy",
                "format": "jpeg"
            }
            """;

        mockMvc.perform(post("/api/generate-photo")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.imageUrl").value("/images/generated/frog1_medium_happy.jpg"));
    }

    @Test
    public void testGeneratePhotoError() throws Exception {
        PhotoResponse mockResponse = new PhotoResponse("Template not found");
        
        when(photoGenerationService.generatePhoto(any(PhotoRequest.class)))
                .thenReturn(mockResponse);

        String requestJson = """
            {
                "template": "invalid",
                "size": "medium",
                "expression": "happy",
                "format": "jpeg"
            }
            """;

        mockMvc.perform(post("/api/generate-photo")
                .contentType(MediaType.APPLICATION_JSON)
                .content(requestJson))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value("Template not found"));
    }
}


