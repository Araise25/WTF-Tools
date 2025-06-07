#!/bin/bash

# docker-prune-safe: Safe Docker cleanup
# Usage: docker-prune-safe [--dry-run]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

KEEP_DAYS="${WTF_DOCKER_PRUNE_SAFE_KEEP_DAYS:-7}"
DRY_RUN=false

show_help() {
    cat << EOF
Usage: docker-prune-safe [--dry-run]

Cleans unused Docker images but keeps tagged ones and those used in the last $KEEP_DAYS days.

Options:
    --dry-run   Show what would be deleted
    -h, --help Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}Docker is not installed.${NC}"
    exit 1
fi

echo -e "${BLUE}Finding unused Docker images older than $KEEP_DAYS days...${NC}"

# List images that are dangling or untagged and older than KEEP_DAYS
target_images=$(docker images --filter "dangling=true" --format '{{.ID}} {{.CreatedSince}}' | awk -v days=$KEEP_DAYS '{
    if ($2 ~ /week|month|year/ || ($2 ~ /day/ && $1+0 > days)) print $1
}')

# List images not used by any container and older than KEEP_DAYS
target_images+=$(docker images --format '{{.ID}} {{.Repository}} {{.Tag}} {{.CreatedSince}}' | awk -v days=$KEEP_DAYS '{
    if ($3!="<none>" && $2!="<none>" && $4 ~ /week|month|year/ || ($4 ~ /day/ && $1+0 > days)) print $1
}')

if [ -z "$target_images" ]; then
    echo -e "${GREEN}No images to prune.${NC}"
    exit 0
fi

echo -e "${YELLOW}Images to be pruned:${NC}"
echo "$target_images"

if [ "$DRY_RUN" = true ]; then
    echo -e "${BLUE}Dry run: No images will be deleted.${NC}"
    exit 0
fi

read -p "Proceed to delete these images? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled"
    exit 0
fi

docker rmi $target_images

echo -e "${GREEN}Prune complete.${NC}" 