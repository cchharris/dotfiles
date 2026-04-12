# NVIDIA/Optimus configuration module
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.nvidia;
in {
  options.cchharris.nixos.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU support with Intel Optimus";

    nvidiaBusId = lib.mkOption {
      type = lib.types.str;
      default = "PCI:1:0:0";
      description = "PCI bus ID for NVIDIA GPU";
    };

    intelBusId = lib.mkOption {
      type = lib.types.str;
      default = "PCI:0:2:0";
      description = "PCI bus ID for Intel GPU";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      powerManagement.enable = true;
      open = true;
      nvidiaSettings = true;
      prime = {
        sync.enable = true;
        nvidiaBusId = cfg.nvidiaBusId;
        intelBusId = cfg.intelBusId;
      };
    };

    hardware.graphics.enable = true;
  };
}
