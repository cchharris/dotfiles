# XRDP remote desktop module
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.xrdp;
in {
  options.cchharris.nixos.xrdp = {
    enable = lib.mkEnableOption "XRDP remote desktop protocol";

    defaultWindowManager = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.gnome-session}/bin/gnome-session";
      description = "Default window manager for XRDP sessions";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xrdp = {
      enable = true;
      defaultWindowManager = cfg.defaultWindowManager;
      openFirewall = true;  # Default RDP port (3389)
    };

    # XRDP needs GNOME remote desktop backend
    services.gnome.gnome-remote-desktop.enable = true;

    # Disable auto-login (security for remote access)
    services.displayManager.autoLogin.enable = false;
    services.getty.autologinUser = null;
  };
}
