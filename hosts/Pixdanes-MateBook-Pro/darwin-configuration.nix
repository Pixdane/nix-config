{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.self.modules.system.base
    inputs.self.darwinModules.base
    inputs.self.darwinModules.host-shared
    inputs.self.darwinModules.yabai
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  pixdane.system = {
    nix.trustedUsers = [ "pixdane" ];
    fishShell.enable = true;
    helix.enable = true;
  };

  users.users.pixdane = {
    home = "/Users/pixdane";
    shell = pkgs.fish;
  };

  system.primaryUser = "pixdane";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # environment.systemPackages =
  #   [ pkgs.vim
  #   ];

  system.stateVersion = 6; # initial nix-darwin state
}
