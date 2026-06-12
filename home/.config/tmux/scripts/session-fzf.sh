#!/usr/bin/env bash
# Session switcher/creator with fzf
# - Shows list of sessions
# - Ctrl-K kills a session (and reloads list)
# - Enter on existing session → switch
# - Enter on query → create + switch
# - Preview pane shows windows inside the session

selected=$(
  tmux list-sessions -F '#{session_name}' 2>/dev/null |
  fzf \
    --prompt="Session: " \
    --print-query \
    --header="Enter: switch/create | Ctrl-K: kill session" \
    --bind "ctrl-k:execute-silent(tmux kill-session -t {})+reload(tmux list-sessions -F '#{session_name}' 2>/dev/null)" \
    --preview="tmux list-windows -t {} -F '  #{window_index}: #{window_name} (#{pane_current_command})' 2>/dev/null || echo 'New session'" \
    --preview-window=right:50%
)

# fzf --print-query outputs query on first line, selection on second
query=$(echo "$selected" | head -1)
match=$(echo "$selected" | tail -1)

# If nothing was selected/typed, exit
[ -z "$query" ] && [ -z "$match" ] && exit 0

# Use the match if available, otherwise use the query to create a new session
target="${match:-$query}"

if tmux has-session -t "=$target" 2>/dev/null; then
  tmux switch-client -t "$target"
else
  tmux new-session -d -s "$target" && tmux switch-client -t "$target"
fi
