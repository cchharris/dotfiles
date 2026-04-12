# Editor configuration (neovim)
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.editor;
in {
  options.cchharris.home.editor = {
    enable = lib.mkEnableOption "editor configuration (neovim)";
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      plugins = with pkgs.vimPlugins; [
        nvim-treesitter.withAllGrammars
      ];
    };

    # Deploy the full nvim config from dotfiles.
    # Plugins are managed by lazy.nvim at runtime; LSP servers are provided by nix below.
    xdg.configFile."nvim".source = ../../dot_config/nvim;

    home.packages = with pkgs; [
      # LSP servers — nix provides these so Mason doesn't try to install on NixOS
      nil                           # Nix
      lua-language-server           # Lua
      bash-language-server          # Bash
      typescript-language-server    # TypeScript / JavaScript (tsserver)
      typescript-go                 # tsgo — Microsoft's Go-based TS server
      vscode-langservers-extracted  # HTML, CSS, JSON, ESLint
      yaml-language-server          # YAML
      terraform-ls                  # Terraform
      taplo                         # TOML
      clang-tools                   # C / C++
      cmake-language-server         # CMake
      ruff                          # Python (linter + LSP)
      tailwindcss-language-server   # Tailwind CSS
      dockerfile-language-server-nodejs # Docker
      vim-language-server           # Vimscript
      buf                           # Protobuf (buf_ls)
      zls                           # Zig

      # Formatters / linters
      stylua
      shellcheck
      hadolint
      yamllint
      prettier
      eslint                        # JS/TS linter
      tflint                        # Terraform linter
      gnumake
    ];
  };
}
