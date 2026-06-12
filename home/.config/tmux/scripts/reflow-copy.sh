#!/bin/sh
set -eu

tmp_in="$(mktemp)"
tmp_out="$(mktemp)"
trap 'rm -f "$tmp_in" "$tmp_out"' EXIT

cat >"$tmp_in"

awk '
function ltrim(value) {
  sub(/^[[:space:]]+/, "", value)
  return value
}

function rtrim(value) {
  sub(/[[:space:]]+$/, "", value)
  return value
}

function flush_block() {
  if (block != "") {
    print block
    block = ""
    mode = ""
  }
}

function is_list_start(value) {
  return value ~ /^[[:space:]]*([-*+]|[0-9]+[.)])[[:space:]]+/
}

function is_verbatim(value) {
  return value ~ /^[[:space:]]*>/ ||
         value ~ /^[[:space:]]*#/ ||
         value ~ /^[[:space:]]*\|/ ||
         value ~ /^[[:space:]]*[-:|][-|:[:space:]]*$/ ||
         value ~ /^\t/ ||
         value ~ /^    /
}

BEGIN {
  in_code_block = 0
  mode = ""
  block = ""
}

{
  raw = $0
  sub(/\r$/, "", raw)

  if (raw ~ /^```/) {
    flush_block()
    print raw
    in_code_block = !in_code_block
    next
  }

  if (in_code_block) {
    print raw
    next
  }

  if (raw ~ /^[[:space:]]*$/) {
    flush_block()
    print ""
    next
  }

  if (is_list_start(raw)) {
    flush_block()
    block = rtrim(raw)
    mode = "list"
    next
  }

  if (mode == "list") {
    if (is_verbatim(raw)) {
      flush_block()
      print raw
      next
    }

    raw = ltrim(rtrim(raw))
    if (raw != "") {
      block = block " " raw
    }
    next
  }

  if (is_verbatim(raw)) {
    flush_block()
    print raw
    next
  }

  raw = ltrim(rtrim(raw))

  if (mode != "paragraph") {
    flush_block()
    block = raw
    mode = "paragraph"
  } else {
    block = block " " raw
  }
}

END {
  flush_block()
}
' "$tmp_in" >"$tmp_out"

if [ -x "$HOME/.local/bin/osc-copy" ]; then
  exec "$HOME/.local/bin/osc-copy" <"$tmp_out"
fi

if command -v pbcopy >/dev/null 2>&1; then
  exec pbcopy <"$tmp_out"
fi

if [ -n "${DISPLAY:-}" ] && command -v xclip >/dev/null 2>&1; then
  exec xclip -selection clipboard <"$tmp_out"
fi

cat "$tmp_out"
