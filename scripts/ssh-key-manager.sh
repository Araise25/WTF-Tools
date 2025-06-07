 #!/bin/bash

# ssh-key-manager: Manage SSH keys for different services
# Usage: ssh-key-manager [add|list|show|delete] [service]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

KEYS_DIR="$HOME/.ssh/wtf-keys"
mkdir -p "$KEYS_DIR"

show_help() {
    cat << EOF
Usage: ssh-key-manager [add|list|show|delete] [service]

Manages SSH keys for different services (e.g., github, gitlab, bitbucket).

Examples:
    ssh-key-manager add github
    ssh-key-manager list
    ssh-key-manager show github
    ssh-key-manager delete github
EOF
}

case "$1" in
    -h|--help|"")
        show_help
        exit 0
        ;;
    add)
        service="$2"
        if [ -z "$service" ]; then
            echo -e "${RED}Specify a service name.${NC}"
            exit 1
        fi
        keyfile="$KEYS_DIR/id_${service}_ed25519"
        if [ -f "$keyfile" ]; then
            echo -e "${YELLOW}Key for $service already exists: $keyfile${NC}"
            exit 1
        fi
        ssh-keygen -t ed25519 -f "$keyfile" -C "$USER@$service" -N ""
        echo -e "${GREEN}Key generated: $keyfile${NC}"
        echo -e "${BLUE}Public key:${NC}"
        cat "$keyfile.pub"
        ;;
    list)
        echo -e "${BLUE}Available SSH keys:${NC}"
        ls "$KEYS_DIR" | grep -v ".pub$" | while read -r key; do
            echo "- ${key}"
        done
        ;;
    show)
        service="$2"
        keyfile="$KEYS_DIR/id_${service}_ed25519.pub"
        if [ ! -f "$keyfile" ]; then
            echo -e "${RED}No key found for $service${NC}"
            exit 1
        fi
        cat "$keyfile"
        ;;
    delete)
        service="$2"
        keyfile="$KEYS_DIR/id_${service}_ed25519"
        if [ ! -f "$keyfile" ]; then
            echo -e "${RED}No key found for $service${NC}"
            exit 1
        fi
        rm -f "$keyfile" "$keyfile.pub"
        echo -e "${GREEN}Deleted key for $service${NC}"
        ;;
    *)
        show_help
        exit 1
        ;;
esac