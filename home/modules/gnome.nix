# GNOME desktop configuration (extensions, dconf, GTK theme)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.gnome;
in {
  options.cchharris.home.gnome = {
    enable = lib.mkEnableOption "GNOME desktop configuration";
  };

  config = lib.mkIf cfg.enable {
    # GNOME extensions
    home.packages = with pkgs; [
      gnome-tweaks
      gnomeExtensions.appindicator
      gnomeExtensions.dash-to-dock
      gnomeExtensions.blur-my-shell
      gnomeExtensions.caffeine
      gnomeExtensions.gsconnect
    ];

    # dconf settings for GNOME
    dconf.settings = {
      # Enable installed extensions
      "org/gnome/shell" = {
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
          "dash-to-dock@micxgx.gmail.com"
          "blur-my-shell@aunetx"
          "caffeine@pataber.com"
          "gsconnect@andyholmes.github.io"
        ];
        favorite-apps = [
          "microsoft-edge.desktop"
          "org.gnome.Nautilus.desktop"
          "ghostty.desktop"
          "discord.desktop"
          "steam.desktop"
        ];
      };

      # Interface settings
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        clock-show-weekday = true;
        show-battery-percentage = true;
      };

      # Window management
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
        focus-mode = "click";
      };

      # Dash to Dock settings
      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-position = "BOTTOM";
        dock-fixed = false;
        autohide = true;
        intellihide = true;
        dash-max-icon-size = 48;
        show-trash = false;
        show-mounts = false;
      };

      # Blur my shell
      "org/gnome/shell/extensions/blur-my-shell/panel" = {
        blur = true;
      };

      # Touchpad settings
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        natural-scroll = true;
        two-finger-scrolling-enabled = true;
      };

      # Power settings
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        power-button-action = "interactive";
      };

      # Night Light
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-temperature = lib.hm.gvariant.mkUint32 3500;
      };

      # File manager
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
        search-filter-time-type = "last_modified";
      };
    };

    # Set Microsoft Edge as default browser
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "microsoft-edge.desktop";
        "x-scheme-handler/http" = "microsoft-edge.desktop";
        "x-scheme-handler/https" = "microsoft-edge.desktop";
        "x-scheme-handler/about" = "microsoft-edge.desktop";
        "x-scheme-handler/unknown" = "microsoft-edge.desktop";
        "application/xhtml+xml" = "microsoft-edge.desktop";
        "application/x-extension-htm" = "microsoft-edge.desktop";
        "application/x-extension-html" = "microsoft-edge.desktop";
        "application/x-extension-shtml" = "microsoft-edge.desktop";
        "application/x-extension-xhtml" = "microsoft-edge.desktop";
        "application/x-extension-xht" = "microsoft-edge.desktop";
      };
    };

    # GTK theme settings
    gtk = {
      enable = true;
      theme = {
        name = "Adwaita-dark";
      };
      iconTheme = {
        name = "Adwaita";
      };
      cursorTheme = {
        name = "Adwaita";
        size = 24;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    };
  };
}
