#!/usr/bin/env bash
# Tmux agent orchestration function
# Provides distributed agent coordination via Redis message bus
# Auto-loaded by shell/load.sh

# shellcheck disable=SC2034
: "${SHELL_VERBOSE:=${ZSHRC_VERBOSE:-0}}"

log_tmux_agents() {
    [ "$SHELL_VERBOSE" = "1" ] && echo "[tmux-agents] $1"
}

tmux-agents() {
    local command="${1:-help}"
    shift || true

    case "$command" in
        init|setup)
            _tmux_agents_init "$@"
            ;;
        start)
            _tmux_agents_start "$@"
            ;;
        heartbeat)
            _tmux_agents_heartbeat "$@"
            ;;
        monitor)
            _tmux_agents_monitor "$@"
            ;;
        broadcast)
            _tmux_agents_broadcast "$@"
            ;;
        listen)
            _tmux_agents_listen "$@"
            ;;
        status)
            _tmux_agents_status "$@"
            ;;
        context)
            _tmux_agents_context "$@"
            ;;
        help|--help|-h)
            _tmux_agents_help
            ;;
        *)
            echo "Unknown command: $command"
            _tmux_agents_help
            return 1
            ;;
    esac
}

_tmux_agents_init() {
    echo "🚀 Initializing tmux agent orchestration..."

    # Check dependencies
    if ! command -v redis-cli &>/dev/null; then
        echo "❌ Redis not found. Please install: brew install redis"
        return 1
    fi

    if ! command -v tmux &>/dev/null; then
        echo "❌ Tmux not found. Please install: brew install tmux"
        return 1
    fi

    # Check if Redis is running
    if ! redis-cli ping &>/dev/null; then
        echo "⚠️  Redis is not running. Starting Redis..."
        brew services start redis
        sleep 2
    fi

    # Test Redis connection
    if redis-cli ping &>/dev/null; then
        echo "✓ Redis is running"
    else
        echo "❌ Failed to connect to Redis"
        return 1
    fi

    # Load pane context in current pane
    if [[ -n "$TMUX" ]]; then
        # shellcheck source=/dev/null
        source "${DOTFILES_DIR}/shell/scripts/tmux-agents/pane-context.sh"
        echo "✓ Pane context loaded"
        tmux_print_context
    else
        echo "⚠️  Not in a tmux session. Pane context not loaded."
    fi

    echo ""
    echo "✓ Tmux agents initialized!"
    echo "  Next steps:"
    echo "    1. tmux-agents start <agent-name>  - Start an agent in a new pane"
    echo "    2. tmux-agents monitor             - Start heartbeat monitor"
    echo "    3. tmux-agents broadcast <msg>     - Send message to all agents"
}

_tmux_agents_start() {
    local agent_name="${1:-agent}"
    local worktree_path="${2:-.}"

    if [[ -z "$TMUX" ]]; then
        echo "❌ Must be run from within a tmux session"
        return 1
    fi

    echo "🚀 Starting agent: $agent_name in $worktree_path"

    # Create a new pane
    local pane_id=$(tmux split-window -h -P -F "#{pane_id}" -c "$worktree_path")

    # Send commands to the new pane
    tmux send-keys -t "$pane_id" "# Agent: $agent_name" C-m
    tmux send-keys -t "$pane_id" "source ${DOTFILES_DIR}/shell/scripts/tmux-agents/pane-context.sh" C-m
    tmux send-keys -t "$pane_id" "tmux rename-window '$agent_name'" C-m
    tmux send-keys -t "$pane_id" "# Pane context loaded. Use tmux_heartbeat, tmux_broadcast, etc." C-m

    # Set pane title
    tmux select-pane -t "$pane_id" -T "$agent_name"

    echo "✓ Agent pane created: $pane_id"
    echo "  Name: $agent_name"
    echo "  Path: $worktree_path"
}

_tmux_agents_heartbeat() {
    if [[ -z "$TMUX" ]]; then
        echo "❌ Must be run from within a tmux session"
        return 1
    fi

    # Load pane context if not already loaded
    if [[ -z "$TMUX_PANE_IDENTIFIER" ]]; then
        # shellcheck source=/dev/null
        source "${DOTFILES_DIR}/shell/scripts/tmux-agents/pane-context.sh"
    fi

    tmux_heartbeat "${1:-alive}"
    echo "💓 Heartbeat sent: $TMUX_PANE_IDENTIFIER"
}

_tmux_agents_broadcast() {
    local message="$*"

    if [[ -z "$message" ]]; then
        echo "Usage: tmux-agents broadcast <message>"
        return 1
    fi

    if [[ -z "$TMUX" ]]; then
        echo "❌ Must be run from within a tmux session"
        return 1
    fi

    # Load pane context if not already loaded
    if [[ -z "$TMUX_PANE_IDENTIFIER" ]]; then
        # shellcheck source=/dev/null
        source "${DOTFILES_DIR}/shell/scripts/tmux-agents/pane-context.sh"
    fi

    tmux_broadcast "$message"
    echo "📢 Broadcast sent: $message"
}

_tmux_agents_listen() {
    if [[ -z "$TMUX" ]]; then
        echo "❌ Must be run from within a tmux session"
        return 1
    fi

    # Load pane context if not already loaded
    if [[ -z "$TMUX_PANE_IDENTIFIER" ]]; then
        # shellcheck source=/dev/null
        source "${DOTFILES_DIR}/shell/scripts/tmux-agents/pane-context.sh"
    fi

    echo "📡 Listening for messages on: $REDIS_MESSAGE_CHANNEL"
    echo "   Press Ctrl-C to stop"
    echo ""

    redis-cli --csv subscribe "$REDIS_MESSAGE_CHANNEL" "$REDIS_AGENT_CHANNEL" | while read -r line; do
        if [[ "$line" =~ message ]]; then
            local message=$(echo "$line" | cut -d',' -f3 | tr -d '"')
            echo "[$(date '+%H:%M:%S')] $message"
        fi
    done
}

_tmux_agents_monitor() {
    local session_name="${1:-$(tmux display-message -p '#S')}"

    echo "🔍 Starting heartbeat monitor for session: $session_name"

    # Run monitor in current pane or new pane
    if [[ "${2:-new}" == "here" ]]; then
        bash "${DOTFILES_DIR}/shell/scripts/tmux-agents/heartbeat-monitor.sh" "$session_name" 30 monitor
    else
        # Create monitor pane
        tmux split-window -v "${DOTFILES_DIR}/shell/scripts/tmux-agents/heartbeat-monitor.sh $session_name 30 monitor"
        tmux select-pane -T "monitor"
    fi
}

_tmux_agents_status() {
    echo "📊 Tmux Agent Status"
    echo ""

    # Check Redis
    if redis-cli ping &>/dev/null; then
        echo "✓ Redis: Running"
    else
        echo "❌ Redis: Not running"
    fi

    # Check if in tmux
    if [[ -n "$TMUX" ]]; then
        echo "✓ Tmux: Active session"
        echo "  Session: $(tmux display-message -p '#S')"
        echo "  Panes: $(tmux list-panes -s | wc -l | tr -d ' ')"
    else
        echo "⚠️  Tmux: Not in a session"
    fi

    # List active heartbeats
    echo ""
    echo "Active heartbeats:"
    redis-cli --scan --pattern "tmux:pane:*:heartbeat" | while read -r key; do
        local value=$(redis-cli get "$key")
        if [[ -n "$value" ]]; then
            local pane=$(echo "$key" | sed 's/tmux:pane:\(.*\):heartbeat/\1/')
            local timestamp=$(echo "$value" | cut -d'|' -f3)
            local age=$(($(date +%s) - timestamp))
            echo "  $pane - ${age}s ago"
        fi
    done
}

_tmux_agents_context() {
    if [[ -z "$TMUX" ]]; then
        echo "❌ Must be run from within a tmux session"
        return 1
    fi

    # Load pane context if not already loaded
    if [[ -z "$TMUX_PANE_IDENTIFIER" ]]; then
        # shellcheck source=/dev/null
        source "${DOTFILES_DIR}/shell/scripts/tmux-agents/pane-context.sh"
    fi

    tmux_print_context
}

_tmux_agents_help() {
    cat <<'EOF'
tmux-agents - Distributed agent orchestration via tmux + Redis

USAGE:
    tmux-agents <command> [args...]

COMMANDS:
    init              Initialize agent system (check deps, start Redis)
    start <name>      Create new agent pane with context loaded
    heartbeat         Send heartbeat from current pane
    broadcast <msg>   Broadcast message to all agents in session
    listen            Listen for messages on agent channel
    monitor           Start heartbeat monitor (auto-respawn dead panes)
    status            Show status of Redis, tmux, and active agents
    context           Show current pane context and Redis keys
    help              Show this help message

EXAMPLES:
    # Initialize the system
    tmux-agents init

    # Start multiple agents
    tmux-agents start agent-1 ~/project/worktree-1
    tmux-agents start agent-2 ~/project/worktree-2

    # From within an agent pane:
    tmux-agents heartbeat                  # Send heartbeat
    tmux-agents broadcast "Task complete"  # Broadcast message
    tmux-agents listen                     # Listen for messages

    # Start monitoring (in a dedicated pane)
    tmux-agents monitor

    # Check status
    tmux-agents status

ARCHITECTURE:
    Each tmux pane is an agent that can:
    - Send heartbeats to Redis (auto-detected when dead)
    - Broadcast messages to all agents
    - Listen for messages from other agents
    - Access shared state via Redis

    Panes communicate via Redis pub/sub and keys:
    - Heartbeats: tmux:pane:<identifier>:heartbeat
    - Messages: tmux:session:<session>:messages
    - Agent channel: tmux:agents:messages

    The monitor pane watches heartbeats and can auto-respawn dead panes.

PANE CONTEXT (auto-loaded in agent panes):
    Functions available in each pane:
    - tmux_heartbeat [status]       # Send heartbeat
    - tmux_broadcast <message>      # Broadcast to all
    - tmux_send_message <pane> <msg> # Send to specific pane
    - tmux_print_context            # Show pane info

    Environment variables:
    - TMUX_PANE_IDENTIFIER          # Unique pane ID (session:window.pane)
    - REDIS_HEARTBEAT_KEY           # Redis key for heartbeat
    - REDIS_MESSAGE_CHANNEL         # Channel for session messages
    - REDIS_AGENT_CHANNEL           # Channel for agent messages

DEPENDENCIES:
    - tmux
    - redis (brew install redis)

For your use case (Claude Code agents on different worktrees):
    1. Create worktrees for each branch
    2. Start agents: tmux-agents start agent-1 ~/proj/worktree-1
    3. In each agent, run: claude-code
    4. Agents can coordinate via file writes + Redis messaging
    5. Monitor keeps them alive
EOF
}

# Auto-load pane context if in tmux (optional, can disable)
if [[ -n "$TMUX" ]] && [[ "${TMUX_AGENTS_AUTO_CONTEXT:-0}" == "1" ]]; then
    # shellcheck source=/dev/null
    source "${DOTFILES_DIR}/shell/scripts/tmux-agents/pane-context.sh" 2>/dev/null || true
fi
