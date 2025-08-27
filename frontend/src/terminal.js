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
            font-size: 16px;
            padding: 20px;
            overflow: hidden;
            white-space: pre-wrap;
            line-height: 1.4;
            text-align: left;
        `;
        // Removed showWelcome() call
    }

    updateConfig(config) {
        this.config = config;
    }

    showWelcome() {
        // Welcome message removed - no longer displaying welcome text
        // const welcome = this.config?.messages?.welcome || '🐸  Welcome to ascii-frog Terminal!';
        // const prompt = this.config?.messages?.prompt || 'frog@terminal:~$ ';
        // this.writeln(welcome);
        // this.writeln('');
        // this.writeln(prompt);
        // this.writeln('');
    }

    displayCompleteFrog(ascii, frogName) {
        this.clear();
        // Removed showWelcome() call to not show welcome message
        this.displayAsciiWithFixedHeight(ascii);
        this.displayFrogName(frogName);
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
        // this.writeCenter(frogName);
        // To add Random Color To the FROG NAME CHANGE HERE:
        this.writeCenterLarge(randomColor(frogName));
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

    writeCenterLarge(content) {
        const div = document.createElement('div');
        div.style.textAlign = 'center';
        div.style.fontSize = '20px';
        div.style.fontWeight = 'bold';
        div.style.marginTop = '8px';
        div.style.marginBottom = '8px';
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
}