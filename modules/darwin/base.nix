{ inputs, ... }:
{
  imports = with inputs.self.darwinModules; [
    touch-id-sudo
    homebrew
    desktop
    skhd
    yabai
    ubersicht
    simple-bar
  ];
}
