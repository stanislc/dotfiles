# Login-shell additions. Keep this small; non-interactive PATH lives in .zshenv.

if command -v python3 >/dev/null 2>&1; then
  _py_user_base="$(python3 -m site --user-base 2>/dev/null)"
  [[ -n "$_py_user_base" && -d "$_py_user_base/bin" ]] && path=("$path[@]" "$_py_user_base/bin")
  unset _py_user_base
fi

ulimit -n 8192 2>/dev/null || true

