# Hardware configuration for nas
# Generated with `nixos-generate-config` on the actual box (WD SN740 256GB
# NVMe boot drive: 1GiB vfat ESP + ext4 root). Data disks are NOT listed
# here — the ZFS pool is imported by zfs.nix, not fileSystems.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Root filesystem stays on its own small, unencrypted boot SSD/NVMe —
  # deliberately NOT the ZFS data pool, so the OS always boots and comes up
  # on the network without needing the data pool's passphrase (see zfs.nix).
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/e71679c2-a40e-4f75-b410-d23901aff9be";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B7DA-7576";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
