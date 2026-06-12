# .zshenv already put the active conda root's bin/ on PATH; derive the root
# from the conda binary instead of re-walking install locations.
# whence -p: binary path only, so re-sourcing after conda defines its
# wrapper function still resolves the root correctly.
_conda_bin="$(whence -p conda 2>/dev/null)"
if [[ -n "$_conda_bin" ]]; then
  CONDA_PATH="${_conda_bin:h:h}"
  __conda_setup="$("$_conda_bin" shell.zsh hook 2>/dev/null)"
  if [[ -n "$__conda_setup" ]]; then
    eval "$__conda_setup"
  elif [[ -f "$CONDA_PATH/etc/profile.d/conda.sh" ]]; then
    source "$CONDA_PATH/etc/profile.d/conda.sh"
  fi
  unset __conda_setup
fi
unset _conda_bin

export MAMBA_ROOT_PREFIX="${MAMBA_ROOT_PREFIX:-${CONDA_PATH:-$HOME/conda}}"
if [[ -x "$MAMBA_ROOT_PREFIX/bin/mamba" ]]; then
  export MAMBA_EXE="$MAMBA_ROOT_PREFIX/bin/mamba"
  __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"
  [[ $? -eq 0 ]] && eval "$__mamba_setup"
  unset __mamba_setup
fi

alias ca="conda activate"
alias cda="conda deactivate"
alias cnab="conda activate base"
alias cncf="mamba env create -f"
alias cncn="mamba create -y -n"
alias cnconf="conda config"
alias cncp="mamba create -y -p"
alias cncr="mamba create -n"
alias cncss="conda config --show-source"
alias cnel="conda env list"
alias cni="mamba install"
alias cniy="mamba install -y"
alias cnl="conda list"
alias cnle="conda list --export"
alias cnles="conda list --explicit > spec-file.txt"
alias cnr="mamba remove"
alias cnrn="mamba remove -y --all -n"
alias cnrp="mamba remove -y --all -p"
alias cnry="mamba remove -y"
alias cnsr="mamba search"
alias cnu="mamba update"
alias cnua="mamba update --all"
alias cnuc="mamba update conda"

# Auto-activate the env named in ./environment.yml when cd-ing into a project.
if [[ -n "${CONDA_PATH:-}" ]]; then
  auto_conda_activate() {
    [[ -f environment.yml ]] || return 0
    local env_name
    env_name="$(grep '^name:' environment.yml | cut -d' ' -f2)"
    if [[ -n "$env_name" && "${CONDA_DEFAULT_ENV:-}" != "$env_name" ]]; then
      conda activate "$env_name" 2>/dev/null
    fi
  }
  add-zsh-hook chpwd auto_conda_activate
fi

