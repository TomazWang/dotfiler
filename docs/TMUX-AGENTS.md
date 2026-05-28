# Tmux Agent Orchestration

Distributed agent coordination system using tmux panes + Redis message bus.

## Overview

This system allows multiple tmux panes to act as coordinated agents that can:
- Communicate via Redis pub/sub (message bus)
- Send heartbeats for health monitoring
- Auto-respawn when dead
- Know their identity and send targeted commands
- Share state across panes

Perfect for orchestrating multiple AI agents (like Claude Code) working on different git worktrees.

## Quick Start

### 1. Initialize the system

```bash
# In a tmux session
tmux-agents init
```

This will:
- Check dependencies (Redis, tmux)
- Start Redis if not running
- Load pane context helpers

### 2. Start agents

```bash
# Create agents in different worktrees
tmux-agents start agent-1 ~/project/worktree-1
tmux-agents start agent-2 ~/project/worktree-2
tmux-agents start agent-3 ~/project/worktree-3
```

Each agent pane gets:
- Unique pane identifier
- Redis helper functions pre-loaded
- Environment variables for coordination

### 3. Start monitoring

```bash
# In a dedicated pane
tmux-agents monitor
```

The monitor will:
- Check heartbeats every 30 seconds
- Detect dead panes (no heartbeat for 2 minutes)
- Auto-respawn dead panes (when enabled)

### 4. Use agents

In each agent pane:

```bash
# Send heartbeat
tmux-agents heartbeat
# or use the function directly:
tmux_heartbeat "working"

# Broadcast message to all agents
tmux-agents broadcast "Found a bug in auth.ts"

# Listen for messages
tmux-agents listen

# Show pane context
tmux-agents context
```

## Architecture

### Message Bus (Redis)

All communication flows through Redis:

```
┌─────────────────────────────────────────┐
│         Redis Message Bus               │
├─────────────────────────────────────────┤
│  Channels:                              │
│  - tmux:session:<name>:messages         │
│  - tmux:agents:messages                 │
│  - tmux:pane:<id>:messages             │
│                                         │
│  Keys:                                  │
│  - tmux:pane:<id>:heartbeat            │
│  - tmux:pane:<id>:status               │
└─────────────────────────────────────────┘
         ↑           ↑           ↑
         │           │           │
    ┌────┴───┐  ┌───┴────┐  ┌───┴────┐
    │ Agent1 │  │ Agent2 │  │ Agent3 │
    │  Pane  │  │  Pane  │  │  Pane  │
    └────────┘  └────────┘  └────────┘
```

### Pane Identity

Each pane has a unique identifier: `session:window.pane`

Example: `main:1.0` means:
- Session: `main`
- Window: `1`
- Pane: `0`

### Heartbeat System

1. Agents send heartbeats to Redis (key + pub/sub)
2. Monitor checks heartbeats every 30s
3. If no heartbeat for 2 minutes → pane is dead
4. Monitor can auto-respawn dead panes

### Communication Patterns

**Broadcast (one-to-all):**
```bash
# From Agent 1
tmux_broadcast "PR #123 ready for review"

# All agents receive via:
redis-cli subscribe tmux:session:main:messages
```

**Targeted message (one-to-one):**
```bash
# From Agent 1 to Agent 2
tmux_send_message "main:1.1" "Can you review my changes?"
```

**Shared state:**
```bash
# Set shared value
redis-cli set "project:current-sprint" "auth-refactor"

# Get from any pane
redis-cli get "project:current-sprint"
```

## Commands Reference

### tmux-agents CLI

```bash
tmux-agents init              # Initialize system
tmux-agents start <name>      # Start agent in new pane
tmux-agents heartbeat         # Send heartbeat
tmux-agents broadcast <msg>   # Broadcast to all
tmux-agents listen            # Listen for messages
tmux-agents monitor           # Start heartbeat monitor
tmux-agents status            # Show system status
tmux-agents context           # Show pane context
```

### Pane Context Functions

Auto-loaded in each agent pane:

```bash
# Heartbeat
tmux_heartbeat [status]       # Default: "alive"

# Messaging
tmux_broadcast <message>              # To all in session
tmux_send_message <pane-id> <message> # To specific pane

# Redis helpers
tmux_redis_publish <channel> <msg>    # Publish to channel
tmux_redis_set <key> <value> [ttl]    # Set key with expiration
tmux_redis_get <key>                  # Get key value

# Info
tmux_print_context                    # Show pane info
```

### Environment Variables

Auto-set in each pane:

```bash
TMUX_PANE_ID               # %0, %1, etc.
TMUX_PANE_IDENTIFIER       # session:window.pane
TMUX_SESSION_NAME          # Session name
TMUX_WINDOW_INDEX          # Window number
TMUX_PANE_INDEX            # Pane number

REDIS_HEARTBEAT_KEY        # Redis key for heartbeat
REDIS_STATUS_KEY           # Redis key for status
REDIS_MESSAGE_CHANNEL      # Session message channel
REDIS_AGENT_CHANNEL        # Global agent channel
```

## Use Case: Claude Code Agents

### Setup Multiple Worktrees

```bash
# Create worktrees for parallel development
cd ~/project
git worktree add ../project-feature-a feature-a
git worktree add ../project-feature-b feature-b
git worktree add ../project-bugfix-c bugfix-c
```

### Start Claude Code Agents

```bash
# In tmux session
tmux-agents init

# Start agents in different worktrees
tmux-agents start agent-a ~/project-feature-a
tmux-agents start agent-b ~/project-feature-b
tmux-agents start agent-c ~/project-bugfix-c

# Start monitor
tmux-agents monitor
```

### Agent Workflow

In each agent pane:

```bash
# Load pane context (auto-loaded by tmux-agents start)
source ~/dotfiler/shell/scripts/tmux-agents/pane-context.sh

# Start Claude Code
claude-code

# In your Claude Code prompts, you can:
# 1. Leave status files for other agents
echo "Working on auth refactor" > /tmp/agent-status-a.txt

# 2. Send heartbeats
tmux_heartbeat "testing-auth"

# 3. Broadcast updates
tmux_broadcast "Auth tests passing, ready for integration"

# 4. Listen for messages from other agents
tmux-agents listen &
```

### Coordination Examples

**Scenario 1: Agent A finishes task, notifies others**

```bash
# Agent A
git push origin feature-a
gh pr create --title "Add auth" --body "Ready for review"
tmux_broadcast "PR #123 created - auth feature ready"
```

**Scenario 2: Agent B monitors for PR comments**

```bash
# Agent B (in a loop or watch command)
while true; do
    # Check for new PR comments
    gh pr view 123 --comments > /tmp/pr-comments.txt

    # If new comments, notify
    if grep -q "@agent-b" /tmp/pr-comments.txt; then
        tmux_broadcast "I was mentioned in PR #123"
    fi

    tmux_heartbeat "monitoring-prs"
    sleep 60
done
```

**Scenario 3: Shared task queue via Redis**

```bash
# Agent A pushes task
redis-cli lpush "tasks:queue" "review:PR-123"
tmux_broadcast "New task available: review:PR-123"

# Agent B pulls task
task=$(redis-cli rpop "tasks:queue")
echo "Processing: $task"
tmux_heartbeat "processing:$task"
```

## Session Persistence (tmux-resurrect)

### Save session

```bash
# Manual save
Ctrl+a Ctrl-s

# Auto-saves every 15 minutes (configured)
```

### Restore session

```bash
# On tmux start (auto-restore enabled)
tmux

# Manual restore
Ctrl+a Ctrl-r
```

### What gets saved

- Pane layout and positions
- Working directories
- **Pane contents** (includes command history)
- Shell history
- Running programs (if supported)

### After restore

Re-initialize agents:

```bash
# In each pane, reload context
source ~/dotfiler/shell/scripts/tmux-agents/pane-context.sh

# Or restart agents
tmux-agents init
```

## Configuration

### Heartbeat Settings

Edit `shell/scripts/tmux-agents/heartbeat-monitor.sh`:

```bash
CHECK_INTERVAL=30          # Check every 30 seconds
HEARTBEAT_TIMEOUT=120      # Dead after 2 minutes
```

### Auto-respawn

Edit `heartbeat-monitor.sh` line 57-59:

```bash
# Uncomment to enable auto-respawn
# respawn_pane "$pane_id" "$identifier"
```

### Auto-load Context

In your `~/.zshrc` or agent startup script:

```bash
# Auto-load pane context in all tmux panes
export TMUX_AGENTS_AUTO_CONTEXT=1

# Enable auto-heartbeat on shell init
export TMUX_AUTO_HEARTBEAT=1
```

## Troubleshooting

### Redis not running

```bash
brew services start redis
redis-cli ping  # Should return PONG
```

### Pane context not loaded

```bash
# Manually load in pane
source ~/dotfiler/shell/scripts/tmux-agents/pane-context.sh

# Verify
tmux-agents context
```

### Messages not received

```bash
# Check Redis connection
redis-cli ping

# List active channels
redis-cli pubsub channels "tmux:*"

# Monitor all Redis activity
redis-cli monitor
```

### Check heartbeats

```bash
# List all heartbeat keys
redis-cli --scan --pattern "tmux:pane:*:heartbeat"

# Check specific pane
redis-cli get "tmux:pane:main:1.0:heartbeat"

# Status check
tmux-agents status
```

## Advanced Patterns

### Dead Letter Queue

Respawn panes that crash repeatedly to a "dead" state:

```bash
# In heartbeat-monitor.sh
respawn_count=$(redis-cli incr "tmux:pane:${pane_identifier}:respawn_count")
if [[ $respawn_count -gt 3 ]]; then
    log "⚠️  Pane $pane_identifier respawned too many times, marking as failed"
    redis-cli set "tmux:pane:${pane_identifier}:status" "failed"
    # Don't respawn anymore
else
    respawn_pane "$pane_id" "$identifier"
fi
```

### Structured Logging

Send structured logs to Redis for analysis:

```bash
# In agent
log_event() {
    local event_type="$1"
    local payload="$2"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local log_entry="${timestamp}|${TMUX_PANE_IDENTIFIER}|${event_type}|${payload}"

    redis-cli lpush "logs:agents" "$log_entry"
    redis-cli ltrim "logs:agents" 0 999  # Keep last 1000 logs
}

log_event "test_passed" "auth.test.ts"
log_event "pr_created" "PR-123"
```

### Metrics Collection

Track agent metrics:

```bash
# Increment counters
redis-cli incr "metrics:${TMUX_PANE_IDENTIFIER}:tasks_completed"
redis-cli incr "metrics:${TMUX_PANE_IDENTIFIER}:tests_run"

# Set gauges
redis-cli set "metrics:${TMUX_PANE_IDENTIFIER}:last_activity" "$(date +%s)"

# Query metrics
tmux-agents status
redis-cli get "metrics:main:1.0:tasks_completed"
```

## Files Reference

```
dotfiler/
├── shell/
│   ├── functions/
│   │   └── tmux-agents.sh           # Main CLI interface
│   └── scripts/
│       └── tmux-agents/
│           ├── pane-context.sh      # Pane identity + helpers
│           └── heartbeat-monitor.sh # Health monitoring
├── dotfiles/
│   └── tmux.conf                    # Tmux config with resurrect
└── docs/
    └── TMUX-AGENTS.md              # This file
```

## Next Steps

1. **Try it out**: `tmux-agents init` → `tmux-agents start test` → `tmux-agents heartbeat`
2. **Enable auto-respawn**: Uncomment line in `heartbeat-monitor.sh`
3. **Add your workflow**: Create scripts in `shell/scripts/tmux-agents/`
4. **Integrate with Claude Code**: Add coordination logic to your agent prompts
5. **Save session**: `Ctrl+a Ctrl-s` to persist your setup

## Resources

- [Tmux documentation](https://github.com/tmux/tmux/wiki)
- [Redis Pub/Sub](https://redis.io/docs/manual/pubsub/)
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
- [Git worktrees](https://git-scm.com/docs/git-worktree)
