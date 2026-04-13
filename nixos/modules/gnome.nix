# GNOME desktop environment module
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.gnome;
in {
  options.cchharris.nixos.gnome = {
    enable = lib.mkEnableOption "GNOME desktop environment";
  };

  config = lib.mkIf cfg.enable {
    # Enable common desktop features
    cchharris.nixos.desktop-common.enable = true;

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

    # GNOME-specific packages
    environment.systemPackages = with pkgs; [
      ghostty
    ];
  };
}
