// ASCII Frog Templates - Plain text only, no colors

// Professional ASCII frog templates from classic ASCII artists
const templates = {
    tiny: {
        name: 'Tiny Frog',
        ascii: [
            '     00',
            '  (\\_--/)',
            '   // \\\\',
            '  ^^   ^^'
        ]
    },

    classic: {
        name: 'Classic Frog',
        ascii: [
            '        ()--()',
            '      .-(___)-.',
            '       _<   >_',
            '       \\/   \\/'
        ]
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
        ]
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
        ]
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
        ]
    },

    simple: {
        name: 'Simple Frog',
        ascii: [
            '        00         ',
            '      (\\__/)       ',
            ' __(  I I   I I  )__'
        ]
    }
};

/**
 * Generate ASCII frog (plain text, no colors)
 * @param {string} templateName - Name of the template to use
 * @returns {string} Plain ASCII art string
 */
function generateFrog(templateName = 'classic') {
    const template = templates[templateName];

    if (!template) {
        throw new Error(`Template "${templateName}" not found`);
    }

    let ascii = '';
    template.ascii.forEach(line => {
        ascii += line + '\n';
    });

    return ascii;
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

module.exports = {
    generateFrog,
    getAvailableTemplates,
    templates
};
