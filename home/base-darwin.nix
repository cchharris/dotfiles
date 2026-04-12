# Home Manager base configuration (macOS)
{ config, lib, pkgs, ... }:
{
  imports = [
    ./modules/shell.nix
    ./modules/editor.nix
    ./modules/terminal.nix
    ./modules/git.nix
    # desktop.nix excluded — GNOME-specific
  ];

  home.username = "cchharris";
  home.homeDirectory = "/Users/cchharris";
  home.stateVersion = "26.05";

  cchharris.home = {
    shell.enable = true;
    editor.enable = true;
    terminal.enable = true;
    git.enable = true;
  };

  programs.home-manager.enable = true;
}
