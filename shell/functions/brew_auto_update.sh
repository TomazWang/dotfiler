#!/usr/bin/env bash

# Inherit verbosity from ZSHRC_VERBOSE if set
: "${SHELL_VERBOSE:=${ZSHRC_VERBOSE:-0}}"
log_shell() {
  [ "$SHELL_VERBOSE" = "1" ] && echo "[BREW_AUTO_UPDATE] $1"
}

# This function runs before each prompt and updates the Brewfile if needed.
function _update_brewfile_if_needed() {
    local dirty_file="$HOME/.shell/.brewfile_dirty"
    local timestamp_file="$HOME/.shell/.brew_update_timestamp"

    # Check if the Brewfile is marked as dirty.
    if [ -f "$dirty_file" ]; then
        # Immediately remove the dirty file to prevent this from running again.
        rm -f "$dirty_file"

        # Now, check if the last update was more than 24 hours ago.
        # The find command returns true if the file is older than 1 day.
        if [ ! -f "$timestamp_file" ] || find "$timestamp_file" -mtime +0 | grep -q .; then
            log_shell "Brewfile is out of date. Updating in the background..."
            (
                command brew bundle dump --file="$HOME/.shell/Brewfile" --force && \
                touch "$timestamp_file"
            ) & 
            disown
        fi
    fi
}

