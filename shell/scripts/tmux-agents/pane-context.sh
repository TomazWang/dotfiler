#!/usr/bin/env bash
# Tmux pane context helper - provides pane ID awareness
# Usage: source this file in any pane to get context variables

# Get current pane information
export TMUX_PANE_ID="${TMUX_PANE}"
export TMUX_SESSION_NAME="$(tmux display-message -p '#S')"
export TMUX_WINDOW_INDEX="$(tmux display-message -p '#I')"
export TMUX_PANE_INDEX="$(tmux display-message -p '#P')"
export TMUX_PANE_TITLE="$(tmux display-message -p '#T')"

# Generate a unique identifier for this pane
# Format: session:window.pane (e.g., main:1.0)
export TMUX_PANE_IDENTIFIER="${TMUX_SESSION_NAME}:${TMUX_WINDOW_INDEX}.${TMUX_PANE_INDEX}"

# Redis keys for this pane
export REDIS_HEARTBEAT_KEY="tmux:pane:${TMUX_PANE_IDENTIFIER}:heartbeat"
export REDIS_STATUS_KEY="tmux:pane:${TMUX_PANE_IDENTIFIER}:status"
export REDIS_MESSAGE_CHANNEL="tmux:session:${TMUX_SESSION_NAME}:messages"
export REDIS_AGENT_CHANNEL="tmux:agents:messages"

# Helper function to publish to Redis
tmux_redis_publish() {
    local channel="$1"
    local message="$2"
    redis-cli publish "$channel" "$message" >/dev/null 2>&1
}

# Helper function to set key in Redis with expiration
tmux_redis_set() {
    local key="$1"
    local value="$2"
    local ttl="${3:-120}"  # Default 2 minute TTL
    redis-cli setex "$key" "$ttl" "$value" >/dev/null 2>&1
}

# Helper function to get key from Redis
tmux_redis_get() {
    local key="$1"
    redis-cli get "$key" 2>/dev/null
}

# Send heartbeat to Redis
tmux_heartbeat() {
    local status="${1:-alive}"
    local timestamp=$(date +%s)
    local payload="${TMUX_PANE_IDENTIFIER}|${status}|${timestamp}"

    tmux_redis_set "$REDIS_HEARTBEAT_KEY" "$payload" 120
    tmux_redis_publish "$REDIS_AGENT_CHANNEL" "heartbeat:$payload"
}

# Broadcast message to all agents in session
tmux_broadcast() {
    local message="$1"
    local payload="${TMUX_PANE_IDENTIFIER}|${message}"
    tmux_redis_publish "$REDIS_MESSAGE_CHANNEL" "$payload"
}

# Send targeted message to specific pane
tmux_send_message() {
    local target_pane="$1"
    local message="$2"
    local channel="tmux:pane:${target_pane}:messages"
    local payload="${TMUX_PANE_IDENTIFIER}|${message}"
    tmux_redis_publish "$channel" "$payload"
}

# Print pane context (for debugging)
tmux_print_context() {
    cat <<EOF
Tmux Pane Context:
  Pane ID:         $TMUX_PANE_ID
  Identifier:      $TMUX_PANE_IDENTIFIER
  Session:         $TMUX_SESSION_NAME
  Window:          $TMUX_WINDOW_INDEX
  Pane:            $TMUX_PANE_INDEX
  Title:           $TMUX_PANE_TITLE

Redis Keys:
  Heartbeat:       $REDIS_HEARTBEAT_KEY
  Status:          $REDIS_STATUS_KEY
  Message Channel: $REDIS_MESSAGE_CHANNEL
  Agent Channel:   $REDIS_AGENT_CHANNEL
EOF
}

# Auto-send heartbeat on load (optional, can be disabled)
if [[ "${TMUX_AUTO_HEARTBEAT:-1}" == "1" ]]; then
    tmux_heartbeat "initialized"
fi
