# Home Manager configuration for the NAS (headless: shell + neovim only).
# No 1Password agent here — use `ssh -A` from a machine that has one.
{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/editor.nix
    ./modules/catppuccin.nix
  ];

  home.username = "cchharris";
  home.homeDirectory = "/home/cchharris";
  home.stateVersion = "25.11";

  cchharris.home = {
    shell = {
      enable = true;
      onePasswordAgent = false;
    };
    editor.enable = true;
    catppuccinTheme.enable = true;
  };

  programs.zsh.oh-my-zsh = {
    enable = true;
    plugins = [ "git" ];
  };

  programs.home-manager.enable = true;
}
