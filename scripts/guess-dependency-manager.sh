#!/bin/bash

# guess-dependency-manager: Smart dependency manager detection
# Usage: guess-dependency-manager [command]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Package manager detection patterns
PACKAGE_MANAGERS=(
    # Node.js
    "package.json:npm:yarn:pnpm"
    "yarn.lock:yarn"
    "pnpm-lock.yaml:pnpm"
    # Python
    "requirements.txt:pip"
    "pyproject.toml:poetry"
    "Pipfile:pipenv"
    "setup.py:pip"
    # Ruby
    "Gemfile:bundler"
    # PHP
    "composer.json:composer"
    # Go
    "go.mod:go"
    # Rust
    "Cargo.toml:cargo"
    # Java
    "pom.xml:maven"
    "build.gradle:gradle"
    # Elixir
    "mix.exs:mix"
    # .NET
    "*.csproj:dotnet"
    "*.fsproj:dotnet"
    "*.vbproj:dotnet"
)

# Help message
show_help() {
    cat << EOF
Usage: guess-dependency-manager [command]

Intelligently detect and use the appropriate package manager for a project.

Options:
    command         Command to run with the detected package manager
                   (e.g., install, update, build)

Examples:
    guess-dependency-manager install    # Run install with detected manager
    guess-dependency-manager update     # Run update with detected manager
    guess-dependency-manager build      # Run build with detected manager
EOF
}

# Parse arguments
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

COMMAND="$1"

# Function to check if a file exists
file_exists() {
    local pattern=$1
    if [[ "$pattern" == *"*"* ]]; then
        compgen -G "$pattern" >/dev/null
    else
        [ -f "$pattern" ]
    fi
}

# Function to get package manager for a file
get_package_manager() {
    local file=$1
    local managers=$2
    IFS=':' read -ra MANAGER_ARRAY <<< "$managers"
    
    # Check if file exists
    if file_exists "$file"; then
        # Return first manager if multiple are specified
        echo "${MANAGER_ARRAY[0]}"
        return 0
    fi
    
    # Check alternative managers
    for ((i=1; i<${#MANAGER_ARRAY[@]}; i++)); do
        local alt_file
        case "${MANAGER_ARRAY[$i]}" in
            "yarn")
                alt_file="yarn.lock"
                ;;
            "pnpm")
                alt_file="pnpm-lock.yaml"
                ;;
            *)
                continue
                ;;
        esac
        
        if file_exists "$alt_file"; then
            echo "${MANAGER_ARRAY[$i]}"
            return 0
        fi
    done
    
    return 1
}

# Detect package manager
detected_manager=""
for pattern in "${PACKAGE_MANAGERS[@]}"; do
    IFS=':' read -r file managers <<< "$pattern"
    if manager=$(get_package_manager "$file" "$managers"); then
        detected_manager=$manager
        break
    fi
done

# Handle no detection
if [ -z "$detected_manager" ]; then
    echo -e "${RED}Error:${NC} No package manager detected in current directory"
    exit 1
fi

# Map commands to package manager specific commands
map_command() {
    local manager=$1
    local cmd=$2
    
    case "$manager" in
        "npm")
            echo "$cmd"
            ;;
        "yarn")
            case "$cmd" in
                "install") echo "install" ;;
                "update") echo "upgrade" ;;
                "build") echo "build" ;;
                *) echo "$cmd" ;;
            esac
            ;;
        "pnpm")
            echo "$cmd"
            ;;
        "pip")
            case "$cmd" in
                "install") echo "install -r requirements.txt" ;;
                "update") echo "install --upgrade -r requirements.txt" ;;
                *) echo "$cmd" ;;
            esac
            ;;
        "poetry")
            case "$cmd" in
                "install") echo "install" ;;
                "update") echo "update" ;;
                "build") echo "build" ;;
                *) echo "$cmd" ;;
            esac
            ;;
        "pipenv")
            case "$cmd" in
                "install") echo "install" ;;
                "update") echo "update" ;;
                *) echo "$cmd" ;;
            esac
            ;;
        "bundler")
            case "$cmd" in
                "install") echo "install" ;;
                "update") echo "update" ;;
                *) echo "$cmd" ;;
            esac
            ;;
        "composer")
            case "$cmd" in
                "install") echo "install" ;;
                "update") echo "update" ;;
                *) echo "$cmd" ;;
            esac
            ;;
        "go")
            case "$cmd" in
                "install") echo "get ./..." ;;
                "update") echo "get -u ./..." ;;
                *) echo "$cmd" ;;
            esac
            ;;
        "cargo")
            case "$cmd" in
                "install") echo "build" ;;
                "update") echo "update" ;;
                *) echo "$cmd" ;;
            esac
            ;;
        "maven")
            case "$cmd" in
                "install") echo "install" ;;
                "update") echo "versions:use-latest-versions" ;;
                "build") echo "package" ;;
                *) echo "$cmd" ;;
            esac
            ;;
        "gradle")
            case "$cmd" in
                "install") echo "build" ;;
                "update") echo "dependencyUpdates" ;;
                "build") echo "build" ;;
                *) echo "$cmd" ;;
            esac
            ;;
        "mix")
            case "$cmd" in
                "install") echo "deps.get" ;;
                "update") echo "deps.update --all" ;;
                *) echo "$cmd" ;;
            esac
            ;;
        "dotnet")
            case "$cmd" in
                "install") echo "restore" ;;
                "update") echo "restore" ;;
                "build") echo "build" ;;
                *) echo "$cmd" ;;
            esac
            ;;
        *)
            echo "$cmd"
            ;;
    esac
}

# Execute command
if [ -n "$COMMAND" ]; then
    mapped_command=$(map_command "$detected_manager" "$COMMAND")
    echo -e "${BLUE}Detected package manager: ${YELLOW}$detected_manager${NC}"
    echo -e "${BLUE}Running: ${YELLOW}$detected_manager $mapped_command${NC}"
    $detected_manager $mapped_command
else
    echo -e "${BLUE}Detected package manager: ${YELLOW}$detected_manager${NC}"
fi 