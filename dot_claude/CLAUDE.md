# User-level instructions (all projects)

Managed from the dotfiles repo (`dot_claude/CLAUDE.md`): deployed by chezmoi on Windows
and by home-manager (`cchharris.home.shell`) on NixOS/macOS. Edit it there, not in `~/.claude/`.

## My infrastructure repos

Two repos describe one system. Changes to one often need a matching change in the other.

| Repo | GitHub | Windows | Linux / macOS | What it owns |
|---|---|---|---|---|
| dotfiles | `cchharris/dotfiles` (`main`) | `~/.local/share/chezmoi` | `~/dotfiles` | Every machine's OS and user config: real NixOS hosts razer-blade, hobbynix and nas (mainrig and aibox are speculative configs for machines that don't exist), nix-darwin, home-manager, chezmoi for Windows |
| homelab | `cchharris/homelab` (`master`) | `~/homelab` | `~/Repos/homelab` | The Turing Pi 2 Talos cluster, managed by Flux from `cluster/flux`: ingress, Pi-hole, Home Assistant, monitoring, Tailscale operator |

From NixOS-WSL, the Windows checkouts are under `/mnt/c/Users/Christopher Harris/`.
Each repo's own `CLAUDE.md` covers how to work in it. Read the other repo's `CLAUDE.md`
before editing anything on the far side of the boundary.

## Where they meet

**Source of truth for LAN addresses:** `homelab/NETWORK.md`. It also lists every file
that hard-codes an address.

| Coupling | homelab side | dotfiles side |
|---|---|---|
| Local CA for `*.home` HTTPS | `cluster/infrastructure-config/local-ca.yaml` (cert-manager creates it and holds the key) | `nixos/certs/homelab-ca.crt`, trusted by `nixos/modules/defaults.nix`, `darwin/modules/defaults.nix`, and `.chezmoiscripts/windows/run_onchange_trust-homelab-ca.cmd.tmpl` |
| NAS monitoring (`.20`, ports 9100/9134/9633 + Scrutiny 8081) | `cluster/monitoring-integrations/nas.yaml`, `cluster/monitoring/zfs-dashboard.yaml` | `nixos/modules/monitoring.nix` (exporters, firewall allowlist) |
| Cluster node IPs (`.31 .32 .34`) | `bootstrap/talos/talconfig.yaml` | `monitoring.nix` default `allowedFrom` |
| NAS services behind ingress (`scrutiny.home`, `nas-bmc.home`) | `cluster/apps/nas-services/nas-services.yaml` | `nixos/hosts/nas.nix`, `monitoring.nix` |
| LanCache game downloads | `cluster/apps/pihole/common-values.yaml`, `game-cache-values.yaml` (DNS overrides to `.20`) | `nixos/modules/lancache.nix` (on the NAS) |
| NFS for cluster storage (`/tank/k8s`) | Not used yet: PVCs are still on `local-path`. An NFS provisioner is future work | `nixos/modules/nfs.nix`, `nixos/hosts/nas.nix` |
| Cluster admin tooling | `talosVersion` / `kubernetesVersion` in `talconfig.yaml` | `home/modules/k8s.nix` (enabled on razer-blade) |
| Secrets | 1Password vault **Homelab**, read through ESO `ClusterSecretStore` and `bootstrap/talos/recover.sh` | Same vault: `nas.nix` deploy key (`op://Homelab/...`) |
| Tailscale | Operator, subnet router, and service proxies in `cluster/tailscale*` | `nixos/modules/tailscale.nix`. The NAS has its own tailnet identity so it doesn't depend on the cluster |

## Keeping them in sync

- When a change touches a row above, update both sides in the same session. Commit to
  each repo separately, and put the other repo's short SHA in each commit message
  (e.g. `pairs with homelab@abc1234`).
- A new hard-coded address in either repo gets a line under "Places that hard-code
  addresses" in `homelab/NETWORK.md`. A new coupling gets a row in the table above.
- **Rebuilding the cluster from zero rotates the local CA**, because cert-manager mints a
  new one. Afterwards, re-export it into dotfiles and re-apply on every machine:
  `kubectl -n cert-manager get secret homelab-ca-secret -o jsonpath='{.data.ca\.crt}' | base64 -d > nixos/certs/homelab-ca.crt`
- Check the live state before trusting the docs. `flux get kustomizations` and
  `kubectl get svc -A` answer questions about the cluster, and `nixos-rebuild dry-activate`
  answers questions about a host.
