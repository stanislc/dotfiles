#!/usr/bin/env bash
# Open the current pane's scrollback in $EDITOR in a split.
# Uses mktemp in the private $TMUX_TMPDIR (0700, created in .zshenv) so the
# dump is never world-readable and the name is unpredictable — safe on shared
# cluster hosts, identical behavior on local machines.
set -euo pipefail

pane_id="${1:-}"
tmpdir="${TMUX_TMPDIR:-${XDG_STATE_HOME:-$HOME/.local/state}/tmux}"
mkdir -p -m 700 "$tmpdir" 2>/dev/null || tmpdir="$(dirname "$(mktemp -u)")"

scrollback="$(mktemp "$tmpdir/scrollback.XXXXXX")"

if [ -n "$pane_id" ]; then
  tmux capture-pane -p -S -32768 -t "$pane_id" >"$scrollback"
else
  tmux capture-pane -p -S -32768 >"$scrollback"
fi

# Edit in a split. The editor runs in the new pane, so cleanup must happen
# there (after it closes), not on this script's exit.
tmux split-window -h "${EDITOR:-nvim} '$scrollback'; rm -f '$scrollback'"
