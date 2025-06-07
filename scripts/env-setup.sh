#!/bin/bash

# env-setup: Automatically setup .env from a template
# Usage: env-setup [template_file] [output_file]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TEMPLATE_FILE="${WTF_ENV_SETUP_TEMPLATE:-.env.example}"
OUTPUT_FILE=".env"

# Help message
show_help() {
    cat << EOF
Usage: env-setup [template_file] [output_file]

Automatically setup .env from a template file.

Options:
    template_file    Template file to use (default: .env.example)
    output_file     Output file to create (default: .env)

Environment variables:
    WTF_ENV_SETUP_TEMPLATE    Default template file (default: .env.example)

Examples:
    env-setup                    # Use .env.example to create .env
    env-setup .env.template      # Use .env.template to create .env
    env-setup .env.template .env.prod  # Use .env.template to create .env.prod
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            if [ -z "$TEMPLATE_FILE" ]; then
                TEMPLATE_FILE="$1"
            elif [ -z "$OUTPUT_FILE" ]; then
                OUTPUT_FILE="$1"
            else
                echo -e "${RED}Error:${NC} Too many arguments"
                show_help
                exit 1
            fi
            ;;
    esac
    shift
done

# Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}Error:${NC} Template file '$TEMPLATE_FILE' not found"
    exit 1
fi

# Check if output file already exists
if [ -f "$OUTPUT_FILE" ]; then
    echo -e "${YELLOW}Warning:${NC} Output file '$OUTPUT_FILE' already exists"
    read -p "Do you want to overwrite it? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operation cancelled"
        exit 0
    fi
fi

# Process the template
echo -e "${BLUE}Setting up $OUTPUT_FILE from $TEMPLATE_FILE...${NC}"

# Create temporary file
TMP_FILE=$(mktemp)

# Process each line
while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines and comments
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
        echo "$line" >> "$TMP_FILE"
        continue
    fi

    # Check if line contains a variable
    if [[ "$line" =~ ^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*= ]]; then
        var_name=$(echo "$line" | cut -d'=' -f1 | tr -d '[:space:]')
        default_value=$(echo "$line" | cut -d'=' -f2-)
        
        # Remove quotes from default value
        default_value=$(echo "$default_value" | sed -E 's/^["'\''](.*)["'\'']$/\1/')
        
        # Prompt for value
        read -p "$var_name [$default_value]: " value
        value="${value:-$default_value}"
        
        # Add to output
        echo "$var_name=$value" >> "$TMP_FILE"
    else
        # Copy line as-is
        echo "$line" >> "$TMP_FILE"
    fi
done < "$TEMPLATE_FILE"

# Move temporary file to output
mv "$TMP_FILE" "$OUTPUT_FILE"

echo -e "${GREEN}Success:${NC} Created $OUTPUT_FILE"
echo -e "${BLUE}Note:${NC} Please review the file and make any necessary adjustments" 