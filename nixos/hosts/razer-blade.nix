# Razer Blade host configuration
{ config, lib, pkgs, ... }:

{
  # Hostname
  networking.hostName = "razer-blade";

  # Force i915 native backlight (intel_backlight) instead of nvidia_wmi_ec_backlight.
  # Without this, only the non-functional NVIDIA WMI device appears on Optimus.
  boot.kernelParams = [ "video.use_native_backlight=1" ];

  # Enable all features for this machine
  cchharris.nixos = {
    nvidia = {
      enable = true;
      openDrivers = true;  # Open drivers for newer GPU
      optimus.enable = true;  # Dual GPU laptop
    };
    gaming.enable = true;
    hyprland.enable = true;
    razer.enable = true;
    tailscale.enable = true;
    howdy.enable = true;
  };

  # Bluetooth
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
  systemd.tmpfiles.rules = [
    "r  /opt/expressvpn - - - - -"
    "d  /opt/expressvpn          0755 root root -"
    "L+ /opt/expressvpn/bin      - - - - ${pkgs.expressvpn}/bin"
    "L+ /opt/expressvpn/lib      - - - - ${pkgs.expressvpn}/lib"
    "L+ /opt/expressvpn/plugins  - - - - ${pkgs.expressvpn}/plugins"
    "L+ /opt/expressvpn/qml      - - - - ${pkgs.expressvpn}/qml"
    "L+ /opt/expressvpn/share    - - - - ${pkgs.expressvpn}/share"
    "d  /opt/expressvpn/etc      0755 root root -"
  ];
  users.groups.expressvpn = {};
  users.groups.expressvpnhnsd = {};
  users.users.expressvpn = { isSystemUser = true; group = "expressvpn"; };
  systemd.services.expressvpn.path = with pkgs; [ iptables iproute2 wireguard-tools kmod openresolv coreutils gnugrep gawk ];
  systemd.services.expressvpn.serviceConfig = {
    # Ask the daemon to disconnect gracefully before sending SIGTERM, so it can
    # run its own iptables/routing teardown. 30s covers slow servers; SIGTERM/SIGKILL
    # fire after that if the daemon is stuck.
    ExecStop = "${pkgs.expressvpn}/bin/expressvpn disconnect";
    TimeoutStopSec = "30";
  };
  # Safety-net cleanup that always runs, even after SIGKILL: remove the
  # resolvconf entry the updown script adds so DNS is never left pointing at
  # a dead VPN server.
  systemd.services.expressvpn.postStop = ''
    ${pkgs.openresolv}/bin/resolvconf -d tun0.expressvpn 2>/dev/null || true
  '';
  environment.etc."opt/edge/native-messaging-hosts/com.expressvpn.helper.json".source =
    "${pkgs.expressvpn}/share/com.expressvpn.helper.json";
  environment.systemPackages = with pkgs; [
    bluez      # Bluetooth stack (bluetoothctl + utils; equivalent to bluez + bluez-utils on Arch)
    expressvpn
    iptables
    unityhub   # Unity Game Engine version manager
    dotnet-sdk # .NET SDK (required for OmniSharp/C# LSP)
    (pkgs.callPackage ../../pkgs/nvimunity.nix {})
  ];

  # System state version
  system.stateVersion = "25.11";
}
