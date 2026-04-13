# NVIDIA GPU configuration module
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.nvidia;
in {
  options.cchharris.nixos.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU support";

    # Optimus configuration for laptops with dual GPU
    optimus = {
      enable = lib.mkEnableOption "Intel Optimus support (dual GPU)";

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

    # Use open-source drivers (recommended for newer cards)
    openDrivers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use open-source NVIDIA drivers (for RTX 20+ series)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = cfg.openDrivers;
      nvidiaSettings = true;
      modesetting.enable = true;

      # Only enable Optimus if configured
      prime = lib.mkIf cfg.optimus.enable {
        sync.enable = true;
        nvidiaBusId = cfg.optimus.nvidiaBusId;
        intelBusId = cfg.optimus.intelBusId;
      };
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
