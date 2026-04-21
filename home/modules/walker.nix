# Walker application launcher
{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.cchharris.home.walker;
in {
  options.cchharris.home.walker = {
    enable = lib.mkEnableOption "Walker application launcher";
  };

  config = lib.mkIf cfg.enable {
    imports = [ inputs.walker.homeManagerModules.default ];

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
    };
  };
}
