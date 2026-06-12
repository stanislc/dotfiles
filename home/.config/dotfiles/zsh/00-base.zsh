autoload -Uz add-zsh-hook

[[ -z "${TERM:-}" ]] && export TERM=xterm-256color

export LSCOLORS="ExFxCxDxBxegedabagacad"
export LS_COLORS="di=1;34:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=1;33:cd=1;33:su=0;41:sg=0;46:tw=0;42:ow=0;43"
export BAT_THEME="${BAT_THEME:-ansi}"
export CLAUDE_CODE_DISABLE_TERMINAL_TITLE="${CLAUDE_CODE_DISABLE_TERMINAL_TITLE:-1}"

setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
HISTSIZE="${HISTSIZE:-10000}"
SAVEHIST="${SAVEHIST:-20000}"
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"

bindkey -e
stty -ixon 2>/dev/null
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

