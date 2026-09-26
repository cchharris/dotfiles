# Use the LAN Nix cache (nix-cache.nix on the NAS) as an extra substituter.
# cache.nixos.org stays as a fallback, and the short connect timeout means a
# powered-off NAS costs a few seconds, not a stalled build.
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.nixCacheClient;
in {
  options.cchharris.nixos.nixCacheClient = {
    enable = lib.mkEnableOption "use the local Nix binary cache";

    url = lib.mkOption {
      type = lib.types.str;
      default = "http://192.168.1.20:8501";
      description = "Address of the ncps cache (a fixed LAN address — see NETWORK.md).";
    };

    publicKey = lib.mkOption {
      type = lib.types.str;
      example = "nas.home:AbC...=";
      description = "The cache's signing public key: curl <url>/pubkey";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      extra-substituters = [ cfg.url ];
      extra-trusted-public-keys = [ cfg.publicKey ];
      connect-timeout = 5;
      fallback = true;
    };
  };
}
