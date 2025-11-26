# Private Dotfiles Guide

This guide explains how to safely manage sensitive configuration files and credentials using dotfiler's private dotfiles feature.

## Overview

The `dotfiles-private/` directory allows you to:
- Store sensitive credentials (API keys, tokens, passwords)
- Manage private configs that shouldn't be in version control
- Keep configs portable across machines
- Maintain security while using dotfiles management

## Security Principles

**SAFE**: Files in `dotfiles-private/` are git-ignored
**SAFE**: Never committed to version control
**SAFE**: Only stored locally on your machine
**NOT SAFE**: For production system credentials (use secrets manager instead)

## Quick Start

### 1. Set Up Claude Desktop MCP Credentials

```bash
# Create directory
mkdir -p dotfiles-private/claude-desktop

# Copy example template
cp dotfiles/claude-desktop-config.example.json \
   dotfiles-private/claude-desktop/config.json

# Edit with your actual credentials
vim dotfiles-private/claude-desktop/config.json
```

Example config with real credentials:
```json
{
  "mcpServers": {
    "gsuite-mcp": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-google-drive"],
      "env": {
        "GOOGLE_CLIENT_ID": "123456789-abc.apps.googleusercontent.com",
        "GOOGLE_CLIENT_SECRET": "GOCSPX-YourActualSecretHere"
      }
    }
  }
}
```

Run `./install.sh` to create the symlink to `~/Library/Application Support/Claude/claude_desktop_config.json`

### 2. Set Up SSH Config

```bash
# Create directory
mkdir -p dotfiles-private/ssh

# Copy example
cp dotfiles/ssh-config.example dotfiles-private/ssh/config

# Edit with your hosts
vim dotfiles-private/ssh/config
```

Run `./install.sh` to link to `~/.ssh/config`

### 3. Set Up AWS Credentials

```bash
# Create directory
mkdir -p dotfiles-private/aws

# Copy examples
cp dotfiles/aws-credentials.example dotfiles-private/aws/credentials
cp dotfiles/aws-config.example dotfiles-private/aws/config

# Edit with your credentials
vim dotfiles-private/aws/credentials
vim dotfiles-private/aws/config
```

Run `./install.sh` to link to `~/.aws/credentials` and `~/.aws/config`

## Supported Configurations

| Config Type | Source | Symlink Target |
|-------------|--------|----------------|
| Claude Desktop | `dotfiles-private/claude-desktop/config.json` | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| SSH | `dotfiles-private/ssh/config` | `~/.ssh/config` |
| AWS Credentials | `dotfiles-private/aws/credentials` | `~/.aws/credentials` |
| AWS Config | `dotfiles-private/aws/config` | `~/.aws/config` |

## Adding New Private Configs

To add support for other applications:

1. **Create a template** in `dotfiles/`:
   ```bash
   # Example: GitHub CLI config
   cat > dotfiles/gh-config.example.yml <<EOF
   # GitHub CLI config template
   git_protocol: ssh
   editor: vim
   EOF
   ```

2. **Update install.sh** to handle the new config:
   ```bash
   # Add to the private dotfiles section in install.sh
   link_private_dotfile \
       "$PRIVATE_DIR/gh/config.yml" \
       "$HOME/.config/gh/config.yml" || \
       info "No GitHub CLI config found in private dotfiles (optional)"
   ```

3. **Document in this guide** for future reference

## Directory Structure

```
dotfiles-private/                    # Git-ignored, safe for credentials
├── .gitkeep                        # Only file tracked in git
├── claude-desktop/
│   └── config.json                 # Claude Desktop MCP config
├── ssh/
│   ├── config                      # SSH client config
│   └── keys/                       # Optional: SSH keys
│       ├── id_ed25519
│       └── id_ed25519.pub
├── aws/
│   ├── credentials                 # AWS access keys
│   └── config                      # AWS profiles/regions
├── gcp/
│   └── service-account.json        # GCP credentials
└── [app-name]/
    └── config-with-secrets.yml
```

## Best Practices

### DO
- Store API keys, tokens, passwords in `dotfiles-private/`
- Use example templates in `dotfiles/` for documentation
- Keep structure organized by application
- Back up `dotfiles-private/` separately (encrypted backup)
- Review what's being linked during `install.sh`

### DON'T
- Commit anything from `dotfiles-private/` to git
- Store production system credentials (use proper secrets management)
- Share `dotfiles-private/` publicly
- Hardcode credentials in shell scripts
- Use for team-shared configs (those belong in `dotfiles/`)

## Backup Strategy

Since `dotfiles-private/` is git-ignored, consider:

1. **Encrypted backups**:
   ```bash
   # Encrypt with GPG
   tar czf - dotfiles-private/ | gpg -e -r your@email.com > dotfiles-private.tar.gz.gpg

   # Decrypt
   gpg -d dotfiles-private.tar.gz.gpg | tar xzf -
   ```

2. **Password manager**: Store small configs/keys in your password manager

3. **Separate private git repo**:
   ```bash
   cd dotfiles-private
   git init
   git remote add origin git@github.com:yourname/dotfiles-private.git  # Private repo!
   git add -A
   git commit -m "Private dotfiles"
   git push -u origin main
   ```

## Multi-Machine Setup

When setting up on a new machine:

1. **Clone main dotfiles**:
   ```bash
   git clone git@github.com:yourname/dotfiler.git ~/dotfiler
   ```

2. **Restore private dotfiles**:
   ```bash
   # Option 1: From encrypted backup
   cd ~/dotfiler
   gpg -d /path/to/dotfiles-private.tar.gz.gpg | tar xzf -

   # Option 2: From private git repo
   cd ~/dotfiler
   git clone git@github.com:yourname/dotfiles-private.git dotfiles-private

   # Option 3: Manually recreate from password manager
   mkdir -p dotfiles-private/claude-desktop
   # ... copy configs from password manager
   ```

3. **Run install**:
   ```bash
   ./install.sh
   ```

## Troubleshooting

### Symlink not created
```bash
# Check if source file exists
ls -la dotfiles-private/claude-desktop/config.json

# Check if parent directory exists
ls -la ~/Library/Application\ Support/Claude/

# Manually create parent if needed
mkdir -p ~/Library/Application\ Support/Claude/

# Re-run install
./install.sh
```

### Changes not taking effect
```bash
# Verify symlink points to correct location
ls -la ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Should show: ... -> /path/to/dotfiler/dotfiles-private/claude-desktop/config.json
```

### Accidentally committed sensitive file
```bash
# Remove from git history (use carefully!)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch dotfiles-private/aws/credentials" \
  --prune-empty --tag-name-filter cat -- --all

# Or use BFG Repo-Cleaner (recommended)
bfg --delete-files credentials
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

Then rotate the exposed credentials immediately!

## Security Checklist

Before committing:
- [ ] `dotfiles-private/` is in `.gitignore`
- [ ] Run `git status` - no sensitive files shown
- [ ] Example files (`.example`) contain no real credentials
- [ ] All credentials are in `dotfiles-private/`, not `dotfiles/`

## Common Use Cases

### Claude Desktop with Multiple MCP Servers
```json
{
  "mcpServers": {
    "gsuite-mcp": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-google-drive"],
      "env": {
        "GOOGLE_CLIENT_ID": "your-id.apps.googleusercontent.com",
        "GOOGLE_CLIENT_SECRET": "your-secret"
      }
    },
    "github-mcp": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_yourtoken"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/yourname/projects",
        "/Users/yourname/documents"
      ]
    }
  }
}
```

### SSH Config with Multiple Identities
```ssh-config
# Personal GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/personal_github

# Work GitHub
Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/work_github

# Personal server
Host homelab
    HostName 192.168.1.100
    User admin
    Port 2222
    IdentityFile ~/.ssh/homelab_key
```

### AWS Multiple Profiles
```ini
# dotfiles-private/aws/credentials
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

[work]
aws_access_key_id = AKIAIOSFODNN7WORK
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYWORKKEY

[personal]
aws_access_key_id = AKIAIOSFODNN7PERSONAL
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYPERSONAL
```

---

**Remember**: The `dotfiles-private/` directory is your safety net for credentials. When in doubt, put sensitive configs there!
