#!/bin/bash

# latency-check: Network latency diagnostics
# Usage: latency-check

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SERVICES=(
    "google.com"
    "github.com"
    "registry.npmjs.org"
    "pypi.org"
    "docker.io"
    "cloudflare.com"
    "amazon.com"
)

show_help() {
    cat << EOF
Usage: latency-check

Pings common services and shows response times.
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

echo -e "${BLUE}Checking network latency...${NC}"

for service in "${SERVICES[@]}"; do
    if ping -c 1 -W 2 "$service" >/dev/null 2>&1; then
        latency=$(ping -c 3 -q "$service" | awk -F'/' '/^rtt/ {print $5}')
        echo -e "${GREEN}$service${NC}: ${latency} ms"
    else
        echo -e "${RED}$service${NC}: unreachable"
    fi
done 