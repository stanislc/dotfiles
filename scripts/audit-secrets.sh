#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

patterns=(
  'AKIA[0-9A-Z]{16}'
  '-----BEGIN (RSA|OPENSSH|EC|DSA)? ?PRIVATE KEY-----'
  'api[_-]?key'
  'access[_-]?token'
  'secret'
  'credentials'
  '/Users/[[:alnum:]][[:alnum:]_.-]+/'
  '/home/[[:alnum:]][[:alnum:]_.-]+/'
  '100\.[0-9]+\.[0-9]+\.[0-9]+'
)

status=0
for pattern in "${patterns[@]}"; do
  if matches="$(grep -RInE \
      --exclude-dir=.git \
      --exclude-dir=logs \
      --exclude-dir=.claude \
      --exclude='.gitignore' \
      --exclude='audit-secrets.sh' \
      --exclude='README.md' \
      -- "$pattern" "$repo_dir" \
      | grep -Ev '/home/linuxbrew/')"; then
    echo "Potential match for pattern: $pattern"
    printf '%s\n' "$matches"
    status=1
  fi
done

exit "$status"
