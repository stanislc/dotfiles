# Linux No-Sudo Package Notes

Use user-local package managers and keep updates behind `update-local` when
possible:

- Conda/Mamba: Python tooling, git, tmux, neovim when available
- Cargo: starship, zoxide, eza, fd, ripgrep, bat, dust, procs
- npm/bun: JavaScript tooling that is not available elsewhere
- official release tarballs: `gh` when conda/cargo packages are unavailable

Prefer executable paths under:

```text
~/.local/bin
~/.cargo/bin
~/software/mambaforge/bin
~/.bun/bin
```

## Getting the zsh flow without sudo

zsh itself is on conda-forge: `mamba install -y -n base zsh`. The installer's
`exec zsh` fallback in `~/.bash_profile` then gives you the full dotfiles flow
even where `chsh` is blocked — prefer this over recreating the setup in bash.

## Bash fallback (hosts where zsh is not an option)

Most of the toolchain is shell-agnostic — starship, zoxide, direnv, atuin, and
fzf each have a bash init line (`starship init bash`, `zoxide init bash`,
`direnv hook bash`, `atuin init bash`, `fzf --bash`). The zsh-only pieces map
to:

- zsh-autosuggestions + zsh-syntax-highlighting -> [ble.sh](https://github.com/akinomyoga/ble.sh).
  `home/.bashrc` already sources it when installed at `~/.local/share/blesh`:

  ```sh
  curl -L https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz | tar xJf -
  bash ble-nightly/ble.sh --install ~/.local/share && rm -rf ble-nightly
  ```
- fzf-tab -> [fzf-tab-completion](https://github.com/lincheney/fzf-tab-completion)
- zsh-completions -> `bash-completion` (conda-forge)
- shared history -> built-in: `shopt -s histappend` + `PROMPT_COMMAND='history -a'`

