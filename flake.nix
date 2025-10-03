{
  description = "Test NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    ...
  }: {
    nixosConfigurations = {
      # Host name
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
  };
}
