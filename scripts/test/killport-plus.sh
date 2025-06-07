#!/bin/bash

# killport-plus: Kill process on a port with info and confirmation
# Usage: killport-plus [port]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << EOF
Usage: killport-plus [port]

Finds and kills the process using a given port, showing process info and asking for confirmation.

Examples:
    killport-plus 3000
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    show_help
    exit 0
fi

PORT="$1"

# Find process using the port
PID=$(lsof -ti :$PORT 2>/dev/null || netstat -nlp 2>/dev/null | grep ":$PORT" | awk '{print $7}' | cut -d'/' -f1 | head -n1)

if [ -z "$PID" ]; then
    echo -e "${RED}No process found on port $PORT${NC}"
    exit 1
fi

# Show process info
ps -p "$PID" -o pid,ppid,user,%cpu,%mem,etime,command

# Show open files (if possible)
lsof -p "$PID" 2>/dev/null | head -n 10

# Ask for confirmation
read -p "Kill process $PID on port $PORT? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
fi

kill -9 "$PID"
echo -e "${GREEN}Killed process $PID on port $PORT${NC}" 