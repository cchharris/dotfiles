# LanCache: caching proxy for game downloads (Steam etc.) on the LAN.
# Runs the lancachenet/monolithic container under Podman on the host network, so
# it serves on the NAS's own IP (ports 80/443). Clients only use it once their
# DNS resolves the game CDN domains to this host — see the Pi-hole records in
# the homelab repo. Cache data lives on its own ZFS dataset (created by hand:
#   zfs create -o mountpoint=/tank/lancache -o compression=off \
#     -o recordsize=1M -o atime=off tank/lancache
# — game files are already compressed, so compression only costs CPU).
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.lancache;
in {
  options.cchharris.nixos.lancache = {
    enable = lib.mkEnableOption "LanCache game download cache";

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/tank/lancache";
      description = "Mountpoint of the ZFS dataset holding the cache and logs.";
    };

    cacheSize = lib.mkOption {
      type = lib.types.str;
      default = "2000g";
      description = "Maximum size of the on-disk cache (CACHE_DISK_SIZE).";
    };

    indexMemory = lib.mkOption {
      type = lib.types.str;
      default = "500m";
      description = "RAM for the cache key index (CACHE_INDEX_SIZE); roughly 250MB per TB of cache.";
    };

    upstreamDns = lib.mkOption {
      type = lib.types.str;
      default = "1.1.1.1 1.0.0.1";
      description = "Resolvers the cache uses to reach the real CDNs. Must NOT be the Pi-hole that redirects clients here, or requests loop.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";

    virtualisation.oci-containers.containers.lancache = {
      image = "lancachenet/monolithic:latest";
      autoStart = true;
      volumes = [
        "${cfg.dataDir}/cache:/data/cache"
        "${cfg.dataDir}/logs:/data/logs"
      ];
      environment = {
        CACHE_DISK_SIZE = cfg.cacheSize;
        CACHE_INDEX_SIZE = cfg.indexMemory;
        CACHE_MAX_AGE = "3650d";
        UPSTREAM_DNS = cfg.upstreamDns;
        TZ = config.time.timeZone or "UTC";
      };
      # Host network: serves on the NAS's own address without a NAT hop.
      extraOptions = [ "--network=host" ];
    };

    # Don't start before the ZFS dataset is mounted, or the container would
    # write the cache into the root filesystem underneath the mountpoint.
    systemd.services.podman-lancache = {
      unitConfig.RequiresMountsFor = cfg.dataDir;
      after = [ "zfs-mount.service" ];
      # Podman won't start if a bind-mount source directory is missing, and the
      # dataset starts out empty.
      preStart = "mkdir -p ${cfg.dataDir}/cache ${cfg.dataDir}/logs";
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
