# NAS host configuration
#
# Platform: ASRock Rack X570D4U-2L2T + Ryzen 5 5600G + 32GB DDR4 non-ECC.
# Drives: 2x4TB + 2x2TB (mirrors, striped into "tank") + 1x8TB (standalone
# backup pool for zfs send/snapshot targets) + 1x1TB spare, no free port.
# Boot: owned 512GB SATA SSD, plain ext4, off the ZFS pool entirely.
#
# TEMPLATE — finish this after the physical install:
#   1. First boot: verify the board POSTs with the 5600G. BIOS v1.70 (the
#      only version ASRock Rack lists) already added 5800X3D support, which
#      postdates the 5600G's Cezanne silicon, so it should already be on the
#      box — but if it doesn't POST, the IPMI/BMC web UI (its own 1GbE port,
#      independent of the host CPU) can very likely flash BIOS without
#      needing a working CPU already in the socket first.
#   2. Run `nixos-generate-config` on the actual box and replace
#      ../../hardware/nas.nix with its output (real disk UUIDs can't be
#      guessed remotely).
#   3. Create the pools (fill in real /dev/disk/by-id paths once drives are
#      connected — run `ls -la /dev/disk/by-id/` to get them):
#        zpool create -o ashift=12 tank \
#          mirror /dev/disk/by-id/<4tb-1> /dev/disk/by-id/<4tb-2> \
#          mirror /dev/disk/by-id/<2tb-1> /dev/disk/by-id/<2tb-2>
#        zfs create -o encryption=aes-256-gcm -o keyformat=passphrase \
#          -o keylocation=prompt -o mountpoint=/tank/k8s tank/k8s
#        zfs create -o mountpoint=/tank/media tank/media
#        zfs create -o encryption=aes-256-gcm -o keyformat=passphrase \
#          -o keylocation=prompt -o canmount=noauto -o mountpoint=/tank/vault \
#          tank/vault
#        zpool create -o ashift=12 backup /dev/disk/by-id/<8tb>
#      (one dataset per client concern is easier to manage than one giant
#      dataset; the 8TB backup pool is the zfs send/snapshot target for tank)
#      For tank/vault's passphrase: use a long, high-entropy one (a random
#      25+ character password-manager string, or several random Diceware
#      words) — see nixos/modules/zfs-vault.nix for why this matters (ZFS's
#      PBKDF2 key derivation is weaker than VeraCrypt's Argon2id, so the
#      passphrase itself has to carry the margin). canmount=noauto keeps it
#      locked at boot; `vault unlock`/`vault lock` manage it after that.
#   4. Fill in nfs.exports / samba.shares below to match.
#   5. In BIOS/UEFI: set "Restore on AC Power Loss" -> Power On. NixOS can't
#      configure this — it's firmware.
{ config, lib, pkgs, ... }:

{
  networking.hostName = "nas";

  # Randomly generated ahead of install — doesn't need to match
  # /etc/machine-id, just needs to be unique across the fleet.
  networking.hostId = "6ad40947";

  cchharris.nixos = {
    zfs.enable = true;
    smartd.enable = true;
    tailscale.enable = true;  # own tailnet identity — reachable without depending on the k8s cluster's Tailscale operator
    fail2ban.enable = true;

    nfs = {
      enable = true;
      exports = ''
        /tank/k8s 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
        /tank/vault 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
      '';
    };

    samba = {
      enable = true;
      shares = {
        media = {
          path = "/tank/media";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "valid users" = "cchharris";
        };
        vault = {
          path = "/tank/vault";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "valid users" = "cchharris";
        };
      };
    };

    zfsVault = {
      enable = true;
      webService.enable = true;
    };
  };

  # Force-reboot if the kernel hangs (no monitor/keyboard on this box to
  # notice otherwise). Combined with the BIOS "restore on AC power loss"
  # setting, covers both "OS wedged" and "power cycled" self-healing —
  # neither depends on the ZFS data pool being unlocked.
  systemd.settings.Manager = {
    RuntimeWatchdogSec = "30s";
    RebootWatchdogSec = "5min";
  };

  # Enhanced SSH security (mirrors hobbynix — this box is a remote-access target)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      AllowUsers = [ "cchharris" ];
    };
  };

  # No home-manager on this host to deploy a key the way razer-blade/hobbynix
  # do, and cchharris has no password here either — without these, there is
  # no way to log in at all. One dedicated key per client machine (not the
  # itszuvalex@gmail.com GitHub key) so either box can be revoked on its own
  # if it's ever lost or compromised, without affecting the other. Both
  # generated directly inside 1Password ("SSH - razer-blade" / "SSH -
  # hobbynix", Personal vault) — private key material never touched disk.
  users.users.cchharris.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAOfqp7e+ZAPS7GjuLF7el6JMYIHLD3eLYz+HYG+PQaF" # razer-blade
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBf0rftj3rBkAvJSi9KYpb2k2VViVhE5D1e/XtD/BhS6" # hobbynix
  ];

  system.stateVersion = "25.11";
}
