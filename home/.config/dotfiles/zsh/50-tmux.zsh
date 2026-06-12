# "ta" = tmux attach-or-create. Session restore is handled by tmux-continuum
# (@continuum-restore in tmux.conf) whenever the tmux server starts.
ta() {
  emulate -L zsh
  local session="${1:-main}"

  if command tmux has-session -t "$session" 2>/dev/null; then
    command tmux attach-session -t "$session"
    return
  fi

  command tmux new-session -A -s "$session"
}
