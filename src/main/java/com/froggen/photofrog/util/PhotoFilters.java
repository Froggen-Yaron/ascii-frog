package com.froggen.photofrog.util;

import org.springframework.stereotype.Component;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.awt.image.ConvolveOp;
import java.awt.image.Kernel;

/**
 * Utility class for applying photo filters and effects to frog images.
 */
@Component
public class PhotoFilters {

    /**
     * Apply brightness adjustment to an image.
     */
    public BufferedImage adjustBrightness(BufferedImage image, float factor) {
        BufferedImage result = new BufferedImage(image.getWidth(), image.getHeight(), image.getType());
        
        for (int x = 0; x < image.getWidth(); x++) {
            for (int y = 0; y < image.getHeight(); y++) {
                Color color = new Color(image.getRGB(x, y));
                
                int red = Math.min(255, Math.max(0, (int) (color.getRed() * factor)));
                int green = Math.min(255, Math.max(0, (int) (color.getGreen() * factor)));
                int blue = Math.min(255, Math.max(0, (int) (color.getBlue() * factor)));
                
                result.setRGB(x, y, new Color(red, green, blue).getRGB());
            }
        }
        
        return result;
    }

    /**
     * Apply contrast adjustment to an image.
     */
    public BufferedImage adjustContrast(BufferedImage image, float factor) {
        BufferedImage result = new BufferedImage(image.getWidth(), image.getHeight(), image.getType());
        
        for (int x = 0; x < image.getWidth(); x++) {
            for (int y = 0; y < image.getHeight(); y++) {
                Color color = new Color(image.getRGB(x, y));
                
                int red = Math.min(255, Math.max(0, (int) (((color.getRed() - 128) * factor) + 128)));
                int green = Math.min(255, Math.max(0, (int) (((color.getGreen() - 128) * factor) + 128)));
                int blue = Math.min(255, Math.max(0, (int) (((color.getBlue() - 128) * factor) + 128)));
                
                result.setRGB(x, y, new Color(red, green, blue).getRGB());
            }
        }
        
        return result;
    }

    /**
     * Apply blur effect to an image.
     */
    public BufferedImage applyBlur(BufferedImage image, int radius) {
        float[] matrix = new float[radius * radius];
        for (int i = 0; i < matrix.length; i++) {
            matrix[i] = 1.0f / matrix.length;
        }
        
        Kernel kernel = new Kernel(radius, radius, matrix);
        ConvolveOp convolveOp = new ConvolveOp(kernel, ConvolveOp.EDGE_NO_OP, null);
        
        return convolveOp.filter(image, null);
    }

    /**
     * Apply expression-based filter to simulate different frog expressions.
     */
    public BufferedImage applyExpressionFilter(BufferedImage image, String expression) {
        return switch (expression.toLowerCase()) {
            case "happy" -> applyHappyFilter(image);
            case "sad" -> applySadFilter(image);
            case "surprised" -> applySurprisedFilter(image);
            case "excited" -> applyExcitedFilter(image);
            case "determined" -> applyDeterminedFilter(image);
            default -> image;
        };
    }

    /**
     * Optimized filter application with caching.
     */
    private final java.util.Map<String, BufferedImage> filterCache = new java.util.concurrent.ConcurrentHashMap<>();

    public BufferedImage applyExpressionFilterOptimized(BufferedImage image, String expression) {
        String cacheKey = expression + "_" + image.getWidth() + "x" + image.getHeight();
        
        return filterCache.computeIfAbsent(cacheKey, k -> applyExpressionFilter(image, expression));
    }

    /**
     * Apply happy expression filter (brighter, warmer colors).
     */
    private BufferedImage applyHappyFilter(BufferedImage image) {
        BufferedImage result = adjustBrightness(image, 1.1f);
        result = adjustSaturation(result, 1.2f);
        result = adjustWarmth(result, 1.1f);
        return result;
    }

    /**
     * Apply sad expression filter (darker, cooler colors).
     */
    private BufferedImage applySadFilter(BufferedImage image) {
        BufferedImage result = adjustBrightness(image, 0.9f);
        result = adjustSaturation(result, 0.8f);
        result = adjustWarmth(result, 0.9f);
        return result;
    }

    /**
     * Apply surprised expression filter (high contrast, bright).
     */
    private BufferedImage applySurprisedFilter(BufferedImage image) {
        BufferedImage result = adjustBrightness(image, 1.2f);
        result = adjustContrast(result, 1.3f);
        result = adjustSaturation(result, 1.1f);
        return result;
    }

    /**
     * Apply excited expression filter (vibrant, high saturation).
     */
    private BufferedImage applyExcitedFilter(BufferedImage image) {
        BufferedImage result = adjustBrightness(image, 1.15f);
        result = adjustSaturation(result, 1.4f);
        result = adjustContrast(result, 1.2f);
        return result;
    }

    /**
     * Apply determined expression filter (sharp, focused).
     */
    private BufferedImage applyDeterminedFilter(BufferedImage image) {
        BufferedImage result = adjustContrast(image, 1.25f);
        result = adjustSharpness(result, 1.1f);
        return result;
    }

    /**
     * Adjust saturation of an image.
     */
    private BufferedImage adjustSaturation(BufferedImage image, float factor) {
        BufferedImage result = new BufferedImage(image.getWidth(), image.getHeight(), image.getType());
        
        for (int x = 0; x < image.getWidth(); x++) {
            for (int y = 0; y < image.getHeight(); y++) {
                Color color = new Color(image.getRGB(x, y));
                float[] hsb = Color.RGBtoHSB(color.getRed(), color.getGreen(), color.getBlue(), null);
                
                hsb[1] = Math.min(1.0f, hsb[1] * factor);
                
                int rgb = Color.HSBtoRGB(hsb[0], hsb[1], hsb[2]);
                result.setRGB(x, y, rgb);
            }
        }
        
        return result;
    }

    /**
     * Adjust warmth (red/yellow tint) of an image.
     */
    private BufferedImage adjustWarmth(BufferedImage image, float factor) {
        BufferedImage result = new BufferedImage(image.getWidth(), image.getHeight(), image.getType());
        
        for (int x = 0; x < image.getWidth(); x++) {
            for (int y = 0; y < image.getHeight(); y++) {
                Color color = new Color(image.getRGB(x, y));
                
                int red = Math.min(255, (int) (color.getRed() * factor));
                int green = color.getGreen();
                int blue = (int) (color.getBlue() / factor);
                
                result.setRGB(x, y, new Color(red, green, blue).getRGB());
            }
        }
        
        return result;
    }

    /**
     * Adjust sharpness of an image.
     */
    private BufferedImage adjustSharpness(BufferedImage image, float factor) {
        float[] matrix = {
            0, -factor, 0,
            -factor, 1 + 4 * factor, -factor,
            0, -factor, 0
        };
        
        Kernel kernel = new Kernel(3, 3, matrix);
        ConvolveOp convolveOp = new ConvolveOp(kernel, ConvolveOp.EDGE_NO_OP, null);
        
        return convolveOp.filter(image, null);
    }
}
