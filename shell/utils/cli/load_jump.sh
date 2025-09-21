#!/bin/bash

# loading jump
if ! command -v jump &> /dev/null; then
    echo "Cannot load `jump`. Please make sure jump is installed."
else
    # echo "Loading jump..."
    eval "$(jump shell)"
    eval "jump import z"
fi

unalias z 2&> /dev/null
alias z=j