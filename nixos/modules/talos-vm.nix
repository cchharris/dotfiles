# Talos worker VM: joins the homelab cluster (Turing Pi, ARM64) as its one x86_64
# node, reserved for GitHub Actions runners (ARC — see the homelab repo,
# cluster/actions-runners). QEMU runs straight under systemd, with no libvirt
# state to manage, on a tap attached to the host's LAN bridge so the VM gets its
# own address.
#
# First boot: the disk is blank, so the VM falls through to the Talos ISO and
# comes up in maintenance mode. `talosctl apply-config --insecure` installs Talos
# to /dev/vda; from then on it boots from disk (disk is first in the boot order).
# Steps: homelab bootstrap/talos/RUNBOOK.md, "NAS CI worker".
#
# Serial console (for debugging a VM that never reaches the network):
#   sudo socat -,rawer UNIX-CONNECT:/run/talos-vm/console.sock   (Ctrl-] to quit)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.talosVm;

  # Must match the cluster's talosVersion (homelab bootstrap/talos/talconfig.yaml).
  # Only the first boot uses the ISO; upgrades go through `talosctl upgrade`.
  talosVersion = "1.7.6";
  talosIso = pkgs.fetchurl {
    url = "https://github.com/siderolabs/talos/releases/download/v${talosVersion}/metal-amd64.iso";
    sha256 = "13e5bf33c337b9656dac84e54867810cffb47a31cc6662dd70575568c343e272";
  };

  stateDir = "/var/lib/talos-vm";
  runDir = "/run/talos-vm";
  tap = "tap-talos";

  # Runs as root ("+" prefix): the tap is created owned by the VM user, so QEMU
  # itself needs no network privileges.
  setupTap = pkgs.writeShellScript "talos-vm-tap-up" ''
    ${pkgs.iproute2}/bin/ip link del ${tap} 2>/dev/null || true
    ${pkgs.iproute2}/bin/ip tuntap add dev ${tap} mode tap user talos-vm
    ${pkgs.iproute2}/bin/ip link set ${tap} master ${cfg.bridge} up
  '';

  # ACPI power button, then wait for QEMU to exit: systemd kills whatever is
  # still running as soon as ExecStop returns, so returning early would pull the
  # plug on Talos mid-shutdown.
  powerdown = pkgs.writeShellScript "talos-vm-powerdown" ''
    echo system_powerdown | ${pkgs.socat}/bin/socat - UNIX-CONNECT:${runDir}/monitor.sock || exit 0
    ${pkgs.coreutils}/bin/tail --pid="$MAINPID" -f /dev/null
  '';
in {
  options.cchharris.nixos.talosVm = {
    enable = lib.mkEnableOption "Talos Kubernetes worker VM (CI runners)";

    bridge = lib.mkOption {
      type = lib.types.str;
      default = "br0";
      description = "Host bridge the VM's tap joins (must already exist, with the LAN uplink in it).";
    };

    macAddress = lib.mkOption {
      type = lib.types.str;
      description = "VM NIC MAC. Talos selects its interface by this (talconfig deviceSelector), so keep them in sync.";
    };

    cpus = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "vCPUs given to the VM.";
    };

    memory = lib.mkOption {
      type = lib.types.str;
      default = "12G";
      description = "VM RAM (QEMU -m syntax). ZFS ARC gives memory back under pressure, so the host copes.";
    };

    diskSize = lib.mkOption {
      type = lib.types.str;
      default = "80G";
      description = "Size of the (sparse) qcow2 disk, created on first start only — resizing needs qemu-img by hand.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.talos-vm = {
      isSystemUser = true;
      group = "talos-vm";
      extraGroups = [ "kvm" ];
    };
    users.groups.talos-vm = { };

    systemd.services.talos-vm = {
      description = "Talos Kubernetes worker VM (CI runners)";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" "${cfg.bridge}-netdev.service" ];
      wants = [ "network-online.target" ];

      preStart = ''
        if [ ! -e ${stateDir}/disk.qcow2 ]; then
          ${pkgs.qemu_kvm}/bin/qemu-img create -f qcow2 ${stateDir}/disk.qcow2 ${cfg.diskSize}
        fi
      '';

      serviceConfig = {
        User = "talos-vm";
        Group = "talos-vm";
        StateDirectory = "talos-vm";
        RuntimeDirectory = "talos-vm";
        ExecStartPre = [ "+${setupTap}" ];
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.qemu_kvm}/bin/qemu-system-x86_64"
          "-name talos-ci"
          "-machine q35,accel=kvm"
          "-cpu host"
          "-smp ${toString cfg.cpus}"
          "-m ${cfg.memory}"
          "-drive file=${stateDir}/disk.qcow2,if=virtio,format=qcow2,cache=none,discard=unmap"
          "-drive file=${talosIso},media=cdrom,readonly=on"
          # Disk first; a blank disk falls through to the ISO.
          "-boot order=cd"
          "-netdev tap,id=net0,ifname=${tap},script=no,downscript=no"
          "-device virtio-net-pci,netdev=net0,mac=${cfg.macAddress}"
          "-display none"
          "-chardev socket,id=ser0,path=${runDir}/console.sock,server=on,wait=off"
          "-serial chardev:ser0"
          "-monitor unix:${runDir}/monitor.sock,server,nowait"
        ];
        ExecStop = "${powerdown}";
        ExecStopPost = [ "-+${pkgs.iproute2}/bin/ip link del ${tap}" ];
        TimeoutStopSec = "3min";
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}
