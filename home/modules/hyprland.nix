# Hyprland user configuration (keybindings, settings)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.hyprland;
in {
  options.cchharris.home.hyprland = {
    enable = lib.mkEnableOption "Hyprland user configuration";
  };

  config = lib.mkIf cfg.enable {
    # Wayland packages
    home.packages = with pkgs; [
      cliphist
      hyprcursor
      hypridle
      hyprlock
      hyprpaper
      hyprpicker
      hyprpolkitagent
      nautilus
      wl-clipboard
      wofi
    ];

    # Hyprland configuration
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;  # Use system package
      portalPackage = null;  # Use system package
      systemd = {
        enable = false;
        enableXdgAutostart = true;
        variables = ["--all"];
      };

      settings = {
        "$terminal" = "kitty";
        "$menu" = "wofi --gtk-dark --allow-images --allow-markup --show drun";

        exec-once = [
          "hyprpanel"
          "wl-clipboard-history -t"
          "wl-paste --watch cliphist store"
          "rm \"$HOME/.cache/cliphist/db\""
        ];

        "$mod" = "SUPER";

        # Vim-style HJKL keybindings
        bind = [
          # Application launchers
          "$mod, T, exec, $terminal"
          "$mod, C, killactive"
          "$mod, M, exec, $menu"
          "$mod, F, togglefloating"
          "$mod+SHIFT, F, fullscreen"

          # Vim-style navigation (HJKL)
          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"

          # Vim-style window movement
          "$mod+SHIFT, H, movewindow, l"
          "$mod+SHIFT, J, movewindow, d"
          "$mod+SHIFT, K, movewindow, u"
          "$mod+SHIFT, L, movewindow, r"

          # Window cycling
          "ALT, TAB, cyclenext"
          "ALT+SHIFT, TAB, cyclenext, prev"

          # Workspace navigation
          "$mod, right, workspace, +1"
          "$mod, left, workspace, -1"
          "$mod+SHIFT, right, movetoworkspace, +1"
          "$mod+SHIFT, left, movetoworkspace, -1"
        ];

        input = {
          follow_mouse = 0;
        };

        general = {
          "$modifier" = "SUPER";
          layout = "dwindle";
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
          force_split = 2;
        };

        xwayland = {
          force_zero_scaling = true;
        };
      };
    };

    # Hyprlock configuration
    programs.hyprlock.enable = true;

    # Wayland environment variable
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
