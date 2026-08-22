# NAS host configuration
#
# TEMPLATE — finish this after the physical install:
#   1. Run `nixos-generate-config` on the actual box and replace
#      ../../hardware/nas.nix with its output (real disk UUIDs can't be
#      guessed remotely).
#   2. Set networking.hostId below (head -c 8 /etc/machine-id).
#   3. Create the data pool, e.g.:
#        zpool create -o ashift=12 tank raidz1 /dev/disk/by-id/<drive1> ...
#        zfs create -o encryption=aes-256-gcm -o keyformat=passphrase \
#          -o keylocation=prompt -o mountpoint=/tank/k8s tank/k8s
#      (repeat per dataset — one export per client concern is easier to
#      manage than one giant dataset)
#   4. Fill in nfs.exports / samba.shares below to match.
#   5. In BIOS/UEFI: set "Restore on AC Power Loss" -> Power On. NixOS can't
#      configure this — it's firmware.
{ config, lib, pkgs, ... }:

{
  networking.hostName = "nas";

  # See step 2 above.
  networking.hostId = "00000000";

  cchharris.nixos = {
    zfs.enable = true;
    smartd.enable = true;
    tailscale.enable = true;  # own tailnet identity — reachable without depending on the k8s cluster's Tailscale operator
    fail2ban.enable = true;

    nfs = {
      enable = true;
      exports = ''
        /tank/k8s 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
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
      };
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

  system.stateVersion = "25.11";
}
