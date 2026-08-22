# S.M.A.R.T. drive health monitoring module
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.smartd;
in {
  options.cchharris.nixos.smartd = {
    enable = lib.mkEnableOption "S.M.A.R.T. drive health monitoring";
  };

  config = lib.mkIf cfg.enable {
    services.smartd = {
      enable = true;
      autodetect = true;
      # Short self-test daily, long self-test weekly, on every detected device
      defaults.monitored = "-a -o on -S on -s (S/../.././02|L/../../6/03)";
    };
  };
}
