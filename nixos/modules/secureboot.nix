# Secure Boot + LUKS full-disk encryption module
# Requires a fresh install — cannot be applied to an existing unencrypted system.
# Enable this after reinstalling with LUKS partitions and enrolling Secure Boot keys.
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.secureboot;
in {
  options.cchharris.nixos.secureboot = {
    enable = lib.mkEnableOption "Secure Boot via lanzaboote + LUKS full-disk encryption";

    pkiBundle = lib.mkOption {
      type = lib.types.str;
      default = "/etc/secureboot";
      description = "Path to the Secure Boot key bundle (sbctl keys).";
    };

    tpmPcrs = lib.mkOption {
      type = lib.types.str;
      default = "0+7";
      description = ''
        TPM2 PCR banks to seal the LUKS key against.
        0 = firmware, 7 = Secure Boot state.
        Add PCR 4 to also bind to the bootloader binary.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Replace systemd-boot with lanzaboote
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.lanzaboote = {
      enable = true;
      pkiBundle = cfg.pkiBundle;
    };

    # sbctl for key management
    environment.systemPackages = [ pkgs.sbctl ];
  };
}
