# Linux profile for machines using user-local package managers.
# Shared PATH setup (~/.local/bin, ~/.cargo/bin, ~/.bun/bin, ...) lives in .zshenv.

for _local_prefix in "$HOME/software" "$HOME/opt"; do
  [[ -d "$_local_prefix/bin" ]] && path=("$_local_prefix/bin" "${path[@]}")
done
unset _local_prefix

if [[ -x "$HOME/.local/bin/update-local" ]]; then
  alias update-local="$HOME/.local/bin/update-local"
fi
