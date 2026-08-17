# The actual linux-cachyos kernel: EEVDF+BORE scheduler, LLVM/ThinLTO build,
# via chaotic-nyx's binary cache. https://github.com/chaotic-cx/nyx
#
# This is the piece [[cachyos.nix]]'s userspace tweaks can't reach — BORE is a
# scheduling-heuristic patch to the kernel itself, not something sched-ext or a
# sysctl can replicate. Requires inputs.chaotic (flake.nix) and
# inputs.chaotic.nixosModules.default (razer-blade's module list) for the
# linuxPackages_cachyos/nvidia_cachyos attributes and binary cache to exist.
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.cachyosKernel;
in {
  options.cchharris.nixos.cachyosKernel = {
    enable = lib.mkEnableOption "linux-cachyos kernel (BORE scheduler + LTO) via chaotic-nyx";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_cachyos.extend (_: lpPrev: {
      # Same fix as the default-kernel openrazer override in flake.nix: openrazer
      # 3.12.2 calls hid_report_raw_event() with 5 args but kernels >=6.18.33 need
      # 6. linuxPackages_cachyos is a separate package set from the default
      # kernel's, so the overlay in flake.nix doesn't reach it — reapplied here.
      openrazer = lpPrev.openrazer.overrideAttrs (_: {
        version = "3.12.3-unstable";
        src = pkgs.fetchFromGitHub {
          owner = "openrazer";
          repo = "openrazer";
          tag = "v3.12.3";
          hash = "sha256-X1NPqbugBdxD5Nt9wIwQADV4CuydGLpgKhlNazVdrIY=";
        };
      });
    });

    # CachyOS's own NVIDIA driver build, matched to this kernel's module ABI.
    cchharris.nixos.nvidia.package = lib.mkDefault pkgs.nvidia_cachyos;
  };
}
