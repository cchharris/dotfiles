# Local Nix binary cache: ncps sits in front of cache.nixos.org and keeps a copy of
# everything the LAN downloads, so each store path is fetched from the internet
# once and then served to every machine from here.
#
# The cache signs what it serves with its own key (generated on first start under
# /var/lib/ncps). Clients must trust that key — fetch it with:
#   curl http://<nas>:8501/pubkey
# and put it in cchharris.nixos.nixCacheClient.publicKey (nix-cache-client.nix).
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.nixCache;
in {
  options.cchharris.nixos.nixCache = {
    enable = lib.mkEnableOption "local Nix binary cache (ncps)";

    hostName = lib.mkOption {
      type = lib.types.str;
      default = "nas.home";
      description = "Name the cache signs with (part of its signing key name).";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8501;
      description = "Port the cache listens on.";
    };

    maxSize = lib.mkOption {
      type = lib.types.str;
      default = "100G";
      description = "Maximum size of the cache on disk (/var/lib/ncps, on the boot drive).";
    };

    allowFrom = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "192.168.1.0/24" ];
      description = "LAN networks allowed to use the cache. It only serves public, signed store paths (no uploads).";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      services.ncps = {
        enable = true;
        server.addr = ":${toString cfg.port}";
        prometheus.enable = true;
        cache = {
          hostName = cfg.hostName;
          maxSize = cfg.maxSize;
          upstream = {
            urls = [ "https://cache.nixos.org" ];
            publicKeys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
          };
        };
      };

      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ cfg.port ];
    }

    (lib.mkIf (!config.networking.nftables.enable) {
      networking.firewall.extraCommands = lib.concatMapStrings (net: ''
        iptables -A nixos-fw -p tcp -s ${net} --dport ${toString cfg.port} -j nixos-fw-accept
      '') cfg.allowFrom;
    })
    (lib.mkIf config.networking.nftables.enable {
      networking.firewall.extraInputRules = ''
        ip saddr { ${lib.concatStringsSep ", " cfg.allowFrom} } tcp dport ${toString cfg.port} accept
      '';
    })
  ]);
}
