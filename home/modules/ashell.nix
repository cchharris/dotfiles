# ashell status bar
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.ashell;

  # Polls expressvpn status every 5s and emits Waybar-format JSON
  expressvpnWatch = pkgs.writeShellScript "expressvpn-watch" ''
    while true; do
      if ${pkgs.expressvpn}/bin/expressvpn status 2>/dev/null | grep -qi "connected"; then
        printf '{"text":"connected","alt":"connected"}\n'
      else
        printf '{"text":"disconnected","alt":"disconnected"}\n'
      fi
      sleep 5
    done
  '';

  # Toggles ExpressVPN on/off
  expressvpnToggle = pkgs.writeShellScript "expressvpn-toggle" ''
    if ${pkgs.expressvpn}/bin/expressvpn status 2>/dev/null | grep -qi "connected"; then
      ${pkgs.expressvpn}/bin/expressvpn disconnect
    else
      ${pkgs.expressvpn}/bin/expressvpn connect
    fi
  '';

  # Checks if nixpkgs flake input is behind nixos-unstable tip
  checkNixpkgsUpdates = pkgs.writeShellScript "check-nixpkgs-updates" ''
    current=$(${pkgs.jq}/bin/jq -r '.nodes.nixpkgs.locked.rev' \
      "$HOME/dotfiles/flake.lock" 2>/dev/null) || exit 0
    latest=$(${pkgs.curl}/bin/curl -sf --max-time 10 \
      "https://api.github.com/repos/NixOS/nixpkgs/commits/nixos-unstable" \
      | ${pkgs.jq}/bin/jq -r '.sha' 2>/dev/null) || exit 0
    [ -n "$latest" ] && [ "$current" != "$latest" ] && echo "nixpkgs update available"
  '';

  # Opens a terminal and runs flake update + rebuild
  runNixpkgsUpdate = pkgs.writeShellScript "run-nixpkgs-update" ''
    ghostty -e bash -c '
      cd ~/dotfiles
      nix flake update
      sudo nixos-rebuild switch --flake .#razer-blade
      echo "Done — press enter to exit"
      read
    '
  '';
in {
  options.cchharris.home.ashell = {
    enable = lib.mkEnableOption "ashell status bar";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.jq ];  # required by checkNixpkgsUpdates

    programs.ashell = {
      enable = true;

      settings = {
        position = "Top";

        modules = {
          left   = [ [ "appLauncher" "Updates" "Workspaces" ] ];
          center = [ "WindowTitle" ];
          right  = [ "MediaPlayer" "SystemInfo" [ "Tray" "ExpressVpn" "Tempo" "Privacy" "Settings" ] ];
        };

        CustomModule = [
          { name = "appLauncher"; icon = "󱗼"; command = "walker"; }
          {
            name       = "ExpressVpn";
            type       = "Button";
            icon       = "󰌿";                         # default: unlocked (disconnected)
            command    = "${expressvpnToggle}";
            listen_cmd = "${expressvpnWatch}";
            icons      = { "connected" = "󰌾"; "disconnected" = "󰌿"; };
            alert      = "disconnected";               # red dot when VPN is off
          }
        ];

        updates = {
          check_cmd  = "${checkNixpkgsUpdates}";
          update_cmd = "${runNixpkgsUpdate}";
          interval   = 3600;
        };

        window_title = {
          mode = "Title";
          truncate_title_after_length = 80;
        };

        workspaces = {
          visibility_mode = "All";
          group_by_monitor = false;
          enable_workspace_filling = true;
        };

        system_info = {
          indicators = [ "Cpu" "Memory" ];
          interval = 5;
          cpu    = { warn_threshold = 60; alert_threshold = 80; };
          memory = { warn_threshold = 70; alert_threshold = 85; };
        };

        tempo = {
          clock_format = "%a %d %b %R";
        };

        # [settings] — ashell's own settings panel config
        settings = {
          lock_cmd               = "hyprlock";
          audio_sinks_more_cmd   = "pavucontrol -t 3";
          audio_sources_more_cmd = "pavucontrol -t 4";
          bluetooth_more_cmd     = "blueman-manager";
          wifi_more_cmd          = "nm-connection-editor";
          battery_format              = "IconAndPercentage";
          audio_indicator_format      = "IconAndPercentage";
          microphone_indicator_format = "Icon";
          network_indicator_format    = "Icon";
          bluetooth_indicator_format  = "Icon";
          indicators = [ "Audio" "Microphone" "Bluetooth" "Network" "Battery" ];
        };

        appearance = {
          style         = "Solid";
          primary_color = "#89b4fa";   # Catppuccin Mocha blue
          success_color = "#a6e3a1";   # green
          text_color    = "#cdd6f4";   # text
          workspace_colors = [ "#89b4fa" "#cba6f7" ];  # blue, mauve

          danger_color = {
            base = "#f38ba8";   # red
            weak = "#fab387";   # peach
          };

          background_color = {
            base   = "#1e1e2e";   # base
            weak   = "#181825";   # mantle
            strong = "#313244";   # surface0
          };

          secondary_color = {
            base = "#11111b";   # crust
          };
        };
      };
    };
  };
}
