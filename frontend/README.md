# ASCII Frog Frontend

Frontend application for the ASCII Frog Generator - a modern Vite-based web interface.

## Development

```bash
npm install
npm run dev
```

The frontend will be available at `http://localhost:3000` and will proxy API requests to the backend at `http://localhost:3001`.

## Build

```bash
npm run build
```

Builds the frontend for production in the `dist/` directory.

## Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build

## Configuration

The frontend is configured to proxy API requests to the backend. See `vite.config.mjs` for proxy configuration.
