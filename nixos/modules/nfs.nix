# NFS server module — backs the Turing Pi k8s cluster's PersistentVolumes
# (see ~/Repos/homelab: local-path-provisioner now, NFS once this exists)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.nfs;
in {
  options.cchharris.nixos.nfs = {
    enable = lib.mkEnableOption "NFS server";

    exports = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Contents appended to /etc/exports. One line per export, e.g.:
        /tank/k8s 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
      '';
      example = ''
        /tank/k8s 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.nfs.server = {
      enable = true;
      exports = cfg.exports;
    };

    # NFSv4 only — simpler firewall surface than v3 (no rpcbind/mountd port dance)
    networking.firewall.allowedTCPPorts = [ 2049 ];
  };
}
