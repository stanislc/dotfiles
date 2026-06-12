#!/usr/bin/env bash
set -euo pipefail

save_script="${HOME}/.config/tmux/plugins/tmux-resurrect/scripts/save.sh"
[[ -x "$save_script" ]] || exit 0

get_opt() {
  tmux show-option -gqv "$1" 2>/dev/null || true
}

restore_opt() {
  local option="$1"
  local value="$2"
  if [[ -n "$value" ]]; then
    tmux set-option -gq "$option" "$value"
  else
    tmux set-option -guq "$option" 2>/dev/null || true
  fi
}

post_save_hook="$(get_opt @resurrect-hook-post-save-all)"
capture_panes="$(get_opt @resurrect-capture-pane-contents)"

cleanup() {
  restore_opt @resurrect-hook-post-save-all "$post_save_hook"
  restore_opt @resurrect-capture-pane-contents "$capture_panes"
}
trap cleanup EXIT

tmux set-option -gq @resurrect-hook-post-save-all ''
tmux set-option -gq @resurrect-capture-pane-contents off
"$save_script" quiet
