# Photo Frog Generator

A Java-based web service that generates photo-realistic images of frogs with customizable features like size, style, and expressions.

## Features

- **Photo-realistic frog generation** with multiple templates
- **Size customization** (small, medium, large, custom)
- **Style variations** (different poses and expressions)
- **Web interface** for easy interaction
- **Download functionality** (JPEG, PNG formats)
- **RESTful API** for programmatic access

## Technology Stack

- **Backend**: Java 17 with Spring Boot 3.1.0
- **Image Processing**: OpenCV 4.7.0
- **Build Tool**: Maven
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Containerization**: Docker
- **Orchestration**: Kubernetes with Helm

## Quick Start

### Prerequisites

- Java 17 or higher
- Maven 3.6 or higher

### Running the Application

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/photo-frog.git
   cd photo-frog
   ```

2. **Build the project**
   ```bash
   mvn clean install
   ```

3. **Run the application**
   ```bash
   mvn spring-boot:run
   ```

4. **Access the application**
   - Web Interface: http://localhost:8080
   - Health Check: http://localhost:8080/api/health
   - API Documentation: http://localhost:8080/api/docs

## API Endpoints

### Health Check
- `GET /api/health` - Application health status

### Photo Generation
- `POST /api/generate-photo` - Generate a new frog photo
- `GET /api/templates` - List available frog templates
- `GET /api/gallery` - View generated photos

## Development

### Project Structure
```
photo-frog/
├── src/
│   ├── main/
│   │   ├── java/com/froggen/photofrog/
│   │   │   ├── PhotoFrogApplication.java
│   │   │   ├── controller/
│   │   │   ├── service/
│   │   │   ├── model/
│   │   │   ├── util/
│   │   │   └── config/
│   │   └── resources/
│   │       ├── static/
│   │       └── application.properties
│   └── test/
└── pom.xml
```

### Running Tests
```bash
mvn test
```

### Code Quality Checks
```bash
mvn checkstyle:check
mvn spotbugs:check
```

## Docker Deployment

### Build Docker Image
```bash
docker build -t photo-frog .
```

### Run with Docker
```bash
docker run -p 8080:8080 photo-frog
```

### Docker Compose
```bash
docker-compose up -d
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Spring Boot team for the excellent framework
- OpenCV community for image processing capabilities
- All contributors and maintainers
# Photo Generation Engine Enhancement
