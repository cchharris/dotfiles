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

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        character = {
          success_symbol = "[>](bold green)";
          error_symbol = "[x](bold red)";
        };
        directory = {
          truncation_length = 3;
          truncate_to_repo = true;
        };
        git_branch = {
          symbol = " ";
        };
        nix_shell = {
          symbol = " ";
          format = "via [$symbol$state]($style) ";
        };
        golang = {
          disabled = true;
        };
        command_timeout = 2000;
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
      tldr         # Simplified man pages
      claude-code  # Claude AI assistant CLI
      gcc          # C compiler
    ];

    # 1Password SSH agent
    home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";

    programs.eza = {
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

    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };

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
