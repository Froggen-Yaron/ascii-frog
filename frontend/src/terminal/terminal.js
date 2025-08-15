import { Terminal } from '@xterm/xterm';
import { FitAddon } from '@xterm/addon-fit';

export class TerminalManager {
    constructor(containerElement) {
        this.container = containerElement;
        this.terminal = null;
        this.fitAddon = null;
        this.config = null;
        this.initialize();
    }

    initialize() {
        // Initialize with default config until backend config is loaded
        this.terminal = new Terminal({
            theme: {
                background: '#0d1117',
                foreground: '#e6edf3',
                cursor: '#58a6ff'
            },
            fontFamily: 'Fira Code, monospace',
            fontSize: 14,
            rows: 24,
            cols: 80,
            cursorBlink: true,
            scrollback: 0,
            disableStdin: true
        });

        this.fitAddon = new FitAddon();
        this.terminal.loadAddon(this.fitAddon);

        this.terminal.open(this.container);
        this.fitAddon.fit();

        this.showWelcome();
    }

    updateConfig(config) {
        this.config = config;
        // Store config for future use, but don't update readonly options
        // Terminal theme can be updated, but settings like rows/cols are readonly
        if (this.terminal && config.theme) {
            this.terminal.options.theme = config.theme;
        }
    }

    // =====================================
    // 🎯 TERMINAL HEADER SECTION
    // =====================================
    // Shows at the top of every terminal screen:
    // 
    // 🐸  Welcome to ascii-frog Terminal!    ← Welcome message with frog emoji
    // 
    // frog@terminal:~$                       ← Command prompt line  
    // 
    showWelcome() {
        const welcome = this.config?.messages?.welcome || '🐸  Welcome to ascii-frog Terminal!';
        const prompt = this.config?.messages?.prompt || 'frog@terminal:~$ ';

        this.terminal.writeln(welcome);  // Header with frog emoji
        this.terminal.writeln('');       // Spacing line
        this.terminal.writeln(prompt);   // Command prompt
        this.terminal.writeln('');       // Spacing line
    }

    // =====================================
    // 🎨 ASCII ART COMPONENT
    // =====================================
    // Displays just the ASCII frog art:
    //
    //                 .-""""""-.              ← ASCII ART LINES
    //                /          \             ← (each line centered)
    //               |  o      o  |            ← 
    //               |     __     |            ← 
    //                \   \__/   /             ← 
    //                 '-.......-'             ← 
    //
    displayAscii(ascii) {
        // 🎨 ASCII ART: Display frog art centered
        const asciiLines = ascii.split('\n');
        asciiLines.forEach(line => {
            const cleanLine = line.replace(/\x1b\[[0-9;]*m/g, '');  // Remove color codes
            const centeredLine = this.centerText(cleanLine);        // Center the line
            this.terminal.writeln(centeredLine);                    // Display it
        });
    }

    // =====================================
    // 🏷️ FROG NAME COMPONENT
    // =====================================
    // Displays just the frog species name:
    //
    //             Red-eyed Tree Frog          ← SPECIES NAME (centered)
    //
    displayFrogName(templateName) {
        // 🏷️ FROG NAME: Show species name centered
        const centeredTitle = this.centerText(templateName);
        this.terminal.writeln(centeredTitle);
    }

    // =====================================
    // 🐸 COMPLETE FROG DISPLAY
    // =====================================
    // Combines all components for full frog display:
    //
    // 🐸  Welcome to ascii-frog Terminal!    ← HEADER SECTION
    // 
    // frog@terminal:~$                       ← PROMPT SECTION
    // 
    //                 .-""""""-.              ← ASCII ART COMPONENT
    //                /          \             ← 
    //               |  o      o  |            ← 
    //               |     __     |            ← 
    //                \   \__/   /             ← 
    //                 '-.......-'             ← 
    // 
    //             Red-eyed Tree Frog          ← FROG NAME COMPONENT
    //
    displayCompleteFrog(ascii, templateName) {
        this.terminal.clear();
        this.terminal.reset();

        // 🎯 HEADER: Always show welcome + prompt at top
        this.showWelcome();

        // 🎨 ASCII ART: Display the frog art
        this.displayAscii(ascii);

        // 📝 SPACING: Add blank line between art and name
        this.terminal.writeln('');

        // 🏷️ FROG NAME: Display the species name
        this.displayFrogName(templateName);
    }



    // Makes ASCII art and frog names appear centered in terminal
    centerText(text) {
        const terminalWidth = this.terminal.cols || 80;
        const textLength = text.replace(/\x1b\[[0-9;]*m/g, '').length;
        const padding = Math.max(0, Math.floor((terminalWidth - textLength) / 2));
        return ' '.repeat(padding) + text;
    }

}
