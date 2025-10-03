{
  description = "Test NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixpkgs-stable,
    nix-darwin,
    home-manager,
    ...
  }: {
    # NixOS
    nixosConfigurations = {
      nixos-parallels = nixpkgs.lib.nixosSystem {
        specialArgs = let
          system = "aarch64-linux";
        in {
          pkgs-stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        };
        
        modules = [
          ./hosts/nixos-parallels

          home-manager.nixosModules.home-manager

          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.pixdane = import ./home;

            # home-manager.extraSpecialArgs = inputs;  
          }
        ];
      };
    };

    darwinConfigurations.Pixdanes-MateBook-Pro = nix-darwin.lib.darwinSystem {
        modules = [ ./hosts/pixdane-matebook-pro ];
    };
  };
}
