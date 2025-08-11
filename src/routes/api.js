const express = require('express');
const router = express.Router();
const {
    generateColoredFrog,
    getAvailableTemplates,
    getAvailableColorSchemes
} = require('../templates/frogTemplates');

/**
 * POST /api/generate-frog
 * Generate a colored ASCII frog
 */
router.post('/generate-frog', (req, res) => {
    try {
        const { template = 'medium', colorScheme = 'classic' } = req.body;

        console.log(`🐸 Generating frog - Template: ${template}, Color: ${colorScheme}`.cyan);

        const asciiArt = generateColoredFrog(template, colorScheme);

        res.json({
            success: true,
            ascii: asciiArt,
            template,
            colorScheme,
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
 * GET /api/color-schemes
 * Get all available color schemes
 */
router.get('/color-schemes', (req, res) => {
    try {
        const colorSchemes = getAvailableColorSchemes();
        res.json({
            success: true,
            colorSchemes
        });
    } catch (error) {
        console.error('Error fetching color schemes:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch color schemes'
        });
    }
});

/**
 * GET /api/random-frog
 * Generate a random frog with random template and color scheme
 */
router.get('/random-frog', (req, res) => {
    try {
        const templates = getAvailableTemplates();
        const colorSchemes = getAvailableColorSchemes();

        const randomTemplate = templates[Math.floor(Math.random() * templates.length)];
        const randomColorScheme = colorSchemes[Math.floor(Math.random() * colorSchemes.length)];

        const asciiArt = generateColoredFrog(randomTemplate.id, randomColorScheme.id);

        console.log(`🎲 Random frog generated - Template: ${randomTemplate.id}, Color: ${randomColorScheme.id}`.magenta);

        res.json({
            success: true,
            ascii: asciiArt,
            template: randomTemplate.id,
            colorScheme: randomColorScheme.id,
            templateName: randomTemplate.name,
            colorSchemeName: randomColorScheme.name,
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
