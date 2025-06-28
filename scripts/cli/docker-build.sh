#!/bin/bash

# docker-build.sh - Build Docker image for Nicotine service

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
IMAGE_NAME="nicotine"
TAG="latest"
BUILD_TARGET="production"
NO_CACHE=false

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
        --dev|--development)
            BUILD_TARGET="development"
            shift
            ;;
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -t, --tag TAG        Set image tag (default: latest)"
            echo "  -n, --name NAME      Set image name (default: nicotine)"
            echo "  --dev, --development Build development image"
            echo "  --no-cache           Build without cache"
            echo "  -h, --help           Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Build options
BUILD_ARGS=""
if [ "$NO_CACHE" = true ]; then
    BUILD_ARGS="--no-cache"
fi

FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"

echo -e "${YELLOW}Building Docker image: ${FULL_IMAGE_NAME}${NC}"
echo -e "${YELLOW}Target: ${BUILD_TARGET}${NC}"

# Build the Docker image
if docker build $BUILD_ARGS --target "$BUILD_TARGET" -t "$FULL_IMAGE_NAME" .; then
    echo -e "${GREEN}✓ Docker image built successfully: ${FULL_IMAGE_NAME}${NC}"
    
    # Show image details
    echo -e "${YELLOW}Image details:${NC}"
    docker images "$IMAGE_NAME" --filter "reference=${FULL_IMAGE_NAME}"
else
    echo -e "${RED}✗ Docker build failed${NC}"
    exit 1
fi 