#!/bin/bash

# smart-find: Intelligent file search
# Usage: smart-find [pattern] [directory]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

EXCLUDES=(
    ".git"
    "node_modules"
    "__pycache__"
    ".venv"
    "venv"
    "env"
    ".mypy_cache"
    ".pytest_cache"
    ".ruff_cache"
    ".tox"
    ".idea"
    ".vscode"
    ".DS_Store"
)

show_help() {
    cat << EOF
Usage: smart-find [pattern] [directory]

Finds files with intelligent exclusions (node_modules, .git, etc.).

Examples:
    smart-find "*.js"           # Find all .js files
    smart-find "*.py" src/      # Find all .py files in src/
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    show_help
    exit 0
fi

PATTERN="$1"
DIR="${2:-.}"

FIND_CMD=(find "$DIR" -type f -name "$PATTERN")
for excl in "${EXCLUDES[@]}"; do
    FIND_CMD+=( -not -path "*/$excl/*" )
done

"${FIND_CMD[@]}" 