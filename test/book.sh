#!/bin/bash

# Configuration
BOOK_HIST_FILE="$HOME/.book_hist"
VERSION="1.0.0"

# Detect current shell
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

# Initialize book history
init_book() {
    if [ -f "$BOOK_HIST_FILE" ]; then
        echo "book: history file already exists at $BOOK_HIST_FILE"
        return 1
    fi

    if touch "$BOOK_HIST_FILE"; then
        echo "book: initialized history file at $BOOK_HIST_FILE"
        
        # Add to shell configuration if not already present
        local shell_config
        case $(detect_shell) in
            bash) shell_config="$HOME/.bashrc" ;;
            zsh) shell_config="$HOME/.zshrc" ;;
            *) shell_config="" ;;
        esac

        if [ -n "$shell_config" ]; then
            if ! grep -q "alias b=" "$shell_config"; then
                echo "Adding book shortcut to $shell_config"
                echo 'alias b="book"' >> "$shell_config"
            fi
        fi
    else
        echo "book: failed to create history file at $BOOK_HIST_FILE"
        return 1
    fi
}

# Add last command to history
add_command() {
    if [ ! -f "$BOOK_HIST_FILE" ]; then
        echo "book: history file not found. Run 'book init' first."
        return 1
    fi

    local cmd
    # Get last command from history
    case $(detect_shell) in
        bash) cmd=$(history 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//') ;;
        zsh) cmd=$(history -1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//') ;;
        *) cmd=$(history | tail -n 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//') ;;
    esac

    # Skip if empty or if it's a book command
    if [[ -z "$cmd" ]] || [[ "$cmd" == book* ]] || [[ "$cmd" == b* ]]; then
        echo "book: not saving book command or empty command"
        return 1
    fi

    # Overwrite the file with just this command
    echo "$cmd" > "$BOOK_HIST_FILE"
    echo "book: saved command: $cmd"
}

# List saved command (only one)
list_command() {
    if [ ! -f "$BOOK_HIST_FILE" ]; then
        echo "book: history file not found. Run 'book init' first."
        return 1
    fi

    if [ ! -s "$BOOK_HIST_FILE" ]; then
        echo "book: no command saved yet"
        return 0
    fi

    echo "1. $(cat "$BOOK_HIST_FILE")"
}

# Execute the saved command
execute_command() {
    if [ ! -f "$BOOK_HIST_FILE" ]; then
        echo "book: history file not found. Run 'book init' first."
        return 1
    fi

    if [ ! -s "$BOOK_HIST_FILE" ]; then
        echo "book: no command saved yet"
        return 1
    fi

    local cmd
    cmd=$(cat "$BOOK_HIST_FILE")
    echo "> $cmd"
    eval "$cmd"
}

# Remove the saved command
remove_command() {
    if [ ! -f "$BOOK_HIST_FILE" ]; then
        echo "book: history file not found. Run 'book init' first."
        return 1
    fi

    if [ ! -s "$BOOK_HIST_FILE" ]; then
        echo "book: no command saved to remove"
        return 1
    fi

    > "$BOOK_HIST_FILE"
    echo "book: removed saved command"
}

# Show help
show_help() {
    cat <<EOF
book v$VERSION - Last Command Manager

Usage:
  book init                Initialize book command tracking
  book add                 Save the last executed command
  book list                Show the saved command
  book run                 Execute the saved command
  book rm                  Remove the saved command
  book help                Show this help message

Shortcut:
  Use 'b' instead of 'book' for faster access

Examples:
  $ some-command
  $ book add              # Saves the last command
  $ book list             # Shows the saved command
  $ book run              # Executes the saved command
  $ book rm               # Removes the saved command
EOF
}

# Main function
main() {
    case $1 in
        init)
            init_book
            ;;
        add)
            add_command
            ;;
        list|ls)
            list_command
            ;;
        run|1)
            execute_command
            ;;
        rm|remove)
            remove_command
            ;;
        help|--help|-h)
            show_help
            ;;
        -v|--version|version)
            echo "book v$VERSION"
            ;;
        *)
            if [ $# -eq 0 ]; then
                list_command
            else
                echo "book: unknown command '$1'. Use 'book help' for usage."
                return 1
            fi
            ;;
    esac
}

# Run main function with all arguments
main "$@"