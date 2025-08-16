package com.froggen.photofrog.util;

import org.springframework.stereotype.Component;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import javax.imageio.ImageIO;

/**
 * Utility class for image processing operations.
 */
@Component
public class ImageUtils {

    /**
     * Resize an image to the specified dimensions.
     */
    public BufferedImage resizeImage(BufferedImage originalImage, int targetWidth, int targetHeight) {
        // For now, return the original image
        // In a real implementation, this would use OpenCV or Java2D to resize
        return originalImage;
    }

    /**
     * Apply expression filter to an image.
     */
    public BufferedImage applyExpressionFilter(BufferedImage image, String expression) {
        // For now, return the original image
        // In a real implementation, this would apply filters based on expression
        return image;
    }

    /**
     * Convert BufferedImage to byte array.
     */
    public byte[] imageToBytes(BufferedImage image, String format) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, format, baos);
        return baos.toByteArray();
    }

    /**
     * Get dimensions for a given size.
     */
    public int[] getDimensionsForSize(String size) {
        return switch (size.toLowerCase()) {
            case "small" -> new int[]{300, 200};
            case "medium" -> new int[]{600, 400};
            case "large" -> new int[]{900, 600};
            default -> new int[]{600, 400}; // default to medium
        };
    }

    /**
     * Validate image format.
     */
    public boolean isValidFormat(String format) {
        return "jpeg".equalsIgnoreCase(format) || 
               "jpg".equalsIgnoreCase(format) || 
               "png".equalsIgnoreCase(format);
    }

    /**
     * Get supported image formats.
     */
    public String[] getSupportedFormats() {
        return new String[]{"jpeg", "jpg", "png"};
    }

    /**
     * Convert format to MIME type.
     */
    public String getMimeType(String format) {
        return switch (format.toLowerCase()) {
            case "jpeg", "jpg" -> "image/jpeg";
            case "png" -> "image/png";
            default -> "image/jpeg";
        };
    }
}
