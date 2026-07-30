{ ... }:
{
  imports = [
    ./features.nix
    ./cli
    ./helix
    ./rime.nix
    ./ubersicht.nix
    ./window-manager
  ];

  home.stateVersion = "26.05";
}
