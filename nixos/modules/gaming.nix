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

      # Desktop entry (metadata from official .desktop, Exec points to nix wrapper)
      mkdir -p $out/share/applications
      cat > $out/share/applications/non-steam-launchers.desktop << EOF
      [Desktop Entry]
      Name=NonSteamLaunchers
      Name[en_US]=NonSteamLaunchers
      GenericName=
      GenericName[en_US]=
      Comment=
      Comment[en_US]=
      Exec=$out/bin/non-steam-launchers
      Icon=uav
      Terminal=false
      Type=Application
      Categories=Game;
      StartupNotify=true
      X-DBUS-ServiceName=
      X-DBUS-StartupType=
      X-KDE-SubstituteUID=false
      X-KDE-Username=
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
