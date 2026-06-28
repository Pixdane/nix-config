{ inputs, ... }:
{
  imports = with inputs.self.darwinModules; [
    touch-id-sudo
    homebrew
    desktop
    skhd
  ];
}
