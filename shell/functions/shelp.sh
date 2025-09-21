#!/bin/bash

# shelp - Simple Shell Help System
# Provides contextual help for shell commands, functions, and utilities

shelp() {
    local HELP_DIR="$HOME/.shell/docs"
    local INDEX_FILE="$HELP_DIR/index.txt"
    local query=""
    local search_type="exact"
    local show_categories=false
    local category_filter=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--search)
                search_type="fuzzy"
                shift
                ;;
            -l|--list)
                show_categories=true
                shift
                ;;
            -c|--category)
                category_filter="$2"
                shift 2
                ;;
            -h|--help)
                _shelp_show_usage
                return 0
                ;;
            -*)
                echo "Unknown option: $1" >&2
                _shelp_show_usage
                return 1
                ;;
            *)
                if [[ -z "$query" ]]; then
                    query="$1"
                fi
                shift
                ;;
        esac
    done

    # Initialize help system if needed
    if [[ ! -d "$HELP_DIR" ]] || [[ ! -f "$INDEX_FILE" ]]; then
        echo "Help system not initialized. Running shelp-build..."
        if command -v shelp-build >/dev/null 2>&1; then
            shelp-build
        else
            echo "Error: shelp-build not found. Please ensure it's in your PATH." >&2
            return 1
        fi
    fi

    # Show categories if requested
    if [[ "$show_categories" == "true" ]]; then
        _shelp_list_categories
        return 0
    fi

    # Show category-filtered results or all available help if no query
    if [[ -z "$query" ]]; then
        if [[ -n "$category_filter" ]]; then
            _shelp_show_category "$category_filter"
        else
            _shelp_show_all
        fi
        return 0
    fi

    # Search for help
    case "$search_type" in
        "exact")
            _shelp_exact_search "$query"
            ;;
        "fuzzy")
            _shelp_fuzzy_search "$query"
            ;;
    esac
}

# Show usage information
_shelp_show_usage() {
    cat << 'EOF'
shelp - Shell Help System

Usage:
    shelp [command]           Show help for specific command
    shelp -s [pattern]        Fuzzy search for commands matching pattern
    shelp -c [category]       Filter by category
    shelp -l, --list          List all available categories
    shelp -h, --help          Show this help message

Examples:
    shelp reload              Show help for reload command
    shelp -s git              Search for commands containing "git"
    shelp -c aliases          Show all aliases
    shelp -l                  List all help categories

The help system automatically indexes your shell functions, scripts, and aliases.
EOF
}

# List all available categories
_shelp_list_categories() {
    local HELP_DIR="$HOME/.shell/docs"
    
    if [[ ! -d "$HELP_DIR" ]]; then
        echo "No help documentation found." >&2
        return 1
    fi

    echo "Available help categories:"
    echo
    
    # List directories in docs
    for category_dir in "$HELP_DIR"/*; do
        if [[ -d "$category_dir" ]]; then
            local category=$(basename "$category_dir")
            local count=$(find "$category_dir" -name "*.txt" 2>/dev/null | wc -l | tr -d ' ')
            printf "  %-15s (%d commands)\n" "$category" "$count"
        fi
    done
    
    # Show total count
    local total=$(find "$HELP_DIR" -name "*.txt" 2>/dev/null | wc -l | tr -d ' ')
    echo
    echo "Total: $total documented commands"
}

# Show commands from a specific category
_shelp_show_category() {
    local category="$1"
    local INDEX_FILE="$HOME/.shell/docs/index.txt"
    
    if [[ ! -f "$INDEX_FILE" ]]; then
        echo "Help index not found. Run 'shelp-build' to create it." >&2
        return 1
    fi

    echo "Commands in category '$category':"
    echo
    
    local found=false
    while IFS=$'\t' read -r command cat type file description; do
        # Skip header line
        [[ "$command" == "command" ]] && continue
        
        if [[ "$cat" == "$category" ]]; then
            printf "  %-20s %s\n" "$command" "$description"
            found=true
        fi
    done < "$INDEX_FILE"
    
    if [[ "$found" == "false" ]]; then
        echo "No commands found in category '$category'."
        echo "Use 'shelp -l' to see available categories."
        return 1
    fi
}

# Show all available help
_shelp_show_all() {
    local INDEX_FILE="$HOME/.shell/docs/index.txt"
    
    if [[ ! -f "$INDEX_FILE" ]]; then
        echo "Help index not found. Run 'shelp-build' to create it." >&2
        return 1
    fi

    echo "Available commands (use 'shelp <command>' for details):"
    echo
    
    # Group by category
    local current_category=""
    while IFS=$'\t' read -r command category type file description; do
        # Skip header line
        [[ "$command" == "command" ]] && continue
        
        if [[ "$category" != "$current_category" ]]; then
            echo
            echo "[$category]"
            current_category="$category"
        fi
        printf "  %-20s %s\n" "$command" "$description"
    done < "$INDEX_FILE"
}

# Exact search for a command
_shelp_exact_search() {
    local query="$1"
    local INDEX_FILE="$HOME/.shell/docs/index.txt"
    local found=false
    
    if [[ ! -f "$INDEX_FILE" ]]; then
        echo "Help index not found. Run 'shelp-build' to create it." >&2
        return 1
    fi

    # Search for exact matches first
    while IFS=$'\t' read -r command category type file description; do
        # Skip header line
        [[ "$command" == "command" ]] && continue
        
        if [[ "$command" == "$query" ]]; then
            _shelp_show_help_file "$file" "$command"
            found=true
            break
        fi
    done < "$INDEX_FILE"

    # If no exact match, try partial matches
    if [[ "$found" == "false" ]]; then
        local matches=()
        while IFS=$'\t' read -r command category type file description; do
            # Skip header line
            [[ "$command" == "command" ]] && continue
            
            if [[ "$command" == *"$query"* ]]; then
                matches+=("$command|$category|$type|$file|$description")
            fi
        done < "$INDEX_FILE"

        if [[ ${#matches[@]} -eq 0 ]]; then
            echo "No help found for '$query'."
            echo "Try 'shelp -s $query' for fuzzy search or 'shelp -l' to list categories."
            return 1
        elif [[ ${#matches[@]} -eq 1 ]]; then
            # Single match, show it
            IFS='|' read -r command category type file description <<< "${matches[0]}"
            _shelp_show_help_file "$file" "$command"
        else
            # Multiple matches, list them
            echo "Multiple matches found for '$query':"
            echo
            for match in "${matches[@]}"; do
                IFS='|' read -r command category type file description <<< "$match"
                printf "  %-20s [%s] %s\n" "$command" "$category" "$description"
            done
            echo
            echo "Use 'shelp <exact-command>' to show specific help."
        fi
    fi
}

# Fuzzy search for commands
_shelp_fuzzy_search() {
    local pattern="$1"
    local INDEX_FILE="$HOME/.shell/docs/index.txt"
    
    if [[ ! -f "$INDEX_FILE" ]]; then
        echo "Help index not found. Run 'shelp-build' to create it." >&2
        return 1
    fi

    echo "Commands matching '$pattern':"
    echo
    
    local found=false
    while IFS=$'\t' read -r command category type file description; do
        # Skip header line
        [[ "$command" == "command" ]] && continue
        
        if [[ "$command" == *"$pattern"* ]] || [[ "$description" == *"$pattern"* ]]; then
            printf "  %-20s [%s] %s\n" "$command" "$category" "$description"
            found=true
        fi
    done < "$INDEX_FILE"

    if [[ "$found" == "false" ]]; then
        echo "No commands found matching '$pattern'."
        return 1
    fi
}

# Show content of a help file
_shelp_show_help_file() {
    local file="$1"
    local command="$2"
    
    if [[ ! -f "$file" ]]; then
        echo "Help file not found: $file" >&2
        return 1
    fi

    echo "Help for: $command"
    echo "$(printf '=%.0s' {1..50})"
    echo
    cat "$file"
    echo
}

# Functions are automatically available in Zsh
# No explicit export needed