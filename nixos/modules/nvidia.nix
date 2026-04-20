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

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Override the NVIDIA driver package (e.g. for legacy GPUs). Null uses the default.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.videoDrivers = [ "nvidia" ];

    # Load nvidia modules early so the DRM device is available before the
    # display manager starts. Required for Wayland/Hyprland with NVIDIA.
    boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

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
    } // lib.optionalAttrs (cfg.package != null) { package = cfg.package; };

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver  # VA-API on NVIDIA (hardware decode on Wayland)
        libvdpau-va-gl       # VDPAU through OpenGL
        libva-vdpau-driver   # VA-API through VDPAU
      ] ++ lib.optionals cfg.optimus.enable [
        intel-media-driver   # Intel iGPU VA-API (iHD, Broadwell+) for Optimus display path
      ];
      extraPackages32 = with pkgs; [
        nvidia-vaapi-driver
      ];
    };
  };
}
