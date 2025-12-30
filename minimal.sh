#!/usr/bin/env bash
set -euo pipefail

# Minimal bootstrap: install chezmoi and apply dotfiles.
# Intended for: throwaway machines, quick comfort setup, or unknown environments.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/mkhnsn/bootstrap/main/minimal.sh | bash

DOTFILES_REPO="https://github.com/mkhnsn/dotfiles.git"

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }

need_cmd() { command -v "$1" >/dev/null 2>&1; }

# -------------------------------
# Platform detection
# -------------------------------
case "$(uname -s)" in
  Darwin) OS="darwin" ;;
  Linux)  OS="linux"  ;;
  *)
    echo "Unsupported OS" >&2
    exit 1
    ;;
esac

# -------------------------------
# Minimal prerequisites
# -------------------------------
install_prereqs_linux() {
  if need_cmd apt-get; then
    sudo apt-get update
    sudo apt-get install -y git curl ca-certificates
  elif need_cmd dnf; then
    sudo dnf install -y git curl ca-certificates
  elif need_cmd yum; then
    sudo yum install -y git curl ca-certificates
  elif need_cmd pacman; then
    sudo pacman -Sy --noconfirm git curl ca-certificates
  else
    echo "No supported package manager found. Install git and curl manually." >&2
    exit 1
  fi
}

install_prereqs_darwin() {
  if ! need_cmd git; then
    log "Triggering Xcode Command Line Tools install"
    xcode-select --install >/dev/null 2>&1 || true
  fi

  if ! need_cmd curl; then
    echo "curl not found on macOS (unexpected)" >&2
    exit 1
  fi
}

# -------------------------------
# Install chezmoi
# -------------------------------
install_chezmoi() {
  if need_cmd chezmoi; then
    log "chezmoi already installed"
    return
  fi

  log "Installing chezmoi"

  if [[ "$OS" == "linux" ]]; then
    sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
  else
    if [[ -w /usr/local/bin ]]; then
      sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
    else
      mkdir -p "$HOME/.local/bin"
      sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
      export PATH="$HOME/.local/bin:$PATH"
    fi
  fi
}

# -------------------------------
# Apply dotfiles
# -------------------------------
apply_dotfiles() {
  if [[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/chezmoi" ]]; then
    log "Applying existing chezmoi config"
    chezmoi apply
  else
    log "Initializing chezmoi"
    chezmoi init --apply "$DOTFILES_REPO"
  fi
}

# -------------------------------
# Main
# -------------------------------
log "minimal bootstrap starting ($OS)"

if [[ "$OS" == "linux" ]]; then
  install_prereqs_linux
else
  install_prereqs_darwin
fi

install_chezmoi
apply_dotfiles

log "done"