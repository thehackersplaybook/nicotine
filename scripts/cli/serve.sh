#!/bin/bash

# serve.sh - Start FastAPI application locally for development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
HOST="0.0.0.0"
PORT="8000"
RELOAD=true
ENV_FILE=".env"
LOG_LEVEL="info"
WORKERS=1

# Show help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Start the Nicotine FastAPI application locally for development"
    echo ""
    echo "Options:"
    echo "  -h, --host HOST           Host to bind to (default: 0.0.0.0)"
    echo "  -p, --port PORT           Port to bind to (default: 8000)"
    echo "  --no-reload               Disable auto-reload on code changes"
    echo "  -e, --env-file FILE       Environment file to load (default: .env)"
    echo "  -l, --log-level LEVEL     Log level (default: info)"
    echo "  -w, --workers NUM         Number of worker processes (default: 1)"
    echo "  --production              Run in production mode (no reload, multiple workers)"
    echo "  --help                    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                        # Start with default settings"
    echo "  $0 -p 8080               # Start on port 8080"
    echo "  $0 --no-reload           # Start without auto-reload"
    echo "  $0 --production          # Start in production mode"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--host)
            HOST="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        --no-reload)
            RELOAD=false
            shift
            ;;
        -e|--env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        -l|--log-level)
            LOG_LEVEL="$2"
            shift 2
            ;;
        -w|--workers)
            WORKERS="$2"
            shift 2
            ;;
        --production)
            RELOAD=false
            WORKERS=4
            LOG_LEVEL="warning"
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

echo -e "${BLUE}🚀 Starting Nicotine FastAPI Application${NC}"
echo -e "${YELLOW}=================================${NC}"

# Check if we're in the right directory
if [ ! -f "nicotine/api.py" ]; then
    echo -e "${RED}❌ Error: nicotine/api.py not found${NC}"
    echo -e "${YELLOW}Please run this script from the nicotine project root directory${NC}"
    exit 1
fi

# Check if environment file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${YELLOW}⚠️  Environment file '$ENV_FILE' not found${NC}"
    if [ -f "env.sample" ]; then
        echo -e "${YELLOW}   Creating $ENV_FILE from env.sample...${NC}"
        cp env.sample "$ENV_FILE"
        echo -e "${YELLOW}   Please edit $ENV_FILE and add your OpenAI API key${NC}"
    else
        echo -e "${YELLOW}   Please create $ENV_FILE with your configuration${NC}"
    fi
    echo
fi

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    echo -e "${GREEN}📝 Loading environment from: $ENV_FILE${NC}"
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo -e "${YELLOW}⚠️  No environment file loaded${NC}"
fi

# Check if OpenAI API key is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${YELLOW}⚠️  Warning: OPENAI_API_KEY not set${NC}"
    echo -e "${YELLOW}   The hallucination detection will not work without it${NC}"
    echo
fi

# Install dependencies if needed
if ! command -v fastapi &> /dev/null; then
    echo -e "${YELLOW}📦 Installing FastAPI CLI...${NC}"
    pip install "fastapi[standard]"
fi

# Build command arguments
FASTAPI_CMD="fastapi"
if [ "$RELOAD" = true ]; then
    FASTAPI_CMD="$FASTAPI_CMD dev"
else
    FASTAPI_CMD="$FASTAPI_CMD run"
fi

# Add common arguments
FASTAPI_CMD="$FASTAPI_CMD nicotine/api.py"
FASTAPI_CMD="$FASTAPI_CMD --host $HOST"
FASTAPI_CMD="$FASTAPI_CMD --port $PORT"

# Add production-specific arguments
if [ "$RELOAD" = false ] && [ "$WORKERS" -gt 1 ]; then
    FASTAPI_CMD="$FASTAPI_CMD --workers $WORKERS"
fi

echo -e "${GREEN}🔧 Configuration:${NC}"
echo -e "   Host: ${BLUE}$HOST${NC}"
echo -e "   Port: ${BLUE}$PORT${NC}"
echo -e "   Reload: ${BLUE}$RELOAD${NC}"
echo -e "   Log Level: ${BLUE}$LOG_LEVEL${NC}"
echo -e "   Workers: ${BLUE}$WORKERS${NC}"
echo -e "   Environment: ${BLUE}$ENV_FILE${NC}"
echo

echo -e "${GREEN}🌐 Server will be available at:${NC}"
echo -e "   ${BLUE}http://localhost:$PORT${NC}"
echo -e "   ${BLUE}http://localhost:$PORT/docs${NC} (API Documentation)"
echo -e "   ${BLUE}http://localhost:$PORT/health${NC} (Health Check)"
echo

echo -e "${GREEN}🎯 Starting server...${NC}"
echo -e "${YELLOW}Command: $FASTAPI_CMD${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo

# Start the server
exec $FASTAPI_CMD 