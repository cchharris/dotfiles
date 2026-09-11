# AMD GPU compute support (ROCm) — for an AMD card used as an
# ollama/llama.cpp/vLLM inference accelerator rather than a display GPU
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.nixos.amdgpu;
in {
  options.cchharris.nixos.amdgpu = {
    enable = lib.mkEnableOption "AMD GPU with ROCm compute support";
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.kernelModules = [ "amdgpu" ];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs.rocmPackages; [
        clr.icd
      ];
    };

    environment.systemPackages = with pkgs.rocmPackages; [
      rocminfo
      rocm-smi
    ];

    users.users.cchharris.extraGroups = [ "render" ];
  };
}
