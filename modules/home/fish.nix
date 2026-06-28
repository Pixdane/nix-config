{
  config,
  inputs,
  lib,
  ...
}:
let
  enabled = config.pixdane.features.fish.effectiveEnabled;
in
{
  config = lib.mkIf enabled {
    programs.fish = {
      enable = true;

      shellAliases = {
        "..." = "cd ../..";
      };

      plugins = [
        {
          name = "nix.fish";
          src = inputs.nix-fish;
        }
      ];
    };
  };
}
