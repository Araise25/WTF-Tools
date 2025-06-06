#!/bin/bash

# commit-message-helper: Helps generate and validate commit messages
# Usage: commit-message-helper [command] [options]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Conventional commit types
COMMIT_TYPES=(
    "feat"     "A new feature"
    "fix"      "A bug fix"
    "docs"     "Documentation only changes"
    "style"    "Changes that do not affect the meaning of the code"
    "refactor" "A code change that neither fixes a bug nor adds a feature"
    "perf"     "A code change that improves performance"
    "test"     "Adding missing tests or correcting existing tests"
    "build"    "Changes that affect the build system or external dependencies"
    "ci"       "Changes to our CI configuration files and scripts"
    "chore"    "Other changes that don't modify src or test files"
    "revert"   "Reverts a previous commit"
)

show_help() {
    cat << EOF
Usage: commit-message-helper [command] [options]

Commands:
    generate              Interactive commit message generation
    validate [message]    Validate a commit message
    types                 List all conventional commit types
    template              Show commit message template

Examples:
    commit-message-helper generate
    commit-message-helper validate "feat: add new feature"
    commit-message-helper types
    commit-message-helper template
EOF
}

list_types() {
    echo -e "${BLUE}Conventional Commit Types:${NC}"
    echo "----------------------------------------"
    for ((i=0; i<${#COMMIT_TYPES[@]}; i+=2)); do
        echo -e "${GREEN}${COMMIT_TYPES[i]}${NC}: ${COMMIT_TYPES[i+1]}"
    done
}

show_template() {
    cat << EOF
# Conventional Commit Message Format:
# <type>(<scope>): <description>
#
# [optional body]
#
# [optional footer(s)]
#
# Examples:
# feat(auth): add OAuth2 login
# fix(api): handle null response from server
# docs(readme): update installation instructions
#
# Rules:
# - Type must be one of: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
# - Description should be in present tense and not capitalized
# - No period at the end of description
# - Body and footer are optional
# - Each line should not exceed 72 characters
EOF
}

validate_message() {
    local message="$1"
    local valid=true
    local errors=()

    # Check if message is empty
    if [ -z "$message" ]; then
        errors+=("Commit message cannot be empty")
        valid=false
    fi

    # Check format: type(scope): description
    if ! [[ "$message" =~ ^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9-]+\))?:\ .+ ]]; then
        errors+=("Message must follow format: type(scope): description")
        valid=false
    fi

    # Check type
    local type
    type=$(echo "$message" | cut -d'(' -f1)
    if ! [[ " ${COMMIT_TYPES[*]} " =~ " $type " ]]; then
        errors+=("Invalid commit type: $type")
        valid=false
    fi

    # Check description length
    local description
    description=$(echo "$message" | cut -d':' -f2- | sed 's/^ //')
    if [ ${#description} -gt 72 ]; then
        errors+=("Description exceeds 72 characters")
        valid=false
    fi

    # Output results
    if [ "$valid" = true ]; then
        echo -e "${GREEN}✓ Valid commit message${NC}"
        return 0
    else
        echo -e "${RED}✗ Invalid commit message:${NC}"
        for error in "${errors[@]}"; do
            echo -e "  - ${RED}$error${NC}"
        done
        return 1
    fi
}

generate_message() {
    echo -e "${BLUE}Generate Commit Message${NC}"
    echo "----------------------------------------"

    # Select type
    echo -e "\n${YELLOW}Select commit type:${NC}"
    select type in "${COMMIT_TYPES[@]}"; do
        if [ -n "$type" ]; then
            break
        fi
    done

    # Get scope
    echo -e "\n${YELLOW}Enter scope (optional, press Enter to skip):${NC}"
    read -r scope
    if [ -n "$scope" ]; then
        type="${type}(${scope})"
    fi

    # Get description
    echo -e "\n${YELLOW}Enter description:${NC}"
    read -r description
    while [ -z "$description" ]; do
        echo -e "${RED}Description cannot be empty${NC}"
        read -r description
    done

    # Get body
    echo -e "\n${YELLOW}Enter body (optional, press Enter twice to finish):${NC}"
    body=""
    while IFS= read -r line; do
        [ -z "$line" ] && break
        body="${body}${line}\n"
    done

    # Get footer
    echo -e "\n${YELLOW}Enter footer (optional, press Enter twice to finish):${NC}"
    footer=""
    while IFS= read -r line; do
        [ -z "$line" ] && break
        footer="${footer}${line}\n"
    done

    # Construct message
    message="${type}: ${description}"
    if [ -n "$body" ]; then
        message="${message}\n\n${body}"
    fi
    if [ -n "$footer" ]; then
        message="${message}\n\n${footer}"
    fi

    # Validate and show message
    echo -e "\n${BLUE}Generated commit message:${NC}"
    echo "----------------------------------------"
    echo -e "$message"
    echo "----------------------------------------"
    
    if validate_message "$(echo "$message" | head -n1)"; then
        echo -e "\n${GREEN}Message is valid!${NC}"
        echo -e "\nTo use this message, run:"
        echo -e "git commit -m \"$(echo "$message" | head -n1)\""
        if [ -n "$body" ] || [ -n "$footer" ]; then
            echo -e "git commit -m \"$(echo "$message" | head -n1)\" -m \"$(echo "$message" | tail -n+3)\""
        fi
    else
        echo -e "\n${RED}Please fix the issues above and try again${NC}"
    fi
}

if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    show_help
    exit 0
fi

case "$1" in
    generate)
        generate_message
        ;;
    validate)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please provide a commit message to validate${NC}"
            exit 1
        fi
        validate_message "$2"
        ;;
    types)
        list_types
        ;;
    template)
        show_template
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        show_help
        exit 1
        ;;
esac 