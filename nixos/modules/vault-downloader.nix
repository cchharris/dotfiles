# aria2 download daemon (magnet/.torrent/HTTP/FTP) that stores into the ZFS
# vault, with the AriaNg web UI. Built on its own unit instead of
# services.aria2 because that module's tmpfiles rule would create the download
# directory on the bare mountpoint at boot, while the vault is still locked.
#
# aria2-vault.service is never started at boot: zfs-vault's `vault unlock`
# starts it and `vault lock` stops it (managedUnits), and
# ConditionPathIsMountPoint stops a manual start while the vault is locked.
# Both ports are only open on tailscale0.
#
# One-time: the RPC secret is generated on first start into
# /var/lib/aria2-vault/rpc-secret (root-only). Read it with
# `sudo cat /var/lib/aria2-vault/rpc-secret` and paste it into AriaNg →
# Settings → RPC → aria2 RPC Secret Token.
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.vaultDownloader;
  vault = config.cchharris.nixos.zfsVault;
  mountPoint = "/tank/vault";
  downloadDir = "${mountPoint}/${cfg.subdir}";
  stateDir = "/var/lib/aria2-vault";
  user = "aria2vault";

  baseConf = pkgs.writeText "aria2-vault-base.conf" ''
    dir=${downloadDir}
    enable-rpc=true
    rpc-listen-all=true
    rpc-listen-port=${toString cfg.rpcPort}
    # AriaNg is served from another port, so the browser's RPC calls are
    # cross-origin. The RPC secret and the tailscale0-only firewall are the
    # access control.
    rpc-allow-origin-all=true
    input-file=${stateDir}/session
    save-session=${stateDir}/session
    save-session-interval=60
    continue=true
    max-concurrent-downloads=5
    split=8
    max-connection-per-server=8
    # Not a seeder: stop uploading as soon as a torrent finishes.
    seed-ratio=0.0
    seed-time=0
    # ZFS is copy-on-write; preallocating buys nothing.
    file-allocation=none
    enable-dht=true
    bt-save-metadata=true
  '';
  # aria2 can't fetch Mega links (they're client-side encrypted), so
  # `vault-mega <link>...` runs megatools' megadl as a transient unit in
  # mega-dl.slice. The slice is in zfsVault.managedUnits, so `vault lock`
  # stops any running Mega download before unmounting, like aria2.
  vaultMega = pkgs.writeShellScriptBin "vault-mega" ''
    set -euo pipefail
    if [ $# -lt 1 ]; then
      echo "usage: vault-mega <mega.nz link>..." >&2
      exit 1
    fi
    if [ "$(id -u)" != 0 ]; then
      exec sudo "$0" "$@"
    fi
    if ! ${pkgs.util-linux}/bin/mountpoint -q ${mountPoint}; then
      echo "${mountPoint} is locked — run 'vault unlock' first." >&2
      exit 1
    fi
    ${pkgs.coreutils}/bin/install -d -o ${user} -g ${user} -m 2775 ${downloadDir}
    for link in "$@"; do
      # Shells turn a pasted '#' into '\#'; megadl needs the plain link.
      link="''${link//\\/}"
      case "$link" in
        *'#'*) ;;
        *) echo "Skipping '$link': no '#key' part. Quote the whole link: vault-mega 'https://mega.nz/file/ID#KEY'" >&2; continue ;;
      esac
      unit="mega-dl-$(${pkgs.coreutils}/bin/date +%s)-$RANDOM"
      ${pkgs.systemd}/bin/systemd-run --quiet --collect --unit="$unit" --slice=mega-dl.slice \
        --uid=${user} --gid=${user} \
        --property=UMask=0002 --property=ProtectSystem=strict \
        --property=ReadWritePaths=${mountPoint} --property=PrivateTmp=yes \
        --property=NoNewPrivileges=yes \
        --setenv=XDG_CACHE_HOME=/tmp \
        ${pkgs.megatools}/bin/megadl --no-progress --path ${downloadDir} "$link"
      echo "Started $unit → ${downloadDir}   (follow: journalctl -u $unit -f)"
    done
  '';
in
{
  options.cchharris.nixos.vaultDownloader = {
    enable = lib.mkEnableOption "aria2 downloader that stores into the ZFS vault (needs zfsVault)";

    subdir = lib.mkOption {
      type = lib.types.str;
      default = "downloads";
      description = "Directory inside the vault that downloads are written to.";
    };

    rpcPort = lib.mkOption {
      type = lib.types.port;
      default = 6800;
      description = "aria2 JSON-RPC port. Only opened on tailscale0.";
    };

    webPort = lib.mkOption {
      type = lib.types.port;
      default = 6880;
      description = "AriaNg web UI port. Only opened on tailscale0.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = vault.enable;
      message = "cchharris.nixos.vaultDownloader needs cchharris.nixos.zfsVault.enable.";
    }];

    users.users.${user} = {
      isSystemUser = true;
      group = user;
      description = "aria2 downloader that writes into the vault";
    };
    users.groups.${user} = { };
    # Downloads are group-writable and setgid, so the login user can manage
    # (and the Samba share, which runs as cchharris, can delete) them.
    users.users.cchharris.extraGroups = [ user ];

    cchharris.nixos.zfsVault.managedUnits = [ "aria2-vault.service" "mega-dl.slice" ];

    environment.systemPackages = [ vaultMega ];
    systemd.slices.mega-dl.description = "Mega downloads into the vault (stopped by vault lock)";

    systemd.services.aria2-vault-secret = {
      description = "Generate the aria2 RPC secret on first use";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "aria2-vault";
        StateDirectoryMode = "0750";
      };
      script = ''
        f=${stateDir}/rpc-secret
        if [ ! -s "$f" ]; then
          umask 077
          ${pkgs.openssl}/bin/openssl rand -hex 24 > "$f"
        fi
        chmod 600 "$f"
      '';
    };

    systemd.services.aria2-vault = {
      description = "aria2 downloader writing into ${mountPoint}";
      # No wantedBy: `vault unlock` starts this, `vault lock` stops it.
      after = [ "network-online.target" "aria2-vault-secret.service" ];
      wants = [ "network-online.target" ];
      requires = [ "aria2-vault-secret.service" ];
      unitConfig.ConditionPathIsMountPoint = mountPoint;
      serviceConfig = {
        User = user;
        Group = user;
        UMask = "0002";
        StateDirectory = "aria2-vault";
        RuntimeDirectory = "aria2-vault";
        LoadCredential = "rpc-secret:${stateDir}/rpc-secret";
        # "+" runs as root: the vault root belongs to cchharris, so the
        # service user needs its own writable subdirectory (setgid, group-rw).
        ExecStartPre = [
          "+${pkgs.coreutils}/bin/install -d -o ${user} -g ${user} -m 2775 ${downloadDir}"
          (pkgs.writeShellScript "aria2-vault-conf" ''
            set -eu
            touch ${stateDir}/session
            cp ${baseConf} "$RUNTIME_DIRECTORY/aria2.conf"
            chmod 600 "$RUNTIME_DIRECTORY/aria2.conf"
            echo "rpc-secret=$(cat "$CREDENTIALS_DIRECTORY/rpc-secret")" >> "$RUNTIME_DIRECTORY/aria2.conf"
          '')
        ];
        ExecStart = "${pkgs.aria2}/bin/aria2c --conf-path=%t/aria2-vault/aria2.conf";
        Restart = "on-failure";
        RestartSec = "10s";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ReadWritePaths = [ mountPoint stateDir ];
      };
    };

    # Static AriaNg files only — no vault data — so this is safe to run
    # whether or not the vault is unlocked.
    systemd.services.aria2-vault-ui = {
      description = "AriaNg web UI for aria2-vault";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python3 -m http.server ${toString cfg.webPort} --directory ${pkgs.ariang}/share/ariang";
        DynamicUser = true;
        Restart = "on-failure";
      };
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ cfg.rpcPort cfg.webPort ];
  };
}
