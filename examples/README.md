# Example Configuration Templates

This directory contains template files for setting up private dotfiles with sensitive credentials.

## Available Templates

### Claude Desktop MCP
**File**: `claude-desktop-config.example.json`
**Purpose**: Configuration for Claude Desktop Model Context Protocol servers
**Target**: `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS)

**Usage**:
```bash
mkdir -p dotfiles-private/claude-desktop
cp examples/claude-desktop-config.example.json \
   dotfiles-private/claude-desktop/config.json
vim dotfiles-private/claude-desktop/config.json  # Add your credentials
```

### SSH Configuration
**File**: `ssh-config.example`
**Purpose**: SSH client configuration with multiple identities
**Target**: `~/.ssh/config`

**Usage**:
```bash
mkdir -p dotfiles-private/ssh
cp examples/ssh-config.example dotfiles-private/ssh/config
vim dotfiles-private/ssh/config  # Customize for your hosts
```

### AWS Credentials
**File**: `aws-credentials.example`
**Purpose**: AWS access keys for multiple profiles
**Target**: `~/.aws/credentials`

**Usage**:
```bash
mkdir -p dotfiles-private/aws
cp examples/aws-credentials.example dotfiles-private/aws/credentials
vim dotfiles-private/aws/credentials  # Add your AWS keys
```

### AWS Configuration
**File**: `aws-config.example`
**Purpose**: AWS CLI configuration (regions, output format)
**Target**: `~/.aws/config`

**Usage**:
```bash
mkdir -p dotfiles-private/aws
cp examples/aws-config.example dotfiles-private/aws/config
vim dotfiles-private/aws/config  # Customize regions/settings
```

## General Workflow

1. **Copy template** from `examples/` to `dotfiles-private/<app>/`
2. **Edit** with your actual credentials
3. **Verify mapping** exists in `mappings.yaml` (or add it)
4. **Run** `./install.sh` to create symlinks

## Security Notes

- ✅ Files in `dotfiles-private/` are git-ignored
- ✅ Your credentials are never committed to version control
- ✅ Example files contain no real credentials
- ❌ Never commit real credentials to this or any repository

## Adding New Templates

To add a template for a new application:

1. **Create example file** in this directory:
   ```bash
   vim examples/myapp-config.example.yml
   ```

2. **Add mapping** to `mappings.template.yaml`:
   ```yaml
   private:
     - source: myapp/config.yml
       target: ~/.config/myapp/config.yml
       platform: common
   ```

3. **Regenerate** mappings:
   ```bash
   ./init.sh
   ```

4. **Document usage** in this README

## See Also

- [PRIVATE-DOTFILES-QUICKSTART.md](../PRIVATE-DOTFILES-QUICKSTART.md) - Quick setup guide
- [docs/PRIVATE-DOTFILES.md](../docs/PRIVATE-DOTFILES.md) - Comprehensive guide
- [mappings.template.yaml](../mappings.template.yaml) - All platform mappings
