#!/usr/bin/env bash

BOOK_FILE="$HOME/.book_commands"
SHELL_NAME=$(basename "$SHELL")

setup_shell_tracking() {
    TRACK_CMD_ZSH='precmd() { LAST_CMD=$(fc -ln -1); export LAST_CMD; }'
    TRACK_CMD_BASH='export PROMPT_COMMAND='\''LAST_CMD=$(history 1 | sed "s/^ *[0-9]* *//")'\'''

    if [[ "$SHELL_NAME" == "zsh" ]]; then
        SHELL_RC="$HOME/.zshrc"
        TRACK_CMD="$TRACK_CMD_ZSH"
    elif [[ "$SHELL_NAME" == "bash" ]]; then
        SHELL_RC="$HOME/.bashrc"
        TRACK_CMD="$TRACK_CMD_BASH"
    else
        echo "❌ Unsupported shell: $SHELL_NAME"
        exit 1
    fi

    if ! grep -q "LAST_CMD=" "$SHELL_RC"; then
        echo -e "\n# For book command tracking\n$TRACK_CMD" >> "$SHELL_RC"
        echo "⚙️  Shell tracking added to $SHELL_RC"
        echo "ℹ️  Please restart your terminal or run: source $SHELL_RC"
    fi
}

# First-time setup
if [ -z "$LAST_CMD" ]; then
    echo "⚠️  LAST_CMD is not set. Running setup..."
    setup_shell_tracking
    exit 0
fi

mkdir -p "$(dirname "$BOOK_FILE")"
touch "$BOOK_FILE"

# Handle subcommands
case "$1" in
  list)
    if [ ! -s "$BOOK_FILE" ]; then
        echo "No saved commands."
    else
        nl -w2 -s'. ' "$BOOK_FILE"
    fi
    ;;

  search)
    shift
    if [ -z "$1" ]; then
        echo "Usage: book search <keyword>"
        exit 1
    fi
    matches=$(grep -ni --color=never -i "$1" "$BOOK_FILE")
    if [ -z "$matches" ]; then
        echo "No matches found for \"$1\"."
    else
        echo "Matches for \"$1\":"
        echo "$matches"
    fi
    ;;

  run)
    index=$2
    cmd=$(sed -n "${index}p" "$BOOK_FILE")
    if [ -z "$cmd" ]; then
        echo "No command at index $index."
        exit 1
    fi
    echo "Executing: $cmd"
    eval "$cmd"
    ;;

  rm)
    index=$2
    cmd=$(sed -n "${index}p" "$BOOK_FILE")
    if [ -z "$cmd" ]; then
        echo "No command at index $index."
        exit 1
    fi
    read -p "Are you sure you want to delete command #$index: \"$cmd\"? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        sed -i "${index}d" "$BOOK_FILE"
        echo "Deleted."
    else
        echo "Cancelled."
    fi
    ;;

  clear)
    read -p "Are you sure you want to clear all saved commands? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        > "$BOOK_FILE"
        echo "All saved commands cleared."
    else
        echo "Cancelled."
    fi
    ;;

  help)
    cat <<EOF
Usage:
  book              - Save the last executed command
  book list         - List saved commands
  book run <n>      - Run saved command at index <n>
  book rm <n>       - Remove saved command at index <n>
  book clear        - Clear all saved commands
  book search <kw>  - Search saved commands for <kw>
  book help         - Show this help
EOF
    ;;

  "")
    echo "$LAST_CMD" >> "$BOOK_FILE"
    echo "Saved: $LAST_CMD"
    ;;

  *)
    echo "Unknown command: $1"
    echo "Run 'book help' for usage."
    ;;
esac

