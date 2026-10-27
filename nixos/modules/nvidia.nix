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
      # Lets the dGPU power down (RTD3) when nothing is using it — only valid
      # with PRIME offload.
      powerManagement.finegrained = cfg.optimus.enable;
      open = cfg.openDrivers;
      nvidiaSettings = true;
      modesetting.enable = true;

      # Only enable Optimus if configured. Offload, not sync: sync is an X11
      # concept and Hyprland ignores it (it renders on the Intel iGPU that
      # drives the panel regardless), so sync only kept the dGPU awake while
      # apps defaulted to NVIDIA — every client buffer then crossed GPUs and
      # failed dmabuf import (EGL_BAD_MATCH), which once crashed Hyprland.
      # Apps that should use NVIDIA opt in via `nvidia-offload` / the offload
      # env vars (Steam does this in gaming.nix).
      prime = lib.mkIf cfg.optimus.enable {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        nvidiaBusId = cfg.optimus.nvidiaBusId;
        intelBusId = cfg.optimus.intelBusId;
      };
    } // lib.optionalAttrs (cfg.package != null) { package = cfg.package; };

    # finegrained's upstream udev rules set power/control=auto on ACTION=="bind",
    # but nvidia binds in the initrd (above), before stage-2 udev has those
    # rules — so they never fire and the dGPU stays "on" (never suspends).
    # Stage-2 coldplug replays "add" events, so match on that instead. Covers
    # the GPU's VGA, 3D, HDMI audio, and USB-C (xHCI/UCSI) functions.
    services.udev.extraRules = lib.mkIf cfg.optimus.enable ''
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", TEST=="power/control", ATTR{power/control}="auto"
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", TEST=="power/control", ATTR{power/control}="auto"
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", TEST=="power/control", ATTR{power/control}="auto"
    '';

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
