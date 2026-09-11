# AI/inference host configuration — dual-GPU: NVIDIA RTX 5080 + AMD RX 7900 XTX
#
# TEMPLATE — finish this after the physical build:
#   1. Run `nixos-generate-config` on the actual box and replace
#      ../../hardware/aibox.nix with its output.
#   2. Confirm both GPUs enumerate correctly: `nvidia-smi` for the 5080,
#      `rocminfo`/`rocm-smi` for the 7900 XTX. If one is silently missing,
#      check `lspci -k` for which driver is bound to each PCI device —
#      a single misdetected card is the most common dual-GPU failure mode.
#   3. No app-level GPU placement is configured yet (e.g. no services.ollama
#      here) since that module only supports one accelerator backend per
#      instance. Once real workloads are known, either run two separate
#      inference services pinned via CUDA_VISIBLE_DEVICES / HIP_VISIBLE_DEVICES,
#      or launch containers per card manually.
#   4. Confirm the PSU has headroom: 5080 (~360W) + 7900 XTX (~355W) + the
#      rest of the system comfortably wants a 1200W+ unit.
{ config, lib, pkgs, ... }:

{
  networking.hostName = "aibox";

  cchharris.nixos = {
    nvidia.enable = true;  # RTX 5080 — standalone, no Optimus (single discrete NVIDIA card)
    amdgpu.enable = true;  # RX 7900 XTX — ROCm compute
    tailscale.enable = true;
  };

  # Enhanced SSH security (mirrors nas/hobbynix — remote-access target)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      AllowUsers = [ "cchharris" ];
    };
  };

  system.stateVersion = "25.11";
}
