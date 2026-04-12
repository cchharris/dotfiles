# Gaming support module (Steam, Proton)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.gaming;
in {
  options.cchharris.nixos.gaming = {
    enable = lib.mkEnableOption "gaming support (Steam, Proton)";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    environment.systemPackages = with pkgs; [
      protonup-qt
    ];
  };
}
