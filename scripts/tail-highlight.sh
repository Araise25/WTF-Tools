#!/bin/bash

# tail-highlight: Colorized log tailing
# Usage: tail-highlight [file]

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << EOF
Usage: tail-highlight [file]

Tails a log file and highlights error/warning/failure keywords in color.

Examples:
    tail-highlight app.log
    tail -f app.log | tail-highlight
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

if [ -n "$1" ]; then
    tail -f "$1" | "$0"
    exit $?
fi

# Read from stdin and colorize
while IFS= read -r line; do
    if [[ "$line" =~ (ERROR|Error|error|FATAL|FAIL|Fail|fail|CRITICAL|Critical|critical) ]]; then
        echo -e "${RED}$line${NC}"
    elif [[ "$line" =~ (WARN|Warn|warn) ]]; then
        echo -e "${YELLOW}$line${NC}"
    elif [[ "$line" =~ (INFO|Info|info) ]]; then
        echo -e "${BLUE}$line${NC}"
    else
        echo "$line"
    fi
done 