# Gaming support module (Steam, Proton)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.gaming;

  nonSteamLaunchers = pkgs.writeShellScriptBin "non-steam-launchers" ''
    export PATH="${pkgs.lib.makeBinPath [
      pkgs.bash pkgs.curl pkgs.wget pkgs.jq
      pkgs.zenity pkgs.unzip pkgs.p7zip pkgs.rsync
      pkgs.python3 pkgs.winetricks pkgs.cabextract
      pkgs.gnused pkgs.gawk pkgs.coreutils pkgs.findutils
    ]}:$PATH"
    exec ${pkgs.bash}/bin/bash ${pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/moraroy/NonSteamLaunchers-On-Steam-Deck/main/NonSteamLaunchers.sh";
      hash = "sha256-ILJl6aRRuvpq1Mu/284SaD+PPnbuZz80jR0TihhbTi8=";
    }} "$@"
  '';
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
