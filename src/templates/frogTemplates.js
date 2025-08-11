const colors = require('colors');

// Define color schemes for frogs
const colorSchemes = {
    classic: {
        body: 'green',
        eyes: 'yellow',
        accent: 'white'
    },
    tropical: {
        body: 'cyan',
        eyes: 'magenta',
        accent: 'yellow'
    },
    fire: {
        body: 'red',
        eyes: 'yellow',
        accent: 'white'
    },
    nature: {
        body: 'green',
        eyes: 'blue',
        accent: 'yellow'
    },
    royal: {
        body: 'blue',
        eyes: 'yellow',
        accent: 'white'
    },
    neon: {
        body: 'cyan',
        eyes: 'green',
        accent: 'magenta'
    },
    galaxy: {
        body: 'magenta',
        eyes: 'cyan',
        accent: 'yellow'
    }
};

// Professional ASCII frog templates from classic ASCII artists
const templates = {
    tiny: {
        name: 'Tiny Frog',
        ascii: [
            '     00',
            '  (\\_--/)',
            '   // \\\\',
            '  ^^   ^^'
        ],
        colorMap: {
            '0': 'eyes',
            '(': 'body',
            ')': 'body',
            '\\': 'body',
            '/': 'body',
            '_': 'body',
            '-': 'accent',
            '^': 'accent'
        }
    },

    classic: {
        name: 'Classic Frog',
        ascii: [
            '        ()--()',
            '      .-(___)-.',
            '       _<   >_',
            '       \\/   \\/'
        ],
        colorMap: {
            '(': 'eyes',
            ')': 'eyes',
            '-': 'eyes',
            '.': 'body',
            '_': 'body',
            '<': 'body',
            '>': 'body',
            '\\': 'body',
            '/': 'body'
        }
    },

    happy: {
        name: 'Happy Frog',
        ascii: [
            '     (l)-(l)',
            '     /_____\\',
            '     \\_____/',
            '      /00\\',
            '  _/^(----)^\\_',
            ' ^^^^^^^^^^^^^^'
        ],
        colorMap: {
            'l': 'eyes',
            '(': 'eyes',
            ')': 'eyes',
            '/': 'body',
            '\\': 'body',
            '_': 'body',
            '0': 'eyes',
            '-': 'accent',
            '^': 'accent'
        }
    },

    sitting: {
        name: 'Sitting Frog',
        ascii: [
            '           _   _',
            '          (o)-(o)',
            '       .-(   "   )-.',
            '      /  /`\'-=-\'`\\  \\',
            '   __\\ _\\ \\___/ /_ /__',
            '     /|  /|\\ /|\\  |\\',
            '    ^^   ^^  ^^   ^^'
        ],
        colorMap: {
            '(': 'eyes',
            ')': 'eyes',
            'o': 'eyes',
            '.': 'body',
            '-': 'body',
            '/': 'body',
            '\\': 'body',
            '_': 'body',
            '|': 'body',
            '\'': 'accent',
            '=': 'accent',
            '^': 'accent'
        }
    },

    large: {
        name: 'Large Frog',
        ascii: [
            '           .--._.--.',
            '          ( O     O )',
            '          /   . .   \\',
            '         .`._______.\'.',
            '        /(           )\\',
            '      _/  \\  \\   /  /  \\_',
            '   .~   `  \\  \\ /  /  \'   ~.',
            '  {    -.   \\  V  /   .-    }',
            ' _ _`.    \\  |  |  |  /    .\' _ _',
            ' >_       _} |  |  | {_       _<',
            '  /. - ~ ,_-\'  .^.  `-_, ~ - .\\',
            '          \'-\'|/   \\|`-`'
        ],
        colorMap: {
            '.': 'body',
            '-': 'body',
            '(': 'body',
            ')': 'body',
            'O': 'eyes',
            '/': 'body',
            '\\': 'body',
            '_': 'body',
            '|': 'body',
            '~': 'accent',
            '^': 'accent',
            'V': 'accent',
            '`': 'body',
            '\'': 'body',
            '{': 'body',
            '}': 'body',
            '<': 'body',
            '>': 'body'
        }
    },

    simple: {
        name: 'Simple Frog',
        ascii: [
            '        00         ',
            '      (\\__/)       ',
            ' __(  I I   I I  )__'
        ],
        colorMap: {
            '0': 'eyes',
            '(': 'body',
            ')': 'body',
            '\\': 'body',
            '/': 'body',
            '_': 'body',
            'I': 'body'
        }
    }
};

/**
 * Generate a colored ASCII frog
 * @param {string} templateName - Name of the template to use
 * @param {string} colorScheme - Color scheme to apply
 * @returns {string} Colored ASCII art string
 */
function generateColoredFrog(templateName = 'medium', colorScheme = 'classic') {
    const template = templates[templateName];
    const scheme = colorSchemes[colorScheme];

    if (!template) {
        throw new Error(`Template "${templateName}" not found`);
    }

    if (!scheme) {
        throw new Error(`Color scheme "${colorScheme}" not found`);
    }

    let coloredAscii = '';

    template.ascii.forEach(line => {
        let coloredLine = '';
        for (let char of line) {
            const colorType = template.colorMap[char];
            if (colorType && scheme[colorType]) {
                coloredLine += char[scheme[colorType]];
            } else {
                coloredLine += char;
            }
        }
        coloredAscii += coloredLine + '\n';
    });

    return coloredAscii;
}

/**
 * Get all available templates
 * @returns {Array} Array of template names and descriptions
 */
function getAvailableTemplates() {
    return Object.keys(templates).map(key => ({
        id: key,
        name: templates[key].name,
        preview: templates[key].ascii[0] // First line as preview
    }));
}

/**
 * Get all available color schemes
 * @returns {Array} Array of color scheme names
 */
function getAvailableColorSchemes() {
    return Object.keys(colorSchemes).map(key => ({
        id: key,
        name: key.charAt(0).toUpperCase() + key.slice(1),
        colors: colorSchemes[key]
    }));
}

module.exports = {
    generateColoredFrog,
    getAvailableTemplates,
    getAvailableColorSchemes,
    templates,
    colorSchemes
};
