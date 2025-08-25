#!/usr/bin/env node
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import path from 'path';
import colors from 'colors';
import { fileURLToPath } from 'url';

// Import routes
import apiRoutes from './src/routes/api.js';
import healthRoutes from './src/routes/health.js';

// ESM equivalent of __dirname
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;

// Security middleware
app.use(helmet({
    contentSecurityPolicy: false, // Disable for development
}));

// CORS middleware
app.use(cors());

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Conditional static file serving for production (Docker deployment)
if (process.env.NODE_ENV === 'production') {
    const frontendPath = path.join(__dirname, '../frontend/dist');
    app.use(express.static(frontendPath));
    console.log('🐳 Production mode: Serving static files from', frontendPath);
}

// Health check route (before API routes for priority)
app.use('/health', healthRoutes);

// API routes
app.use('/api', apiRoutes);

// Root route - conditional behavior
app.get('/', (req, res) => {
    if (process.env.NODE_ENV === 'production') {
        // Serve frontend HTML in production
        const htmlPath = path.join(__dirname, '../frontend/dist', 'index.html');
        res.sendFile(htmlPath);
    } else {
        // API info for development
        res.json({
            message: 'ASCII Frog Generator API',
            version: '1.0.0',
            endpoints: {
                health: '/health',
                api: '/api'
            }
        });
    }
});

// Error handling middleware
app.use((error, req, res, next) => {
    console.error('Error:', error.message.red);
    res.status(500).json({ error: 'Internal server error' });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({ error: 'Route not found' });
});

// Start server
app.listen(PORT, () => {
    if (process.env.NODE_ENV === 'production') {
        console.log(`🐸 ASCII Frog Generator running at http://localhost:${PORT}`.green.bold);
    } else {
        console.log(`🔗 API server ready on port ${PORT}`.green);
        console.log(`🐸 Visit the app at http://localhost:3000`.cyan.bold);
    }
});

export default app;
