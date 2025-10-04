{
  pkgs,
  pkgs-stable,
  user,
  ...
}: {
  imports = [
    ./default.nix
    ./config
  ];

  home.username = "${user}";
  home.homeDirectory = "/Users/${user}";

  home.packages = with pkgs; [
  ];

  home.stateVersion = "25.05";
}
