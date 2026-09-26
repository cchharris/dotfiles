# Manually-unlocked encrypted ZFS dataset for consolidating VeraCrypt volumes.
# Stays locked at boot (canmount=noauto on the dataset itself) and is only ever
# unlocked deliberately, via the `vault` CLI or the Tailscale-only web service
# below — never automatically. It auto-locks autoLockAfter after unlock; if the
# vault is busy (open files, active transfers) the lock is retried every
# autoLockRetryEvery instead of cutting anything off, and `vault extend <time>`
# pushes the auto-lock out for a long transfer.
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.zfsVault;

  # Units that make up a pending auto-lock: the declarative timer/service and
  # the transient ones `vault extend` creates. Timers alone are safe to stop
  # from inside the auto-lock service; stopping the services too is only for
  # unlock/extend, which cancel a pending retry.
  timerUnits = "vault-autolock.timer vault-autolock-extend.timer";
  allUnits = "${timerUnits} vault-autolock.service vault-autolock-extend.service";

  vaultScript = pkgs.writeShellScriptBin "vault" ''
    set -euo pipefail
    dataset="${cfg.dataset}"
    ctl=${pkgs.systemd}/bin/systemctl
    run=${pkgs.systemd}/bin/systemd-run
    analyze=${pkgs.systemd}/bin/systemd-analyze

    # Human callers just type `vault ...`; re-exec via sudo so the zfs commands
    # below run as root. The web service already runs as ${cfg.serviceUser},
    # which has delegated zfs permissions (see zfs-vault-allow.service) and
    # skips this branch.
    if [ "$(id -un)" != "root" ] && [ "$(id -un)" != "${cfg.serviceUser}" ]; then
      exec sudo "$0" "$@"
    fi

    keystatus() { zfs get -H -o value keystatus "$dataset"; }
    mounted() { zfs get -H -o value mounted "$dataset"; }
    # Stops only the countdown timers — safe to call from inside the auto-lock
    # service itself (it must not stop its own unit).
    stop_timers() { sudo $ctl stop ${timerUnits} || true; }
    # Also cancels a pending auto-lock retry. Only for unlock/extend.
    cancel_autolock() { sudo $ctl stop ${allUnits} || true; }

    case "''${1:-}" in
      unlock)
        # Idempotent: the key can already be loaded (e.g. right after
        # `zfs create`) or the dataset already mounted.
        if [ "$(keystatus)" != "available" ]; then
          zfs load-key "$dataset"
        fi
        if [ "$(mounted)" != "yes" ]; then
          zfs mount "$dataset"
        fi
        cancel_autolock
        sudo $ctl restart vault-autolock.timer
        echo "Unlocked $dataset. Will auto-lock in ${cfg.autoLockAfter} unless relocked sooner."
        ;;
      lock)
        if [ "$(keystatus)" = "available" ]; then
          if [ "$(mounted)" = "yes" ] && ! zfs unmount "$dataset"; then
            echo "$dataset is busy (open files or connections) — still unlocked. The auto-lock keeps retrying every ${cfg.autoLockRetryEvery}." >&2
            exit 1
          fi
          zfs unload-key "$dataset"
        fi
        # Only stop the countdown once the lock has actually succeeded, so a
        # failed lock leaves the auto-lock armed.
        stop_timers
        echo "Locked $dataset."
        ;;
      extend)
        span="''${2:-}"
        if [ -z "$span" ]; then
          echo "usage: vault extend <time>   (e.g. 8h, 90min, 1d)" >&2
          exit 1
        fi
        if [ "$(id -un)" != "root" ]; then
          echo "vault extend must run as root (run it as a normal user; it re-execs via sudo)." >&2
          exit 1
        fi
        if ! $analyze timespan "$span" >/dev/null 2>&1; then
          echo "Invalid time span: $span (try 8h, 90min, 1d)" >&2
          exit 1
        fi
        if [ "$(keystatus)" != "available" ] || [ "$(mounted)" != "yes" ]; then
          echo "$dataset is not unlocked; nothing to extend." >&2
          exit 1
        fi
        cancel_autolock
        $run --quiet --unit=vault-autolock-extend --on-active="$span"           --timer-property=AccuracySec=1min           --service-type=oneshot           --property=Restart=on-failure           --property=RestartSec=${cfg.autoLockRetryEvery}           "$0" lock
        echo "Auto-lock moved to $span from now (retries every ${cfg.autoLockRetryEvery} while busy)."
        ;;
      status)
        zfs get -o property,value keystatus,mounted "$dataset"
        $ctl list-timers --no-pager 'vault-autolock*' || true
        ;;
      *)
        echo "usage: vault {unlock|lock|extend <time>|status}" >&2
        exit 1
        ;;
    esac
  '';

  vaultWeb = pkgs.writeTextFile {
    name = "vault-web.py";
    text = ''
      import http.server, json, subprocess

      DATASET = "${cfg.dataset}"
      PORT = ${toString cfg.webService.port}
      ZFS = "${pkgs.zfs}/bin/zfs"
      VAULT = "${vaultScript}/bin/vault"

      class Handler(http.server.BaseHTTPRequestHandler):
          def _send(self, code, body):
              self.send_response(code)
              self.send_header("Content-Type", "application/json")
              self.end_headers()
              self.wfile.write(json.dumps(body).encode())

          def do_GET(self):
              if self.path != "/status":
                  self._send(404, {"error": "not found"})
                  return
              r = subprocess.run([ZFS, "get", "-H", "-o", "value", "keystatus,mounted", DATASET],
                                  capture_output=True, text=True)
              lines = r.stdout.strip().splitlines()
              self._send(200, {
                  "keystatus": lines[0] if lines else "unknown",
                  "mounted": lines[1] if len(lines) > 1 else "unknown",
              })

          def do_POST(self):
              length = int(self.headers.get("Content-Length", 0))
              body = self.rfile.read(length)

              # Both routes shell out to the same `vault` CLI used for manual
              # unlock/lock, rather than reimplementing the zfs/systemctl
              # calls here — one place decides what "unlock" and "lock" mean.
              if self.path == "/lock":
                  subprocess.run([VAULT, "lock"], check=False)
                  self._send(200, {"status": "locked"})
                  return

              if self.path == "/unlock":
                  # `body` is the real dataset passphrase, piped straight
                  # into `vault unlock`'s stdin (which zfs load-key reads,
                  # since keylocation=prompt falls back to stdin when it
                  # isn't a tty). Never logged, never written to disk, never
                  # kept beyond this one call.
                  passphrase = body
                  try:
                      subprocess.run([VAULT, "unlock"], input=passphrase, check=True)
                      self._send(200, {"status": "unlocked"})
                  except subprocess.CalledProcessError:
                      self._send(401, {"error": "unlock failed"})
                  finally:
                      passphrase = None
                  return

              self._send(404, {"error": "not found"})

          def log_message(self, fmt, *args):
              # Suppress default request logging so nothing about /unlock
              # requests (which carry the passphrase in the body) lands in
              # the journal.
              pass

      if __name__ == "__main__":
          http.server.HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
    '';
  };
in
{
  options.cchharris.nixos.zfsVault = {
    enable = lib.mkEnableOption "manually-unlocked encrypted ZFS vault dataset";

    dataset = lib.mkOption {
      type = lib.types.str;
      default = "tank/vault";
      description = ''
        ZFS dataset to manage. Must already exist — created imperatively via
        `zfs create -o encryption=aes-256-gcm -o keyformat=passphrase
        -o keylocation=prompt -o canmount=noauto -o mountpoint=... <dataset>`,
        same as tank/k8s. This module does not provision the dataset itself,
        only the lock/unlock tooling around it.
      '';
    };

    serviceUser = lib.mkOption {
      type = lib.types.str;
      default = "vault-svc";
      description = "Unprivileged system user granted delegated ZFS permissions on the dataset; runs the web service.";
    };

    autoLockAfter = lib.mkOption {
      type = lib.types.str;
      default = "4h";
      description = "systemd time span after which an unlocked vault is force-relocked if not relocked sooner.";
    };

    autoLockRetryEvery = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      description = "How often the auto-lock retries while the vault is busy (open files or active transfers). Nothing is ever force-disconnected.";
    };

    webService = {
      enable = lib.mkEnableOption "Tailscale-only web unlock/lock service";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8420;
        description = "Port the web service listens on. Only opened on the tailscale0 interface, never the LAN.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.serviceUser} = {
      isSystemUser = true;
      group = cfg.serviceUser;
      description = "Runs the zfs-vault CLI/web unlock service; delegated ZFS permissions only, no sudo beyond the autolock timer.";
    };
    users.groups.${cfg.serviceUser} = { };

    # Note: load-key also covers unload-key — `unload-key` is not a valid
    # `zfs allow` permission name and makes the command fail.
    # `zfs allow` isn't declarative — re-applying it idempotently every boot
    # avoids relying on a one-time manual step that could be forgotten after
    # a reinstall or a pool re-import.
    systemd.services.zfs-vault-allow = {
      description = "Grant ${cfg.serviceUser} delegated ZFS permissions on ${cfg.dataset}";
      wantedBy = [ "multi-user.target" ];
      after = [ "zfs-import.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.zfs}/bin/zfs allow ${cfg.serviceUser} load-key,mount ${cfg.dataset}";
      };
    };

    # Narrowly scoped to exactly the autolock timer — vault-svc's actual zfs
    # access comes from the delegation above, not from sudo.
    security.sudo.extraRules = [
      {
        users = [ cfg.serviceUser ];
        commands = [
          { command = "${pkgs.systemd}/bin/systemctl restart vault-autolock.timer"; options = [ "NOPASSWD" ]; }
          { command = "${pkgs.systemd}/bin/systemctl stop ${timerUnits}"; options = [ "NOPASSWD" ]; }
          { command = "${pkgs.systemd}/bin/systemctl stop ${allUnits}"; options = [ "NOPASSWD" ]; }
        ];
      }
    ];

    environment.systemPackages = [ vaultScript ];

    systemd.timers.vault-autolock = {
      description = "Force-relock ${cfg.dataset} ${cfg.autoLockAfter} after unlock if not relocked sooner";
      timerConfig = {
        OnActiveSec = cfg.autoLockAfter;
        AccuracySec = "1min";
      };
    };

    systemd.services.vault-autolock = {
      description = "Force-relock ${cfg.dataset}";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${vaultScript}/bin/vault lock";
        # Busy vault => `vault lock` exits non-zero; retry instead of leaving
        # it unlocked forever. Nothing is force-disconnected.
        Restart = "on-failure";
        RestartSec = cfg.autoLockRetryEvery;
      };
    };

    systemd.services.vault-web = lib.mkIf cfg.webService.enable {
      description = "Tailscale-only web unlock/lock service for ${cfg.dataset}";
      wantedBy = [ "multi-user.target" ];
      after = [ "tailscaled.service" "zfs-vault-allow.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python3 ${vaultWeb}";
        User = cfg.serviceUser;
        Group = cfg.serviceUser;
        Restart = "on-failure";
      };
    };

    # Firewall rule, not app-level trust: this port simply does not exist on
    # the LAN interface at all.
    networking.firewall.interfaces.tailscale0.allowedTCPPorts =
      lib.mkIf cfg.webService.enable [ cfg.webService.port ];
  };
}
