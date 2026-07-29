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
    "nixYourShell"
    "payRespects"
    "tools"
  ];
}
