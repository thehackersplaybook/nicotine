#!/bin/bash
echo "Available CLI commands:"
ls -1 "$(dirname "$0")" | grep '.sh$' | grep -v 'help.sh' | sed 's/\.sh$//'
echo ""
echo "Run any with: ./scripts/cli/<command>.sh"