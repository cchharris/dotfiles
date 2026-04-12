# Terminal configuration (ghostty)
{ config, lib, pkgs, ... }:

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
      theme = tokyonight

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
    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    # Font configuration
    fonts.fontconfig.enable = true;
  };
}
