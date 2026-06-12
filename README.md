# Dotfiles

Portable shell, tmux, Vim/Neovim, Ghostty, Conda/Mamba, and Starship
configuration for macOS and Linux.

The repository is split into shared files plus capability profiles:

- `macos`: Homebrew-first macOS machines.
- `linux-sudo`: Linux machines where system packages can be installed.
- `linux-nosudo`: Linux machines using user-local package managers
  (conda, cargo, release tarballs).

The installer uses the current `$HOME`; no username is hard-coded.

## Quick Start (new machine or new user)

```sh
git clone https://github.com/stanislc/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run   # preview everything first
./install.sh
exec zsh
```

Then inside tmux press `prefix + I` once to install tmux plugins, and run
`:PlugInstall` once in Vim/Neovim.

`install.sh` does three things, in order:

1. **Links** configs into `$HOME` (existing files are backed up as `*.bak-<timestamp>`).
2. **Installs packages** for the profile: Homebrew + `packages/Brewfile` on
   macOS, `packages/linux-sudo-packages.txt` via apt on Linux with sudo. On
   no-sudo machines it points to `packages/linux-nosudo-notes.md` instead.
3. **Bootstraps plugin managers**: TPM for tmux, vim-plug for Vim/Neovim, and
   (on Linux) fzf-tab, zsh-autosuggestions, and zsh-syntax-highlighting into
   `~/.local/share/`.

Useful flags:

- `--profile macos|linux-sudo|linux-nosudo` — skip auto-detection (recommended on new hosts)
- `--dry-run` — print every action without executing
- `--skip-packages` — link configs only, install nothing (good for trying out the configs)
- `--force` — replace existing files instead of backing them up

Re-running `install.sh` is safe: links and clones are idempotent.

## Choosing What Gets Installed

The package lists are the interface — edit them:

- `packages/Brewfile` — shared macOS package set (`brew bundle` format).
- `packages/Brewfile.local` — optional, untracked, per-machine extras
  (installed automatically when present).
- `packages/linux-sudo-packages.txt` — one apt package per line, `#` comments
  skipped; a missing package warns instead of aborting.
- `packages/linux-nosudo-notes.md` — manual hints for machines without sudo.

To snapshot what is actually installed on a Mac back into the repo:

```sh
brew bundle dump --force --file=packages/Brewfile
```

Review the diff before committing — `dump` records everything installed,
including one-off experiments.

## Local Overrides

Machine-specific or private settings go in files that are not tracked:

```text
~/.config/dotfiles/local.zsh
~/.config/dotfiles/local.bash
```

Use these for private endpoints, API variables, machine shortcuts, SSH socket
paths, and project-specific aliases. They are sourced last and never touched
by the installer. For host-only file snippets, `local/`, `private/`, and
`secrets/` directories inside the repo are gitignored.

## Privacy Rules

Do not commit:

- credentials, tokens, SSH keys, API keys, or keychain bridge scripts
- shell history, tmux resurrect state, tmux plugin checkouts, Vim plugin checkouts
- machine caches, backup files, `.DS_Store`, Claude Code logs
- absolute account paths such as `/Users/name` or `/home/name`
- private network addresses, Tailnet hostnames, or project-specific paths

All reusable paths should use `$HOME`, `~`, `$XDG_CONFIG_HOME`,
`$XDG_STATE_HOME`, or command discovery. Before committing, run:

```sh
./scripts/audit-secrets.sh
```

## What Is Included

- `home/.zshenv`: non-interactive PATH bootstrap
- `home/.zprofile`: login-shell additions
- `home/.zshrc`: interactive shell entrypoint
- `home/.bashrc`: bash fallback mirroring the zsh flow (ble.sh, fzf, zoxide,
  direnv, atuin, starship) for hosts where zsh is unavailable
- `home/.config/dotfiles/zsh/*.zsh`: zsh modules (history, completion, aliases, conda, tools, tmux)
- `home/.config/tmux/tmux.conf`: tmux defaults, modal controls, restore behavior
- `home/.config/tmux/scripts/*.sh`: tmux helper scripts
- `home/.config/zellij/config.kdl`: Zellij keybinds (tmux-style Ctrl+b mode) and
  theme — config only, zellij itself is not in the package lists
- `home/.local/bin/osc-copy`: OSC 52 clipboard helper used by tmux and Zellij;
  copies to every attached client, works over SSH
- `home/.config/ghostty/config`: Ghostty terminal settings (macOS)
- `home/.vimrc`, `home/.config/nvim/init.vim`: Vim/Neovim defaults and plugins
- `home/.condarc`: conda-forge + libmamba defaults
- `profiles/*/profile.zsh`, `profiles/*/starship.toml`: per-platform shell and prompt config

## Daily Use

- `ta [session]` — attach to a tmux session, creating it if needed (default: `main`).
- tmux auto-saves every 5 minutes (`tmux-continuum`) and restores saved
  sessions when the server starts.
- After an intentional `kill-session`, a lightweight snapshot is written so
  the closed session is not restored next time.
