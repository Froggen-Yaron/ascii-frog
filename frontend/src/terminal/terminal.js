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
            white-space: pre;
            line-height: 1.4;
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

    displayAscii(ascii) {
        const asciiLines = ascii.split('\n');
        asciiLines.forEach(line => {
            const centeredLine = this.centerText(line);
            this.writeln(centeredLine);
        });
    }

    displayFrogName(frogName) {
        // Demo one-liner: wrap frog name with random color
        return randomColor(frogName);
    }

    displayCompleteFrog(ascii, frogName) {
        this.clear();
        this.showWelcome();
        this.displayAscii(ascii);
        this.writeln('');
        this.writeln(this.centerText(this.displayFrogName(frogName)));
    }

    centerText(text) {
        const terminalWidth = 80;
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

    clear() {
        this.container.innerHTML = '';
    }

    reset() {
        // No-op for HTML version
    }
}