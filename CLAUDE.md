# Claude AI Assistant Context for Dotfiler Project

## Project Overview

This is a **complete dotfiles management system** that provides a clean, organized setup following zero-magic principles. The goal is to create a portable, predictable dotfiles management system that works on any Unix-like machine.

## Current Status: Migration Complete ✅

**The migration from ~/.shell has been completed successfully**. This is now a fully functional dotfiles system. Migration documentation is archived in `docs/archives/`.

## Design Philosophy

**Zero Magic**: Every operation should be explicit, understandable, and debuggable
**Portable First**: Works on any Unix system (macOS, Linux) with standard tools only
**Organized by Purpose**: Files organized by what they DO, not what they ARE
**Auto-Detection**: Uses relative paths and auto-detection for maximum portability

## Directory Structure

```
dotfiler/
├── install.sh              # One-command setup script (auto-detects location)
├── dotfiles/               # Entry point files → symlinked to ~/
│   ├── zshrc              # → ~/.zshrc (sources shell/load.sh)
│   └── ghostty/           # → ~/.config/ghostty/
├── shell/                  # Shell runtime configs → auto-sourced
│   ├── load.sh            # Main orchestrator (auto-detects paths)
│   ├── configs/           # Environment, aliases
│   ├── functions/         # Shell functions
│   ├── scripts/           # Complex scripts
│   └── utils/             # Utility scripts
├── bin/                    # User executables (auto-added to PATH)
├── packages/               # Dependency management
│   └── Brewfile           # Complete package manifest
├── vendor/                 # Third-party code
└── docs/                   # Documentation
    └── archives/          # Migration documentation
```

## Key Features

### Auto-Detection & Portability
- **Self-locating scripts**: All paths are auto-detected relative to script locations
- **Portable installation**: Can be placed anywhere and will work correctly
- **No hardcoded paths**: Everything uses relative path detection

### Shell Integration
- **Modular loading**: `shell/load.sh` sources all configs, functions, scripts, and utils
- **Zero-magic sourcing**: Clear, predictable file loading order
- **Preserved functionality**: All original aliases, functions, and scripts maintained

### Organized Structure
- **Purpose-based organization**: Files grouped by function, not file type
- **Clear separation**: Entry points (`dotfiles/`) vs runtime code (`shell/`)
- **Dependency management**: Centralized package management with Brewfile

## Usage

### Quick Start
```bash
# Clone or download dotfiler to any location
cd ~/dotfiler  # or wherever you placed it

# Run the installer
./install.sh

# Start new shell session or reload
source ~/.zshrc
```

### What install.sh Does
1. **Installs Homebrew packages** from `packages/Brewfile`
2. **Creates symlinks**:
   - `dotfiles/zshrc` → `~/.zshrc`
   - `dotfiles/ghostty/` → `~/.config/ghostty/`
3. **Auto-detects location** and works from any directory

## Development Notes

### Key Commands Available After Setup
- `reload` - Reload shell configuration
- `shelp` - Shell help system
- Custom git functions from `shell/functions/fn_git.sh`
- Development tools from `bin/` directory

### Environment Considerations
- **macOS focused**: Setup is optimized for macOS with Homebrew
- **oh-my-zsh integration**: Uses Spaceship theme and oh-my-zsh plugins
- **Development tools**: Includes Android SDK, various programming languages
- **Terminal integrations**: fzf, various CLI tools

### Maintenance
- **Adding new functions**: Place in appropriate `shell/functions/` file
- **Adding new scripts**: Place in `shell/scripts/` directory
- **Adding new tools**: Place in `bin/` directory (will be auto-added to PATH)
- **Adding packages**: Update `packages/Brewfile`

### For AI Agents
- **Migration completed**: No migration work needed
- **Focus on enhancements**: Add features, fix bugs, improve organization
- **Test functionality**: Ensure changes don't break existing workflows
- **Use auto-detection**: Never hardcode paths, always use relative detection