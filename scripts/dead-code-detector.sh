#!/bin/bash

# dead-code-detector: Finds unused functions, imports, and variables
# Usage: dead-code-detector [directory]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << EOF
Usage: dead-code-detector [directory]

Finds unused functions, imports, and variables (basic heuristics, language-agnostic).

Examples:
    dead-code-detector src/
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

DIR="${1:-.}"

# Find all function/def/class definitions and variable assignments
candidates=$(grep -rEn --include='*.py' --include='*.js' --include='*.ts' --include='*.sh' --include='*.rb' --include='*.go' --include='*.java' --include='*.php' --include='*.c' --include='*.cpp' --include='*.h' --exclude-dir={.git,node_modules,__pycache__,.venv,venv,env,.mypy_cache,.pytest_cache,.ruff_cache,.tox,.idea,.vscode} \
    -e '^[[:space:]]*def[[:space:]]+[a-zA-Z0-9_]+\(' \
    -e '^[[:space:]]*function[[:space:]]+[a-zA-Z0-9_]+\(' \
    -e '^[[:space:]]*class[[:space:]]+[a-zA-Z0-9_]+[[:space:]]*' \
    -e '^[[:space:]]*[a-zA-Z0-9_]+[[:space:]]*=' \
    "$DIR" 2>/dev/null)

if [ -z "$candidates" ]; then
    echo -e "${GREEN}No candidate dead code found.${NC}"
    exit 0
fi

echo "$candidates" | while IFS=: read -r file line content; do
    # Extract symbol name
    if [[ "$content" =~ def[[:space:]]+([a-zA-Z0-9_]+)\( ]]; then
        symbol="${BASH_REMATCH[1]}"
    elif [[ "$content" =~ function[[:space:]]+([a-zA-Z0-9_]+)\( ]]; then
        symbol="${BASH_REMATCH[1]}"
    elif [[ "$content" =~ class[[:space:]]+([a-zA-Z0-9_]+) ]]; then
        symbol="${BASH_REMATCH[1]}"
    elif [[ "$content" =~ ^[[:space:]]*([a-zA-Z0-9_]+)[[:space:]]*= ]]; then
        symbol="${BASH_REMATCH[1]}"
    else
        continue
    fi
    # Search for symbol usage (excluding definition line)
    if ! grep -rEq --exclude-dir={.git,node_modules,__pycache__,.venv,venv,env,.mypy_cache,.pytest_cache,.ruff_cache,.tox,.idea,.vscode} "\b$symbol\b" "$DIR" | grep -v "$file:$line" >/dev/null; then
        echo -e "${YELLOW}Possibly unused: $symbol ($file:$line)${NC}"
    fi
done 