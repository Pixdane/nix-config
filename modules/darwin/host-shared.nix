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

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # environment.systemPackages =
  #   [ pkgs.vim
  #   ];
}
