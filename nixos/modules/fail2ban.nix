# fail2ban intrusion prevention module
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.fail2ban;
in {
  options.cchharris.nixos.fail2ban = {
    enable = lib.mkEnableOption "fail2ban intrusion prevention";
  };

  config = lib.mkIf cfg.enable {
    services.fail2ban.enable = true;
  };
}
