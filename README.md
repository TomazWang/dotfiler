# Dotfiler

A clean, organized dotfiles management system following zero-magic principles. Portable, predictable, and works on any Unix-like machine.

## Features

- **🔧 Auto-Detection**: Self-locating scripts work from any directory location
- **📁 Organized Structure**: Files grouped by purpose, not file type
- **🚀 One-Command Setup**: `./install.sh` handles everything
- **🔄 Modular Loading**: Clear, predictable configuration loading
- **📦 Dependency Management**: Centralized package management with Homebrew
- **🛠️ Development Ready**: Includes shell functions, scripts, and development tools

## Quick Start

```bash
# Place dotfiler anywhere you like
git clone <this-repo> ~/dotfiler
cd ~/dotfiler

# Run the installer
./install.sh

# Start using (or reload current shell)
source ~/.zshrc
```

## What You Get

### Shell Configuration
- **oh-my-zsh integration** with Spaceship theme
- **Custom aliases and functions** for development workflow
- **Environment variables** for development tools (Android SDK, etc.)
- **PATH management** with automatic tool discovery

### Development Tools
- **Custom git functions** for enhanced workflow
- **Shell utilities** in `bin/` directory (auto-added to PATH)
- **Helper scripts** for various development tasks
- **Homebrew package management** with comprehensive Brewfile

### Available Commands
- `reload` - Reload shell configuration
- `shelp` - Shell help system
- Custom git functions from shell functions
- Development tools from bin/ directory

## Directory Structure

```
dotfiler/
├── install.sh              # One-command setup (auto-detects location)
├── dotfiles/               # Files symlinked to home directory
│   ├── zshrc              # → ~/.zshrc
│   └── ghostty/           # → ~/.config/ghostty/
├── shell/                  # Shell runtime configuration
│   ├── load.sh            # Main orchestrator (auto-detects paths)
│   ├── configs/           # Environment variables, aliases
│   ├── functions/         # Shell functions
│   ├── scripts/           # Complex scripts
│   └── utils/             # Utility scripts
├── bin/                    # User executables (auto-added to PATH)
├── packages/               # Dependency management
│   └── Brewfile           # Package manifest
├── vendor/                 # Third-party code
└── docs/                   # Documentation
    └── archives/          # Migration history
```

## How It Works

1. **install.sh** auto-detects its location and creates symlinks
2. **~/.zshrc** sources `shell/load.sh` from the detected location
3. **shell/load.sh** systematically loads all configs, functions, scripts, and utils
4. **bin/** directory is automatically added to PATH
5. **Everything uses relative paths** - works from any location

## Customization

### Adding New Functionality
- **Shell functions**: Add to appropriate file in `shell/functions/`
- **Scripts**: Place in `shell/scripts/` directory
- **Tools**: Add executables to `bin/` directory
- **Packages**: Update `packages/Brewfile`

### Environment
- **macOS optimized**: Built for macOS with Homebrew
- **Development focused**: Includes Android SDK, programming language tools
- **Terminal integrated**: Works with modern terminal features

## Requirements

- **macOS or Linux** (macOS preferred)
- **Homebrew** (installed automatically if missing)
- **zsh shell** (with oh-my-zsh)

## Troubleshooting

### When to Run install.sh

Run `./install.sh` if:
- ✅ Initial setup on a new machine
- ✅ Symlinks are broken or pointing to wrong locations
- ✅ After moving the dotfiler directory
- ✅ Missing dotfiles in home directory

**To check if symlinks are correct:**
```bash
ls -la ~/.zshrc    # Should point to /path/to/dotfiler/dotfiles/zshrc
ls -la ~/.gitconfig # Should point to /path/to/dotfiler/dotfiles/gitconfig
```

**Don't run install.sh if:**
- ❌ Just editing config files (use `reload` instead)
- ❌ Adding new functions or aliases (use `reload` instead)
- ❌ Symlinks are already correct

### Changes Not Taking Effect?

1. **Check symlinks first:**
   ```bash
   ls -la ~/.zshrc
   ```
   If pointing to old location (e.g., `~/.shell/`), run `./install.sh`

2. **For correct symlinks, just reload:**
   ```bash
   reload  # or: source ~/.zshrc
   ```

3. **Verify the change worked:**
   ```bash
   alias c        # Check alias definition
   echo $EDITOR   # Check environment variable
   ```

## Philosophy

- **Zero Magic**: Every operation is explicit and debuggable
- **Portable First**: Works anywhere without hardcoded paths
- **Organized by Purpose**: Clear separation of concerns
- **Preserve Functionality**: Maintains all existing workflows

---

*For detailed migration history and development context, see `docs/archives/` and `CLAUDE.md`*