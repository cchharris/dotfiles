# Gaming support module (Steam, Proton)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.gaming;

  nonSteamLaunchersScript = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/moraroy/NonSteamLaunchers-On-Steam-Deck/main/NonSteamLaunchers.sh";
    hash = "sha256-ILJl6aRRuvpq1Mu/284SaD+PPnbuZz80jR0TihhbTi8=";
  };

  deps = pkgs.lib.makeBinPath [
    pkgs.bash pkgs.curl pkgs.wget pkgs.jq
    pkgs.zenity pkgs.unzip pkgs.p7zip pkgs.rsync
    pkgs.python3 pkgs.winetricks pkgs.cabextract
    pkgs.gnused pkgs.gawk pkgs.coreutils pkgs.findutils
  ];

  nonSteamLaunchers = pkgs.stdenvNoCC.mkDerivation {
    name = "non-steam-launchers";
    dontUnpack = true;
    installPhase = ''
      # Wrapper script
      mkdir -p $out/bin
      cat > $out/bin/non-steam-launchers << EOF
      #!${pkgs.bash}/bin/bash
      export PATH="${deps}:\$PATH"
      exec ${pkgs.bash}/bin/bash ${nonSteamLaunchersScript} "\$@"
      EOF
      chmod +x $out/bin/non-steam-launchers

      # Desktop entry
      mkdir -p $out/share/applications
      cat > $out/share/applications/non-steam-launchers.desktop << EOF
      [Desktop Entry]
      Name=NonSteamLaunchers
      Comment=Install and manage non-Steam game launchers
      Exec=$out/bin/non-steam-launchers
      Icon=steam
      Terminal=false
      Type=Application
      Categories=Game;
      EOF
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
