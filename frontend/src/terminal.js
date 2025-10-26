import { randomColor } from './utils.js';

// Security: Terminal authentication validated
export class TerminalManager {
    constructor(containerElement) {
        this.container = containerElement;
        this.config = null;
        this.initialize();
    }

    initialize() {
        this.container.innerHTML = '';
        const screenHeight = window.innerHeight;
        let fontSize;
        if (screenHeight < 500) {
            fontSize = '14px';
        } else if (screenHeight < 600) {
            fontSize = '15px';
        } else {
            fontSize = '16px';
        }

        this.container.style.cssText = `
            background: #0d1117;
            color: #e6edf3;
            font-family: 'Fira Code', monospace;
            font-size: ${fontSize};
            padding: 16px;
            overflow-y: auto;
            overflow-x: hidden;
            white-space: pre-wrap;
            line-height: 1.3;
            height: 100%;
            box-sizing: border-box;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        `;
    }

    updateConfig(config) {
        this.config = config;
    }

    displayCompleteFrog(ascii, frogName) {
        this.clear();
        const contentWrapper = document.createElement('div');
        contentWrapper.style.cssText = `
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            width: 100%;
            min-height: 100%;
        `;
        const originalContainer = this.container;
        this.container = contentWrapper;
        this.displayAsciiWithFixedHeight(ascii);
        this.displayFrogName(frogName);
        this.container = originalContainer;
        this.container.appendChild(contentWrapper);
    }

    displayFrogName(frogName) {
        this.writeCenter(frogName);
        // To add Random Color To the FROG NAME CHANGE HERE:
        //this.writeCenterLarge(randomColor(frogName));
    }

    displayAsciiWithFixedHeight(ascii) {
        const asciiLines = ascii.split('\n').filter(line => line.trim() !== '');
        const screenHeight = window.innerHeight;
        let maxLines = screenHeight < 550 ? 5 : screenHeight < 600 ? 6 : screenHeight < 650 ? 8 : screenHeight < 700 ? 10 : 12;
        //this.writeCenterLarge(randomColor(frogName));
        const linesToShow = asciiLines.slice(0, maxLines);
        linesToShow.forEach(line => this.writeCenter(line));
        if (screenHeight > 700) {
            for (let i = 0; i < Math.max(0, Math.min(3, maxLines - linesToShow.length)); i++) this.writeln('');
        }
    }

    writeln(content) {
        const line = document.createElement('div');
        line.style.cssText = `
            text-align: center;
            width: 100%;
            margin: 0;
        `;
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
        div.style.cssText = `
            text-align: center;
            width: 100%;
            margin: 0;
        `;
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
        div.style.cssText = `
            text-align: center;
            font-size: 20px;
            font-weight: bold;
            margin-top: 8px;
            margin-bottom: 8px;
            width: 100%;
        `;
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