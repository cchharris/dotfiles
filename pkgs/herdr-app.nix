# Herdr desktop app (herdr-app), prebuilt from Herdr's release server; not in
# nixpkgs. It is a native GPU-rendered app that links only libxcb and
# libxkbcommon and dlopen()s Wayland, EGL and Vulkan, so those go on the
# runpath. The terminals themselves run in herdr-core (./herdr-core.nix),
# which the app finds on PATH.
#
# The app's own self-update can't write to the store; bump it here instead.
# To update: read version and sha256 from https://releases.herdr.dev/app/latest.json
# and convert with `nix hash convert --hash-algo sha256 --to sri <hex>`.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  addDriverRunpath,
  makeDesktopItem,
  copyDesktopItems,
  libxcb,
  libxkbcommon,
  libGL,
  vulkan-loader,
  wayland,
}:

let
  version = "0.1.18";
  platforms = {
    x86_64-linux = { target = "linux-x86_64"; hash = "sha256-ihHt153UCzSfcobPUZELYuIRNtr48DAFqf0sTcWDD4M="; };
    aarch64-linux = { target = "linux-aarch64"; hash = "sha256-O/UVBcsefWHmPM3CZV6IGfS0Urq+rZki/ku2/mnpE1A="; };
  };
  plat = platforms.${stdenv.hostPlatform.system}
    or (throw "herdr-app: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "herdr-app";
  inherit version;

  src = fetchurl {
    url = "https://releases.herdr.dev/app/${version}/herdr-app-${plat.target}.tar.gz";
    inherit (plat) hash;
  };

  nativeBuildInputs = [ autoPatchelfHook copyDesktopItems ];
  buildInputs = [ libxcb libxkbcommon stdenv.cc.cc.lib ];
  runtimeDependencies = map lib.getLib [ libGL vulkan-loader wayland libxkbcommon ];
  appendRunpaths = [ "${addDriverRunpath.driverLink}/lib" ];

  dontConfigure = true;
  dontBuild = true;

  # Same entry upstream's install.sh writes, with a store-path Exec.
  desktopItems = [
    (makeDesktopItem {
      name = "herdr-app";
      desktopName = "Herdr";
      comment = "Terminals and coding agents that keep running";
      exec = "herdr-app";
      icon = "herdr-app";
      categories = [ "Development" ];
      startupWMClass = "herdr-app";
    })
  ];

  installPhase = ''
    runHook preInstall
    install -Dm0755 herdr-app $out/bin/herdr-app
    install -Dm0644 herdr-app.svg $out/share/icons/hicolor/scalable/apps/herdr-app.svg
    runHook postInstall
  '';

  meta = {
    description = "Herdr desktop app: terminals and coding agents that keep running";
    homepage = "https://herdr.dev";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames platforms;
    mainProgram = "herdr-app";
  };
}
