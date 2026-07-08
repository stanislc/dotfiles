export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 40% --layout=reverse --border}"
_source_if_readable "$HOME/.fzf.zsh"

# nvm (standard or brew install); .zshenv already covers non-interactive PATH.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
_source_first "$NVM_DIR/nvm.sh" "${HOMEBREW_PREFIX:-}/opt/nvm/nvm.sh"

# Ctrl+F: fuzzy command palette over all commands/aliases with cached whatis
# descriptions. Rebuild with fzf-rebuild-cache after installing new tools.
_fzf_cmd_cache="$HOME/.cache/fzf-commands"
_fzf_build_cache() {
  mkdir -p "$(dirname "$_fzf_cmd_cache")"
  echo "Building command cache (one-time)..." >&2
  (print -l "${(@k)aliases}" "${(@k)commands}") | sort -u | while read -r c; do
    [[ "$c" =~ ^[^a-zA-Z0-9]$ ]] && continue
    [[ "$c" == "[" || "$c" == "]" || "$c" == "[[" ]] && continue
    desc=$(whatis "$c" 2>/dev/null | head -1 | sed 's/.*) *- *//')
    if [[ -n "$desc" ]]; then
      printf "%s\t%s\n" "$c" "$desc"
    else
      printf "%s\n" "$c"
    fi
  done > "$_fzf_cmd_cache"
}
fzf-command-widget() {
  local selection cmd
  [[ ! -f "$_fzf_cmd_cache" ]] && _fzf_build_cache
  selection=$(fzf --height=60% --layout=reverse --border \
    --prompt="command> " --nth=1 --delimiter='\t' --tabstop=30 < "$_fzf_cmd_cache")
  if [[ -n "$selection" ]]; then
    cmd="${selection%%$'\t'*}"
    LBUFFER="$cmd "
    zle redisplay
  fi
}
zle -N fzf-command-widget
bindkey '^f' fzf-command-widget
fzf-rebuild-cache() {
  rm -f "$_fzf_cmd_cache"
  _fzf_build_cache
  echo "Cache rebuilt!"
}

# Keep SSH agent forwarding alive across detached tmux/zellij reattaches.
_ssh_sock="$HOME/.ssh/agent.sock"
if [[ -n "${SSH_AUTH_SOCK:-}" && -S "$SSH_AUTH_SOCK" && "$SSH_AUTH_SOCK" != "$_ssh_sock" ]]; then
  ln -snf "$SSH_AUTH_SOCK" "$_ssh_sock" 2>/dev/null && [[ -S "$_ssh_sock" ]] && export SSH_AUTH_SOCK="$_ssh_sock"
elif [[ -S "$_ssh_sock" ]]; then
  export SSH_AUTH_SOCK="$_ssh_sock"
fi
unset _ssh_sock

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

if [[ "${DOTFILES_AUTOSUGGEST:-0}" == 1 || ( -z "${SSH_CONNECTION:-}" && "${TERM:-}" != xterm-ghostty && "${TERM_PROGRAM:-}" != ghostty ) ]]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="${ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE:-fg=244}"
  ZSH_AUTOSUGGEST_STRATEGY=(${=ZSH_AUTOSUGGEST_STRATEGY:-history completion})
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="${ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE:-20}"
  _source_first \
    "${HOMEBREW_PREFIX:-}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    "$HOME/.local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if command -v starship >/dev/null 2>&1; then
  # Use a slimmer prompt config in $HOME and ~/.claude when one is bundled.
  if [[ -r "$HOME/.config/starship-home.toml" ]]; then
    export STARSHIP_CONFIG_DEFAULT="${STARSHIP_CONFIG_DEFAULT:-$HOME/.config/starship.toml}"
    export STARSHIP_CONFIG_HOME="${STARSHIP_CONFIG_HOME:-$HOME/.config/starship-home.toml}"
    _starship_select_config() {
      case "$PWD" in
        "$HOME"|"$HOME/.claude"|"$HOME/.claude"/*) export STARSHIP_CONFIG="$STARSHIP_CONFIG_HOME" ;;
        *) export STARSHIP_CONFIG="$STARSHIP_CONFIG_DEFAULT" ;;
      esac
    }
    add-zsh-hook chpwd _starship_select_config
    add-zsh-hook precmd _starship_select_config
    _starship_select_config
  fi
  eval "$(starship init zsh)"
fi

# ${=...} forces word-splitting: zsh keeps an unquoted default as ONE element,
# which would make the plugin build an invalid `typeset ..._main brackets_cache`.
ZSH_HIGHLIGHT_HIGHLIGHTERS=(${=ZSH_HIGHLIGHT_HIGHLIGHTERS:-main brackets})
_source_first \
  "${HOMEBREW_PREFIX:-}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  "$HOME/.local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

unsetopt correct_all
