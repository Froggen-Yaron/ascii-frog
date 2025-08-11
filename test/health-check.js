// Simple health check test for ASCII Frog Generator
const http = require('http');

const SERVER_URL = process.env.SERVER_URL || 'http://localhost:3000';
const PORT = process.env.PORT || 3000;

function healthCheck() {
    return new Promise((resolve, reject) => {
        const req = http.get(`${SERVER_URL}/api/templates`, (res) => {
            if (res.statusCode === 200) {
                console.log('✅ Health Check: Server is responding');
                resolve(true);
            } else {
                console.error(`❌ Health Check: Server returned ${res.statusCode}`);
                reject(new Error(`Health check failed with status ${res.statusCode}`));
            }
        });

        req.on('error', (error) => {
            console.error('❌ Health Check: Server is not responding');
            console.error(error.message);
            reject(error);
        });

        req.setTimeout(5000, () => {
            req.destroy();
            reject(new Error('Health check timeout'));
        });
    });
}

async function runHealthCheck() {
    try {
        console.log('🔍 Running health check...');
        await healthCheck();
        console.log('✅ All health checks passed!');
        process.exit(0);
    } catch (error) {
        console.error('❌ Health check failed:', error.message);
        process.exit(1);
    }
}

// Only run if this file is executed directly
if (require.main === module) {
    runHealthCheck();
}

module.exports = { healthCheck };
