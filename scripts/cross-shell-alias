#!/bin/bash

# cross-shell-alias: Sync aliases/functions across bash, zsh, fish
# Usage: cross-shell-alias [--push|--pull|--list]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONFIG_DIR="$HOME/.config/wtf-tools"
ALIAS_FILE="$CONFIG_DIR/aliases.sh"
FISH_FILE="$CONFIG_DIR/aliases.fish"

show_help() {
    cat << EOF
Usage: cross-shell-alias [--push|--pull|--list]

Sync aliases/functions across bash, zsh, and fish shells.

Options:
    --push   Export current shell aliases to config
    --pull   Import aliases from config to all shells
    --list   Show synced aliases
    -h, --help  Show this help
EOF
}

case "$1" in
    -h|--help)
        show_help
        exit 0
        ;;
    --push)
        mkdir -p "$CONFIG_DIR"
        alias > "$ALIAS_FILE"
        echo -e "${GREEN}Aliases exported to $ALIAS_FILE${NC}"
        # Convert to fish format
        awk '/alias / {gsub("alias ","alias "); gsub("=", " "); print}' "$ALIAS_FILE" | sed "s/'//g" > "$FISH_FILE"
        echo -e "${GREEN}Fish aliases exported to $FISH_FILE${NC}"
        ;;
    --pull)
        # Bash/Zsh
        if [ -f "$ALIAS_FILE" ]; then
            for shellrc in "$HOME/.bashrc" "$HOME/.zshrc"; do
                if ! grep -q "$ALIAS_FILE" "$shellrc" 2>/dev/null; then
                    echo "source $ALIAS_FILE" >> "$shellrc"
                fi
            done
            echo -e "${GREEN}Aliases sourced in .bashrc and .zshrc${NC}"
        fi
        # Fish
        if [ -f "$FISH_FILE" ]; then
            mkdir -p "$HOME/.config/fish/functions"
            cp "$FISH_FILE" "$HOME/.config/fish/functions/wtf_aliases.fish"
            echo -e "${GREEN}Fish aliases installed${NC}"
        fi
        ;;
    --list)
        if [ -f "$ALIAS_FILE" ]; then
            cat "$ALIAS_FILE"
        else
            echo -e "${YELLOW}No aliases found in $ALIAS_FILE${NC}"
        fi
        ;;
    *)
        show_help
        exit 1
        ;;
esac 