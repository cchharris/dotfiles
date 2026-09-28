# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository location

On Windows this repo is the chezmoi source directory at `~/.local/share/chezmoi/`. On Linux and macOS it's cloned to `~/dotfiles`. Chezmoi deploys files prefixed with `dot_` as dotfiles (e.g. `dot_config/` → `~/.config/`, `dot_zshrc` → `~/.zshrc`). `AppData/` and `private_Library/` hold Windows- and macOS-specific managed files. Repo-only files (flake, `nixos/`, `home/`, `pkgs/`, `scripts/`, this file) are listed in `.chezmoiignore.tmpl` so they aren't deployed into `~`. Patterns there match **target** paths (`.config`, not `dot_config`).

`dot_claude/CLAUDE.md` is the user-level `~/.claude/CLAUDE.md`. It maps this repo and the homelab repo and how they couple. Chezmoi deploys it on Windows, and `cchharris.home.shell.claudeInstructions` deploys it through home-manager (turned off on the work configs). Nix flakes only see git-tracked files, so `git add` a new file before rebuilding.

## Homelab coupling

The NAS host (`nixos/hosts/nas.nix`) and several modules serve the Turing Pi Talos cluster in the **homelab** repo (`cchharris/homelab`, at `~/homelab` on Windows and `~/Repos/homelab` elsewhere). The coupling table and sync rules are in `dot_claude/CLAUDE.md`, and LAN addresses are in `homelab/NETWORK.md`. The touchpoints on this side:
- `nixos/certs/homelab-ca.crt`: the public cert of the cluster's cert-manager CA. It has to be re-exported whenever the cluster is rebuilt from zero.
- `nixos/modules/monitoring.nix`: exporter ports and the cluster-node IP allowlist, scraped by `homelab/cluster/monitoring-integrations/nas.yaml`.
- `nixos/modules/lancache.nix`: the cache that Pi-hole's DNS overrides point at (`homelab/cluster/apps/pihole/*-values.yaml`).
- `nixos/modules/nfs.nix`: `/tank/k8s`, reserved for cluster PVs. No provisioner uses it yet.
- `home/modules/k8s.nix`: talosctl/kubectl/flux/talhelper for administering the cluster.

## Apply changes

**razer-blade** (Hyprland laptop, requires sudo):
```bash
sudo nixos-rebuild switch --flake ~/dotfiles#razer-blade
```

**hobbynix** (Hyprland desktop, run on that machine):
```bash
sudo nixos-rebuild switch --flake ~/dotfiles#hobbynix
```

**nas** (run on that machine; the `hm` alias is `nixos-rebuild switch --flake ~/dotfiles#$(hostname)`):
```bash
sudo nixos-rebuild switch --flake ~/dotfiles#nas
```

**Home Manager only** (no sudo, faster iteration; on NixOS this is the `hm` alias which runs `nixos-rebuild`):
```bash
# On NixOS hosts (razer-blade, hobbynix) — hm alias does this:
sudo nixos-rebuild switch --flake ~/dotfiles#$(hostname)

# Standalone non-NixOS Linux — requires --impure (nixGL uses builtins.currentTime):
home-manager switch --flake ~/dotfiles#cchharris --impure
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
- `nixosConfigurations.nas`: headless NAS at 192.168.1.20 (ZFS, NFS/Samba, LanCache, ncps Nix cache, exporters + Scrutiny). Home-manager gives it shell and nvim only. It supports the homelab cluster (see "Homelab coupling")
- `nixosConfigurations.mainrig`: **speculative, not a real machine.** A planned dev and gaming desktop (Hyprland, RTX 5080). Nothing runs this config
- `nixosConfigurations.aibox`: **speculative, not a real machine.** A planned headless dual-GPU inference box (RTX 5080 + RX 7900 XTX). Nothing runs this config
- `darwinConfigurations.mac` — macOS system config via nix-darwin
- `homeConfigurations.cchharris` — standalone Home Manager (non-NixOS Linux)
- `homeConfigurations.work-mac` — standalone Home Manager (work macOS, aarch64)
- `homeConfigurations.work-linux` — standalone Home Manager (work non-NixOS Linux, username from env)

### NixOS system modules (`nixos/modules/`)

Each module defines a `cchharris.nixos.<name>.enable` option (mkEnableOption pattern). Modules are composed in `nixos/hosts/<hostname>.nix` and wired in `flake.nix`:
- `defaults.nix` — locale, networking, base system packages, user account
- `nvidia.nix` — NVIDIA GPU drivers (supports Optimus for razer-blade, standalone for hobbynix)
- `gaming.nix` — Steam + Proton; includes the `nonSteamLaunchers` custom derivation (see below)
- `hyprland.nix` — Hyprland WM, SDDM login (Catlogin theme, fetched pinned from GitHub), xdg-portal, hyprlock PAM
- `gnome.nix` — GNOME (kept for reference; not used by any active host)
- `desktop-common.nix` — PipeWire, printing, Firefox, Edge, blueman, KDE Connect, 1Password
- `razer.nix` — Razer-specific hardware config (openrazer, polychromatic)
- `howdy.nix` — facial recognition (IR camera); configurable PAM services, certainty threshold, video device
- `tailscale.nix` — Tailscale VPN (all NixOS hosts)
- `xrdp.nix` — RDP server (hobbynix only)
- `fail2ban.nix` — intrusion prevention (hobbynix, nas)
- `zfs.nix` — ZFS pool support: autoscrub, autotrim, encrypted datasets via passphrase-prompt (nas only)
- `nfs.nix` — NFS server, exports configurable per-host (nas only)
- `samba.nix` — Samba file sharing, shares configurable per-host (nas only)
- `smartd.nix` — S.M.A.R.T. drive health monitoring (nas only)
- `zfs-vault.nix` — manually-unlocked encrypted ZFS dataset (nas only)
- `lancache.nix` — game download cache (nas); Pi-hole in the homelab cluster points game CDNs at it
- `monitoring.nix` — Prometheus exporters + Scrutiny (nas); scraped by the homelab cluster
- `nix-cache.nix` / `nix-cache-client.nix` — ncps LAN Nix cache on the nas (port 8501) / use it as a substituter (razer-blade, hobbynix)
- `cachyos.nix` / `cachyos-kernel.nix` — CachyOS-derived tweaks / the linux-cachyos kernel
- `amdgpu.nix` — AMD GPU with ROCm (only aibox uses it, which is speculative)

### macOS system modules (`darwin/modules/`)

- `defaults.nix` — nix-darwin system defaults: Dock, Finder, NSGlobalDomain key repeat, dark mode. Rename `networking.hostName` to match `scutil --get LocalHostName` on the target Mac.

### Home Manager modules (`home/modules/`)

Each module defines a `cchharris.home.<name>.enable` option:
- `shell.nix` — zsh + starship prompt + CLI tools (eza, bat, fd, fzf, claude-code, zoxide, direnv); 1Password SSH agent socket
- `editor.nix` — Neovim with Nix-managed LSP servers and formatters; deploys `dot_config/nvim` via `xdg.configFile`
- `terminal.nix` — Ghostty config
- `git.nix` — git config, delta pager
- `hyprland.nix` — Hyprland user config (keybindings, NVIDIA env vars, wofi, screenshot tools)
- `ashell.nix` / `wayle.nix` / `walker.nix` — status bar / shell (wayle replaces ashell + swaync + swayosd) / app launcher
- `catppuccin.nix` — Catppuccin theming toggle
- `k8s.nix` — talosctl, kubectl, flux, talhelper, helm, k9s + aliases for the homelab cluster (razer-blade; mainrig is speculative)
- `npm-cli.nix` — npm-installed global CLIs not in nixpkgs
- `gnome.nix` — GNOME dconf settings (used by `base.nix` / standalone HM only)

Host home configs: `home/razer-blade.nix`, `home/hobbynix.nix` (Hyprland), `home/mainrig.nix` (speculative host, not a real machine), `home/nas.nix` (headless), `home/base.nix` (standalone, GNOME settings), `home/base-darwin.nix` (personal macOS), `home/work-mac.nix`, `home/work-linux.nix`.

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
