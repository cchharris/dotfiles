# The actual linux-cachyos kernel: EEVDF+BORE scheduler, via chaotic-nyx's binary
# cache. https://github.com/chaotic-cx/nyx
#
# This is the piece [[cachyos.nix]]'s userspace tweaks can't reach — BORE is a
# scheduling-heuristic patch to the kernel itself, not something sched-ext or a
# sysctl can replicate. Requires inputs.chaotic (flake.nix) and
# inputs.chaotic.nixosModules.default (razer-blade's module list) for the
# linuxPackages_cachyos-gcc/nvidia_cachyos-gcc attributes and binary cache to exist.
#
# Using the `-gcc` variant, not the default (Clang+ThinLTO) one: the Clang/LTO
# toolchain path has a recurring class of bug where chaotic-nyx's cache falls out
# of sync and dependents rebuild from source against a Clang version gnulib
# doesn't support, breaking things — openrazer included (see
# https://github.com/chaotic-cx/nyx/issues/1178, confirmed by reproducing a build
# failure in `grep`'s gnulib-tests on 2026-08-16). The GCC variant sidesteps that
# whole path at the cost of the LTO gains; BORE itself is unaffected either way.
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.cachyosKernel;
in {
  options.cchharris.nixos.cachyosKernel = {
    enable = lib.mkEnableOption "linux-cachyos kernel (BORE scheduler) via chaotic-nyx";
  };

  config = lib.mkIf cfg.enable {
    boot.kernelPackages = pkgs.linuxPackages_cachyos-gcc.extend (_: lpPrev: {
      # Same fix as the default-kernel openrazer override in flake.nix: openrazer
      # 3.12.2 calls hid_report_raw_event() with 5 args but kernels >=6.18.33 need
      # 6. linuxPackages_cachyos-gcc is a separate package set from the default
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
    cchharris.nixos.nvidia.package = lib.mkDefault pkgs.nvidia_cachyos-gcc;
  };
}
