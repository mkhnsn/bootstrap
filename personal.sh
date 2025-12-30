#!/usr/bin/env bash
set -euo pipefail

# personal.sh — full personal machine bootstrap
# Intended for permanent machines you own and trust.

log() { printf "[personal] %s\n" "$*"; }

need_cmd() { command -v "$1" >/dev/null 2>&1; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "personal.sh is intended for macOS only" >&2
  exit 1
fi

# -------------------------------
# Homebrew
# -------------------------------
if ! need_cmd brew; then
  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is in PATH for this session
eval "$(/opt/homebrew/bin/brew shellenv)"

# -------------------------------
# Core packages
# -------------------------------
log "Installing Brewfile packages"
brew bundle --file "$HOME/.local/share/chezmoi/Brewfile"

# -------------------------------
# Default shell
# -------------------------------
if need_cmd zsh; then
  log "Setting zsh as default shell"
  chsh -s "$(command -v zsh)" "$USER" || true
fi

# -------------------------------
# Final apply (ensures new tools are wired)
# -------------------------------
log "Re-applying chezmoi after installs"
chezmoi apply

log "personal bootstrap complete"