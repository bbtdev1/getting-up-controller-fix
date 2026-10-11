#!/usr/bin/env bash
set -euo pipefail
read -r -p "Path to your game installation: " GAME_PATH
BINDS_FILE="$GAME_PATH/engine/binds_pc.cfg"
PATCH_FILE="$(dirname "$0")/../patch/binds_pc.cfg.patch"
[[ -f "$BINDS_FILE" ]] || { echo "Error: binds_pc.cfg not found."; exit 1; }
[[ -f "$PATCH_FILE" ]] || { echo "Error: patch file not found."; exit 1; }
if patch --dry-run -N "$BINDS_FILE" < "$PATCH_FILE" >/dev/null 2>&1; then
  [[ -f "$BINDS_FILE.backup" ]] || cp "$BINDS_FILE" "$BINDS_FILE.backup"
  patch -N "$BINDS_FILE" < "$PATCH_FILE"
else
  echo "Patch cannot be applied cleanly; no changes made."
  exit 1
fi
