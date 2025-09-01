package com.froggen.photofrog.model;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Model representing a photo generation response.
 */
public class PhotoResponse {
    
    @JsonProperty("success")
    private boolean success;
    
    @JsonProperty("imageUrl")
    private String imageUrl;
    
    @JsonProperty("message")
    private String message;
    
    @JsonProperty("generatedAt")
    private String generatedAt;
    
    @JsonProperty("format")
    private String format;
    
    @JsonProperty("size")
    private String size;

    // Default constructor
    public PhotoResponse() {}

    // Constructor for success response
    public PhotoResponse(String imageUrl, String format, String size) {
        this.success = true;
        this.imageUrl = imageUrl;
        this.format = format;
        this.size = size;
        this.generatedAt = java.time.LocalDateTime.now().toString();
    }

    // Constructor for error response
    public PhotoResponse(String message) {
        this.success = false;
        this.message = message;
        this.generatedAt = java.time.LocalDateTime.now().toString();
    }

    // Getters and Setters
    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getGeneratedAt() {
        return generatedAt;
    }

    public void setGeneratedAt(String generatedAt) {
        this.generatedAt = generatedAt;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(String format) {
        this.format = format;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    @Override
    public String toString() {
        return "PhotoResponse{" +
                "success=" + success +
                ", imageUrl='" + imageUrl + '\'' +
                ", message='" + message + '\'' +
                ", generatedAt='" + generatedAt + '\'' +
                ", format='" + format + '\'' +
                ", size='" + size + '\'' +
                '}';
    }
}






