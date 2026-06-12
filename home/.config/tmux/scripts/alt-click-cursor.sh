#!/usr/bin/env bash
set -euo pipefail

pane_id="${1:-}"
mouse_x="${2:-}"
mouse_y="${3:-}"
cursor_x="${4:-}"
cursor_y="${5:-}"
pane_command="${6:-}"

case "$pane_command" in
  bash|dash|fish|ksh|mksh|nu|sh|zsh) ;;
  *)
    tmux select-pane -t "$pane_id"
    exit 0
    ;;
esac

case "$mouse_x:$mouse_y:$cursor_x:$cursor_y" in
  *[!0-9:]* | *::* | :* | *:) exit 0 ;;
esac

tmux select-pane -t "$pane_id"

# This intentionally handles the common shell prompt case only. Native
# terminal Option-click cannot pass through tmux mouse mode, so moving across
# rows would require guessing shell/editor state and is easy to get wrong.
if [ "$mouse_y" -ne "$cursor_y" ]; then
  exit 0
fi

delta=$((mouse_x - cursor_x))
if [ "$delta" -gt 0 ]; then
  tmux send-keys -t "$pane_id" -N "$delta" Right
elif [ "$delta" -lt 0 ]; then
  tmux send-keys -t "$pane_id" -N "$((-delta))" Left
fi
