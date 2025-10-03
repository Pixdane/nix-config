{
  pkgs,
  pkgs-stable,
  user,
  ...
}:

{
  imports = [ ./config ];
  
  home.username = "${user}";
  home.homeDirectory = "/Users/${user}";
  home.packages = with pkgs; [];
  home.stateVersion = "25.05";
}
