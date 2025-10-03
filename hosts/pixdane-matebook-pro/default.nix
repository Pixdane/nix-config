{
  pkgs,
  user,
  ...
}:

{
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # environment.systemPackages =
  #   [ pkgs.vim
  #   ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # Set login shell to Nix's fish
  environment.shells = [
    pkgs.fish
    "/opt/homebrew.bin/fish" # Temporarily
  ];

  users.users.${user} = {
    shell = pkgs.fish;
    home = "/Users/${user}";
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  nixpkgs.config.allowUnfree = true;
}