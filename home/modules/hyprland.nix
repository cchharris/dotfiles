# Hyprland user configuration (keybindings, settings)
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.cchharris.home.hyprland;

in {
  options.cchharris.home.hyprland = {
    enable = lib.mkEnableOption "Hyprland user configuration";
    nvidiaEnvVars = lib.mkEnableOption "NVIDIA Wayland env vars (LIBVA, GLX, NVD — needed on all NVIDIA setups)";
    nvidiaGbmBackend = lib.mkEnableOption "Force GBM backend to nvidia-drm (single GPU only, breaks Optimus)";
    polychromaticAutostart = lib.mkEnableOption "Autostart polychromatic-tray-applet to apply saved Razer lighting on login";
    monitorScale = lib.mkOption {
      type = lib.types.str;
      default = "1";
      description = "Monitor scale factor (e.g. \"1\", \"1.5\", \"2\")";
    };
    gpuCount = lib.mkOption {
      type = lib.types.ints.positive;
      default = 1;
      description = "Number of GPU boxes to show in btop. Optimus laptops (iGPU + dGPU) should set 2.";
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
      awww           # wallpaper daemon backend wayle's wallpaper engine renders through (formerly "swww")
      pavucontrol   # volume mixer (wayle audio → open mixer)
      playerctl     # MPRIS media control (wayle media widget)
      grim          # screenshot tool
      slurp         # region selection for screenshots
      swappy        # screenshot annotation
      wf-recorder   # screen recording (software encode)
      gpu-screen-recorder # NVENC hardware-encoded recording — game clips
      brightnessctl # backlight control
      adwaita-icon-theme # icons for GTK apps
      kanshi    # auto-apply monitor profiles on connect/disconnect
    ];

    # Hyprland configuration
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      plugins = [ inputs.hyprtasking.packages.${pkgs.stdenv.hostPlatform.system}.hyprtasking ];
      systemd = {
        enable = false;
        enableXdgAutostart = true;
        variables = ["--all"];
      };

      settings = {
        # Monitor config — see https://wiki.hypr.land/Configuring/Basics/Monitors/
        # "preferred"/"auto" lets the driver negotiate — replace once stable.
        monitor = {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = cfg.monitorScale;
        };

        env = [
          { _args = [ "XDG_SESSION_TYPE" "wayland" ]; }
          { _args = [ "SSH_AUTH_SOCK" "$HOME/.1password/agent.sock" ]; }
          # wayle's units_from_locale_name strips .UTF-8 encoding only if bare;
          # set bare en_US here (session-only) so it matches the "en_US" → Imperial branch
          { _args = [ "LC_MEASUREMENT" "en_US" ]; }
        ] ++ lib.optionals cfg.nvidiaEnvVars [
          { _args = [ "LIBVA_DRIVER_NAME" "nvidia" ]; }
          { _args = [ "__GLX_VENDOR_LIBRARY_NAME" "nvidia" ]; }
          { _args = [ "NVD_BACKEND" "direct" ]; }
        ] ++ lib.optionals cfg.nvidiaGbmBackend [
          { _args = [ "GBM_BACKEND" "nvidia-drm" ]; }  # single GPU only — breaks Optimus display output
        ];

        config = {
          general = {
            layout = "dwindle";
            gaps_in = 2;   # was Hyprland's default 5
            gaps_out = 4;  # was Hyprland's default 20 — that plus wayle's exclusive
                           # bar zone was the dead space near the top edge
          };

          input = {
            follow_mouse = 0;
            touchpad = {
              disable_while_typing = false;
            };
          };

          dwindle = {
            preserve_split = true;
            force_split = 2;
          };

          xwayland = {
            force_zero_scaling = true;
          };

          ecosystem = {
            no_update_news = true;
          };

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            # Matches Catlogin's SDDM backgroundColor so the screen doesn't
            # jump color before wayle's wallpaper paints over it.
            background_color = "0x2a2d3d";
          };
        } // lib.optionalAttrs cfg.nvidiaGbmBackend {
          # GTX 1080 (Pascal) has hardware cursor issues under Wayland/Hyprland
          cursor = {
            no_hardware_cursors = true;
          };
        };
      };

      # Raw Lua: keybindings translated from hyprlang dispatcher-string syntax to
      # hl.dsp.* calls (https://wiki.hypr.land/Configuring/Basics/Binds/), autostart,
      # and hyprtasking's plugin config (its README documents this Lua form directly:
      # https://github.com/raybbian/hyprtasking#configuration). The plugin itself is
      # loaded via the `plugins` option above, not here.
      extraConfig = ''
        local mod = "SUPER"
        local terminal = "ghostty"
        local menu = "walker"

        hl.on("hyprland.start", function()
          hl.exec_cmd("awww-daemon")
          hl.exec_cmd("wayle shell")
          hl.exec_cmd("kanshi")
          hl.exec_cmd("elephant")
          hl.exec_cmd("pgrep trayscale || trayscale --hide-window")
          hl.exec_cmd("wl-clipboard-history -t")
          hl.exec_cmd("wl-paste --watch cliphist store")
          hl.exec_cmd('rm "$HOME/.cache/cliphist/db"')
          hl.exec_cmd("1password --silent")
          hl.exec_cmd("expressvpn-client")
      ''
      + lib.optionalString cfg.polychromaticAutostart ''
          hl.exec_cmd("polychromatic-tray-applet")
      ''
      + ''
        end)

        -- Application launchers
        hl.bind(mod .. " + T", hl.dsp.exec_cmd(terminal))
        hl.bind(mod .. " + C", hl.dsp.window.close())
        hl.bind(mod .. " + M", hl.dsp.exec_cmd(menu))
        hl.bind(mod .. " + F", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))

        -- Vim-style navigation (HJKL)
        hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
        hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))
        hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
        hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))

        -- Vim-style window movement
        hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
        hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
        hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
        hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

        -- Window cycling
        hl.bind("ALT + TAB", hl.dsp.window.cycle_next({}))
        hl.bind("ALT + SHIFT + TAB", hl.dsp.window.cycle_next({ next = false }))

        -- Screenshots
        hl.bind("Print", hl.dsp.exec_cmd("grim - | swappy -f -"))
        hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'))
        hl.bind(mod .. " + SHIFT + CTRL + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

        -- Screen recording
        hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd('wf-recorder -g "$(slurp)" -f ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4'))
        hl.bind(mod .. " + SHIFT + CTRL + R", hl.dsp.exec_cmd("pkill wf-recorder"))

        -- Workspace navigation
        hl.bind(mod .. " + right", hl.dsp.focus({ workspace = "+1" }))
        hl.bind(mod .. " + left", hl.dsp.focus({ workspace = "-1" }))
        hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ workspace = "+1" }))
        hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ workspace = "-1" }))
        for i = 1, 9 do
          hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
          hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
        end

        -- Brightness (wayle shows OSD)
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"))
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))

        -- Volume (wayle shows OSD)
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
        hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

        -- Media controls
        hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
        hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
        hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
        hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

        -- hyprtasking
        hl.bind(mod .. " + TAB", function() hl.plugin.hyprtasking.toggle("cursor") end)

        hl.config({
          plugin = {
            hyprtasking = {
              layout = "grid",
              gap_size = 20,
              border_size = 4,
              bg_color = 0xff000000,
              exit_on_hovered = false,
              grid = {
                rows = 1,
                cols = 9,
                loop = false,
              },
              gestures = {
                enabled = true,
                open_fingers = 4,
                open_positive = true,
                move_fingers = 3,
              },
            },
          },
        })
      '';
    };

    # Hyprlock configuration
    programs.hyprlock.enable = true;
    catppuccin.hyprlock.enable = true;

    # System monitor — shown_boxes gpu list sized to this host's GPU count
    # (Optimus laptops set gpuCount = 2 for iGPU + dGPU).
    programs.btop = {
      enable = true;
      settings = {
        shown_boxes = lib.concatStringsSep " "
          ([ "cpu" "mem" "net" "proc" ]
          ++ map (i: "gpu${toString i}") (lib.range 0 (cfg.gpuCount - 1)));
        # Nix manages this file; don't let btop overwrite it on exit.
        save_config_on_exit = false;
      };
    };
    catppuccin.btop.enable = true;

    # GTK dark theme
    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
    };
    # Widget theme (above) stays adw-gtk3-dark — catppuccin/nix doesn't ship a
    # GTK widget theme, only icons + cursors, so layer those on top instead.
    catppuccin.gtk.icon.enable = true;
    # Sets home.pointerCursor, which home-manager's own cursor module then
    # uses to set HYPRCURSOR_THEME/HYPRCURSOR_SIZE automatically.
    catppuccin.cursors.enable = true;
    # catppuccin's cursors module doesn't set this itself (deprecation warning
    # otherwise) — home-manager now wants it explicit rather than inferred.
    home.pointerCursor.enable = true;

    # Tell XDG portal (and apps that query it) to prefer dark mode
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    # Force dark GTK theme for apps that ignore the portal (Edge under XWayland, 1Password)
    home.sessionVariables.GTK_THEME = "adw-gtk3-dark";

    # Wayland environment variable
    home.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
