if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -la --icons --group-directories-first --git'
  alias la='eza -a --icons --group-directories-first'
  alias l='eza --icons'
  alias lt='eza -T --icons --level=2'
fi

# Debian/Ubuntu install these under different names; aliases expand recursively.
command -v batcat >/dev/null 2>&1 && alias bat='batcat'
command -v fdfind >/dev/null 2>&1 && alias fd='fdfind'

command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'
command -v fd >/dev/null 2>&1 && alias find='fd'
command -v duf >/dev/null 2>&1 && alias df='duf'
command -v dust >/dev/null 2>&1 && alias du='dust'
command -v procs >/dev/null 2>&1 && alias ps='procs'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
command -v lazygit >/dev/null 2>&1 && alias lg='lazygit'

