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
        this.displayFrogAsUnit(ascii, frogName);
    }

    displayAscii(ascii) {
        const asciiLines = ascii.split('\n').filter(line => line.trim() !== '');
        asciiLines.forEach(line => {
            this.writeCenter(line);
        });
    }

    displayAsciiWithFixedHeight(ascii) {
        const asciiLines = ascii.split('\n').filter(line => line.trim() !== '');
        const minHeight = 12; // Fixed height for ASCII area (lines)

        // Display the ASCII art
        asciiLines.forEach(line => {
            this.writeCenter(line);
        });

        // Add padding to reach minimum height
        const linesUsed = asciiLines.length;
        const paddingNeeded = Math.max(0, minHeight - linesUsed);

        for (let i = 0; i < paddingNeeded; i++) {
            this.writeln('');
        }

        // Add a separator line before frog name
        this.writeln('');
    }

    displayFrogName(frogName) {
        this.writeCenter(frogName);
        // To add Random Color To the FROG NAME CHANGE HERE:
        //this.writeCenter(randomColor(frogName));
    }

    displayFrogAsUnit(ascii, frogName) {
        const asciiLines = ascii.split('\n').filter(line => line.trim() !== '');

        // Find the widest ASCII line
        let maxAsciiWidth = 0;
        asciiLines.forEach(line => {
            maxAsciiWidth = Math.max(maxAsciiWidth, line.length);
        });

        const nameWidth = frogName.length;
        const totalWidth = Math.max(maxAsciiWidth, nameWidth);

        // Center ASCII lines within the total width
        asciiLines.forEach(line => {
            const padding = Math.floor((totalWidth - line.length) / 2);
            const centeredLine = ' '.repeat(padding) + line + ' '.repeat(totalWidth - line.length - padding);
            this.writeCenter(centeredLine);
        });

        // Add spacing between frog and name
        this.writeln('');

        // Center name within the same total width
        const namePadding = Math.floor((totalWidth - nameWidth) / 2);
        const centeredName = ' '.repeat(namePadding) + frogName + ' '.repeat(totalWidth - nameWidth - namePadding);
        this.writeCenter(randomColor(centeredName));
        //this.writeCenter(centeredName);
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