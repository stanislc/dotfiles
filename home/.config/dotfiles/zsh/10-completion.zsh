if [[ -d "${HOMEBREW_PREFIX:-}/share/zsh-completions" ]]; then
  fpath=("${HOMEBREW_PREFIX}/share/zsh-completions" $fpath)
fi

autoload -Uz compinit
compinit -i -C

zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' special-dirs false
LISTMAX=50

_source_first \
  "${HOMEBREW_PREFIX:-}/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh" \
  "$HOME/.local/share/fzf-tab/fzf-tab.zsh"

zstyle ':fzf-tab:*' fzf-flags --ansi --height=50% --layout=reverse --border
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' default-color $'\033[0m'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -1 --color=always --icons $realpath'
zstyle ':fzf-tab:complete:*' fzf-bindings 'tab:accept'

