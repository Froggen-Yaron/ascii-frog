const express = require('express');
const router = express.Router();
const {
    generateFrog,
    getAvailableTemplates
} = require('../templates/frogTemplates');
/**
 * POST /api/generate-frog
 * Generate ASCII frog (plain text)
 */
router.post('/generate-frog', (req, res) => {
    try {
        const { template = 'classic' } = req.body;

        console.log(`🐸 Generating frog - Template: ${template}`.cyan);

        const asciiArt = generateFrog(template);

        res.json({
            success: true,
            ascii: asciiArt,
            template,
            timestamp: new Date().toISOString()
        });

    } catch (error) {
        console.error('Error generating frog:', error.message);
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
});

/**
 * GET /api/templates
 * Get all available frog templates
 */
router.get('/templates', (req, res) => {
    try {
        const templates = getAvailableTemplates();
        res.json({
            success: true,
            templates
        });
    } catch (error) {
        console.error('Error fetching templates:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch templates'
        });
    }
});



/**
 * GET /api/random-frog
 * Generate a random frog with random template
 */
router.get('/random-frog', (req, res) => {
    try {
        const templates = getAvailableTemplates();
        const randomTemplate = templates[Math.floor(Math.random() * templates.length)];
        const asciiArt = generateFrog(randomTemplate.id);

        console.log(`🎲 Random frog generated - Template: ${randomTemplate.id}`.magenta);

        res.json({
            success: true,
            ascii: asciiArt,
            template: randomTemplate.id,
            templateName: "Frog Name",
            timestamp: new Date().toISOString()
        });

    } catch (error) {
        console.error('Error generating random frog:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to generate random frog'
        });
    }
});

module.exports = router;
