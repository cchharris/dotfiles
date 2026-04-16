# LUKS + Secure Boot Setup Plan

Plan for adding full-disk encryption (LUKS) with TPM2 auto-unlock and Secure Boot (lanzaboote) to razer-blade. Requires a full reinstall — cannot be applied to an existing unencrypted system.

**Phase 1 is complete** — lanzaboote is wired into the flake and `secureboot.nix` exists (disabled).

---

## Current disk layout (pre-reinstall)

```
nvme0n1 (953.9G — main drive)
├── nvme0n1p1   1G      vfat   /boot       UUID: 5924-6CF2
├── nvme0n1p2   918.7G  ext4   /           UUID: 41074c9f-8bb3-46a2-8082-b2d5ded6b501
└── nvme0n1p3   34.2G   swap               UUID: 203b84fd-bde2-4e14-95c4-08691e019647

nvme1n1 (1.8T — data drive)
└── nvme1n1p1   1.8T    ext4   /mnt/data   UUID: c554397a-9e86-4f9a-8f14-ca6760e5887b
```

---

## Files to Create/Modify

| File | Action |
|------|--------|
| `nixos/modules/secureboot.nix` | ✅ Done — module exists, disabled by default |
| `flake.nix` | ✅ Done — lanzaboote input added |
| `nixos/hosts/razer-blade.nix` | Add `secureboot.enable = true` (Phase 3) |
| `hardware/razer-blade.nix` | Update UUIDs + add LUKS devices (Phase 2, after reinstall) |

---

## Phase 1: Add the Module to Dotfiles ✅ Complete

lanzaboote v0.4.1 is in `flake.nix` and `nixos/modules/secureboot.nix` is wired into the razer-blade config (disabled). Nothing to do here.

---

## Phase 2: Reinstall with LUKS

> **Back up `/mnt/data` (nvme1n1, 1.8T) before starting — it will be wiped.**

### Target partition layout

```
nvme0n1 (953.9G — main drive)
├── nvme0n1p1   1G      vfat        /boot        (EFI, unencrypted — must be)
├── nvme0n1p2   918.7G  LUKS → ext4 /            (root)
└── nvme0n1p3   34.2G   LUKS → swap              (swap)

nvme1n1 (1.8T — data drive)
└── nvme1n1p1   1.8T    LUKS → ext4 /mnt/data    (data)
```

### Step 1: Boot NixOS ISO

Write ISO to USB from another machine, boot the Razer Blade from it.

### Step 2: Partition the drives

```sh
# Main drive — keep same sizes, change LUKS type codes
gdisk /dev/nvme0n1
# Delete all partitions (d), then create:
#   p1:  +1G       type EF00  (EFI System)
#   p2:  +918G     type 8309  (Linux LUKS — root)
#   p3:  remaining type 8309  (Linux LUKS — swap, ~34G)
# Write (w)

# Data drive
gdisk /dev/nvme1n1
# Delete all partitions (d), then create:
#   p1:  remaining type 8309  (Linux LUKS — data)
# Write (w)
```

### Step 3: Format + open LUKS volumes

Use the same strong passphrase for all three (simplifies recovery):

```sh
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 root

cryptsetup luksFormat /dev/nvme0n1p3
cryptsetup open /dev/nvme0n1p3 swap

cryptsetup luksFormat /dev/nvme1n1p1
cryptsetup open /dev/nvme1n1p1 data
```

### Step 4: Format filesystems

```sh
mkfs.fat -F32 -n BOOT /dev/nvme0n1p1
mkfs.ext4 -L root /dev/mapper/root
mkswap -L swap /dev/mapper/swap
mkfs.ext4 -L data /dev/mapper/data
```

### Step 5: Mount everything

```sh
mount /dev/mapper/root /mnt
mkdir -p /mnt/boot /mnt/mnt/data
mount /dev/nvme0n1p1 /mnt/boot
mount /dev/mapper/data /mnt/mnt/data
swapon /dev/mapper/swap
```

### Step 6: Install from dotfiles

```sh
nixos-install --flake github:cchharris/dotfiles#razer-blade
```

### Step 7: Record new UUIDs before rebooting

```sh
blkid /dev/nvme0n1p1   # EFI — use in fileSystems."/boot"
blkid /dev/nvme0n1p2   # LUKS container — use in luks.devices.root
blkid /dev/nvme0n1p3   # LUKS container — use in luks.devices.swap
blkid /dev/nvme1n1p1   # LUKS container — use in luks.devices.data
```

Write these down, then update `hardware/razer-blade.nix`:

```nix
boot.initrd.luks.devices = {
  root = { device = "/dev/disk/by-uuid/<nvme0n1p2-uuid>"; };
  swap = { device = "/dev/disk/by-uuid/<nvme0n1p3-uuid>"; };
  data = { device = "/dev/disk/by-uuid/<nvme1n1p1-uuid>"; };
};

fileSystems."/" = { device = "/dev/mapper/root"; fsType = "ext4"; };
fileSystems."/boot" = {
  device = "/dev/disk/by-uuid/<nvme0n1p1-uuid>";
  fsType = "vfat";
  options = [ "fmask=0077" "dmask=0077" ];
};
fileSystems."/mnt/data" = { device = "/dev/mapper/data"; fsType = "ext4"; };
swapDevices = [{ device = "/dev/mapper/swap"; }];
```

Push to GitHub, reboot into the new system, then run `update` to apply.

---

## Phase 3: Enable Secure Boot + TPM2 (after reinstall)

### Enable the module

In `nixos/hosts/razer-blade.nix`:

```nix
cchharris.nixos.secureboot.enable = true;
```

Run `update` to switch to lanzaboote.

### Enroll Secure Boot keys (one-time)

```sh
# First: enter UEFI → Security → clear platform keys / enter Setup Mode
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft   # --microsoft preserves UEFI firmware trust
sudo nixos-rebuild switch --flake ~/dotfiles#razer-blade
sudo sbctl verify   # all files should show ✓
# Then: enable Secure Boot in UEFI and reboot
```

### Bind LUKS volumes to TPM2 (one-time)

```sh
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p3
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme1n1p1
```

Then add `crypttabExtraOpts` to `hardware/razer-blade.nix`:

```nix
boot.initrd.luks.devices = {
  root = {
    device = "/dev/disk/by-uuid/<nvme0n1p2-uuid>";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
  swap = {
    device = "/dev/disk/by-uuid/<nvme0n1p3-uuid>";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
  data = {
    device = "/dev/disk/by-uuid/<nvme1n1p1-uuid>";
    crypttabExtraOpts = [ "tpm2-device=auto" ];
  };
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

## Verification checklist

1. `sbctl status` → Secure Boot enabled, keys enrolled
2. `sbctl verify` → all boot files signed ✓
3. `cryptsetup luksDump /dev/nvme0n1p2` → shows `systemd-tpm2` token
4. Cold reboot → boots without passphrase prompt
5. Test passphrase fallback: `sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2`, reboot, enter passphrase, re-enroll
