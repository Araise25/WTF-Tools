#!/bin/bash

# venv-reset: Wipe and recreate Python virtualenv
# Usage: venv-reset [venv_dir]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << EOF
Usage: venv-reset [venv_dir]

Wipes and recreates a Python virtual environment, then reinstalls dependencies.

Examples:
    venv-reset           # Uses .venv or venv
    venv-reset myenv     # Uses myenv directory
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

VENV_DIR="${1:-.venv}"
[ -d "$VENV_DIR" ] || VENV_DIR="venv"

if [ ! -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}No existing virtualenv found, will create new one.${NC}"
else
    echo -e "${YELLOW}Removing existing virtualenv: $VENV_DIR${NC}"
    rm -rf "$VENV_DIR"
fi

python3 -m venv "$VENV_DIR"
echo -e "${GREEN}Created new virtualenv: $VENV_DIR${NC}"

if [ -f requirements.txt ]; then
    source "$VENV_DIR/bin/activate"
    pip install --upgrade pip
    pip install -r requirements.txt
    echo -e "${GREEN}Dependencies installed from requirements.txt${NC}"
    deactivate
fi 