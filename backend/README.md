# ASCII Frog Backend

Backend application for the ASCII Frog Generator - an Express API server.

## Development

```bash
npm install
npm run dev
```

The API server will be available at `http://localhost:8001`.

## Production

In production mode, the backend also serves static frontend files.

```bash
NODE_ENV=production npm start
```

## Scripts

- `npm run dev` - Start development server with nodemon
- `npm start` - Start production server
- `npm test` - Run health check tests

## API Endpoints

- `GET /` - API info (development) or frontend app (production)
- `GET /health` - Health check endpoint
- `GET /api/*` - ASCII frog generation endpoints

## Environment Variables

- `PORT` - Server port (default: 8001)
- `NODE_ENV` - Environment mode (development/production)
