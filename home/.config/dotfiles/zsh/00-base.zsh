autoload -Uz add-zsh-hook

export LSCOLORS="ExFxCxDxBxegedabagacad"
export LS_COLORS="di=1;34:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=1;33:cd=1;33:su=0;41:sg=0;46:tw=0;42:ow=0;43"
export EZA_COLORS="${EZA_COLORS:-di=34:ln=35:or=31:ex=32:fi=0:pi=33:so=35:bd=1;33:cd=1;33:ur=33:uw=31:ux=32:ue=32:gr=33:gw=31:gx=32:tr=33:tw=31:tx=32:su=37;41:sf=37;41:xa=35:sn=32:sb=2;32:uu=33:un=0:gu=33:gn=0:da=34:lp=35:hd=4;37:xx=90:ga=32:gm=33:gd=31:gv=35:gt=36:gi=90:Gm=1;34:Go=34:Gc=32:Gd=31:bu=36:do=36:sc=0}"
export BAT_THEME="${BAT_THEME:-ansi}"
export CLAUDE_CODE_DISABLE_TERMINAL_TITLE="${CLAUDE_CODE_DISABLE_TERMINAL_TITLE:-1}"
export CLAUDE_CODE_NO_FLICKER="${CLAUDE_CODE_NO_FLICKER:-1}"

if command -v nvim >/dev/null 2>&1; then
  export EDITOR="${EDITOR:-nvim}" VISUAL="${VISUAL:-nvim}"
else
  export EDITOR="${EDITOR:-vim}" VISUAL="${VISUAL:-vim}"
fi
command -v bat >/dev/null 2>&1 && export MANPAGER="${MANPAGER:-sh -c 'col -bx | bat -l man -p'}"
[[ -n "${SSH_CONNECTION:-}" ]] && export BROWSER="${BROWSER:-echo}"

setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY
setopt EXTENDED_HISTORY HIST_FIND_NO_DUPS
# Unconditional: macOS /etc/zshrc pre-sets HISTSIZE=2000, so :- guards never fire.
HISTSIZE=50000
SAVEHIST=50000
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"

bindkey -e
stty -ixon 2>/dev/null
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
