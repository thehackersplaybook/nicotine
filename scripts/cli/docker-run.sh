#!/bin/bash

# docker-run.sh - Run Docker container for Nicotine service

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
IMAGE_NAME="nicotine"
TAG="latest"
CONTAINER_NAME="nicotine-service"
PORT="8000"
ENV_FILE=".env"
DETACHED=false
REMOVE_AFTER=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -n|--name)
            IMAGE_NAME="$2"
            shift 2
            ;;
        -c|--container-name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -e|--env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        -d|--detach)
            DETACHED=true
            shift
            ;;
        --rm)
            REMOVE_AFTER=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -t, --tag TAG              Set image tag (default: latest)"
            echo "  -n, --name NAME            Set image name (default: nicotine)"
            echo "  -c, --container-name NAME  Set container name (default: nicotine-service)"
            echo "  -p, --port PORT            Set port mapping (default: 8000)"
            echo "  -e, --env-file FILE        Set environment file (default: .env)"
            echo "  -d, --detach               Run container in background"
            echo "  --rm                       Remove container after exit"
            echo "  -h, --help                 Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"

# Check if image exists
if ! docker image inspect "$FULL_IMAGE_NAME" >/dev/null 2>&1; then
    echo -e "${RED}✗ Docker image ${FULL_IMAGE_NAME} not found${NC}"
    echo -e "${YELLOW}Run ./docker-build.sh first to build the image${NC}"
    exit 1
fi

# Stop and remove existing container if it exists
if docker ps -a --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}Stopping and removing existing container: ${CONTAINER_NAME}${NC}"
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
fi

# Build docker run command
DOCKER_ARGS=""

if [ "$DETACHED" = true ]; then
    DOCKER_ARGS="$DOCKER_ARGS -d"
fi

if [ "$REMOVE_AFTER" = true ]; then
    DOCKER_ARGS="$DOCKER_ARGS --rm"
fi

# Add environment file if it exists
if [ -f "$ENV_FILE" ]; then
    DOCKER_ARGS="$DOCKER_ARGS --env-file $ENV_FILE"
    echo -e "${GREEN}Using environment file: ${ENV_FILE}${NC}"
else
    echo -e "${YELLOW}Environment file ${ENV_FILE} not found, using default environment${NC}"
fi

echo -e "${YELLOW}Starting Docker container: ${CONTAINER_NAME}${NC}"
echo -e "${YELLOW}Image: ${FULL_IMAGE_NAME}${NC}"
echo -e "${YELLOW}Port mapping: ${PORT}:8000${NC}"

# Run the container
if docker run $DOCKER_ARGS \
    --name "$CONTAINER_NAME" \
    -p "${PORT}:8000" \
    "$FULL_IMAGE_NAME"; then
    
    if [ "$DETACHED" = true ]; then
        echo -e "${GREEN}✓ Container started successfully in background${NC}"
        echo -e "${GREEN}Access the API at: http://localhost:${PORT}${NC}"
        echo -e "${GREEN}API docs at: http://localhost:${PORT}/docs${NC}"
        echo -e "${YELLOW}To view logs: docker logs -f ${CONTAINER_NAME}${NC}"
        echo -e "${YELLOW}To stop: docker stop ${CONTAINER_NAME}${NC}"
    else
        echo -e "${GREEN}✓ Container finished${NC}"
    fi
else
    echo -e "${RED}✗ Failed to start container${NC}"
    exit 1
fi 