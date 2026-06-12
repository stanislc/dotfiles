# Bash fallback. The primary flow is zsh (home/.zshrc); this mirrors it on
# hosts where zsh is unavailable. Load order matters:
#   ble.sh (--noattach) -> conda -> completion -> aliases -> tools -> ble-attach

case $- in *i*) ;; *) return ;; esac

# Minimal PATH (bash does not read .zshenv).
for _d in "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/.bun/bin" "$HOME/go/bin"; do
  [[ -d "$_d" && ":$PATH:" != *":$_d:"* ]] && PATH="$_d:$PATH"
done
unset _d
export PATH

# History: mirror zsh's shared, deduplicated history behavior.
shopt -s histappend cmdhist checkwinsize
HISTCONTROL=ignoredups:ignorespace
HISTSIZE=10000
HISTFILESIZE=20000
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ble.sh: autosuggestions + syntax highlighting (zsh-autosuggestions and
# zsh-syntax-highlighting in one). Source first with --noattach, attach last.
[[ -r "$HOME/.local/share/blesh/ble.sh" ]] && source "$HOME/.local/share/blesh/ble.sh" --noattach

# Conda/Mamba.
if command -v conda >/dev/null 2>&1; then
  __conda_setup="$(conda shell.bash hook 2>/dev/null)" && eval "$__conda_setup"
  unset __conda_setup
fi

# Completion (system or conda-forge bash-completion).
for _f in /usr/share/bash-completion/bash_completion /etc/bash_completion \
  "${CONDA_PREFIX:-}/share/bash-completion/bash_completion"; do
  [[ -r "$_f" ]] && { source "$_f"; break; }
done
unset _f

# Shared aliases (the file is plain POSIX-compatible aliasing).
[[ -r "$HOME/.config/dotfiles/zsh/20-aliases.zsh" ]] && source "$HOME/.config/dotfiles/zsh/20-aliases.zsh"

# Tools; each one no-ops when not installed.
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash 2>/dev/null)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init --cmd cd bash)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"
# atuin needs preexec hooks in bash; ble.sh provides them.
[[ ${BLE_VERSION-} ]] && command -v atuin >/dev/null 2>&1 && eval "$(atuin init bash)"
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

# tmux attach-or-create, same as the zsh `ta`.
ta() { tmux attach-session -t "${1:-main}" 2>/dev/null || tmux new-session -A -s "${1:-main}"; }

[[ -f "$HOME/.config/dotfiles/local.bash" ]] && source "$HOME/.config/dotfiles/local.bash"

# Must stay the last line: hand control to ble.sh.
[[ ${BLE_VERSION-} ]] && ble-attach
