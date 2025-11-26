#!/usr/bin/env bash

# This script sets up the dotfiles and installs necessary tools.

set -e

# Define the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRIVATE_DIR="$DOTFILES_DIR/dotfiles-private"

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
info "Step 3: Creating symbolic links from mappings.yaml..."

# Check if yq is available
if ! command_exists yq; then
    error "yq is not installed. Please run 'brew install yq' first."
    exit 1
fi

# Check if mappings.yaml exists
MAPPINGS_FILE="$DOTFILES_DIR/mappings.yaml"
if [ ! -f "$MAPPINGS_FILE" ]; then
    error "mappings.yaml not found at $MAPPINGS_FILE"
    error "Please run ./init.sh first to generate platform-specific mappings."
    exit 1
fi

# Function to create symlink with directory creation
create_symlink() {
    local source="$1"
    local target="$2"
    local type="$3"

    # Expand ~ in target path
    target="${target/#\~/$HOME}"

    # Create parent directory if needed
    local target_dir
    target_dir="$(dirname "$target")"
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    # Create symlink
    if [ -e "$source" ] || [ -L "$source" ]; then
        info "[$type] Linking $source -> $target"
        ln -sfv "$source" "$target"
    else
        info "[$type] Source not found (skipping): $source"
    fi
}

# Process public dotfiles mappings
info "Processing public dotfiles..."
PUBLIC_COUNT=$(yq eval '.public | length' "$MAPPINGS_FILE")
if [ "$PUBLIC_COUNT" != "null" ] && [ "$PUBLIC_COUNT" -gt 0 ]; then
    for i in $(seq 0 $((PUBLIC_COUNT - 1))); do
        source=$(yq eval ".public[$i].source" "$MAPPINGS_FILE")
        target=$(yq eval ".public[$i].target" "$MAPPINGS_FILE")

        source_path="$DOTFILES_DIR/dotfiles/$source"
        create_symlink "$source_path" "$target" "public"
    done
else
    info "No public mappings found in mappings.yaml"
fi

# Process private dotfiles mappings
info "Processing private dotfiles..."
PRIVATE_COUNT=$(yq eval '.private | length' "$MAPPINGS_FILE")
if [ "$PRIVATE_COUNT" != "null" ] && [ "$PRIVATE_COUNT" -gt 0 ]; then
    if [ -d "$PRIVATE_DIR" ]; then
        info "Private dotfiles directory found at $PRIVATE_DIR"
        for i in $(seq 0 $((PRIVATE_COUNT - 1))); do
            source=$(yq eval ".private[$i].source" "$MAPPINGS_FILE")
            target=$(yq eval ".private[$i].target" "$MAPPINGS_FILE")

            source_path="$PRIVATE_DIR/$source"
            create_symlink "$source_path" "$target" "private"
        done
    else
        info "No private dotfiles directory found (optional)."
        info "To use private dotfiles, create: $PRIVATE_DIR"
    fi
else
    info "No private mappings found in mappings.yaml"
fi

STEP_END=$(date +%s)
info "Step 3 complete. Duration: $((STEP_END - STEP_START)) seconds."

echo
info "Dotfiles setup complete!"
info "Please restart your shell for the changes to take effect."
info ""
info "📝 Configuration:"
info "   - Edit mappings.yaml to customize which files are linked"
info "   - For sensitive configs (credentials, API keys), use dotfiles-private/"
info "   - Run ./init.sh to regenerate mappings.yaml if needed"
info "   - See PRIVATE-DOTFILES-QUICKSTART.md for quick setup guide"
