{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  enabled = config.pixdane.features.helix.effectiveEnabled;
in
{
  imports = [
    ./settings.nix
    ./themes.nix
    ./languages.nix
    # ./latex-support.nix
  ];

  config = lib.mkIf enabled {
    programs.helix = {
      enable = true;
      package = inputs.helix-flake.packages.${pkgs.system}.default;
      defaultEditor = true;
    };
  };
}
