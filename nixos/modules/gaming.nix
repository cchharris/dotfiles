# Gaming support module (Steam, Proton)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.gaming;

  nonSteamLaunchersScript = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/moraroy/NonSteamLaunchers-On-Steam-Deck/main/NonSteamLaunchers.sh";
    hash = "sha256-ILJl6aRRuvpq1Mu/284SaD+PPnbuZz80jR0TihhbTi8=";
  };

  # Packages whose GI typelibs are needed for the GTK3 Python GUI
  gi-deps = with pkgs; [ gtk3 glib.out pango.out gdk-pixbuf atk harfbuzz gobject-introspection ];
  gi-typelib-path = pkgs.lib.makeSearchPath "lib/girepository-1.0" gi-deps;

  # Single Python env reused in both the wrapper PATH and the /usr/bin/python3 symlink
  nsl-python = pkgs.python3.withPackages (ps: [ ps.pygobject3 ps.certifi ]);

  deps = pkgs.lib.makeBinPath [
    pkgs.bash pkgs.curl pkgs.wget pkgs.jq
    pkgs.zenity pkgs.unzip pkgs.p7zip pkgs.rsync
    nsl-python pkgs.winetricks pkgs.cabextract
    pkgs.gnused pkgs.gawk pkgs.coreutils pkgs.findutils
  ];

  # NixOS-specific wrapping notes:
  #
  # NSL is a Steam Deck tool that assumes a standard FHS Linux environment. Several
  # layers of wrapping are needed to make it work on NixOS:
  #
  # 1. GTK3 GUI: GI_TYPELIB_PATH must be set so Python's gi module can find Gtk-3.0.
  #    glib and pango must use .out (not the default -bin output) to get their typelibs.
  #
  # 2. Proton/steam-runtime: NSL invokes steam-runtime/run.sh which contains FHS
  #    dynamically-linked binaries that can't run on NixOS. The entire script must run
  #    inside `steam-run` to get the FHS environment Proton needs.
  #
  # 3. PATH priority: steam-run prepends its own FHS paths, overriding our Nix Python
  #    (which has gi/certifi). Fix: store deps in env vars before entering steam-run,
  #    then re-prepend them inside a bash -c subshell after entering the FHS env.
  #
  # 4. /usr/bin/python3: NSLGameScanner.service hardcodes this path. Handled via
  #    systemd.tmpfiles.rules below — symlinked to nsl-python.
  nonSteamLaunchers = pkgs.stdenvNoCC.mkDerivation {
    name = "non-steam-launchers";
    dontUnpack = true;
    installPhase = ''
      # Wrapper script
      mkdir -p $out/bin
      cat > $out/bin/non-steam-launchers << EOF
      #!${pkgs.bash}/bin/bash
      export _NSL_DEPS="${deps}"
      export _NSL_GI_TYPELIB="${gi-typelib-path}"
      exec steam-run ${pkgs.bash}/bin/bash -c 'export PATH="\$_NSL_DEPS:\$PATH"; export GI_TYPELIB_PATH="\$_NSL_GI_TYPELIB"; exec ${pkgs.bash}/bin/bash ${nonSteamLaunchersScript} "\$@"' -- "\$@"
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
    # Steam/Proton scripts use #!/bin/bash shebangs; NixOS only provides /bin/sh
    systemd.tmpfiles.rules = [
      "L /bin/bash - - - - ${pkgs.bash}/bin/bash"
      # NSLGameScanner.service hardcodes /usr/bin/python3 which doesn't exist on NixOS
      "L /usr/bin/python3 - - - - ${nsl-python}/bin/python3"
    ];

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
