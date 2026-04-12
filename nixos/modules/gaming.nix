# Gaming support module (Steam, Proton)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.gaming;

  nonSteamLaunchers = pkgs.stdenvNoCC.mkDerivation {
    name = "non-steam-launchers";
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/moraroy/NonSteamLaunchers-On-Steam-Deck/main/NonSteamLaunchers.sh";
      hash = "sha256-0bsfbcc8l4qxils3yrzffqz8ygv82b7dpgybsimgmfjilklnbci0=";
    };
    dontUnpack = true;
    buildInputs = [ pkgs.steam ];
    installPhase = ''
      install -Dm755 $src $out/bin/non-steam-launchers
    '';
  };
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
      nonSteamLaunchers
    ];
  };
}
