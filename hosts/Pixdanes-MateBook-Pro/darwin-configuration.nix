{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.self.modules.common.host-shared
    inputs.self.darwinModules.host-shared
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.pixdane.home = /Users/pixdane;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # environment.systemPackages =
  #   [ pkgs.vim
  #   ];

  system.stateVersion = 6; # initial nix-darwin state
}
