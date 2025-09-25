#!/usr/bin/env bash

# This script sets up the dotfiles and installs necessary tools.

set -e

# Define the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure Homebrew is in PATH
export PATH="/opt/homebrew/bin:$PATH"

# --- Helper Functions ---

# Function to print messages
info() {
    echo "[INFO] $1"
}

# Function to print error messages
error() {
    echo "[ERROR] $1"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Main Setup ---

STEP_START=$(date +%s)
info "Step 1: Checking Homebrew installation..."
# 1. Install Homebrew
if ! command_exists brew; then
    info "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH for the rest of the script
    eval "$(/opt/homebrew/bin/brew shellenv)"
    info "Homebrew installed successfully."
else
    info "Homebrew is already installed."
fi
STEP_END=$(date +%s)
info "Step 1 complete. Duration: $((STEP_END - STEP_START)) seconds."

echo
STEP_START=$(date +%s)
info "Step 2: Installing packages from Brewfile..."
# 2. Install packages from Brewfile
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    info "Brewfile found. Running brew bundle... (this may take a while)"
    brew bundle --file="$DOTFILES_DIR/Brewfile"
    info "brew bundle completed."
else
    info "Brewfile not found. Skipping package installation."
fi
STEP_END=$(date +%s)
info "Step 2 complete. Duration: $((STEP_END - STEP_START)) seconds."

echo
STEP_START=$(date +%s)
info "Step 3: Creating symbolic links..."
# 3. Create symbolic links

# Link .zshrc
info "Linking $DOTFILES_DIR/dotfiles/zshrc to $HOME/.zshrc"
ln -sfv "$DOTFILES_DIR/dotfiles/zshrc" "$HOME/.zshrc"

# Link git configuration
info "Linking $DOTFILES_DIR/dotfiles/gitconfig to $HOME/.gitconfig"
ln -sfv "$DOTFILES_DIR/dotfiles/gitconfig" "$HOME/.gitconfig"

# Link Node version (fnm/nvm)
info "Linking $DOTFILES_DIR/dotfiles/nvmrc to $HOME/.nvmrc"
ln -sfv "$DOTFILES_DIR/dotfiles/nvmrc" "$HOME/.nvmrc"

# Link Python version (pyenv)
info "Linking $DOTFILES_DIR/dotfiles/python-version to $HOME/.pyenv/version"
mkdir -p "$HOME/.pyenv"
ln -sfv "$DOTFILES_DIR/dotfiles/python-version" "$HOME/.pyenv/version"

# Create ~/.config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Link ghostty config
info "Linking $DOTFILES_DIR/dotfiles/ghostty to $HOME/.config/ghostty"
ln -sfv "$DOTFILES_DIR/dotfiles/ghostty" "$HOME/.config/ghostty"

# Additional dotfiles can be added here as needed

STEP_END=$(date +%s)
info "Step 3 complete. Duration: $((STEP_END - STEP_START)) seconds."

echo
info "Dotfiles setup complete!"
info "Please restart your shell for the changes to take effect."
