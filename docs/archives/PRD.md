# Dotfiler: Zero-Magic Portable Dotfiles System

## Product Requirements Document

### Project Status: Migration Phase
This PRD defines the target state for a migration project from an existing ~/.shell dotfiles repository to a clean, organized dotfiler system.

### Overview
Dotfiler is a portable, zero-magic dotfiles management system designed for developers who want a clean, predictable setup that works on any Unix-like machine without complex dependencies or frameworks.

### Core Principles
1. **Zero Magic**: Every operation is explicit and understandable
2. **Portable**: Works on any Unix system (macOS, Linux) without special tools
3. **Predictable**: Clear file organization and consistent behavior
4. **Minimal**: No unnecessary dependencies or frameworks
5. **Resilient**: Graceful fallbacks when tools aren't available
6. **Migration Safe**: Preserve 100% of existing functionality during transition

### Migration Goals
1. **Reorganize for clarity**: Transform current structure into purpose-based organization
2. **Maintain functionality**: Keep all existing aliases, functions, and scripts working
3. **Preserve dependencies**: Don't remove oh-my-zsh, Brewfile packages, or vendor code during migration
4. **Enable future enhancements**: Create structure that supports clean additions
5. **Provide clear handoffs**: Enable multiple AI agents to work on different phases

### Current State Analysis

#### Existing ~/.shell Structure (Source):
```
~/.shell/
├── zshrc              # Main zsh config with oh-my-zsh
├── apply.sh           # Sources all shell configs
├── install.sh         # Installation and symlinking
├── configs/           # alias.sh, exports.sh
├── functions/         # Shell function libraries
├── scripts/           # Complex shell scripts
├── utils/             # Utility scripts
├── bin/               # Executable scripts
├── Brewfile           # Complete package manifest
└── vendor/            # Third-party code (themes, etc.)
```

#### Target dotfiler Structure:
```
dotfiler/
├── install.sh              # One-command setup
├── bootstrap/              # Entry point files → symlinked to ~/
│   ├── zshrc              # → ~/.zshrc
│   └── [future dotfiles]
├── shell/                  # Runtime shell configs → sourced
│   ├── load.sh            # Main orchestrator
│   ├── configs/           # Environment, aliases
│   ├── functions/         # Function libraries
│   ├── scripts/           # Complex scripts
│   └── utils/             # Utility scripts
├── config/                 # App config dirs → ~/.config/
│   └── ghostty/           # Terminal configuration
│       ├── config
│       └── themes/
├── bin/                    # User executables → PATH
├── packages/               # Dependency manifests
│   └── Brewfile           # Package management
└── vendor/                 # Third-party code
```

### Migration Strategy

#### Phase 1: Reset and Planning
- Clear any previous migration attempts
- Create comprehensive planning documents
- Define clear handoff procedures

#### Phase 2: Copy and Reorganize
- Copy all files from ~/.shell to dotfiler with new organization
- Preserve every file and configuration
- Create basic app config structure (ghostty)

#### Phase 3: Independent Project Setup
- Move dotfiler to independent location
- Initialize git repository for version control
- Set up proper project structure

#### Phase 4: Script Refactoring
- Update all path references for new structure
- Modify loading mechanisms to work with reorganization
- Test all functionality works correctly

#### Phase 5: Enhancement and Polish
- Add new application configurations
- Implement git workflow
- Gather additional configs (Claude settings, etc.)
- Final testing and documentation

### Technical Requirements

#### Must Preserve During Migration
1. **Complete oh-my-zsh setup**: All themes, plugins, and configurations
2. **All shell functions**: Even if they appear unused
3. **Complete Brewfile**: All packages and taps
4. **All vendor integrations**: Spaceship theme, z.sh, etc.
5. **All custom scripts**: Development tools, utilities, etc.
6. **PATH modifications**: All bin/ directory additions
7. **Environment variables**: Android SDK paths, etc.

#### Must Update During Refactoring
1. **Directory references**: configs/ → shell/configs/
2. **Source calls**: apply.sh → shell/load.sh
3. **Symlink targets**: zshrc → bootstrap/zshrc
4. **Script paths**: Update relative path references

#### Must Add During Enhancement
1. **Ghostty configuration**: Terminal setup
2. **Additional app configs**: Claude settings, etc.
3. **Git workflow**: Repository management
4. **Documentation**: Usage and maintenance guides

### File Organization Logic

#### Purpose-Based Categories:
- **`bootstrap/`**: Files that applications read directly (symlinked to ~/)
- **`shell/`**: Runtime configurations loaded at shell startup (sourced)
- **`config/`**: Application config directories (symlinked to ~/.config/)
- **`bin/`**: User executables (added to PATH)
- **`packages/`**: Dependency manifests (used by package managers)
- **`vendor/`**: Third-party code (sourced or referenced)

#### Loading Flow:
1. Application (zsh) reads `~/.zshrc` (symlinked from `bootstrap/zshrc`)
2. `bootstrap/zshrc` sources `shell/load.sh`
3. `shell/load.sh` auto-discovers and sources all shell configs
4. User gets fully configured shell environment

### Success Criteria

#### Phase Completion:
- [ ] All existing functionality preserved
- [ ] Clean directory organization implemented
- [ ] No broken references or missing files
- [ ] Shell loads without errors or warnings
- [ ] All aliases and functions available
- [ ] Installation script works correctly

#### Migration Validation:
- [ ] Fresh shell startup completes successfully
- [ ] `reload` alias works
- [ ] Custom git functions accessible
- [ ] Development tools available
- [ ] PATH includes bin/ directory
- [ ] Homebrew packages installable

#### Quality Gates:
- [ ] No hardcoded paths in scripts
- [ ] All file references use variables
- [ ] Proper error handling in load scripts
- [ ] Clean handoff documentation created
- [ ] Test procedures defined and passed

### Risk Mitigation

#### Backup Strategy:
- Original ~/.shell remains untouched during migration
- Each phase creates working state before proceeding
- Clear rollback procedures documented

#### Testing Strategy:
- Incremental testing after each change
- Fresh shell session validation
- Key workflow verification
- Clean system installation testing

#### Handoff Strategy:
- Comprehensive status documentation
- Clear next steps definition
- Issue and consideration logging
- Working state verification

### Future Enhancements (Post-Migration)

#### Planned Additions:
- Additional application configurations
- Cross-platform compatibility improvements
- Package manager abstraction
- Encrypted secrets management
- Multiple profile support

#### Maintenance Features:
- Automatic backup creation
- Configuration validation
- Dependency health checks
- Update mechanisms

### Non-Goals (During Migration)

- Removing oh-my-zsh dependency
- Simplifying existing configurations
- Reducing package dependencies
- Changing existing workflows
- Performance optimizations
- Cross-platform adaptations

The migration focuses solely on reorganization while preserving all existing functionality and dependencies.