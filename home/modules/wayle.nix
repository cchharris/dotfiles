# wayle shell — replaces ashell + swaync + swayosd
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.wayle;

  checkNixpkgsUpdates = pkgs.writeShellScript "check-nixpkgs-updates" ''
    current=$(${pkgs.jq}/bin/jq -r '.nodes.nixpkgs.locked.rev' \
      "$HOME/dotfiles/flake.lock" 2>/dev/null) || exit 0
    latest=$(${pkgs.curl}/bin/curl -sf --max-time 10 \
      "https://api.github.com/repos/NixOS/nixpkgs/commits/nixos-unstable" \
      | ${pkgs.jq}/bin/jq -r '.sha' 2>/dev/null) || exit 0
    [ -n "$latest" ] && [ "$current" != "$latest" ] && \
      printf '{"text":"nixpkgs %s→%s"}\n' "''${current:0:7}" "''${latest:0:7}" && exit 0
    printf '{"text":""}\n'
  '';

  runNixpkgsUpdate = pkgs.writeShellScript "run-nixpkgs-update" ''
    ghostty -e bash -c '
      cd ~/dotfiles
      nix flake update
      sudo nixos-rebuild boot --flake ".#$(hostname)"
      echo "Done — reboot to apply. Press enter to exit"
      read
    '
  '';

  powerMenu = pkgs.writeShellScript "power-menu" ''
    chosen=$(printf 'Lock\nSleep\nReboot\nShutdown' \
      | wofi --dmenu --prompt "Power" --lines 4 --width 200)
    case "$chosen" in
      Lock)     hyprlock ;;
      Sleep)    systemctl suspend ;;
      Reboot)   systemctl reboot ;;
      Shutdown) systemctl poweroff ;;
    esac
  '';
in {
  options.cchharris.home.wayle = {
    enable = lib.mkEnableOption "wayle shell";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.wayle pkgs.jq ];

    xdg.configFile."wayle/config.toml".text = ''
      [bar]
      location = "top"
      exclusive = true

      [[bar.layout]]
      monitor = "*"
      left = ["custom-launcher", "hyprland-workspaces"]
      center = ["window-title"]
      right = ["media", "systray", "clock", "weather", "notifications", "volume", "brightness", "bluetooth", "network", "battery", "idle-inhibit", "power"]

      [modules.weather]
      location = "Seattle"
      units = "imperial"

      [modules.power]
      left-click = "${powerMenu}"

      [styling]
      theme-provider = "wayle"

      [styling.palette]
      bg = "#1e1e2e"
      fg = "#cdd6f4"
      primary = "#89b4fa"
      success = "#a6e3a1"
      warning = "#fab387"
      error = "#f38ba8"

      [[modules.custom]]
      id = "launcher"
      left-click = "walker"
      format = "Apps"

      [[modules.custom]]
      id = "nixpkgs-updates"
      command = "${checkNixpkgsUpdates}"
      interval-ms = 3600000
      left-click = "${runNixpkgsUpdate}"
      format = "{{ text }}"
    '';
  };
}
