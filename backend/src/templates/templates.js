// ASCII Frog Templates - plain text names, colors applied in API layer

// Professional ASCII frog templates from classic ASCII artists
const templates = {
    tiny: {
        name: 'Strawberry Poison Frog',
        ascii: [
            '   00',
            '(\\_--/)',
            ' // \\\\',
            '^^   ^^'
        ]
    },

    classic: {
        name: 'American Bullfrog',
        ascii: [
            '  ()--()',
            '.-(___)-.',
            ' _<   >_',
            ' \\/   \\/'
        ]
    },

    happy: {
        name: 'Red-eyed Tree Frog',
        ascii: [
            '   (l)-(l)',
            '   /_____\\',
            '   \\_____/',
            '    /00\\',
            '_/^(----)^\\_',
            '^^^^^^^^^^^^^'
        ]
    },

    sitting: {
        name: 'Common Frog',
        ascii: [
            '        _   _',
            '       (o)-(o)',
            '    .-(   "   )-.',
            '   /  /`\'-=-\'`\\  \\',
            '__\\ _\\ \\___/ /_ /__',
            '  /|  /|\\ /|\\  |\\',
            ' ^^   ^^  ^^   ^^'
        ]
    },

    large: {
        name: 'Goliath Frog',
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
        name: 'Desert Rain Frog',
        ascii: [
            '        00         ',
            '      (\\__/)       ',
            ' __(  I I   I I  )__'
        ]
    },

    wonder: {
        name: 'Wonder Frog',
        ascii: [
            '       *  .  *',
            '    .    ★    .',
            '      (◕‿◕)',
            '    .-\'`~~~~`\'-.',
            '   /  ∙    ∙  \\',
            '  |    ~~~~    |',
            '   \\  \'.__.\' /',
            '    `-._~~_.-\'',
            '      /|  |\\',
            '     ^^    ^^',
            '    *   ★   *'
        ]
    }
};

/**
 * Generate ASCII frog with name (plain text, no colors)
 * @param {string} templateName - Name of the template to use
 * @returns {Object} Object containing ASCII art string and frog name
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

    return {
        ascii,
        name: template.name
    };
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

export {
    generateFrog,
    getAvailableTemplates,
    templates
};
