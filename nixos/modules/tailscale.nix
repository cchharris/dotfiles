# Tailscale VPN module
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.tailscale;
in {
  options.cchharris.nixos.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";
  };

  config = lib.mkIf cfg.enable {
    services.tailscale.enable = true;

    # Open firewall for Tailscale
    networking.firewall.checkReversePath = "loose";
  };
}
