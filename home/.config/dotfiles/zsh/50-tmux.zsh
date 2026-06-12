# "ta" = tmux attach-or-create. When no server is running, first try a
# tmux-resurrect restore so saved sessions come back even if continuum's
# server-start hook did not fire (common over SSH).
ta() {
  emulate -L zsh
  local session="${1:-main}"
  local restore_script="$HOME/.config/tmux/plugins/tmux-resurrect/scripts/restore.sh"
  local resurrect_dir="${TMUX_RESURRECT_DIR:-$HOME/.tmux/resurrect}"
  local -a resurrect_saves=( "$resurrect_dir"/tmux_resurrect_*.txt(N) )
  local restored_session

  if command tmux has-session -t "$session" 2>/dev/null; then
    command tmux attach-session -t "$session"
    return
  fi

  if ! command tmux ls >/dev/null 2>&1 \
      && [[ -x "$restore_script" && ${#resurrect_saves[@]} -gt 0 ]]; then
    command tmux start-server >/dev/null 2>&1 || true
    "$restore_script" >/dev/null 2>&1 || true
    if command tmux has-session -t "$session" 2>/dev/null; then
      command tmux attach-session -t "$session"
      return
    fi
    restored_session="$(command tmux list-sessions -F '#{session_name}' 2>/dev/null | head -1)"
    if [[ -n "$restored_session" ]]; then
      command tmux attach-session -t "$restored_session"
      return
    fi
  fi

  command tmux new-session -A -s "$session"
}

# Zellij: attach-or-create, agent-team tmux shim, and pane recoloring that
# follows the local terminal's light/dark appearance.
alias zac='zellij attach -c'

if [[ -n "${ZELLIJ:-}" ]]; then
  _source_if_readable "${XDG_DATA_HOME:-$HOME/.local/share}/zellij-tmux-shim/activate.sh"
fi

_zellij_apply_pane_theme() {
  [[ -n "${ZELLIJ:-}" && -n "${ZELLIJ_PANE_ID:-}" ]] || return 0
  local appearance="${LOCAL_TERM_APPEARANCE:-}" fg bg
  case "$appearance" in
    dark)  fg="#abb2bf" bg="#282c34" ;;
    light) fg="#383a42" bg="#fafafa" ;;
    *) return 0 ;;
  esac
  [[ "${_ZELLIJ_LAST_APPEARANCE:-}" == "$appearance" ]] && return 0
  zellij action set-pane-color \
    --pane-id "$ZELLIJ_PANE_ID" --fg "$fg" --bg "$bg" >/dev/null 2>&1 || return 0
  export _ZELLIJ_LAST_APPEARANCE="$appearance"
}
add-zsh-hook precmd _zellij_apply_pane_theme
