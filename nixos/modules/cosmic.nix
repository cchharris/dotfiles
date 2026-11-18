# COSMIC desktop environment module (System76, Rust)
# Adds a COSMIC session alongside Hyprland and makes it the SDDM default.
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.cosmic;
in {
  options.cchharris.nixos.cosmic = {
    enable = lib.mkEnableOption "COSMIC desktop environment";
  };

  config = lib.mkIf cfg.enable {
    # Enable common desktop features
    cchharris.nixos.desktop-common.enable = true;

    # Registers the cosmic-session with whichever display manager is running.
    # cosmic-greeter is not enabled: SDDM (from hyprland.nix) stays the greeter.
    services.desktopManager.cosmic.enable = true;

    # Preselect COSMIC at the SDDM login screen (Hyprland stays in the list)
    services.displayManager.defaultSession = lib.mkDefault "cosmic";

    # COSMIC turns on system76-power when power-profiles-daemon and tuned are
    # off, which would fight TLP over CPU governors and dGPU runtime PM
    hardware.system76.power-daemon.enable = lib.mkIf config.services.tlp.enable false;

    # Overlaps ananicy-cpp + scx_lavd from cachyos.nix (all three renice processes)
    services.system76-scheduler.enable = lib.mkIf config.cchharris.nixos.cachyos.enable false;
  };
}
