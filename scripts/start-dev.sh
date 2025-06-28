#!/bin/bash

# start-dev.sh - Quick start script for local FastAPI development

set -e

echo "🚀 Starting Nicotine FastAPI in development mode..."

# Check if we're in the right directory
if [ ! -f "nicotine/api.py" ]; then
    echo "❌ Error: nicotine/api.py not found"
    echo "Please run this script from the nicotine project root directory"
    exit 1
fi

# Create .env from sample if it doesn't exist
if [ ! -f ".env" ] && [ -f "env.sample" ]; then
    echo "📝 Creating .env file from env.sample..."
    cp env.sample .env
    echo "⚠️  Please edit .env and add your OpenAI API key"
fi

# Load environment variables
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs) 2>/dev/null || true
fi

# Check if FastAPI CLI is installed
if ! command -v fastapi &> /dev/null; then
    echo "📦 Installing FastAPI CLI..."
    pip install "fastapi[standard]"
fi

echo "🌐 Server will be available at:"
echo "   http://localhost:8000"
echo "   http://localhost:8000/docs (API Documentation)"
echo "   http://localhost:8000/health (Health Check)"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Start the development server
fastapi dev nicotine/api.py 