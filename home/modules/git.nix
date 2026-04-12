# Git configuration
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.git;
in {
  options.cchharris.home.git = {
    enable = lib.mkEnableOption "git configuration";

    userName = lib.mkOption {
      type = lib.types.str;
      default = "Christopher Harris";
      description = "Git user name";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      default = "cchharris@users.noreply.github.com";
      description = "Git user email";
    };
  };

  config = lib.mkIf cfg.enable {
    # SSH configuration for 1Password agent
    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host *
          IdentityAgent ~/.1password/agent.sock
      '';
    };

    # Set SSH_AUTH_SOCK for 1Password
    home.sessionVariables = {
      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
    };

    programs.git = {
      enable = true;

      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push.autoSetupRemote = true;
        core.editor = "nvim";
        core.sshCommand = "ssh -o IdentityAgent=~/.1password/agent.sock";
        diff.colorMoved = "default";
        merge.conflictstyle = "diff3";
        alias = {
          st = "status";
          co = "checkout";
          br = "branch";
          ci = "commit";
          lg = "log --graph --oneline --decorate --all";
          unstage = "reset HEAD --";
          last = "log -1 HEAD";
          amend = "commit --amend --no-edit";
        };
      };

      ignores = [
        ".DS_Store"
        "*.swp"
        "*.swo"
        "*~"
        ".direnv"
        ".envrc"
        "result"
        "result-*"
      ];
    };

    programs.delta = {
      enable = true;
      enableGitIntegration = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };
    };

    programs.gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };

    programs.lazygit = {
      enable = true;
    };

    home.packages = with pkgs; [
      git-crypt
    ];
  };
}
