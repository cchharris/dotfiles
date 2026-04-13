# Hyprland window manager module
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.hyprland;
in {
  options.cchharris.nixos.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager";
  };

  config = lib.mkIf cfg.enable {
    # Enable common desktop features
    cchharris.nixos.desktop-common.enable = true;

    # Hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    programs.hyprlock.enable = true;

    # Hint to electron apps to use wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # greetd with gtkgreet for login manager
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.cage}/bin/cage -s -- ${pkgs.gtkgreet}/bin/gtkgreet -s /etc/greetd/gtkgreet.css";
          user = "greeter";
        };
      };
    };

    environment.etc."greetd/environments".text = ''
      ${pkgs.hyprland}/bin/start-hyprland
    '';

    environment.etc."greetd/gtkgreet.css".text = ''
      * {
        background: #1e1e2e;
        color: #cdd6f4;
      }
      window {
        background-image: none;
        background-color: #1e1e2e;
      }
      box#body {
        background-color: #181825;
        border-radius: 12px;
        padding: 32px;
        margin: 16px;
      }
      label {
        color: #cdd6f4;
      }
      entry {
        background-color: #313244;
        color: #cdd6f4;
        border: 1px solid #45475a;
        border-radius: 6px;
        padding: 8px;
      }
      entry:focus {
        border-color: #89b4fa;
      }
      button {
        background-color: #89b4fa;
        color: #1e1e2e;
        border: none;
        border-radius: 6px;
        padding: 8px 16px;
        font-weight: bold;
      }
      button:hover {
        background-color: #b4befe;
      }
      combobox button {
        background-color: #313244;
        color: #cdd6f4;
      }
    '';

    # X11 config for keyboard (still used by some apps)
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # PAM configuration for hyprlock
    security.pam.services.hyprlock = {};

    # Hyprland-specific packages
    environment.systemPackages = with pkgs; [
      ghostty
      hyprlock
    ];
  };
}
