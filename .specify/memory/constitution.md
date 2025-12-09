<!--
  SYNC IMPACT REPORT
  ==================
  Version Change: 1.0.0 → 2.0.0 (MAJOR: Complete restructure from placeholder template)

  Modified Principles:
  - [NEW] I. Zero Magic
  - [NEW] II. Portable First
  - [NEW] III. Organized by Purpose
  - [NEW] IV. Preserve Functionality
  - [NEW] V. Evidence-Based Development

  Added Sections:
  - Core Principles (5 principles from .ai/instructions.md)
  - Development Standards (shell conventions, safety, feedback)
  - AI Agent Protocol
  - Speckit-Specific Configuration

  Removed Sections:
  - All placeholder template sections

  Templates Status:
  - .specify/templates/plan-template.md ✅ Compatible (Constitution Check section aligns)
  - .specify/templates/spec-template.md ✅ Compatible (no constitution-specific references)
  - .specify/templates/tasks-template.md ✅ Compatible (no constitution-specific references)

  Follow-up TODOs: None
-->

# Dotfiler Constitution

> **Source of Truth**: [`.ai/instructions.md`](../../.ai/instructions.md)
>
> This constitution derives principles from the main AI instructions file. For complete project documentation including architecture, workflows, and common tasks, always refer to `.ai/instructions.md`.

## Core Principles

### I. Zero Magic

Every operation MUST be explicit, understandable, and debuggable.

- No hidden behavior or implicit configuration
- All operations produce visible, traceable output
- When something happens, users can understand why

### II. Portable First

The system MUST work on any Unix system (macOS, Linux) with standard tools only.

- Scripts use auto-detection instead of hardcoded paths
- No platform-specific assumptions without explicit checks
- Fallbacks for missing optional tools

### III. Organized by Purpose

Files MUST be organized by what they DO, not what they ARE.

- `shell/functions/` for shell functions
- `shell/scripts/` for complex scripts
- `shell/configs/` for configuration (exports, aliases)
- `bin/` for executables

### IV. Preserve Functionality

During migration or changes, MUST maintain 100% of existing functionality.

- Never remove code that "seems unused" without verification
- Keep all Brewfile packages, vendor scripts, existing functions
- Document any intentional removals with rationale

### V. Evidence-Based Development

All changes MUST be verified with actual evidence.

- Check actual state before giving advice
- Show evidence: "I checked X by running Y, found Z"
- No assumptions about "typical" setups
- Test changes and verify they work

## Development Standards

### Shell Function Standards

1. **Verbosity logging**: Use `SHELL_VERBOSE` pattern for debuggability
2. **Error handling**: Return non-zero exit codes, provide helpful messages
3. **Safety checks**: Validate paths, confirm destructive operations
4. **User feedback**: Use emoji-based status indicators (🔄, ✓, ❌, ⚠️)

### Safety Rules

- ❌ Don't hardcode paths - Use `$DOTFILES_DIR`, `$DOTFILER_ROOT`, `$HOME`
- ❌ Don't use git commands without explicit user request
- ❌ Don't remove "unused" code during migration
- ✅ Follow existing patterns - Check similar functions for conventions
- ✅ Add safety checks - Validate paths, confirm destructive operations
- ✅ Provide clear feedback - Emoji status, helpful error messages

## AI Agent Protocol

All AI agents working on this project MUST:

1. **Read `.ai/instructions.md`** before making changes
2. **Verify before advising** - Run diagnostic commands first
3. **Never use git commands** unless explicitly requested by user
4. **Preserve working state** - Don't leave system in broken state

## Speckit-Specific Configuration

### Constitution Check Gates

When running `/speckit.plan`, verify:

- [ ] Changes follow Zero Magic principle (explicit, traceable)
- [ ] No hardcoded paths introduced
- [ ] Existing functionality preserved
- [ ] Changes tested with evidence

### Task Categories

Align with dotfiler structure:

- **Shell functions**: `shell/functions/*.sh`
- **Scripts**: `shell/scripts/*.sh`
- **Configurations**: `shell/configs/*.sh`
- **Executables**: `bin/*`
- **Dotfiles**: `dotfiles/*`

## Governance

This constitution:

- References `.ai/instructions.md` as the authoritative source
- Supersedes any conflicting local guidance
- Amendments require updating both this file and `.ai/instructions.md` if principles change

**Version**: 2.0.0 | **Ratified**: 2025-12-09 | **Last Amended**: 2025-12-09
