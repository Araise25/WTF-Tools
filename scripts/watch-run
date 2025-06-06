#!/bin/bash

# watch-run: Watch files and re-run commands on changes
# Usage: watch-run [path] [command]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
WATCH_PATH="."
COMMAND=""
DELAY="${WTF_WATCH_RUN_DELAY:-1}"
IGNORE_PATTERNS=(
    ".git"
    "node_modules"
    "__pycache__"
    "*.pyc"
    "*.pyo"
    "*.pyd"
    ".pytest_cache"
    ".coverage"
    "*.so"
    "*.o"
    "*.a"
    "*.swp"
    "*.swo"
    "*~"
)

# Help message
show_help() {
    cat << EOF
Usage: watch-run [path] [command]

Watch files for changes and re-run a command when changes are detected.

Options:
    path            Path to watch (default: current directory)
    command         Command to run on changes

Environment variables:
    WTF_WATCH_RUN_DELAY    Delay between checks in seconds (default: 1)

Examples:
    watch-run src/ "npm test"           # Watch src/ directory and run tests
    watch-run . "python app.py"         # Watch current directory and run Python app
    watch-run docs/ "mkdocs serve"      # Watch docs/ and serve documentation
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            if [ -z "$WATCH_PATH" ]; then
                WATCH_PATH="$1"
            elif [ -z "$COMMAND" ]; then
                COMMAND="$1"
            else
                echo -e "${RED}Error:${NC} Too many arguments"
                show_help
                exit 1
            fi
            ;;
    esac
    shift
done

# Validate arguments
if [ -z "$COMMAND" ]; then
    echo -e "${RED}Error:${NC} No command specified"
    show_help
    exit 1
fi

if [ ! -e "$WATCH_PATH" ]; then
    echo -e "${RED}Error:${NC} Path '$WATCH_PATH' does not exist"
    exit 1
fi

# Build ignore pattern for find
IGNORE_PATTERN=""
for pattern in "${IGNORE_PATTERNS[@]}"; do
    IGNORE_PATTERN="$IGNORE_PATTERN -not -path '*/$pattern/*' -not -name '$pattern'"
done

# Function to get file hashes
get_file_hashes() {
    eval "find \"$WATCH_PATH\" -type f $IGNORE_PATTERN" | xargs md5sum 2>/dev/null || true
}

# Initial file hashes
echo -e "${BLUE}Watching $WATCH_PATH for changes...${NC}"
echo -e "${BLUE}Running: $COMMAND${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo

# Run command initially
eval "$COMMAND"

# Watch loop
while true; do
    # Get current file hashes
    current_hashes=$(get_file_hashes)
    
    # Wait for changes
    sleep "$DELAY"
    
    # Get new file hashes
    new_hashes=$(get_file_hashes)
    
    # Compare hashes
    if [ "$current_hashes" != "$new_hashes" ]; then
        echo -e "\n${GREEN}Changes detected!${NC}"
        echo -e "${BLUE}Running: $COMMAND${NC}"
        
        # Run command
        eval "$COMMAND"
        
        # Update current hashes
        current_hashes="$new_hashes"
    fi
done 