# Desktop environment module (GNOME, audio, printing)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.desktop;
in {
  options.cchharris.nixos.desktop = {
    enable = lib.mkEnableOption "desktop environment (GNOME)";
  };

  config = lib.mkIf cfg.enable {
    # X11 and GNOME
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Keyboard layout
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Touchpad support
    services.libinput.enable = true;

    # Printing
    services.printing.enable = true;

    # Audio with PipeWire
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Desktop applications
    programs.firefox.enable = true;

    environment.systemPackages = with pkgs; [
      microsoft-edge
      discord
      ghostty
    ];
  };
}
