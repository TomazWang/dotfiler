# Private Dotfiles Quick Start

> **TL;DR**: Store sensitive configs in `dotfiles-private/`, configure mappings in `mappings.yaml`, they're git-ignored and safe.

## Claude Desktop MCP Setup (Most Common)

```bash
# 1. Create directory
mkdir -p dotfiles-private/claude-desktop

# 2. Copy example
cp examples/claude-desktop-config.example.json \
   dotfiles-private/claude-desktop/config.json

# 3. Edit with your real credentials
vim dotfiles-private/claude-desktop/config.json

# 4. Verify mapping exists in mappings.yaml (already included by default)
# The mapping for Claude Desktop is pre-configured with platform detection

# 5. Run install to create symlink
./install.sh
```

**Platform-aware linking:**
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Linux: `~/.config/claude/claude_desktop_config.json`

## What Gets Linked

All mappings are configured in **`mappings.yaml`**. Pre-configured mappings include:

| Your File | → | System Location |
|-----------|---|-----------------|
| `dotfiles-private/claude-desktop/config.json` | → | `~/Library/Application Support/Claude/...` (macOS)<br>`~/.config/claude/...` (Linux) |
| `dotfiles-private/ssh/config` | → | `~/.ssh/config` |
| `dotfiles-private/aws/credentials` | → | `~/.aws/credentials` |
| `dotfiles-private/aws/config` | → | `~/.aws/config` |

## Adding New Private Configs

1. Create file in `dotfiles-private/<app-name>/`
2. Add mapping to `mappings.yaml`:
   ```yaml
   private:
     - source: <app-name>/config.json
       target: ~/.config/<app-name>/config.json
       platform: common
   ```
3. Run `./install.sh`

## Security

- `dotfiles-private/` is in `.gitignore` - safe for credentials
- Only `.gitkeep` is tracked in git
- All actual config files are ignored
- Platform detection ensures correct paths

## Need More Info?

- **Quick editing**: `vim mappings.yaml` to see/modify all mappings
- **Complete guide**: See [`docs/PRIVATE-DOTFILES.md`](docs/PRIVATE-DOTFILES.md) for:
  - Backup strategies
  - Multi-machine setup
  - Troubleshooting
  - Common use cases

## Example Templates

Look in `examples/` directory for templates:
- `claude-desktop-config.example.json` - Claude Desktop MCP
- `ssh-config.example` - SSH configuration
- `aws-credentials.example` - AWS credentials
- `aws-config.example` - AWS configuration
