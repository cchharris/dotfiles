# Terminal configuration (ghostty)
{ config, lib, pkgs, inputs, osConfig ? null, ... }:

let
  cfg = config.cchharris.home.terminal;
in {
  options.cchharris.home.terminal = {
    enable = lib.mkEnableOption "terminal configuration (ghostty)";
  };

  config = lib.mkIf cfg.enable {
    # Ghostty configuration
    xdg.configFile."ghostty/config".text = ''
      # Font settings
      font-family = JetBrainsMono Nerd Font
      font-size = 12

      # Theme
      theme = Catppuccin Mocha

      # Window settings
      window-padding-x = 10
      window-padding-y = 10
      window-decoration = true

      # Cursor
      cursor-style = block
      cursor-style-blink = true

      # Scrollback
      scrollback-limit = 10000

      # Shell
      command = ${pkgs.zsh}/bin/zsh
      shell-integration = zsh

      # Keybindings
      keybind = ctrl+shift+c=copy_to_clipboard
      keybind = ctrl+shift+v=paste_from_clipboard
      keybind = ctrl+shift+n=new_window
      keybind = ctrl+shift+t=new_tab
      keybind = ctrl+shift+w=close_surface
    '';

    # Install Nerd Font for terminal icons
    # ghostty-bin provides pre-built macOS binaries (pkgs.ghostty is broken on darwin)
    # On NixOS hosts, ghostty is installed via the system module instead (nixos/modules/hyprland.nix,
    # gnome.nix), which wires up /run/opengl-driver for Mesa/EGL discovery. Standalone (non-NixOS)
    # Linux targets like work-linux/base lack that, so ghostty needs a nixGL wrapper to find the
    # host's real driver — detected via `osConfig == null`, which home-manager only sets when NOT
    # integrated into a nixosSystem/darwinSystem.
    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      ghostty-bin
    ] ++ lib.optionals (pkgs.stdenv.isLinux && osConfig == null) [
      (pkgs.writeShellScriptBin "ghostty" ''
        exec ${inputs.nixgl.packages.${pkgs.system}.nixGLDefault}/bin/nixGL ${pkgs.ghostty}/bin/ghostty "$@"
      '')
    ];

    # Font configuration
    fonts.fontconfig.enable = true;
  };
}
