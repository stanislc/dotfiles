# Essential PATH for non-interactive shells (SSH, tmux, scripts, headless).
typeset -U path PATH

if [[ -n "${SHELL:-}" && ! -x "$SHELL" && -x /bin/zsh ]]; then
  export SHELL=/bin/zsh
fi

_path_prepend() {
  [[ -d "$1" ]] && path=("$1" "${path[@]}")
}

# Homebrew and Linuxbrew.
for _brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
  if [[ -d "$_brew_prefix/bin" ]]; then
    export HOMEBREW_PREFIX="$_brew_prefix"
    export HOMEBREW_CELLAR="${HOMEBREW_CELLAR:-$_brew_prefix/Cellar}"
    export HOMEBREW_REPOSITORY="${HOMEBREW_REPOSITORY:-$_brew_prefix}"
    _path_prepend "$_brew_prefix/sbin"
    _path_prepend "$_brew_prefix/bin"
    break
  fi
done
unset _brew_prefix

_path_prepend "$HOME/.local/bin"
_path_prepend "$HOME/.cargo/bin"
_path_prepend "$HOME/go/bin"
_path_prepend "$HOME/.bun/bin"
_path_prepend "$HOME/.claude/bin"
_path_prepend "$HOME/.local/dnfroot/usr/bin"

export CLAUDE_CODE_DISABLE_TERMINAL_TITLE="${CLAUDE_CODE_DISABLE_TERMINAL_TITLE:-1}"

# Conda/Mamba roots. Prefer user-local roots and avoid account-specific paths.
for _conda_root in \
  "$HOME/miniforge3" \
  "$HOME/mambaforge" \
  "$HOME/conda" \
  "$HOME/miniconda3" \
  "$HOME/anaconda3" \
  "$HOME/software/mambaforge" \
  "${HOMEBREW_PREFIX:-/opt/homebrew}/Caskroom/miniforge/base"; do
  if [[ -d "$_conda_root/bin" ]]; then
    _path_prepend "$_conda_root/bin"
    break
  fi
done
unset _conda_root

# NVM node for non-interactive tools.
if [[ -d "$HOME/.nvm/versions/node" ]]; then
  autoload -Uz is-at-least
  _nvm_node_dir=
  _nvm_node_version=
  for _nvm_candidate in "$HOME/.nvm/versions/node"/v*(N/); do
    _nvm_candidate_version="${_nvm_candidate:t}"
    _nvm_candidate_version="${_nvm_candidate_version#v}"
    if [[ -z "$_nvm_node_version" ]] || is-at-least "$_nvm_node_version" "$_nvm_candidate_version"; then
      _nvm_node_dir="$_nvm_candidate"
      _nvm_node_version="$_nvm_candidate_version"
    fi
  done
  [[ -n "$_nvm_node_dir" && -d "$_nvm_node_dir/bin" ]] && _path_prepend "$_nvm_node_dir/bin"
  unset _nvm_node_dir _nvm_node_version _nvm_candidate _nvm_candidate_version
fi

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export TMUX_TMPDIR="${TMUX_TMPDIR:-$XDG_STATE_HOME/tmux}"
[[ -d "$TMUX_TMPDIR" ]] || mkdir -p -m 700 "$TMUX_TMPDIR" 2>/dev/null
chmod 700 "$TMUX_TMPDIR" 2>/dev/null

[[ -d /Library/TeX/texbin ]] && _path_prepend /Library/TeX/texbin

export PATH
