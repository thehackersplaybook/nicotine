#!/bin/bash

# docker-manage.sh - Manage Docker containers for Nicotine service

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
CONTAINER_NAME="nicotine-service"

# Show help
show_help() {
    echo "Usage: $0 COMMAND [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start    Start the container"
    echo "  stop     Stop the container"
    echo "  restart  Restart the container"
    echo "  logs     Show container logs"
    echo "  status   Show container status"
    echo "  shell    Open shell in container"
    echo "  clean    Stop and remove container"
    echo ""
    echo "Options:"
    echo "  -c, --container-name NAME  Container name (default: nicotine-service)"
    echo "  -f, --follow              Follow logs (for logs command)"
    echo "  -h, --help                Show this help message"
}

# Parse command line arguments
COMMAND=""
FOLLOW_LOGS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        start|stop|restart|logs|status|shell|clean)
            COMMAND="$1"
            shift
            ;;
        -c|--container-name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -f|--follow)
            FOLLOW_LOGS=true
            shift
            ;;
        -h|--help)
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

if [ -z "$COMMAND" ]; then
    echo -e "${RED}✗ No command specified${NC}"
    show_help
    exit 1
fi

# Check if container exists
container_exists() {
    docker ps -a --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"
}

# Check if container is running
container_running() {
    docker ps --format "table {{.Names}}" | grep -q "^${CONTAINER_NAME}$"
}

case $COMMAND in
    start)
        if container_exists; then
            if container_running; then
                echo -e "${YELLOW}Container ${CONTAINER_NAME} is already running${NC}"
            else
                echo -e "${YELLOW}Starting container: ${CONTAINER_NAME}${NC}"
                docker start "$CONTAINER_NAME"
                echo -e "${GREEN}✓ Container started${NC}"
            fi
        else
            echo -e "${RED}✗ Container ${CONTAINER_NAME} does not exist${NC}"
            echo -e "${YELLOW}Run ./docker-run.sh to create and start the container${NC}"
            exit 1
        fi
        ;;
    
    stop)
        if container_running; then
            echo -e "${YELLOW}Stopping container: ${CONTAINER_NAME}${NC}"
            docker stop "$CONTAINER_NAME"
            echo -e "${GREEN}✓ Container stopped${NC}"
        else
            echo -e "${YELLOW}Container ${CONTAINER_NAME} is not running${NC}"
        fi
        ;;
    
    restart)
        if container_exists; then
            echo -e "${YELLOW}Restarting container: ${CONTAINER_NAME}${NC}"
            docker restart "$CONTAINER_NAME"
            echo -e "${GREEN}✓ Container restarted${NC}"
        else
            echo -e "${RED}✗ Container ${CONTAINER_NAME} does not exist${NC}"
            exit 1
        fi
        ;;
    
    logs)
        if container_exists; then
            echo -e "${YELLOW}Showing logs for container: ${CONTAINER_NAME}${NC}"
            if [ "$FOLLOW_LOGS" = true ]; then
                docker logs -f "$CONTAINER_NAME"
            else
                docker logs "$CONTAINER_NAME"
            fi
        else
            echo -e "${RED}✗ Container ${CONTAINER_NAME} does not exist${NC}"
            exit 1
        fi
        ;;
    
    status)
        if container_exists; then
            echo -e "${BLUE}Container Status:${NC}"
            docker ps -a --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
            
            if container_running; then
                echo -e "${GREEN}✓ Container is running${NC}"
                echo -e "${BLUE}Container stats:${NC}"
                docker stats --no-stream "$CONTAINER_NAME"
            else
                echo -e "${YELLOW}Container exists but is not running${NC}"
            fi
        else
            echo -e "${RED}✗ Container ${CONTAINER_NAME} does not exist${NC}"
        fi
        ;;
    
    shell)
        if container_running; then
            echo -e "${YELLOW}Opening shell in container: ${CONTAINER_NAME}${NC}"
            docker exec -it "$CONTAINER_NAME" /bin/bash
        else
            echo -e "${RED}✗ Container ${CONTAINER_NAME} is not running${NC}"
            exit 1
        fi
        ;;
    
    clean)
        if container_exists; then
            echo -e "${YELLOW}Stopping and removing container: ${CONTAINER_NAME}${NC}"
            docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
            docker rm "$CONTAINER_NAME"
            echo -e "${GREEN}✓ Container removed${NC}"
        else
            echo -e "${YELLOW}Container ${CONTAINER_NAME} does not exist${NC}"
        fi
        ;;
esac 