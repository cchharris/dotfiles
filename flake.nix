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
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs:
  let
    mkPkgs = system: import nixpkgs { inherit system; config.allowUnfree = true; };
  in {
    # razer-blade configuration (GNOME)
    nixosConfigurations.razer-blade = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware/razer-blade.nix
        ./nixos/modules/defaults.nix
        ./nixos/modules/desktop-common.nix
        ./nixos/modules/nvidia.nix
        ./nixos/modules/gaming.nix
        ./nixos/modules/gnome.nix
        ./nixos/modules/razer.nix
        ./nixos/hosts/razer-blade.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.cchharris = import ./home/base.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };

    # hobbynix configuration (Hyprland)
    nixosConfigurations.hobbynix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
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

    homeConfigurations."christopherharris" = home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs "aarch64-darwin";
      extraSpecialArgs = { inherit inputs; };
      modules = [ ./home/work-mac.nix ];
    };

    # work-linux: standalone home-manager for non-NixOS work machines.
    # Apply with: home-manager switch --flake ~/dotfiles#work-linux --impure
    # (--impure is required so builtins.getEnv "USER" resolves at build time)
    homeConfigurations."work-linux" = home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs "x86_64-linux";
      extraSpecialArgs = { inherit inputs; };
      modules = [ ./home/work-linux.nix ];
    };
  };
}
