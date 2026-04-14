# LUKS + Secure Boot Setup Plan

Plan for adding full-disk encryption (LUKS) with TPM2 auto-unlock and Secure Boot (lanzaboote) to razer-blade. Requires a full reinstall — cannot be applied to an existing unencrypted system.

---

## Files to Create/Modify

| File | Action |
|------|--------|
| `nixos/modules/secureboot.nix` | Create — new module (disabled by default) |
| `flake.nix` | Add lanzaboote input + pass it to razer-blade modules |
| `nixos/hosts/razer-blade.nix` | Add `secureboot.enable = true` (when ready) |
| `hardware/razer-blade.nix` | Update UUIDs + add LUKS devices (after reinstall) |

---

## Phase 1: Add the Module to Dotfiles (before reinstall)

### 1a. Add lanzaboote to flake.nix inputs

```nix
lanzaboote = {
  url = "github:nix-community/lanzaboote/v0.4.1";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Pass it into the razer-blade system modules:
```nix
specialArgs = { inherit inputs; };
modules = [
  inputs.lanzaboote.nixosModules.lanzaboote
  ./nixos/modules/secureboot.nix
  # ... existing modules
];
```

### 1b. Create nixos/modules/secureboot.nix

Follows the same `cchharris.nixos.<name>` pattern as other modules. Leave `enable = false` in razer-blade.nix until after reinstall.

```nix
# Secure Boot + LUKS full-disk encryption module
# Requires a fresh install — cannot be applied to an existing unencrypted system.
# Enable this after reinstalling with LUKS partitions and enrolling Secure Boot keys.
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.secureboot;
in {
  options.cchharris.nixos.secureboot = {
    enable = lib.mkEnableOption "Secure Boot via lanzaboote + LUKS full-disk encryption";

    pkiBundle = lib.mkOption {
      type = lib.types.str;
      default = "/etc/secureboot";
      description = "Path to the Secure Boot key bundle (sbctl keys).";
    };

    tpmPcrs = lib.mkOption {
      type = lib.types.str;
      default = "0+7";
      description = ''
        TPM2 PCR banks to seal the LUKS key against.
        0 = firmware, 7 = Secure Boot state.
        Add PCR 4 to also bind to the bootloader binary.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Replace systemd-boot with lanzaboote
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = cfg.pkiBundle;
    };

    # sbctl for key management
    environment.systemPackages = [ pkgs.sbctl ];
  };
}
```

---

## Phase 2: Reinstall with LUKS

### Partition layout

```
nvme0n1 (main drive)
├── nvme0n1p1   512MB   vfat        /boot        (EFI, unencrypted — must be)
├── nvme0n1p2   XGB     LUKS → ext4 /            (root)
└── nvme0n1p3   YGB     LUKS → swap              (swap)

nvme1n1 (data drive)
└── nvme1n1p1   full    LUKS → ext4 /mnt/data    (data)
```

### Reinstall steps

```sh
# Boot NixOS ISO

# Format + open LUKS volumes
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 root
cryptsetup luksFormat /dev/nvme0n1p3
cryptsetup open /dev/nvme0n1p3 swap
cryptsetup luksFormat /dev/nvme1n1p1
cryptsetup open /dev/nvme1n1p1 data

# Format filesystems
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/mapper/root
mkswap /dev/mapper/swap
mkfs.ext4 /dev/mapper/data

# Mount
mount /dev/mapper/root /mnt
mkdir -p /mnt/boot /mnt/mnt/data
mount /dev/nvme0n1p1 /mnt/boot
mount /dev/mapper/data /mnt/mnt/data
swapon /dev/mapper/swap

# Install from dotfiles
nixos-install --flake github:cchharris/dotfiles#razer-blade
```

### Update hardware/razer-blade.nix after reinstall

Replace fileSystems/swapDevices with new UUIDs and LUKS mappings:

```nix
boot.initrd.luks.devices = {
  root = { device = "/dev/disk/by-uuid/<new-root-luks-uuid>"; };
  swap = { device = "/dev/disk/by-uuid/<new-swap-luks-uuid>"; };
  data = { device = "/dev/disk/by-uuid/<new-data-luks-uuid>"; };
};

fileSystems."/" = { device = "/dev/mapper/root"; fsType = "ext4"; };
fileSystems."/boot" = {
  device = "/dev/disk/by-uuid/<efi-uuid>";
  fsType = "vfat";
  options = [ "fmask=0077" "dmask=0077" ];
};
fileSystems."/mnt/data" = { device = "/dev/mapper/data"; fsType = "ext4"; };
swapDevices = [{ device = "/dev/mapper/swap"; }];
```

---

## Phase 3: Enable Secure Boot + TPM2 (after reinstall)

### Enable the module
```nix
# nixos/hosts/razer-blade.nix
cchharris.nixos.secureboot.enable = true;
```

### Enroll Secure Boot keys (one-time)

```sh
# First: enter UEFI Setup Mode in BIOS (clear platform keys)
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft   # --microsoft preserves UEFI firmware trust
sudo nixos-rebuild switch --flake ~/dotfiles#razer-blade
sudo sbctl verify   # all files should show ✓
# Then: enable Secure Boot in BIOS and reboot
```

### Bind LUKS volumes to TPM2 (one-time)

```sh
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p3
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme1n1p1
```

Add to hardware/razer-blade.nix:
```nix
boot.initrd.luks.devices = {
  root = {
    device = "/dev/disk/by-uuid/<uuid>";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
  # same for swap and data
};
```

---

## Hardware Change Reference

| Event | Impact | Recovery |
|-------|--------|----------|
| RAM / GPU swap | None | — |
| BIOS/firmware update | TPM auto-unlock may break | Enter passphrase, re-enroll TPM |
| Motherboard replacement | TPM broken entirely | Enter passphrase, re-enroll TPM on new board |
| Replacing root SSD | System gone | Full reinstall |

**Always keep a passphrase fallback on every LUKS volume** — it's the recovery path when TPM auto-unlock breaks.

---

## Verification
1. `sbctl status` → Secure Boot enabled, keys enrolled
2. `sbctl verify` → all boot files signed ✓
3. `cryptsetup luksDump /dev/nvme0n1p2` → shows `systemd-tpm2` token
4. Cold reboot → boots without passphrase prompt
5. Test passphrase fallback: temporarily remove TPM token, reboot, enter passphrase
