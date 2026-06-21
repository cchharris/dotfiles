# macOS system defaults (nix-darwin)
{ config, lib, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.optimise.automatic = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim wget ripgrep git
  ];

  system.defaults = {
    dock.autohide = true;
    dock.show-recents = false;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "Nlsv";
    finder.ShowPathbar = true;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.InitialKeyRepeat = 15;
  };

  # Trust homelab local CA so .home services work with HTTPS
  security.pki.certificates = [
    (builtins.readFile ../../nixos/certs/homelab-ca.crt)
  ];

  # Placeholder — rename to match actual Mac hostname (run: scutil --get LocalHostName)
  networking.hostName = "mac";

  system.stateVersion = 6;
}
