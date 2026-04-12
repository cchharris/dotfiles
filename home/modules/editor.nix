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
    };

    # Deploy the full nvim config from dotfiles.
    # Plugins are managed by lazy.nvim at runtime; LSP servers are provided by nix below.
    xdg.configFile."nvim".source = ../../dot_config/nvim;

    home.packages = with pkgs; [
      # LSP servers (supplements Mason — nix-provided servers take priority on PATH)
      nil                           # Nix
      lua-language-server           # Lua
      bash-language-server          # Bash
      typescript-language-server    # TypeScript / JavaScript
      vscode-langservers-extracted  # HTML, CSS, JSON
      yaml-language-server          # YAML
      terraform-ls                  # Terraform
      taplo                         # TOML
      clang-tools                   # C / C++
      cmake-language-server         # CMake

      # Formatters / linters
      stylua
      shellcheck
      hadolint
      yamllint
      nodePackages.prettier
    ];
  };
}
