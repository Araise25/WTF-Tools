#!/bin/bash

# WTF-Tools Installation Script
# Installs all WTF-Tools to make them available in your PATH

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# List of all tools to install
TOOLS=(
    "zombie-killer"
    "guess-dependency-manager"
    "postmortem"
    "killport-plus"
    "tail-highlight"
    "latency-check"
    "stash-manager"
    "ssh-key-manager"
    "build-cache-manager"
    "book"
)

# Create installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Check if installation directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}Warning:${NC} $INSTALL_DIR is not in your PATH"
    echo -e "Add the following line to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    echo -e "${BLUE}export PATH=\"\$PATH:$INSTALL_DIR\"${NC}"
    echo
fi

# Install each tool
echo -e "${BLUE}Installing WTF-Tools...${NC}"
for tool in "${TOOLS[@]}"; do
    source_file="$SCRIPT_DIR/scripts/$tool.sh"
    target_file="$INSTALL_DIR/$tool"
    
    if [ -f "$source_file" ]; then
        cp "$source_file" "$target_file"
        chmod +x "$target_file"
        echo -e "${GREEN}✓${NC} Installed $tool"
    else
        echo -e "${RED}✗${NC} Could not find $tool.sh"
    fi
done

echo
echo -e "${GREEN}Installation complete!${NC}"
echo -e "You can now use the following commands:"
for tool in "${TOOLS[@]}"; do
    echo -e "  ${BLUE}$tool${NC}"
done

echo
echo -e "${YELLOW}Note:${NC} If this is your first time running these tools,"
echo -e "you may need to restart your terminal or run: ${BLUE}source ~/.bashrc${NC} (or your shell's config file)"