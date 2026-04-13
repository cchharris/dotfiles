# dotfiles

Personal system configuration for all platforms.

- **Linux / macOS** — managed with [Nix](https://nixos.org/) + [Home Manager](https://github.com/nix-community/home-manager) (and [nix-darwin](https://github.com/LnL7/nix-darwin) on macOS)
- **Windows** — managed with [chezmoi](https://www.chezmoi.io/)

## Linux (NixOS)

```bash
sudo nixos-rebuild switch --flake github:cchharris/dotfiles#razer-blade
```

Or from a local clone:

```bash
git clone https://github.com/cchharris/dotfiles.git ~/dotfiles
sudo nixos-rebuild switch --flake ~/dotfiles#razer-blade
```

## macOS

Install Nix if not already present:

```bash
sh <(curl -L https://nixos.org/nix/install)
```

Install nix-darwin on first setup:

```bash
nix run nix-darwin -- switch --flake github:cchharris/dotfiles#mac
```

On subsequent machines or after first install:

```bash
darwin-rebuild switch --flake github:cchharris/dotfiles#mac
```

> **Note:** The `#mac` hostname is a placeholder. Update `darwinConfigurations.mac` in
> `flake.nix` to match your machine's hostname (`scutil --get LocalHostName`).

## Work Linux (non-NixOS / Ubuntu)

Bootstrap a fresh machine with one command:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/cchharris/dotfiles/main/scripts/bootstrap-work-linux.sh)
```

This installs Nix (via Determinate Nix Installer), clones the dotfiles to `~/dotfiles`, and applies the home-manager config for your current user.

After first setup, update with:

```bash
hm   # or: home-manager switch --flake ~/dotfiles#work-linux --impure
```

## Windows

Install [chezmoi](https://www.chezmoi.io/install/) and apply:

```powershell
chezmoi init --apply cchharris
```

This installs packages via winget, sets up PowerShell, and deploys Neovim config.
Subsequent updates:

```powershell
chezmoi update
```

## Repository layout

```
dotfiles/
├── flake.nix                  # Nix entry point (NixOS + nix-darwin + home-manager)
├── flake.lock                 # Pinned dependency versions
├── hardware/                  # Hardware-specific NixOS config
├── nixos/
│   ├── hosts/                 # Per-machine NixOS config
│   └── modules/               # NixOS modules (desktop, nvidia, gaming, razer, …)
├── darwin/
│   └── modules/               # macOS system defaults (nix-darwin)
├── home/
│   ├── base.nix               # Home Manager config for Linux
│   ├── base-darwin.nix        # Home Manager config for macOS
│   └── modules/               # Shared home modules (shell, editor, terminal, git, desktop)
└── dot_config/                # Raw config files deployed by chezmoi (Windows) or nix (Linux/macOS)
    └── nvim/                  # Neovim config — shared across all platforms via lazy.nvim
```

## Neovim

The Neovim config lives in `dot_config/nvim/` and is shared across all platforms:

- **Linux / macOS** — nix deploys the config directory and provides LSP servers on PATH
- **Windows** — chezmoi deploys the config directory; Mason manages LSP servers

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim) on all platforms.
Platform differences (shell commands, Windows-specific keybindings) are handled at runtime
via `vim.fn.has('win32')`.
