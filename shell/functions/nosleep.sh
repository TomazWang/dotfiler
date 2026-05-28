#!/usr/bin/env bash

# nosleep - keep Mac awake (for Claude distributed, SSH, etc.)
# Usage: nosleep [on [MIN%]|off|status]

NOSLEEP_MIN_BATTERY=10
NOSLEEP_THRESHOLD_FILE="/tmp/.nosleep_threshold"

_nosleep_battery_pct() {
  pmset -g batt | grep -oE '[0-9]+%' | head -1 | tr -d '%'
}

_nosleep_is_on() {
  [[ "$(pmset -g 2>/dev/null | grep -c 'SleepDisabled.*1')" -gt 0 ]]
}

_nosleep_threshold() {
  if [[ -f "$NOSLEEP_THRESHOLD_FILE" ]]; then
    cat "$NOSLEEP_THRESHOLD_FILE"
  else
    echo "$NOSLEEP_MIN_BATTERY"
  fi
}

_nosleep_check_battery() {
  local pct threshold
  pct=$(_nosleep_battery_pct)
  threshold=$(_nosleep_threshold)
  [[ -z "$pct" ]] && return 0
  [[ "$pct" -ge "$threshold" ]]
}

NOSLEEP_WATCHDOG_PID_FILE="/tmp/.nosleep_watchdog.pid"
NOSLEEP_WATCHDOG_INTERVAL=120  # check every 2 minutes

_nosleep_kill_watchdog() {
  if [[ -f "$NOSLEEP_WATCHDOG_PID_FILE" ]]; then
    local pid
    pid=$(cat "$NOSLEEP_WATCHDOG_PID_FILE" 2>/dev/null)
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null
    fi
    rm -f "$NOSLEEP_WATCHDOG_PID_FILE"
  fi
}

_nosleep_start_watchdog() {
  _nosleep_kill_watchdog
  local threshold
  threshold=$(_nosleep_threshold)
  (
    while true; do
      sleep "$NOSLEEP_WATCHDOG_INTERVAL"
      local pct cur_threshold
      pct=$(pmset -g batt | grep -oE '[0-9]+%' | head -1 | tr -d '%')
      cur_threshold=$(cat "$NOSLEEP_THRESHOLD_FILE" 2>/dev/null || echo "$NOSLEEP_MIN_BATTERY")
      if [[ -n "$pct" && "$pct" -lt "$cur_threshold" ]]; then
        env -u TERMINFO sudo pmset -a disablesleep 0
        osascript -e "display notification \"Battery at ${pct}% — nosleep auto-disabled (threshold: ${cur_threshold}%)\" with title \"nosleep watchdog\"" 2>/dev/null
        rm -f "$NOSLEEP_WATCHDOG_PID_FILE" "$NOSLEEP_THRESHOLD_FILE"
        exit 0
      fi
      # stop if nosleep was turned off manually
      if [[ "$(pmset -g 2>/dev/null | grep -c 'SleepDisabled.*1')" -eq 0 ]]; then
        rm -f "$NOSLEEP_WATCHDOG_PID_FILE" "$NOSLEEP_THRESHOLD_FILE"
        exit 0
      fi
    done
  ) &
  disown
  echo $! > "$NOSLEEP_WATCHDOG_PID_FILE"
}

nosleep() {
  case "${1:-status}" in
    on)
      local threshold="${2:-$NOSLEEP_MIN_BATTERY}"
      if ! [[ "$threshold" =~ ^[0-9]+$ ]]; then
        echo "Invalid threshold: $threshold. Must be a number."
        return 1
      fi
      local pct
      pct=$(_nosleep_battery_pct)
      if [[ -n "$pct" && "$pct" -lt "$threshold" ]]; then
        echo "Battery at ${pct}% (< ${threshold}%). Refusing to enable nosleep."
        return 1
      fi
      if ! env -u TERMINFO sudo pmset -a disablesleep 1; then
        echo "Failed to enable nosleep (sudo pmset failed)."
        return 1
      fi
      echo "$threshold" > "$NOSLEEP_THRESHOLD_FILE"
      _nosleep_start_watchdog
      echo "nosleep ON — Mac will stay awake with lid closed."
      echo "Watchdog running (checks every ${NOSLEEP_WATCHDOG_INTERVAL}s, auto-off at <${threshold}%)."
      ;;
    off)
      env -u TERMINFO sudo pmset -a disablesleep 0
      _nosleep_kill_watchdog
      rm -f "$NOSLEEP_THRESHOLD_FILE"
      echo "nosleep OFF — normal sleep behavior restored."
      ;;
    status)
      if _nosleep_is_on; then
        echo "nosleep is ON"
        if [[ -f "$NOSLEEP_WATCHDOG_PID_FILE" ]] && kill -0 "$(cat "$NOSLEEP_WATCHDOG_PID_FILE")" 2>/dev/null; then
          echo "Watchdog: running (PID $(cat "$NOSLEEP_WATCHDOG_PID_FILE"), auto-off at <$(_nosleep_threshold)%)"
        else
          echo "Watchdog: not running"
        fi
      else
        echo "nosleep is OFF"
      fi
      echo "Battery: $(_nosleep_battery_pct)%"
      ;;
    *)
      echo "Usage: nosleep [on [MIN%]|off|status]"
      echo "  nosleep on        — use default threshold (${NOSLEEP_MIN_BATTERY}%)"
      echo "  nosleep on 20     — auto-off when battery drops below 20%"
      return 1
      ;;
  esac
}
