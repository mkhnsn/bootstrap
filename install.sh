#!/usr/bin/env bash
set -euo pipefail

# Public bootstrapper for mkhnsn/dotfiles (private repo).
# Installs chezmoi, then runs `chezmoi init --apply`.

DOTFILES_REPO_SSH="${DOTFILES_REPO_SSH:-git@github.com:mkhnsn/dotfiles.git}"
DOTFILES_REPO_HTTPS="${DOTFILES_REPO_HTTPS:-https://github.com/mkhnsn/dotfiles.git}"
DOTFILES_REF="${DOTFILES_REF:-}"

has() { command -v "$1" >/dev/null 2>&1; }

install_chezmoi_darwin() {
  if has brew; then
    brew install chezmoi
  else
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

install_chezmoi_linux() {
  if has apt-get; then
    sudo apt-get update
    sudo apt-get install -y curl git ca-certificates
  elif has dnf; then
    sudo dnf install -y curl git ca-certificates
  elif has yum; then
    sudo yum install -y curl git ca-certificates
  elif has pacman; then
    sudo pacman -Sy --noconfirm curl git ca-certificates
  fi

  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
}

main() {
  if ! has curl; then
    echo "curl is required." >&2
    exit 1
  fi

  if ! has chezmoi; then
    case "$(uname -s)" in
      Darwin) install_chezmoi_darwin ;;
      Linux)  install_chezmoi_linux ;;
      *)
        echo "Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
    esac
  fi

  # Prefer SSH (works great on your Macs with 1Password SSH agent),
  # fall back to HTTPS if SSH isn't usable.
  repo="$DOTFILES_REPO_SSH"
  if [[ "${DOTFILES_USE_HTTPS:-}" == "1" ]]; then
    repo="$DOTFILES_REPO_HTTPS"
  fi

  # Apply dotfiles
  if [[ -z "$DOTFILES_REF" ]]; then
    chezmoi init --apply "$repo"
  else
    chezmoi init --apply --branch "$DOTFILES_REF" "$repo"
  fi

  echo "Done. Restart your shell (or: exec zsh)."
}

main "$@"