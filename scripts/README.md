# Nicotine Scripts Directory

This directory contains various scripts to help with development, testing, and deployment of the Nicotine FastAPI service.

## 🚀 Local Development Scripts

### Quick Start

- **`start-dev.sh`** - Simple one-command start for local development
  ```bash
  ./scripts/start-dev.sh
  ```

### Advanced Development

- **`cli/serve.sh`** - Advanced local development server with many options
  ```bash
  ./scripts/cli/serve.sh --help
  ./scripts/cli/serve.sh -p 8080 --no-reload
  ./scripts/cli/serve.sh --production
  ```

## 🐳 Docker Scripts

### Building

- **`cli/docker-build.sh`** - Build Docker images
  ```bash
  ./scripts/cli/docker-build.sh
  ./scripts/cli/docker-build.sh --dev
  ./scripts/cli/docker-build.sh --no-cache
  ```

### Running

- **`cli/docker-run.sh`** - Run Docker containers
  ```bash
  ./scripts/cli/docker-run.sh -d
  ./scripts/cli/docker-run.sh -p 8080
  ```

### Management

- **`cli/docker-manage.sh`** - Manage running containers
  ```bash
  ./scripts/cli/docker-manage.sh status
  ./scripts/cli/docker-manage.sh logs -f
  ./scripts/cli/docker-manage.sh stop
  ./scripts/cli/docker-manage.sh clean
  ```

## 🧪 Testing Scripts

### API Testing

- **`test_api.py`** - Manual API endpoint testing
  ```bash
  python scripts/test_api.py
  python scripts/test_api.py http://localhost:8080
  ```

### Code Quality

- **`cli/validate.sh`** - Run all code quality checks
- **`cli/test.sh`** - Run all tests
- **`cli/lint.sh`** - Run linting checks
- **`cli/typecheck.sh`** - Run type checking

## 🛠 Utility Scripts

### Setup and Installation

- **`cli/install.sh`** - Install dependencies
- **`cli/build.sh`** - Build the package
- **`cli/clean.sh`** - Clean build artifacts
- **`verify-setup.sh`** - Verify installation

### Help and Information

- **`cli/help.sh`** - Show available commands
- **`nico`** - Main CLI entry point

## 📝 Usage Examples

### Complete Development Workflow

```bash
# 1. Quick start for development
./scripts/start-dev.sh

# 2. Run tests in another terminal
./scripts/cli/test.sh

# 3. Test API manually
python scripts/test_api.py

# 4. Build and test with Docker
./scripts/cli/docker-build.sh
./scripts/cli/docker-run.sh -d
./scripts/cli/docker-manage.sh logs -f
```

### Production Deployment

```bash
# Build production image
./scripts/cli/docker-build.sh

# Run in production mode
./scripts/cli/docker-run.sh --env-file .env.prod

# Or use the advanced serve script
./scripts/cli/serve.sh --production
```

### Development with Custom Settings

```bash
# Development on different port
./scripts/cli/serve.sh -p 3000

# Development without auto-reload
./scripts/cli/serve.sh --no-reload

# Development with custom environment
./scripts/cli/serve.sh -e .env.development
```

## 💡 Tips

1. **Always start with `./scripts/start-dev.sh`** for quick development
2. **Use `./scripts/cli/serve.sh --help`** to see all available options
3. **Check logs with `./scripts/cli/docker-manage.sh logs -f`** when using Docker
4. **Run `python scripts/test_api.py`** to verify your API is working
5. **Use `./scripts/cli/validate.sh`** before committing code

## 🔧 Script Permissions

All scripts should be executable. If you get permission errors, run:

```bash
chmod +x scripts/*.sh
chmod +x scripts/cli/*.sh
chmod +x scripts/*.py
```

---

For more detailed documentation, see the main [README.md](../README.md) and [QUICKSTART.md](../QUICKSTART.md).
