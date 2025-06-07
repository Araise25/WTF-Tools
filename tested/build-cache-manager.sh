#!/bin/bash

# build-cache-manager: Manages build caches for various build systems
# Usage: build-cache-manager [command] [options]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Cache directories
CACHE_DIRS=(
    "~/.cache/pip"
    "~/.cache/npm"
    "~/.cache/yarn"
    "~/.cache/cargo"
    "~/.cache/go-build"
    "~/.cache/maven"
    "~/.gradle/caches"
    "~/.cache/bazel"
    "~/.cache/ccache"
    "~/.cache/meson"
    "~/.cache/ninja"
    "~/.cache/rustc"
    "~/.cache/sccache"
    "~/.cache/buck"
    "~/.cache/bazelisk"
)

show_help() {
    cat << EOF
Usage: build-cache-manager [command] [options]

Commands:
    list                    List all cache directories and their sizes
    clean [system]         Clean cache for specific build system
    clean-all              Clean all build caches
    info [system]          Show detailed info about specific cache
    status                 Show cache status summary

Build Systems:
    pip                    Python pip cache
    npm                    Node.js npm cache
    yarn                   Yarn cache
    cargo                  Rust Cargo cache
    go                     Go build cache
    maven                  Maven cache
    gradle                 Gradle cache
    bazel                  Bazel cache
    ccache                 C/C++ compiler cache
    meson                  Meson build cache
    ninja                  Ninja build cache
    rustc                  Rust compiler cache
    sccache                Rust sccache
    buck                   Buck build cache
    bazelisk               Bazelisk cache

Examples:
    build-cache-manager list
    build-cache-manager clean npm
    build-cache-manager clean-all
    build-cache-manager info cargo
    build-cache-manager status
EOF
}

get_cache_dir() {
    local system="$1"
    case "$system" in
        pip) echo "~/.cache/pip" ;;
        npm) echo "~/.cache/npm" ;;
        yarn) echo "~/.cache/yarn" ;;
        cargo) echo "~/.cache/cargo" ;;
        go) echo "~/.cache/go-build" ;;
        maven) echo "~/.cache/maven" ;;
        gradle) echo "~/.gradle/caches" ;;
        bazel) echo "~/.cache/bazel" ;;
        ccache) echo "~/.cache/ccache" ;;
        meson) echo "~/.cache/meson" ;;
        ninja) echo "~/.cache/ninja" ;;
        rustc) echo "~/.cache/rustc" ;;
        sccache) echo "~/.cache/sccache" ;;
        buck) echo "~/.cache/buck" ;;
        bazelisk) echo "~/.cache/bazelisk" ;;
        *) echo "" ;;
    esac
}

get_cache_size() {
    local dir="$1"
    if [ -d "$dir" ]; then
        du -sh "$dir" 2>/dev/null | cut -f1
    else
        echo "N/A"
    fi
}

list_caches() {
    echo -e "${BLUE}Build Cache Directories:${NC}"
    echo "----------------------------------------"
    for dir in "${CACHE_DIRS[@]}"; do
        expanded_dir=$(eval echo "$dir")
        if [ -d "$expanded_dir" ]; then
            size=$(get_cache_size "$expanded_dir")
            echo -e "${GREEN}$(basename "$dir")${NC}: $size"
        fi
    done
}

clean_cache() {
    local system="$1"
    local cache_dir
    cache_dir=$(get_cache_dir "$system")
    
    if [ -z "$cache_dir" ]; then
        echo -e "${RED}Error: Unknown build system '$system'${NC}"
        exit 1
    fi
    
    expanded_dir=$(eval echo "$cache_dir")
    if [ -d "$expanded_dir" ]; then
        echo -e "${YELLOW}Cleaning $system cache...${NC}"
        rm -rf "$expanded_dir"/*
        echo -e "${GREEN}Cache cleaned successfully${NC}"
    else
        echo -e "${YELLOW}No cache directory found for $system${NC}"
    fi
}

clean_all_caches() {
    echo -e "${YELLOW}Cleaning all build caches...${NC}"
    for dir in "${CACHE_DIRS[@]}"; do
        expanded_dir=$(eval echo "$dir")
        if [ -d "$expanded_dir" ]; then
            echo -e "Cleaning $(basename "$dir")..."
            rm -rf "$expanded_dir"/*
        fi
    done
    echo -e "${GREEN}All caches cleaned successfully${NC}"
}

show_cache_info() {
    local system="$1"
    local cache_dir
    cache_dir=$(get_cache_dir "$system")
    
    if [ -z "$cache_dir" ]; then
        echo -e "${RED}Error: Unknown build system '$system'${NC}"
        exit 1
    fi
    
    expanded_dir=$(eval echo "$cache_dir")
    echo -e "${BLUE}Cache Information for $system:${NC}"
    echo "----------------------------------------"
    
    if [ -d "$expanded_dir" ]; then
        echo -e "Location: ${GREEN}$expanded_dir${NC}"
        echo -e "Size: ${GREEN}$(get_cache_size "$expanded_dir")${NC}"
        echo -e "Contents:"
        ls -la "$expanded_dir" 2>/dev/null || echo "No contents"
    else
        echo -e "${YELLOW}Cache directory does not exist${NC}"
    fi
}

show_status() {
    local total_size=0
    local active_caches=0
    
    echo -e "${BLUE}Build Cache Status:${NC}"
    echo "----------------------------------------"
    
    for dir in "${CACHE_DIRS[@]}"; do
        expanded_dir=$(eval echo "$dir")
        if [ -d "$expanded_dir" ]; then
            size=$(du -sb "$expanded_dir" 2>/dev/null | cut -f1)
            if [ -n "$size" ]; then
                total_size=$((total_size + size))
                active_caches=$((active_caches + 1))
            fi
        fi
    done
    
    echo -e "Active Caches: ${GREEN}$active_caches${NC}"
    echo -e "Total Size: ${GREEN}$(numfmt --to=iec-i --suffix=B $total_size)${NC}"
    echo -e "Cache Systems: ${GREEN}${#CACHE_DIRS[@]}${NC}"
}

if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    show_help
    exit 0
fi

case "$1" in
    list)
        list_caches
        ;;
    clean)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please specify a build system${NC}"
            exit 1
        fi
        clean_cache "$2"
        ;;
    clean-all)
        clean_all_caches
        ;;
    info)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please specify a build system${NC}"
            exit 1
        fi
        show_cache_info "$2"
        ;;
    status)
        show_status
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        show_help
        exit 1
        ;;
esac 