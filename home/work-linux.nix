# Home Manager configuration for work Linux (non-NixOS / Ubuntu)
# Username is resolved at switch time via --impure
{ config, lib, pkgs, ... }:
let
  username = builtins.getEnv "USER";
in {
  imports = [
    ./modules/shell.nix
    ./modules/editor.nix
    ./modules/terminal.nix
    ./modules/git.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "26.05";

  cchharris.home = {
    shell.enable = true;
    editor.enable = true;
    terminal.enable = true;
    git.enable = true;
  };

  # Override aliases from shell.nix for standalone home-manager on non-NixOS
  programs.zsh.shellAliases = {
    update = lib.mkForce "home-manager switch --flake ~/dotfiles#work-linux --impure";
    hm     = lib.mkForce "home-manager switch --flake ~/dotfiles#work-linux --impure";
  };

  programs.home-manager.enable = true;
}
