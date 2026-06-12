#!/usr/bin/env bash
cat << 'HELP' | less -R --mouse
 ── TMUX CHEATSHEET ──────────────────────────────────────

 MODES (no prefix needed)
  Ctrl+T    Tab      n/x/r/h/l/1-9/Esc
  Ctrl+P    Pane     n(↓)/r(→)/x/f(zoom)/c/hjkl/Esc
  Ctrl+N    Resize   hjkl or arrows (sticky, Esc)
  Ctrl+S    Scroll   see SCROLL section below
  Ctrl+O    Session  d(detach)/n/w(switch)/x/Esc
  Ctrl+G    Lock     passthrough, Ctrl+G to unlock

 QUICK NAVIGATION (no prefix)
  Alt+]     Next tab       Alt+[     Prev tab
  Alt+`     Cycle panes    Alt+i/o   Reorder win

 PREFIX (`) — WINDOWS & PANES
  c/C       New window (after/end)
  - or "    Split H       | or %    Split V
  H/J/K/L   Resize         m         Zoom
  ;         Last pane       l         Last window
  0-9       Goto window     ,         Rename win
  &         Kill window     x         Kill pane
  !         Break to win    .         Move window

 PREFIX (`) — SESSIONS & CLIENTS
  S         New session     d         Detach
  T         Sesh (fzf)      O         Session fzf
  o         Last session    (/)       Prev/next
  s         Session tree    D         Detach other client

 SESSION MANAGEMENT (command prompt: ` :)
  list-clients              Show attached clients
  list-clients -t main      Clients on session "main"
  detach-client -t /dev/... Kick specific client
  detach-client -a          Kick all others
  kill-session -t name      Kill a session
  rename-session newname    Rename current session

 PREFIX (`) — PLUGINS
  Space     Thumbs (copy hints for URLs/paths)
  j         Jump to char    u         URL picker
  P         Floax menu      Alt+\     Floax toggle
  `         Type literal backtick

 PREFIX (`) — COPY & META
  [         Copy mode       ]         Paste
  =         Choose buffer   #         List buffers
  r         Reload config   :         Command prompt
  I/U       Install/Update plugins (TPM)
  k         Keys (fzf)      ?         This help

 SCROLL MODE (Ctrl+S)
  j/k       Line             d/u       Half page
  Ctrl+F/B  Full page        g/G       Top/bottom
  /         Search fwd       ?         Search back
  n/N       Next/prev match  f/F       Jump to char
  v         Select           V         Select line
  Ctrl+V    Rectangle        y         Yank
  Y         Yank+exit        E         Edit $EDITOR
  o         Open             q/Esc     Exit

 SESSION PERSISTENCE
  Auto-saves every 5 min
  ` Ctrl+s   Save    ` Ctrl+r   Restore

 Tip: ` k opens searchable key list via fzf
 Click ? on status bar or press ` ? for this help
HELP
