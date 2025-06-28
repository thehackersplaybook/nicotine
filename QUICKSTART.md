# Nicotine FastAPI Service - Quick Start Guide

This guide will help you quickly set up and run the Nicotine AI Hallucination Detection Service using FastAPI and Docker.

## 🚀 Quick Setup (5 minutes).

### Prerequisites

- Docker and Docker Compose installed.
- Git (to clone the repository).
- Optional: Python 3.11+ for local development.

### 1. Clone and Setup.

```bash
# Clone the repository (if not already done)
git clone https://www.github.com/thehackersplaybook/nicotine
cd nicotine

# Copy environment template
cp env.sample .env

# Edit .env file and add your OpenAI API key
# OPENAI_API_KEY=your_actual_api_key_here
```

### 2. Build and Run with Docker

```bash
# Build the Docker image
./scripts/cli/docker-build.sh

# Run the service in background
./scripts/cli/docker-run.sh -d

# Or use docker-compose for development
docker-compose up -d nicotine-dev
```

### 3. Verify the Service

```bash
# Check if service is running
curl http://localhost:8000/health

# Run the API test script
python scripts/test_api.py

# Open interactive API docs in browser
open http://localhost:8000/docs
```

## 🛠 Development Workflow

### Local Development

#### Quick Start (Recommended)

```bash
# Simple development server with auto-reload
./scripts/start-dev.sh

# Or with more options
./scripts/cli/serve.sh
```

#### Manual Setup

```bash
# Install dependencies
pip install -r requirements.dev.txt

# Quick start with FastAPI CLI
fastapi dev nicotine/api.py

# Or with uvicorn directly
uvicorn nicotine.api:app --host 0.0.0.0 --port 8000 --reload

# Run tests
pytest tests/ -v

# Run integration tests
pytest tests/test_api_integration.py -v
```

#### Advanced Local Development

```bash
# Start with custom port
./scripts/cli/serve.sh -p 8080

# Start without auto-reload
./scripts/cli/serve.sh --no-reload

# Start in production mode
./scripts/cli/serve.sh --production

# Start with custom environment file
./scripts/cli/serve.sh -e .env.local
```

### Docker Development

```bash
# Development with hot reload
docker-compose up nicotine-dev

# Run tests in Docker
docker-compose up nicotine-test

# View logs
./scripts/cli/docker-manage.sh logs -f

# Open shell in container
./scripts/cli/docker-manage.sh shell
```

## 📊 API Usage Examples

### Health Check

```bash
curl http://localhost:8000/health
```

### Detect Hallucinations

```bash
curl -X POST http://localhost:8000/api/v1/detect-hallucination \
  -H "Content-Type: application/json" \
  -d '{
    "id": "test-001",
    "prompt": "What is the capital of France?",
    "output": "The capital of France is Paris.",
    "settings": {
      "model": "gpt-4",
      "temperature": 0.7,
      "max_tokens": 1000
    }
  }'
```

## 🧪 Testing

### Run All Tests

```bash
# Unit tests
pytest tests/unit/ -v

# Integration tests
pytest tests/test_api_integration.py -v

# All tests with coverage
pytest --cov=nicotine --cov-report=html
```

### Manual API Testing

```bash
# Start service
./scripts/cli/docker-run.sh -d

# Run test script
python scripts/test_api.py

# Stop service
./scripts/cli/docker-manage.sh stop
```

## 🐳 Docker Commands Reference

### Building

```bash
# Build development image
./scripts/cli/docker-build.sh --dev

# Build production image
./scripts/cli/docker-build.sh

# Build without cache
./scripts/cli/docker-build.sh --no-cache
```

### Running

```bash
# Run in foreground
./scripts/cli/docker-run.sh

# Run in background
./scripts/cli/docker-run.sh -d

# Run with custom port
./scripts/cli/docker-run.sh -p 8080

# Run with custom environment file
./scripts/cli/docker-run.sh -e .env.prod
```

### Managing

```bash
# Check status
./scripts/cli/docker-manage.sh status

# View logs
./scripts/cli/docker-manage.sh logs

# Follow logs
./scripts/cli/docker-manage.sh logs -f

# Stop container
./scripts/cli/docker-manage.sh stop

# Start existing container
./scripts/cli/docker-manage.sh start

# Restart container
./scripts/cli/docker-manage.sh restart

# Clean up (stop and remove)
./scripts/cli/docker-manage.sh clean
```

## 🔧 Configuration

### Environment Variables

```bash
# Required
OPENAI_API_KEY=your_api_key

# Optional
NICOTINE_CONFIG=./config/default.yaml
NICOTINE_HOST=0.0.0.0
NICOTINE_PORT=8000
NICOTINE_LOG_LEVEL=INFO
```

### Configuration File

Edit `config/default.yaml` to customize:

- API settings (CORS, endpoints)
- OpenAI model defaults
- Logging configuration
- Health check settings
- Metrics and monitoring

## 🚨 Troubleshooting

### Service Won't Start

```bash
# Check if port 8000 is already in use
lsof -i :8000

# Check Docker containers
docker ps -a

# View container logs
./scripts/cli/docker-manage.sh logs
```

### API Errors

```bash
# Verify OpenAI API key is set
echo $OPENAI_API_KEY

# Check service health
curl http://localhost:8000/health

# Run diagnostic test
python scripts/test_api.py
```

### Permission Issues

```bash
# Make scripts executable
chmod +x scripts/cli/*.sh
chmod +x scripts/*.py
```

## 📈 Production Deployment

### Production Build

```bash
# Build production image
docker build --target production -t nicotine:latest .

# Run production container
docker run -d \
  --name nicotine-prod \
  -p 8000:8000 \
  --env-file .env.prod \
  --restart unless-stopped \
  nicotine:latest
```

### Docker Compose Production

```bash
# Use production configuration
docker-compose -f docker-compose.yml up -d nicotine-prod
```

### Health Monitoring

- Health endpoint: `GET /health`
- Metrics endpoint: `GET /metrics` (if enabled)
- API docs: `GET /docs`

## 🔗 Useful Links

- Interactive API Documentation: http://localhost:8000/docs
- Alternative API Documentation: http://localhost:8000/redoc
- Health Check Endpoint: http://localhost:8000/health
- Service Root: http://localhost:8000/

## 💡 Tips

1. **Use the test script** (`python scripts/test_api.py`) to verify everything works
2. **Check logs** regularly with `./scripts/cli/docker-manage.sh logs -f`
3. **Use docker-compose** for development, direct Docker for production
4. **Set proper OpenAI API key** - the service won't work without it
5. **Monitor resource usage** with `./scripts/cli/docker-manage.sh status`

---

## Next Steps

1. Explore the interactive API documentation at http://localhost:8000/docs
2. Run the integration tests to ensure everything works
3. Customize the configuration in `config/default.yaml`
4. Build your application using the API endpoints
5. Deploy to production using the production Docker configuration

Happy coding! 🎉
