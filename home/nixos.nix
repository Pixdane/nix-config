{
  pkgs,
  pkgs-stable,
  user,
  ...
}:

{
  imports = [ ./config ];
  
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";

  home.packages = with pkgs; [
    zip
    xz
    unzip
  ];

  home.stateVersion = "25.05";
}
