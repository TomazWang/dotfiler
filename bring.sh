#!/usr/bin/env bash

# Dotfiler: Bring Existing Files Under Management
# This script helps you adopt existing dotfiles into dotfiler management

set -e

# Define directories
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PUBLIC_DIR="$DOTFILES_DIR/dotfiles"
PRIVATE_DIR="$DOTFILES_DIR/dotfiles-private"
MAPPINGS_FILE="$DOTFILES_DIR/mappings.yaml"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Helper Functions ---

show_help() {
    cat <<EOF
Usage: ./bring.sh [PATH...] [OPTIONS]

Bring existing dotfiles under dotfiler management.

Arguments:
    PATH                Path(s) to file(s) to bring (optional, will prompt if omitted)

Options:
    --private           Mark as private dotfile (default)
    --public            Mark as public dotfile
    --yes, -y           Auto-confirm all prompts
    --help, -h          Show this help

Examples:
    ./bring.sh
        Interactive mode (prompts for everything)

    ./bring.sh ~/.vimrc
        Bring .vimrc, prompt for public/private and confirmation

    ./bring.sh ~/.aws/credentials --private
        Bring AWS credentials as private, still prompt for confirmation

    ./bring.sh ~/.vimrc --public --yes
        Bring .vimrc as public, auto-confirm (no prompts)

    ./bring.sh ~/.aws/credentials ~/.aws/config --private --yes
        Bring multiple files as private, auto-confirm

    ./bring.sh ~/Library/Application\ Support/Claude/claude_desktop_config.json
        Bring Claude config (use quotes or escape spaces)

EOF
    exit 0
}

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
    echo -e "${RED}[ERROR]${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Suggest a destination path based on source
suggest_destination() {
    local source="$1"
    local is_private="$2"

    # Get just the filename
    local filename=$(basename "$source")

    # Try to detect app/context from path
    local parent_dir=$(basename "$(dirname "$source")")

    # Smart suggestions based on common patterns
    if [[ "$source" == *".aws/"* ]]; then
        echo "aws/$filename"
    elif [[ "$source" == *".ssh/"* ]]; then
        echo "ssh/$filename"
    elif [[ "$source" == *".config/claude"* ]] || [[ "$source" == *"Claude/"* ]]; then
        echo "claude-desktop/$filename"
    elif [[ "$source" == *".config/"* ]]; then
        echo "$parent_dir/$filename"
    elif [[ "$source" == *"Library/Application Support/"* ]]; then
        echo "$parent_dir/$filename"
    else
        # Just use filename for home directory dotfiles
        echo "$filename"
    fi
}

# Add mapping to mappings.yaml
add_mapping() {
    local source_path="$1"
    local target_path="$2"
    local is_private="$3"

    if [ ! -f "$MAPPINGS_FILE" ]; then
        error "mappings.yaml not found. Please run ./init.sh first."
        return 1
    fi

    local section="public"
    if [ "$is_private" = "true" ]; then
        section="private"
    fi

    # Check if mapping already exists
    if grep -q "source: $source_path" "$MAPPINGS_FILE" 2>/dev/null; then
        warn "Mapping already exists in mappings.yaml"
        return 0
    fi

    # Add mapping using yq
    if command_exists yq; then
        yq eval -i ".$section += [{\"source\": \"$source_path\", \"target\": \"$target_path\"}]" "$MAPPINGS_FILE"
    else
        # Fallback: append to file
        echo "  - source: $source_path" >> "$MAPPINGS_FILE"
        echo "    target: $target_path" >> "$MAPPINGS_FILE"
    fi
}

# Main bring function
bring_file() {
    local source_path="$1"
    local is_private_preset="$2"  # Optional: "true", "false", or empty
    local auto_yes="$3"            # Optional: "true" or empty

    # Expand ~ if present
    source_path="${source_path/#\~/$HOME}"

    # Validate source exists
    if [ ! -e "$source_path" ] && [ ! -L "$source_path" ]; then
        error "Source does not exist: $source_path"
        return 1
    fi

    # Check if already a symlink pointing to dotfiler
    if [ -L "$source_path" ]; then
        local link_target=$(readlink "$source_path")
        if [[ "$link_target" == *"$DOTFILES_DIR"* ]]; then
            warn "File is already managed by dotfiler"
            return 1
        fi
    fi

    echo ""
    info "Bringing: $source_path"
    echo ""

    # Determine if private
    local is_private
    if [ -n "$is_private_preset" ]; then
        # Use preset value
        is_private="$is_private_preset"
        if [ "$is_private" = "true" ]; then
            info "Will be managed as: PRIVATE dotfile"
        else
            info "Will be managed as: PUBLIC dotfile"
        fi
    else
        # Ask if private (default: yes)
        read -p "Is this a PUBLIC dotfile (no credentials)? [y/N]: " is_public
        is_private="true"
        if [[ "$is_public" =~ ^[Yy]$ ]]; then
            is_private="false"
            info "Will be managed as: PUBLIC dotfile"
        else
            info "Will be managed as: PRIVATE dotfile (default)"
        fi
    fi

    # Suggest destination
    local suggested=$(suggest_destination "$source_path" "$is_private")
    echo ""
    echo "Suggested destination: $suggested"

    local dest_path="$suggested"
    if [ "$auto_yes" != "true" ]; then
        read -p "Accept? [Y/n]: " accept_suggestion
        if [[ "$accept_suggestion" =~ ^[Nn]$ ]]; then
            read -p "Enter destination path: " dest_path
        fi
    else
        info "Using suggested destination (--yes mode)"
    fi

    # Determine full destination
    local full_dest
    if [ "$is_private" = "true" ]; then
        full_dest="$PRIVATE_DIR/$dest_path"
    else
        full_dest="$PUBLIC_DIR/$dest_path"
    fi

    # Show preview
    echo ""
    echo "Preview:"
    echo "  [1] Backup: ${source_path}.backup"
    echo "  [2] Move to: $full_dest"
    echo "  [3] Create symlink: $source_path → $full_dest"
    echo "  [4] Add mapping to mappings.yaml"
    echo ""

    if [ "$auto_yes" != "true" ]; then
        read -p "Proceed? [y/N]: " proceed
        if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
            info "Cancelled"
            return 0
        fi
    else
        info "Proceeding (--yes mode)"
    fi

    echo ""

    # 1. Create backup
    info "Creating backup..."
    cp -a "$source_path" "${source_path}.backup"
    success "Created backup: ${source_path}.backup"

    # 2. Create destination directory if needed
    local dest_dir=$(dirname "$full_dest")
    if [ ! -d "$dest_dir" ]; then
        mkdir -p "$dest_dir"
    fi

    # 3. Move file to dotfiler
    info "Moving to dotfiler..."
    mv "$source_path" "$full_dest"
    success "Moved to: $full_dest"

    # 4. Create symlink
    info "Creating symlink..."
    ln -s "$full_dest" "$source_path"
    success "Created symlink: $source_path → $full_dest"

    # 5. Add mapping to mappings.yaml
    info "Updating mappings.yaml..."
    add_mapping "$dest_path" "$source_path" "$is_private"
    success "Updated mappings.yaml"

    echo ""
    success "Done! File is now managed by dotfiler."
    echo ""
    info "Verify with:"
    echo "  ls -la $source_path"
    echo "  cat mappings.yaml"
    echo ""
}

# --- Main Script ---

# Parse command-line arguments
FILE_PATHS=()
IS_PRIVATE_SET=""
AUTO_YES=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --private)
            IS_PRIVATE_SET="true"
            shift
            ;;
        --public)
            IS_PRIVATE_SET="false"
            shift
            ;;
        --yes|-y)
            AUTO_YES="true"
            shift
            ;;
        --help|-h)
            show_help
            ;;
        -*)
            error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
        *)
            FILE_PATHS+=("$1")
            shift
            ;;
    esac
done

echo "========================================="
echo "  Dotfiler: Bring Existing File Under Management"
echo "========================================="
echo ""

# Check prerequisites
if ! command_exists yq; then
    warn "yq not found. Mapping updates will use fallback method."
    echo ""
fi

if [ ! -f "$MAPPINGS_FILE" ]; then
    error "mappings.yaml not found!"
    error "Please run ./init.sh first to initialize dotfiler."
    exit 1
fi

# If paths provided as arguments, process them
if [ ${#FILE_PATHS[@]} -gt 0 ]; then
    for file_path in "${FILE_PATHS[@]}"; do
        bring_file "$file_path" "$IS_PRIVATE_SET" "$AUTO_YES"
    done
    echo ""
    info "All done!"
    exit 0
fi

# Interactive mode (no arguments provided)
while true; do
    read -p "Enter path to bring (or 'q' to quit): " input_path

    if [[ "$input_path" == "q" ]] || [[ "$input_path" == "Q" ]]; then
        info "Goodbye!"
        exit 0
    fi

    if [ -z "$input_path" ]; then
        warn "Please enter a path"
        continue
    fi

    bring_file "$input_path" "$IS_PRIVATE_SET" "$AUTO_YES"

    echo ""
    read -p "Bring another file? [y/N]: " another
    if [[ ! "$another" =~ ^[Yy]$ ]]; then
        break
    fi
    echo ""
    echo "========================================="
    echo ""
done

echo ""
info "All done!"
