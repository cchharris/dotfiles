# Walker application launcher
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.cchharris.home.walker;
in {
  options.cchharris.home.walker = {
    enable = lib.mkEnableOption "Walker application launcher";
  };

  imports = [ inputs.walker.homeManagerModules.default ];

  config = lib.mkIf cfg.enable {
    programs.walker = {
      enable = true;
      runAsService = true;

      config = {
        search.placeholder = "Search...";
        ui.fullscreen = false;
        list.height = 400;

        providers.prefixes = [
          { provider = "websearch"; prefix = "?"; }
          { provider = "runner";    prefix = "!"; }
          { provider = "finder";    prefix = "/"; }
        ];

        # Enabled providers
        builtins = {
          applications.enable = true;
          websearch.enable = true;
          runner.enable = true;
          finder.enable = true;
          clipboard.enable = true;
          calculator.enable = true;
          ssh.enable = true;
          windows.enable = true;
        };
      };

      theme.style = ''
        * {
          all: unset;
          font-family: "SauceCodePro Nerd Font", monospace;
          font-size: 14px;
          color: #cdd6f4;
        }

        .box-wrapper {
          background-color: #1e1e2e;
          border-radius: 12px;
          border: 1px solid #45475a;
          padding: 8px;
        }

        .input {
          background-color: #313244;
          color: #cdd6f4;
          border: 1px solid #45475a;
          border-radius: 8px;
          padding: 8px 12px;
          margin-bottom: 8px;
          caret-color: #89b4fa;
        }

        .input:focus {
          border-color: #89b4fa;
        }

        .item-box {
          padding: 6px 10px;
          border-radius: 6px;
        }

        .item-box:hover,
        .item-box:selected {
          background-color: #313244;
        }

        .item-text {
          color: #cdd6f4;
        }

        .item-subtext {
          color: #a6adc8;
          font-size: 12px;
        }

        .item-image {
          margin-right: 8px;
        }

        .item-quick-activation {
          color: #89b4fa;
          font-size: 11px;
        }

        .placeholder {
          color: #585b70;
          padding: 16px;
        }

        .elephant-hint {
          color: #585b70;
        }

        .calc {
          color: #a6e3a1;
        }

        .error {
          color: #f38ba8;
        }
      '';
    };
  };
}
