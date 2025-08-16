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
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet({
    contentSecurityPolicy: false, // Disable for development
}));

// CORS middleware
app.use(cors());

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files (built frontend or fallback to public)
const frontendPath = process.env.NODE_ENV === 'production'
    ? path.join(__dirname, '../frontend/dist')
    : path.join(__dirname, '../frontend/public');
app.use(express.static(frontendPath));

// Health check route (before API routes for priority)
app.use('/health', healthRoutes);

// API routes
app.use('/api', apiRoutes);

// Root route
app.get('/', (req, res) => {
    const htmlPath = process.env.NODE_ENV === 'production'
        ? path.join(__dirname, '../frontend/dist', 'index.html')
        : path.join(__dirname, '../frontend', 'index.html');
    res.sendFile(htmlPath);
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
    console.log(`🐸 ASCII Frog Generator API server running on port ${PORT}`.green.bold);
    console.log(`🌐 Frontend available at http://localhost:3000`.cyan);
});

export default app;
