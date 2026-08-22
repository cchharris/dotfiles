# Samba file sharing module — SMB access for desktop/laptop clients
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.samba;
in {
  options.cchharris.nixos.samba = {
    enable = lib.mkEnableOption "Samba file sharing";

    shares = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
      description = "Samba share definitions, passed through to services.samba.settings";
      example = lib.literalExpression ''
        {
          media = {
            path = "/tank/media";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "valid users" = "cchharris";
          };
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "server string" = "nas";
          security = "user";
          "map to guest" = "never";
        };
      } // cfg.shares;
    };

    # mDNS advertisement so shares show up as nas.local in Finder/Explorer
    services.samba.nsswins = true;
  };
}
