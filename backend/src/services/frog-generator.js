
import { generateFrog, getAvailableTemplates } from '../templates/templates.js';

/**
 * Generate a frog with specified type/ID
 * @param {string} frogId - The ID of the frog type to generate
 * @returns {Object} Generated frog data with ASCII art and name
 */
function generateSpecificFrog(frogId) {
    const frogData = generateFrog(frogId);
    return {
        ascii: frogData.ascii,
        frogName: frogData.name
    };
}

/**
 * Generate a random frog
 * @returns {Object} Generated frog data with ASCII art and name
 */
function generateRandomFrog() {
    const availableFrogs = getAvailableTemplates();
    const randomFrog = availableFrogs[Math.floor(Math.random() * availableFrogs.length)];

    return generateSpecificFrog(randomFrog.id);
}

export {
    generateSpecificFrog,
    generateRandomFrog
};
