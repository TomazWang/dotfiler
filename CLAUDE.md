# Claude AI Assistant Context for Dotfiler Migration Project

## Project Overview

This is a **migration project** to transform the existing ~/.shell dotfiles repository into a clean, organized "dotfiler" system following zero-magic principles. The goal is to create a portable, predictable dotfiles management system that works on any Unix-like machine.

## Current Status: Migration In Progress

**This project is a WORK IN PROGRESS**. The current session is focused on Phase 1-2.5 of a multi-phase migration plan. See MIGRATION_PLAN.md for complete roadmap.

## Migration Philosophy

**Zero Magic**: Every operation should be explicit, understandable, and debuggable
**Portable First**: Must work on any Unix system (macOS, Linux) with standard tools only
**Organized by Purpose**: Files organized by what they DO, not what they ARE
**Preserve Functionality**: Maintain 100% of existing functionality during migration

## Target Directory Structure

```
dotfiler/
├── install.sh              # One-command setup script
├── bootstrap/              # Entry point files → symlinked to ~/
│   ├── zshrc              # → ~/.zshrc (keeps oh-my-zsh for now)
│   └── [future dotfiles]
├── shell/                  # Shell runtime configs → auto-sourced
│   ├── load.sh            # Main orchestrator (replaces apply.sh)
│   ├── configs/           # Environment, aliases (from current configs/)
│   ├── functions/         # Shell functions (from current functions/)
│   ├── scripts/           # Complex scripts (from current scripts/)
│   └── utils/             # Utility scripts (from current utils/)
├── config/                 # Modern app configs → symlinked to ~/.config/
│   └── ghostty/           # Terminal configuration
│       ├── config
│       └── themes/
├── bin/                    # User executables (from current bin/)
├── packages/               # Dependency management
│   └── Brewfile           # Complete current Brewfile
└── vendor/                 # Third-party code (from current vendor/)
```

## File Migration Mapping

### From Current ~/.shell Structure:
- `zshrc` → `bootstrap/zshrc`
- `apply.sh` → `shell/load.sh`
- `configs/` → `shell/configs/`
- `functions/` → `shell/functions/`
- `scripts/` → `shell/scripts/`
- `utils/` → `shell/utils/`
- `bin/` → `bin/` (direct copy)
- `Brewfile` → `packages/Brewfile`
- `vendor/` → `vendor/` (direct copy)
- `install.sh` → `install.sh` (will need updates)

## Key Principles for AI Agents

### During Migration (Phases 1-2)
1. **Preserve Everything**: Copy all files, don't exclude anything
2. **Maintain Functionality**: All existing aliases, functions, and scripts must work
3. **Keep oh-my-zsh**: Don't remove oh-my-zsh dependency during migration
4. **Full Brewfile**: Copy complete Brewfile, don't reduce packages

### During Refactoring (Phases 3-5)
1. **Update Paths Carefully**: Scripts reference files by relative paths that will change
2. **Test Incrementally**: Verify each change doesn't break functionality
3. **Maintain Backwards Compatibility**: During transition period
4. **Document Changes**: Track what was modified and why

## Script Refactoring Requirements

### Critical Path Updates Needed:
1. **`shell/load.sh`** (copied from apply.sh):
   - Update directory references from `configs` to `shell/configs`
   - Update directory references from `functions` to `shell/functions`
   - Update directory references from `scripts` to `shell/scripts`
   - Update directory references from `utils` to `shell/utils`

2. **`bootstrap/zshrc`** (copied from zshrc):
   - Change source call from `apply.sh` to `shell/load.sh`
   - Update any hardcoded paths to dotfiler structure

3. **`install.sh`** (copied from install.sh):
   - Update symlink targets to use `bootstrap/` directory
   - Add new symlinks for `config/` directory contents
   - Update path references throughout script

## Testing Requirements

### After Each Phase:
- [ ] Shell starts without errors
- [ ] All aliases and functions are available
- [ ] PATH modifications work correctly
- [ ] No missing or broken file references
- [ ] Installation script works on clean system

### Critical Commands to Test:
- `source ~/.zshrc` (should load cleanly)
- `reload` alias (should work)
- Custom functions from functions/ directory
- Scripts from scripts/ directory
- Tools from bin/ directory

## Compatibility Notes

### Keep During Migration:
- **oh-my-zsh dependency**: Don't remove during migration
- **All current aliases**: Even if they seem redundant
- **All current functions**: Even if they seem unused
- **Complete Brewfile**: All packages, even development-specific ones
- **Vendor scripts**: All third-party integrations

### Environment Considerations:
- **macOS focused**: Current setup is heavily macOS-oriented
- **Homebrew dependent**: Many scripts assume Homebrew availability
- **Development tools**: Android SDK, various programming languages
- **Terminal integrations**: iTerm2, fzf, various CLI tools

## Handoff Requirements

Each AI agent session should:
1. **Update TODO list**: Mark completed tasks, add new discoveries
2. **Document issues**: Any problems found during migration
3. **Create NEXT_STEPS.md**: Clear instructions for next session
4. **Test before handoff**: Verify current state works
5. **Preserve working state**: Don't leave system in broken state

## Anti-Patterns to Avoid

- **Don't simplify prematurely**: Keep all current complexity during migration
- **Don't remove dependencies**: Even if they seem unnecessary
- **Don't combine steps**: Each phase should be complete and tested
- **Don't hardcode paths**: Use variables and detection
- **Don't break existing workflows**: User should be able to continue working

## Current Session Scope

**Phase 1-2.5 Only**:
- Reset dotfiler folder
- Create planning documents
- Copy and reorganize all files
- Create handoff documentation
- **STOP before Phase 3**: Don't move folder or initialize git

Next AI agent will handle moving dotfiler to independent location and git setup.