#!/bin/bash

# Absolute path to your project (edit if needed)
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Where the nico dispatcher lives
NICO_SCRIPT="$PROJECT_DIR/scripts/nico"

# Where to put the alias (user shell config)
SHELL_RC="$HOME/.bashrc"
[ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"

# Add alias only if not present
if ! grep -q "alias nico=" "$SHELL_RC"; then
    echo "alias nico=\"$NICO_SCRIPT\"" >> "$SHELL_RC"
    echo "Alias 'nico' added to $SHELL_RC. Please restart your terminal or run: source $SHELL_RC"
else
    echo "Alias 'nico' already present in $SHELL_RC"
fi

# Optional: Show help
echo ""
echo "You can now run: nico <command> (e.g., nico verify, nico build, nico lint)"
