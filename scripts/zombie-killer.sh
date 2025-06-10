#!/bin/bash

# zombie-killer: Detect and optionally terminate orphaned or zombie-like dev processes

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# Parse command line arguments
DRY_RUN=false
FORCE=false
GRACE_PERIOD=300  # Default 5 minutes

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true ;;
        --force) FORCE=true ;;
        --grace) GRACE_PERIOD="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo -e "${GREEN}🔍 Scanning for zombie-like or orphaned dev processes...${NC}"
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}⚠️  DRY RUN MODE: No processes will be killed${NC}"
fi

KEYWORDS=("node" "python" "gunicorn" "uvicorn" "php" "ruby" "docker" "npm" "yarn" "next" "vite")
FOUND_PROCS=()

# Header
printf "\n%-6s %-6s %-6s %-6s %-6s %-40s\n" "PID" "PPID" "STAT" "CPU%" "MEM%" "COMMAND"
echo "--------------------------------------------------------------------------------------------"

# Collect matching processes
while read -r pid ppid stat cpu mem cmd; do
    if [[ "$stat" =~ Z || "$ppid" -eq 1 ]]; then
        printf "%-6s %-6s %-6s %-6s %-6s %-40s\n" "$pid" "$ppid" "$stat" "$cpu" "$mem" "$cmd"
        FOUND_PROCS+=("$pid|$ppid|$stat|$cpu|$mem|$cmd")
    fi
done < <(ps -eo pid=,ppid=,stat=,%cpu=,%mem=,command= | grep -Ei "$(IFS=\|; echo "${KEYWORDS[*]}")" | grep -v "grep" | grep -v "zombie-killer")

# Check if anything found
if [ "${#FOUND_PROCS[@]}" -eq 0 ]; then
    echo -e "${GREEN}🎉 No zombie or orphaned processes found.${NC}"
    exit 0
fi

echo -e "\n${YELLOW}⚠️  Found ${#FOUND_PROCS[@]} suspicious process(es).${NC}"

# Handle processes based on mode
if [ "$DRY_RUN" = true ]; then
    echo -e "\n${CYAN}📋 Would kill the following processes:${NC}"
    for entry in "${FOUND_PROCS[@]}"; do
        IFS='|' read -r pid ppid stat cpu mem cmd <<< "$entry"
        echo -e "${CYAN}🔎 PID: $pid | PPID: $ppid | STAT: $stat | CPU: $cpu | MEM: $mem${NC}"
        echo "   → $cmd"
    done
elif [ "$FORCE" = true ]; then
    echo -e "\n${YELLOW}⚠️  FORCE MODE: Killing all processes without confirmation${NC}"
    for entry in "${FOUND_PROCS[@]}"; do
        IFS='|' read -r pid ppid stat cpu mem cmd <<< "$entry"
        kill -9 "$pid" && echo -e "${GREEN}✅ Killed $pid${NC}" || echo -e "${RED}❌ Failed to kill $pid${NC}"
    done
else
    # Interactive mode
    for entry in "${FOUND_PROCS[@]}"; do
        IFS='|' read -r pid ppid stat cpu mem cmd <<< "$entry"
        echo -e "\n${CYAN}🔎 PID: $pid | PPID: $ppid | STAT: $stat | CPU: $cpu | MEM: $mem${NC}"
        echo "   → $cmd"

        read -rp "❓ Do you want to kill this process? [y/N]: " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            kill -9 "$pid" && echo -e "${GREEN}✅ Killed $pid${NC}" || echo -e "${RED}❌ Failed to kill $pid${NC}"
        else
            echo -e "${YELLOW}⏭️  Skipped $pid${NC}"
        fi
    done
fi

echo -e "\n${GREEN}✅ zombie-killer finished.${NC}"
