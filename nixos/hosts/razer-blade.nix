# Razer Blade host configuration
{ config, lib, pkgs, ... }:

{
  # Hostname
  networking.hostName = "razer-blade";

  # Enable all features for this machine
  cchharris.nixos = {
    nvidia.enable = true;
    gaming.enable = true;
    desktop.enable = true;
    razer.enable = true;
  };

  # ExpressVPN (host-specific service)
  services.expressvpn.enable = true;
  environment.systemPackages = with pkgs; [
    expressvpn
  ];

  # System state version
  system.stateVersion = "25.11";
}
