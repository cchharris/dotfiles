# Common desktop environment features (audio, printing, applications)
# Shared between GNOME and Hyprland configurations
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.desktop-common;
in {
  options.cchharris.nixos.desktop-common = {
    enable = lib.mkEnableOption "common desktop environment features";
  };

  config = lib.mkIf cfg.enable {
    # Audio with PipeWire (shared by both GNOME and Hyprland)
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Printing (shared by both)
    services.printing.enable = true;

    # Common desktop applications
    programs.firefox.enable = true;

    # Force Microsoft Edge to use dark theme via managed policy
    environment.etc."opt/edge/policies/managed/dark-theme.json".text = builtins.toJSON {
      ForceDarkModeEnabled = true;
    };

    # Bluetooth manager (used by hyprpanel bluetooth widget)
    services.blueman.enable = true;

    # Common desktop packages
    environment.systemPackages = with pkgs; [
      microsoft-edge
      discord
    ];
  };
}
