# Kubernetes / homelab tooling
{ config, lib, pkgs, ... }:

let
  cfg = config.cchharris.home.k8s;
in {
  options.cchharris.home.k8s = {
    enable = lib.mkEnableOption "Kubernetes / homelab tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      talosctl          # Talos Linux node management
      kubectl           # Kubernetes CLI
      fluxcd            # Flux GitOps CLI
      talhelper         # Generate Talos node configs from talconfig.yaml
      kubernetes-helm   # Helm CLI (ad-hoc chart inspection)
      k9s               # Interactive Kubernetes TUI
    ];

    programs.zsh.shellAliases = {
      k    = "kubectl";
      kgp  = "kubectl get pods -A";
      kgn  = "kubectl get nodes";
      kaf  = "kubectl apply -f";
      kctx = "kubectl config use-context";
      fgk  = "flux get kustomizations";
      fgh  = "flux get helmreleases -A";
    };
  };
}
