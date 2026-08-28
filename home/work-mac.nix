# Home Manager configuration for christopherharris (work macOS)
{ config, lib, pkgs, ... }:
{
  imports = [
    ./modules/shell.nix
    ./modules/editor.nix
    ./modules/terminal.nix
    ./modules/git.nix
    ./modules/npm-cli.nix
  ];

  home.username = "christopherharris";
  home.homeDirectory = "/Users/christopherharris";
  home.stateVersion = "26.05";

  cchharris.home = {
    shell.enable = true;
    editor.enable = true;
    terminal.enable = true;
    git = {
      enable = true;
      # Teleport tsh / corp device-trust tooling writes Host blocks straight
      # into ~/.ssh/config; home-manager can't own that file here too.
      manageSshConfig = false;
    };
    npmCli = {
      enable = true;
      packages = {
        # ACP server for agentic.nvim. Bump version to upgrade on next `hm`.
        "@agentclientprotocol/claude-agent-acp" = "0.33.1";
      };
    };
  };

  # Override Linux-specific aliases from shell.nix
  programs.zsh.shellAliases = {
    update = lib.mkForce "home-manager switch --flake ~/dotfiles#work-mac";
    hm = lib.mkForce "home-manager switch --flake ~/dotfiles#work-mac";
  };

  # home-manager now manages ~/.zprofile on Darwin; preserve the Homebrew
  # shellenv line that lived there before (this is a standalone home-manager
  # setup, not nix-darwin, so there's no /etc/zprofile to do this instead).
  programs.zsh.profileExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  programs.home-manager.enable = true;
}
