{
  description = "Pixdane's NixOS + nix-darwin + home-manager config.";

  # Add all your dependencies here
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-python.url = "github:cachix/nixpkgs-python";

    helix-flake.url = "github:helix-editor/helix";

    nix-fish = {
      url = "github:kidonng/nix.fish";
      flake = false;
    };

    simple-bar = {
      url = "github:Jean-Tinland/simple-bar/7673cbbc56973748897bcae15afc135865694351";
      flake = false;
    };
  };

  # Load the blueprint
  outputs =
    inputs:
    inputs.blueprint {
      inherit inputs;
      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-linux"
        "x86_64-darwin"
      ];
      nixpkgs.config.allowUnfree = true;
    };
}
