#!/bin/bash

BOOK_HIST_FILE="$HOME/.book_hist"
VERSION="1.0.3"

init_book() {
    if [[ ! -f "$BOOK_HIST_FILE" ]]; then
        touch "$BOOK_HIST_FILE"
        echo "book: Initialized command history at $BOOK_HIST_FILE"
    else
        echo "book: Command history already exists at $BOOK_HIST_FILE"
    fi
}

detect_shell() {
    if [[ -n "$ZSH_VERSION" ]]; then
        echo "zsh"
    elif [[ -n "$BASH_VERSION" ]]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

add_command() {
    if [[ ! -f "$BOOK_HIST_FILE" ]]; then
        echo "book: History file not found. Run 'book init' first."
        return 1
    fi

    if [[ ! -f "$HOME/.book_last_cmd" ]]; then
        echo "book: No recent command found"
        return 1
    fi

    local cmd
    cmd=$(<"$HOME/.book_last_cmd")
    cmd="${cmd#"${cmd%%[![:space:]]*}"}"  # Trim leading whitespace

    # Skip empty commands or ones starting with 'book' or 'b'
    if [[ -z "$cmd" ]] || [[ "$cmd" == book* ]] || [[ "$cmd" == b\ * ]]; then
        echo "book: Skipping internal or empty command"
        return 0
    fi

    # Don't save if it's the same as the last saved one (avoid duplicates)
    if [[ -s "$BOOK_HIST_FILE" ]]; then
        local last_saved
        last_saved=$(tail -n 1 "$BOOK_HIST_FILE")
        if [[ "$last_saved" == "$cmd" ]]; then
            echo "book: Skipping duplicate command"
            return 0
        fi
    fi

    echo "$cmd" >> "$BOOK_HIST_FILE"
    echo "book: Saved command: $cmd"
}


list_command() {
    if [[ ! -f "$BOOK_HIST_FILE" ]]; then
        echo "book: History file not found. Run 'book init' first."
        return 1
    fi

    if [[ ! -s "$BOOK_HIST_FILE" ]]; then
        echo "book: No commands saved yet"
        return 0
    fi

    nl -w1 -s'. ' "$BOOK_HIST_FILE"
}



execute_command() {
    if [[ ! -f "$BOOK_HIST_FILE" ]]; then
        echo "book: History file not found. Run 'book init' first."
        return 1
    fi

    local cmd
    if [[ "$1" == "run" ]]; then
        cmd=$(tail -n 1 "$BOOK_HIST_FILE")
    else
        cmd=$(sed -n "${1}p" "$BOOK_HIST_FILE" || echo "")
    fi

    if [[ -z "$cmd" ]]; then
        echo "book: Command not found"
        return 1
    fi

    echo "> $cmd"
    eval "$cmd" # Security risk, consider safer alternatives if needed
}

remove_command() {
    if [[ ! -f "$BOOK_HIST_FILE" ]]; then
        echo "book: History file not found. Run 'book init' first."
        return 1
    fi

    if [[ ! -s "$BOOK_HIST_FILE" ]]; then
        echo "book: No commands to remove"
        return 1
    fi

    sed -i "${1}d" "$BOOK_HIST_FILE" || sed -i '1d' "$BOOK_HIST_FILE"
    echo "book: Command removed"
}

show_help() {
    cat <<EOF
book v$VERSION - Enhanced Command History Manager

Usage:
  book init                Initialize command tracking
  book add                 Save last executed command
  book list                Show saved commands with numbering
  book <number>            Execute command with specified number
  book run                 Execute most recently saved command
  book rm <number>         Remove command with specified number
  book help                Show this help message
  book version             Show version information

Aliases:
  Use 'b' instead of 'book' for faster access

Examples:
  $ ls -la                  # Run a command
  $ book add                # Save the command
  $ book list               # Display numbered commands
  $ book 1                  # Execute the first command
  $ book rm 2               # Remove the second command
  $ book run                # Execute most recent command

Security Note:
  Be cautious when executing saved commands as they may contain untrusted content.

EOF
}

main() {
    case "$1" in
        init)
            init_book
            ;;
        add)
            add_command
            ;;
        list|ls)
            list_command
            ;;
        run)
            execute_command "run"
            ;;
        rm|remove)
            if [[ -z "$2" ]]; then
                echo "book: Usage: book rm <number>"
                return 1
            fi
            remove_command "$2"
            ;;
        [0-9]*)
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                execute_command "$1"
            else
                echo "book: Unknown command '$1'"
                return 1
            fi
            ;;
        help|--help|-h)
            show_help
            ;;
        -v|--version|version)
            echo "book v$VERSION"
            ;;
        *)
            if [[ $# == 0 ]]; then
                list_command
            else
                echo "book: Unknown command '$1'"
                return 1
            fi
            ;;
    esac
}

main "$@"