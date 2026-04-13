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
      pavucontrol   # volume mixer (hyprpanel volume widget → open mixer)
      playerctl     # MPRIS media control (hyprpanel media widget)
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
        # Monitor config: connector,resolution@refresh,position,scale
        # Run `hyprctl monitors` or check /sys/class/drm/ for connector name.
        # Use "preferred" to let the driver negotiate — replace once stable.
        monitor = [
          ",preferred,auto,1"
        ];

        "$terminal" = "ghostty";
        "$menu" = "wofi --gtk-dark --allow-images --allow-markup --show drun";

        # NVIDIA-required environment variables (Aquamarine-compatible, not wlroots-era)
        env = [
          "LIBVA_DRIVER_NAME,nvidia"
          "XDG_SESSION_TYPE,wayland"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          "NVD_BACKEND,direct"
          "GBM_BACKEND,nvidia-drm"
          "SSH_AUTH_SOCK,$HOME/.1password/agent.sock"
        ];

        exec-once = [
          "hyprpanel"
          "wl-clipboard-history -t"
          "wl-paste --watch cliphist store"
          "rm \"$HOME/.cache/cliphist/db\""
          "1password --silent"
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

        # GTX 1080 (Pascal) has hardware cursor issues under Wayland/Hyprland
        cursor = {
          no_hardware_cursors = true;
        };
      };
    };

    # Hyprlock configuration
    programs.hyprlock.enable = true;

    # Wayland environment variable
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
