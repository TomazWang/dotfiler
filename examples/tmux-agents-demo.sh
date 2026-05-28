#!/usr/bin/env bash
# Demo script for tmux-agents
# Shows how to set up multiple Claude Code agents coordinating via Redis

# This script demonstrates:
# 1. Creating a tmux session
# 2. Setting up multiple agent panes
# 3. Starting a monitor
# 4. Coordination patterns

set -e

SESSION_NAME="claude-agents"
PROJECT_DIR="${1:-$HOME/my-project}"

echo "🚀 Setting up Claude Code agent swarm"
echo "   Session: $SESSION_NAME"
echo "   Project: $PROJECT_DIR"
echo ""

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "⚠️  Session '$SESSION_NAME' already exists"
    read -p "Kill and recreate? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        tmux kill-session -t "$SESSION_NAME"
    else
        echo "Attaching to existing session..."
        tmux attach-session -t "$SESSION_NAME"
        exit 0
    fi
fi

# Create new session
echo "1. Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -n "control" -c "$PROJECT_DIR"

# Initialize tmux-agents in the control pane
tmux send-keys -t "$SESSION_NAME:control" "# Control pane - Agent orchestration" C-m
tmux send-keys -t "$SESSION_NAME:control" "tmux-agents init" C-m
tmux send-keys -t "$SESSION_NAME:control" "clear" C-m

# Create agent panes (example with 3 agents)
echo "2. Creating agent panes..."

# Agent 1 - Feature A
tmux split-window -h -t "$SESSION_NAME" -c "$PROJECT_DIR"
tmux send-keys -t "$SESSION_NAME:1.1" "# Agent 1: Feature A" C-m
tmux send-keys -t "$SESSION_NAME:1.1" "source ~/dotfiler/shell/scripts/tmux-agents/pane-context.sh" C-m
tmux select-pane -t "$SESSION_NAME:1.1" -T "agent-1-feature-a"

# Agent 2 - Feature B
tmux split-window -v -t "$SESSION_NAME:1.1" -c "$PROJECT_DIR"
tmux send-keys -t "$SESSION_NAME:1.2" "# Agent 2: Feature B" C-m
tmux send-keys -t "$SESSION_NAME:1.2" "source ~/dotfiler/shell/scripts/tmux-agents/pane-context.sh" C-m
tmux select-pane -t "$SESSION_NAME:1.2" -T "agent-2-feature-b"

# Agent 3 - Bug fixes
tmux select-pane -t "$SESSION_NAME:1.0"
tmux split-window -v -t "$SESSION_NAME:1.0" -c "$PROJECT_DIR"
tmux send-keys -t "$SESSION_NAME:1.1" "# Agent 3: Bug fixes" C-m
tmux send-keys -t "$SESSION_NAME:1.1" "source ~/dotfiler/shell/scripts/tmux-agents/pane-context.sh" C-m
tmux select-pane -t "$SESSION_NAME:1.1" -T "agent-3-bugfix"

# Create monitor pane
echo "3. Creating monitor pane..."
tmux select-pane -t "$SESSION_NAME:1.0"
tmux split-window -v -t "$SESSION_NAME:1.0" -c "$PROJECT_DIR"
tmux send-keys -t "$SESSION_NAME:1.1" "# Monitor pane" C-m
tmux send-keys -t "$SESSION_NAME:1.1" "sleep 2" C-m
tmux send-keys -t "$SESSION_NAME:1.1" "tmux-agents monitor $SESSION_NAME here" C-m
tmux select-pane -t "$SESSION_NAME:1.1" -T "monitor"

# Resize panes for better layout
tmux select-layout -t "$SESSION_NAME" tiled

# Focus on control pane
tmux select-pane -t "$SESSION_NAME:1.0"

echo ""
echo "✓ Session created!"
echo ""
echo "Layout:"
echo "  - Control pane: tmux-agents commands"
echo "  - Agent 1: Feature A development"
echo "  - Agent 2: Feature B development"
echo "  - Agent 3: Bug fixes"
echo "  - Monitor: Heartbeat monitoring"
echo ""
echo "Next steps:"
echo "  1. Attach to session: tmux attach -t $SESSION_NAME"
echo "  2. In each agent pane: claude-code"
echo "  3. Use coordination:"
echo "     - tmux_heartbeat 'working'"
echo "     - tmux_broadcast 'Task done'"
echo "     - tmux-agents listen"
echo ""
echo "Save session: Ctrl+a Ctrl-s (tmux-resurrect)"
echo "Attach now? (tmux attach -t $SESSION_NAME)"
