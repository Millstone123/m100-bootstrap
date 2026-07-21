#!/usr/bin/env bash
set -euo pipefail

if [[ "${npm_lifecycle_event:-}" != "setup" ]]; then
  echo "Run this installer through: npm run setup" >&2
  exit 1
fi

CONFIG_DIR="$HOME/.m100/tools/config"
PENDING="$CONFIG_DIR/setup.pending"
RECEIPT="$CONFIG_DIR/npm-setup.receipt"

mkdir -p "$CONFIG_DIR"
rm -f "$RECEIPT"
printf 'started=%s\n' "$(date -u +%FT%TZ)" > "$PENDING"

cleanup() {
  rm -f "$PENDING"
}
trap cleanup EXIT

wget -qO- https://m100.cloud/bootstrap | bash
bash ./init-scanner.sh

{
  printf 'installed_by=npm\n'
  printf 'completed=%s\n' "$(date -u +%FT%TZ)"
  printf 'package=%s\n' "${npm_package_name:-m100-bootstrap}"
  printf 'version=%s\n' "${npm_package_version:-unknown}"
} > "$RECEIPT"

echo "M100 installation completed through npm."
