#!/bin/bash

# watch-errors: Watches for new errors in logs and sends notifications
# Usage: watch-errors [file]

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << EOF
Usage: watch-errors [file]

Watches a log file for new errors and sends system notifications.

Examples:
    watch-errors app.log
    tail -f app.log | watch-errors
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

notify() {
    local msg="$1"
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Log Error" "$msg"
    elif command -v osascript >/dev/null 2>&1; then
        osascript -e "display notification \"$msg\" with title \"Log Error\""
    else
        echo -e "${RED}No notification system found. Error: $msg${NC}"
    fi
}

if [ -n "$1" ]; then
    tail -F "$1" | "$0"
    exit $?
fi

while IFS= read -r line; do
    if [[ "$line" =~ (ERROR|Error|error|FATAL|FAIL|Fail|fail|CRITICAL|Critical|critical) ]]; then
        echo -e "${RED}$line${NC}"
        notify "$line"
    elif [[ "$line" =~ (WARN|Warn|warn) ]]; then
        echo -e "${YELLOW}$line${NC}"
    else
        echo "$line"
    fi
done 