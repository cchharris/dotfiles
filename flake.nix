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
    nixosConfigurations.razer-blade = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware/razer-blade.nix
        ./nixos/modules/defaults.nix
        ./nixos/modules/nvidia.nix
        ./nixos/modules/gaming.nix
        ./nixos/modules/desktop.nix
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
  };
}
