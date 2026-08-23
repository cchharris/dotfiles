{
  description = "System configuration for cchharris";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland/v0.56.1";
    hyprtasking = {
      # matches hyprtasking's own hyprpm.toml compatibility pin for Hyprland v0.56.1.
      # No compatibility pin exists yet for v0.56.2 (latest), so staying one behind.
      url = "github:raybbian/hyprtasking/e68897e32fb5316bdfeae41268e6efb25a5dc4ea";
      inputs.hyprland.follows = "hyprland";
    };
    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
    # Wraps Nix-built OpenGL/EGL apps (e.g. ghostty) so they find the host's real Mesa
    # driver on non-NixOS Linux, where /run/opengl-driver doesn't exist. Kept on its
    # own nixpkgs pin rather than following the main one, since nixGL's driver
    # detection is tested against specific mesa versions upstream.
    nixgl.url = "github:nix-community/nixGL";
    # linux-cachyos kernel (BORE scheduler + LTO) + matching nvidia driver builds,
    # via a binary cache. Deliberately NOT following our nixpkgs — chaotic-nyx's
    # cache is built against their own pinned nixpkgs revision, and following ours
    # would cause cache misses (forcing a from-source kernel build).
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs:
  let
    mkPkgs = system: import nixpkgs { inherit system; config.allowUnfree = true; };
  in {
    # razer-blade configuration (Hyprland)
    nixosConfigurations.razer-blade = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.overlays = [ (final: prev: {
            expressvpn = final.callPackage ./pkgs/expressvpn.nix {};
            # egl-wayland2 1.0.1 returns fd 0 (stdin) instead of -1 on syncobj
            # creation failure, causing GLFenceEGL::ServerWait() to SIGSEGV in
            # Chromium-based browsers on NVIDIA Optimus Wayland. Fix is commit
            # aebd876 ("Return invalid fd on syncobj creation failure"), merged
            # Apr 28 2026 into main but not yet tagged as a release.
            egl-wayland2 = prev.egl-wayland2.overrideAttrs (_: {
              version = "1.0.2-unstable-2026-04-30";
              src = prev.fetchFromGitHub {
                owner = "NVIDIA";
                repo = "egl-wayland2";
                rev = "6d3d235808959a62259964c2dbd01ece594c1e7f";
                hash = "sha256-eFLxJ2SqnQjKfxwvbxMXcVDKPrdTpAuPE3H+SqDuSI4=";
              };
            });
            # openrazer 3.12.2 calls hid_report_raw_event() with 5 args but
            # Linux 6.18.33 changed its signature to require 6. Fixed in v3.12.3
            # (openrazer/openrazer commit ef57422, released 2026-05-21); nixpkgs
            # hasn't updated yet as of the 2026-05-23 nixos-unstable pin.
            linuxPackages = prev.linuxPackages.extend (_: lpPrev: {
              openrazer = lpPrev.openrazer.overrideAttrs (_: {
                src = prev.fetchFromGitHub {
                  owner = "openrazer";
                  repo = "openrazer";
                  tag = "v3.12.3";
                  hash = "sha256-X1NPqbugBdxD5Nt9wIwQADV4CuydGLpgKhlNazVdrIY=";
                };
              });
            });
        }) ]; }
        ./hardware/razer-blade.nix
        ./nixos/modules/defaults.nix
        ./nixos/modules/desktop-common.nix
        ./nixos/modules/nvidia.nix
        ./nixos/modules/gaming.nix
        ./nixos/modules/hyprland.nix
        ./nixos/modules/razer.nix
        ./nixos/modules/howdy.nix
        ./nixos/modules/tailscale.nix
        ./nixos/modules/cachyos.nix
        ./nixos/modules/cachyos-kernel.nix
        inputs.chaotic.nixosModules.default
        ./nixos/hosts/razer-blade.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.cchharris = import ./home/razer-blade.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };

    # hobbynix configuration (Hyprland)
    nixosConfigurations.hobbynix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.overlays = [ (final: prev: {
            expressvpn = final.callPackage ./pkgs/expressvpn.nix {};
            egl-wayland2 = prev.egl-wayland2.overrideAttrs (_: {
              version = "1.0.2-unstable-2026-04-30";
              src = prev.fetchFromGitHub {
                owner = "NVIDIA";
                repo = "egl-wayland2";
                rev = "6d3d235808959a62259964c2dbd01ece594c1e7f";
                hash = "sha256-eFLxJ2SqnQjKfxwvbxMXcVDKPrdTpAuPE3H+SqDuSI4=";
              };
            });
        }) ]; }
        ./hardware/hobbynix.nix
        ./nixos/modules/defaults.nix
        ./nixos/modules/desktop-common.nix
        ./nixos/modules/nvidia.nix
        ./nixos/modules/gaming.nix
        ./nixos/modules/hyprland.nix
        ./nixos/modules/tailscale.nix
        ./nixos/modules/xrdp.nix
        ./nixos/modules/fail2ban.nix
        ./nixos/hosts/hobbynix.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.cchharris = import ./home/hobbynix.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };

    # nas configuration (headless server — no home-manager/desktop modules)
    nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware/nas.nix
        ./nixos/modules/defaults.nix
        ./nixos/modules/tailscale.nix
        ./nixos/modules/fail2ban.nix
        ./nixos/modules/zfs.nix
        ./nixos/modules/nfs.nix
        ./nixos/modules/samba.nix
        ./nixos/modules/smartd.nix
        ./nixos/hosts/nas.nix
      ];
    };

    darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs; };
      modules = [
        ./darwin/modules/defaults.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.cchharris = import ./home/base-darwin.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };

    homeConfigurations.cchharris = home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs "x86_64-linux";
      extraSpecialArgs = { inherit inputs; };
      modules = [ ./home/base.nix ];
    };

    homeConfigurations."work-mac" = home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs "aarch64-darwin";
      extraSpecialArgs = { inherit inputs; };
      modules = [ ./home/work-mac.nix ];
    };

    # work-linux: standalone home-manager for non-NixOS work machines.
    # Apply with: nix run github:nix-community/home-manager/master -- switch --flake ~/dotfiles#work-linux --impure
    # (--impure is required so builtins.getEnv "USER" resolves at build time)
    homeConfigurations."work-linux" = home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs "x86_64-linux";
      extraSpecialArgs = { inherit inputs; };
      modules = [ ./home/work-linux.nix ];
    };
  };
}
