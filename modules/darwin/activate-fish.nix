{
  pkgs,
  inputs,
  ...
}: {
  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;

  # Set login shell to Nix's fish
  environment.shells = [
    pkgs.fish
  ];
}
