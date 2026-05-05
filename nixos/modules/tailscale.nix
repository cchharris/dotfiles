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

    # Prevent Tailscale from taking exclusive DNS control so ExpressVPN can manage DNS when active
    systemd.services.tailscale-disable-dns = {
      description = "Disable Tailscale DNS management";
      after = [ "tailscaled.service" ];
      wants = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.tailscale}/bin/tailscale set --accept-dns=false";
      };
    };

    # Open firewall for Tailscale
    networking.firewall.checkReversePath = "loose";

    environment.systemPackages = with pkgs; [
      trayscale  # GTK4 systray applet for Tailscale
    ];
  };
}
