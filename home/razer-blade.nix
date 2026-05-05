# Home Manager configuration for razer-blade (Hyprland)
{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/editor.nix
    ./modules/terminal.nix
    ./modules/git.nix
    ./modules/hyprland.nix
    ./modules/ashell.nix
    ./modules/walker.nix
  ];

  home.username = "cchharris";
  home.homeDirectory = "/home/cchharris";
  home.stateVersion = "26.05";

  # Enable Hyprland modules instead of GNOME
  cchharris.home = {
    shell.enable = true;
    editor.enable = true;
    terminal.enable = true;
    git.enable = true;
    hyprland = {
      enable = true;
      nvidiaEnvVars = true;  # needed for VA-API and GLX on NVIDIA Optimus
      # nvidiaGbmBackend intentionally off — Optimus uses Intel for display output
      monitorScale = "1.6";
      polychromaticAutostart = true;
    };
    ashell.enable = true;
    walker.enable = true;
  };

  # Discord
  programs.discord.enable = true;

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
