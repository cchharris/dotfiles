# Hyprland window manager module
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.cchharris.nixos.hyprland;

  sddm-theme-catlogin = pkgs.stdenvNoCC.mkDerivation {
    pname = "sddm-theme-catlogin";
    version = "unstable-2026-08-25";

    src = pkgs.fetchFromGitHub {
      owner = "MaxBoss69";
      repo = "Catlogin";
      rev = "48f729b35959a4aecd5497565b5f668b9dbc22cf";
      hash = "sha256-0kPSUnjV7NOKgc0NCgzDw9xH0QLxCFdKUxR73h0ILS4=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/sddm/themes/catlogin
      cp -r $src/* $out/share/sddm/themes/catlogin/
      runHook postInstall
    '';
  };
in {
  options.cchharris.nixos.hyprland = {
    enable = lib.mkEnableOption "Hyprland window manager";
  };

  config = lib.mkIf cfg.enable {
    # Enable common desktop features
    cchharris.nixos.desktop-common.enable = true;

    # Hyprland — use flake package so plugins built against the same binary
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

    programs.hyprlock.enable = true;

    # Hint to electron apps to use wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # SDDM (Wayland-native greeter) with the Catlogin theme
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "catlogin";
      extraPackages = [ pkgs.kdePackages.qtsvg ];
    };

    # X11 config for keyboard (still used by some apps)
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # XDG portal (required for screen sharing in Discord/Firefox/browsers on Wayland)
    xdg.portal = {
      enable = true;
      extraPortals = [ inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland ];
    };

    # PAM configuration for hyprlock
    security.pam.services.hyprlock = {};


    # Hyprland-specific packages
    environment.systemPackages = [
      sddm-theme-catlogin
    ] ++ (with pkgs; [
      ghostty
      hyprlock
      brightnessctl
    ]);
  };
}
