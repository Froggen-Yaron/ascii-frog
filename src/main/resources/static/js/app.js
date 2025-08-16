// Photo Frog Generator - Frontend JavaScript

class PhotoFrogApp {
    constructor() {
        this.apiBaseUrl = '/api';
        this.currentImage = null;
        this.init();
    }

    init() {
        this.bindEvents();
        this.loadTemplates();
    }

    bindEvents() {
        // Generate button
        document.getElementById('generateBtn').addEventListener('click', () => {
            this.generateFrog();
        });

        // Random button
        document.getElementById('randomBtn').addEventListener('click', () => {
            this.generateRandomFrog();
        });

        // Download button
        document.getElementById('downloadBtn').addEventListener('click', () => {
            this.downloadImage();
        });

        // Real-time preview on control changes
        const controls = ['template', 'size', 'expression'];
        controls.forEach(controlId => {
            document.getElementById(controlId).addEventListener('change', () => {
                this.updatePreview();
            });
        });
    }

    async loadTemplates() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/templates`);
            if (response.ok) {
                const templates = await response.json();
                this.populateTemplateSelect(templates);
            }
        } catch (error) {
            console.error('Error loading templates:', error);
            this.showMessage('Error loading templates', 'error');
        }
    }

    populateTemplateSelect(templates) {
        const select = document.getElementById('template');
        select.innerHTML = '';
        
        templates.forEach(template => {
            const option = document.createElement('option');
            option.value = template.id;
            option.textContent = template.name;
            select.appendChild(option);
        });
    }

    async generateFrog() {
        const config = this.getConfiguration();
        
        try {
            this.showLoading(true);
            
            const response = await fetch(`${this.apiBaseUrl}/generate-photo`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(config)
            });

            if (response.ok) {
                const result = await response.json();
                this.displayImage(result.imageUrl);
                this.showMessage('Frog generated successfully!', 'success');
            } else {
                throw new Error('Failed to generate frog');
            }
        } catch (error) {
            console.error('Error generating frog:', error);
            this.showMessage('Error generating frog. Please try again.', 'error');
        } finally {
            this.showLoading(false);
        }
    }

    async generateRandomFrog() {
        // Randomize all controls
        const controls = ['template', 'size', 'expression'];
        controls.forEach(controlId => {
            const select = document.getElementById(controlId);
            const randomIndex = Math.floor(Math.random() * select.options.length);
            select.selectedIndex = randomIndex;
        });

        // Generate with random config
        await this.generateFrog();
    }

    getConfiguration() {
        return {
            template: document.getElementById('template').value,
            size: document.getElementById('size').value,
            expression: document.getElementById('expression').value,
            format: document.getElementById('format').value
        };
    }

    displayImage(imageUrl) {
        const preview = document.getElementById('preview');
        const downloadSection = document.getElementById('downloadSection');
        
        // Clear previous content
        preview.innerHTML = '';
        
        // Create and display image
        const img = document.createElement('img');
        img.src = imageUrl;
        img.alt = 'Generated Frog Photo';
        img.onload = () => {
            this.currentImage = imageUrl;
            downloadSection.style.display = 'block';
        };
        
        preview.appendChild(img);
    }

    updatePreview() {
        // This would ideally show a preview without generating the full image
        // For now, we'll just update the UI to reflect the current settings
        const config = this.getConfiguration();
        console.log('Preview updated with config:', config);
    }

    downloadImage() {
        if (!this.currentImage) {
            this.showMessage('No image to download', 'error');
            return;
        }

        const link = document.createElement('a');
        link.href = this.currentImage;
        link.download = `frog-${Date.now()}.${document.getElementById('format').value}`;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        this.showMessage('Download started!', 'success');
    }

    showLoading(show) {
        const generateBtn = document.getElementById('generateBtn');
        const randomBtn = document.getElementById('randomBtn');
        
        if (show) {
            generateBtn.innerHTML = '<span class="loading"></span> Generating...';
            generateBtn.disabled = true;
            randomBtn.disabled = true;
        } else {
            generateBtn.innerHTML = 'Generate Frog Photo';
            generateBtn.disabled = false;
            randomBtn.disabled = false;
        }
    }

    showMessage(message, type) {
        // Remove existing messages
        const existingMessages = document.querySelectorAll('.message');
        existingMessages.forEach(msg => msg.remove());

        // Create new message
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${type}`;
        messageDiv.textContent = message;

        // Insert at the top of the container
        const container = document.querySelector('.container');
        container.insertBefore(messageDiv, container.firstChild);

        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (messageDiv.parentNode) {
                messageDiv.remove();
            }
        }, 5000);
    }
}

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new PhotoFrogApp();
});

// Utility functions
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = PhotoFrogApp;
}
