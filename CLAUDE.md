# Claude AI Assistant Context for Dotfiler

> **📋 For complete project instructions, see [`.ai/instructions.md`](.ai/instructions.md)**

This file provides Claude-specific context and handoff procedures.

## Quick Reference

All comprehensive project documentation is centralized in `.ai/instructions.md`, including:
- Architecture and file organization
- Development workflows and key commands
- Project-specific conventions
- Common tasks and debugging
- Migration context and philosophy

## Claude-Specific Guidelines

### Session Handoff Requirements

Each AI agent session should:
1. **Update TODO list**: Mark completed tasks, add new discoveries
2. **Document issues**: Any problems found during work
3. **Test before handoff**: Verify current state works
4. **Preserve working state**: Don't leave system in broken state

### Critical Reminders

⚠️ **Git Operations**: Never use git commands unless explicitly requested by the user
⚠️ **Path Detection**: Always use auto-detection patterns (see `.ai/instructions.md`)
⚠️ **Preserve Everything**: Don't remove code that seems unused - this is a migration-in-progress

### Current Session Context

**Status**: Post-migration, feature development phase
**Current Branch**: `feature/claude-code-update-function`
**Active PR**: #11 - Add claude-update function

For detailed project information, always refer to `.ai/instructions.md` first.