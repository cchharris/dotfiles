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
    howdy.enable = true;
  };

  # TLP for laptop power management — replaces GNOME's power-profiles-daemon
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      # CPU scaling
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Battery charge thresholds — preserve long-term battery health
      # Charges when below 75%, stops at 80% (like macOS optimized charging)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;

      # NVMe power saving on battery
      DISK_DEVICES = "nvme0n1 nvme1n1";
      DISK_APM_LEVEL_ON_AC = "254 254";
      DISK_APM_LEVEL_ON_BAT = "128 128";

      # PCIe active state power management
      PCIE_ASPM_ON_BAT = "powersupersave";

      # USB autosuspend (skip audio devices to avoid glitches)
      USB_AUTOSUSPEND = 1;
      USB_EXCLUDE_AUDIO = 1;
    };
  };

  # ExpressVPN (host-specific service)
  services.expressvpn.enable = true;
  environment.systemPackages = with pkgs; [
    expressvpn
    unityhub   # Unity Game Engine version manager
    dotnet-sdk # .NET SDK (required for OmniSharp/C# LSP)
    (pkgs.callPackage ../../pkgs/nvimunity.nix {})
  ];

  # System state version
  system.stateVersion = "25.11";
}
