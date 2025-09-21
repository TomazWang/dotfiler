#!/usr/bin/env bash

# load thefuck
if command -v thefuck >/dev/null 2>&1; then
    # echo "Loading thefuck ..."
    eval "$(thefuck --alias)"
else
    echo "thefuck is not installed."
    # Do NOT exit or return here!
    true
fi
