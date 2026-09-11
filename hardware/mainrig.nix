# Hardware configuration for mainrig
#
# TEMPLATE — this is not machine-generated yet. Real UUIDs get filled in after
# installation (run `nixos-generate-config` or read them off `blkid`/`lsblk -f`
# post-partition) and replace the REPLACE-ME placeholders below. See the
# migration plan for the partition layout this maps to:
#   - Disk 0 (Force MP510, 1.79TB):    shared ESP + Windows (400G) + LUKS "root"
#   - Disk 1 (Samsung 990 Pro, 3.73TB): LUKS "games-primary"
#   - Disk 2 (FireCuda 510, 1.86TB):    LUKS "games-secondary"
#
# Disk 1 and 2 are wiped and reformatted native (not kept as NTFS) — the ~3.85TB
# of existing Steam installs on them gets redownloaded post-install in exchange
# for all three volumes being LUKS2+TPM2 encrypted and btrfs throughout.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.systemd.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.initrd.luks.devices = {
    root = { device = "/dev/disk/by-uuid/REPLACE-ME-ROOT-LUKS-UUID"; crypttabExtraOpts = [ "tpm2-device=auto" ]; };
    games-primary = { device = "/dev/disk/by-uuid/REPLACE-ME-GAMES-PRIMARY-LUKS-UUID"; crypttabExtraOpts = [ "tpm2-device=auto" ]; };
    games-secondary = { device = "/dev/disk/by-uuid/REPLACE-ME-GAMES-SECONDARY-LUKS-UUID"; crypttabExtraOpts = [ "tpm2-device=auto" ]; };
  };
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [ "subvol=/@" "compress=zstd" "noatime" "ssd" "space_cache=v2" ];
    };

  fileSystems."/nix" =
    { device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [ "subvol=/@nix" "compress=zstd" "noatime" "ssd" "space_cache=v2" ];
    };

  fileSystems."/home" =
    { device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [ "subvol=/@home" "compress=zstd" "noatime" "ssd" "space_cache=v2" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [ "subvol=/@log" "compress=zstd" "noatime" "ssd" "space_cache=v2" ];
      neededForBoot = true;
    };

  fileSystems."/tmp" =
    { device = "/dev/mapper/root";
      fsType = "btrfs";
      options = [ "subvol=/@tmp" "compress=zstd" "noatime" "ssd" "space_cache=v2" ];
    };

  # Shared ESP — Windows Boot Manager and systemd-boot both live here.
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/REPLACE-ME-ESP-UUID";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  fileSystems."/mnt/games-primary" =
    { device = "/dev/mapper/games-primary";
      fsType = "btrfs";
      options = [ "compress=zstd" "noatime" "ssd" "space_cache=v2" ];
    };

  fileSystems."/mnt/games-secondary" =
    { device = "/dev/mapper/games-secondary";
      fsType = "btrfs";
      options = [ "compress=zstd" "noatime" "ssd" "space_cache=v2" ];
    };

  # No disk swap partition — zramSwap (nixos/hosts/mainrig.nix) covers it given 64GB RAM.

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
