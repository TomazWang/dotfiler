#!/usr/bin/env bash

# A wrapper for the brew command to automatically update the Brewfile.
function brew() {
    # Call the real brew command with all arguments.
    command brew "$@"

    # After the command, check if it was one that modifies packages.
    case "$1" in
        install|uninstall|upgrade|tap|untap)
            # Mark the Brewfile as needing an update by creating a dirty file.
            touch "$HOME/.shell/.brewfile_dirty"
            ;;
    esac
}
