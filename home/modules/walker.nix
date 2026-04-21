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
    home.packages = [ inputs.elephant.packages.${pkgs.system}.default ];

    # Elephant must run in the user environment (not as a system service)
    # so it has access to user env vars, dbus session, etc.
    systemd.user.services.elephant = {
      Unit = {
        Description = "Elephant data provider service for Walker";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${inputs.elephant.packages.${pkgs.system}.default}/bin/elephant";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

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
