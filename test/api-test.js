// API integration tests for ASCII Frog Generator
const http = require('http');

const SERVER_URL = process.env.SERVER_URL || 'http://localhost:3000';

function makeRequest(options, data = null) {
    return new Promise((resolve, reject) => {
        const req = http.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => {
                try {
                    const parsed = body ? JSON.parse(body) : {};
                    resolve({ statusCode: res.statusCode, body: parsed });
                } catch (error) {
                    resolve({ statusCode: res.statusCode, body: body });
                }
            });
        });

        req.on('error', reject);
        req.setTimeout(10000, () => {
            req.destroy();
            reject(new Error('Request timeout'));
        });

        if (data) {
            req.write(JSON.stringify(data));
        }
        req.end();
    });
}

async function testTemplatesEndpoint() {
    console.log('🧪 Testing /api/templates endpoint...');

    const options = {
        hostname: 'localhost',
        port: 3000,
        path: '/api/templates',
        method: 'GET'
    };

    const response = await makeRequest(options);

    if (response.statusCode !== 200) {
        throw new Error(`Templates endpoint failed: ${response.statusCode}`);
    }

    if (!response.body.success || !Array.isArray(response.body.templates)) {
        throw new Error('Templates endpoint returned invalid data');
    }

    console.log(`✅ Templates endpoint: Found ${response.body.templates.length} templates`);
}

async function testGenerateFrogEndpoint() {
    console.log('🧪 Testing /api/generate-frog endpoint...');

    const options = {
        hostname: 'localhost',
        port: 3000,
        path: '/api/generate-frog',
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    };

    const data = {
        template: 'tiny',
        colorScheme: 'classic'
    };

    const response = await makeRequest(options, data);

    if (response.statusCode !== 200) {
        throw new Error(`Generate frog endpoint failed: ${response.statusCode}`);
    }

    if (!response.body.success || !response.body.ascii) {
        throw new Error('Generate frog endpoint returned invalid data');
    }

    console.log('✅ Generate frog endpoint: Successfully generated ASCII art');
}

async function testRandomFrogEndpoint() {
    console.log('🧪 Testing /api/random-frog endpoint...');

    const options = {
        hostname: 'localhost',
        port: 3000,
        path: '/api/random-frog',
        method: 'GET'
    };

    const response = await makeRequest(options);

    if (response.statusCode !== 200) {
        throw new Error(`Random frog endpoint failed: ${response.statusCode}`);
    }

    if (!response.body.success || !response.body.ascii) {
        throw new Error('Random frog endpoint returned invalid data');
    }

    console.log('✅ Random frog endpoint: Successfully generated random ASCII art');
}

async function runAPITests() {
    try {
        console.log('🔍 Running API tests...');

        await testTemplatesEndpoint();
        await testGenerateFrogEndpoint();
        await testRandomFrogEndpoint();

        console.log('✅ All API tests passed!');
        process.exit(0);
    } catch (error) {
        console.error('❌ API test failed:', error.message);
        process.exit(1);
    }
}

// Only run if this file is executed directly
if (require.main === module) {
    runAPITests();
}

module.exports = { testTemplatesEndpoint, testGenerateFrogEndpoint, testRandomFrogEndpoint };
