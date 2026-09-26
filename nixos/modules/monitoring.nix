# NAS monitoring: Prometheus exporters (scraped by the homelab cluster's
# kube-prometheus-stack, graphed in Grafana) + Scrutiny (SMART dashboard).
#
# Exposure: exporters are reachable from the cluster nodes (scrapeFrom) and from
# Tailscale only; Scrutiny's web UI (no auth of its own) is Tailscale-only —
# nothing here is open to the rest of the LAN.
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.monitoring;

  # node_exporter, zfs_exporter, smartctl_exporter (their nixpkgs default ports)
  exporterPorts = [ 9100 9134 9633 ];
  scrutinyPort = config.services.scrutiny.settings.web.listen.port;
  nft = config.networking.nftables.enable;
in {
  options.cchharris.nixos.monitoring = {
    enable = lib.mkEnableOption "Prometheus exporters + Scrutiny SMART dashboard";

    scrapeFrom = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "192.168.1.31" "192.168.1.32" "192.168.1.34" ];
      description = "LAN addresses allowed to reach the exporter ports (the cluster nodes running Prometheus scrapes).";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.prometheus.exporters = {
        # Includes the ZFS kstat collector (ARC etc.); the systemd collector
        # adds unit state (e.g. to alert on vault-web / smbd / nfs-server).
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
        };
        # Pool/dataset health and capacity.
        zfs.enable = true;
        # Per-drive SMART attributes (autodiscovers all disks).
        smartctl.enable = true;
      };

      # Per-drive history and failure thresholds. Runs its own InfluxDB (module
      # default). Web UI is Tailscale-only (below).
      services.scrutiny.enable = true;
      # Not the default 8080: the LanCache container (host network) needs 8080
      # for its own nginx.
      services.scrutiny.settings.web.listen.port = 8081;

      networking.firewall.interfaces.tailscale0.allowedTCPPorts =
        exporterPorts ++ [ scrutinyPort ];
    }

    # Exporter ports from the cluster nodes only. The default NixOS firewall is
    # iptables; handle nftables too in case it's ever enabled.
    (lib.mkIf (!nft) {
      networking.firewall.extraCommands = lib.concatMapStrings (ip:
        lib.concatMapStrings (port: ''
          iptables -A nixos-fw -p tcp -s ${ip} --dport ${toString port} -j nixos-fw-accept
        '') exporterPorts) cfg.scrapeFrom;
    })
    (lib.mkIf nft {
      networking.firewall.extraInputRules = ''
        ip saddr { ${lib.concatStringsSep ", " cfg.scrapeFrom} } tcp dport { ${lib.concatMapStringsSep ", " toString exporterPorts} } accept
      '';
    })
  ]);
}
