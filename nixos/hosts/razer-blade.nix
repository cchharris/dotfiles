# Razer Blade host configuration
{ config, lib, pkgs, ... }:

{
  # Hostname
  networking.hostName = "razer-blade";

  # Enable all features for this machine
  cchharris.nixos = {
    nvidia = {
      enable = true;
      openDrivers = true;  # Open drivers for newer GPU
      optimus.enable = true;  # Dual GPU laptop
    };
    gaming.enable = true;
    gnome.enable = true;
    razer.enable = true;
    tailscale.enable = true;
  };

  # CPU frequency scaling for better battery life
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "auto";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # ExpressVPN (host-specific service)
  services.expressvpn.enable = true;
  environment.systemPackages = with pkgs; [
    expressvpn
  ];

  # System state version
  system.stateVersion = "25.11";
}
