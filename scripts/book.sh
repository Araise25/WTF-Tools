#!/bin/sh

# File to store commands
BOOK_FILE="$HOME/.book_commands"
# Maximum number of stored commands
MAX_COMMANDS=100

# Detect shell type
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
else
    echo "Error: Unsupported shell. Only bash and zsh are supported."
    exit 1
fi

# Function to initialize the book file
init_book() {
    if [ -f "$BOOK_FILE" ]; then
        echo "Book is already initialized at $BOOK_FILE"
        return 0
    fi

    touch "$BOOK_FILE" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Error: Could not create $BOOK_FILE. Check permissions."
        exit 1
    fi

    chmod 600 "$BOOK_FILE" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Error: Could not set permissions for $BOOK_FILE"
        exit 1
    fi

    echo "Book initialized at $BOOK_FILE"
}

# Function to get the last executed command
get_last_command() {
    if [ "$SHELL_TYPE" = "zsh" ]; then
        # Force history to be written and read
        fc -W 2>/dev/null
        fc -R 2>/dev/null
        fc -l -1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' 2>/dev/null
    else
        # Force history to be written and read
        history -a 2>/dev/null
        history -r 2>/dev/null
        history 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' 2>/dev/null
    fi
}

# Function to save the last command
save_command() {
    local cmd
    cmd=$(get_last_command)
    
    if [ -z "$cmd" ]; then
        echo "Error: No previous command found"
        return 1
    fi

    if [ ! -f "$BOOK_FILE" ]; then
        echo "Error: Book not initialized. Run 'book init' first."
        return 1
    fi

    # Check if command already exists to avoid duplicates
    if grep -Fx "$cmd" "$BOOK_FILE" >/dev/null; then
        echo "Command already saved: $cmd"
        return 0
    fi

    # Add command to file
    echo "$cmd" >> "$BOOK_FILE"
    
    # Trim file to MAX_COMMANDS
    if [ "$(wc -l < "$BOOK_FILE")" -gt "$MAX_COMMANDS" ]; then
        sed -i "1d" "$BOOK_FILE"
    fi

    echo "Saved command: $cmd"
}

# Function to list saved commands
list_commands() {
    if [ ! -f "$BOOK_FILE" ]; then
        echo "Error: Book not initialized. Run 'book init' first."
        return 1
    fi

    if [ ! -s "$BOOK_FILE" ]; then
        echo "No commands saved yet"
        return 0
    fi

    nl -w2 -s'. ' "$BOOK_FILE"
}

# Function to retrieve a command by index
retrieve_command() {
    local index="$1"
    if [ ! -f "$BOOK_FILE" ]; then
        echo "Error: Book not initialized. Run 'book init' first."
        return 1
    fi

    if [ ! -s "$BOOK_FILE" ]; then
        echo "No commands saved yet"
        return 1
    fi

    if ! echo "$index" | grep -q '^[0-9]\+$'; then
        echo "Error: Index must be a positive integer"
        return 1
    fi

    local cmd
    cmd=$(sed -n "${index}p" "$BOOK_FILE")
    if [ -z "$cmd" ]; then
        echo "Error: No command found at index $index"
        return 1
    fi

    echo "$cmd"
    # Add to shell history
    if [ "$SHELL_TYPE" = "zsh" ]; then
        print -s "$cmd"
    else
        history -s "$cmd"
    fi
}

# Main command processing
case "$1" in
    init)
        init_book
        ;;
    list)
        list_commands
        ;;
    [0-9]*)
        retrieve_command "$1"
        ;;
    "")
        save_command
        ;;
    *)
        echo "Usage: book [init|list|<index>]"
        echo "  init: Initialize the command book"
        echo "  list: List all saved commands"
        echo "  <index>: Retrieve command at specified index"
        echo "  (no args): Save the last executed command"
        exit 1
        ;;
esac