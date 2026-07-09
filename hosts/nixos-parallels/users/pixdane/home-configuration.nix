{
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.self.homeModules.base ];

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
