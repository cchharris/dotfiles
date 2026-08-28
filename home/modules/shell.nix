# Shell configuration (zsh + starship)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.shell;
in {
  options.cchharris.home.shell = {
    enable = lib.mkEnableOption "shell configuration (zsh + starship)";
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
        update = "sudo nixos-rebuild switch --flake ~/dotfiles#$(hostname)";
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
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      presets = [ "catppuccin-powerline" ];
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
    ] ++ lib.optionals (!pkgs.stdenv.isDarwin) [
      gcc          # C compiler (Linux only — on macOS it shadows Apple clang and breaks native module builds)
    ];

    # 1Password SSH agent
    home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";

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
      changeDirWidgetOptions = [ "--preview 'eza --tree --color=always {} | head -200'" ];
      fileWidgetOptions = [ "--preview 'bat -n --color=always {}'" ];
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
