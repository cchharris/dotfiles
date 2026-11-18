# Claude Desktop (GUI), repackaged from Anthropic's official Linux .deb.
#
# Anthropic ships Linux builds (beta since 2026-06-30) only as a .deb from their
# own APT repo, and nixpkgs doesn't package it. This follows the nixpkgs
# discord/slack pattern: unpack the vendor tree, autoPatchelf the bundled
# Electron, and keep its ELF in place (not a nixpkgs electron) so
# process.resourcesPath resolves inside this store path.
#
# To update: read the Version from
#   https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages
# then `nix store prefetch-file <deb url>` for the new hash.
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  addDriverRunpath,
  makeWrapper,
  asar,
  # DT_NEEDED of the bundled ELFs
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libgbm,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  pango,
  systemd,
  libcap_ng,
  libseccomp,
  # dlopen'd at runtime
  libGL,
  libayatana-appindicator,
  libnotify,
  libpulseaudio,
  libsecret,
  libuuid,
  libxtst,
  pciutils,
  pipewire,
  wayland,
  # host helpers the app spawns by absolute path
  bash,
  procps,
}:

let
  version = "5.11492.0";

  # The app spawns these by absolute path. NixOS has no /usr/bin (bar env) and
  # no /bin/bash, so they're rewritten to store paths inside app.asar.
  # /bin/bash matters most: Claude Code sessions' persistent shell uses it.
  hostHelpers = {
    "/bin/bash" = "${bash}/bin/bash";
    "/bin/ps" = "${procps}/bin/ps";
    "/usr/bin/pgrep" = "${procps}/bin/pgrep";
    "/usr/bin/busctl" = "${systemd}/bin/busctl";
    "/usr/bin/secret-tool" = "${libsecret}/bin/secret-tool";
  };

  # Fails the build if an upstream re-minification moves a literal, rather
  # than silently shipping a dead path.
  rewriteHelper = from: to: ''
    files=$(grep -rlF --include='*.js' '"${from}"' "$work/app" || true)
    [[ -n $files ]] || { echo "claude-desktop: \"${from}\" not found in app.asar" >&2; exit 1; }
    for f in $files; do
      substituteInPlace "$f" --replace-fail '"${from}"' '"${to}"'
      patched+=("$f")
    done
  '';
in
stdenv.mkDerivation {
  pname = "claude-desktop";
  inherit version;

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${version}_amd64.deb";
    hash = "sha256-nFz11MiyNWd5o93n3t/hwwGnIjlxWXGYIT2BX+jM+lU=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook makeWrapper asar ];

  buildInputs = [
    alsa-lib at-spi2-atk at-spi2-core atk cairo cups dbus expat glib gtk3
    libcap_ng libgbm libseccomp libxkbcommon nspr nss pango pipewire systemd
    libx11 libxcb libxcomposite libxdamage libxext libxfixes libxrandr
    stdenv.cc.cc.lib
  ];

  runtimeDependencies = map lib.getLib [
    libGL libayatana-appindicator libnotify libpulseaudio libsecret libuuid
    libxtst pciutils pipewire systemd wayland
  ];

  # chrome-sandbox is SUID in the .deb, which tar can't restore in the build
  # sandbox (and the store can't hold). Chromium uses the userns sandbox on
  # NixOS anyway, so the helper is never invoked.
  unpackPhase = ''
    dpkg-deb --fsys-tarfile "$src" | tar -x --no-same-owner --no-same-permissions
  '';

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -a usr/lib usr/share $out/

    # Wrap the in-tree ELF (not a symlink) so /proc/self/exe stays in the
    # store path. The bundled Vulkan loader only searches FHS ICD dirs, so
    # point it at NixOS's driver dir or it falls back to SwiftShader.
    makeWrapper $out/lib/claude-desktop/claude-desktop $out/bin/claude-desktop \
      --prefix VK_ADD_DRIVER_FILES : "${addDriverRunpath.driverLink}/share/vulkan/icd.d"

    runHook postInstall
  '';

  postInstall = ''
    resources=$out/lib/claude-desktop/resources
    work=$(mktemp -d)
    patched=()
    asar extract "$resources/app.asar" "$work/app"

    ${lib.concatStrings (lib.mapAttrsToList rewriteHelper hostHelpers)}

    # V8 would happily reuse a stale code cache for the patched files.
    for f in "''${patched[@]}"; do
      rm -f "$work/app/compile-cache/$(basename "$f")".*.jsc
    done

    # Repack with the same set of files left unpacked as upstream shipped.
    (cd "$resources/app.asar.unpacked" && find . -type f | sort) > "$work/unpacked"
    unpack="{$(sed "s|^\./|$work/app/|" "$work/unpacked" | paste -sd,)}"
    mkdir "$work/out"
    asar pack "$work/app" "$work/out/app.asar" --unpack "$unpack"
    diff -r "$resources/app.asar.unpacked" "$work/out/app.asar.unpacked"
    while read -r f; do
      chmod --reference="$resources/app.asar.unpacked/$f" "$work/out/app.asar.unpacked/$f"
    done < "$work/unpacked"

    rm -r "$resources/app.asar" "$resources/app.asar.unpacked"
    mv "$work/out/app.asar" "$work/out/app.asar.unpacked" "$resources/"
    rm -r "$work"
  '';

  preFixup = ''
    addAutoPatchelfSearchPath "$out/lib/claude-desktop"
  '';

  # Bundled ANGLE dlopen()s libEGL.so.1 by soname from its own .so, so the
  # GL dispatcher and host driver dir must be on every ELF's runpath, not
  # just the executable's.
  appendRunpaths = [
    "${lib.getLib libGL}/lib"
    "${addDriverRunpath.driverLink}/lib"
  ];

  meta = {
    description = "Claude Desktop for Linux (official .deb, repackaged)";
    homepage = "https://claude.ai/download";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude-desktop";
  };
}
