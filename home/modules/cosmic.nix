# COSMIC desktop user settings
#
# COSMIC stores each setting as its own small file under
# ~/.config/cosmic/<component>/v<N>/<key>, and its Settings app rewrites them in
# place. Symlinking them from the Nix store would make them read-only, so this
# module copies the repo's copies (home/cosmic/config) into place instead.
#
# Workflow: tune COSMIC in its Settings app, run `cosmic-capture` to copy every
# setting that differs from the shipped defaults into the repo, review the
# `git diff`, commit.
#
# Activation only writes a key when its repo copy changed since the last
# activation (tracked in ~/.local/state/cosmic-dotfiles), so a rebuild doesn't
# undo GUI tweaks that haven't been captured yet.
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.cosmic;
  repoConfig = ../cosmic/config;

  cosmicCapture = pkgs.writeShellScriptBin "cosmic-capture" ''
    set -euo pipefail
    live="''${XDG_CONFIG_HOME:-$HOME/.config}/cosmic"
    defaults=/run/current-system/sw/share/cosmic
    repo="''${1:-$HOME/dotfiles/home/cosmic/config}"

    cd "$live"
    count=0
    while IFS= read -r -d "" f; do
      f=''${f#./}
      case "$f" in
        # Generated from the *.Builder settings; capturing the Builder is enough
        com.system76.CosmicTheme.Dark/*|com.system76.CosmicTheme.Light/*) continue ;;
      esac
      if [ -f "$defaults/$f" ] && cmp -s "$f" "$defaults/$f"; then
        continue
      fi
      if ! cmp -s "$f" "$repo/$f" 2>/dev/null; then
        mkdir -p "$repo/$(dirname "$f")"
        cp "$f" "$repo/$f"
        echo "captured $f"
        count=$((count + 1))
      fi
    done < <(find . -type f -print0 | sort -z)
    echo "$count setting(s) updated in $repo; review with git diff"
  '';
in {
  options.cchharris.home.cosmic = {
    enable = lib.mkEnableOption "COSMIC desktop user settings";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cosmicCapture ];

    home.activation.cosmicConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      src=${repoConfig}
      live="${config.xdg.configHome}/cosmic"
      state="${config.xdg.stateHome}/cosmic-dotfiles"
      (cd "$src" && find . -type f ! -name .gitkeep) | while IFS= read -r f; do
        f=''${f#./}
        if ! cmp -s "$src/$f" "$state/$f" 2>/dev/null; then
          run mkdir -p "$live/$(dirname "$f")" "$state/$(dirname "$f")"
          run install -m 644 "$src/$f" "$live/$f"
          run install -m 644 "$src/$f" "$state/$f"
        fi
      done
    '';
  };
}
