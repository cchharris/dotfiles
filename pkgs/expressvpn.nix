{ lib, stdenv, fetchurl, autoPatchelfHook
, glib, zlib, brotli, wayland, libGL, libxkbcommon
, libsm, libice, libxau, libxdmcp
, libcap_ng, dbus, fontconfig, freetype
# Needed for patching openvpn-updown.sh (expressvpn-lightway clears env before spawning it)
, coreutils, findutils, gnugrep, gawk, openresolv, iproute2, systemd
}:

stdenv.mkDerivation {
  pname = "expressvpn";
  version = "14.0.1.12858";

  src = fetchurl {
    url = "https://www.expressvpn.works/clients/linux/expressvpn-linux-universal-14.0.1.12858_release.run";
    hash = "sha256-H1CUHndgazZnzOguZRW2NSFDK/r5jtN32xaXBM6IcRg=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    stdenv.cc.cc.lib glib zlib brotli
    wayland libGL libxkbcommon
    libsm libice libxau libxdmcp
    libcap_ng dbus fontconfig freetype
  ];

  dontUnpack = true;
  dontBuild = true;
  autoPatchelfIgnoreMissingDeps = true;

  installPhase = ''
    runHook preInstall

    sh "$src" --noexec --target ./extracted

    mkdir -p $out/bin $out/lib $out/share $out/plugins $out/qml

    cp -r ./extracted/x64/expressvpnfiles/bin/. $out/bin/
    cp -r ./extracted/x64/expressvpnfiles/lib/. $out/lib/
    cp -r ./extracted/x64/expressvpnfiles/share/. $out/share/
    cp -r ./extracted/x64/expressvpnfiles/plugins/. $out/plugins/
    cp -r ./extracted/x64/expressvpnfiles/qml/. $out/qml/

    ln -s $out/bin/expressvpnctl $out/bin/expressvpn
    ln -s $out/bin/expressvpn-daemon $out/bin/expressvpnd

    # Native messaging hosts for browsers
    mkdir -p $out/lib/mozilla/native-messaging-hosts
    sed "s|REPLACE_PATH|$out/share/browser_helper_wrapper.sh|g" \
      ./extracted/x64/expressvpnfiles/share/firefox.com.expressvpn.helper.json \
      > $out/lib/mozilla/native-messaging-hosts/com.expressvpn.helper.json
    sed "s|REPLACE_PATH|$out/share/browser_helper_wrapper.sh|g" \
      ./extracted/x64/expressvpnfiles/share/chrome.com.expressvpn.helper.json \
      > $out/share/com.expressvpn.helper.json

    mkdir -p $out/share/applications $out/share/icons/hicolor/256x256/apps
    cp ./extracted/x64/installfiles/expressvpn.desktop $out/share/applications/
    cp ./extracted/x64/installfiles/app-icon.png $out/share/icons/hicolor/256x256/apps/expressvpn.png
    substituteInPlace $out/share/applications/expressvpn.desktop \
      --replace-fail "/opt/expressvpn/bin/expressvpn-client" "$out/bin/expressvpn-client" \
      --replace-fail "XDG_SESSION_TYPE=X11" "XDG_SESSION_TYPE=wayland"

    cat > $out/bin/qt.conf << EOF
[Paths]
Plugins=$out/plugins
Libraries=$out/lib
Qml2Imports=$out/qml
EOF

    # expressvpn-lightway spawns openvpn-updown.sh with a cleared environment (4 vars only).
    # Inject the PATH it needs as line 2, and fix the /usr/bin/systemctl hardcode.
    sed -i "2i export PATH=\"${coreutils}/bin:${findutils}/bin:${gnugrep}/bin:${gawk}/bin:${openresolv}/bin:${iproute2}/bin:${systemd}/bin:\$PATH\"" \
      $out/bin/openvpn-updown.sh
    substituteInPlace $out/bin/openvpn-updown.sh \
      --replace-fail '/usr/bin/systemctl' 'systemctl'

    # On NixOS, /etc/resolv.conf is a plain file managed by resolvconf (not a symlink to
    # /run/resolvconf/resolv.conf), so the upstream symlink check never matches and DNS
    # falls through to a direct overwrite that leaves no cleanup on crash. Drop the symlink
    # requirement and use resolvconf whenever it is available in PATH (injected above).
    # up) section uses "2> /dev/null" (space before /dev/null)
    substituteInPlace $out/bin/openvpn-updown.sh \
      --replace-fail \
        'elif [ $(realpath /etc/resolv.conf) = $resolvconf_link_path ] && hash resolvconf 2> /dev/null; then' \
        'elif hash resolvconf 2>/dev/null; then'
    # down) section uses "elif  " (two spaces) and "2>/dev/null" (no space) — different string, needs separate patch
    substituteInPlace $out/bin/openvpn-updown.sh \
      --replace-fail \
        'elif  [ $(realpath /etc/resolv.conf) = $resolvconf_link_path ] && hash resolvconf 2>/dev/null; then' \
        'elif hash resolvconf 2>/dev/null; then'

    runHook postInstall
  '';

  meta = with lib; {
    description = "ExpressVPN client";
    homepage = "https://www.expressvpn.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "expressvpnctl";
  };
}
