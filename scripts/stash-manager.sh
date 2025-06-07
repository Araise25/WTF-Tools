#!/bin/bash

# stash-manager: Git stash management
# Usage: stash-manager

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << EOF
Usage: stash-manager

Lists all Git stashes with diffs and lets you preview and delete interactively.
EOF
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo -e "${RED}Not a git repository.${NC}"
    exit 1
fi

stashes=$(git stash list)
if [ -z "$stashes" ]; then
    echo -e "${GREEN}No stashes found.${NC}"
    exit 0
fi

PS3="Select a stash to view/delete (or 'q' to quit): "
select stash in $stashes; do
    if [ -z "$stash" ]; then
        echo "Exiting."
        break
    fi
    echo -e "${YELLOW}Showing diff for: $stash${NC}"
    git stash show -p "stash@{$REPLY-1}"
    read -p "Delete this stash? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git stash drop "stash@{$REPLY-1}"
        echo -e "${GREEN}Stash deleted.${NC}"
    fi
    break
done 