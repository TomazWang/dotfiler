#!/usr/bin/env bash

# Dotfiler Initialization Script
# This script sets up a platform-specific mappings.yaml file

set -e

# Define the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$DOTFILES_DIR/mappings.template.yaml"
MAPPINGS_FILE="$DOTFILES_DIR/mappings.yaml"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Helper Functions ---

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "\033[0;31m[ERROR]${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Main Script ---

echo "========================================="
echo "  Dotfiler Initialization"
echo "========================================="
echo ""

# Check for yq
if ! command_exists yq; then
    error "yq is not installed. Please install it first:"
    echo "  brew install yq"
    exit 1
fi

# Check if template exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    error "Template file not found: $TEMPLATE_FILE"
    exit 1
fi

# Detect platform
PLATFORM="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
else
    error "Unsupported platform: $OSTYPE"
    exit 1
fi

info "Detected platform: $PLATFORM"
echo ""

# Check if mappings.yaml already exists
if [ -f "$MAPPINGS_FILE" ]; then
    warn "mappings.yaml already exists!"
    echo ""
    read -p "Do you want to regenerate it? This will overwrite existing file. [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Keeping existing mappings.yaml"
        exit 0
    fi
    info "Backing up existing mappings.yaml to mappings.yaml.backup"
    cp "$MAPPINGS_FILE" "$MAPPINGS_FILE.backup"
fi

# Generate platform-specific mappings.yaml
info "Generating platform-specific mappings.yaml..."
echo ""

# Start building the new YAML file
cat > "$MAPPINGS_FILE" << EOF
# Dotfiler Mappings Configuration
# Platform: $PLATFORM
# Generated: $(date)
#
# This file defines which files should be symlinked and where.
# Edit this file to customize your dotfiles setup.
#
# Format:
#   - source: Path relative to dotfiles/ or dotfiles-private/
#   - target: Absolute target path (use ~ for home directory)
#
# To regenerate for a different platform, run: ./init.sh

EOF

# Process public mappings
info "Processing public mappings..."
PUBLIC_COUNT=$(yq eval '.public | length' "$TEMPLATE_FILE")

if [ "$PUBLIC_COUNT" != "null" ] && [ "$PUBLIC_COUNT" -gt 0 ]; then
    echo "public:" >> "$MAPPINGS_FILE"

    for i in $(seq 0 $((PUBLIC_COUNT - 1))); do
        source=$(yq eval ".public[$i].source" "$TEMPLATE_FILE")
        target=$(yq eval ".public[$i].target" "$TEMPLATE_FILE")
        platform=$(yq eval ".public[$i].platform" "$TEMPLATE_FILE")

        # Only include if platform matches or is "common"
        if [ "$platform" = "common" ] || [ "$platform" = "$PLATFORM" ]; then
            echo "  - source: $source" >> "$MAPPINGS_FILE"
            echo "    target: $target" >> "$MAPPINGS_FILE"
            success "  Added: $source -> $target"
        fi
    done
    echo "" >> "$MAPPINGS_FILE"
fi

# Process private mappings
info "Processing private mappings..."
PRIVATE_COUNT=$(yq eval '.private | length' "$TEMPLATE_FILE")

if [ "$PRIVATE_COUNT" != "null" ] && [ "$PRIVATE_COUNT" -gt 0 ]; then
    echo "private:" >> "$MAPPINGS_FILE"

    for i in $(seq 0 $((PRIVATE_COUNT - 1))); do
        source=$(yq eval ".private[$i].source" "$TEMPLATE_FILE")
        target=$(yq eval ".private[$i].target" "$TEMPLATE_FILE")
        platform=$(yq eval ".private[$i].platform" "$TEMPLATE_FILE")

        # Only include if platform matches or is "common"
        if [ "$platform" = "common" ] || [ "$platform" = "$PLATFORM" ]; then
            # Check if this source was already added (avoid duplicates from multiple platform entries)
            if ! grep -q "source: $source" "$MAPPINGS_FILE" 2>/dev/null; then
                echo "  - source: $source" >> "$MAPPINGS_FILE"
                echo "    target: $target" >> "$MAPPINGS_FILE"
                success "  Added: $source -> $target"
            fi
        fi
    done
    echo "" >> "$MAPPINGS_FILE"
fi

echo ""
success "Platform-specific mappings.yaml created successfully!"
echo ""
info "Location: $MAPPINGS_FILE"
info "Platform: $PLATFORM"
echo ""
info "Next steps:"
echo "  1. Review mappings.yaml and customize if needed"
echo "  2. Run ./install.sh to create symlinks"
echo ""
info "To add custom mappings, edit mappings.yaml directly:"
echo "  vim mappings.yaml"
echo ""
