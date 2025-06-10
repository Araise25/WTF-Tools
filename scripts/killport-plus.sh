#!/bin/bash

# killport-plus: Kill process on a port with info and confirmation
# Usage: killport-plus [port]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

echo -e "${BLUE}Searching for processes on port $PORT...${NC}"

# Try to get process info with netstat
PROCESSES=$(netstat -nlp 2>/dev/null | grep ":$PORT")

if [ -z "$PROCESSES" ]; then
    echo -e "${RED}No process found using port $PORT${NC}"
    exit 1
fi

# Extract PID from netstat output
PID=$(echo "$PROCESSES" | awk '{print $7}' | cut -d'/' -f1 | head -n1)

if [ -z "$PID" ]; then
    echo -e "${RED}Could not determine process ID${NC}"
    echo -e "${YELLOW}Debug information:${NC}"
    echo "$PROCESSES"
    exit 1
fi

# Verify the process still exists
if ! ps -p "$PID" > /dev/null 2>&1; then
    echo -e "${RED}Process $PID no longer exists${NC}"
    exit 1
fi

# Show process info
echo -e "${BLUE}Process information:${NC}"
ps -p "$PID" -o pid,ppid,user,%cpu,%mem,etime,command 2>/dev/null || {
    echo -e "${YELLOW}Could not get detailed process information, but process exists${NC}"
    echo "PID: $PID"
}

# Show port connections
echo -e "\n${BLUE}Port connections:${NC}"
echo "$PROCESSES"

# Show open files (if possible)
echo -e "\n${BLUE}Open files:${NC}"
lsof -p "$PID" 2>/dev/null | head -n 10 || echo -e "${YELLOW}Could not get open files information${NC}"

# Ask for confirmation
read -p "$(echo -e ${CYAN}Kill process $PID on port $PORT? [y/N] ${NC})" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
fi

# Try to kill the process
if kill -9 "$PID" 2>/dev/null; then
    echo -e "${GREEN}Killed process $PID on port $PORT${NC}"
else
    echo -e "${RED}Failed to kill process $PID${NC}"
    exit 1
fi 