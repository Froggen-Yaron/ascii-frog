package com.froggen.photofrog.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * Model representing a photo generation request.
 */
public class PhotoRequest {
    
    @JsonProperty("template")
    @NotBlank(message = "Template is required")
    private String template;
    
    @JsonProperty("size")
    @NotBlank(message = "Size is required")
    private String size;
    
    @JsonProperty("expression")
    @NotBlank(message = "Expression is required")
    private String expression;
    
    @JsonProperty("format")
    @NotBlank(message = "Format is required")
    private String format;
    
    @JsonProperty("customWidth")
    private Integer customWidth;
    
    @JsonProperty("customHeight")
    private Integer customHeight;

    // Default constructor
    public PhotoRequest() {}

    // Constructor with required fields
    public PhotoRequest(String template, String size, String expression, String format) {
        this.template = template;
        this.size = size;
        this.expression = expression;
        this.format = format;
    }

    // Constructor with all fields
    public PhotoRequest(String template, String size, String expression, String format, 
                       Integer customWidth, Integer customHeight) {
        this.template = template;
        this.size = size;
        this.expression = expression;
        this.format = format;
        this.customWidth = customWidth;
        this.customHeight = customHeight;
    }

    // Getters and Setters
    public String getTemplate() {
        return template;
    }

    public void setTemplate(String template) {
        this.template = template;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public String getExpression() {
        return expression;
    }

    public void setExpression(String expression) {
        this.expression = expression;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(String format) {
        this.format = format;
    }

    public Integer getCustomWidth() {
        return customWidth;
    }

    public void setCustomWidth(Integer customWidth) {
        this.customWidth = customWidth;
    }

    public Integer getCustomHeight() {
        return customHeight;
    }

    public void setCustomHeight(Integer customHeight) {
        this.customHeight = customHeight;
    }

    @Override
    public String toString() {
        return "PhotoRequest{" +
                "template='" + template + '\'' +
                ", size='" + size + '\'' +
                ", expression='" + expression + '\'' +
                ", format='" + format + '\'' +
                ", customWidth=" + customWidth +
                ", customHeight=" + customHeight +
                '}';
    }
}
