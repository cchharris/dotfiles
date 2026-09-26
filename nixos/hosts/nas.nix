# NAS host configuration
#
# Platform: ASRock Rack X570D4U-2L2T + Ryzen 5 5600G + 32GB DDR4 non-ECC.
# Drives (installed): 3x 8TB Seagate IronWolf ST8000VN004 + 1x 8TB Seagate
# BarraCuda Pro ST8000DM0004 (CMR) + 2x 4TB (WD40EFRX, ST4000VN000) + 256GB
# WD SN740 M.2 NVMe boot SSD. The 2TB backup drive is not connected yet.
# Pool "tank" — 3 mirrors striped for capacity + IOPS scaling:
#   mirror(8TB-new, 8TB-new) + mirror(8TB-existing, 8TB-new) +
#   mirror(4TB-existing, 4TB-existing) = 20TB usable
# Pool "backup" — repurposed spare 2TB, single drive (no redundancy needed —
# it's already a copy of redundant primary data), scoped to only
# tank/k8s + tank/vault + tank/data via zfs send (NOT tank/media — deliberately
# not backed up). Cloud backup (separate, outside NixOS config) covers
# tank/k8s + tank/vault offsite, for the site-disaster case a local drive can't
# (tank/data is local-backup only unless you add it there too). Watch the size:
# the combined datasets must fit on the single 2TB backup drive.
# Spares held in reserve, not installed: 1x2TB, 1x1TB HDD, 1x1TB SSD.
# Port budget: 6 (tank) + 1 (backup) = 7 of 7 SATA ports used, 0 free — any
# further growth needs a SATA HBA card in the board's PCIe x1 slot.
# Boot: 256GB M.2 NVMe SSD, plain ext4, off the ZFS pool entirely. Deliberately
# NOT SATA — the X570D4U-2L2T's M.2 slots don't share lanes with any SATA
# port (per the manual), so boot doesn't cost a SATA port at all.
#
# TEMPLATE — finish this after the physical install:
#   1. DONE: box POSTs with the 5600G (BIOS P1.40, BMC 1.20.00). BMC web
#      UI is on the dedicated IPMI LAN port.
#   2. DONE: hardware/nas.nix holds the real disk UUIDs.
#   3. Create the pools (fill in real /dev/disk/by-id paths once drives are
#      connected — run `ls -la /dev/disk/by-id/` to get them):
#        # Compression everywhere: set on the pool root (-O) so every dataset
#        # inherits it. If the pool already exists: `zfs set compression=zstd tank`
#        # (only affects data written afterwards).
#        zpool create -o ashift=12 -O compression=zstd tank \
#          mirror /dev/disk/by-id/<8tb-new-1> /dev/disk/by-id/<8tb-new-2> \
#          mirror /dev/disk/by-id/<8tb-existing> /dev/disk/by-id/<8tb-new-3> \
#          mirror /dev/disk/by-id/<4tb-1> /dev/disk/by-id/<4tb-2>
#        # tank/k8s is deliberately UNENCRYPTED: an encrypted dataset would
#        # stay locked after any reboot/power loss and hang every PVC on it.
#        # Keep network-critical apps (Pi-hole, ingress, cert-manager) on
#        # node-local storage, not here; only deferrable apps go on tank/k8s.
#        zfs create -o mountpoint=/tank/k8s tank/k8s
#        # tank/data: general-purpose plain storage, shared over Samba. Not
#        # encrypted (put private material on tank/vault). Included in the
#        # local backup pool's zfs send scope (see backup notes below).
#        zfs create -o mountpoint=/tank/data tank/data
#        chown cchharris:users /tank/data   # so the Samba user can write
#        # tank/media is NOT created yet (deferred). When you want it:
#        #   zfs create -o recordsize=1M -o mountpoint=/tank/media tank/media
#        # then re-add the `media` Samba share below.
#        zfs create -o encryption=aes-256-gcm -o keyformat=passphrase \
#          -o keylocation=prompt -o canmount=noauto -o mountpoint=/tank/vault \
#          tank/vault
#        zpool create -o ashift=12 -O compression=zstd backup /dev/disk/by-id/<2tb-spare>
#      (one dataset per client concern is easier to manage than one giant
#      dataset; tank/k8s, tank/vault and tank/data get zfs send'd to backup —
#      set up a periodic `zfs send -R -i` cron/systemd timer for just those
#      three once the pool exists; tank/media is intentionally excluded.
#      tank/vault is encrypted: send it raw (`zfs send -w`) so it lands on the
#      backup pool still encrypted and the key isn't needed there)
#      For tank/vault's passphrase: use a long, high-entropy one (a random
#      25+ character password-manager string, or several random Diceware
#      words) — see nixos/modules/zfs-vault.nix for why this matters (ZFS's
#      PBKDF2 key derivation is weaker than VeraCrypt's Argon2id, so the
#      passphrase itself has to carry the margin). canmount=noauto keeps it
#      locked at boot; `vault unlock`/`vault lock` manage it after that.
#      Before trusting the reused 4TB pair or existing 8TB with live data,
#      check their SMART health first (smartd is already enabled below) —
#      they're not new.
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
        # media share deferred until tank/media exists (see pool notes above).
        data = {
          path = "/tank/data";
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

  # VeraCrypt CLI: open uploaded .hc volumes on the box and copy their contents
  # straight into the ZFS vault, instead of pulling them across the network a
  # second time. Headless — use `sudo veracrypt --text --mount <file> <dir>`.
  environment.systemPackages = with pkgs; [ veracrypt ];

  system.stateVersion = "25.11";
}
