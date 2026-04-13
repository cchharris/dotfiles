# Hyprpanel status bar configuration
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.hyprpanel;
in {
  options.cchharris.home.hyprpanel = {
    enable = lib.mkEnableOption "Hyprpanel status bar";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprpanel = {
      enable = true;
      settings = {
        scalingPriority = "both";

        theme = {
          font = {
            name = "SauceCodePro Nerd Font Regular";
            label = "SauceCodePro Nerd Font Regular";
          };
          osd.enableDropShadow = true;
          notifications = {
            autoDismiss = true;
            show_total = true;
            hideCountWhenZero = true;
          };
        };

        notifications.autoDismiss = true;

        bar.bluetooth.label = true;
        bar.dashboard.auto_detect_icon = true;
        bar.media.show_active_only = true;

        bar.workspaces = {
          workspaceMask = false;
          showWsIcons = true;
          showApplicationIcons = true;
        };

        bar.network.showWifiInfo = true;
        bar.launcher.autoDetectIcon = true;

        bar.layouts = {
          "*" = {
            left = [ "dashboard" "workspaces" "media" ];
            middle = [ "windowtitle" ];
            right = [ "volume" "network" "bluetooth" "systray" "clock" "notifications" ];
          };
        };

        menus = {
          dashboard = {
            shortcuts = {
              left = {
                shortcut1.command = "microsoft-edge";
                shortcut4.command = "wofi --gtk-dark --allow-images --allow-markup --show drun";
              };
            };
            directories = {
              right = {
                directory1.commmand = "bash -c \"nautilus $HOME/Documents/\"";
                directory2.command = "bash -c \"nautilus $HOME/Pictures/\"";
                directory3.command = "bash -c \"nautilus $HOME/\"";
              };
              left = {
                directory1.command = "bash -c \"nautilus $HOME/Downloads/\"";
                directory2.command = "bash -c \"nautilus $HOME/Videos/\"";
                directory3.command = "bash -c \"nautilus $HOME/Projects/\"";
              };
            };
          };
          media = {
            hideAlbum = false;
            displayTime = true;
            displayTimeTooltip = true;
          };
        };
      };
    };

    # Install SauceCodePro Nerd Font
    home.packages = with pkgs; [
      (nerd-fonts.sauce-code-pro)
    ];

    fonts.fontconfig.enable = true;
  };
}
