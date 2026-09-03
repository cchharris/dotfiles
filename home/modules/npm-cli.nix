# Globally-installed npm CLIs (for tools not packaged in nixpkgs).
#
# Why this exists: the system `npm` prefix points at the read-only nix store, so
# `npm install -g` fails. This module configures a user-writable prefix at
# ~/.npm-global, puts its bin/ on PATH, and runs `npm install -g` on hm switch
# for each declared package — only when the installed version doesn't match.
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.npmCli;
  prefix = "${config.home.homeDirectory}/.npm-global";

  installSnippet = pkg: version: ''
    current="$(${pkgs.nodejs}/bin/npm ls -g --depth=0 --json --prefix="${prefix}" 2>/dev/null \
      | ${pkgs.jq}/bin/jq -r '.dependencies."${pkg}".version // ""')"
    if [ "$current" != "${version}" ]; then
      echo "[npm-cli] Installing ${pkg}@${version} (was: ''${current:-none})"
      ${pkgs.nodejs}/bin/npm install -g --prefix="${prefix}" "${pkg}@${version}"
    fi
  '';

  installAll = lib.concatStringsSep "\n"
    (lib.mapAttrsToList installSnippet cfg.packages);
in {
  options.cchharris.home.npmCli = {
    enable = lib.mkEnableOption "npm-managed global CLI tools";
    packages = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = ''
        Map of npm package spec -> version string. Each entry is ensured at
        the declared version on hm switch via `npm install -g`.
      '';
      example = lib.literalExpression ''
        { "@agentclientprotocol/claude-agent-acp" = "0.33.1"; }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionPath = [ "${prefix}/bin" ];

    home.activation.installNpmGlobals =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "${prefix}"
        ${installAll}
      '';
  };
}
