{ ... }:
{
  imports = [
    ./features.nix
    ./cli
    ./helix
    ./ubersicht.nix
    ./window-manager
  ];

  home.stateVersion = "25.05";
}
