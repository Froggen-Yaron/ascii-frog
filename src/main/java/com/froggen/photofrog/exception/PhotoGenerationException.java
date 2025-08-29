package com.froggen.photofrog.exception;

/**
 * Custom exception for photo generation errors.
 */
public class PhotoGenerationException extends RuntimeException {
    
    public PhotoGenerationException(String message) {
        super(message);
    }
    
    public PhotoGenerationException(String message, Throwable cause) {
        super(message, cause);
    }
    
    public PhotoGenerationException(Throwable cause) {
        super(cause);
    }
}






