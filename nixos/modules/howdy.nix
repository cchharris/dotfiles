# Facial recognition module (howdy / Windows Hello equivalent)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.howdy;
in {
  options.cchharris.nixos.howdy = {
    enable = lib.mkEnableOption "howdy facial recognition";

    videoDevice = lib.mkOption {
      type = lib.types.str;
      default = "/dev/video2";
      description = "V4L2 device path for the IR camera.";
    };

    control = lib.mkOption {
      type = lib.types.enum [ "required" "sufficient" "optional" ];
      default = "sufficient";
      description = ''
        PAM control flag. "sufficient" means face alone unlocks (no password);
        "required" adds face as a second factor on top of password.
      '';
    };

    certainty = lib.mkOption {
      type = lib.types.float;
      default = 3.5;
      description = "Recognition certainty threshold (lower = stricter).";
    };

    pamServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "gdm-password" "sudo" "login" ];
      description = "PAM services to enable howdy for.";
    };

    irEmitter = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable linux-enable-ir-emitter to activate the IR emitter on boot.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.howdy = {
      enable = true;
      control = cfg.control;
      settings = {
        core = {
          abort_if_ssh = true;
          abort_if_lid_closed = false;
        };
        video = {
          device_path = cfg.videoDevice;
          certainty = cfg.certainty;
          timeout = 4;
        };
      };
    };

    security.pam.services = lib.genAttrs cfg.pamServices (_: {
      howdy.enable = true;
    });

    services.linux-enable-ir-emitter.enable = cfg.irEmitter;
  };
}
