# Home Manager configuration for hobbynix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/editor.nix
    ./modules/terminal.nix
    ./modules/git.nix
    ./modules/hyprland.nix
    ./modules/wayle.nix
    ./modules/walker.nix
    ./modules/catppuccin.nix
  ];

  home.username = "cchharris";
  home.homeDirectory = "/home/cchharris";
  home.stateVersion = "25.11";

  # Enable Hyprland modules instead of GNOME
  cchharris.home = {
    shell.enable = true;
    editor.enable = true;
    terminal.enable = true;
    git = {
      enable = true;
      nasIdentity = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBf0rftj3rBkAvJSi9KYpb2k2VViVhE5D1e/XtD/BhS6";
    };
    hyprland = {
      enable = true;
      nvidiaEnvVars = true;
      nvidiaGbmBackend = true;  # single GPU, no Optimus
    };
    wayle.enable = true;
    walker.enable = true;
    catppuccinTheme.enable = true;
  };

  # Discord
  programs.discord.enable = true;

  # Zsh plugins (from current hobbynix config)
  programs.zsh = {
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
      ];
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
      ];
    };
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
