#!/bin/bash

# zombie-killer: Detect and terminate orphaned processes
# Usage: zombie-killer [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
GRACE_PERIOD="${WTF_ZOMBIE_KILLER_GRACE_PERIOD:-300}"  # 5 minutes
FORCE=false
DRY_RUN=false

# Common development process patterns
DEV_PATTERNS=(
    "node"
    "python"
    "ruby"
    "java"
    "php"
    "go"
    "rust"
    "docker"
    "kubectl"
    "npm"
    "yarn"
    "pnpm"
    "pip"
    "poetry"
    "gradle"
    "maven"
    "sbt"
    "cargo"
    "mix"
    "rails"
    "jekyll"
    "hugo"
    "gatsby"
    "next"
    "webpack"
    "vite"
    "parcel"
    "rollup"
    "esbuild"
    "tsc"
    "babel"
    "jest"
    "pytest"
    "mocha"
    "karma"
    "cypress"
    "selenium"
    "chromedriver"
    "geckodriver"
)

# Help message
show_help() {
    cat << EOF
Usage: zombie-killer [options]

Detect and terminate orphaned development processes.

Options:
    -f, --force           Force kill without confirmation
    -d, --dry-run         Show what would be killed without actually killing
    -g, --grace N         Grace period in seconds (default: 300)
    -h, --help            Show this help message

Environment variables:
    WTF_ZOMBIE_KILLER_GRACE_PERIOD    Grace period in seconds (default: 300)

Examples:
    zombie-killer                     # Interactive mode
    zombie-killer --force            # Force kill without confirmation
    zombie-killer --dry-run          # Show what would be killed
    zombie-killer --grace 600        # Set grace period to 10 minutes
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -g|--grace)
            GRACE_PERIOD="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Error:${NC} Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Function to get process info
get_process_info() {
    local pid=$1
    ps -p "$pid" -o pid,ppid,user,%cpu,%mem,vsz,rss,stat,start,time,command 2>/dev/null
}

# Function to check if process is a development process
is_dev_process() {
    local cmd=$1
    for pattern in "${DEV_PATTERNS[@]}"; do
        if [[ "$cmd" =~ $pattern ]]; then
            return 0
        fi
    done
    return 1
}

# Function to check if process is orphaned
is_orphaned() {
    local pid=$1
    local ppid=$2
    local start_time=$3
    
    # Check if parent process exists
    if ! ps -p "$ppid" >/dev/null 2>&1; then
        # Check if process has been running longer than grace period
        local current_time=$(date +%s)
        local process_start=$(date -d "$start_time" +%s 2>/dev/null || date -j -f "%b %d %H:%M" "$start_time" +%s 2>/dev/null)
        local runtime=$((current_time - process_start))
        
        if [ "$runtime" -gt "$GRACE_PERIOD" ]; then
            return 0
        fi
    fi
    return 1
}

# Get list of processes
echo -e "${BLUE}Scanning for orphaned processes...${NC}"

# Get all processes
mapfile -t processes < <(ps aux | grep -v "grep" | grep -v "zombie-killer")

# Track found zombies
zombies=()

# Check each process
for process in "${processes[@]}"; do
    # Parse process info
    pid=$(echo "$process" | awk '{print $2}')
    ppid=$(ps -o ppid= -p "$pid" 2>/dev/null)
    start_time=$(ps -o lstart= -p "$pid" 2>/dev/null)
    cmd=$(echo "$process" | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}')
    
    # Skip if not a development process
    if ! is_dev_process "$cmd"; then
        continue
    fi
    
    # Check if orphaned
    if is_orphaned "$pid" "$ppid" "$start_time"; then
        zombies+=("$pid:$cmd")
    fi
done

# Handle found zombies
if [ ${#zombies[@]} -eq 0 ]; then
    echo -e "${GREEN}No orphaned processes found${NC}"
    exit 0
fi

# Show found zombies
echo -e "\n${YELLOW}Found ${#zombies[@]} orphaned processes:${NC}"
for zombie in "${zombies[@]}"; do
    pid=$(echo "$zombie" | cut -d: -f1)
    cmd=$(echo "$zombie" | cut -d: -f2-)
    echo -e "${RED}PID: $pid${NC}"
    echo -e "Command: $cmd"
    echo
done

# Handle dry run
if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}Dry run - no processes were killed${NC}"
    exit 0
fi

# Handle force kill
if [ "$FORCE" = true ]; then
    for zombie in "${zombies[@]}"; do
        pid=$(echo "$zombie" | cut -d: -f1)
        echo -e "${YELLOW}Killing PID $pid...${NC}"
        kill -9 "$pid" 2>/dev/null || true
    done
    echo -e "${GREEN}All orphaned processes terminated${NC}"
    exit 0
fi

# Interactive mode
echo -e "${YELLOW}Do you want to kill these processes? [y/N]${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    for zombie in "${zombies[@]}"; do
        pid=$(echo "$zombie" | cut -d: -f1)
        echo -e "${YELLOW}Killing PID $pid...${NC}"
        kill -9 "$pid" 2>/dev/null || true
    done
    echo -e "${GREEN}All orphaned processes terminated${NC}"
else
    echo -e "${BLUE}Operation cancelled${NC}"
fi 