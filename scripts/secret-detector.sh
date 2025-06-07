#!/bin/bash

# secret-detector: Scan for secrets in codebase
# Usage: secret-detector [directory]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PATTERNS="${WTF_SECRET_DETECTOR_PATTERNS:-aws_key|api_key|secret|token|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z\-_]{35}|sk_live_[0-9a-zA-Z]{24}|ghp_[0-9a-zA-Z]{36}}"
TARGET_DIR="${1:-.}"

show_help() {
    cat << EOF
Usage: secret-detector [directory]

Greps for hardcoded tokens, AWS keys, API secrets in any directory.

Examples:
    secret-detector           # Scan current directory
    secret-detector src/      # Scan src/ directory
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

echo -e "${BLUE}Scanning $TARGET_DIR for secrets...${NC}"

# Exclude common directories
EXCLUDES="--exclude-dir=.git --exclude-dir=node_modules --exclude-dir=__pycache__ --exclude-dir=.venv --exclude-dir=venv --exclude-dir=env"

# Run grep
matches=$(grep -rEIn $EXCLUDES --color=never "$PATTERNS" "$TARGET_DIR" || true)

if [ -z "$matches" ]; then
    echo -e "${GREEN}No secrets found.${NC}"
    exit 0
fi

echo -e "${RED}Potential secrets found:${NC}"
echo "$matches"
exit 1 