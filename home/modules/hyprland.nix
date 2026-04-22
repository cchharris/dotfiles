# Hyprland user configuration (keybindings, settings)
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.cchharris.home.hyprland;
in {
  options.cchharris.home.hyprland = {
    enable = lib.mkEnableOption "Hyprland user configuration";
    nvidiaEnvVars = lib.mkEnableOption "NVIDIA Wayland env vars (LIBVA, GLX, NVD — needed on all NVIDIA setups)";
    nvidiaGbmBackend = lib.mkEnableOption "Force GBM backend to nvidia-drm (single GPU only, breaks Optimus)";
    xwaylandForceZeroScaling = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Prevent Hyprland from upscaling XWayland apps (keeps them sharp at 1x). Disable on HiDPI to let Hyprland scale XWayland apps to the correct physical size.";
    };
    monitorScale = lib.mkOption {
      type = lib.types.str;
      default = "1";
      description = "Monitor scale factor (e.g. \"1\", \"1.5\", \"2\")";
    };
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
      grim          # screenshot tool
      slurp         # region selection for screenshots
      swappy        # screenshot annotation
      wf-recorder   # screen recording
      dart-sass     # required by HyprPanel for CSS compilation
      python3       # HyprPanel bluetooth scripts
      gpustat       # HyprPanel GPU monitoring widget
      btop          # opens when clicking HyprPanel CPU/RAM widgets
    ];

    # Hyprland configuration
    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
      plugins = [
        inputs.hyprtasking.packages.${pkgs.system}.hyprtasking
      ];
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
          ",preferred,auto,${cfg.monitorScale}"
        ];

        "$terminal" = "ghostty";
        "$menu" = "walker";

        env = [
          "XDG_SESSION_TYPE,wayland"
          "SSH_AUTH_SOCK,$HOME/.1password/agent.sock"
        ] ++ lib.optionals cfg.nvidiaEnvVars [
          "LIBVA_DRIVER_NAME,nvidia"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
          "NVD_BACKEND,direct"
        ] ++ lib.optionals cfg.nvidiaGbmBackend [
          "GBM_BACKEND,nvidia-drm"  # single GPU only — breaks Optimus display output
        ];

        exec-once = [
          "hyprpanel"
          "trayscale --hide-window"
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

          # Screenshots
          ", Print, exec, grim - | swappy -f -"                                       # fullscreen → annotate
          "$mod+SHIFT, S, exec, grim -g \"$(slurp)\" - | swappy -f -"                # region → annotate
          "$mod+SHIFT+CTRL, S, exec, grim -g \"$(slurp)\" - | wl-copy"               # region → clipboard

          # Screen recording
          "$mod+SHIFT, R, exec, wf-recorder -g \"$(slurp)\" -f ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4"
          "$mod+SHIFT+CTRL, R, exec, pkill wf-recorder"

          # Workspace navigation
          "$mod, right, workspace, +1"
          "$mod, left, workspace, -1"
          "$mod+SHIFT, right, movetoworkspace, +1"
          "$mod+SHIFT, left, movetoworkspace, -1"

          # Hyprtasking overlay
          "$mod, tab, hyprtasking:toggle, cursor"

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
          force_zero_scaling = cfg.xwaylandForceZeroScaling;
        };

        # GTX 1080 (Pascal) has hardware cursor issues under Wayland/Hyprland
        cursor = lib.mkIf cfg.nvidiaGbmBackend {
          no_hardware_cursors = true;
        };

        ecosystem = {
          no_update_news = true;
        };

        plugin = {
          hyprtasking = {
            layout = "grid";
            gap_size = 20;
            border_size = 4;
            bg_color = "0xff000000";
            exit_on_hovered = false;
            grid = {
              rows = 3;
              cols = 3;
              loop = false;
            };
            gestures = {
              enabled = true;
              open_fingers = 4;    # 4-finger swipe up/down to open/close
              open_positive = true; # swipe up = open, swipe down = close
              move_fingers = 3;    # 3-finger swipe to move between workspaces when open
            };
          };
        };

      };
    };

    # Hyprlock configuration
    programs.hyprlock.enable = true;

    # GTK dark theme
    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
    };

    # Tell XDG portal (and apps that query it) to prefer dark mode
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    # Force dark GTK theme for apps that ignore the portal (Edge under XWayland, 1Password)
    home.sessionVariables.GTK_THEME = "adw-gtk3-dark";

    # Wayland environment variable
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
