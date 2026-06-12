if [[ -d "${HOMEBREW_PREFIX:-}/share/zsh-completions" ]]; then
  fpath=("${HOMEBREW_PREFIX}/share/zsh-completions" $fpath)
fi

# Defer compinit + fzf-tab + extra completions to the first Tab press —
# noticeably faster shell startup, especially on NFS homes.
# Mark compinit for autoload WITHOUT running it: the mamba shell hook runs its
# own compinit when `command -v compinit` fails, which would defeat the lazy
# load (and abort in shells without a terminal).
autoload -Uz compinit
# Tool inits (zoxide, atuin, mamba, ...) call compdef before compinit has run;
# queue those calls and replay them once real completion is up.
typeset -ga _compdef_queue
compdef() { _compdef_queue+=("${(j: :)@}") }

_lazy_completion_init() {
  unset -f _lazy_completion_init
  unfunction compdef 2>/dev/null
  autoload -Uz compinit
  compinit -i -C
  local _c
  for _c in "${_compdef_queue[@]}"; do compdef ${=_c}; done
  unset _compdef_queue
  (( $+functions[_scancel] )) && compdef _scancel scancel
  _source_if_readable "$HOME/.bun/_bun"
  bindkey '^I' expand-or-complete
  if _source_first \
    "${HOMEBREW_PREFIX:-}/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh" \
    "$HOME/.local/share/fzf-tab/fzf-tab.zsh"; then
    zle fzf-tab-complete
  else
    zle expand-or-complete
  fi
}
zle -N _lazy_completion_init
bindkey '^I' _lazy_completion_init

zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' special-dirs false
LISTMAX=50

zstyle ':fzf-tab:*' fzf-flags --ansi --height=50% --layout=reverse --border
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' default-color $'\033[0m'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:*' fzf-bindings 'tab:accept'

