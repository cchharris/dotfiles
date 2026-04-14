# Razer hardware support module
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.razer;
in {
  options.cchharris.nixos.razer = {
    enable = lib.mkEnableOption "Razer hardware support";
  };

  config = lib.mkIf cfg.enable {
    hardware.openrazer.enable = true;
    services.thermald.enable = true;
    services.iio-sensor-proxy.enable = true;

    environment.systemPackages = with pkgs; [
      openrazer-daemon
    ];

    # Add user to openrazer group
    users.users.cchharris.extraGroups = [ "openrazer" ];

    # Windows Hello-style facial recognition via IR camera
    # IR camera is on /dev/video2 (USB interface 02, separate from RGB on interface 00)
    cchharris.nixos.howdy = {
      enable = true;
      videoDevice = "/dev/video2";
      irEmitter = true;
    };
  };
}
