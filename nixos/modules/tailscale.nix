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

    # ExpressVPN Lightway uses 100.64.100.0/24 internally for tunnel addresses
    # and DNS (100.64.100.1). Tailscale's ts-input chain drops packets sourced
    # from 100.64.0.0/10 that don't arrive via tailscale0 (anti-spoofing). This
    # silently drops VPN DNS responses, breaking DNS while connected.
    # Insert a RETURN before the DROP so tun0 traffic from the VPN range is
    # skipped past Tailscale's filter and accepted by nixos-fw's conntrack rule.
    systemd.services.tailscale-expressvpn-compat = {
      description = "Exempt ExpressVPN tunnel range from Tailscale anti-spoofing";
      after = [ "tailscaled.service" ];
      bindsTo = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iptables}/bin/iptables -I ts-input 1 -s 100.64.100.0/24 -i tun0 -j RETURN";
        ExecStop = "${pkgs.iptables}/bin/iptables -D ts-input -s 100.64.100.0/24 -i tun0 -j RETURN || true";
      };
    };

    environment.systemPackages = with pkgs; [
      trayscale  # GTK4 systray applet for Tailscale
    ];
  };
}
