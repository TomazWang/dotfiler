# `claude` goes through cp-router, which starts the real Claude on the right claude-profile:
# resume → the session's own profile; new session typed in a terminal → asks (Enter = current profile).
# `claude-primitive` runs the real binary untouched. See bin/cp-router.
# (A function, not a PATH entry: ~/.local/bin/env puts the real claude first in PATH.)

# Locate cp-router without trusting $DOTFILER_ROOT alone (it has been mis-set in zsh before).
_cp_router_path() {
  local p
  for p in "${DOTFILER_ROOT:+$DOTFILER_ROOT/bin/cp-router}" "$HOME/dev/workspace/mine/dotfiler/bin/cp-router"; do
    [ -n "$p" ] && [ -x "$p" ] && { printf '%s\n' "$p"; return 0; }
  done
  return 1
}

claude() {
  local r
  if ! r="$(_cp_router_path)"; then
    # Never block a launch: without the router, run the real claude as before.
    echo "claude: cp-router not found, starting the real claude" >&2
    command "$HOME/.local/bin/claude" "$@"
    return
  fi
  CP_ROUTER_FROM_SHELL=1 "$r" "$@"
}

claude-primitive() {
  command "$HOME/.local/bin/claude" "$@"
}
