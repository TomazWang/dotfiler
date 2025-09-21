# Next Steps for Dotfiler Migration

## Current Status: Phase 2.5 Complete ✅

**Migration Phase 1-2.5 has been completed successfully.**

### What Was Accomplished:

✅ **Phase 1: Reset and Planning**
- Cleared previous dotfiler attempts
- Created comprehensive CLAUDE.md with migration context
- Created PRD.md with requirements and goals
- Created MIGRATION_PLAN.md with detailed roadmap

✅ **Phase 2: Copy and Reorganize**
- Created complete directory structure
- Copied all files from ~/.shell with reorganization
- Renamed `bootstrap/` to `dotfiles/` for clarity
- Created ghostty directory structure (folder only, no config file yet)
- Verified all files copied correctly

### Current Directory Structure:

```
dotfiler/
├── CLAUDE.md              # Context for AI agents
├── PRD.md                 # Product requirements
├── MIGRATION_PLAN.md      # Complete migration roadmap
├── NEXT_STEPS.md          # This file
├── install.sh             # Installation script (needs updates)
├── dotfiles/              # Files to be symlinked
│   ├── zshrc             # → ~/.zshrc
│   └── ghostty/          # → ~/.config/ghostty/
│       └── themes/       # (empty, ready for themes)
├── shell/                 # Shell runtime configs (sourced)
│   ├── load.sh           # Main orchestrator (copied from apply.sh)
│   ├── configs/          # alias.sh, exports.sh
│   ├── functions/        # All function libraries
│   ├── scripts/          # Complex scripts
│   └── utils/            # Utility scripts
├── bin/                   # User executables
│   ├── git-commands/     # Git utilities
│   ├── leavemealone      # Custom scripts
│   ├── nnn_copier
│   └── shelp-build
├── packages/              # Dependency management
│   └── Brewfile          # Complete package manifest
└── vendor/                # Third-party code
    ├── forgit.zsh
    ├── themes/           # Spaceship, pure themes
    ├── z.sh
    └── zsh-interactive-cd.zsh
```

### File Migration Verification:

**All files successfully copied and reorganized:**
- ✅ `zshrc` → `dotfiles/zshrc`
- ✅ `apply.sh` → `shell/load.sh`
- ✅ `install.sh` → `install.sh` (root level)
- ✅ `configs/` → `shell/configs/` (alias.sh, exports.sh)
- ✅ `functions/` → `shell/functions/` (15 files including claude_wrapper.sh, shelp.sh, etc.)
- ✅ `scripts/` → `shell/scripts/` (10 files including shell_fzf.sh, shell_fnm.sh, etc.)
- ✅ `utils/` → `shell/utils/` (4 CLI loader scripts)
- ✅ `bin/` → `bin/` (6 executable tools)
- ✅ `Brewfile` → `packages/Brewfile` (complete package manifest)
- ✅ `vendor/` → `vendor/` (7 third-party scripts and themes)

---

## Phase 3: Independent Project Setup 🚀

**Next AI Agent Tasks:**

### 3.1 Move to Independent Location
```bash
# Move dotfiler out of ~/.shell
mv ~/.shell/dotfiler ~/dotfiler

# Verify move completed
ls ~/dotfiler
```

### 3.2 Initialize Git Repository
```bash
cd ~/dotfiler

# Initialize git
git init

# Create .gitignore
cat > .gitignore << 'EOF'
# Temporary files
*.tmp
*.log
.DS_Store

# Backup files
*.backup
*.bak

# Local environment files
.env.local
EOF

# Initial commit
git add .
git commit -m "Initial dotfiler migration from ~/.shell

- Reorganized from original ~/.shell structure
- Renamed bootstrap/ to dotfiles/ for clarity
- Preserved all existing functionality
- Created comprehensive documentation"
```

### 3.3 Verification
```bash
# Verify structure
find ~/dotfiler -type f | wc -l  # Should be ~50+ files

# Check critical files exist
ls ~/dotfiler/dotfiles/zshrc
ls ~/dotfiler/shell/load.sh
ls ~/dotfiler/packages/Brewfile
```

---

## Phase 4: Script Refactoring 🔧

**Critical Updates Required:**

### 4.1 Update shell/load.sh
**Current issue**: References old directory structure

```bash
# CHANGE FROM:
for dir in "configs" "functions" "scripts" "utils"; do

# CHANGE TO:
for dir in "shell/configs" "shell/functions" "shell/scripts" "shell/utils"; do
```

### 4.2 Update dotfiles/zshrc
**Current issue**: Still calls apply.sh

```bash
# FIND this line in dotfiles/zshrc:
source "$HOME/.shell/apply.sh"

# CHANGE TO:
source "$HOME/.dotfiles/shell/load.sh"  # or wherever dotfiler is installed
```

### 4.3 Update install.sh
**Critical changes needed:**

```bash
# Update symlink targets:
# OLD: ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
# NEW: ln -sf "$DOTFILES_DIR/dotfiles/zshrc" "$HOME/.zshrc"

# Add new symlinks:
ln -sf "$DOTFILES_DIR/dotfiles/ghostty" "$HOME/.config/ghostty"
```

### 4.4 Update DOTFILES_DIR variable
**In install.sh and other scripts:**
```bash
# Change from: DOTFILES_DIR="$HOME/.shell"
# Change to: DOTFILES_DIR="$HOME/dotfiler"  # or wherever installed
```

---

## Testing Checklist 📋

**After each phase, verify:**

### Functionality Tests:
- [ ] Fresh shell session starts without errors
- [ ] `reload` alias works
- [ ] Custom git functions available (from shell/functions/fn_git.sh)
- [ ] All aliases from shell/configs/alias.sh work
- [ ] Environment variables from shell/configs/exports.sh loaded
- [ ] Tools from bin/ directory available in PATH

### Installation Tests:
- [ ] `./install.sh` runs without errors
- [ ] Symlinks created correctly:
  - [ ] `~/.zshrc` → `dotfiler/dotfiles/zshrc`
  - [ ] `~/.config/ghostty` → `dotfiler/dotfiles/ghostty`
- [ ] Brewfile installation works: `brew bundle --file=packages/Brewfile`

### Critical Commands to Test:
```bash
# Basic shell functionality
source ~/.zshrc
reload

# Custom functions
git-cof  # Custom git function
shelp    # Shell help function

# Environment
echo $ANDROID_HOME  # Should be set from exports.sh
which leavemealone  # Should find bin/ script
```

---

## Known Issues & Considerations 🚨

### Path Dependencies:
- Many scripts may have hardcoded `~/.shell` paths
- Search for and update any remaining references:
  ```bash
  grep -r "\.shell" ~/dotfiler/
  ```

### Oh-My-Zsh Dependency:
- Current setup heavily depends on oh-my-zsh
- **Do not remove during migration** - preserve all functionality
- Spaceship theme integration in vendor/themes/

### Homebrew Integration:
- Brewfile contains 100+ packages - keep all during migration
- Scripts expect Homebrew to be available
- Android SDK paths in exports.sh are macOS-specific

### Testing Environment:
- Test on clean shell session: `zsh --no-rcs`
- Verify no broken symlinks: `find ~ -xtype l`
- Check for missing files: Look for "file not found" errors

---

## Future Enhancements (Phase 5) 🔮

### Planned Additions:
- **Ghostty config file**: Create actual config content in dotfiles/ghostty/config
- **Claude settings**: Gather from ~/.claude/settings.json
- **Git configuration**: Add global .gitconfig
- **Enhanced documentation**: Usage guides and maintenance docs

### Git Workflow:
- Set up development branches
- Create update mechanisms
- Add commit hooks for validation

---

## Emergency Rollback 🆘

**If something breaks:**

1. **Original ~/.shell is untouched** - you can still use it
2. **Restore symlinks:**
   ```bash
   ln -sf ~/.shell/zshrc ~/.zshrc
   source ~/.zshrc
   ```
3. **Check logs:** Look for error messages in terminal output
4. **Incremental testing:** Test one component at a time

---

**Ready for Phase 3! The foundation is solid and all files are properly organized.** 🎉