# Brewfile Sync Guide

This guide explains how to keep your Homebrew packages synced with your dotfiles using the built-in Brewfile management system.

## Overview

Your dotfiler includes an **automatic syncing system** that keeps `packages/Brewfile` up-to-date with your installed Homebrew packages. No manual intervention needed - it just works!

## How It Works

### Automatic Syncing (Already Active)

The system runs automatically in the background:

1. **You install/remove packages:**
   ```bash
   brew install ripgrep
   brew uninstall wget
   brew upgrade
   ```

2. **Detection:** A wrapper function detects package-modifying operations and marks Brewfile as "dirty"

3. **Background update:** Before each shell prompt, the system checks if an update is needed (throttled to 24-hour intervals)

4. **Silent sync:** Runs `brew bundle dump` in the background without blocking your shell

5. **Brewfile updated:** Your `packages/Brewfile` is automatically updated with current installations

**That's it!** Just use brew normally and the Brewfile stays synced automatically.

## Manual Commands

### Force Immediate Sync

If you want to update Brewfile right now (skip the 24-hour wait):

```bash
cd ~/dotfiler
brew bundle dump --force --file=packages/Brewfile
```

This overwrites `packages/Brewfile` with everything currently installed.

### Restore Packages from Brewfile

On a new machine or to sync installations with Brewfile:

```bash
# Option 1: Use the installer (recommended)
cd ~/dotfiler
./install.sh

# Option 2: Run brew bundle directly
cd ~/dotfiler
brew bundle --file=packages/Brewfile
```

This installs all packages defined in Brewfile that aren't already installed.

## Checking Sync Status

### Check if Update is Pending

```bash
# See if Brewfile is marked as dirty (needs update)
ls -la ~/.shell/.brewfile_dirty
```

- If exists: Update is pending (will run within 24hrs)
- If missing: Brewfile is current

### Check Last Update Time

```bash
# View timestamp of last background sync
ls -la ~/.shell/.brew_update_timestamp
```

Shows when the last auto-update ran.

### Compare Installed vs. Brewfile

```bash
cd ~/dotfiler
brew bundle check --file=packages/Brewfile
```

Shows what's missing or extra compared to Brewfile.

## Viewing and Editing

### View Package List

```bash
# See all tracked packages
cat ~/dotfiler/packages/Brewfile

# Or open in editor
vim ~/dotfiler/packages/Brewfile
```

### Manual Editing (Advanced)

You can manually edit Brewfile, but be careful:

```bash
# Edit Brewfile
vim ~/dotfiler/packages/Brewfile

# After manual edits, install new packages
cd ~/dotfiler
brew bundle --file=packages/Brewfile
```

**Warning:** Manual `brew bundle dump` will overwrite your edits with actual installed packages.

## Troubleshooting

### Auto-Sync Seems Stuck

Force an immediate sync and reset throttle:

```bash
# Force immediate sync
cd ~/dotfiler
brew bundle dump --force --file=packages/Brewfile

# Remove throttle to allow immediate next update
rm -f ~/.shell/.brew_update_timestamp ~/.shell/.brewfile_dirty
```

### Enable Verbose Logging

See what's happening during sync:

```bash
# Enable verbose mode
export ZSHRC_VERBOSE=1
source ~/.zshrc

# Now you'll see logs like:
# [brew_auto_update] Brewfile is dirty, updating...
# [brew_auto_update] Running brew bundle dump...
```

### Brewfile Not Updating

Check if the wrapper function is active:

```bash
# Should show function definition
type brew

# Should show the wrapper from brew_functions.sh
# If it just shows "brew is /opt/homebrew/bin/brew", the wrapper isn't loaded
```

If wrapper isn't loaded, reload your shell:

```bash
reload  # or: source ~/.zshrc
```

## Key Files

| File | Purpose | Type |
|------|---------|------|
| `packages/Brewfile` | Package manifest (244 packages) | Git-tracked |
| `~/.shell/.brewfile_dirty` | Flag: Brewfile needs update | Temporary |
| `~/.shell/.brew_update_timestamp` | Last sync time (24hr throttle) | Temporary |
| `shell/functions/brew_functions.sh` | Wrapper that detects changes | Git-tracked |
| `shell/functions/brew_auto_update.sh` | Background sync process | Git-tracked |

## What's Included in Brewfile

Your Brewfile tracks:

- **15 Taps:** Custom repositories (heroku, mongodb, bun, etc.)
- **68 Brews:** Command-line tools (git, fzf, kubectl, docker, etc.)
- **52 Casks:** GUI applications (VS Code, Docker, Slack, Chrome, etc.)
- **16 Mac App Store apps:** 1Password, DaVinci Resolve, Keynote, etc.
- **174 VS Code extensions:** Complete development environment

Total: **244 packages/extensions** across 5 categories

## Best Practices

### DO

- Let the auto-sync handle updates (it's non-blocking and efficient)
- Commit Brewfile changes to git regularly
- Use `brew bundle dump --force` before setting up a new machine
- Review Brewfile periodically to remove unused packages
- Use `./install.sh` for fresh machine setup

### DON'T

- Edit Brewfile manually unless you know what you're doing
- Delete the throttle files unnecessarily
- Run `brew bundle dump` repeatedly (slows down shell)
- Commit temporary files (.brewfile_dirty, .brew_update_timestamp)

## Common Workflows

### Setting Up a New Machine

```bash
# 1. Clone dotfiler
git clone <your-repo> ~/dotfiler
cd ~/dotfiler

# 2. Initialize and install (includes brew bundle)
./init.sh
./install.sh

# 3. All packages automatically installed!
```

### Before Committing

```bash
# Force sync to ensure Brewfile is current
cd ~/dotfiler
brew bundle dump --force --file=packages/Brewfile

# Review changes
git diff packages/Brewfile

# Commit if changes make sense
git add packages/Brewfile
git commit -m "Update Brewfile with new packages"
```

### Cleaning Up Unused Packages

```bash
# See what's installed but not in Brewfile
cd ~/dotfiler
brew bundle cleanup --file=packages/Brewfile

# Actually remove them (be careful!)
brew bundle cleanup --force --file=packages/Brewfile
```

### Selective Installation

```bash
# Install only CLI tools (skip casks/mas)
brew bundle --file=packages/Brewfile --no-upgrade

# Install without Mac App Store apps
brew bundle --file=packages/Brewfile --no-mas
```

## Advanced Configuration

### Change Update Interval

The 24-hour throttle is defined in `shell/functions/brew_auto_update.sh`:

```bash
# Current: 24 hours (86400 seconds)
local UPDATE_INTERVAL=86400

# Modify to change frequency
# 12 hours: 43200
# 6 hours: 21600
```

### Disable Auto-Sync

If you want to disable automatic updates:

```bash
# Comment out the precmd hook in your zshrc or brew_auto_update.sh
# Or remove the wrapper from brew_functions.sh

# Manual sync only:
brew bundle dump --force --file=~/dotfiler/packages/Brewfile
```

## Technical Details

### How the Wrapper Works

The `brew` command is wrapped by `shell/functions/brew_functions.sh`:

```bash
brew() {
    command brew "$@"
    local exit_code=$?

    # Detect package-modifying operations
    if [[ "$1" =~ ^(install|uninstall|upgrade|tap|untap)$ ]]; then
        # Mark Brewfile as dirty
        touch "$HOME/.shell/.brewfile_dirty"
    fi

    return $exit_code
}
```

### How Background Update Works

The `shell/functions/brew_auto_update.sh` runs via zsh `precmd` hook:

```bash
_update_brewfile_if_needed() {
    # Check if dirty file exists
    # Check if last update was >24hrs ago
    # Run brew bundle dump in background with disown
}

# Runs before each prompt
precmd_functions+=(_update_brewfile_if_needed)
```

---

**Your system is already working!** Just use `brew` normally and commit `packages/Brewfile` when it changes. The automatic sync keeps everything in sync for you.
