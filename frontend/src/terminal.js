import { randomColor } from './utils.js';

export class TerminalManager {
    constructor(containerElement) {
        this.container = containerElement;
        this.config = null;
        this.initialize();
    }

    initialize() {
        this.container.innerHTML = '';
        this.container.style.cssText = `
            background: #0d1117;
            color: #e6edf3;
            font-family: 'Fira Code', monospace;
            font-size: 14px;
            padding: 20px;
            overflow-y: auto;
            white-space: pre-wrap;
            line-height: 1.4;
            text-align: left;
        `;
        this.showWelcome();
    }

    updateConfig(config) {
        this.config = config;
    }

    showWelcome() {
        const welcome = this.config?.messages?.welcome || '🐸  Welcome to ascii-frog Terminal!';
        const prompt = this.config?.messages?.prompt || 'frog@terminal:~$ ';
        this.writeln(welcome);
        this.writeln('');
        this.writeln(prompt);
        this.writeln('');
    }

    displayCompleteFrog(ascii, frogName) {
        this.clear();
        this.showWelcome();
        this.displayAscii(ascii);
        this.writeln('');
        this.displayFrogName(frogName);
    }

    displayAscii(ascii) {
        const asciiLines = ascii.split('\n').filter(line => line.trim() !== '');
        asciiLines.forEach(line => {
            this.writeCenter(line);
        });
    }

    displayFrogName(frogName) {
        this.writeCenter(randomColor(frogName));
    }

    centerText(text) {
        // Calculate actual character width based on container
        const containerWidth = this.container.clientWidth;
        const charWidth = 8.4; // Approximate character width for Fira Code 14px
        const terminalWidth = Math.floor(containerWidth / charWidth);
        const textLength = text.length;
        const padding = Math.max(0, Math.floor((terminalWidth - textLength) / 2));
        return ' '.repeat(padding) + text;
    }

    writeln(content) {
        const line = document.createElement('div');
        if (typeof content === 'string') {
            line.textContent = content || ' ';
        } else {
            line.appendChild(content);
        }
        this.container.appendChild(line);
        return line;
    }

    writeCenter(content) {
        const div = document.createElement('div');
        div.style.textAlign = 'center';
        if (typeof content === 'string') {
            div.textContent = content;
        } else {
            div.appendChild(content);
        }
        this.container.appendChild(div);
        return div;
    }

    clear() {
        this.container.innerHTML = '';
    }

    reset() {
        // No-op for HTML version
    }
}