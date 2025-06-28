#!/bin/bash

set -e

# Parse args for -r/--reset
RESET=0
if [ "$1" = "-r" ] || [ "$1" = "--reset" ]; then
    RESET=1
fi

# Absolute path to your project root and nico script
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NICO_SCRIPT="$PROJECT_DIR/scripts/nico"
SYMLINK_TARGET="$HOME/.local/bin/nico"

# Detect user's shell rc file
SHELL_RC="$HOME/.bashrc"
[ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"
if [ -f "$HOME/.zshrc" ]; then SHELL_RC="$HOME/.zshrc"; fi

# Ensure .local/bin exists and is in PATH
mkdir -p "$HOME/.local/bin"
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_RC"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
        echo "Added ~/.local/bin to PATH in $SHELL_RC"
    fi
    export PATH="$HOME/.local/bin:$PATH"
fi

# Remove alias if exists, or if resetting
if grep -q "alias nico=" "$SHELL_RC"; then
    sed -i.bak '/alias nico=/d' "$SHELL_RC"
    echo "Removed old 'nico' alias from $SHELL_RC"
fi

# Remove old symlink if resetting or it already exists
if [ $RESET -eq 1 ]; then
    if [ -L "$SYMLINK_TARGET" ] || [ -f "$SYMLINK_TARGET" ]; then
        rm -f "$SYMLINK_TARGET"
        echo "Removed old symlink at $SYMLINK_TARGET"
    fi
fi

# Create symlink if not present (or after reset)
if [ ! -L "$SYMLINK_TARGET" ] && [ ! -f "$SYMLINK_TARGET" ]; then
    ln -s "$NICO_SCRIPT" "$SYMLINK_TARGET"
    chmod +x "$NICO_SCRIPT"
    echo "Symlink created: $SYMLINK_TARGET → $NICO_SCRIPT"
else
    echo "'$SYMLINK_TARGET' already exists. Use -r to reset and recreate."
fi

echo ""
echo "You can now run: nico <command> (e.g., nico verify, nico build, nico lint)"
echo "If you just set this up, restart your terminal or run: source $SHELL_RC"
echo ""
echo "To rerun this setup and force alias/symlink recreation, use:"
echo "    ./setup_nico.sh -r"
