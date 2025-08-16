import express from 'express';
const router = express.Router();

// Health check endpoint for Docker and monitoring
router.get('/', (req, res) => {
    res.status(200).json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        service: 'ascii-frog-generator'
    });
});

export default router;
