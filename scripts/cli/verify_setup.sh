#!/bin/bash

FILES=("requirements.txt" "requirements-dev.txt")
MISSING=()

# Map pip package names to import names (extend as needed)
map_import_name() {
  case "$1" in
    python_dotenv) echo "dotenv" ;;
    fastapi) echo "fastapi" ;;
    uvicorn) echo "uvicorn" ;;
    openai) echo "openai" ;;
    pytest) echo "pytest" ;;
    mypy) echo "mypy" ;;
    flake8) echo "flake8" ;;
    bandit) echo "bandit" ;;
    *) echo "$1" ;;
  esac
}

# Extract all packages (ignoring comments, blank lines, and -r includes)
get_packages() {
  grep -hvE '^\s*#|^\s*$|^-r' ${FILES[@]} 2>/dev/null | \
  cut -d'[' -f1 | cut -d'<' -f1 | cut -d'=' -f1 | tr '-' '_' | sort -u
}

PACKAGES=$(get_packages)

for pkg in $PACKAGES; do
  import_name=$(map_import_name "$pkg")
  python -c "import $import_name" 2>/dev/null
  if [ $? -ne 0 ]; then
    MISSING+=("$pkg")
  fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "✅ All required packages are installed."
else
  echo "❌ Missing packages: ${MISSING[*]}"
fi
