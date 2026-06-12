# Login bash. Prefer zsh where it exists but is not the login shell
# (managed hosts where chsh is blocked); otherwise use the bash fallback.
if [ -t 1 ] && [ -z "${ZSH_VERSION:-}" ] && command -v zsh >/dev/null 2>&1; then
  export SHELL="$(command -v zsh)"
  exec zsh -l
fi
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
