class AsciiFrogGenerator {
    constructor() {
        this.initializeElements();
        this.bindEvents();
        this.loadInitialData();
        this.currentAscii = '';
    }

    initializeElements() {
        this.templateSelect = document.getElementById('template-select');
        this.colorSelect = document.getElementById('color-select');
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
        this.colorSelect.addEventListener('change', () => this.generateFrog());
    }

    async loadInitialData() {
        try {
            // Load templates and color schemes from API
            const [templatesResponse, colorsResponse] = await Promise.all([
                fetch('/api/templates'),
                fetch('/api/color-schemes')
            ]);

            if (templatesResponse.ok && colorsResponse.ok) {
                const templatesData = await templatesResponse.json();
                const colorsData = await colorsResponse.json();

                this.populateTemplateSelect(templatesData.templates);
                this.populateColorSelect(colorsData.colorSchemes);
            }
        } catch (error) {
            console.error('Error loading initial data:', error);
            this.showToast('Failed to load templates and colors', 'error');
        }
    }

    populateTemplateSelect(templates) {
        this.templateSelect.innerHTML = '';
        templates.forEach(template => {
            const option = document.createElement('option');
            option.value = template.id;
            option.textContent = template.name;
            if (template.id === 'medium') {
                option.selected = true;
            }
            this.templateSelect.appendChild(option);
        });
    }

    populateColorSelect(colorSchemes) {
        this.colorSelect.innerHTML = '';
        colorSchemes.forEach(scheme => {
            const option = document.createElement('option');
            option.value = scheme.id;
            option.textContent = scheme.name;
            if (scheme.id === 'classic') {
                option.selected = true;
            }
            this.colorSelect.appendChild(option);
        });
    }

    async generateFrog() {
        const template = this.templateSelect.value;
        const colorScheme = this.colorSelect.value;

        this.setLoading(true);

        try {
            const response = await fetch('/api/generate-frog', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    template,
                    colorScheme
                })
            });

            const data = await response.json();

            if (data.success) {
                this.displayAscii(data.ascii, data.template, data.colorScheme);
                this.copyBtn.disabled = false;
                this.showToast(`🐸 Generated ${data.template} frog with ${data.colorScheme} colors!`);
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
                // Update the selects to match the random generation
                this.templateSelect.value = data.template;
                this.colorSelect.value = data.colorScheme;

                this.displayAscii(data.ascii, data.template, data.colorScheme);
                this.copyBtn.disabled = false;
                this.showToast(`🎲 Random frog: ${data.templateName} with ${data.colorSchemeName}!`);
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

    displayAscii(ascii, template, colorScheme) {
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

        // Create colored frog name at bottom
        const nameContainer = document.createElement('div');
        nameContainer.className = 'frog-name-bottom';
        nameContainer.style.fontSize = '16px';
        nameContainer.style.fontWeight = 'bold';

        const coloredName = this.getColoredFrogName(templateName, colorScheme);
        nameContainer.innerHTML = coloredName;

        // Clear and append
        this.asciiOutput.innerHTML = '';
        this.asciiOutput.appendChild(asciiContainer);
        this.asciiOutput.appendChild(nameContainer);
    }

    convertAnsiToHtml(text) {
        // First, strip all ANSI escape codes to get clean text
        const cleanText = text.replace(/\x1b\[[0-9;]*m/g, '');

        // Then apply our color scheme based on the selected scheme
        const colorScheme = this.colorSelect.value;
        const coloredHtml = this.applyColorScheme(cleanText, colorScheme);

        return coloredHtml;
    }

    applyColorScheme(text, scheme) {
        // Apply colors based on characters and scheme
        const colorMaps = {
            classic: { body: 'ascii-green', eyes: 'ascii-yellow', accent: 'ascii-white' },
            tropical: { body: 'ascii-cyan', eyes: 'ascii-magenta', accent: 'ascii-yellow' },
            fire: { body: 'ascii-red', eyes: 'ascii-yellow', accent: 'ascii-white' },
            nature: { body: 'ascii-green', eyes: 'ascii-blue', accent: 'ascii-yellow' },
            royal: { body: 'ascii-blue', eyes: 'ascii-yellow', accent: 'ascii-white' },
            neon: { body: 'ascii-cyan', eyes: 'ascii-green', accent: 'ascii-magenta' },
            galaxy: { body: 'ascii-magenta', eyes: 'ascii-cyan', accent: 'ascii-yellow' }
        };

        const colors = colorMaps[scheme] || colorMaps.classic;

        // Process each line separately to avoid HTML corruption
        const lines = text.split('\n');
        const coloredLines = lines.map(line => {
            // Process each character individually to build proper HTML
            let coloredLine = '';
            for (let i = 0; i < line.length; i++) {
                const char = line[i];
                let colorClass = '';

                // Determine color based on character
                if (char === '@' || char === 'o' || char === '^' || char === '●' || char === '◉') {
                    colorClass = colors.eyes;
                } else if (char === '(' || char === ')' || char === '_' || char === '/' || char === '\\' || char === '|' ||
                    char === '╭' || char === '╮' || char === '╱' || char === '╲' || char === '│' ||
                    char === '╰' || char === '┬' || char === '┴' || char === '┤' || char === '├' ||
                    char === '┐' || char === '┌' || char === '└' || char === '┘') {
                    colorClass = colors.body;
                } else if (char === '-' || char === '~' || char === '★' || char === '═' || char === '♔' ||
                    char === '♦' || char === '∞') {
                    colorClass = colors.accent;
                }

                // Apply color if needed, otherwise use plain character
                if (colorClass) {
                    coloredLine += `<span class="${colorClass}">${char}</span>`;
                } else {
                    coloredLine += char;
                }
            }
            return coloredLine;
        });

        return coloredLines.join('\n');
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

    getColoredFrogName(templateName, colorScheme) {
        const colorMaps = {
            classic: 'ascii-green',
            tropical: 'ascii-cyan',
            fire: 'ascii-red',
            nature: 'ascii-blue',
            royal: 'ascii-blue',
            neon: 'ascii-cyan',
            galaxy: 'ascii-magenta'
        };

        const colorClass = colorMaps[colorScheme] || 'ascii-green';
        return `<span class="${colorClass}">🐸 ${templateName}</span>`;
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
