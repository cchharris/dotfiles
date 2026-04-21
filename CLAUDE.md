# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository location

The chezmoi source directory (this repo) lives at `~/.local/share/chezmoi/`. Chezmoi deploys files prefixed with `dot_` as dotfiles (e.g. `dot_config/` → `~/.config/`, `dot_zshrc` → `~/.zshrc`). `AppData/` and `private_Library/` hold Windows- and macOS-specific managed files.

## Apply changes

**razer-blade** (Hyprland laptop, requires sudo):
```bash
sudo nixos-rebuild switch --flake ~/dotfiles#razer-blade
```

**hobbynix** (Hyprland desktop, run on that machine):
```bash
sudo nixos-rebuild switch --flake ~/dotfiles#hobbynix
```

**Home Manager only** (no sudo, faster iteration):
```bash
home-manager switch --flake ~/dotfiles#cchharris
# or use the shell alias:
hm
```

**macOS** (personal):
```bash
darwin-rebuild switch --flake ~/dotfiles#mac
```

**work-mac** (standalone Home Manager):
```bash
home-manager switch --flake ~/dotfiles#work-mac
```

**work-linux** (standalone Home Manager on non-NixOS; `--impure` required so `builtins.getEnv "USER"` resolves at build time):
```bash
nix run github:nix-community/home-manager/master -- switch --flake ~/dotfiles#work-linux --impure
# or after first install, via alias:
hm
```

**Windows** (chezmoi):
```bash
chezmoi apply
```

**Dry-run / check before applying**:
```bash
sudo nixos-rebuild dry-activate --flake ~/dotfiles#razer-blade
sudo nixos-rebuild dry-activate --flake ~/dotfiles#hobbynix
```

## Repository architecture

This is a multi-platform dotfiles repo using Nix (NixOS + nix-darwin + Home Manager) for Linux/macOS and chezmoi for Windows.

### Nix entry point

`flake.nix` defines these outputs:
- `nixosConfigurations.razer-blade` — Razer Blade laptop (Hyprland + NVIDIA Optimus)
- `nixosConfigurations.hobbynix` — desktop PC (Hyprland + GTX 1080, xrdp, fail2ban)
- `darwinConfigurations.mac` — macOS system config via nix-darwin
- `homeConfigurations.cchharris` — standalone Home Manager (non-NixOS Linux)
- `homeConfigurations.work-mac` — standalone Home Manager (work macOS, aarch64)
- `homeConfigurations.work-linux` — standalone Home Manager (work non-NixOS Linux, username from env)

### NixOS system modules (`nixos/modules/`)

Each module defines a `cchharris.nixos.<name>.enable` option (mkEnableOption pattern). Modules are composed in `nixos/hosts/<hostname>.nix` and wired in `flake.nix`:
- `defaults.nix` — locale, networking, base system packages, user account
- `nvidia.nix` — NVIDIA GPU drivers (supports Optimus for razer-blade, standalone for hobbynix)
- `gaming.nix` — Steam + Proton; includes the `nonSteamLaunchers` custom derivation (see below)
- `hyprland.nix` — Hyprland WM, greetd/gtkgreet login, xdg-portal, hyprlock PAM
- `gnome.nix` — GNOME (kept for reference; not used by any active host)
- `desktop-common.nix` — PipeWire, printing, Firefox, Edge, blueman, KDE Connect, 1Password
- `razer.nix` — Razer-specific hardware config (openrazer, polychromatic)
- `howdy.nix` — facial recognition (IR camera); configurable PAM services, certainty threshold, video device
- `tailscale.nix` — Tailscale VPN (both hosts)
- `xrdp.nix` — RDP server (hobbynix only)
- `fail2ban.nix` — intrusion prevention (hobbynix only)

### macOS system modules (`darwin/modules/`)

- `defaults.nix` — nix-darwin system defaults: Dock, Finder, NSGlobalDomain key repeat, dark mode. Rename `networking.hostName` to match `scutil --get LocalHostName` on the target Mac.

### Home Manager modules (`home/modules/`)

Each module defines a `cchharris.home.<name>.enable` option:
- `shell.nix` — zsh + starship prompt + CLI tools (eza, bat, fd, fzf, claude-code, zoxide, direnv); 1Password SSH agent socket
- `editor.nix` — Neovim with Nix-managed LSP servers and formatters; deploys `dot_config/nvim` via `xdg.configFile`
- `terminal.nix` — Ghostty config
- `git.nix` — git config, delta pager
- `hyprland.nix` — Hyprland user config (keybindings, NVIDIA env vars, wofi, screenshot tools)
- `hyprpanel.nix` — HyprPanel bar (workspaces, media, clock, systray; SauceCodePro Nerd Font)
- `gnome.nix` — GNOME dconf settings (used by `base.nix` / standalone HM only)

Host home configs: `home/razer-blade.nix` (Hyprland), `home/hobbynix.nix` (Hyprland), `home/base.nix` (standalone, GNOME settings), `home/base-darwin.nix` (personal macOS), `home/work-mac.nix`, `home/work-linux.nix`.

### Neovim config (`dot_config/nvim/`)

Shared across all platforms. Entry: `init.lua` → `lua/config/lazy.lua` bootstraps lazy.nvim. Each plugin has its own file under `lua/plugins/`. On NixOS/macOS, LSP servers come from Nix (see `editor.nix`); on Windows, Mason manages them.

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
