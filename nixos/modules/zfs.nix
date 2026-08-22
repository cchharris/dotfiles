# ZFS storage pool support module
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.zfs;
in {
  options.cchharris.nixos.zfs = {
    enable = lib.mkEnableOption "ZFS storage pools";
  };

  config = lib.mkIf cfg.enable {
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.forceImportRoot = false;

    # ZFS requires a unique host ID to refuse importing a pool that's still
    # marked as in-use by another machine (protects against corruption if a
    # pool is ever moved between hosts without exporting first). Must be set
    # per-host in the host config: networking.hostId = "<8 hex chars>";
    # (generate with: head -c 8 /etc/machine-id)

    # Weekly scrub catches bit rot before it compounds; TRIM keeps SSD-backed
    # pools performant. Both are safe no-ops on pools/devices that don't apply.
    services.zfs.autoScrub.enable = true;
    services.zfs.trim.enable = true;

    # Data datasets are created with `-o keylocation=prompt` (passphrase, not a
    # keyfile) so a stolen machine's data pool stays opaque without needing
    # network-bound unlock infra. On boot, the pool imports fine (import
    # doesn't require the key) but datasets needing decryption block on
    # zfs-load-key.service via systemd's ask-password mechanism. Only
    # units that depend on the mounted dataset (nfs/samba exports) wait on
    # this — networking/sshd/tailscaled come up regardless. Unlock remotely
    # after boot with either:
    #   ssh nas 'systemd-tty-ask-password-agent'   # answers the pending prompt
    #   ssh nas 'zfs load-key -a && zfs mount -a'  # or just do it directly
    environment.systemPackages = with pkgs; [ zfs smartmontools ];
  };
}
