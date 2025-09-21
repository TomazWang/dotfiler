#!/usr/bin/env bash

# Inherit verbosity from ZSHRC_VERBOSE if set
: "${SHELL_VERBOSE:=${ZSHRC_VERBOSE:-0}}"
log_shell() {
  [ "$SHELL_VERBOSE" = "1" ] && echo "[APPLY.SH] $1"
}

# This script sources all the configuration files for the shell.

# Exit on error
# set -e

# Define the dotfiles directory
DOTFILES_DIR="$HOME/dev/dotfiler"

# Function to source files if they exist and are readable
source_if_exists() {
    if [ -r "$1" ] && [ -f "$1" ]; then
        log_shell "Sourcing $1..."
        if source "$1"; then
            log_shell "Successfully sourced $1"
        else
            log_shell "ERROR sourcing $1"
        fi
    fi
}

# Source all .sh files in the specified directories
for dir in "shell/configs" "shell/functions" "shell/scripts" "shell/utils"; do
    while IFS= read -r -d '' file; do
        source_if_exists "$file"
    done < <(find "$DOTFILES_DIR/$dir" -name "*.sh" -print0)
done

unset -f source_if_exists