# Catppuccin theming (https://nix.catppuccin.com) — global toggle + flavor/accent.
# Per-program integrations (catppuccin.<program>.enable) live next to that
# program's own config in the relevant module (hyprland.nix, shell.nix, etc.)
# rather than all being listed here.
{ config, lib, ... }:

let
  cfg = config.cchharris.home.catppuccinTheme;
in {
  options.cchharris.home.catppuccinTheme = {
    enable = lib.mkEnableOption "Catppuccin theming via catppuccin/nix";
  };

  config = lib.mkIf cfg.enable {
    catppuccin = {
      enable = true;
      autoEnable = false; # explicit per-program opt-in, matches the rest of this repo's style
      flavor = "mocha";
      accent = "blue"; # matches the blue accent already used in wayle/Ghostty/SDDM
    };
  };
}
