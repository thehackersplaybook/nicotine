#!/bin/bash

# Usage: source exportenv [.env_file]
# Default .env_file is ".env" in the current directory.

ENV_FILE="${1:-.env}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: File '$ENV_FILE' does not exist."
  return 1 2>/dev/null || exit 1
fi

# Export all variables in the .env file
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

echo "Exported environment variables from $ENV_FILE"
