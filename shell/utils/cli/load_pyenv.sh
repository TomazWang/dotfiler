#!/bin/bash

# pyenv
if ! command -v pyenv &> /dev/null; then
    echo "Cannot load `pyenv`. Please make sure pyenv is installed."
else
    echo "Loading pyenv..."
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi