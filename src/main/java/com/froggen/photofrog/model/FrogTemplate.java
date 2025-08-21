package com.froggen.photofrog.model;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Model representing a frog template for photo generation.
 */
public class FrogTemplate {
    
    @JsonProperty("id")
    private String id;
    
    @JsonProperty("name")
    private String name;
    
    @JsonProperty("description")
    private String description;
    
    @JsonProperty("imagePath")
    private String imagePath;
    
    @JsonProperty("category")
    private String category;
    
    @JsonProperty("availableSizes")
    private String[] availableSizes;
    
    @JsonProperty("availableExpressions")
    private String[] availableExpressions;

    // Default constructor
    public FrogTemplate() {}

    // Constructor with all fields
    public FrogTemplate(String id, String name, String description, String imagePath, 
                       String category, String[] availableSizes, String[] availableExpressions) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.imagePath = imagePath;
        this.category = category;
        this.availableSizes = availableSizes;
        this.availableExpressions = availableExpressions;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String[] getAvailableSizes() {
        return availableSizes;
    }

    public void setAvailableSizes(String[] availableSizes) {
        this.availableSizes = availableSizes;
    }

    public String[] getAvailableExpressions() {
        return availableExpressions;
    }

    public void setAvailableExpressions(String[] availableExpressions) {
        this.availableExpressions = availableExpressions;
    }

    @Override
    public String toString() {
        return "FrogTemplate{" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", imagePath='" + imagePath + '\'' +
                ", category='" + category + '\'' +
                '}';
    }
}

