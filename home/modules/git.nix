# Git configuration
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.git;
  # 1Password SSH agent socket path.
  # On macOS, the real socket is at ~/Library/Group Containers/.../agent.sock (path with space).
  # A space-free symlink is created at ~/.1password/agent.sock on each macOS machine (one-time
  # manual step: mkdir -p ~/.1password && ln -sf "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ~/.1password/agent.sock).
  # This lets us use the same path on Linux and macOS.
  opAgentSock = "~/.1password/agent.sock";
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

    manageSshConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether home-manager owns ~/.ssh/config outright (as a read-only
        symlink into the nix store). Set false on machines where something
        else (Teleport tsh, corp MDM device-trust tooling, etc.) needs to
        write Host blocks into ~/.ssh/config directly - home-manager can't
        share ownership of that file. When false, the 1Password IdentityAgent
        routing is written to ~/.ssh/conf.d/nix-managed.conf instead, and
        ~/.ssh/config itself is left alone for other tools to manage. You
        must manually add `Include ~/.ssh/conf.d/nix-managed.conf` as the
        first line of ~/.ssh/config (one-time, since that file is no longer
        nix-managed) - a home-manager activation check warns if it's missing.
      '';
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.manageSshConfig {
      # SSH configuration for 1Password agent
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        # Include 1Password's generated config which maps specific keys to hosts.
        # 1Password writes this file automatically; it's what routes the correct
        # key to each host (e.g. personal key for github.com vs work key).
        includes = lib.optionals pkgs.stdenv.isDarwin [ "~/.ssh/1Password/config" ];
        settings."*" = {
          IdentityAgent = opAgentSock;
        };
      };
    })

    (lib.mkIf (!cfg.manageSshConfig) {
      home.file.".ssh/conf.d/nix-managed.conf".text = ''
        # Managed by home-manager (cchharris.home.git.manageSshConfig = false).
        # ~/.ssh/config itself is intentionally left mutable on this machine, so
        # it must Include this file (as the first line) for the settings below
        # to take effect.
      ''
      + lib.optionalString pkgs.stdenv.isDarwin ''
        Include ~/.ssh/1Password/config
      ''
      + ''
        Host *
            IdentityAgent ${opAgentSock}
      '';

      home.activation.checkSshConfigInclude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        sshConfig="$HOME/.ssh/config"
        if [ -f "$sshConfig" ] && ! grep -q "conf.d/nix-managed.conf" "$sshConfig"; then
          echo "Warning: $sshConfig does not Include ~/.ssh/conf.d/nix-managed.conf" >&2
          echo "  Add this as the first line of $sshConfig for the 1Password IdentityAgent routing to apply:" >&2
          echo "    Include ~/.ssh/conf.d/nix-managed.conf" >&2
        fi
      '';
    })

    {
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
    }
  ]);
}
