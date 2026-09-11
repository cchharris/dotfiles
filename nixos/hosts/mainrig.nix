# mainrig host configuration — main dev + gaming desktop (AMD Ryzen 9 9950X, RTX 5080)
{ config, lib, pkgs, ... }:

{
  # Hostname
  networking.hostName = "mainrig";

  # Enable features for this machine
  cchharris.nixos = {
    nvidia = {
      enable = true;
      openDrivers = true;  # required for RTX 50-series (Blackwell) — closed driver doesn't support it
      optimus.enable = false;  # single GPU desktop
    };
    gaming.enable = true;
    hyprland.enable = true;
    tailscale.enable = true;
  };

  # zram swap instead of a disk swap partition — comfortable given 64GB RAM
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # Bluetooth configuration
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  # System state version
  system.stateVersion = "26.05";
}
