class AsciiFrogGenerator {
    constructor() {
        this.initializeElements();
        this.bindEvents();
        this.loadInitialData();
        this.currentAscii = '';
    }

    initializeElements() {
        this.templateSelect = document.getElementById('template-select');
        this.generateBtn = document.getElementById('generate-btn');
        this.randomBtn = document.getElementById('random-btn');
        this.copyBtn = document.getElementById('copy-btn');
        this.asciiOutput = document.getElementById('ascii-output');
        this.toast = document.getElementById('toast');
        this.toastMessage = document.getElementById('toast-message');
    }

    bindEvents() {
        this.generateBtn.addEventListener('click', () => this.generateFrog());
        this.randomBtn.addEventListener('click', () => this.generateRandomFrog());
        this.copyBtn.addEventListener('click', () => this.copyToClipboard());

        // Auto-generate on selection change
        this.templateSelect.addEventListener('change', () => this.generateFrog());
    }

    async loadInitialData() {
        try {
            // Load templates from API
            const templatesResponse = await fetch('/api/templates');

            if (templatesResponse.ok) {
                const templatesData = await templatesResponse.json();
                this.populateTemplateSelect(templatesData.templates);
            }
        } catch (error) {
            console.error('Error loading initial data:', error);
            this.showToast('Failed to load templates', 'error');
        }
    }

    populateTemplateSelect(templates) {
        this.templateSelect.innerHTML = '';
        templates.forEach(template => {
            const option = document.createElement('option');
            option.value = template.id;
            option.textContent = template.name;
            if (template.id === 'classic') {
                option.selected = true;
            }
            this.templateSelect.appendChild(option);
        });
    }

    async generateFrog() {
        const template = this.templateSelect.value;

        this.setLoading(true);

        try {
            const response = await fetch('/api/generate-frog', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    template
                })
            });

            const data = await response.json();

            if (data.success) {
                this.displayAscii(data.ascii, data.template);
                this.copyBtn.disabled = false;
                this.showToast(`🐸 Generated ${data.template} frog!`);
            } else {
                throw new Error(data.error || 'Failed to generate frog');
            }
        } catch (error) {
            console.error('Error generating frog:', error);
            this.showToast('Failed to generate frog. Please try again.', 'error');
            this.displayError(error.message);
        } finally {
            this.setLoading(false);
        }
    }

    async generateRandomFrog() {
        this.setLoading(true);

        try {
            const response = await fetch('/api/random-frog');
            const data = await response.json();

            if (data.success) {
                // Update the template select to match the random generation
                this.templateSelect.value = data.template;

                this.displayAscii(data.ascii, data.template);
                this.copyBtn.disabled = false;
                this.showToast(`🎲 Random frog: ${data.templateName}!`);
            } else {
                throw new Error(data.error || 'Failed to generate random frog');
            }
        } catch (error) {
            console.error('Error generating random frog:', error);
            this.showToast('Failed to generate random frog. Please try again.', 'error');
            this.displayError(error.message);
        } finally {
            this.setLoading(false);
        }
    }

    displayAscii(ascii, template) {
        this.currentAscii = ascii;

        // Strip ANSI codes and keep ASCII art plain
        const cleanAscii = ascii.replace(/\x1b\[[0-9;]*m/g, '');

        // Get template info
        const templateData = this.getTemplateData(template);
        const templateName = templateData ? templateData.name : template;

        // Create the ASCII content container (plain, no colors)
        const asciiContainer = document.createElement('div');
        asciiContainer.className = 'ascii-content';
        asciiContainer.style.color = '#e6edf3';
        asciiContainer.style.lineHeight = '1.1';
        asciiContainer.style.textAlign = 'center';
        asciiContainer.style.whiteSpace = 'pre';
        asciiContainer.textContent = cleanAscii;

        // Create plain frog name at bottom
        const nameContainer = document.createElement('div');
        nameContainer.className = 'frog-name-bottom';
        nameContainer.style.fontSize = '16px';
        nameContainer.style.fontWeight = 'bold';
        nameContainer.style.color = '#e6edf3';
        nameContainer.textContent = `🐸 ${templateName}`;

        // Clear and append
        this.asciiOutput.innerHTML = '';
        this.asciiOutput.appendChild(asciiContainer);
        this.asciiOutput.appendChild(nameContainer);
    }



    getTemplateData(templateId) {
        // This would ideally come from the API, but for now we'll use a local mapping
        const templateNames = {
            'tiny': { name: 'Tiny Frog' },
            'classic': { name: 'Classic Frog' },
            'happy': { name: 'Happy Frog' },
            'sitting': { name: 'Sitting Frog' },
            'large': { name: 'Large Frog' },
            'simple': { name: 'Simple Frog' }
        };
        return templateNames[templateId];
    }



    displayError(message) {
        this.asciiOutput.innerHTML = `
            <div style="color: #f85149; text-align: center; padding: 40px 20px;">
                ❌ Error: ${message}
                <br><br>
                Please try again or contact support if the problem persists.
            </div>
        `;
    }

    async copyToClipboard() {
        if (!this.currentAscii) {
            this.showToast('No ASCII art to copy!', 'error');
            return;
        }

        try {
            // Remove ANSI color codes for plain text copy
            const plainAscii = this.currentAscii.replace(/\x1b\[[0-9;]*m/g, '');

            // Get the current frog name
            const template = this.templateSelect.value;
            const templateData = this.getTemplateData(template);
            const templateName = templateData ? templateData.name : template;

            // Combine ASCII art with frog name
            const fullText = `${plainAscii}\n\n🐸 ${templateName}`;

            await navigator.clipboard.writeText(fullText);
            this.showToast('📋 ASCII frog copied to clipboard!');
        } catch (error) {
            console.error('Error copying to clipboard:', error);

            // Fallback for older browsers
            const plainAscii = this.currentAscii.replace(/\x1b\[[0-9;]*m/g, '');
            const template = this.templateSelect.value;
            const templateData = this.getTemplateData(template);
            const templateName = templateData ? templateData.name : template;
            const fullText = `${plainAscii}\n\n🐸 ${templateName}`;

            const textArea = document.createElement('textarea');
            textArea.value = fullText;
            document.body.appendChild(textArea);
            textArea.select();

            try {
                document.execCommand('copy');
                this.showToast('📋 ASCII frog copied to clipboard!');
            } catch (fallbackError) {
                this.showToast('Failed to copy to clipboard', 'error');
            }

            document.body.removeChild(textArea);
        }
    }

    setLoading(loading) {
        if (loading) {
            this.generateBtn.innerHTML = '<span class="loading">Generating... 🐸</span>';
            this.randomBtn.innerHTML = '<span class="loading">Generating... 🎲</span>';
            this.generateBtn.disabled = true;
            this.randomBtn.disabled = true;
        } else {
            this.generateBtn.innerHTML = 'Generate Frog 🐸';
            this.randomBtn.innerHTML = 'Random Frog 🎲';
            this.generateBtn.disabled = false;
            this.randomBtn.disabled = false;
        }
    }

    showToast(message, type = 'success') {
        this.toastMessage.textContent = message;

        // Update toast color based on type
        if (type === 'error') {
            this.toast.style.background = '#ef4444';
        } else {
            this.toast.style.background = '#10b981';
        }

        this.toast.classList.add('show');

        setTimeout(() => {
            this.toast.classList.remove('show');
        }, 3000);
    }
}

// Initialize the app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new AsciiFrogGenerator();
});

// Add some fun console messages
console.log(`
🐸 ASCII Frog Generator
Built with Node.js, Express, and love for ASCII art!

Try these in the console:
- Open the Network tab to see API calls
- Check out the beautiful terminal styling
- View the source code for implementation details
`);

// Easter egg - Konami code for special frog
let konamiCode = [];
const konami = [
    'ArrowUp', 'ArrowUp', 'ArrowDown', 'ArrowDown',
    'ArrowLeft', 'ArrowRight', 'ArrowLeft', 'ArrowRight',
    'KeyB', 'KeyA'
];

document.addEventListener('keydown', (e) => {
    konamiCode.push(e.code);
    konamiCode = konamiCode.slice(-10);

    if (JSON.stringify(konamiCode) === JSON.stringify(konami)) {
        const specialFrog = `
        🎉 SPECIAL KONAMI FROG! 🎉
        
            ★ ★   ★ ★
           (◉ ◉) (◉ ◉)
          _)     (_   
         (  ★★★★★★★  )
        (  /  ★★★★★  \\  )
         ) | ◉   ◉ | (
        (  \\   ★   /  )
         )  \\  ^  /  (
        (    \\___/    )
         ★★★★★★★★★★★★★ 
        
        🎊 You found the secret frog! 🎊
        `;

        document.getElementById('ascii-output').innerHTML = `
            <div style="color: #d946ef; text-align: center; animation: pulse 1s infinite;">
                ${specialFrog}
            </div>
        `;
    }
});
