#!/bin/bash

set -e

# Function to detect if inside a virtualenv
is_venv_active() {
  [ -n "$VIRTUAL_ENV" ]
}

# Only create/activate .venv if not in a venv already
if is_venv_active; then
  echo "✅ Virtual environment already active: $VIRTUAL_ENV"
else
  if [ ! -d ".venv" ]; then
    echo "🔍 Creating a virtual environment (.venv)..."
    python3 -m venv .venv
  else
    echo "ℹ️  Using existing .venv"
  fi
  echo "🔗 Activating virtual environment..."
  # shellcheck disable=SC1091
  source .venv/bin/activate
fi

echo "⬇️  Installing project (in editable mode) and dependencies..."
pip install --upgrade pip
pip install -e .
pip install -r requirements-dev.txt 2>/dev/null || pip install -r requirements.txt

# Set up 'nico' command dispatcher
NICO_SCRIPT="$PWD/scripts/nico"
if [ ! -f "$NICO_SCRIPT" ]; then
  echo "⚠️  nico dispatcher not found at scripts/nico, skipping alias setup."
else
  # Add alias to shell rc file if not already present
  SHELL_RC="$HOME/.bashrc"
  [ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"
  if ! grep -q "alias nico=" "$SHELL_RC"; then
    echo "alias nico=\"$NICO_SCRIPT\"" >> "$SHELL_RC"
    echo "Alias 'nico' added to $SHELL_RC."
    ADDED_ALIAS=1
  else
    echo "Alias 'nico' already present in $SHELL_RC."
    ADDED_ALIAS=0
  fi
  chmod +x "$NICO_SCRIPT"
fi

echo ""
echo "✅ Nicotine is installed and ready."
if ! is_venv_active; then
  echo "To activate the virtual environment, run:"
  echo "   source .venv/bin/activate"
fi

echo ""
echo "To use Nicotine in Python, try:"
echo "   python"
echo "   >>> from nicotine.system import LLMSettings, LLMInput, detect_hallucination"
echo ""
if [ -f "$NICO_SCRIPT" ]; then
  echo "To use the nico CLI, restart your terminal or run: source $SHELL_RC"
  echo "Then try commands like:"
  echo "   nico verify"
  echo "   nico build"
  echo "   nico lint"
fi
