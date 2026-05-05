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

    environment.systemPackages = with pkgs; [
      openrazer-daemon
      polychromatic   # GUI for RGB lighting, battery conservation, DPI
      iio-sensor-proxy  # ambient light sensor — lets GNOME auto-adjust brightness
    ];

    # Include iio-sensor-proxy systemd service units
    systemd.packages = [ pkgs.iio-sensor-proxy ];

    # Add user to openrazer group
    users.users.cchharris.extraGroups = [ "openrazer" ];

    # openrazer's udev rules set GROUP="openrazer" on Razer USB devices but don't
    # add TAG+="uaccess", which logind requires to hand the device fd to a Wayland
    # compositor (Hyprland uses libseat → logind TakeDevice). Without it the kernel
    # detects the device but Hyprland can't open the event node on first plug-in.
    services.udev.extraRules = ''
      SUBSYSTEM=="input", ATTRS{idVendor}=="1532", TAG+="uaccess", TAG+="seat"
    '';

    # Windows Hello-style facial recognition via IR camera
    # IR camera is on /dev/video2 (USB interface 02, separate from RGB on interface 00)
    cchharris.nixos.howdy = {
      enable = true;
      videoDevice = "/dev/video2";
      irEmitter = true;
    };
  };
}
