#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
profile=""
dry_run=0
force=0
skip_packages=0

usage() {
  cat <<'USAGE'
Usage: ./install.sh [--profile macos|linux-sudo|linux-nosudo] [--dry-run] [--force] [--skip-packages]

Links dotfiles into the current user's HOME, installs packages for the profile
(Homebrew + Brewfile on macOS, system packages on linux-sudo), and bootstraps
tmux/vim plugin managers. Existing files are backed up unless they are already
the expected symlink. Private local overrides are never touched.

  --skip-packages   Only link config files; install no software.
USAGE
}

while (($#)); do
  case "$1" in
    --profile)
      profile="${2:-}"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --force)
      force=1
      shift
      ;;
    --skip-packages)
      skip_packages=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

detect_profile() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)
      if command -v sudo >/dev/null 2>&1 && id -nG 2>/dev/null | grep -Eq '(^| )(sudo|wheel|admin)( |$)'; then
        echo linux-sudo
      else
        echo linux-nosudo
      fi
      ;;
    *)
      echo "Unsupported OS: $(uname -s)" >&2
      exit 2
      ;;
  esac
}

profile="${profile:-$(detect_profile)}"
case "$profile" in
  macos|linux-sudo|linux-nosudo) ;;
  *)
    echo "Invalid profile: $profile" >&2
    exit 2
    ;;
esac

run() {
  if ((dry_run)); then
    printf 'DRY-RUN:'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

link_file() {
  local src="$1"
  local dst="$2"
  local backup

  if [[ ! -e "$src" ]]; then
    echo "Missing source: $src" >&2
    exit 1
  fi

  run mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "ok: $dst"
    return
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    backup="${dst}.bak-$(date +%Y%m%d%H%M%S)"
    if ((force)); then
      run rm -rf "$dst"
    else
      run mv "$dst" "$backup"
    fi
  fi

  run ln -s "$src" "$dst"
}

link_file "$repo_dir/home/.zshenv" "$HOME/.zshenv"
link_file "$repo_dir/home/.zprofile" "$HOME/.zprofile"
link_file "$repo_dir/home/.zshrc" "$HOME/.zshrc"
link_file "$repo_dir/home/.bashrc" "$HOME/.bashrc"
link_file "$repo_dir/home/.vimrc" "$HOME/.vimrc"
link_file "$repo_dir/home/.config/nvim/init.vim" "$HOME/.config/nvim/init.vim"
link_file "$repo_dir/home/.condarc" "$HOME/.condarc"

link_file "$repo_dir/home/.local/bin/osc-copy" "$HOME/.local/bin/osc-copy"
link_file "$repo_dir/home/.config/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"

link_file "$repo_dir/home/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
for script in "$repo_dir"/home/.config/tmux/scripts/*.sh; do
  link_file "$script" "$HOME/.config/tmux/scripts/$(basename "$script")"
done

run mkdir -p "$HOME/.config/dotfiles"
link_file "$repo_dir/home/.config/dotfiles/zsh" "$HOME/.config/dotfiles/zsh"
link_file "$repo_dir/profiles/$profile/profile.zsh" "$HOME/.config/dotfiles/profile.zsh"
link_file "$repo_dir/profiles/$profile/starship.toml" "$HOME/.config/starship.toml"

if [[ "$profile" == macos ]]; then
  link_file "$repo_dir/home/.config/ghostty/config" "$HOME/.config/ghostty/config"
fi

clone_if_missing() {
  local url="$1"
  local dst="$2"
  [[ -d "$dst" ]] && return 0
  if command -v git >/dev/null 2>&1; then
    run git clone --depth 1 "$url" "$dst"
  else
    echo "skip (no git): $dst" >&2
  fi
}

# Install a single binary from a GitHub release tarball into ~/.local/bin.
# Used on Linux for tools that apt does not package; macOS gets them via brew.
install_release_bin() {
  local url="$1" bin="$2" tmp src
  command -v "$bin" >/dev/null 2>&1 && return 0
  if ((dry_run)); then
    echo "DRY-RUN: install $bin from $url"
    return 0
  fi
  tmp="$(mktemp -d)"
  if curl -fsSL "$url" -o "$tmp/pkg.tar.gz" && tar -xzf "$tmp/pkg.tar.gz" -C "$tmp"; then
    src="$(find "$tmp" -type f -name "$bin" | head -1)"
    if [[ -n "$src" ]]; then
      mkdir -p "$HOME/.local/bin"
      install -m 755 "$src" "$HOME/.local/bin/$bin"
      echo "installed: $bin -> ~/.local/bin/$bin"
    else
      echo "no $bin binary in tarball: $url" >&2
    fi
  else
    echo "download failed: $bin" >&2
  fi
  rm -rf "$tmp"
}

install_packages() {
  case "$profile" in
    macos)
      if ! command -v brew >/dev/null 2>&1; then
        run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
          [[ -x "$b" ]] && { eval "$("$b" shellenv)"; break; }
        done
      fi
      run brew bundle --file="$repo_dir/packages/Brewfile"
      # Optional untracked per-machine extras.
      if [[ -f "$repo_dir/packages/Brewfile.local" ]]; then
        run brew bundle --file="$repo_dir/packages/Brewfile.local"
      fi
      ;;
    linux-sudo)
      if command -v apt-get >/dev/null 2>&1; then
        run sudo apt-get update
        # Per-package so one missing name does not abort the rest.
        while IFS= read -r pkg; do
          [[ -z "$pkg" || "$pkg" == \#* ]] && continue
          run sudo apt-get install -y "$pkg" </dev/null || echo "not in apt: $pkg" >&2
        done <"$repo_dir/packages/linux-sudo-packages.txt"
        # Debian/Ubuntu rename these; real symlinks (not aliases) so tmux
        # bindings and scripts find them too.
        run mkdir -p "$HOME/.local/bin"
        command -v fd >/dev/null 2>&1 || { command -v fdfind >/dev/null 2>&1 && run ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"; }
        command -v bat >/dev/null 2>&1 || { command -v batcat >/dev/null 2>&1 && run ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"; }
      else
        echo "No apt-get found; install packages/linux-sudo-packages.txt manually." >&2
      fi
      ;;
    linux-nosudo)
      echo "No sudo: see packages/linux-nosudo-notes.md for conda/cargo install hints."
      ;;
  esac

  # Tools apt does not package; user-local installs (work without sudo).
  if [[ "$profile" != macos ]]; then
    if ! command -v starship >/dev/null 2>&1; then
      run sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y -b "$HOME/.local/bin"
    fi
    local arch sesh_arch lg_ver
    arch="$(uname -m)"
    sesh_arch="x86_64"; [[ "$arch" == aarch64 || "$arch" == arm64 ]] && sesh_arch="arm64"
    install_release_bin "https://github.com/joshmedeski/sesh/releases/latest/download/sesh_Linux_${sesh_arch}.tar.gz" sesh
    install_release_bin "https://github.com/atuinsh/atuin/releases/latest/download/atuin-${arch}-unknown-linux-gnu.tar.gz" atuin
    if ! command -v lazygit >/dev/null 2>&1; then
      lg_ver="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -om1 '"tag_name": *"v[^"]*"' | cut -d'"' -f4)"
      [[ -n "$lg_ver" ]] && install_release_bin "https://github.com/jesseduffield/lazygit/releases/download/${lg_ver}/lazygit_${lg_ver#v}_linux_${sesh_arch}.tar.gz" lazygit
    fi
  fi

  # Conda comes from the official miniforge installer (never brew/apt); the
  # zsh config auto-detects ~/miniforge3.
  if ! command -v conda >/dev/null 2>&1 && [[ ! -d "$HOME/miniforge3" ]]; then
    run curl -fsSL -o /tmp/miniforge.sh \
      "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    run bash /tmp/miniforge.sh -b -p "$HOME/miniforge3"
    run rm -f /tmp/miniforge.sh
  fi
}

if ((skip_packages)); then
  echo "Skipping package installation (--skip-packages)."
else
  install_packages
fi

# Make zsh the login shell (Linux defaults to bash). chsh is often blocked on
# managed/no-sudo hosts; fall back to exec'ing zsh from ~/.bash_profile.
ensure_zsh_default() {
  local zsh_path
  zsh_path="$(command -v zsh || true)"
  if [[ -z "$zsh_path" ]]; then
    echo "zsh not found; login shell unchanged." >&2
    return
  fi
  [[ "$(basename "${SHELL:-}")" == zsh ]] && return
  if ((dry_run)); then
    run chsh -s "$zsh_path"
    return
  fi
  if chsh -s "$zsh_path" 2>/dev/null; then
    echo "Login shell set to $zsh_path (takes effect on next login)."
  elif ! grep -q 'dotfiles: exec zsh' "$HOME/.bash_profile" 2>/dev/null; then
    cat >>"$HOME/.bash_profile" <<'BASHEOF'

# dotfiles: exec zsh when chsh is not permitted on this host.
if [ -t 1 ] && [ -z "${ZSH_VERSION:-}" ] && command -v zsh >/dev/null 2>&1; then
  export SHELL="$(command -v zsh)"
  exec zsh -l
fi
# Still in bash (no zsh on this host): use the bash fallback config.
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
BASHEOF
    echo "chsh not permitted; added exec-zsh fallback to ~/.bash_profile."
  fi
}
ensure_zsh_default

# Plugin managers and zsh plugins that no package manager provides everywhere.
clone_if_missing https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
# Headless tmux plugin install so no manual prefix+I is needed.
if command -v tmux >/dev/null 2>&1 && [[ -x "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" ]]; then
  run "$HOME/.config/tmux/plugins/tpm/bin/install_plugins" || echo "tmux plugin install failed; run prefix+I inside tmux." >&2
fi
if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
  run curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
if [[ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" ]]; then
  run curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
if [[ "$profile" != macos ]]; then
  clone_if_missing https://github.com/Aloxaf/fzf-tab "$HOME/.local/share/fzf-tab"
  clone_if_missing https://github.com/zsh-users/zsh-autosuggestions "$HOME/.local/share/zsh-autosuggestions"
  clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.local/share/zsh-syntax-highlighting"
fi

echo "Installed profile: $profile"
echo "Optional local overrides: $HOME/.config/dotfiles/local.zsh"
echo "Next step: restart your shell (exec zsh)."
