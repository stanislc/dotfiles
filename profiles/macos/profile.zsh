# macOS profile. Keep private machine shortcuts in local.zsh.

if [[ -d "${HOMEBREW_PREFIX:-}/opt/coreutils/libexec/gnubin" ]]; then
  for _gnu_path in \
    "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/findutils/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/grep/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/gawk/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/diffutils/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/gnu-which/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/make/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/gnu-indent/libexec/gnubin" \
    "$HOMEBREW_PREFIX/opt/gnu-getopt/bin" \
    "$HOMEBREW_PREFIX/opt/rsync/bin" \
    "$HOMEBREW_PREFIX/opt/unzip/bin" \
    "$HOMEBREW_PREFIX/opt/zip/bin" \
    "$HOMEBREW_PREFIX/opt/gzip/bin"; do
    [[ -d "$_gnu_path" ]] && path=("$_gnu_path" "${path[@]}")
  done
  unset _gnu_path
fi

if [[ -d "${HOMEBREW_PREFIX:-}/opt/llvm/bin" ]]; then
  path=("$HOMEBREW_PREFIX/opt/llvm/bin" "${path[@]}")
  export CC="${CC:-$HOMEBREW_PREFIX/opt/llvm/bin/clang}"
  export CXX="${CXX:-$HOMEBREW_PREFIX/opt/llvm/bin/clang++}"
fi

