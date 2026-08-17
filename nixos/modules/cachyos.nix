# CachyOS-derived performance tweaks, ported to run on top of a stock nixpkgs kernel.
# Sources: https://github.com/CachyOS/CachyOS-Settings, https://github.com/sched-ext/scx
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.cachyos;
in {
  options.cchharris.nixos.cachyos = {
    enable = lib.mkEnableOption "CachyOS-derived performance tweaks (scx, ananicy, sysctls, THP)";
  };

  config = lib.mkIf cfg.enable {
    # sched-ext: run a userspace CPU scheduler instead of the kernel's built-in one.
    # scx_lavd (Latency-Aware Voluntary Deadline) is CachyOS's pick for desktop/gaming
    # responsiveness — it prioritizes latency-sensitive threads (input, audio, frame
    # submission) over raw throughput. Requires kernel >=6.12; asserted by the module.
    services.scx = {
      enable = true;
      scheduler = "scx_lavd";
    };

    # Auto-nice daemon: watches running processes and adjusts nice/ionice/sched class
    # per CachyOS's ruleset, so background noise doesn't steal CPU/IO from foreground work.
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };

    # Compressed RAM-backed swap, checked before the physical LUKS/NVMe swap
    # partition (higher-priority swap devices are preferred by the kernel). Makes
    # vm.swappiness=100 below the right call instead of the wrong one: swapping to
    # zram is RAM-speed, so swapping "aggressively" no longer means "swap to disk."
    zramSwap.enable = true;

    # Ported from CachyOS-Settings' 70-cachyos-settings.conf, minus:
    #  - kernel.unprivileged_userns_clone: a Debian-kernel-only sysctl toggle; the
    #    stock nixpkgs kernel doesn't carry that patch, so the node wouldn't exist.
    boot.kernel.sysctl = {
      "vm.swappiness" = 100;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_bytes" = 268435456;
      "vm.dirty_background_bytes" = 67108864;
      "vm.dirty_writeback_centisecs" = 1500;
      "vm.page-cluster" = 0;
      "kernel.nmi_watchdog" = 0;
      "kernel.kptr_restrict" = 2;
      "kernel.printk" = "3 3 3 3";
      "net.core.netdev_max_backlog" = 4096;
      "fs.file-max" = 2097152;
    };

    # Transparent Huge Page tuning: only defragment memory into huge pages when an
    # app explicitly requests it (madvise), deferred to the background, avoiding the
    # random stalls THP=always defrag can cause. Cap khugepaged so it won't collapse
    # mostly-empty (>80% zero) regions into huge pages, which bloats memory for little
    # benefit.
    systemd.tmpfiles.rules = [
      "w! /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise"
      "w! /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_none - - - - 409"
    ];
  };
}
