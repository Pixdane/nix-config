{
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.self.homeModules.home-shared ];

  pixdane.features.enabled = [
    "fish"
    "git"
    "helix"
    "starship"
    "direnv"
    "zoxide"
    "zellij"
    "nixYourShell"
    "payRespects"
    "tools"
  ];
}
