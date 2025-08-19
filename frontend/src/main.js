// Import CSS
import './styles.css';
import { TerminalManager } from './terminal.js';



export class AsciiFrogGenerator {
    constructor() {
        this.initializeElements();
        this.initializeTerminal();
        this.bindEvents();
        this.loadInitialData();
        this.currentAscii = '';
    }

    initializeElements() {
        this.frogSelect = document.getElementById('template-select'); // Keep same ID for compatibility
        this.randomBtn = document.getElementById('random-btn');
        this.copyBtn = document.getElementById('copy-btn');
        this.terminalContainer = document.getElementById('terminal');
    }

    initializeTerminal() {
        this.terminalManager = new TerminalManager(this.terminalContainer);
    }

    bindEvents() {
        this.randomBtn.addEventListener('click', () => this.generateRandomFrog());
        this.copyBtn.addEventListener('click', () => this.copyToClipboard());

        // Auto-generate on frog selection change
        this.frogSelect.addEventListener('change', () => this.generateFrog());
    }

    async loadInitialData() {
        try {
            // Load AI frogs and terminal config from API
            const [frogsResponse, configResponse] = await Promise.all([
                fetch('/api/frogs'),
                fetch('/api/terminal-config')
            ]);

            if (frogsResponse.ok) {
                const frogsData = await frogsResponse.json();
                this.populateFrogSelect(frogsData.frogs);
            }

            if (configResponse.ok) {
                const configData = await configResponse.json();
                this.terminalConfig = configData.config;
                // Update terminal with backend config
                this.terminalManager.updateConfig(this.terminalConfig);
            }
        } catch (error) {
            console.error('Error loading initial data:', error);
        }
    }

    populateFrogSelect(frogs) {
        this.frogSelect.innerHTML = '';
        frogs.forEach(frog => {
            const option = document.createElement('option');
            option.value = frog.id;
            option.textContent = frog.name;
            if (frog.id === 'classic') {
                option.selected = true;
            }
            this.frogSelect.appendChild(option);
        });
    }

    async generateFrog() {
        const selectedFrog = this.frogSelect.value;

        try {
            const response = await fetch('/api/generate-frog', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    frog: selectedFrog
                })
            });

            const data = await response.json();

            if (data.success) {
                this.displayAscii(data.ascii, data.frogName);
                this.copyBtn.disabled = false;
                console.log(`🤖 AI Generated ${data.frogName} frog!`);
            } else {
                throw new Error(data.error || 'Failed to generate frog');
            }
        } catch (error) {
            console.error('Error generating AI frog:', error);
        }
    }

    async generateRandomFrog() {
        try {
            const response = await fetch('/api/random-frog');
            const data = await response.json();

            if (data.success) {
                this.displayAscii(data.ascii, data.frogName);
                this.copyBtn.disabled = false;
                console.log(`🎲 AI Generated random frog: ${data.frogName}!`);
            } else {
                throw new Error(data.error || 'Failed to generate random frog');
            }
        } catch (error) {
            console.error('Error generating random AI frog:', error);
        }
    }

    displayAscii(ascii, frogName) {
        this.currentAscii = ascii;
        this.currentFrogName = frogName;

        // Use terminal manager to display complete AI-generated frog
        this.terminalManager.displayCompleteFrog(ascii, frogName);
    }













    async copyToClipboard() {
        if (!this.currentAscii) {
            console.warn('No ASCII art to copy!');
            return;
        }

        try {
            // Use backend API to format clipboard text
            const response = await fetch('/api/format-clipboard', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    ascii: this.currentAscii,
                    frogName: this.currentFrogName
                })
            });

            const data = await response.json();

            if (data.success) {
                await navigator.clipboard.writeText(data.formattedText);
                console.log('📋 AI-generated ASCII frog copied to clipboard!');
            } else {
                throw new Error(data.error || 'Failed to format clipboard text');
            }
        } catch (error) {
            console.error('Error copying to clipboard:', error);
        }
    }



    showToast(message, type = 'success') {
        this.toastMessage.textContent = message;

        // Remove any existing type classes
        this.toast.classList.remove('success', 'error');

        // Add the appropriate type class
        this.toast.classList.add(type);
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

// Export for ES6 modules
export default AsciiFrogGenerator;



