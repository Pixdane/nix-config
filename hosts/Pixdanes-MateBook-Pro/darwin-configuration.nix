{
  pkgs,
  inputs,
  ...
}: {
  imports = [inputs.self.darwinModules.host-shared];

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.pixdane.home = /Users/pixdane;

  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # environment.systemPackages =
  #   [ pkgs.vim
  #   ];

  # Set login shell to Nix's fish
  environment.shells = [
    pkgs.fish
  ];

  system.stateVersion = 6; # initial nix-darwin state
}
