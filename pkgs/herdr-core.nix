# herdr-core (`hc`): the background server that runs the Herdr desktop app's
# terminals and agents, so they outlive the window. Prebuilt from Herdr's own
# release server, not in nixpkgs. The Linux build is static, so it needs no
# patching. Herdr finds it on PATH; its in-app "Update herdr-core" can't
# replace a store path, so bump it here instead.
#
# To update: read version and sha256 per target from
#   https://releases.herdr.dev/core/latest.json
# and convert each with `nix hash convert --hash-algo sha256 --to sri <hex>`.
{ lib, stdenv, fetchurl }:

let
  version = "0.1.22";
  platforms = {
    x86_64-linux = { target = "linux-x86_64"; hash = "sha256-MFTsOZLOgMVxXXIcqp3O+mBWch0V3BE/R1CvznY7pd8="; };
    aarch64-linux = { target = "linux-aarch64"; hash = "sha256-mHV5hSRdRfjXPdheaLE5t/FnwoSIu4nt2YNMP1pc9M8="; };
    aarch64-darwin = { target = "macos-aarch64"; hash = "sha256-kHmNqt76jRJrkO8Lzb6cfdqcbPvwEaJHBlq12jSPNQ4="; };
  };
  plat = platforms.${stdenv.hostPlatform.system}
    or (throw "herdr-core: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "herdr-core";
  inherit version;

  src = fetchurl {
    url = "https://releases.herdr.dev/core/${version}/herdr-core-${plat.target}.tar.gz";
    inherit (plat) hash;
  };

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm0755 herdr-core $out/bin/herdr-core
    ln -s herdr-core $out/bin/hc
    runHook postInstall
  '';

  meta = {
    description = "Background server for Herdr's terminals and coding agents (hc)";
    homepage = "https://herdr.dev";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames platforms;
    mainProgram = "hc";
  };
}
