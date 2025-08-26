/**
 * Browser-sync configuration for ASCII Frog Generator
 * Provides live reloading for frontend development
 */

module.exports = {
    proxy: 'localhost:8000',
    files: [
        'public/**/*.html',
        'public/**/*.css',
        'public/**/*.js',
        'public/**/*.json'
    ],
    port: 8002,
    open: true,
    notify: true,
    reloadDelay: 100,
    reloadDebounce: 100,
    ui: {
        port: 8003
    },
    ghostMode: {
        clicks: true,
        forms: true,
        scroll: true
    },
    logLevel: 'info',
    logPrefix: '🐸 ASCII-Frog',
    browser: 'default',
    cors: true,
    reloadOnRestart: true,
    timestamps: true
};
