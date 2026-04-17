# Home Manager configuration for christopherharris (work macOS)
{ config, lib, pkgs, ... }:
{
  imports = [
    ./modules/shell.nix
    ./modules/editor.nix
    ./modules/terminal.nix
    ./modules/git.nix
  ];

  home.username = "christopherharris";
  home.homeDirectory = "/Users/christopherharris";
  home.stateVersion = "26.05";

  cchharris.home = {
    shell.enable = true;
    editor.enable = true;
    terminal.enable = true;
    git.enable = true;
  };

  # Override Linux-specific aliases from shell.nix
  programs.zsh.shellAliases = {
    update = lib.mkForce "home-manager switch --flake ~/dotfiles#work-mac";
    hm = lib.mkForce "home-manager switch --flake ~/dotfiles#work-mac";
  };

  programs.home-manager.enable = true;
}
