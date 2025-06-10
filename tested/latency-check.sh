#!/bin/bash

# latency-check: Network latency diagnostics tool
# Usage: latency-check [website_url]

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Developer Services
DEV_SERVICES=(
    "github.com"
    "gitlab.com"
    "bitbucket.org"
    "api.bitbucket.org"
    "registry.npmjs.org"
    "pypi.org"
    "registry-1.docker.io"
    "auth.docker.io"
    "stackoverflow.com"
    "developer.mozilla.org"
    "docs.microsoft.com"
)

# Basic Services
BASIC_SERVICES=(
    "google.com"
    "cloudflare.com"
    "amazon.com"
    "microsoft.com"
    "apple.com"
    "facebook.com"
    "twitter.com"
    "linkedin.com"
)

show_help() {
    cat << EOF
Usage: $(basename "$0") [website_url]

Pings services and shows response times.
If a website URL is provided, only that website will be tested.
Otherwise, tests a list of common services including:
- Developer services (Git platforms, package registries, documentation)
- Basic services (Major tech companies and social platforms)

Examples:
  $(basename "$0")              # Test all default services
  $(basename "$0") example.com  # Test only example.com
EOF
}

# Check if a value exists in an array
in_array() {
    local item=$1
    shift
    for e in "$@"; do [[ "$e" == "$item" ]] && return 0; done
    return 1
}

# Check latency using curl for specific services
check_latency_curl() {
    local service=$1
    local url="https://$service"
    local headers=()
    
    case "$service" in
        "registry-1.docker.io")
            url="https://registry-1.docker.io/v2/"
            headers=(-H "Accept: application/vnd.docker.distribution.manifest.v2+json")
            ;;
        "auth.docker.io")
            url="https://auth.docker.io/token"
            headers=(-H "Accept: application/json")
            ;;
        "bitbucket.org"|"api.bitbucket.org")
            url="https://$service/2.0/repositories"
            headers=(-H "Accept: application/json")
            ;;
    esac

    local start_time
    start_time=$(date +%s.%N)
    if curl -s -o /dev/null -w "%{http_code}" "${headers[@]}" "$url" > /dev/null 2>&1; then
        local end_time
        end_time=$(date +%s.%N)
        local latency
        latency=$(echo "($end_time - $start_time) * 1000" | bc)
        printf "${GREEN}%-25s${NC}: %6.3f ms\n" "$service" "$latency"
    else
        printf "${RED}%-25s${NC}: unreachable\n" "$service"
    fi
}

# Ping and get latency
check_latency() {
    local service=$1
    
    # Use curl for specific services
    if [[ "$service" == "registry-1.docker.io" ]] || \
       [[ "$service" == "auth.docker.io" ]] || \
       [[ "$service" == "bitbucket.org" ]] || \
       [[ "$service" == "api.bitbucket.org" ]]; then
        check_latency_curl "$service"
        return
    fi

    if ping -c 1 -W 2 "$service" >/dev/null 2>&1; then
        local latency
        latency=$(ping -c 3 -q "$service" | awk -F'/' '/^rtt/ {print $5}')
        if [[ -n "$latency" ]]; then
            printf "${GREEN}%-25s${NC}: %6.3f ms\n" "$service" "$latency"
        else
            printf "${RED}%-25s${NC}: error getting latency\n" "$service"
        fi
    else
        printf "${RED}%-25s${NC}: unreachable\n" "$service"
    fi
}

# Parse args
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    show_help
    exit 0
fi

# Handle custom service check
if [[ -n "${1:-}" ]]; then
    input="$1"
    if ! in_array "$input" "${DEV_SERVICES[@]}" "${BASIC_SERVICES[@]}"; then
        SERVICES=("$input")
    else
        SERVICES=("$input")
    fi
else
    SERVICES=("${DEV_SERVICES[@]}" "${BASIC_SERVICES[@]}")
fi

# Output banner
echo -e "${BLUE}Checking network latency...${NC}"

# Run checks
if [[ -z "${1:-}" ]]; then
    echo -e "\n${YELLOW}Developer Services:${NC}"
    for svc in "${DEV_SERVICES[@]}"; do check_latency "$svc"; done

    echo -e "\n${YELLOW}Basic Services:${NC}"
    for svc in "${BASIC_SERVICES[@]}"; do check_latency "$svc"; done
else
    for svc in "${SERVICES[@]}"; do check_latency "$svc"; done
fi
