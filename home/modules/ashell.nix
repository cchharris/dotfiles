# ashell status bar
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.ashell;
in {
  options.cchharris.home.ashell = {
    enable = lib.mkEnableOption "ashell status bar";
  };

  config = lib.mkIf cfg.enable {
    programs.ashell = {
      enable = true;

      settings = {
        position = "Top";

        modules = {
          left  = [ [ "appLauncher" "Workspaces" ] ];
          center = [ "WindowTitle" ];
          right  = [ "MediaPlayer" "SystemInfo" [ "Tray" "Tempo" "Privacy" "Settings" ] ];
        };

        CustomModule = [
          { name = "appLauncher"; icon = "󱗼"; command = "walker"; }
        ];

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
          lock_cmd              = "hyprlock";
          audio_sinks_more_cmd  = "pavucontrol -t 3";
          audio_sources_more_cmd = "pavucontrol -t 4";
          bluetooth_more_cmd    = "blueman-manager";
          wifi_more_cmd         = "nm-connection-editor";
          battery_format              = "IconAndPercentage";
          audio_indicator_format      = "IconAndText";
          microphone_indicator_format = "Icon";
          network_indicator_format    = "Icon";
          bluetooth_indicator_format  = "Icon";
          indicators = [ "Audio" "Microphone" "Bluetooth" "Network" "Battery" ];
        };

        appearance = {
          style         = "Islands";
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
