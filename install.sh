#!/usr/bin/env bash
set -euo pipefail

# install.sh — canonical dotfiles entrypoint
# Used by:
#   - GitHub Codespaces automatic dotfiles install
#   - Humans who want a predictable, idempotent apply

log() { printf "[install] %s\n" "$*"; }

need_cmd() { command -v "$1" >/dev/null 2>&1; }

# -------------------------------
# Ensure chezmoi exists
# -------------------------------
if ! need_cmd chezmoi; then
  log "chezmoi not found, installing"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
fi

# -------------------------------
# Apply dotfiles
# -------------------------------
if [[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/chezmoi" ]]; then
  log "Applying existing dotfiles"
  chezmoi apply
else
  log "Initializing dotfiles"
  chezmoi init --apply
fi

log "install complete"