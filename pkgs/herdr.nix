# Prebuilt binary release, not in nixpkgs, from herdrdev/herdr on GitHub.
# Hashes are prefetched directly from the release URLs (nix-prefetch-url) —
# Discord's disget registry (discord_disget/registry/*/dev.herdr.herdr) records
# different hashes for the same v0.8.2 tag, i.e. GitHub release assets were
# overwritten in place after disget last synced. Re-prefetch on version bumps.
{ lib, stdenv, fetchurl, autoPatchelfHook }:

let
  version = "0.9.5";
  platforms = {
    aarch64-darwin = {
      url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-macos-aarch64";
      hash = "sha256-+3fCIyoFqANUITgsiUOS9BdOTjihjkivPdApAVfDp+I=";
    };
    x86_64-linux = {
      url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-linux-x86_64";
      hash = "sha256-FNnovItKngEY13wyJm921GHwm0A0LrI3UpYL2J9Zkp0=";
    };
    aarch64-linux = {
      url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-linux-aarch64";
      hash = "sha256-F9dTby2lCFlSNoDvJ53/ysjkojX05G/o2mwuxEFBiXw=";
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
