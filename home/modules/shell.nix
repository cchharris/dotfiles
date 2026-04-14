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
        update = "sudo nixos-rebuild switch --flake ~/dotfiles#$(hostname)";
        hm = "sudo nixos-rebuild switch --flake ~/dotfiles#$(hostname)";
      };

      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };

      initContent = ''
        # Additional shell initialization
        bindkey -e  # Emacs keybindings
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
      };
    };

    # Useful CLI tools
    home.packages = with pkgs; [
      eza          # Modern ls
      bat          # Better cat
      fd           # Better find
      fzf          # Fuzzy finder
      htop         # Process viewer
      tree         # Directory tree
      claude-code  # Claude AI assistant CLI
      _1password-cli # 1Password CLI (op)
    ];

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";
      };
    };
  };
}
