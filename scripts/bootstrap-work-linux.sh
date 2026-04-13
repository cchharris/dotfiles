#!/usr/bin/env bash
# Bootstrap script for work Linux (non-NixOS / Ubuntu)
# Installs Nix, clones dotfiles, and applies home-manager config.
# Idempotent: safe to re-run if a step was already completed.
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
DOTFILES_REPO="https://github.com/cchharris/dotfiles.git"
FLAKE_TARGET="$DOTFILES_DIR#work-linux"

# ── 1. Install Nix ────────────────────────────────────────────────────────────
if ! command -v nix &>/dev/null; then
  echo "==> Installing Nix (Determinate Nix Installer)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  # Source Nix for the rest of this script session
  if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    # shellcheck source=/dev/null
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  fi
else
  echo "==> Nix already installed, skipping."
fi

# ── 2. Clone dotfiles ─────────────────────────────────────────────────────────
if [ ! -d "$DOTFILES_DIR/.git" ]; then
  echo "==> Cloning dotfiles to $DOTFILES_DIR..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "==> Dotfiles already present at $DOTFILES_DIR, skipping clone."
fi

# ── 3. Apply home-manager config ──────────────────────────────────────────────
echo "==> Applying home-manager config for $USER..."
nix run home-manager/master -- switch --flake "$FLAKE_TARGET" --impure

# ── 4. Done ───────────────────────────────────────────────────────────────────
echo ""
echo "Bootstrap complete! Start a new shell (or run: exec zsh) to pick up PATH changes."
echo "Future updates: run 'hm' from any shell."
