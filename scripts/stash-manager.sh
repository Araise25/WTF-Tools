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

while true; do
    stashes=$(git stash list)
    if [ -z "$stashes" ]; then
        echo -e "${GREEN}No stashes found.${NC}"
        exit 0
    fi

    echo -e "\n${BLUE}Available stashes:${NC}"
    echo -e "${YELLOW}----------------------------------------${NC}"
    echo "$stashes" | nl -w2 -s') '
    echo -e "${YELLOW}----------------------------------------${NC}"
    echo -e "${BLUE}Options:${NC}"
    echo "1) View stash diff(Hit q to exit diff)"
    echo "2) Delete stash"
    echo "3) Quit"
    echo "q) Quick exit"
    
    read -p "Select an option (1-3 or q): " option
    
    case $option in
        q|Q)
            echo -e "${GREEN}Exiting stash manager.${NC}"
            exit 0
            ;;
        1)
            read -p "Enter stash number to view: " stash_num
            if [[ $stash_num =~ ^[0-9]+$ ]] && [ $stash_num -le $(echo "$stashes" | wc -l) ]; then
                echo -e "\n${YELLOW}Showing diff for stash #$stash_num:${NC}"
                git stash show -p "stash@{$((stash_num-1))}"
            else
                echo -e "${RED}Invalid stash number.${NC}"
            fi
            ;;
        2)
            read -p "Enter stash number to delete: " stash_num
            if [[ $stash_num =~ ^[0-9]+$ ]] && [ $stash_num -le $(echo "$stashes" | wc -l) ]; then
                read -p "Are you sure you want to delete stash #$stash_num? [y/N] " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    git stash drop "stash@{$((stash_num-1))}"
                    echo -e "${GREEN}Stash deleted.${NC}"
                fi
            else
                echo -e "${RED}Invalid stash number.${NC}"
            fi
            ;;
        3)
            echo -e "${GREEN}Exiting stash manager.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please select 1-3 or q.${NC}"
            ;;
    esac
done 