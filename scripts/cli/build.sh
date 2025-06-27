#!/bin/bash

# Exit if any command fails
set -e

# Ensure the build tool is installed
if ! python -m pip show build > /dev/null 2>&1; then
  echo "Installing build tool (python -m pip install build)..."
  python -m pip install build
fi

# Clean previous builds
rm -rf dist/ build/ *.egg-info

# Build both sdist and wheel using PEP 517 build backend
python -m build

echo "✅ Nicotine package built successfully. See ./dist for output files."
