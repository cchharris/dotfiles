# Hyprland window manager module
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.hyprland;
in {
  options.cchharris.nixos.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager";
  };

  config = lib.mkIf cfg.enable {
    # Enable common desktop features
    cchharris.nixos.desktop-common.enable = true;

    # Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    programs.hyprlock.enable = true;

    # Hint to electron apps to use wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # GDM for login manager (compatible with Hyprland)
    services.displayManager.gdm.enable = true;

    # X11 config for keyboard (still used by some apps)
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # PAM configuration for hyprlock
    security.pam.services.hyprlock = {};

    # Hyprland-specific packages
    environment.systemPackages = with pkgs; [
      kitty
      hyprlock
    ];
  };
}
