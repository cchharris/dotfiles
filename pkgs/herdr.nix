# Prebuilt binary release, not in nixpkgs, from herdrdev/herdr on GitHub.
# Hashes are prefetched directly from the release URLs (nix-prefetch-url) —
# Discord's disget registry (discord_disget/registry/*/dev.herdr.herdr) records
# different hashes for the same v0.8.2 tag, i.e. GitHub release assets were
# overwritten in place after disget last synced. Re-prefetch on version bumps.
{ lib, stdenv, fetchurl, autoPatchelfHook }:

let
  version = "0.8.2";
  platforms = {
    aarch64-darwin = {
      url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-macos-aarch64";
      hash = "sha256-pdT01QTYswnJH4EQUFWTAPq6MSWEJfU8UIUvyW9q5XQ=";
    };
    x86_64-linux = {
      url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-linux-x86_64";
      hash = "sha256-l2FQoU1JDJSyQ+ouGn6y37Z/EuNrGC25CTb2co5q7PQ=";
    };
    aarch64-linux = {
      url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-linux-aarch64";
      hash = "sha256-9VYQZY4cLg0qrvcwtLKriF9/i6AChas3K/sU8uPVtA0=";
    };
  };
  plat = platforms.${stdenv.hostPlatform.system}
    or (throw "herdr: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "herdr";
  inherit version;

  src = fetchurl {
    inherit (plat) url hash;
  };

  dontUnpack = true;
  nativeBuildInputs = lib.optionals stdenv.isLinux [ autoPatchelfHook ];
  autoPatchelfIgnoreMissingDeps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m 0755 $src $out/bin/herdr
    runHook postInstall
  '';

  meta = with lib; {
    description = "Terminal workspace manager for AI coding agents";
    homepage = "https://github.com/herdrdev/herdr";
    platforms = builtins.attrNames platforms;
    mainProgram = "herdr";
  };
}
