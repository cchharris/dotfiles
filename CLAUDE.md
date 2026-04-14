# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Apply changes

**NixOS system** (requires sudo):
```bash
sudo nixos-rebuild switch --flake ~/dotfiles#razer-blade
```

**Home Manager only** (no sudo, faster iteration):
```bash
home-manager switch --flake ~/dotfiles#cchharris
# or use the shell alias:
hm
```

**macOS**:
```bash
darwin-rebuild switch --flake ~/dotfiles#mac
```

**Dry-run / check before applying**:
```bash
sudo nixos-rebuild dry-activate --flake ~/dotfiles#razer-blade
```

## Repository architecture

This is a multi-platform dotfiles repo using Nix (NixOS + nix-darwin + Home Manager) for Linux/macOS and chezmoi for Windows.

### Nix entry point

`flake.nix` defines three outputs:
- `nixosConfigurations.razer-blade` — full NixOS system config for the Razer Blade laptop
- `darwinConfigurations.mac` — macOS system config via nix-darwin
- `homeConfigurations.cchharris` — standalone Home Manager (non-NixOS Linux)

### NixOS system modules (`nixos/modules/`)

Each module defines a `cchharris.nixos.<name>.enable` option (mkEnableOption pattern). Modules are composed in `nixos/hosts/razer-blade.nix` and the top-level flake:
- `defaults.nix` — locale, networking, base system packages, user account
- `nvidia.nix` — NVIDIA GPU drivers
- `gaming.nix` — Steam + Proton; includes the `nonSteamLaunchers` custom derivation (see below)
- `desktop.nix` — GNOME, GDM, PipeWire, Firefox, Ghostty
- `razer.nix` — Razer-specific hardware config (openrazer, polychromatic)

### Home Manager modules (`home/modules/`)

Each module defines a `cchharris.home.<name>.enable` option, imported by `home/base.nix` (Linux) or `home/base-darwin.nix` (macOS):
- `shell.nix` — zsh + starship prompt + CLI tools (eza, bat, fd, fzf, claude-code)
- `editor.nix` — Neovim with Nix-managed LSP servers and formatters; deploys `dot_config/nvim` via `xdg.configFile`
- `terminal.nix` — Ghostty config
- `git.nix` — git config, delta pager
- `desktop.nix` — GNOME Home Manager settings

### Neovim config (`dot_config/nvim/`)

Shared across all platforms. Entry: `init.lua` → `lua/config/lazy.lua` bootstraps lazy.nvim. Each plugin has its own file under `lua/plugins/`. On NixOS/macOS, LSP servers come from Nix (see `editor.nix`); on Windows, Mason manages them.

### Windows / chezmoi

Files and directories prefixed with `dot_` are deployed by chezmoi as dotfiles (e.g. `dot_config/` → `~/.config/`). `dot_zshrc` → `~/.zshrc`. The `AppData/` and `private_Library/` directories hold Windows and macOS platform-specific chezmoi-managed files.

## NonSteamLaunchers NixOS wrapping

The `nonSteamLaunchers` derivation in `gaming.nix` is a multi-layer wrapper needed because NSL is a Steam Deck tool that assumes FHS:
1. `GI_TYPELIB_PATH` must be set before entering `steam-run` (for PyGObject/Gtk3)
2. The whole script runs inside `steam-run` for the FHS environment Proton needs
3. Nix deps are stored in env vars before `steam-run` overwrites PATH, then re-prepended inside
4. `/usr/bin/python3` and `/bin/bash` are symlinked via `systemd.tmpfiles.rules`

When updating the NSL script hash, fetch the new sha256 with:
```bash
nix-prefetch-url https://raw.githubusercontent.com/moraroy/NonSteamLaunchers-On-Steam-Deck/main/NonSteamLaunchers.sh
```
