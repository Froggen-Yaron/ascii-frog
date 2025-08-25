# 🐸 FrogGen - ASCII Frog Generator

A fun web service that generates beautiful colored ASCII art frogs with a terminal-like interface.

**Also check out our other cool apps: lineart-frog and photo-frog!**


## Features

- 🎨 **Professional ASCII Art**: Templates from legendary ASCII artists like Joan Stark
- 🐸 **6 Authentic Frog Designs**: Traditional, recognizable ASCII frog artwork
- 🌈 **Clean Display**: Monochrome ASCII art with colorful frog names
- 💻 **Terminal UI**: Embedded terminal-like display for authentic CLI feel
- 📋 **Copy to Clipboard**: Easy copying of generated ASCII art with frog names
- 🎲 **Random Generation**: Get surprise professional frog combinations
- 📱 **Responsive Design**: Works on desktop and mobile devices

## Quick Start

1. **Install workspace dependencies:**
   ```bash
   npm install
   ```

2. **Start development servers:**
   ```bash
   npm run dev
   ```
   This will start both the frontend (Vite) and backend (Express) servers concurrently.

3. **Development URLs:**
   - **Frontend**: `http://localhost:3000` (Vite dev server)
   - **Backend API**: `http://localhost:3001` (Express API server)

4. **Alternative development modes:**
   ```bash
   npm run frontend:dev   # Frontend only
   npm run backend:dev    # Backend only
   npm run build         # Build frontend for production
   npm start             # Start Docker container
   ```

## Project Structure

This is a modern monorepo following industry best practices:

```
ascii-frog/
├── frontend/             # Frontend web application (Vite + TypeScript)
├── backend/              # Backend API server (Express + Node.js)
├── Dockerfile            # Container build configuration
├── docker-compose.yml    # Container orchestration
└── package.json          # Workspace root
```

- **`frontend/`** - Frontend web application
- **`backend/`** - Backend API server  
- **`Dockerfile` & `docker-compose.yml`** - Container deployment

## API Endpoints

### Generate Frog
```bash
POST /api/generate-frog
Content-Type: application/json

{
  "template": "medium",
  "colorScheme": "classic"
}
```

### Get Templates
```bash
GET /api/templates
```

### Get Color Schemes
```bash
GET /api/color-schemes
```

### Random Frog
```bash
GET /api/random-frog
```

## Available Templates

- **Tiny Frog**: Minimalist 4-line design
- **Classic Frog**: Traditional detailed design
- **Happy Frog**: Cheerful expression with smile
- **Sitting Frog**: Detailed relaxed pose
- **Large Frog**: Elaborate multi-line design
- **Simple Frog**: Clean traditional style

## Available Color Schemes

- **Classic**: Traditional green frog colors
- **Tropical**: Bright cyan and magenta
- **Fire**: Bold red and yellow
- **Nature**: Natural green and blue
- **Royal**: Elegant blue and gold

## Technology Stack

- **Backend**: Node.js, Express.js
- **Frontend**: Vanilla JavaScript, Modern CSS
- **Colors**: npm colors package for terminal output
- **Styling**: Terminal-inspired UI with animations

## Project Structure

```
ascii-frog/
├── server.js                 # Main server file
├── package.json             # Dependencies and scripts
├── public/                  # Static frontend files
│   ├── index.html          # Main webpage
│   ├── css/styles.css      # Styling
│   └── js/app.js           # Frontend JavaScript
└── src/                    # Backend source code
    ├── routes/api.js       # API routes
    └── templates/          # ASCII art templates
        └── frogTemplates.js
```

## Scripts

- `npm start`: Start production server
- `npm run dev`: Start development with live reloading (recommended)
- `npm run server`: Start backend server only (no live reload)
- `npm run browser-sync`: Start browser-sync proxy only
- `npm run build`: Build the project (no build step required)
- `npm test`: Run health check tests
- `npm run test:api`: Run API integration tests

## 🚀 Deployment

### Docker Deployment (Recommended)

#### Quick Start with Docker Compose
```bash
# Build and run the service
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the service
docker-compose down
```

#### Manual Docker Build
```bash
# Build the Docker image
docker build -t ascii-frog .

# Run the container
docker run -p 3000:3000 ascii-frog
```

### 🔄 Simple CI/CD Pipeline

The project includes a streamlined GitHub Actions workflow:

1. **🧪 Tests**: Runs on Node.js 20
   - Health checks
   - API integration tests

2. **🐳 Docker**: Simple build and push
   - Builds and pushes to GitHub Container Registry
   - Tags with latest and version numbers

3. **🚀 Releases**: Automated for version tags
   - Creates GitHub releases
   - Publishes Docker images


### 🌐 Simple Production Deployment

#### Environment Variables
```bash
NODE_ENV=production
PORT=3000
```

#### Health Checks
The application includes built-in health checks:
- **Docker**: `HEALTHCHECK` instruction
- **API**: `/api/templates` endpoint  
- **Tests**: `npm test` for validation

### 🔒 Security Features

- **Container Security**: Non-root user (froggen:nodejs)
- **Health Monitoring**: Built-in health checks

## Easter Egg

Try entering the Konami Code on the webpage: ↑↑↓↓←→←→BA

## Demo

Visit the live demo at: `http://localhost:3000`

## Screenshots

The interface features:
- Beautiful terminal-like ASCII art display
- Intuitive controls for template and color selection
- Real-time generation and preview
- Modern dark theme with syntax highlighting

## Contributing

This is a demo project, but feel free to:
- Add new frog templates
- Create additional color schemes
- Improve the terminal styling
- Add new features

## License

MIT License - Feel free to use this code for your own ASCII art projects!

---

Made with ❤️ for ASCII art enthusiasts
# Testing credentials restored
