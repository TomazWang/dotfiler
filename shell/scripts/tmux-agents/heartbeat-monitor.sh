#!/usr/bin/env bash
# Heartbeat monitor for tmux panes
# Monitors agent heartbeats and respawns dead panes
# Usage: ./heartbeat-monitor.sh [session-name] [check-interval-seconds]

set -euo pipefail

SESSION_NAME="${1:-$(tmux display-message -p '#S')}"
CHECK_INTERVAL="${2:-30}"  # Check every 30 seconds
HEARTBEAT_TIMEOUT=120      # Consider dead if no heartbeat for 2 minutes
REDIS_CHANNEL="tmux:agents:messages"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

get_session_panes() {
    tmux list-panes -s -t "$SESSION_NAME" -F "#{session_name}:#{window_index}.#{pane_index}|#{pane_id}|#{pane_title}"
}

check_pane_heartbeat() {
    local pane_identifier="$1"
    local heartbeat_key="tmux:pane:${pane_identifier}:heartbeat"

    # Get heartbeat from Redis
    local heartbeat=$(redis-cli get "$heartbeat_key" 2>/dev/null || echo "")

    if [[ -z "$heartbeat" ]]; then
        return 1  # No heartbeat found
    fi

    # Parse heartbeat: identifier|status|timestamp
    local timestamp=$(echo "$heartbeat" | cut -d'|' -f3)
    local current_time=$(date +%s)
    local age=$((current_time - timestamp))

    if [[ $age -gt $HEARTBEAT_TIMEOUT ]]; then
        return 1  # Heartbeat too old
    fi

    return 0  # Heartbeat is fresh
}

respawn_pane() {
    local pane_id="$1"
    local pane_identifier="$2"

    log "⚠️  Respawning dead pane: $pane_identifier ($pane_id)"

    # Respawn the pane
    if tmux respawn-pane -k -t "$pane_id"; then
        log "✓ Successfully respawned $pane_identifier"

        # Publish notification
        local payload="${pane_identifier}|respawned|$(date +%s)"
        redis-cli publish "$REDIS_CHANNEL" "pane_respawn:$payload" >/dev/null 2>&1
    else
        log "❌ Failed to respawn $pane_identifier"
    fi
}

monitor_session() {
    log "🔍 Starting heartbeat monitor for session: $SESSION_NAME"
    log "   Check interval: ${CHECK_INTERVAL}s"
    log "   Heartbeat timeout: ${HEARTBEAT_TIMEOUT}s"

    while true; do
        # Get all panes in the session
        while IFS='|' read -r identifier pane_id title; do
            # Skip the monitor pane itself (check by title or position)
            if [[ "$title" == "monitor" ]] || [[ "$title" == "heartbeat-monitor" ]]; then
                continue
            fi

            # Check heartbeat
            if ! check_pane_heartbeat "$identifier"; then
                log "⚠️  No heartbeat from $identifier (${title})"
                # Uncomment to enable auto-respawn
                # respawn_pane "$pane_id" "$identifier"
            else
                log "✓ Heartbeat OK: $identifier (${title})"
            fi
        done < <(get_session_panes)

        sleep "$CHECK_INTERVAL"
    done
}

# Subscribe to Redis channel for real-time updates (alternative monitoring)
monitor_redis_channel() {
    log "📡 Listening to Redis channel: $REDIS_CHANNEL"

    redis-cli --csv subscribe "$REDIS_CHANNEL" | while read -r line; do
        # Parse CSV output: "subscribe","channel",count or "message","channel","payload"
        if [[ "$line" =~ message ]]; then
            # Extract message payload
            local message=$(echo "$line" | cut -d',' -f3 | tr -d '"')
            log "📨 Received: $message"
        fi
    done
}


# Main execution
case "${3:-monitor}" in
    monitor)
        monitor_session
        ;;
    redis)
        monitor_redis_channel
        ;;
    *)
        echo "Usage: $0 [session-name] [check-interval] [monitor|redis]"
        exit 1
        ;;
esac
