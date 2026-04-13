# hobbynix host configuration
{ config, lib, pkgs, ... }:

{
  # Hostname
  networking.hostName = "hobbynix";

  # Enable features for this machine
  cchharris.nixos = {
    nvidia = {
      enable = true;
      openDrivers = false;  # Using proprietary drivers
      optimus.enable = false;  # Single NVIDIA GPU, no Optimus
    };
    hyprland.enable = true;
    tailscale.enable = true;
    xrdp.enable = true;
    fail2ban.enable = true;
  };

  # Bluetooth configuration
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  # Enhanced SSH security (hobbynix is internet-facing)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      AllowUsers = [ "cchharris" ];
    };
  };

  # 1Password
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "cchharris" ];
  };

  # Steam gaming support
  programs.steam.enable = true;

  # zsh
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];
  users.defaultUserShell = pkgs.zsh;

  # System state version
  system.stateVersion = "25.11";
}
