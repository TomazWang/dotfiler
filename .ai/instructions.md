# AI Assistant Instructions for Dotfiler

## Project Overview

Dotfiler is a **zero-magic, portable dotfiles management system** for macOS/Linux. This is a **migration-in-progress** from `~/.shell` to a cleaner structure. The project prioritizes explicit operations, portability, and preserving all existing functionality.

## AI Behavior Rules

### CRITICAL: Verify Before Advising

**ALWAYS follow this protocol when answering questions:**

1. **Check actual state FIRST** - Run diagnostic commands before giving advice
2. **Show evidence** - State what you verified: "I checked X by running Y, found Z"
3. **No assumptions** - Don't assume "typical" setups, especially during migration
4. **Respect documentation** - Read README.md and linked docs before contradicting them
5. **Test changes** - After edits, verify they work (run commands, check output)

**For this migration-in-progress project:**
- ❌ **NEVER assume** old `~/.shell` vs new `dotfiler` paths without checking
- ❌ **NEVER say** "you don't need to run X" without verifying current state
- ✅ **ALWAYS check** symlink locations: `ls -la ~/.zshrc`, `ls -la ~/.gitconfig`
- ✅ **ALWAYS verify** which config is loaded: `which command`, `alias command`
- ✅ **ALWAYS read** README.md and linked documentation before giving setup advice

**Evidence-based response pattern:**
```
1. [Run diagnostic commands]
2. [Analyze results]
3. [Give advice based on evidence]
4. [Make changes if needed]
5. [Verify changes worked]
```

**When uncertain:** Say "Let me check..." then gather evidence. Never fake confidence.

## Architecture

### File Organization (Purpose-Based)

```
dotfiler/
├── install.sh              # One-command setup: symlinks dotfiles, installs Homebrew packages
├── dotfiles/               # Symlinked to home directory
│   ├── zshrc              # Entry point: sources shell/load.sh
│   ├── gitconfig, nvmrc, python-version
│   └── ghostty/           # Terminal config
├── shell/                  # Runtime shell configuration
│   ├── load.sh            # Auto-detects location, sources all configs/functions/scripts/utils
│   ├── configs/           # exports.sh (env vars, PATH), alias.sh
│   ├── functions/         # Shell functions (organized by purpose)
│   ├── scripts/           # Complex scripts with external integrations
│   └── utils/             # CLI tool loaders (pyenv, fzf, etc.)
├── bin/                    # User executables (auto-added to PATH via exports.sh)
│   └── git-commands/      # Custom git commands (e.g., git-cof)
├── packages/
│   └── Brewfile           # Complete Homebrew dependency manifest (244 lines)
└── vendor/                # Third-party code (forgit, z.sh, spaceship theme)
```

### Core Loading Flow

1. **Shell startup** → `~/.zshrc` (symlink to `dotfiles/zshrc`)
2. **oh-my-zsh init** → Loads Spaceship theme, plugins (git, zsh-syntax-highlighting)
3. **`shell/load.sh`** → Auto-detects `$DOTFILES_DIR`, sources all `.sh` files in:
   - `shell/configs/` (aliases, exports)
   - `shell/functions/` (shell functions)
   - `shell/scripts/` (scripts like fzf integration)
   - `shell/utils/` (CLI tool integrations)
4. **Vendor integrations** → forgit, z.sh, fzf, iTerm2, Google Cloud SDK, SDKMAN

### Auto-Detection Pattern

Scripts use **auto-detection** instead of hardcoded paths:

```bash
# In shell/load.sh and exports.sh
if [[ -n "${BASH_SOURCE[0]}" ]]; then
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
elif [[ -n "${(%):-%N}" ]]; then
    DOTFILES_DIR="$(cd "$(dirname "${(%):-%N}")/.." && pwd)"
fi
```

This allows dotfiler to work from any location without configuration.

## Development Workflows

### Key Commands

- **`reload`** - Reload shell config (alias: `. ~/.zshrc`)
- **`shelp [command]`** - Self-documenting help system (searches functions, aliases, brew packages)
  - Auto-builds index via `shelp-build` (scans all `.sh` files, Brewfile, npm globals)
  - Examples: `shelp reload`, `shelp -s git`, `shelp -c aliases`
- **`claude-update`** - Manual update function for Claude Code (workaround for fnm auto-update issues)
- **`cl [command]`** - Claude Code CLI wrapper for one-shot commands

### Installation/Testing

```bash
./install.sh       # Installs Homebrew, runs brew bundle, creates symlinks
source ~/.zshrc    # Reload to test changes
```

**Testing checklist after changes:**
- Shell loads without errors
- Aliases/functions available
- PATH includes `bin/` directory
- No broken file references

### Git Workflow

⚠️ **CRITICAL:** User handles all git operations. **Never use git commands** unless explicitly requested.

Custom git commands in `bin/git-commands/`:
- `git-cof` - Interactive branch checkout with fzf
- `git-ignore` - Generate .gitignore from toptal.com API

## Project-Specific Conventions

### Shell Function Standards

1. **Verbosity logging pattern** (from `brew_auto_update.sh`):
   ```bash
   : "${SHELL_VERBOSE:=${ZSHRC_VERBOSE:-0}}"
   log_shell() {
     [ "$SHELL_VERBOSE" = "1" ] && echo "[FUNCTION_NAME] $1"
   }
   ```

2. **Error handling:** Return non-zero exit codes, provide helpful error messages
3. **Safety checks:** Validate paths, confirm destructive operations
4. **User feedback:** Use emoji-based status indicators (🔄, ✓, ❌, ⚠️)

Example: `shell/functions/claude-update.sh` (see PR #11 for review comments addressing quoting, process detection, error handling)

### PATH Management

**Exports.sh** builds PATH in reverse order (last item has highest priority):
```bash
dirs_to_prepend=(
    "$ANDROID_HOME/platform-tools"
    # ... more Android SDK paths
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    "$SPACESHIP_ROOT"
)
for dir in ${(k)dirs_to_prepend[@]}; do
    [ -d ${dir} ] && PATH="${dir}:$PATH"
done
```

Then adds `$DOTFILER_ROOT/bin:$PATH` to include custom executables.

### Brewfile Auto-Update

Background process (`brew_auto_update.sh`) updates `Brewfile` when marked dirty:
- Triggered via `precmd` hook in zsh
- Uses `.brew_update_timestamp` to throttle (24hr intervals)
- Runs `brew bundle dump` in background with `disown`

### Environment-Specific

- **macOS-focused:** Android SDK paths, Homebrew at `/opt/homebrew`
- **Development tools:** Android SDK, Python (pyenv), Node (fnm), Java (SDKMAN)
- **Terminal:** Ghostty config (themes), iTerm2 integration, tmux 256-color support

## Dependencies & Constraints

### Keep During Migration

- **oh-my-zsh** - Don't remove (used for themes, plugins)
- **All Brewfile packages** - Complete manifest (244 lines)
- **Vendor scripts** - Third-party integrations (forgit, z.sh, spaceship theme)
- **All existing functions** - Even if seemingly unused

### External Dependencies

- **Homebrew** (auto-installed by `install.sh`)
- **zsh** with oh-my-zsh
- **fzf** - Fuzzy finder (used by git-cof, shelp, scripts)
- **eza** - Modern ls replacement (conditional alias)

## Common Tasks

### Adding New Functionality

1. **Shell function:** Create `.sh` file in `shell/functions/` (follow verbosity pattern)
2. **Script:** Add to `shell/scripts/` (for complex integrations)
3. **Executable:** Place in `bin/` (auto-added to PATH)
4. **Alias:** Add to `shell/configs/alias.sh`
5. **Package:** Update `packages/Brewfile`

No manual sourcing needed - `shell/load.sh` auto-discovers `.sh` files.

### Debugging

Enable verbose logging:
```bash
ZSHRC_VERBOSE=1 source ~/.zshrc
```

Check specific file loading:
```bash
# In shell/load.sh - logs "Sourcing <file>..." when SHELL_VERBOSE=1
```

### Common Pitfalls

❌ **Don't hardcode paths** - Use `$DOTFILES_DIR`, `$DOTFILER_ROOT`, `$HOME`
❌ **Don't use git commands** - User handles version control
❌ **Don't remove "unused" code** - Migration preserves everything
❌ **Don't quote command substitution in paths** - See PR #11 critical issue (line 44)
✅ **Do follow existing patterns** - Check similar functions for conventions
✅ **Do add safety checks** - Validate paths, confirm destructive ops
✅ **Do provide clear feedback** - Emoji status, helpful error messages

## Migration Context

See `docs/archives/` for historical context:
- **PRD.md** - Target architecture, principles
- **MIGRATION_PLAN.md** - Phased migration strategy
- **CLAUDE.md** - AI agent handoff procedures (legacy, see `.ai/instructions.md`)

**Current phase:** Post-migration, adding features. Structure is stable but may evolve.

## Project Philosophy

- **Zero Magic**: Every operation is explicit, understandable, and debuggable
- **Portable First**: Works on any Unix system (macOS, Linux) with standard tools only
- **Organized by Purpose**: Files organized by what they DO, not what they ARE
- **Preserve Functionality**: Maintain 100% of existing functionality during migration
