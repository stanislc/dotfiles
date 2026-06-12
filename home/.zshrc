# Interactive zsh entrypoint.

[[ ! -o interactive ]] && return

typeset -U path PATH fpath

_source_if_readable() {
  [[ -r "$1" ]] && source "$1"
}

# Source the first readable candidate (brew, system, or user-cloned paths).
_source_first() {
  local f
  for f in "$@"; do
    [[ -r "$f" ]] && { source "$f"; return 0; }
  done
  return 1
}

for _module in "$HOME/.config/dotfiles/zsh"/*.zsh(N); do
  source "$_module"
done
unset _module

_source_if_readable "$HOME/.config/dotfiles/profile.zsh"
_source_if_readable "$HOME/.config/dotfiles/local.zsh"

