{
  config,
  pkgs,
  pkgs-stable,
  ...
}:

{
  imports = [ ./git.nix ];
  
  home.username = "pixdane";
  home.homeDirectory = "/home/pixdane";

  home.packages = with pkgs; [
    zip
    xz
    unzip
  ];

  home.stateVersion = "25.05";
}
