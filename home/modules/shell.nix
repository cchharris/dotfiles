# Shell configuration (zsh + starship)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.shell;
in {
  options.cchharris.home.shell = {
    enable = lib.mkEnableOption "shell configuration (zsh + starship)";

    onePasswordAgent = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Point SSH_AUTH_SOCK at the 1Password agent socket. Turn off on hosts without 1Password (it would also clobber a forwarded `ssh -A` agent).";
    };

    claudeInstructions = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Deploy dot_claude/CLAUDE.md (personal repo map: dotfiles <-> homelab) to ~/.claude/CLAUDE.md. Off on work machines.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        ll = "ls -la";
        cat = "bat";
        update = "sudo nixos-rebuild boot --flake ~/dotfiles#$(hostname)";
        hm = "sudo nixos-rebuild switch --flake ~/dotfiles#$(hostname)";
      };

      plugins = [
        {
          name = "zsh-history-substring-search";
          src = pkgs.zsh-history-substring-search;
          file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
        }
      ];

      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };

      initContent = ''
        # Raise file descriptor limit (macOS launchd default is 256)
        ulimit -n 65536

        # Additional shell initialization
        bindkey -e  # Emacs keybindings

        # History substring search: bind up/down arrows
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
      '';
    };

    # Catppuccin Powerline preset (https://starship.rs/presets/catppuccin-powerline),
    # pinned to the Mocha flavor to match theming everywhere else (Ghostty, wayle, SDDM).
    # `presets` pulls the actual .toml shipped inside the starship package itself,
    # so this stays in sync with upstream instead of a hand-copied config.
    #
    # Over SSH, a separate mauve pill with the hostname is prepended so a remote
    # shell can't be mistaken for a local one. The preset's own `format` is read
    # back and prefixed rather than copied, for the same keep-in-sync reason.
    # (hostname's default ssh_only = true keeps local prompts unchanged.)
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      presets = [ "catppuccin-powerline" ];
      settings = {
        format = "$hostname" + (builtins.fromTOML (builtins.readFile
          "${config.programs.starship.package}/share/starship/presets/catppuccin-powerline.toml")).format;
        hostname = {
          ssh_symbol = "󰣀 ";
          style = "bg:mauve fg:crust";
          format = "[](mauve)[ $ssh_symbol$hostname ]($style)[](mauve) ";
        };
      };
    };

    # Useful CLI tools
    home.packages = with pkgs; [
      eza          # Modern ls
      bat          # Better cat
      fd           # Better find
      fzf          # Fuzzy finder
      ripgrep      # Better grep
      htop         # Process viewer
      tree         # Directory tree
      dust         # Better du
      duf          # Better df
      tldr         # Simplified man pages
      claude-code  # Claude AI assistant CLI
      (callPackage ../../pkgs/herdr.nix {}) # Terminal workspace manager for AI coding agents
      (callPackage ../../pkgs/herdr-core.nix {}) # herdr-core/hc: runs the Herdr app's terminals (also on remote machines it attaches)
    ] ++ lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
      gcc          # C compiler (Linux only — on macOS it shadows Apple clang and breaks native module builds)
    ];

    # User-level Claude Code instructions (shared with Windows via chezmoi)
    home.file.".claude/CLAUDE.md" = lib.mkIf cfg.claudeInstructions {
      source = ../../dot_claude/CLAUDE.md;
    };

    # 1Password SSH agent
    home.sessionVariables = lib.mkIf cfg.onePasswordAgent {
      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
    };

    # The same for apps started by the desktop session rather than a shell
    # (COSMIC reads environment.d; Hyprland sets it itself). Without this,
    # GUI apps fall back to whatever agent the session started.
    systemd.user.sessionVariables = lib.mkIf (cfg.onePasswordAgent && pkgs.stdenv.hostPlatform.isLinux) {
      SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
    };

    # Keep 1Password's SSH agent and its developer Watchtower (scans disk and
    # .env files for plaintext secrets and SSH keys) switched on. The app owns
    # settings.json and rewrites it, so only these keys are merged in, and only
    # once the app has created the file. The regular Watchtower checks aren't
    # in this file: they're on by default and kept with the account.
    home.activation.onePasswordSettings = lib.mkIf (cfg.onePasswordAgent && pkgs.stdenv.hostPlatform.isLinux)
      (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings="${config.xdg.configHome}/1Password/settings/settings.json"
        want='${builtins.toJSON {
          "sshAgent.enabled" = true;
          "devWatchtower.localDiskScanning" = true;
          "devWatchtower.envSubScanning" = true;
        }}'
        if [ -f "$settings" ]; then
          merged=$(${pkgs.jq}/bin/jq --argjson want "$want" '. + $want' "$settings")
          if [ "$merged" != "$(${pkgs.jq}/bin/jq . "$settings")" ]; then
            run ${pkgs.coreutils}/bin/install -m 600 /dev/stdin "$settings" <<< "$merged"
            echo "1Password: enforced SSH agent / developer Watchtower settings; restart 1Password to apply" >&2
          fi
        fi
      '');

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
    };

    # Terminal multiplexer — session persistence. Not shell-integrated (no
    # auto-start on new terminals) yet; invoke manually with `zellij`.
    programs.zellij = {
      enable = true;
      settings.theme = "catppuccin-mocha";
      # zellij ships no built-in themes — colors from catppuccin/zellij upstream.
      themes.catppuccin-mocha = ''
        themes {
          catppuccin-mocha {
            bg "#585b70"
            fg "#cdd6f4"
            red "#f38ba8"
            green "#a6e3a1"
            blue "#89b4fa"
            yellow "#f9e2af"
            magenta "#f5c2e7"
            orange "#fab387"
            cyan "#89dceb"
            black "#181825"
            white "#cdd6f4"
          }
        }
      '';
    };

    # Interactive cheatsheet — fuzzy-search (via fzf) commands, fill in
    # placeholder args, and it types the finished command into the shell.
    # navi defaults to shelling out via bash regardless of login shell,
    # which throws a harmless "bind: warning: line editing not enabled"
    # in non-interactive contexts. Tried pointing shell.command at zsh
    # to avoid it, but navi's own internal `fn` scripts (e.g. `navi fn
    # welcome`) are bash-specific and broke under zsh — reverted. The
    # warning is cosmetic; leave shell.command at its bash default.
    programs.navi = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "rg --files --hidden --follow --glob '!.git'";
      defaultOptions = [ "--height=40%" "--layout=reverse" "--border" ];
      changeDirWidget.options = [ "--preview 'eza --tree --color=always {} | head -200'" ];
      fileWidget.options = [ "--preview 'bat -n --color=always {}'" ];
    };
    catppuccin.fzf.enable = true;

    programs.bat.enable = true;
    catppuccin.bat.enable = true; # was hardcoded to TwoDark; catppuccin.bat sets the theme itself

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
