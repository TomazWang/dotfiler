#!/usr/bin/env bash

# Claude Code Update Function
#
# Updates Claude Code when auto-update fails due to fnm/node environment conflicts.
# This happens when Claude Code runs in a shelled node environment (like fnm) and
# cannot delete its temporary folders while running.
#
# Usage: claude-update
#
# What it does:
# 1. Detects and terminates any running Claude Code processes
# 2. Locates and removes the Claude Code installation directory
# 3. Reinstalls the latest version via npm
# 4. Verifies the installation
#
# Dependencies: npm, pkill (standard on macOS/Linux)

function claude-update() {
    local claude_path
    local install_dir
    local processes_killed=false

    echo "🔄 Claude Code Update Utility"
    echo "================================"
    echo ""

    # Step 1: Check if claude command exists
    echo "📍 Checking Claude Code installation..."
    if ! command -v claude &> /dev/null; then
        echo "❌ Error: 'claude' command not found in PATH"
        echo "   Make sure Claude Code is installed: npm i -g @anthropic-ai/claude-code"
        return 1
    fi

    claude_path=$(which claude)
    echo "✓ Found Claude Code at: $claude_path"
    echo ""

    # Step 2: Detect installation directory
    echo "📂 Detecting installation directory..."
    # Path is typically: /path/to/node_modules/.bin/claude
    # We want: /path/to/node_modules/@anthropic-ai/claude-code
    install_dir=$(dirname $(dirname "$claude_path"))/lib/node_modules/@anthropic-ai/claude-code

    if [ ! -d "$install_dir" ]; then
        echo "❌ Error: Could not find installation directory at: $install_dir"
        return 1
    fi

    echo "✓ Installation directory: $install_dir"
    echo ""

    # Step 3: Check for running processes
    echo "🔍 Checking for running Claude Code processes..."
    if pgrep -f "claude-code" > /dev/null 2>&1; then
        echo "⚠️  Found running Claude Code processes"
        echo ""
        echo "   The following processes will be terminated:"
        pgrep -fl "claude-code"
        echo ""

        # Ask for confirmation
        read -p "   Continue? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Update cancelled by user"
            return 1
        fi

        echo "   Terminating processes..."
        pkill -f "claude-code"
        sleep 1

        # Check if processes still exist
        if pgrep -f "claude-code" > /dev/null 2>&1; then
            echo "⚠️  Some processes still running, forcing termination..."
            pkill -9 -f "claude-code"
            sleep 1
        fi

        processes_killed=true
        echo "✓ Processes terminated"
    else
        echo "✓ No running processes found"
    fi
    echo ""

    # Step 4: Remove installation directory
    echo "🗑️  Removing old installation..."
    if [ ! -d "$install_dir" ]; then
        echo "⚠️  Installation directory no longer exists (may have been removed)"
    else
        # Safety check: make sure path contains "claude-code"
        if [[ "$install_dir" != *"claude-code"* ]]; then
            echo "❌ Error: Installation path doesn't contain 'claude-code'. Aborting for safety."
            echo "   Path: $install_dir"
            return 1
        fi

        rm -rf "$install_dir"
        if [ $? -eq 0 ]; then
            echo "✓ Old installation removed"
        else
            echo "❌ Error: Failed to remove installation directory"
            echo "   You may need to run with sudo or check permissions"
            return 1
        fi
    fi
    echo ""

    # Step 5: Reinstall Claude Code
    echo "📦 Installing latest Claude Code..."
    npm install -g @anthropic-ai/claude-code

    if [ $? -ne 0 ]; then
        echo "❌ Error: npm install failed"
        echo "   Check your npm configuration and network connection"
        return 1
    fi
    echo ""

    # Step 6: Verify installation
    echo "✅ Verifying installation..."
    if command -v claude &> /dev/null; then
        local version=$(claude --version 2>/dev/null || echo "unknown")
        echo "✓ Claude Code successfully installed"
        echo "✓ Version: $version"
        echo ""
        echo "🎉 Update complete! You can now run 'claude' to start."
        return 0
    else
        echo "❌ Error: Claude Code command not found after installation"
        echo "   Try reopening your terminal or checking your PATH"
        return 1
    fi
}
