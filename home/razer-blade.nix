# Home Manager configuration for razer-blade (Hyprland)
{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/editor.nix
    ./modules/terminal.nix
    ./modules/git.nix
    ./modules/hyprland.nix
    ./modules/wayle.nix
    ./modules/walker.nix
    ./modules/k8s.nix
  ];

  home.username = "cchharris";
  home.homeDirectory = "/home/cchharris";
  home.stateVersion = "26.05";

  # Enable Hyprland modules instead of GNOME
  cchharris.home = {
    shell.enable = true;
    editor.enable = true;
    terminal.enable = true;
    git.enable = true;
    hyprland = {
      enable = true;
      nvidiaEnvVars = true;  # needed for VA-API and GLX on NVIDIA Optimus
      # nvidiaGbmBackend intentionally off — Optimus uses Intel for display output
      monitorScale = "1.6";
      polychromaticAutostart = true;
    };
    wayle.enable = true;
    walker.enable = true;
    k8s.enable = true;
  };

  # Discord
  programs.discord.enable = true;

  # Kanshi monitor profiles — applied automatically on connector hotplug.
  # eDP-2 is the Intel-driven internal panel (2560x1440, scale 1.6 = 1600x900 logical).
  # HDMI-A-1 is wired to the NVIDIA GPU; placed to the right of the laptop screen.
  # 4K TV at scale 1.0 so games can render at full 3840x2160.
  xdg.configFile."kanshi/config".text = ''
    profile laptop {
        output eDP-2 mode 2560x1440 position 0,0 scale 1.6
    }

    profile tv {
        output eDP-2 mode 2560x1440 position 0,0 scale 1.6
        output HDMI-A-1 mode 1920x1080@60 position 1600,0 scale 1.0
    }
  '';

  # WirePlumber hook: auto-switch default audio sink to HDMI on plug-in,
  # restore the previous sink on unplug.
  # Script lives in XDG_DATA_HOME so WirePlumber finds it by name in the conf.d.
  xdg.dataFile."wireplumber/scripts/hdmi-auto-switch.lua".text = ''
    log = Log.open_topic("s-hdmi-autoswitch")
    local prev_default_sink = nil

    SimpleEventHook {
      name = "node-added@hdmi-auto-switch",
      interests = {
        EventInterest {
          Constraint { "event.type", "=", "node-added" },
          Constraint { "media.class", "=", "Audio/Sink" },
        },
      },
      execute = function(event)
        local source = event:get_source()
        local node = event:get_subject()
        local node_name = node.properties["node.name"] or ""

        if not node_name:match(".*hdmi.*") and not node_name:match(".*iec958.*") then
          return
        end

        local metadata_om = source:call("get-object-manager", "metadata")
        local metadata = metadata_om:lookup {
          Constraint { "metadata.name", "=", "default" }
        }
        if not metadata then return end

        local current = metadata:find(0, "default.configured.audio.sink")
        if current then
          local parsed = Json.Raw(current):parse()
          if parsed and parsed.name and not parsed.name:match(".*hdmi.*") then
            prev_default_sink = parsed.name
            log:info("Saving previous default sink: " .. parsed.name)
          end
        end

        log:info("HDMI audio connected, switching to: " .. node_name)
        metadata:set(0, "default.configured.audio.sink",
          "Spa:String:JSON",
          Json.Object { ["name"] = node_name }:to_string())
      end
    }:register()

    SimpleEventHook {
      name = "node-removed@hdmi-auto-switch",
      interests = {
        EventInterest {
          Constraint { "event.type", "=", "node-removed" },
          Constraint { "media.class", "=", "Audio/Sink" },
        },
      },
      execute = function(event)
        local source = event:get_source()
        local node = event:get_subject()
        local node_name = node.properties["node.name"] or ""

        if not node_name:match(".*hdmi.*") and not node_name:match(".*iec958.*") then
          return
        end
        if not prev_default_sink then return end

        local metadata_om = source:call("get-object-manager", "metadata")
        local metadata = metadata_om:lookup {
          Constraint { "metadata.name", "=", "default" }
        }
        if not metadata then return end

        log:info("HDMI audio disconnected, restoring to: " .. prev_default_sink)
        metadata:set(0, "default.configured.audio.sink",
          "Spa:String:JSON",
          Json.Object { ["name"] = prev_default_sink }:to_string())
        prev_default_sink = nil
      end
    }:register()
  '';

  # Register the hook as an optional WirePlumber component in the main profile.
  xdg.configFile."wireplumber/wireplumber.conf.d/51-hdmi-auto-switch.conf".text = ''
    wireplumber.components = [
      {
        name = hdmi-auto-switch.lua
        type = script/lua
        provides = custom.hdmi-auto-switch
        requires = [ metadata.default, support.standard-event-source ]
      }
    ]

    wireplumber.profiles.main = {
      custom.hdmi-auto-switch = optional
    }
  '';

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
