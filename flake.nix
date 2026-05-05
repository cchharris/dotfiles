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
    hyprland.url = "github:hyprwm/Hyprland/v0.54.3";
    hyprtasking = {
      url = "github:raybbian/hyprtasking";
      inputs.hyprland.follows = "hyprland";
    };
    elephant.url = "github:abenz1267/elephant";
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
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
