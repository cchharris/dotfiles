# Home Manager base configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/editor.nix
    ./modules/terminal.nix
    ./modules/git.nix
    ./modules/gnome.nix
  ];

  home.username = "cchharris";
  home.homeDirectory = "/home/cchharris";
  home.stateVersion = "26.05";

  # Enable all home modules
  cchharris.home = {
    shell.enable = true;
    editor.enable = true;
    terminal.enable = true;
    git.enable = true;
    gnome.enable = true;
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
