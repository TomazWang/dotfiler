#!/usr/bin/env bash

# Claude Code CLI wrapper for one-time command execution
# Usage: cl [command] [arguments...]
# Examples:
#   cl think "how to optimize this algorithm"
#   cl search "TODO comments in codebase"
#   cl "explain this bash syntax"

cl() {
    # Check if claude command exists
    if ! command -v claude &> /dev/null; then
        echo "Error: claude command not found. Please install Claude Code CLI first."
        return 1
    fi

    # If no arguments provided, show usage
    if [ $# -eq 0 ]; then
        echo "Usage: cl [command] [arguments...]"
        echo "Examples:"
        echo "  cl think \"how to optimize this algorithm\""
        echo "  cl search \"TODO comments\""
        echo "  cl \"explain this bash syntax\""
        echo ""
        echo "For interactive mode, use: claude"
        return 0
    fi

    local first_arg="$1"
    shift

    # Check if the first argument already starts with a slash
    if [[ "$first_arg" == /* ]]; then
        # Already has slash, pass through as-is
        claude -p "$first_arg $*"
    elif [ $# -eq 0 ]; then
        # Single argument, could be a direct prompt or single word command
        # Check if it's a known command without arguments (like help, version)
        case "$first_arg" in
            help|version|status)
                # These are likely slash commands
                claude -p "/$first_arg"
                ;;
            *)
                # Treat as a direct prompt
                claude -p "$first_arg"
                ;;
        esac
    else
        # Multiple arguments - first is likely a command, rest are arguments
        # Add slash to make it a command
        claude -p "/$first_arg $*"
    fi
}

# Optional: Add completion support for common commands
# Only set up completion if compdef is available
if [ -n "$ZSH_VERSION" ] && command -v compdef &> /dev/null; then
    # Zsh completion
    _cl_complete() {
        local -a commands
        commands=(
            'think:Think through a problem or solution'
            'search:Search for something in the codebase'
            'help:Show help information'
            'test:Run or create tests'
            'explain:Explain code or concepts'
            'refactor:Refactor code'
            'debug:Debug an issue'
            'review:Review code'
        )
        _describe 'command' commands
    }
    compdef _cl_complete cl 2>/dev/null
fi