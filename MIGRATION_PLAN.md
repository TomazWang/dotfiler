# Dotfiler Migration Plan

## Overview
Complete migration plan for transforming existing ~/.shell dotfiles repository into organized dotfiler system. This document provides detailed steps for AI agents working on different phases.

## Phase Breakdown

### Phase 1: Reset and Planning ✅ COMPLETED
**Responsible**: Current AI agent
**Status**: ✅ COMPLETED

Tasks:
- [x] Clear dotfiler folder of previous incorrect attempts
- [x] Create new CLAUDE.md with migration context
- [x] Create new PRD.md with requirements and goals
- [x] Create this MIGRATION_PLAN.md for future AI agents

### Phase 2: Copy and Reorganize 🔄 IN PROGRESS
**Responsible**: Current AI agent
**Status**: 🔄 IN PROGRESS

Tasks:
- [ ] Create directory structure in dotfiler/
- [ ] Copy all files from ~/.shell/ with reorganization
- [ ] Create basic application configs (ghostty)
- [ ] Verify all files copied correctly

#### Directory Structure to Create:
```
dotfiler/
├── bootstrap/              # Entry point files
│   └── ghostty/           # New terminal config
├── shell/                  # Shell runtime configs
│   ├── configs/           # From current configs/
│   ├── functions/         # From current functions/
│   ├── scripts/           # From current scripts/
│   └── utils/             # From current utils/
├── bin/                    # From current bin/
├── packages/               # Dependency management
└── vendor/                 # From current vendor/
```

#### File Copy Operations:
| Source | Destination | Notes |
|--------|-------------|-------|
| `zshrc` | `bootstrap/zshrc` | Entry point file |
| `apply.sh` | `shell/load.sh` | Rename for clarity |
| `install.sh` | `install.sh` | Root level script |
| `configs/` | `shell/configs/` | Shell configurations |
| `functions/` | `shell/functions/` | Function libraries |
| `scripts/` | `shell/scripts/` | Complex scripts |
| `utils/` | `shell/utils/` | Utility scripts |
| `bin/` | `bin/` | Direct copy |
| `Brewfile` | `packages/Brewfile` | Package manifest |
| `vendor/` | `vendor/` | Direct copy |

### Phase 2.5: Handoff Preparation 📋 PENDING
**Responsible**: Current AI agent
**Status**: 📋 PENDING

Tasks:
- [ ] Create NEXT_STEPS.md with detailed instructions
- [ ] Document any issues found during copy
- [ ] Verify copied files are complete and correct
- [ ] Create testing checklist for next AI agent
- [ ] Update this plan with current status

**STOP POINT**: Current AI agent stops here. Next AI agent continues from Phase 3.

---

### Phase 3: Independent Project Setup 🔜 FUTURE
**Responsible**: Next AI agent
**Status**: 🔜 WAITING

Tasks:
- [ ] Move dotfiler/ to independent location (e.g., ~/dotfiler)
- [ ] Initialize git repository in new location
- [ ] Create initial commit with all migrated files
- [ ] Set up .gitignore file
- [ ] Verify project structure is correct

#### Prerequisites:
- Phase 2.5 completed successfully
- NEXT_STEPS.md provides clear instructions
- All files copied and verified

#### Location Strategy:
- Target: `~/dotfiler` (independent of ~/.shell)
- Backup: Keep ~/.shell untouched during testing
- Testing: Verify installation works from new location

### Phase 4: Script Refactoring 🔧 FUTURE
**Responsible**: Next AI agent
**Status**: 🔧 WAITING

Tasks:
- [ ] Update shell/load.sh path references
- [ ] Modify bootstrap/zshrc to call shell/load.sh
- [ ] Update install.sh for new directory structure
- [ ] Fix any broken path references in scripts
- [ ] Test complete workflow end-to-end

#### Critical Updates Needed:

**shell/load.sh** (copied from apply.sh):
```bash
# CHANGE FROM:
for dir in "configs" "functions" "scripts" "utils"; do

# CHANGE TO:
for dir in "shell/configs" "shell/functions" "shell/scripts" "shell/utils"; do
```

**bootstrap/zshrc** (copied from zshrc):
```bash
# CHANGE FROM:
source "$HOME/.shell/apply.sh"

# CHANGE TO:
source "$HOME/.dotfiles/shell/load.sh"  # or wherever dotfiler is installed
```

**install.sh**:
- Update symlink source: `bootstrap/zshrc` → `~/.zshrc`
- Add new symlinks for config/ directory
- Update all path references

#### Testing Requirements:
- [ ] Fresh shell session starts without errors
- [ ] All aliases and functions available
- [ ] Custom scripts work correctly
- [ ] PATH includes bin/ directory
- [ ] Installation script works on clean system

### Phase 5: Enhancement 🚀 FUTURE
**Responsible**: Next AI agent
**Status**: 🚀 WAITING

Tasks:
- [ ] Implement proper git workflow
- [ ] Enhance ghostty configuration
- [ ] Gather Claude settings from ~/.claude/
- [ ] Add other application configurations
- [ ] Create comprehensive documentation
- [ ] Final testing and validation

#### New Configurations to Add:
- **Claude settings**: From ~/.claude/settings.json
- **Git configuration**: Global .gitconfig
- **SSH configuration**: If applicable
- **Terminal themes**: Extended ghostty themes
- **Additional applications**: Based on user needs

#### Git Workflow:
- [ ] Set up branching strategy
- [ ] Create development workflow
- [ ] Add commit hooks if needed
- [ ] Document update procedures

## Handoff Protocol

### Between Phase Sessions:
1. **Status Update**: Current AI agent updates this document
2. **Issue Log**: Document any problems encountered
3. **Next Steps**: Create detailed NEXT_STEPS.md file
4. **Verification**: Test current state works correctly
5. **Clean State**: Don't leave system in broken state

### Required Handoff Documents:
- **NEXT_STEPS.md**: Immediate actions for next AI agent
- **ISSUES.md**: Problems found and solutions attempted
- **STATUS.md**: Current state summary
- **TESTING.md**: Validation procedures and results

## Risk Management

### Backup Strategy:
- Original ~/.shell remains untouched
- Each phase creates stable checkpoint
- Clear rollback procedures documented

### Validation Points:
- End of each phase: full functionality test
- Before handoff: comprehensive validation
- After critical changes: immediate testing

### Failure Recovery:
- Document all issues encountered
- Provide clear recovery steps
- Maintain working state at all times

## Testing Procedures

### Phase 2 Validation:
```bash
# Verify file copy completeness
find ~/.shell -type f | wc -l
find dotfiler/ -type f | wc -l
# Numbers should be close (accounting for new files)

# Check critical files exist
ls dotfiler/bootstrap/zshrc
ls dotfiler/shell/load.sh
ls dotfiler/packages/Brewfile
```

### Phase 4 Validation:
```bash
# Test shell loading
cd ~/dotfiler
source bootstrap/zshrc

# Test critical functions
which reload
git # Should work
# Test custom aliases and functions
```

### Phase 5 Validation:
```bash
# Test fresh installation
cd ~/dotfiler
./install.sh

# Start new shell session
# Verify all functionality works
```

## Success Criteria

### Overall Migration Success:
- [ ] All original functionality preserved
- [ ] Clean directory organization achieved
- [ ] No broken references or missing files
- [ ] Installation works on fresh system
- [ ] Documentation complete and accurate

### Quality Gates:
- [ ] Shell loads without errors
- [ ] All aliases and functions available
- [ ] Scripts execute correctly
- [ ] PATH modifications work
- [ ] Package installation succeeds

This migration plan ensures systematic, safe transformation of the dotfiles system while preserving all existing functionality.